---
description: Complementa o review do Gemini num PR com o /pr-code-review e traz o consolidado das threads
argument-hint: <PR número ou URL> [foco extra]
---

Use a skill `pr-code-review` neste PR: $ARGUMENTS

Faz um review aprofundado sobre clean code, clean arch, com relação à arquitetura do projeto, funcionalidade, DRY, KISS e outros design patterns, e aí me traga um consolidado das threads que podemos abrir no PR. Já pedi para o Gemini fazer um review: leia as threads dele no PR, veja se encontra mais pontos e se faz sentido o que ele levou lá.

- Use `gh` para ler o PR, o diff e as threads (inclusive as resolvidas).
- Para cada thread que já existe, diga se faz sentido, se faz sentido com ajuste, se não faz sentido ou se já foi corrigida em outro PR da pilha.
- Não repita o que já está aberto.
- Não publique nada antes de eu aprovar. Quando eu aprovar, publique um único review `COMMENT` no formato da skill, só em linhas que o PR alterou.
