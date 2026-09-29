---
title: Gestão de Estado Frontend
description: Define o uso de Redux Toolkit, estado local e padrões para estado compartilhado no ecossistema frontend Aarin.
status: draft
version: 1.0.0
---

# Gestão de Estado Frontend

## Purpose

Garantir estado global previsível, testável e limitado ao necessário, enquanto mantém estado local quando apropriado.

## Scope

### Dentro do escopo

- Uso de Redux Toolkit.
- Organização de slices, selectors e thunks.
- Estado global vs estado local.
- Integração com custom hooks.

### Fora do escopo

- Escolha de outra lib de estado (já decidida via ADR-002).
- Persistência de estado (ver `../security/security.md`).

## References

- `docs/adrs/adr-002-redux.md`
- `docs/guias/boas-praticas-redux.md`
- Notion: "WIP - Boas práticas com redux"

## Principles

1. **Estado global mínimo**: apenas estado realmente compartilhado fica no Redux.
2. **Domínio único por slice**: cada slice gerencia um domínio.
3. **Selectors obrigatórios**: nunca acessar `state` diretamente no componente.
4. **Hooks encapsulam dispatch**: lógica de interação com store fica em hooks.

## Must

- Usar Redux Toolkit para estado global.
- Separar cada domínio em `slice.ts`, `selectors.ts` e `thunks.ts`.
- Acessar estado via `useAppSelector(selector)`.
- Usar custom hooks para encapsular `dispatch`.
- Manter estado local em `useState`/`useReducer` quando não for compartilhado.
- Usar `createSlice` com Immer para mutação segura.

## Must not

- Não colocar lógica de negócio em reducers (reducers devem ser puros).
- Não acessar `state.dominio.dado` diretamente no componente.
- Não criar slices gigantes que gerenciam múltiplos domínios.
- Não dar spread em `action.payload` sem validação.
- Não usar Context API para substituir Redux em casos de estado global.

## Folder Structure

```
src/store/
  slices/
    auth/
      authSlice.ts
      authSelectors.ts
      authThunks.ts
```

## Done when

- [ ] Todos os projetos seguem estrutura de slices/selectors/thunks.
- [ ] 0 acessos diretos a `state` em componentes.
- [ ] Estado global auditado: tudo que está no Redux é realmente compartilhado.
