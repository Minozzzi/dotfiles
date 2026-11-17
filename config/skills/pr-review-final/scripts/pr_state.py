#!/usr/bin/env python3
"""Levanta o estado de um PR para a verificação de merge-readiness.

Uso:
    pr_state.py [PR] [--out DIR]

PR é número, URL ou `owner/repo#N`; sem PR, usa o PR da branch atual.
Reúne com `gh api graphql` o que a revisão final precisa e que o `gh pr view`
não traz inteiro:

  - TODAS as threads de review (resolvidas, desatualizadas e as respostas);
  - os reviews e o commit em que cada um foi feito;
  - os commits novos desde o último review (seu, se houver; senão o mais recente);
  - os checks do commit atual (head), separando falhas de pendentes.

Escreve DIR/state.json (completo) e imprime um resumo em markdown.
"""
import argparse
import json
import os
import re
import subprocess
import sys

QUERY = """
query($owner:String!, $repo:String!, $number:Int!, $threadsAfter:String) {
  viewer { login }
  repository(owner:$owner, name:$repo) {
    pullRequest(number:$number) {
      number title url state isDraft mergeable mergeStateStatus reviewDecision
      baseRefName headRefName headRefOid
      author { login }
      reviews(last:100) { nodes { id state submittedAt url body author { login } commit { oid } } }
      commits(last:100) {
        totalCount
        nodes { commit { oid committedDate messageHeadline author { user { login } } } }
      }
      reviewThreads(first:100, after:$threadsAfter) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id isResolved isOutdated path line originalLine startLine diffSide
          resolvedBy { login }
          comments(first:100) {
            nodes {
              databaseId url body createdAt path
              author { login }
              commit { oid } originalCommit { oid }
            }
          }
        }
      }
    }
  }
}
"""

CHECKS_QUERY = """
query($owner:String!, $repo:String!, $oid:GitObjectID!) {
  repository(owner:$owner, name:$repo) {
    object(oid:$oid) {
      ... on Commit {
        oid
        statusCheckRollup {
          state
          contexts(first:100) {
            nodes {
              __typename
              ... on CheckRun { name status conclusion detailsUrl checkSuite { workflowRun { workflow { name } } } }
              ... on StatusContext { context state targetUrl }
            }
          }
        }
      }
    }
  }
}
"""


def gh(args, stdin=None):
    p = subprocess.run(["gh"] + args, capture_output=True, text=True, input=stdin)
    if p.returncode != 0:
        sys.exit("erro: gh %s\n%s" % (" ".join(args), p.stderr.strip()))
    return p.stdout


def graphql(query, **variables):
    args = ["api", "graphql", "-f", "query=" + query]
    for k, v in variables.items():
        if v is None:
            continue
        args += ["-F" if isinstance(v, int) else "-f", "%s=%s" % (k, v)]
    return json.loads(gh(args))["data"]


def resolve(arg):
    target = []
    if arg:
        m = re.match(r"^([\w.-]+/[\w.-]+)#(\d+)$", arg)
        target = ["--repo", m.group(1), m.group(2)] if m else [arg]
    url = json.loads(gh(["pr", "view"] + target + ["--json", "url"]))["url"]
    m = re.match(r"https://[^/]+/([^/]+)/([^/]+)/pull/(\d+)", url)
    return m.group(1), m.group(2), int(m.group(3))


def short(oid):
    return oid[:10] if oid else "?"


def one_line(text, n=160):
    text = re.sub(r"\s+", " ", text or "").strip()
    return text if len(text) <= n else text[: n - 1] + "…"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pr", nargs="?")
    ap.add_argument("--out")
    args = ap.parse_args()

    owner, repo, number = resolve(args.pr)
    out = args.out or "/tmp/pr-final-%s-%s-%d" % (owner, repo, number)
    os.makedirs(out, exist_ok=True)

    threads, cursor = [], None
    while True:
        data = graphql(QUERY, owner=owner, repo=repo, number=number, threadsAfter=cursor)
        pr = data["repository"]["pullRequest"]
        threads += pr["reviewThreads"]["nodes"]
        if not pr["reviewThreads"]["pageInfo"]["hasNextPage"]:
            break
        cursor = pr["reviewThreads"]["pageInfo"]["endCursor"]
    viewer = data["viewer"]["login"]

    head = pr["headRefOid"]
    checks_root = graphql(CHECKS_QUERY, owner=owner, repo=repo, oid=head)["repository"]["object"]
    rollup = (checks_root or {}).get("statusCheckRollup") or {"state": "NONE", "contexts": {"nodes": []}}
    checks = []
    for c in rollup["contexts"]["nodes"]:
        if c["__typename"] == "CheckRun":
            workflow = (((c.get("checkSuite") or {}).get("workflowRun") or {}).get("workflow") or {}).get("name")
            checks.append({"name": c["name"], "workflow": workflow, "status": c["status"],
                           "conclusion": c["conclusion"], "url": c["detailsUrl"]})
        else:
            state = c["state"]
            checks.append({"name": c["context"], "workflow": None,
                           "status": "COMPLETED" if state not in ("PENDING", "EXPECTED") else "IN_PROGRESS",
                           "conclusion": state, "url": c["targetUrl"]})
    failing_states = {"FAILURE", "ERROR", "TIMED_OUT", "CANCELLED", "ACTION_REQUIRED", "STARTUP_FAILURE"}
    failed = [c for c in checks if c["conclusion"] in failing_states]
    pending = [c for c in checks if c["status"] != "COMPLETED"]

    reviews = [r for r in pr["reviews"]["nodes"] if r["state"] != "PENDING"]
    reviews.sort(key=lambda r: r["submittedAt"] or "")
    mine = [r for r in reviews if (r["author"] or {}).get("login") == viewer]
    anchor = (mine or reviews or [None])[-1]
    commits = [n["commit"] for n in pr["commits"]["nodes"]]
    oids = [c["oid"] for c in commits]
    since = []
    if anchor and anchor["commit"] and anchor["commit"]["oid"] in oids:
        since = commits[oids.index(anchor["commit"]["oid"]) + 1:]
    elif anchor and anchor["submittedAt"]:
        since = [c for c in commits if c["committedDate"] > anchor["submittedAt"]]

    state = {
        "owner": owner, "repo": repo, "number": number, "viewer": viewer,
        "pr": {k: pr[k] for k in ("title", "url", "state", "isDraft", "mergeable", "mergeStateStatus",
                                  "reviewDecision", "baseRefName", "headRefName", "headRefOid")},
        "author": (pr["author"] or {}).get("login"),
        "last_review": anchor, "reviews": reviews,
        "commits_total": pr["commits"]["totalCount"], "commits_since_last_review": since,
        "threads": threads, "checks": checks, "checks_rollup": rollup["state"],
    }
    with open(os.path.join(out, "state.json"), "w") as fh:
        json.dump(state, fh, indent=2, ensure_ascii=False)

    p = state["pr"]
    md = ["## Estado do PR %s/%s#%d" % (owner, repo, number), "",
          "**%s**" % p["title"], "",
          "- Estado: %s%s; merge: %s / %s; decisão de review: %s" % (
              p["state"], " (draft)" if p["isDraft"] else "", p["mergeable"], p["mergeStateStatus"], p["reviewDecision"] or "-"),
          "- Branch: `%s` ← `%s`, head `%s`" % (p["baseRefName"], p["headRefName"], short(head)),
          "- Autor: %s; eu (gh): %s" % (state["author"], viewer), ""]

    md.append("### Último review")
    if anchor:
        md.append("- %s por %s em %s, no commit `%s`%s" % (
            anchor["state"], (anchor["author"] or {}).get("login"), anchor["submittedAt"],
            short((anchor["commit"] or {}).get("oid")), "" if mine else " (não é seu: nenhum review seu neste PR)"))
        md.append("- Commits novos desde então: **%d**" % len(since))
        for c in since:
            md.append("  - `%s` %s (%s)" % (short(c["oid"]), c["messageHeadline"], c["committedDate"]))
        base = (anchor["commit"] or {}).get("oid")
        if since:
            # sem o commit do review (reescrito/force-push), compara a partir do pai do primeiro commit novo
            base = base or since[0]["oid"] + "~1"
            md.append("  - diff incremental: `git diff %s..%s` (ou `gh api repos/%s/%s/compare/%s...%s`)" % (
                short(base) if "~" not in base else base, short(head), owner, repo, base, short(head)))
    else:
        md.append("- Nenhum review anterior: trate como primeira revisão (use `pr-review`).")
    md.append("")

    unresolved = [t for t in threads if not t["isResolved"]]
    resolved = [t for t in threads if t["isResolved"]]
    md.append("### Threads: %d no total, %d abertas, %d resolvidas (%d desatualizadas)" % (
        len(threads), len(unresolved), len(resolved), sum(1 for t in threads if t["isOutdated"])))
    for label, group in (("Abertas", unresolved), ("Resolvidas", resolved)):
        if not group:
            continue
        md.append("\n**%s**\n" % label)
        for i, t in enumerate(group, 1):
            cs = t["comments"]["nodes"]
            first = cs[0] if cs else None
            loc = "%s:%s" % (t["path"], t["line"] or t["originalLine"] or "?")
            who = (first["author"] or {}).get("login") if first else "?"
            flags = ("desatualizada, " if t["isOutdated"] else "") + ("resolvida por %s, " % (t["resolvedBy"] or {}).get("login") if t["isResolved"] else "")
            md.append("%d. `%s` (%s%d comentário(s)) %s: %s" % (i, loc, flags, len(cs), who, one_line(first["body"] if first else "")))
            md.append("   - %s" % (first["url"] if first else t["id"]))
            if len(cs) > 1:
                last = cs[-1]
                md.append("   - última resposta (%s): %s" % ((last["author"] or {}).get("login"), one_line(last["body"], 200)))
    md.append("")

    md.append("### CI do commit atual (`%s`): %s" % (short(head), rollup["state"]))
    if not checks:
        md.append("- Sem checks reportados para este commit.")
    for c in failed:
        md.append("- FALHOU: %s%s (%s) %s" % (c["name"], " / " + c["workflow"] if c["workflow"] else "", c["conclusion"], c["url"] or ""))
    for c in pending:
        md.append("- PENDENTE: %s (%s) %s" % (c["name"], c["status"], c["url"] or ""))
    ok = len(checks) - len(failed) - len(pending)
    if checks:
        md.append("- %d verdes, %d falhando, %d pendentes" % (ok, len(failed), len(pending)))
    md.append("\nEstado completo (threads com todas as respostas): `%s`" % os.path.join(out, "state.json"))
    sys.stdout.write("\n".join(md) + "\n")


if __name__ == "__main__":
    main()
