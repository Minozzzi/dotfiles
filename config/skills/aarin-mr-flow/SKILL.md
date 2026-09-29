---
name: aarin-mr-flow
description: Automação global do fluxo de Merge Requests (Aarin/Consórcio). Criação de branches (inglês, com ID do ClickUp, sempre a partir da main), abertura de MR apenas no ambiente DEV com links, labels, revisores e dependências utilizando os MCPs (GitLab, ClickUp, Figma).
---

# Fluxo de Merge Requests Automático (Aarin/Consórcio)

Sempre que o usuário solicitar para "iniciar o fluxo de MRs", "criar as branches/MRs da task" ou invocar essa skill, siga rigorosamente as regras abaixo.

## 1. Interação Inicial (Revisor)
- **ATENÇÃO**: Antes de criar os MRs, pergunte obrigatoriamente ao usuário: *"Quem deve ser definido como reviewer para este MR?"*
- Não assuma nenhum revisor. O reviewer fornecido pelo usuário deverá ser configurado EXCLUSIVAMENTE via parâmetro no GitLab MCP para garantir que fique correto na UI do GitLab. Se o MCP falhar nesse atributo, use como fallback a Quick Action `/reviewer @revisor` na descrição.

## 2. Coleta de Dados via MCP
- Utilize o **ClickUp MCP** buscando pelo ID da task para descobrir o **nome exato da task** e obter o link direto.
- Utilize o **Figma MCP** para obter a URL de contexto visual (opcional).

## 3. Nomenclatura de Branch, Commits e Títulos
- **Commits**: As mensagens de commit devem ser escritas **SEMPRE em inglês**.
- **Branch**: A branch DEVE ser criada/puxada **SEMPRE a partir da branch `main`**. O nome deve ser sempre em **inglês**, com underscore (`_`).
  **Regra rígida:** A parte correspondente ao nome da task deve conter **no máximo 3 palavras**.
  `feat/dev_<clickup_id>_<nome_da_task_em_ingles_max_3_palavras>`
- **Título do MR**: Deve conter o tipo (feat/fix/chore) e o nome literal do card envolto em colchetes `[]`.
  Formato: `[<ENV>] feat/fix/chore: [<Nome literal do card do clickup (title)>]`

## 4. Orquestração de Ambientes via GitLab MCP
- **OBRIGATÓRIO**: Utilize EXCLUSIVAMENTE as ferramentas do **GitLab MCP** (`create_merge_request`, `update_merge_request`) para abrir e configurar os Merge Requests. NUNCA tente usar CLI (`glab`) ou Git push options.
- **Revisor (Reviewer)**: Você deve sempre definir ou associar o revisor (nome escolhido pelo usuário) via parâmetro obrigatório no GitLab MCP. Caso a API do MCP falhe em aceitar o parâmetro, use como último recurso a Quick Action `/reviewer @revisor_escolhido` na descrição (body) do MR.

Abra **APENAS 1 MR**, direcionado EXCLUSIVAMENTE para o ambiente DEV:
1. **Ambiente DEV**:
   - Título: `[DEV] feat/fix/chore: ...`
   - Label nativa: `DEV`
   - **Target Branch**: **`dev`** (ou a branch de desenvolvimento padrão).

**Regra de Ouro do Release Flow**: A branch da nova feature/fix DEVE ser sempre criada a partir da `main`, mas o target do Merge Request deve ser APENAS a branch `dev`. Não abra MR para a `main` ou `PRD` nesta etapa inicial.

## 5. Preenchimento do Template
- **ATENÇÃO:** Cada repositório possui o seu próprio template padrão de MR (geralmente em `.gitlab/merge_request_templates/`, `PULL_REQUEST_TEMPLATE.md` ou na documentação local).
- Antes de preencher a descrição, busque ativamente o template padrão do repositório em que você está operando.
- Preencha o corpo da descrição do MR utilizando os campos desse template correto do projeto, inserindo os dados coletados de forma inteligente (marcando checkboxes do tipo de mudança correspondente, inserindo o link da evidência e listando o ClickUp/Figma na seção de links úteis, se existirem essas seções no template local).

## 6. Arquivos Ignorados no Commit
- **ATENÇÃO**: NUNCA commite arquivos de configuração e contexto de IA no repositório.
- Certifique-se de ignorar ou remover (`git rm --cached`) arquivos/diretórios como: `.agents/`, `.github/`, `AGENTS.md`, `skills-lock.json`, e scripts auxiliares (ex: `run_flow.sh`).
