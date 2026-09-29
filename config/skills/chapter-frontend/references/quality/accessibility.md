---
title: Acessibilidade Frontend
description: Define padrões mínimos de acessibilidade para aplicações frontend Aarin.
status: draft
version: 1.0.0
---

# Acessibilidade Frontend

## Purpose

Garantir que as aplicações sejam usáveis por todas as pessoas, incluindo aquelas que utilizam tecnologias assistivas.

## Scope

### Dentro do escopo

- Navegação por teclado.
- Contraste e cores.
- Semântica HTML e landmarks.
- Rótulos e roles ARIA.
- Foco visível.
- Testes de acessibilidade.

### Fora do escopo

- Design do design system base (MUI já cobre boa parte).
- Componentes específicos (tratados em specs de feature).

## References

- WCAG 2.1 AA
- `docs/adrs/adr-001-mui.md` (acessibilidade embutida)
- Notion — requisitos de acessibilidade

## Must

- Todos os apps visam conformidade WCAG 2.1 AA.
- Componentes interativos são acessíveis via teclado.
- Imagens relevantes possuem `alt` descritivo.
- Formulários possuem rótulos associados (`label` + `htmlFor`).
- Foco é sempre visível (`focus-visible`).
- Cores não são o único meio de comunicar estado ou erro.
- Uso correto de headings (`h1`, `h2`, etc.) para estrutura semântica.

## Must not

- Não remover foco visível sem substituto acessível.
- Não usar `div` como botão ou link sem roles e eventos de teclado.
- Não depender exclusivamente de cor para indicar erro.

## Done when

- [ ] Checklist de acessibilidade aplicado nos MRs.
- [ ] Auditagem periódica com ferramenta automática (axe, Lighthouse).
