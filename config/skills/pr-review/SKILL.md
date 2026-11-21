---
name: pr-review
description: "Primeira rodada de review de um PR: revisores em paralelo sobre o diff congelado, com arquitetura do projeto, clean code, funcionalidade, segurança, DRY e KISS, e um consolidado de threads (arquivo:linha, severidade, ponto) para abrir no PR. Aceita foco extra. Use para /pr-review <PR> [foco extra], ou quando pedirem para revisar, fazer o review ou a primeira rodada de um PR. Publica direto, sem pedir confirmação (um review COMMENT)."
argument-hint: "<PR número, URL ou owner/repo#N> [foco extra]"
---

# Review de PR (primeira rodada)

Porte do `/review` do OMP: o orquestrador congela o diff, divide os arquivos
entre revisores pelo tamanho da mudança, cada revisor aplica a rubrica e o
orquestrador consolida. Foi escrito para valer em Claude Code, Antigravity (`agy`)
e OMP.

Argumentos: `<PR> [foco extra]`. O PR é número, URL ou `owner/repo#N`; sem PR,
usa o da branch atual. Todo o resto do texto é **foco extra**: ele prioriza onde
olhar.

## 1. Regras do projeto

Leia `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` do repositório e os docs que eles
apontam (arquitetura, camadas, convenções). Elas mandam sobre esta skill. Anote
os caminhos: os revisores recebem a lista.

## 2. Congele o diff

```bash
python3 <dir desta skill>/scripts/review_snapshot.py <PR> [--out DIR]
```

O script resolve o PR com `gh`, filtra o que não vale revisão (lockfiles,
minificados, gerados, snapshots, binários, `dist/`, `vendor/`), escreve o diff de
cada arquivo em `DIR/files/NN-*.diff`, as linhas alteradas em
`DIR/commentable.json` e imprime a tabela de arquivos, a contagem de revisores e
a sugestão de grupos. Sem `gh` autenticado, ele para com o erro do `gh`.

`<dir desta skill>` é a pasta onde está este `SKILL.md`; nos harnesses do
usuário, `~/.claude/skills/pr-review` (o mesmo diretório, por symlink, em
`~/.agents/skills`, `~/.gemini/skills` e `~/.omp/agent/skills`).

Se o resumo disser "nenhum arquivo revisável", pare e diga isso ao usuário.

## 3. Fan-out

A contagem do script segue a do OMP: **1 revisor** com menos de 100 linhas
alteradas ou até 2 arquivos; depois 2, 4, 8 e até 16 revisores conforme o diff
cresce (500, 2000 e 5000 linhas), sempre agrupando por localidade: mesmo
diretório ou módulo, testes junto da implementação. Ajuste a sugestão de grupos
se um agrupamento por funcionalidade ficar melhor.

Abra todos os revisores **na mesma rodada, em paralelo**, com a ferramenta de
subagentes do harness (Claude Code: Task/Agent; Antigravity: subagente; OMP:
`task` com `agent: reviewer`). Sem subagentes, revise você mesmo, grupo a grupo,
com a mesma rubrica e sem pular a consolidação.

Prompt de cada revisor (preencha os campos; não resuma a rubrica, mande o
caminho):

```
Revise parte do PR <owner>/<repo>#<N> (<título>), head <head_sha>, base <base>.

1. Leia e siga <dir desta skill>/references/reviewer-rubric.md.
2. Arquivos atribuídos a você (índice, caminho, arquivo de diff):
   <linhas da tabela do snapshot>
3. Leia só esses diffs; não rode git diff nem gh pr diff de novo.
4. Regras do projeto que valem como critério: <AGENTS.md, CLAUDE.md, docs>.
5. Foco extra do usuário: <foco, ou "nenhum">.
6. Só leitura. Devolva os findings e o veredito no formato da rubrica.
```

Se o snapshot disser que o diff **não** cabe inline (mais de 50 000 caracteres ou
20 arquivos), não cole diff no prompt: cada revisor lê só os arquivos dele.

## 4. Consolide

Com os resultados de todos os revisores:

1. Junte, remova duplicatas e confirme cada finding no código (leia o trecho no
   head do PR). Descarte o que não se sustenta.
2. Mantenha só linhas alteradas: cada `arquivo:linha` precisa estar em
   `commentable.json` (`RIGHT` para `+`, `LEFT` para `-`). Linha de contexto,
   não.
3. Mapeie a prioridade: P0 = CRITICAL, P1 = HIGH, P2 = MEDIUM, P3 = LOW.
4. Se o PR já tem threads abertas (confira com `pr-review-final/scripts/pr_state.py`
   ou `gh api graphql`, além de `gh pr view <PR> --comments`), não repita o que
   já está lá. Se o objetivo for avaliar o review de outro agente e complementá-lo,
   use a skill `pr-review-complement`.
5. Ordene por severidade.

## 5. Entregue

Responda ao usuário, em português, com:

- um parágrafo curto: o que o PR faz e o veredito (os `overall_correctness` dos
  revisores, reconciliados);
- o consolidado das threads para abrir lá, uma por linha:
  `arquivo:linha | SEVERIDADE | ponto em uma linha`;
- o que você descartou ou não conseguiu verificar, se for relevante.

Publique direto, sem pedir confirmação (etapa 6). Se o usuário pedir só para
ver (`dry run`, `só me mostre`), pare aqui e não publique nada.

**Limites duros:** nunca `APPROVE` nem `REQUEST_CHANGES`, nunca merge nem
auto-merge, nunca `--no-verify` nem force-push, nunca baixar threshold,
cobertura ou baseline, nunca expor segredo, token ou `.env` em comentário, e nunca repetir
uma thread que já está aberta (idempotência).

## 6. Publicar

Publique **um único review `COMMENT`**, só em linhas que o PR alterou.
Cada comentário segue este formato:

```
[SEVERIDADE] texto do comentário

```suggestion
código de substituição (só se houver sugestão concreta)
```
```

O resumo do review usa este formato:

```
## 📋 Review Summary

2 a 3 frases sobre o objetivo e a qualidade do PR.

## 🔍 General Feedback

- observações gerais e pontos positivos que não cabem inline; sem repetir os inline.
```

Monte o payload e envie com `gh` (o `commit_id` é o `head_sha` do snapshot; para
vários trechos use `start_line`/`start_side`):

```bash
cat > /tmp/review.json <<'EOF'
{
  "commit_id": "<head_sha>",
  "event": "COMMENT",
  "body": "<resumo>",
  "comments": [
    {"path": "src/a.ts", "line": 42, "side": "RIGHT", "body": "[HIGH] ..."}
  ]
}
EOF
gh api repos/<owner>/<repo>/pulls/<N>/reviews --method POST --input /tmp/review.json
```

Se o `gh` recusar uma linha (422), ela não está no diff do head: corrija a
âncora com `commentable.json` e reenvie; não troque por comentário solto.
