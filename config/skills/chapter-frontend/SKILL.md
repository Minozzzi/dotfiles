---
name: chapter-frontend
description: |
  Regras de governança frontend da Aarin mantidas pelo Chapter Frontend.
  Use SEMPRE que estiver trabalhando em projetos frontend da Aarin e
  precisar validar decisões contra as specs oficiais do Chapter. Aciona
  para: arquitetura de módulos, stack tecnológica, CI/CD, estratégia de
  testes, observabilidade com Datadog, Core Web Vitals, acessibilidade
  WCAG, camada de API, estado (Redux Toolkit), design system, segurança
  (CSP/tokens), analytics (Amplitude), internacionalização, ownership de
  features e migração de legado.
  Também ative ao criar ou revisar specs de feature em .opencode/specs/
  — o template e as regras de SpecDD estão aqui.
---

# Chapter Frontend — Skills de Governança

As especificações de governança do Chapter Frontend da Aarin, disponíveis como
skill para agents.

## When To Use

Acione este skill quando o trabalho envolver:

- **Arquitetura**: definir estrutura de módulos, camadas, boundaries.
- **Stack**: decidir entre Next.js e Vite, escolher bibliotecas.
- **CI/CD**: configurar pipelines, fluxo de MRs, deploy.
- **Qualidade**: escrever testes, configurar Datadog RUM, auditar performance
  ou acessibilidade.
- **Runtime**: criar services de API, gerenciar estado global, usar tokens do
  design system.
- **Segurança**: configurar CSP, proteger tokens, evitar vazamento de dados.
- **Plataforma**: configurar analytics (Amplitude), adicionar i18n, definir
  ownership de feature, planejar migração de legado.
- **Specs de feature**: criar ou revisar specs em `.opencode/specs/`.

Não acione para backend, infraestrutura geral, ou projetos não-Aarin.

## Required Context

Antes de implementar ou revisar qualquer coisa neste escopo, leia a spec
correspondente em `references/<area>/<spec>.md`. Cada spec contém:

- **Purpose** — por que a regra existe.
- **Scope** — o que está dentro e fora.
- **Must / Must not** — obrigações e restrições.
- **Done when** — critérios objetivos de conclusão.

## Reference Index

| Área | Spec | Quando consultar |
|---|---|---|
| **Critical** | [specdd-governance](references/specdd-governance.md) | Criar ou revisar formato de specs |
| | [architecture](references/architecture.md) | Definir módulos, camadas, boundaries |
| | [frontend-stack](references/frontend-stack.md) | Escolher framework, libs, runtime |
| | [git-ci-cd](references/git-ci-cd.md) | Configurar Git, MRs, pipeline, deploy |
| **Quality** | [testing](references/quality/testing.md) | Escrever testes, revisar cobertura |
| | [observability](references/quality/observability.md) | Configurar Datadog RUM, tracing |
| | [performance](references/quality/performance.md) | Auditar Core Web Vitals, bundle |
| | [accessibility](references/quality/accessibility.md) | Garantir conformidade WCAG 2.1 AA |
| **Runtime** | [api-layer](references/runtime/api-layer.md) | Criar services, mocks, tratar erros |
| | [state-management](references/runtime/state-management.md) | Definir estado local/global, Redux |
| | [design-system](references/runtime/design-system.md) | Usar tokens, estilização, temas |
| **Security** | [security](references/security/security.md) | Configurar CSP, proteger tokens |
| **Platform** | [analytics](references/platform/analytics.md) | Instrumentar Amplitude, eventos |
| | [internationalization](references/platform/internationalization.md) | Adicionar i18n, gerenciar locales |
| | [feature-ownership](references/platform/feature-ownership.md) | Definir squads, ownership |
| | [legacy-migration](references/platform/legacy-migration.md) | Planejar migração de projetos |

## Process

1. Identifique qual área o trabalho atual impacta.
2. Leia a spec correspondente em `references/<area>/`.
3. Extraia as regras `Must` e `Must not` aplicáveis ao contexto.
4. Ao criar uma spec de feature, use o template em
   `references/_template.md` e referencie as specs de governança usadas.
5. Documente desvios justificados — toda exceção precisa de rationale.

## Output Format (revisão de aderência)

Quando revisar código ou decisão contra as specs, reporte:

```markdown
## Findings

- [severity] Título do problema
  Spec violada: `nome-da-spec`
  Local: `caminho/arquivo:linha`
  Por que viola: explicação.
  Correção sugerida: direção concreta.

## Summary

Contexto secundário. Decisões acertadas também podem ser mencionadas.
```

### Severidade

- **P0**: violação com impacto em segurança, dados ou produção.
- **P1**: desvio de padrão obrigatório (`Must`) com risco médio.
- **P2**: desvio de recomendação (`Must not`) ou boas práticas.
- **P3**: sugestão de melhoria sem impacto crítico.
