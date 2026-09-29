---
title: Performance e Core Web Vitals
description: Define metas de performance, práticas de otimização e monitoramento de Web Vitals.
status: draft
version: 1.0.0
---

# Performance e Core Web Vitals

## Purpose

Garantir uma experiência rápida e estável para usuários, com metas claras de performance e reação a regressões.

## Scope

### Dentro do escopo

- Core Web Vitals (LCP, INP, CLS).
- Code splitting e lazy loading.
- Otimização de assets e bundles.
- Cache de API.
- Monitoramento e alertas.

### Fora do escopo

- Infraestrutura de CDN/Amplify.
- Backend performance.

## References

- Notion: "Performance"
- Notion: "Web Vitals"
- `SDD-ECOSSISTEMA-FRONTEND.md` (seção 8.5 — Cache e Performance)

## Targets

| Métrica | Meta |
|---|---|
| LCP | < 2.5s |
| INP | < 200ms |
| CLS | < 0.1 |
| Tempo de carregamento (3G) | < 3s |
| TTI | < 5s |

## Must

- Medir Core Web Vitals em produção (Datadog RUM ou equivalente).
- Usar code splitting automático do Next.js App Router / Vite.
- Lazy loading de componentes pesados (modais, gráficos, etc.).
- Otimizar imagens e assets (formatos modernos, lazy load).
- Usar cache de dados de API quando aplicável (SWR, React Query, ISR).
- Reagir a regressões de performance detectadas nos dashboards.

## Must not

- Não carregar bundles inteiros quando apenas parte é necessária.
- Não ignorar alertas de LCP/INP/CLS degradados.
- Não usar imagens não otimizadas em produção.

## Done when

- [ ] Dashboards de Web Vitals configurados.
- [ ] Regressões geram alertas automáticos.
- [ ] 90%+ das páginas principais dentro das metas.
