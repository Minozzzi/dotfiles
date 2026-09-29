---
title: Git, Merge Requests e CI/CD
description: Define o fluxo de branches, commits, merge requests e pipeline de CI/CD do ecossistema frontend Aarin.
status: draft
version: 1.0.0
---

# Git, Merge Requests e CI/CD

## Purpose

Garantir entregas contínuas, revisadas e seguras, padronizando o fluxo de Git, a estrutura dos MRs e as etapas do pipeline.

## Scope

### Dentro do escopo

- Nomenclatura e fluxo de branches.
- Formato de commits e MRs.
- Regras de aprovação.
- Stages do pipeline GitLab CI.
- Deploy em dev, sandbox e produção via Amplify.
- Feature release trains.

### Fora do escopo

- Detalhes de implementação de cada app.
- Configuração de observabilidade (ver `quality/observability.md`).
- Formato de specs (ver `specdd-governance.md`).

## References

- `docs/guidelines/git-e-mrs.md`
- `docs/guias/como-construimos-frontend.md`
- `.gitlab-ci.yml`
- Notion: "Frontend Guideline" (seção Git)
- Notion: "Fluxo de deploy para MAIN"

## Branch Flow

```
main ──── sandbox ──── dev ──── feat/FRONTCORE-XXXX
                                    └── fix/FRONTCORE-XXXX
                                    └── chore/FRONTCORE-XXXX
                                    └── refactor/FRONTCORE-XXXX
                                    └── release/vX.Y.Z
```

### Branch Naming

| Prefixo | Uso |
|---|---|
| `feat/` | Nova funcionalidade |
| `fix/` | Correção de bug |
| `chore/` | Configuração, dependências, CI |
| `refactor/` | Refatoração sem mudança de comportamento |
| `release/` | Release train |

Toda branch deve conter ID do ClickUp:

```
feat/FRONTCORE-12055-adicionar-funcionalidade
fix/FRONTCORE-1055-intangible-button
chore/FRONTCORE-1055-configurar-eslint
```

## Commits

- Seguir Conventional Commits.
- Mensagem em inglês, imperativo, máximo 72 caracteres.
- Commits pequenos, atômicos e descritivos.

```
feat: open sidebar link in new tab
refactor: remove button legacy from login page
chore: configure vitest setup
fix: correct padding on mobile
```

## Merge Request

### Título

Descritivo, em português.

```
feat: adicionar funcionalidade de recuperação de senha
```

### Descrição obrigatória

```markdown
## O que foi feito
Breve explicação.

## Task
[FRONTCORE-XXXX](https://app.clickup.com/t/XXXX)

## Evidências
- Screenshot/vídeo
- Print de testes
- Link preview deploy

## Checklist
- [ ] Código segue convenções
- [ ] Testes passando
- [ ] Pipeline verde
```

### Regras de aprovação

| Critério | Obrigatório |
|---|---|
| Pipeline CI verde | Sim |
| Mínimo 1 approve | Sim |
| Sem conflitos | Sim |
| Descrição preenchida | Sim |
| Task do ClickUp | Sim |
| Evidências | Sim |

## Pipeline

| Stage | Comando | Valida |
|---|---|---|
| `lint` | `npm run lint && npm run typecheck` | Qualidade e tipagem |
| `test` | `npm run test:ci` | Testes e cobertura |
| `build` | `npm run docs:build` / `npm run build` | Compilação |
| `deploy` | `npx @aws-amplify/cli publish --app-id $AMPLIFY_ID_*` | Deploy por branch |

## Ambientes

| Branch | Ambiente | URL |
|---|---|---|
| `dev` | Dev | `dev.app.aarin.com.br` |
| `sandbox` | Sandbox | `sandbox.app.aarin.com.br` |
| `main` | Produção | `app.aarin.com.br` |

## Feature Release

Para features grandes com múltiplas tarefas:

1. Criar `release/vX.Y.Z` a partir de `main`.
2. Criar `feat/` a partir da release.
3. Mergear `feat/` em `release/` conforme completas.
4. Mergear `release/` → `dev` → `sandbox` → `main`.

## Must

- Todo MR para `dev`/`sandbox`/`main` passa por review e pipeline verde.
- Toda branch com ID do ClickUp.
- Todo MR descreve o que foi feito, task e evidências.
- Deploy para produção só via merge em `main`.
- Resolver conflitos localmente antes do merge.
- Não fazer force push em branches compartilhadas.

## Must not

- Não mergear sem approve.
- Não mergear com pipeline vermelho.
- Não enviar alterações não relacionadas à task no mesmo MR.
- Não fazer deploy manual fora do pipeline, exceto hotfix autorizado.

## Done when

- [ ] `.gitlab-ci.yml` reflete stages e jobs desta spec.
- [ ] MR template configurado no GitLab com checklist.
- [ ] Pipeline executa validação de specs (em projetos com SpecDD).
- [ ] 100% dos MRs para `dev`/`sandbox`/`main` têm pelo menos 1 approve.
- [ ] Nenhum deploy de produção ocorre fora de `main`.
