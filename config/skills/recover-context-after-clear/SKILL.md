---
name: recover-context-after-clear
description: "Use when the user lost conversation context (accidental /clear, new session) and asks if you remember earlier work or wants to resume it."
---

# Recuperar contexto após /clear

Nunca diga que lembra: você não lembra. Recupere de fato.

1. `read xd://eval/archive` uma vez para ver a API.
2. Eval (py): `await archive.sessions(project="*", limit=15)` e `await archive.search("<palavra-chave>", project="*")` para achar a sessão anterior (os recaps já dão o objetivo e o próximo passo).
3. `await archive.session(id, limit=50, silent=True)` e imprima `recaps` e `prompts`. Isso traz só as falas do USUÁRIO, não as decisões do assistente.
4. Para decisões, raciocínio, paths e pendências, spawne um agente `seance` com `sourceSession=<id>` pedindo dossiê estruturado em PT-BR (objetivo, decisões fechadas, discussões, pontos em aberto, arquivos/URLs/valores). Leva ~2-3 min; leia o resultado completo em `agent://<Nome>`.
5. Verifique também `maestri note read current-feature` (Maestro): pode estar vazia e ser de outro projeto.
6. Responda ao usuário separando: o que foi decidido, o que NÃO foi confirmado por ele (suposições do assistente), pendências e estado de integrações (ex.: MCP). Ofereça gravar o contexto numa note.

Não leia o JSONL cru no contexto principal; use seance.
