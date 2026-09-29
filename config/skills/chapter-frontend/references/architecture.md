---
title: Arquitetura de Módulos Frontend
description: Define a arquitetura de referência do ecossistema frontend Aarin (feature/module by pack, camadas e responsabilidades).
status: draft
version: 1.0.0
---

# Arquitetura de Módulos Frontend

## Purpose

Garantir que todas as aplicações frontend Aarin sigam uma arquitetura comum, escalável e testável, separando claramente apresentação, lógica de negócio e acesso a dados.

## Scope

### Dentro do escopo

- Estrutura de pastas padrão (`config/`, `modules/`, `app/`).
- Separação de responsabilidades por camada (Page/Screen, Custom Hook, Service, Component).
- Organização em módulos funcionais (feature/module by pack).
- Padrões para apps Next.js (App Router) e Vite + React.

### Fora do escopo

- Escolha entre Next.js e Vite (ver `frontend-stack.md`).
- Configuração específica de bibliotecas (MUI, Redux, etc.).
- Especificações de componentes individuais (use `.md`).

## References

- `SDD-ECOSSISTEMA-FRONTEND.md`
- `docs/sdd.md`
- `docs/guias/arquitetura-modulos.md`
- `docs/adrs/adr-001-mui.md`
- `docs/adrs/adr-002-redux.md`
- Notion: "Qual arquitetura seguimos?"
- Notion: "Arquitetura Frontend"

## Principles

1. **Separation of Concerns**: UI, lógica de negócio e acesso a dados em camadas distintas.
2. **Feature/Module by Pack**: cada funcionalidade vive em um módulo com seu próprio ecossistema.
3. **Custom Hook Pattern**: toda lógica de negócio fica em hooks; páginas e screens são "burras".
4. **Responsabilidade Única**: cada arquivo, componente e função faz uma coisa bem.
5. **Baixo acoplamento entre módulos**: módulos não importam internamente uns dos outros sem justificativa aprovada.

## Must

- Apps Next.js usam `app/` para roteamento e `modules/` para funcionalidades.
- Apps Vite usam `src/` como raiz e seguem a mesma estrutura de módulos.
- Cada módulo contém pelo menos: `data/`, `pages/` e/ou `components/`, `hooks/`, `constants/`.
- Páginas e screens consomem hooks; não implementam regras de negócio.
- Custom hooks encapsulam estado, validação e chamadas a services.
- Services em `data/services/` são a única camada que faz chamadas HTTP.
- Componentes compartilhados entre módulos devem migrar para `modules/common/components` ou `aarin-ui`.
- Tipos de input/output de API vivem em `data/types/`.

## Must not

- Não colocar regras de negócio em components ou pages.
- Não chamar APIs diretamente de hooks de UI ou de event handlers inline.
- Não importar de `modules/<outro-modulo>/pages` ou suas subpastas internas.
- Não manter estado global desnecessário no Redux (ver `runtime/state-management.md`).
- Não criar componentes gigantes com múltiplas responsabilidades.

## Responsibilities by Layer

| Camada | Responsabilidade | Onde testar |
|---|---|---|
| Page/Screen | Renderização, eventos de UI, consumo do hook | Teste de render |
| Custom Hook | Lógica de negócio, estado, chamadas a services | Teste unitário puro |
| Service | Chamadas HTTP, serialização, tratamento de erro | Mock/integração |
| Component | UI reutilizável, sem regra de negócio | Teste de componente |
| Type | Interfaces de entrada e saída de dados | Static analysis |

## Folder Structure Reference

```
src/
  config/
    assets/          # Recursos estáticos por partner
    theme/           # Tokens e tema MUI
    providers/       # Providers de API (headers, base URL, tokens)
    contexts/        # Context API quando aplicável

  modules/
    <module-name>/
      data/
        services/    # Chamadas HTTP
        types/       # Interfaces de API
      pages/
        <page-name>/
          screens/     # Componentes de tela
          locales/     # i18n
          styles/      # sx props / estilização
          hooks/       # Hooks da página
          components/  # Componentes específicos da página
          data/        # Services específicos da página
          tests/       # Testes da página
      hooks/           # Hooks compartilhados do módulo
      components/      # Componentes compartilhados do módulo
      constants/       # Constantes do módulo
      tests/           # Testes do módulo

  app/                 # Next.js App Router
    <module-name>/
    layout.tsx
```

## Done when

- [ ] Todas as aplicações novas seguem a estrutura de módulos sem exceção.
- [ ] Cada app possui um `ARCHITECTURE.md` local apontando desvios justificados.
- [ ] Port scorecard verifica estrutura de pastas e ausência de regras em pages.
- [ ] Code review valida separação de camadas.
