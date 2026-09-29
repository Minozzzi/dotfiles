---
title: Segurança Frontend
description: Define práticas obrigatórias de segurança para aplicações frontend Aarin.
status: draft
version: 1.0.0
---

# Segurança Frontend

## Purpose

Proteger usuários e aplicações contra vulnerabilidades comuns de frontend, como XSS, vazamento de dados sensíveis, armazenamento inseguro e injeção de conteúdo.

## Scope

### Dentro do escopo

- Content Security Policy (CSP).
- Tratamento de tokens e sessão.
- Dados sensíveis (CPF, CNPJ, cartão, senha).
- Uso seguro de `dangerouslySetInnerHTML`.
- Proteção contra inline scripts.
- Logs e secrets.

### Fora do escopo

- Segurança de APIs backend.
- Infraestrutura de rede/firewall.

## References

- Notion: "Content Security Policy - CSP"
- Notion: "Acesso indevido à conta Bradesco do cliente..."
- `docs/guias/checklist-code-review.md` (seção Segurança)
- `SDD-ECOSSISTEMA-FRONTEND.md` (seção 8.4 — Segurança)

## Must

- CSP configurada em todas as aplicações Next.js/Vite publicadas.
- Scripts e conexões permitidas apenas para origens confiáveis.
- Tokens nunca armazenados em `localStorage` sem criptografia.
- Dados sensíveis mascarados em inputs e logs.
- Componentes interativos que lidam com dados sensíveis sem `data-testid` expondo valor.
- Nenhum uso de `dangerouslySetInnerHTML` sem justificativa documentada e aprovação de segurança.
- Nenhum `console.log` de dados sensíveis em produção.
- Nenhum secret ou URL hardcoded no código.
- Error boundaries não exibem stack traces em produção.

## Must not

- Não usar inline scripts não seguros.
- Não armazenar credenciais, tokens ou dados pessoais em localStorage sem criptografia.
- Não logar CPF, CNPJ, senha ou token no console/RUM.
- Não confiar em conteúdo dinâmico sem sanitização.
- Não ignorar violações reportadas de CSP.

## CSP Pilots

Projetos já com CSP configurada:

- Portal de Vendas - Consórcio
- DRC - Plataforma / Portal
- Interface Web / Backoffice
- Laas - Portal do Consultor / KYC

## Done when

- [ ] CSP configurada em 100% das aplicações frontend.
- [ ] 0 ocorrências de `dangerouslySetInnerHTML` sem aprovação.
- [ ] Tokens e dados sensíveis auditados.
- [ ] SonarQube sem vulnerabilidades blockers/criticas.
