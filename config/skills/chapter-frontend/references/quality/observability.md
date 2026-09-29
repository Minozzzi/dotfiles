---
title: Observabilidade Frontend
description: Define o uso de Datadog RUM, tracing e dashboards para monitoramento das aplicações frontend Aarin.
status: draft
version: 1.0.0
---

# Observabilidade Frontend

## Purpose

Ter visibilidade real da experiência do usuário, capturar erros de frontend e correlacionar com traces de backend de forma padronizada.

## Scope

### Dentro do escopo

- Inicialização do Datadog RUM.
- Configuração de `allowedTracingUrls`.
- Envio de erros e eventos customizados.
- Uso de Session Replay.
- Dashboards de monitoramento.

### Fora do escopo

- Analytics de negócio (ver `../platform/analytics.md`).
- Logging de backend.

## References

- `docs/adrs/adr-003-datadog.md`
- Notion: "Rastreabilidade com Datadog"
- Notion: "Dashboards de Monitoramento Frontend"
- Documentação Datadog RUM

## Must

- Todo projeto frontend configura Datadog RUM.
- `applicationId`, `clientToken`, `service`, `env` e `version` injetados via variáveis de ambiente.
- `allowedTracingUrls` configurado com origens internas para correlacionar com APM.
- Session replay habilitado com taxa definida (padrão: 20%).
- `trackUserInteractions`, `trackResources`, `trackLongTasks` habilitados.
- Erros de API e exceções não capturadas enviados ao Datadog.
- Cada app possui dashboards de saúde no Datadog.

## Must not

- Não enviar dados sensíveis (CNPJ, senha, token) no RUM ou replay.
- Não deixar de configurar `allowedTracingUrls` para APIs internas.
- Não inicializar RUM sem identificar corretamente `service` e `env`.

## Default RUM Configuration

```typescript
import { datadogRum } from '@datadog/browser-rum'

datadogRum.init({
  applicationId: process.env.NEXT_PUBLIC_DD_APPLICATION_ID,
  clientToken: process.env.NEXT_PUBLIC_DD_CLIENT_TOKEN,
  site: 'datadoghq.com',
  service: process.env.NEXT_PUBLIC_DD_SERVICE,
  env: process.env.NODE_ENV,
  version: process.env.NEXT_PUBLIC_APP_VERSION ?? pkg.version,
  sessionSampleRate: 100,
  sessionReplaySampleRate: 20,
  trackUserInteractions: true,
  trackResources: true,
  trackLongTasks: true,
  allowedTracingUrls: [
    /https:\/\/[^\/]+\.aarin\.com\.br/,
  ],
})
```

## Done when

- [ ] RUM configurado em 100% das aplicações frontend.
- [ ] Tracing ativo para todas as APIs internas.
- [ ] Dashboards de RUM e APM correlacionados.
- [ ] Erros críticos geram alertas no Datadog.
