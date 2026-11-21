---
name: pr-review-final
description: "Verificação final de merge-readiness de um PR depois que o autor aplicou as melhorias do review: confere no código do head se cada thread (inclusive as resolvidas) foi corrigida de fato, revisa os commits novos desde o último review, lê o CI do commit atual separando falhas já documentadas das novas e diz se pode mergear ou o que ainda bloqueia. Aceita foco extra. Use para /pr-review-final <PR> [foco extra], ou quando pedirem para refazer o review, ver se está 100% ou se pode mergear. Publica direto, sem pedir confirmação (um review COMMENT)."
argument-hint: "<PR número, URL ou owner/repo#N> [foco extra]"
---

# Review final de PR (merge-readiness)

Rodada de fechamento, depois de `pr-review` e das correções do autor. A pergunta
é: **está 100% e podemos mergear?** Escrito para Claude Code, Antigravity (`agy`)
e OMP.

Argumentos: `<PR> [foco extra]`. Sem PR, usa o da branch atual. O foco extra só
prioriza.

## 1. Regras do projeto

Leia `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` do repositório e os docs que eles
apontam. Elas mandam sobre esta skill.

## 2. Levante o estado do PR

```bash
python3 <dir desta skill>/scripts/pr_state.py <PR> [--out DIR]
```

(`<dir desta skill>` é a pasta deste `SKILL.md`, normalmente
`~/.claude/skills/pr-review-final`, linkada também em `~/.gemini/skills`,
`~/.agents/skills` e `~/.omp/agent/skills`.)

O script usa `gh api graphql` e imprime, com o completo em `DIR/state.json`:

- **todas** as threads de review (abertas e resolvidas, desatualizadas ou não),
  com autor, local e respostas;
- o último review (o seu, se existir; senão o mais recente) e o commit em que foi
  feito;
- os **commits novos desde esse review**, com a dica do diff incremental;
- os checks do **commit atual** (head), separando falhando de pendente.

Sem review anterior, não há o que verificar: rode a skill `pr-review`.

Leia também a descrição e os comentários do PR (`gh pr view <PR> --comments`):
é onde ficam as falhas de CI já documentadas e as respostas do autor.

## 3. Cada thread foi corrigida de fato?

Para **toda** thread, resolvida ou não, valide **no código do head do PR**, não
na resposta do autor nem no "resolved" da interface:

1. Leia o trecho atual do arquivo no `headRefOid` (`git show <head>:<path>`,
   depois de `git fetch origin pull/<N>/head` se faltar o objeto, ou
   `gh api repos/<owner>/<repo>/contents/<path>?ref=<head>`). Thread
   desatualizada: o `line` aponta para a versão antiga; ache o trecho
   equivalente no head e leia o diff dos commits posteriores ao comentário.
2. Classifique:
   - **Corrigida**: o código mudou e resolve a causa do que a thread apontou
     (cite `arquivo:linha` no head).
   - **Corrigida em parte**: resolve um sintoma, ou só um dos pontos.
   - **Não corrigida**: o problema continua, mesmo com resposta ou resolvida.
   - **Contestada com razão**: o autor explicou e o código sustenta; diga por quê.
   - **Resolvida sem correção**: marcada como resolvida mas o código não mudou e
     não há justificativa. Isso é alerta.
3. Uma correção pode ter criado problema novo: olhe o entorno do trecho alterado.

Com muitas threads, divida entre subagentes em paralelo (cada um com a lista de
threads dele e o `head`), mas **a conclusão sobre cada thread é sua**: confira
as evidências antes de aceitar.

## 4. Commits novos desde o último review

Revise o diff incremental como uma primeira rodada, com a skill `pr-review`: gere
o diff do estado revisado até o head (`git diff <commit do review>..<head>`,
`<primeiro commit novo>~1..<head>` se o review não tem commit/foi reescrito, ou
`gh api repos/<owner>/<repo>/compare/<base>...<head> -H "Accept: application/vnd.github.v3.diff"`
se os commits não estiverem no repositório local), congele com

```bash
python3 <dir da skill pr-review>/scripts/review_snapshot.py <PR> --diff-file <arquivo do diff> --out /tmp/pr-final-incremental
```

e siga as etapas 3 e 4 daquela skill (revisores em paralelo, rubrica, consolidar).
Só conta o que os commits novos **introduziram**; thread antiga volta à etapa 3.

## 5. CI do commit atual

Para cada check falhando no head:

1. Leia o motivo (`gh run view <run-id> --log-failed`, ou a URL do check).
2. Separe:
   - **Já documentada no PR**: citada na descrição, nos comentários ou nas
     threads, ou comprovadamente a mesma falha que a base já tem
     (`gh run list --branch <base> --workflow <wf>`). Diga onde está documentada.
   - **Nova**: não aparece em lugar nenhum e passa na base.
3. Check pendente não é verde: relate como pendente.

## 6. Veredito

Responda em português:

- **Pode mergear** só se: toda thread está corrigida (ou contestada com razão),
  não há finding P0/P1 novo nos commits novos, o CI do head não tem falha nova,
  nada pendente e o PR está mergeável (`mergeable`/`mergeStateStatus`, sem
  `draft`, base correta numa pilha de PRs). Diga isso e o que sustenta cada item.
- **Não pode mergear**: liste o que **ainda bloqueia**, um item por linha:
  `arquivo:linha | SEVERIDADE | o que falta`, com o motivo (thread não corrigida,
  falha de CI nova, finding novo, conflito).
- Em qualquer caso, a tabela das threads (corrigida / em parte / não corrigida /
  contestada / resolvida sem correção) e as falhas de CI separadas em
  documentadas e novas.

Publique direto, sem pedir confirmação: um único review `COMMENT` como descrito
na skill `pr-review` (etapa 6), só em linhas alteradas pelo PR. Se o usuário
pedir só para ver (`dry run`, `só me mostre`), não publique.

**Limites duros:** nunca `APPROVE` nem `REQUEST_CHANGES`, nunca merge nem
auto-merge, nunca resolver thread de outra pessoa, nunca `--no-verify` nem force-push, nunca baixar
threshold, cobertura ou baseline, nunca expor segredo, token ou
`.env` em comentário, e nunca repetir uma thread que já está aberta
(idempotência).
