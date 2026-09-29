---
title: Stack Tecnológica Frontend
description: Define a stack tecnológica permitida e os critérios de escolha entre Next.js e Vite + React no ecossistema frontend Aarin.
status: draft
version: 1.0.0
---

# Stack Tecnológica Frontend

## Purpose

Padronizar as tecnologias usadas no desenvolvimento frontend, reduzir variabilidade entre squads e garantir que cada projeto use a ferramenta certa para seu contexto.

## Scope

### Dentro do escopo

- Frameworks e bibliotecas obrigatórias para novos projetos.
- Critérios de escolha entre Next.js e Vite + React.
- Linguagem, bundler, test runner e libs compartilhadas.

### Fora do escopo

- Decisões arquiteturais de módulos (ver `architecture.md`).
- Padrões de design system (ver `runtime/design-system.md`).
- Configuração de CI/CD detalhada (ver `git-ci-cd.md`).

## References

- `SDD-ECOSSISTEMA-FRONTEND.md` (seção 2 — Restrições de Arquitetura)
- `docs/adrs/adr-001-mui.md`
- `docs/adrs/adr-002-redux.md`
- `docs/adrs/adr-003-datadog.md`
- `docs/adrs/adr-004-vitest.md`
- `docs/adrs/adr-005-vite.md`
- `docs/adrs/adr-006-web-utils.md`
- `docs/adrs/adr-007-as-const.md`
- Notion: "Quais tecnologias utilizamos?"
- Notion: "RFC: Adoção do Vite.js para aplicações React client-side"

## Stack Base (obrigatória)

| Camada | Tecnologia | Justificativa |
|---|---|---|
| Linguagem | TypeScript | Type safety, padronização, facilidade de contratação |
| UI | React | Stack consolidada, mercado amplo |
| Framework SSR/SEO | Next.js (App Router) | SSR, SSG, ISR, SEO |
| Bundler SPA | Vite.js + React | Build rápido, DX, microfrontends |
| Componentes | MUI (Material-UI) | Ecossistema maduro, acessibilidade, tema |
| Estilização | Emotion via MUI | Integração nativa |
| Estado global | Redux Toolkit | Previsível, testável, devtools |
| Testes | Vitest + happy-dom | Integração com Vite, performance |
| Observabilidade | Datadog RUM | RUM, session replay, tracing |
| Analytics | Amplitude | Autocapture + eventos manuais |
| Utilitários | Web Utils (npm interno) | Consistência entre apps |
| Deploy | AWS Amplify | Infraestrutura corporativa existente |
| CI/CD | GitLab CI | Ferramenta corporativa |

## Decision Tree — Next.js vs Vite

```
Novo projeto frontend
├── Precisa de SEO, SSR ou SSG?
│   ├── SIM → Next.js (App Router)
│   └── NÃO → Dashboard, ferramenta interna, SPA?
│       ├── SIM → Vite + React
│       └── NÃO → Avaliar caso a caso com Chapter Lead
```

### Usar Next.js quando

- SEO é requisito de negócio.
- A página precisa de renderização no servidor (SSR/SSG/ISR).
- Projeto é e-commerce, site público, portal de vendas com indexação.

### Usar Vite quando

- Aplicação é client-side only.
- Não há requisitos de SEO ou SSR.
- Projeto é dashboard, painel administrativo ou ferramenta interna.
- Planeja-se arquitetura de microfrontends no futuro.

## Must

- Todo novo projeto usa TypeScript obrigatoriamente.
- Todo novo projeto usa React.
- Escolha entre Next.js e Vite segue a decision tree desta spec.
- Todo projeto usa MUI como biblioteca de componentes base.
- Todo projeto usa Vitest para testes (exceto legados em migração).
- Todo projeto configura Datadog RUM.
- Todo projeto consome `@aarin/web-utils` ou equivalente para utilitários compartilhados.
- Novas tecnologias só são adotadas via RFC/ADR aprovado no chapter.

## Must not

- Não criar novos projetos com Create React App (CRA).
- Não usar Majoris/Panda CSS em projetos novos.
- Não introduzir libs de estado global diferentes do Redux Toolkit sem ADR.
- Não usar Jest em projetos novos (migrar para Vitest).
- Não escolher framework por familiaridade pessoal; seguir critérios objetivos.

## Done when

- [ ] Template de scaffold Next.js aprovado e disponível.
- [ ] Template de scaffold Vite + React aprovado e disponível.
- [ ] Scorecard do Port identifica stack de cada app e alerta desvios.
- [ ] Todo projeto novo passa por checklist de stack antes do primeiro deploy.
