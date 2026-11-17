#!/usr/bin/env python3
"""Congela o diff de um PR e prepara o fan-out de revisão.

Porta a preparação do `/review` do OMP: filtra arquivos que não valem revisão
(lockfiles, minificados, gerados, binários...), calcula quantos revisores usar
pelo tamanho do diff, agrupa os arquivos por localidade e escreve cada diff em
disco para os revisores lerem sem rodar `git diff` de novo.

Uso:
    review_snapshot.py [PR] [--out DIR] [--diff-file ARQUIVO]

PR é um número, uma URL de PR ou `owner/repo#N`; sem PR, usa o PR da branch
atual (`gh pr view`). Saída em DIR (padrão /tmp/pr-review-<owner>-<repo>-<N>):

    all.diff              diff completo, como o gh devolveu
    files/NN-<slug>.diff  diff de cada arquivo revisável (NN = índice no diff)
    commentable.json      linhas alteradas por arquivo: RIGHT (+) e LEFT (-)
    snapshot.json         metadados, tabela, grupos e contagem de revisores
    snapshot.md           o mesmo resumo que vai para o stdout
"""
import argparse
import json
import os
import re
import subprocess
import sys

MAX_INLINE_CHARS = 50000
MAX_INLINE_FILES = 20

EXCLUSIONS = [
    (r"\.lock$", "lock file"),
    (r"-lock\.(json|yaml|yml)$", "lock file"),
    (r"package-lock\.json$", "lock file"),
    (r"yarn\.lock$", "lock file"),
    (r"pnpm-lock\.yaml$", "lock file"),
    (r"Cargo\.lock$", "lock file"),
    (r"Gemfile\.lock$", "lock file"),
    (r"poetry\.lock$", "lock file"),
    (r"composer\.lock$", "lock file"),
    (r"flake\.lock$", "lock file"),
    (r"\.min\.(js|css)$", "minificado"),
    (r"\.generated\.", "gerado"),
    (r"\.snap$", "snapshot"),
    (r"\.map$", "source map"),
    (r"^dist/", "build output"),
    (r"^build/", "build output"),
    (r"^out/", "build output"),
    (r"node_modules/", "vendor"),
    (r"vendor/", "vendor"),
    (r"(?i)\.(png|jpg|jpeg|gif|ico|webp|avif)$", "imagem"),
    (r"(?i)\.(woff|woff2|ttf|eot|otf)$", "fonte"),
    (r"(?i)\.(pdf|zip|tar|gz|rar|7z)$", "binário"),
]
EXCLUSIONS = [(re.compile(p), r) for p, r in EXCLUSIONS]
HUNK = re.compile(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@")


def run(cmd):
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode != 0:
        sys.exit("erro: %s\n%s" % (" ".join(cmd), p.stderr.strip()))
    return p.stdout


def resolve_pr(arg):
    """Devolve (url, owner, repo, number, meta) para número, URL ou owner/repo#N."""
    target = []
    if arg:
        m = re.match(r"^([\w.-]+/[\w.-]+)#(\d+)$", arg)
        if m:
            target = ["--repo", m.group(1), m.group(2)]
        else:
            target = [arg]
    fields = "url,number,title,baseRefName,headRefName,headRefOid,baseRefOid,isDraft,state"
    meta = json.loads(run(["gh", "pr", "view"] + target + ["--json", fields]))
    m = re.match(r"https://[^/]+/([^/]+)/([^/]+)/pull/(\d+)", meta["url"])
    return meta["url"], m.group(1), m.group(2), int(m.group(3)), meta


def parse_diff(raw):
    starts = [m.start() for m in re.finditer(r"^diff --git ", raw, re.M)]
    blocks = []
    for i, s in enumerate(starts):
        e = starts[i + 1] if i + 1 < len(starts) else len(raw)
        blocks.append(re.sub(r"\r?\n$", "", raw[s:e]))
    return blocks


def paths_of(block):
    old = new = None
    for line in block.split("\n"):
        if line.startswith("--- "):
            old = line[4:]
        elif line.startswith("+++ "):
            new = line[4:]
        elif line.startswith("@@"):
            break
    def clean(p):
        if p is None or p == "/dev/null":
            return None
        return re.sub(r"^[ab]/", "", p.split("\t")[0])
    old, new = clean(old), clean(new)
    if old is None and new is None:  # rename puro, binário ou modo: cai no cabeçalho
        m = re.match(r"diff --git a/(.+?) b/(.+)$", block.split("\n", 1)[0])
        if m:
            old, new = m.group(1), m.group(2)
    return old, new


def scan(block):
    """Conta +/- e coleta as linhas alteradas (RIGHT = novas, LEFT = removidas)."""
    added = removed = 0
    right, left = [], []
    old_n = new_n = 0
    in_hunk = False
    for line in block.split("\n"):
        m = HUNK.match(line)
        if m:
            old_n, new_n, in_hunk = int(m.group(1)), int(m.group(2)), True
            continue
        if not in_hunk or line.startswith("\\"):
            continue
        if line.startswith("+"):
            right.append(new_n)
            new_n += 1
            added += 1
        elif line.startswith("-"):
            left.append(old_n)
            old_n += 1
            removed += 1
        elif line.startswith(" "):
            old_n += 1
            new_n += 1
    return added, removed, right, left


def ranges(nums):
    out = []
    for n in nums:
        if out and n == out[-1][1] + 1:
            out[-1][1] = n
        else:
            out.append([n, n])
    return out


def reviewer_count(total_lines, n_files):
    if total_lines < 100 or n_files <= 2:
        return 1
    if total_lines < 500:
        return min(2, n_files)
    if total_lines < 2000:
        return min(4, -(-n_files // 3))
    if total_lines < 5000:
        return min(8, -(-n_files // 2))
    return min(16, n_files)


def group_files(files, n):
    """Fatias contíguas por caminho (localidade), balanceadas por linhas alteradas."""
    ordered = sorted(files, key=lambda f: f["path"])
    if n <= 1:
        return [ordered]
    target = (sum(f["added"] + f["removed"] for f in ordered) or 1) / n
    groups, cur, acc = [], [], 0
    for i, f in enumerate(ordered):
        cur.append(f)
        acc += f["added"] + f["removed"]
        files_left = len(ordered) - i - 1
        groups_left = n - len(groups) - 1  # grupos que ainda faltam depois do atual
        if groups_left > 0 and (acc >= target or files_left == groups_left):
            groups.append(cur)
            cur, acc = [], 0
    if cur:
        groups.append(cur)
    return groups


def slug(path):
    return re.sub(r"[^A-Za-z0-9._-]+", "_", path)[-80:]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pr", nargs="?")
    ap.add_argument("--out")
    ap.add_argument("--diff-file", help="usa este diff em vez de `gh pr diff` (teste)")
    args = ap.parse_args()

    url, owner, repo, number, meta = resolve_pr(args.pr)
    out = args.out or "/tmp/pr-review-%s-%s-%d" % (owner, repo, number)
    os.makedirs(os.path.join(out, "files"), exist_ok=True)

    if args.diff_file:
        raw = open(args.diff_file, encoding="utf-8", errors="replace").read()
    else:
        raw = run(["gh", "pr", "diff", url])
    with open(os.path.join(out, "all.diff"), "w") as fh:
        fh.write(raw)

    files, excluded, commentable = [], [], {}
    total_add = total_del = 0
    for idx, block in enumerate(parse_diff(raw), 1):
        old, new = paths_of(block)
        path = new or old
        if path is None:
            continue
        added, removed, right, left = scan(block)
        reason = next((r for p, r in EXCLUSIONS if p.search(path)), None)
        if reason:
            excluded.append({"path": path, "reason": reason, "added": added, "removed": removed})
            continue
        total_add += added
        total_del += removed
        diff_path = os.path.join(out, "files", "%02d-%s.diff" % (idx, slug(path)))
        with open(diff_path, "w") as fh:
            fh.write(block + "\n")
        files.append({
            "index": idx, "path": path, "old_path": old, "added": added, "removed": removed,
            "ext": path.rsplit(".", 1)[-1] if "." in os.path.basename(path) else "",
            "diff_file": diff_path, "chars": len(block),
            "binary": "Binary files " in block or "GIT binary patch" in block,
        })
        entry = commentable.setdefault(path, {"RIGHT": set(), "LEFT": set()})
        entry["RIGHT"].update(right)
        entry["LEFT"].update(left)

    total = total_add + total_del
    n = reviewer_count(total, len(files))
    groups = group_files(files, n) if files else []
    inline = sum(f["chars"] for f in files) <= MAX_INLINE_CHARS and len(files) <= MAX_INLINE_FILES

    snapshot = {
        "url": url, "owner": owner, "repo": repo, "number": number, "title": meta["title"],
        "base": meta["baseRefName"], "head": meta["headRefName"], "head_sha": meta["headRefOid"],
        "total_added": total_add, "total_removed": total_del, "files": files, "excluded": excluded,
        "reviewers": len(groups), "groups": [[f["index"] for f in g] for g in groups],
        "inline_diff": inline, "out_dir": out,
    }
    with open(os.path.join(out, "snapshot.json"), "w") as fh:
        json.dump(snapshot, fh, indent=2, ensure_ascii=False)
    commentable = {p: {side: ranges(sorted(nums)) for side, nums in e.items()} for p, e in commentable.items()}
    with open(os.path.join(out, "commentable.json"), "w") as fh:
        json.dump(commentable, fh, indent=2, ensure_ascii=False)

    md = []
    md.append("## Code Review Request\n")
    md.append("### Alvo\n")
    md.append("PR %s/%s#%d: %s (`%s` ← `%s`, head `%s`)\n" % (
        owner, repo, number, meta["title"], meta["baseRefName"], meta["headRefName"], meta["headRefOid"][:10]))
    md.append("### Arquivos revisáveis (%d arquivos, +%d/-%d linhas)\n" % (len(files), total_add, total_del))
    md.append("O índice é a posição do arquivo no diff completo do PR; os excluídos deixam lacunas.\n")
    md.append("|Índice|Arquivo|+/-|Tipo|Diff|")
    md.append("|---|---|---|---|---|")
    for f in files:
        md.append("|%d|%s|+%d/-%d|%s|`%s`|" % (f["index"], f["path"], f["added"], f["removed"], f["ext"], f["diff_file"]))
    if excluded:
        md.append("\n### Excluídos da revisão\n")
        for e in excluded:
            md.append("- %s (%s, +%d/-%d)" % (e["path"], e["reason"], e["added"], e["removed"]))
    md.append("\n### Distribuição\n")
    if not files:
        md.append("Nenhum arquivo revisável: todas as mudanças foram filtradas.")
    elif len(groups) == 1:
        md.append("Crie exatamente **1 revisor** para todos os arquivos.")
    else:
        md.append("Crie **%d revisores** em paralelo, agrupados por localidade (mesmo diretório/módulo, testes junto da implementação). Sugestão:\n" % len(groups))
        for i, g in enumerate(groups, 1):
            lines = sum(f["added"] + f["removed"] for f in g)
            md.append("- Revisor %d (%d linhas): %s" % (i, lines, ", ".join(str(f["index"]) for f in g)))
    md.append("")
    if inline:
        md.append("O diff cabe inline: o revisor lê `files/NN-*.diff` e **não** roda `gh pr diff` de novo.")
    else:
        md.append("O diff passa de %d caracteres ou %d arquivos: **não cole o diff nos prompts**. Cada revisor lê só os `files/NN-*.diff` que recebeu." % (MAX_INLINE_CHARS, MAX_INLINE_FILES))
    md.append("\nLinhas comentáveis (só `+` em RIGHT e `-` em LEFT): `%s`" % os.path.join(out, "commentable.json"))
    text = "\n".join(md) + "\n"
    with open(os.path.join(out, "snapshot.md"), "w") as fh:
        fh.write(text)
    sys.stdout.write(text)


if __name__ == "__main__":
    main()
