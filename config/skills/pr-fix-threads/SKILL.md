---
name: pr-fix-threads
description: "Corrige as threads de review de um PR (de qualquer agente ou pessoa): triagem no código, correção com testes e gate, e, com aprovação, commit, push, respostas e resolução. Use para /pr-fix-threads <PR> [foco], ou quando pedirem para corrigir, responder ou resolver comentários de review de um PR."
---

# Corrigir as threads de um PR

Argumentos: `<PR número ou URL> [foco extra]`. Sem PR, use o da branch atual
(`gh pr view`). O foco extra só prioriza; nunca amplia o que pode ser
publicado ou enviado.

## Antes de tudo

1. Leia as regras do repositório (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md` e os
   docs que eles apontam). Elas mandam sobre esta skill: nada de baixar
   threshold, pular check ou commitar algo que o projeto proíbe.
2. Leia o PR com `gh`: título, descrição, base, head, diff e **todas** as
   threads, inclusive as resolvidas e as respostas, de qualquer autor. As
   threads de revisão ficam em
   `gh api graphql` → `pullRequest.reviewThreads` (com `id`, `isResolved`,
   `isOutdated`, `path`, `line` e o `databaseId` do primeiro comentário).
3. Descubra a pilha: o PR em que este faz merge (a base é head de outro PR
   aberto?) e os PRs que fazem merge neste (`gh pr list --base <head>`).

## Triagem

Para cada thread não resolvida, confira a afirmação no código da branch,
nunca só no texto da thread, e classifique:

- **corrigir**: o ponto procede (com ou sem ajuste; diga qual ajuste);
- **já corrigida**: aponte o commit e o PR da pilha onde está;
- **contestar**: o ponto não procede; dê a razão técnica com o código, a
  regra ou o doc que a prova. Decisão de produto (o que o sistema deve fazer
  quando as regras não dizem) vai para o usuário decidir, não para o código.

Uma thread resolvida cuja correção não está no código volta para a lista.

## Branch

Em PR empilhado, corrija na branch do topo da pilha que reescreve o mesmo
código, para que o merge não conflite; a correção chega ao PR de baixo quando
a pilha for mergeada (de cima para baixo). Diga em qual branch vai corrigir e
por quê, e avise que a branch de baixo segue com o código antigo até o merge.
Confirme que a árvore de trabalho está limpa antes de trocar de branch.

## Correção

1. Corrija a causa no módulo dono do código, como as regras do projeto dizem.
   Patches pequenos; nada de refatorar além do que a thread pede.
2. Todo comportamento alterado ganha um teste que o prova (comportamento,
   autorização, erro, limite ou transição; não chamada de mock nem texto
   fonte). Mantenha a cobertura que o projeto exige.
3. Se a correção mudar um contrato público, gere os artefatos pelo caminho do
   projeto, meça a compatibilidade com a base e escolha a opção de menor
   quebra; explique a escolha na resposta da thread.
4. Rode o gate canônico do projeto (por exemplo `pnpm validate`) e o caminho
   alterado de verdade. Falha não se esconde: conserte ou relate.

## Antes de publicar

Traga ao usuário, sem ter commitado nada:

- uma tabela por thread: link, decisão (corrigida / já corrigida /
  contestada) e o que mudou ou por quê não;
- a branch usada e os arquivos alterados;
- os comandos rodados com o resultado real, e o que ficou sem verificar
  (CI ainda não rodou, caminho não exercido).

Peça **um único sim** para o pacote inteiro: commitar, fazer push, responder
e resolver.

## Com o sim

1. Commit em Conventional Commits, com as regras de atribuição do projeto e
   da ferramenta; push da branch escolhida.
2. Responda cada thread no idioma do PR, na própria thread
   (`gh api -X POST repos/<owner>/<repo>/pulls/<PR>/comments/<databaseId>/replies`),
   com o link do commit
   (`https://github.com/<owner>/<repo>/pull/<PR>/commits/<sha>`) e o que mudou,
   ou a razão de não ter mudado. Em PR empilhado, responda as threads do PR de
   baixo com o commit do topo.
3. Resolva só as threads corrigidas ou já corrigidas
   (`resolveReviewThread`). As contestadas ficam abertas para quem revisou.
4. Nunca aprove, peça mudanças, faça merge ou ative auto-merge.

No fim, relate o que foi enviado (commit, branch, threads respondidas e
resolvidas) e o que segue pendente.
