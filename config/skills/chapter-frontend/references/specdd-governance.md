---
title: Governança do SpecDD
description: Define o formato, frontmatter, seções obrigatórias e ciclo de vida das specs de governança frontend Aarin.
status: draft
version: 1.0.0
owner: chapter-frontend
last-reviewed: 2026-07-21
---

# Governança do SpecDD

## Purpose

Estabelecer o formato padronizado para as specs de governança do Chapter Frontend, garantindo consistência entre documentação, validação automatizada e o site gerado pelo Starlight.

## Scope

### Dentro do escopo

- Formato e local das specs de governança.
- Frontmatter obrigatório e seções.
- Ciclo de vida (`draft → approved → implemented`).
- Validação automatizada via `scripts/validate-specs.mjs`.
- Evolução do próprio formato.

### Fora do escopo

- Detalhes de implementação de cada feature.
- Regras de CI/CD gerais (ver `git-ci-cd.md`).

## References

- `scripts/validate-specs.mjs`
- Documentação do Chapter Frontend no Notion

## Frontmatter

```yaml
---
title: Nome da Spec
description: Resumo do escopo da spec.
status: draft
version: 1.0.0
owner: chapter-frontend
last-reviewed: YYYY-MM-DD
---
```

| Campo | Obrigatório | Descrição |
|---|---|---|
| `title` | Sim | Título curto e descritivo |
| `description` | Sim | Resumo do escopo |
| `status` | Sim | `draft`, `approved` ou `implemented` |
| `version` | Sim | Semver (`1.0.0`) |
| `owner` | Sim | Time responsável (`chapter-frontend`) |
| `last-reviewed` | Sim | Data da última revisão |

## Seções obrigatórias

| Seção | Finalidade |
|---|---|
| `Purpose` | Por que esta spec existe? |
| `Scope` | O que está dentro e fora do escopo |
| `References` | Documentos relacionados (ADRs, Notion, etc.) |
| `Must` | Regras obrigatórias |
| `Must not` | Restrições e proibições |
| `Done when` | Critérios objetivos de conclusão |

## Lifecycle

| Status | Quando usar |
|---|---|
| `draft` | Spec recém-criada, ainda não revisada |
| `approved` | Revisada e aprovada pelo Chapter |
| `implemented` | Práticas adotadas pelo time |

O status nunca é alterado manualmente — é derivado do processo de revisão.

## Roles

| Papel | Responsabilidade |
|---|---|
| Autor | Escreve a spec seguindo o template |
| Revisor | Valida conteúdo, clareza e aderência ao formato |
| Chapter | Aprova a spec e define prioridades |

## Must

- Toda spec de governança segue o frontmatter e seções obrigatórias definidos aqui.
- Toda spec é validada por `node scripts/validate-specs.mjs` antes de merge.
- Toda spec nova ou alterada deve ser sincronizada com o site via `node scripts/sync-specs-to-website.mjs`.
- O arquivo fica em `specs/governance/<area>/<nome>.md`.
- A linguagem principal é português brasileiro.

## Must not

- Não alterar `status` manualmente para `approved` ou `implemented`.
- Não renomear ou mover specs sem atualizar referências cruzadas.
- Não incluir informações sensíveis (tokens, URLs internas não públicas, credenciais).
- Não manter o validador divergente do formato documentado.

## Done when

- [ ] Formato das specs alinhado entre documentação e validador.
- [ ] `scripts/validate-specs.mjs` valida frontmatter e seções de toda spec de governança.
- [ ] Site Starlight reflete a estrutura de specs atualizada.
