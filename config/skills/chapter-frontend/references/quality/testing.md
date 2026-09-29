---
title: Estratégia de Testes Frontend
description: Define framework, cobertura, estrutura e prioridades de testes no ecossistema frontend Aarin.
status: draft
version: 1.0.0
---

# Estratégia de Testes Frontend

## Purpose

Garantir qualidade e confiança nas entregas, priorizando testes de lógica e integração e mantendo cobertura mínima mensurável.

## Scope

### Dentro do escopo

- Framework de testes (Vitest + happy-dom).
- Cobertura mínima.
- Estrutura de testes.
- O que testar e em que ordem de prioridade.
- Uso de MSW para mocks de API.
- `data-testid` obrigatório.

### Fora do escopo

- Testes E2E (cobertos por Notion "Testes E2E").
- Testes de acessibilidade automatizados (ver `../quality/accessibility.md`).

## References

- `docs/adrs/adr-004-vitest.md`
- `docs/guidelines/testes.md`
- Notion: "Testes"
- Notion: "Data Test ID"
- Notion: "Mocks"

## Framework

- **Vitest** como framework padrão.
- **happy-dom** como ambiente de teste.
- Cobertura via `v8`.

## Coverage Thresholds

| Métrica | Mínimo |
|---|---|
| Statements | 80% |
| Branches | 75% |
| Functions | 80% |
| Lines | 80% |

## Testing Priority

| Prioridade | O que testar | Exemplo |
|---|---|---|
| Alta | Custom hooks | `useLogin`, `useAuth` |
| Alta | Services / API calls | `authService.login` |
| Alta | Componentes interativos | `Button`, `Form`, `Modal` |
| Média | Selectors Redux | `selectUser` |
| Média | Páginas (casos principais) | `LoginPage` renderiza |
| Baixa | Constantes e tipos | Geralmente não testar |

## Must

- Todo projeto usa Vitest.
- Todo elemento interativo recebe `data-testid` em kebab-case e em inglês.
- Hooks de lógica de negócio são testados de forma isolada.
- Services são testados com mocks de API.
- Componentes interativos são testados com `@testing-library/react` e `user-event`.
- Estrutura de testes em `tests/` ou `__tests__/` por módulo/página.
- Testes de data/time configuram timezone `America/Sao_Paulo`.

## Must not

- Não usar Jest em projetos novos.
- Não testar constantes e tipos puros.
- Não deixar componentes interativos sem `data-testid`.
- Não importar mocks de teste em código de produção.
- Não criar data-testid em português, camelCase ou sem prefixo claro.

## Examples

```typescript
// ✅ data-testid
<button data-testid="create-partner-button">Salvar</button>

// ❌ data-testid ruim
data-testid="adicionarSocio"
data-testid="editar_socio"
```

## Done when

- [ ] Vitest configurado em todos os projetos.
- [ ] Cobertura mínima atingida e validada no CI.
- [ ] 100% dos componentes interativos com `data-testid`.
- [ ] Testes de hook cobrem sucesso, erro e loading.
- [ ] SonarQube sem bloqueadores/críticos.
