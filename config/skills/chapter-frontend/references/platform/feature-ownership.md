---
title: Ownership de Aplicações e Squads
description: Define como aplicações, bibliotecas e áreas de frontend são ownershipadas por squads e tech leads.
status: draft
version: 1.0.0
---

# Ownership de Aplicações e Squads

## Purpose

Tornar claro quem é responsável por cada aplicação, biblioteca e decisão técnica do ecossistema frontend.

## Scope

### Dentro do escopo

- Registro de aplicações frontend no Port.
- Registro de bibliotecas compartilhadas.
- Definição de squads e tech leads responsáveis.
- Regras de aprovação de ADRs e specs.

### Fora do escopo

- Organização de times fora de frontend.
- Orçamento ou capacity de squads.

## References

- `docs/port/catalogo-scorecards.md`
- Notion: "Frontend" (Principais Stakeholders)
- Notion: "Chapter Frontend"

## Roles

| Papel | Responsabilidade |
|---|---|
| Chapter Lead | Governança, consistência, evolução técnica, aprovação de ADRs |
| Tech Lead | Decisões técnicas do app/lib, revisão de specs |
| Squad | Manutenção e evolução das apps sob sua responsabilidade |
| Product Manager | Prioridade e escopo de features |
| Chapter Frontend | Alinhamento quinzenal de padrões |

## Must

- Toda aplicação frontend registrada no Port com owner (squad + tech lead).
- Toda biblioteca compartilhada (`aarin-ui`, `web-utils`, `aarin-assets`) possui mantenedor.
- Toda ADR/SDD especifica autores e revisores.
- Toda MR de frontend com impacto arquitetural passa por pelo menos 1 tech lead.
- Chapter Frontend mantém registro de reuniões e ações.

## Must not

- Não deixar app sem owner identificado.
- Não permitir que bibliotecas compartilhadas sejam alteradas sem comunicar mantenedor.
- Não tomar decisões cross-app sem alinhamento do chapter.

## Blueprints

Ver `docs/port/catalogo-scorecards.md` para modelos de `frontendApp` e `library`.

## Done when

- [ ] 100% das apps registradas no Port.
- [ ] 100% das libs compartilhadas com mantenedor documentado.
- [ ] Scorecard de conformidade ativo.
