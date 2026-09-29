---
name: jira-task-creator
description: Cria tasks, bugs, stories e outros tipos de issue no Jira após coletar projeto, tipo, campos e confirmação. Use quando o usuário pedir para criar uma task, ticket ou issue, tratando Jira como destino padrão em vez de ClickUp.
---

# Jira Task Creator

Use este fluxo para solicitações de criação de tasks/tickets. O destino padrão é Jira; não crie essas solicitações no ClickUp nem reutilize regras específicas do antigo fluxo do ClickUp.

## Fluxo de criação

1. Entenda o objetivo e reúna o contexto que o usuário já forneceu. Não pergunte novamente o que estiver claro na conversa. Se faltar informação necessária para descrever o trabalho, pergunte antes de preparar a issue; não invente requisitos, critérios de aceite, escopo ou decisões técnicas.
2. Para cada issue, pergunte qual site/instância Jira e projeto devem ser usados. Use `atlassian_getVisibleJiraProjects` com `action: "create"` para validar projetos disponíveis e permissões de criação. Se o usuário não souber o projeto, apresente os projetos disponíveis e peça que escolha; não escolha por conta própria.
3. Depois da escolha do projeto, obtenha os tipos disponíveis com `atlassian_getJiraProjectIssueTypesMetadata`. Apresente os tipos válidos naquele projeto e pergunte qual usar. Não assuma que Task, Bug, Story, Epic ou Sub-task existem em todos os projetos.
4. Para o tipo escolhido, consulte `atlassian_getJiraIssueTypeMetaWithFields` com `requiredFieldsOnly: false`. Use os metadados do projeto/tipo para descobrir campos obrigatórios, campos opcionais, formatos, IDs, descrições e opções válidas.
5. Pergunte os valores de todos os campos disponíveis para criação, agrupando-os em obrigatórios e opcionais e explicando as opções fornecidas pelo Jira. Para opcionais, permita que o usuário escolha explicitamente deixar vazio. Não preencha valores ausentes por suposição. Pergunte sobre campos condicionais ou customizados somente quando os metadados os disponibilizarem para aquele projeto/tipo. Colete o summary e a description no rascunho do passo seguinte, sem perguntar esses mesmos campos uma segunda vez. Para assignee, consulte/valide o usuário no Jira antes de usar seu account ID. Para subtasks, peça e valide a issue pai.
6. Proponha título e descrição. Antes de definir o formato, consulte até cinco issues recentes do mesmo projeto e tipo usando `atlassian_searchJiraIssuesUsingJql` para identificar convenções úteis. Trate exemplos apenas como referência, não como requisito; não copie conteúdo de outras issues. Se não houver exemplos acessíveis ou consistentes, proponha um formato claro e enxuto com base no contexto fornecido e indique que é uma proposta. Para tasks de backend, prefixe o summary com `B | ` (ex.: `B | Adequar Products API à migração para EKS Pod Identity`). Não transfira automaticamente para o Jira o formato legado do ClickUp (`[B/F][Escopo]`) nem o template antigo. Mostre ao usuário o título e a descrição completos e permita ajustes.
7. Mostre um rascunho completo de cada issue, incluindo site, projeto, tipo e todos os campos escolhidos; marque campos opcionais deixados vazios. Para lotes, mostre todos os rascunhos juntos. Só prossiga após confirmação explícita do conteúdo final e da criação.
8. Crie cada issue confirmada com `atlassian_createJiraIssue`. Use `parent` para subtasks; envie prioridade, labels, components, versões e campos customizados em `additional_fields`, respeitando os nomes/IDs e formatos obtidos nos metadados. Use `contentFormat: "markdown"` para descrição em Markdown. Não envie campos desconhecidos nem valores incompatíveis.
9. Informe o resultado confirmado pelo Jira, incluindo chave, tipo, projeto e link quando retornado/disponível. Se uma criação falhar, reporte exatamente a falha e quais itens do lote foram ou não criados. Nunca afirme que uma issue foi criada sem resposta bem-sucedida da ferramenta.

## Uso das ferramentas

- Antes de chamar ferramentas Jira, descubra/confirme as ferramentas Atlassian disponíveis no portal. Use os nomes exatos retornados pelo catálogo; não invente nomes de ferramentas ou parâmetros.
- Ferramentas esperadas para este fluxo: `atlassian_getVisibleJiraProjects`, `atlassian_getJiraProjectIssueTypesMetadata`, `atlassian_getJiraIssueTypeMetaWithFields`, `atlassian_searchJiraIssuesUsingJql`, `atlassian_lookupJiraAccountId` e `atlassian_createJiraIssue`.
- `cloudId` aceita o identificador da instância ou a URL do site conforme o schema da ferramenta. Peça essa informação em cada solicitação se não estiver explícita ou inequívoca no contexto atual.
- Se a ferramenta, projeto, tipo ou campo não estiver disponível por permissão/integração, não tente contornar nem use ClickUp como fallback. Explique o bloqueio e peça a informação ou acesso necessário.
