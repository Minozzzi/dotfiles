---
name: maverick-task-creator
description: Cria tarefas no ClickUp no board de dev da Maverick, seguindo o template padrão (Objetivo, Background, Requisitos, etc), com títulos formatados em h3 e nomenclatura específica.
---

# Maverick Task Creator

Sempre que o usuário solicitar para "criar uma task", "criar card no clickup" ou similar no contexto da Maverick/Aarin, siga rigorosamente as regras abaixo.

## 1. Configuração do Board
- As tarefas devem ser criadas **exclusivamente** no List ID: `901305333930` (board de dev da Maverick).
- Utilize a ferramenta `create_task` do MCP `clickup` informando este `list_id`.

## 2. Nomenclatura do Título (Name)
O título da tarefa deve **sempre** seguir este padrão:
`[B/F][Escopo] - Breve descrição`
- `[B/F]`: Use `B` para Backend ou `F` para Frontend.
- `[Escopo]`: A área, jornada ou módulo afetado (ex: Login, AS, BL, Comissão, etc).
- `Breve descrição`: Resumo claro da ação.

*Exemplo: `[F][Login] - Adicionar tratamento de erro para senha inválida`*

## 3. Template da Descrição (Description)
A descrição deve ser enviada exatamente com o formato abaixo. Note que todos os títulos devem usar `###` (que equivale ao Heading 3 do markdown), sem dois-pontos `:` no final.

```markdown
### Objetivo técnico
[descreva o propósito e benefícios de ser feita esta task e para qual parte do produto ela interfere]

### Background do produto e interferências
[pontue brevemente do que existe já do produto e em que parte esta task irá se inserir ou possivelmente interferir]

### Requisitos e Especificações técnicas
[descreva e detalhe os requisitos técnicos e as regras de negócio]

### Mitigação de Riscos
[algum possível risco ou ponto de atenção para o desenvolvedor?]

### Documentação
[adicione aqui quaisquer links úteis do Figma, Swagger, Confluence, etc.]
```

## 4. Execução
1. Reúna as informações do contexto atual com o usuário para preencher corretamente o template. Se o usuário fornecer poucos dados, preencha o que for possível com o contexto da conversa.
2. Acione o tool `create_task` do MCP `clickup`, enviando o título formatado no campo `name` e a template substituída no campo `description`.
