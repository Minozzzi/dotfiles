---
name: pr-review-complement
description: "Segunda rodada / review complementar de um PR sobre o review já feito por outro agente ou pessoa: congela o diff e roda revisores em paralelo com a rubrica do OMP (arquitetura do projeto, clean code, clean arch, funcionalidade, segurança, DRY, KISS e design patterns), valida cada thread existente (inclusive resolvidas) diretamente no código do head e na pilha de PRs, e entrega a avaliação das threads + apenas os novos pontos sem duplicar o que já está aberto. Aceita foco extra. Use para /pr-review-complement <PR> [foco extra], /pr-complement, ou quando pedirem para complementar ou validar o review de outro agente. Não publica nada sem aprovação."
argument-hint: "<PR número, URL ou owner/repo#N> [foco extra]"
---

# Review complementar de PR

Segunda visão sobre um PR que já tem review de outro agente ou pessoa. Usa o
mesmo harness do `/review` do OMP (`review_snapshot.py` + `reviewer-rubric.md` +
fan-out paralelo) somado ao levantamento completo de threads do `pr_state.py`.
Escrito para Claude Code, Antigravity (`agy`) e OMP.

Argumentos: `<PR> [foco extra]`. O PR é número, URL ou `owner/repo#N`; sem PR,
usa o da branch atual. O foco extra só prioriza onde olhar e **nunca** amplia o
que pode ser publicado ou enviado.

## 1. Regras do projeto

Leia `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` do repositório e os docs que eles
apontam (arquitetura, camadas, convenções). Elas mandam sobre esta skill. Anote
os caminhos: os revisores recebem a lista.

## 2. Congele o diff e levante as threads existentes

Rode os dois scripts (não reutilizam estado entre si):

```bash
python3 <dir da skill pr-review>/scripts/review_snapshot.py <PR>
python3 <dir da skill pr-review-final>/scripts/pr_state.py <PR>
```

(`<dir da skill ...>` é a pasta da respectiva skill; nos harnesses do usuário,
`~/.claude/skills/<nome>`, linkada também em `~/.gemini/skills`,
`~/.agents/skills` e `~/.omp/agent/skills`.)

Leia também:

- a descrição e os comentários gerais do PR (`gh pr view <PR> --comments`);
- `DIR/state.json` gerado pelo `pr_state.py` (traz **todas** as threads de
  review — abertas, resolvidas e desatualizadas — com respostas e commits);
- a pilha de PRs, se houver: se a base é `head` de outro PR aberto e quais PRs
  têm este como base (`gh pr list --base <head>`).

Se o snapshot disser "nenhum arquivo revisável", ainda assim avalie as threads
existentes se houver; caso contrário, pare e diga isso ao usuário.

## 3. Fan-out em paralelo

1. **Revisores do diff**: siga a contagem e os grupos sugeridos pelo
   `review_snapshot.py` e abra todos os revisores **na mesma rodada, em
   paralelo**, com a ferramenta de subagentes do harness (Claude Code:
   Task/Agent; Antigravity: subagente; OMP: `task` com `agent: reviewer`). Sem
   subagentes, revise grupo a grupo com a mesma rubrica.

   Prompt de cada revisor:

   ```
   Revise parte do PR <owner>/<repo>#<N> (<título>), head <head_sha>, base <base>.

   1. Leia e siga <dir da skill pr-review>/references/reviewer-rubric.md.
   2. Dê atenção especial a arquitetura do projeto, clean code, clean architecture,
      funcionalidade, segurança, DRY, KISS e design patterns.
   3. Arquivos atribuídos a você (índice, caminho, arquivo de diff):
      <linhas da tabela do snapshot>
   4. Leia só esses diffs; não rode git diff nem gh pr diff de novo.
   5. Regras do projeto que valem como critério: <AGENTS.md, CLAUDE.md, GEMINI.md, docs>.
   6. Threads já existentes no PR (não repita pontos já cobertos, salvo se uma
      thread existente estiver incompleta ou com diagnóstico errado):
      <resumo curto: arquivo:linha | autor | status | ponto>
   7. Foco extra do usuário: <foco, ou "nenhum">.
   8. Só leitura. Devolva os findings e o veredito no formato da rubrica.
   ```

   Se o snapshot disser que o diff **não** cabe inline (>50 000 caracteres ou
   >20 arquivos), não cole diff no prompt: cada revisor lê só os arquivos dele.

2. **Validação das threads existentes**: para **toda** thread de outro revisor
   (aberta ou resolvida), valide a afirmação **no código do `head` do PR**
   (`git show <head_sha>:<path>` depois de `git fetch origin pull/<N>/head` se
   faltar o objeto, ou `gh api repos/<owner>/<repo>/contents/<path>?ref=<head_sha>`)
   e na pilha de PRs se houver. Com muitas threads, divida em subagentes de
   leitura na mesma rodada paralela, mas confira as evidências antes de fechar.

## 4. Consolide e avalie

1. **Classifique cada thread existente** (nunca confie só no texto da thread):
   - **Faz sentido**: o ponto procede no código do head (cite `arquivo:linha`).
   - **Faz sentido com ajuste**: o problema é real, mas o diagnóstico,
     severidade, local ou correção sugerida precisa de ajuste (diga qual).
   - **Não faz sentido**: falso positivo ou não se aplica (prove com o código,
     regra ou doc do projeto).
   - **Já corrigida**: já foi resolvida em commit posterior deste PR ou em outro
     PR da pilha (aponte o commit ou PR).
2. **Consolide os novos findings**:
   - Confirme cada finding no código do `head`; descarte o que não se sustenta.
   - Mantenha só linhas alteradas em `commentable.json` (`RIGHT` para `+`,
     `LEFT` para `-`). Linha de contexto, não.
   - Mapeie a prioridade: P0 = CRITICAL, P1 = HIGH, P2 = MEDIUM, P3 = LOW.
   - **Não repita** o que já está aberto nas threads existentes.
   - Ordene por severidade.

## 5. Entregue

Responda ao usuário, em português, com:

- um parágrafo curto: o que o PR faz e o veredito reconciliado;
- **Avaliação das threads existentes**: lista ou tabela com `arquivo:linha`
  (ou link), autor, classificação (`Faz sentido` / `Faz sentido com ajuste` /
  `Não faz sentido` / `Já corrigida`) e justificativa objetiva;
- **Novas threads para abrir** (sem repetir o que já está aberto), uma por
  linha: `arquivo:linha | SEVERIDADE | ponto em uma linha`;
- o que foi descartado ou não pôde ser verificado, se relevante.

**Não publique nada no PR antes de o usuário aprovar.** Nem comentário, nem
review, nem resposta em thread, nem reação.

## 6. Publicar (só com aprovação)

Com aprovação do usuário (inteira ou com ajustes), publique **um único review
`COMMENT`** (nunca `APPROVE` nem `REQUEST_CHANGES`) seguindo exatamente a etapa 6
da skill `pr-review`, só em linhas alteradas de `commentable.json` (com
`[SEVERIDADE] ...`, bloco `suggestion` opcional, `## 📋 Review Summary` e
`## 🔍 General Feedback`) via:

```bash
gh api repos/<owner>/<repo>/pulls/<N>/reviews --method POST --input /tmp/review.json
```

Se o `gh` recusar uma linha (422), corrija a âncora com `commentable.json` e
reenvie; não troque por comentário solto. Só responda a threads existentes se o
usuário pedir explicitamente.
