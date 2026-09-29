---
title: Migração de Projetos Legados
description: Define a estratégia de migração de projetos legados para a arquitetura e stack atual do ecossistema frontend Aarin.
status: draft
version: 1.0.0
---

# Migração de Projetos Legados

## Purpose

Reduzir dívida técnica de projetos legados de forma gradual, priorizada e documentada, sem bloquear entregas de negócio.

## Scope

### Dentro do escopo

- Projetos com Majoris/Panda CSS.
- Projetos com estrutura `pages/` contendo regras de negócio.
- Projetos sem testes ou com baixa cobertura.
- Migração incremental vs reescrita.

### Fora do escopo

- Projetos já em arquitetura atual.
- Decisões de descontinuação de produto.

## References

- `SDD-ECOSSISTEMA-FRONTEND.md` (seção 11 — Riscos e Dívida Técnica)
- `docs/adrs/adr-001-mui.md`
- `docs/adrs/adr-005-vite.md`
- Notion: "Como construímos frontend na Aarin?" (Disclaimer)
- Notion: "Documento técnico refatoração IW"

## Principles

1. **Migração gradual**: não parar o desenvolvimento de features para reescrever.
2. **No free pass**: novas features seguem a arquitetura atual, mesmo em projetos legados.
3. **Documentar desvios**: todo desvio temporário é registrado.
4. **Priorizar por risco**: apps críticos e com maior dívida técnica primeiro.

## Must

- Todo projeto legado possui um plano de migração registrado.
- Novas funcionalidades em projetos legados seguem a arquitetura de módulos quando possível.
- Desvios da arquitetura são documentados em `ARCHITECTURE.md` do projeto.
- Componentes novos em projetos legados usam MUI.
- Testes são adicionados à medida que código legado é alterado.

## Must not

- Não expandir código com Majoris/Panda CSS sem plano de migração.
- Não criar novas telas com regras de negócio acopladas em `pages/`.
- Não migrar tudo de uma vez sem priorização e risco avaliado.

## Migration Plan Template

1. Inventário de dívida técnica (Majoris, pages/, testes, cobertura).
2. Priorização por risco e valor de negócio.
3. Definição de fronteiras (o que será migrado primeiro).
4. Cronograma incremental.
5. Critérios de sucesso (cobertura, ADRs seguidos, lint).

## Done when

- [ ] 100% dos projetos legados com plano de migração.
- [ ] 0 novos componentes Majoris/Panda CSS.
- [ ] Cobertura de testes aumentando a cada sprint.
