---
title: Design System e Estilização
description: Define os padrões de componentes, tokens visuais e estilização usando MUI no ecossistema frontend Aarin.
status: draft
version: 1.0.0
---

# Design System e Estilização

## Purpose

Garantir consistência visual entre aplicações, reduzir retrabalho e definir quando usar componentes MUI, quando estendê-los e quando criar componentes compartilhados no design system.

## Scope

### Dentro do escopo

- Uso de MUI como base.
- Tokens de tema (cores, tipografia, espaçamento).
- Estratégia de estilização (props inline vs `sx` vs `styled`).
- Componentes compartilhados (`aarin-ui`, `modules/common/components`).
- Aarin Assets (ilustrações e assets).
- Iconografia e ícones compartilhados.

### Fora do escopo

- Especificações de componentes individuais (use specs de feature).
- Regras de acessibilidade detalhadas (ver `../quality/accessibility.md`).

## References

- `docs/adrs/adr-001-mui.md`
- `docs/guidelines/convencoes-codigo.md`
- `docs/adrs/adr-007-as-const.md`
- Notion: "Padrão de estilização MUI"
- Notion: "Como adicionar ilustrações no Aarin Assets"
- Notion: "Documento técnico sobre a estrutura da Aarin Assets"

## Principles

1. **MUI primeiro**: usar componentes MUI antes de criar novos.
2. **Tema como fonte da verdade**: cores, espaçamentos e tipografia vêm do tema.
3. **Props inline para poucas propriedades**: começar simples.
4. **`sx` para complexidade**: mover para `sx` quando houver mais de 4 propriedades, pseudoclasses ou media queries.
5. **Componentes compartilhados sob demanda**: extrair para `aarin-ui` apenas quando há reuso real.

## Must

- Usar MUI como base para todos os componentes.
- Respeitar o tema MUI (`theme.palette`, `theme.spacing`, `theme.typography`).
- Componentes reutilizáveis entre apps vivem em `aarin-ui` (ou equivalente).
- Componentes compartilhados dentro de uma app vivem em `modules/common/components`.
- Ilustrações e assets seguem a interface `PartnerAsset` e `assetNameList`.
- Tokens básicos seguem a interface `tokensBase`.
- Estilos CSS sempre em arquivos/`sx`/`styled`; nunca inline `style={{}}`.
- Cores, espaçamentos e breakpoints nunca hardcoded, exceto casos justificados.

## Must not

- Não misturar props inline com `sx` no mesmo componente MUI.
- Não usar mais de 4 props de estilização inline sem mover para `sx`.
- Não duplicar tokens ou estilos em múltiplos componentes.
- Não criar componentes do zero se MUI já oferece equivalente acessível.
- Não usar cores hex hardcoded fora do tema.
- Não importar Majoris/Panda CSS em projetos novos.

## Styling Strategy

| Cenário | Abordagem |
|---|---|
| 1–4 props de estilo rápidas | Props inline do MUI |
| > 4 props, pseudoclasses, media queries | `sx` com objeto separado (ex: `loginStyles.ts`) |
| Componente reutilizável com estilo complexo | `styled()` + tema |
| Tema por partner/white-label | `tokensBase` + override seletivo |

## Shared Components

| Escopo | Local |
|---|---|
| Entre aplicações | `aarin-ui` (npm interno) |
| Dentro de uma aplicação | `modules/common/components` |
| Dentro de um módulo | `modules/<module>/components` |

## Done when

- [ ] Tema MUI unificado publicado como source of truth.
- [ ] Catálogo de componentes `aarin-ui` documentado.
- [ ] Nenhum app usa cores hardcoded fora do tema.
- [ ] Port scorecard identifica uso de `aarin-ui` e ausência de inline styles.
