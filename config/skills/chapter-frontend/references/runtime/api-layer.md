---
title: Camada de API, Providers e Mocks
description: Define como o frontend consome APIs, trata erros, serializa dados e usa mocks durante o desenvolvimento.
status: draft
version: 1.0.0
---

# Camada de API, Providers e Mocks

## Purpose

Padronizar a comunicação com backend, reduzir duplicação de lógica HTTP e garanter tratamento de erro, loading e serialização consistentes em todas as aplicações.

## Scope

### Dentro do escopo

- Providers de API (headers, base URL, tokens).
- Services e serialização.
- Tratamento de erro, loading e retry.
- Mocks de teste e mocks de integração (API routes).
- Convenções de nomenclatura e retorno.

### Fora do escopo

- Padrões de UI para loading/erro (mas a camada deve expor estados para UI).
- Autenticação de alto nível (ver `../security/security.md`).

## References

- `docs/guias/arquitetura-modulos.md`
- `SDD-ECOSSISTEMA-FRONTEND.md` (seção 8.1 — Tratamento de Erros)
- Notion: "Mocks"
- Notion: "Configuração WL com MUI" (providers)

## Principles

1. **Services são a única camada HTTP**: hooks e componentes não fazem fetch direto.
2. **Erros serializados**: services lançam exceções tipadas (`ApiError`).
3. **Estados explícitos**: hooks expõe `isLoading`, `error`, `data`.
4. **Mocks como contrato**: simulam o contrato real, não apenas dados estáticos.

## Must

- Cada app possui providers em `config/providers/` (headers, base URL, token).
- Services vivem em `modules/<module>/data/services/` ou `modules/<module>/pages/<page>/data/services/`.
- Tipos de request/response vivem em `data/types/`.
- Services retornam dados serializados ou lançam `ApiError`.
- Hooks consomem services e expõe estados claros para UI.
- Mocks de teste vivem em `__tests__/mocks/` e são escritos em TypeScript (não JSON).
- Mocks de integração usam Next.js API routes quando aplicável.
- Tratamento de erro padronizado: log no Datadog + mensagem amigável para usuário.

## Must not

- Não usar `fetch`/`axios` diretamente em componentes ou hooks de página.
- Não propagar erros brutos de HTTP para a UI.
- Não usar JSON para mocks de teste.
- Não importar mocks de teste em código de produção.
- Não duplicar lógica de retry/cancelamento em vários services.

## Error Handling

| Camada | Ação |
|---|---|
| Service | Valida response, serializa erro em `ApiError` |
| Hook | Captura erro, expõe `error` e dispara log |
| UI | Renderiza mensagem amigável, spinner, empty state |
| Global | Error boundary captura erros não tratados |

## Mocks por Contexto

| Tipo | Local | Uso |
|---|---|---|
| Teste | `__tests__/mocks/mocks.ts` | Apenas em testes |
| Integração API | `api/<resource>/(mocks)/` | Simula backend durante desenvolvimento |

## Done when

- [ ] Todos os apps usam providers centralizados.
- [ ] 100% dos calls HTTP passam por services tipados.
- [ ] Mocks de teste são TypeScript e isolados do código produtivo.
- [ ] Testes cobrem cenários de sucesso, erro e loading.
- [ ] Erros de API são logados no Datadog.
