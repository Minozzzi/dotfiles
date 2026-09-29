---
title: Internacionalização (i18n)
description: Define padrões de internacionalização para aplicações frontend Aarin.
status: draft
version: 1.0.0
---

# Internacionalização (i18n)

## Purpose

Padronizar como textos, datas e formatos locais são gerenciados nas aplicações, reduzindo strings hardcoded e facilitando futura expansão multilíngue.

## Scope

### Dentro do escopo

- Estrutura de arquivos de `locales/`.
- Formato de chaves.
- Idioma padrão e fallback.
- Formatação de data, número e moeda.

### Fora do escopo

- Regras de negócio de localização.
- Traduções de conteúdo dinâmico de backend.

## References

- `docs/guias/arquitetura-modulos.md` (seção Pages/Locales)
- Notion: "Frontend Guideline"
- `SDD-ECOSSISTEMA-FRONTEND.md` (seção 8.3 — Internacionalização)

## Must

- Idioma padrão: `pt-BR`.
- Fallback para `pt-BR` quando uma chave não existe.
- Textos de UI vivem em arquivos `locales/` dentro da página ou módulo.
- Chaves em `camelCase` descritivo e em inglês.
- Uso de `@aarin/web-utils` para formatação de data/moeda/documento.

## Must not

- Não deixar strings hardcoded em componentes.
- Não duplicar chaves entre módulos quando compartilhadas.
- Não misturar lógica de formatação com strings de UI.

## Example

```typescript
// pt-BR.ts
export const locales = {
  loginTitle: 'Acessar minha conta',
  cnpjLabel: 'CNPJ',
  passwordLabel: 'Senha',
  button: 'Entrar',
} as const
```

## Done when

- [ ] 0 strings hardcoded em componentes de UI.
- [ ] Fallback de i18n funcionando.
