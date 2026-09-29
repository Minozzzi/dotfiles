---
title: Analytics e Eventos de Negócio
description: Define a governança de eventos frontend com Amplitude no ecossistema Aarin.
status: draft
version: 1.0.0
---

# Analytics e Eventos de Negócio

## Purpose

Garantir que eventos de negócio sejam rastreados de forma consistente, sem dependência excessiva de código, e sob controle do time de produto.

## Scope

### Dentro do escopo

- Autocapture de interações (Amplitude).
- Eventos manuais e nomenclatura.
- Governança de eventos.
- Controle de propriedades obrigatórias.

### Fora do escopo

- Observabilidade técnica (ver `../quality/observability.md`).
- Eventos de backend.

## References

- Notion: "Amplitude"
- Notion: "Governança de Eventos Frontend"
- Notion: "Arquitetura" (Amplitude)
- `SDD-ECOSSISTEMA-FRONTEND.md` (seção 8.2 — Observabilidade)

## Principles

1. **Autocapture primeiro**: aproveitar autocapture do Amplitude antes de criar eventos manuais.
2. **Nomenclatura padronizada**: eventos manuais seguem padrão deproduto.
3. **Controle do PM**: time de produto gerencia configuração remota e visibilidade.
4. **Nenhum dado sensível**: eventos não devem conter CPF, CNPJ, senha ou token.

## Must

- Todo app inicializa Amplitude com configuração de produto.
- Eventos manuais enviados via função utilitária padronizada.
- Nomenclatura de eventos em inglês, `snake_case`.
- Propriedades comuns (ex: `page`, `user_id`, `product`) padronizadas.
- Exportação rápida de catálogo de eventos para CSV.
- Revisão de novos eventos manuais por PM.

## Must not

- Não duplicar tracking do mesmo evento.
- Não enviar dados sensíveis em propriedades de evento.
- Não criar eventos manuais sem documentar no catálogo.
- Não depender de deploy para criar/configurar eventos (usar configuração remota).

## Example

```typescript
amplitude.track('login_success', { userId: '...', method: 'cnpj' })
```

## Done when

- [ ] Catálogo de eventos por app documentado.
- [ ] 100% dos eventos manuais revisados por PM.
- [ ] Auditoria de dados sensíveis em eventos.
