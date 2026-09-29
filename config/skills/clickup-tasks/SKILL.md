# ClickUp — Task Management

Criar/atualizar tasks no ClickUp via MCP.

## Configuração

```jsonc
"mcpServers": {
  "clickup": {
    "command": "npx",
    "args": ["-y", "clickup-mcp"],
    "env": {
      "CLICKUP_API_TOKEN": "<seu-token>",
      "CLICKUP_API_KEY": "<seu-token>",
      "CLICKUP_TOKEN": "<seu-token>"
    }
  }
}
```

Token in `~/.gemini/antigravity-cli/plugins/clickup/mcp_config.json`.

## Maverick board (dev)

**List ID:** `901305333930`

### Naming convention

`[B/F][Escopo] - Breve descrição`

- `B` = Backend · `F` = Frontend
- `[Escopo]` = área/módulo (Login, AS, BL, Comissão, etc)

Example: `[F][Login] - Adicionar tratamento de erro para senha inválida`

### Description template (use as `### h3` headings)

```
### Objetivo técnico
[propósito, benefícios, parte do produto que interfere]

### Background do produto e interferências
[o que já existe, onde esta task se insere]

### Requisitos e Especificações técnicas
[requisitos técnicos + regras de negócio]

### Mitigação de Riscos
[riscos ou pontos de atenção]

### Documentação
[links Figma, Swagger, Confluence, etc]
```

## MCP tools available

- `get_tasks(listId)` — list tasks
- `get_task(taskId)` — task details
- `create_task(listId, name, description, ...)` — create
- `update_task(taskId, ...)` — update
- `add_task_comment(taskId, commentText)` — comment

## Example

```json
create_task({
  "listId": "901305333930",
  "name": "[F][Login] - Adicionar tratamento de erro para senha inválida",
  "description": "### Objetivo técnico\n...",
  "priority": 3
})
```
