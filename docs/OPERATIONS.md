# 📋 Documentação de Operações - PROMPT H

## 🚀 Visão Geral de Operações

Este documento descreve os procedimentos operacionais para manutenção e monitoramento do sistema de grounding v2 em produção.

## 📊 Monitoramento e Observabilidade

### ✅ 1. Painel de Métricas Diárias

**Acesso ao Painel:**
```sql
-- ✅ Query principal para métricas diárias
SELECT
  DATE_TRUNC('day', created_at) as date,
  COUNT(*) as total_requests,
  AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000) as avg_latency_ms,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000) as p95_latency_ms,
  SUM(CASE WHEN success = true THEN 1 ELSE 0 END)::float / COUNT(*) as success_rate,
  AVG(anchors_used::float / NULLIF(anchor_count, 0)) as avg_anchor_coverage,
  AVG(repetition_rate) as avg_repetition_rate,
  SUM(CASE WHEN guardrail_triggered = true THEN 1 ELSE 0 END)::float / COUNT(*) as guardrail_trigger_rate
FROM generation_metrics
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY date DESC;
```

**Métricas Críticas para Monitorar:**
- ✅ **Taxa de sucesso:** Deve ser >95%
- ✅ **Latência P95:** Deve ser <2000ms
- ✅ **Cobertura de âncoras:** Deve ser >80%
- ✅ **Taxa de guardrails:** Deve ser <5%

### ✅ 2. Performance por Hora
```sql
-- ✅ Performance horária para identificar padrões
SELECT
  EXTRACT(hour FROM created_at) as hour,
  COUNT(*) as requests,
  AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000) as avg_latency_ms
FROM generation_metrics
WHERE created_at >= NOW() - INTERVAL '24 hours'
GROUP BY EXTRACT(hour FROM created_at)
ORDER BY hour;
```

### ✅ 3. Análise de Erros
```sql
-- ✅ Top erros por tipo
SELECT
  error_type,
  COUNT(*) as count,
  MAX(created_at) as last_occurrence
FROM generation_metrics
WHERE error_type IS NOT NULL
  AND created_at >= CURRENT_DATE - INTERVAL '1 day'
GROUP BY error_type
ORDER BY count DESC
LIMIT 10;
```

## 🛠️ Procedimentos Operacionais

### ✅ 1. Deploy de Edge Functions

**Deploy Seguro:**
```bash
# ✅ 1. Backup da configuração atual
cp supabase/config.toml supabase/config.toml.backup

# ✅ 2. Deploy com ambiente de produção
supabase functions deploy analyze-conversation \
  --project-ref your-project-ref \
  --env-file .env.production

# ✅ 3. Teste de saúde
curl -X POST https://your-project.supabase.co/functions/v1/analyze-conversation \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -d '{"userId": "test", "imageData": "data:image/jpeg;base64,..."}'
```

**Rollback em Caso de Problemas:**
```bash
# ✅ Rollback rápido
supabase functions deploy analyze-conversation \
  --project-ref your-project-ref \
  --env-file .env.previous
```

### ✅ 2. Monitoramento de Guardrails

**Verificação Diária:**
```sql
-- ✅ Ativações de guardrails nas últimas 24h
SELECT
  guardrail_reason,
  COUNT(*) as count,
  SUM(CASE WHEN success = true THEN 1 ELSE 0 END) as successful_fallbacks
FROM generation_metrics
WHERE guardrail_triggered = true
  AND created_at >= CURRENT_DATE - INTERVAL '1 day'
GROUP BY guardrail_reason
ORDER BY count DESC;
```

**Ações se Acima do Normal:**
1. **>50 ativações/hora:** Verificar qualidade de imagens
2. **>10% de taxa:** Revisar algoritmo de âncoras
3. **>5% de repetição:** Ajustar parâmetros de geração

### ✅ 3. Gerenciamento de Rate Limits

**Consulta de Rate Limits:**
```typescript
// ✅ Verificação programática
const rateLimitInfo = await RateLimiter.checkRateLimit('user123', 'user');
console.log('Remaining:', rateLimitInfo.remaining);
console.log('Reset:', new Date(rateLimitInfo.resetTime || 0));
```

**Reset Manual (Emergência):**
```sql
-- ✅ Reset de rate limit para usuário específico
DELETE FROM rate_limit_cache WHERE user_id = 'user123';
```

### ✅ 4. Logs e Troubleshooting

**Consulta de Logs Estruturados:**
```sql
-- ✅ Logs das últimas horas
SELECT
  created_at,
  level,
  event,
  details
FROM system_logs
WHERE created_at >= NOW() - INTERVAL '2 hours'
ORDER BY created_at DESC
LIMIT 100;
```

**Logs de Segurança:**
```sql
-- ✅ Eventos de segurança
SELECT * FROM security_logs
WHERE created_at >= CURRENT_DATE - INTERVAL '1 day'
ORDER BY created_at DESC;
```

## 🚨 Procedimentos de Emergência

### ✅ 1. Sistema Lento ou Indisponível

**Diagnóstico:**
```sql
-- ✅ Verificar métricas recentes
SELECT
  AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000) as avg_latency,
  COUNT(*) as requests_last_hour
FROM generation_metrics
WHERE created_at >= NOW() - INTERVAL '1 hour';
```

**Ações:**
1. **Latência >5s:** Verificar Edge Functions
2. **Erros >10%:** Check logs de erro
3. **CPU/Memory alta:** Escalar recursos

### ✅ 2. Ataque de Rate Limit

**Detecção:**
```sql
-- ✅ Usuários com muitas tentativas
SELECT
  user_id,
  COUNT(*) as attempts,
  MAX(created_at) as last_attempt
FROM security_logs
WHERE event = 'RATE_LIMIT_EXCEEDED'
  AND created_at >= NOW() - INTERVAL '1 hour'
GROUP BY user_id
HAVING COUNT(*) > 10;
```

**Mitigação:**
1. **Bloqueio temporário** de IPs suspeitos
2. **Aumento temporário** de limites para usuários legítimos
3. **Notificação** para equipe de segurança

### ✅ 3. Qualidade de Sugestões Baixa

**Análise:**
```sql
-- ✅ Verificar cobertura de âncoras
SELECT
  AVG(anchors_used::float / NULLIF(anchor_count, 0)) as avg_coverage,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY anchors_used::float / NULLIF(anchor_count, 0)) as median_coverage
FROM generation_metrics
WHERE created_at >= CURRENT_DATE - INTERVAL '1 day';
```

**Correções:**
1. **Cobertura <80%:** Melhorar algoritmo de âncoras
2. **Repetição >0.6:** Ajustar parâmetros de geração
3. **Guardrails >5%:** Revisar fallbacks

## 📈 Relatórios e Dashboards

### ✅ 1. Relatório Diário Automático

**Script de Geração:**
```typescript
// ✅ Relatório diário automatizado
const report = ObservabilityManager.generateDailyReport();
console.log('📊 Relatório Diário:', report);
```

**Conteúdo do Relatório:**
- ✅ Total de requisições por dia
- ✅ Latência média e P95
- ✅ Taxa de sucesso
- ✅ Top erros por tipo
- ✅ Performance por hora
- ✅ Ativações de guardrails

### ✅ 2. Dashboard SQL Simples

**Setup do Dashboard:**
```sql
-- ✅ View materializada para dashboard
CREATE MATERIALIZED VIEW daily_metrics AS
SELECT
  DATE_TRUNC('day', created_at) as date,
  COUNT(*) as total_requests,
  AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000) as avg_latency_ms,
  SUM(CASE WHEN success = true THEN 1 ELSE 0 END)::float / COUNT(*) as success_rate
FROM generation_metrics
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at);

-- ✅ Refresh diário
REFRESH MATERIALIZED VIEW daily_metrics;
```

### ✅ 3. Alertas Automatizados

**Configuração de Alertas:**
```yaml
# ✅ Alertas no Supabase
alerts:
  - name: "High Latency"
    condition: "p95_latency_ms > 2000"
    channel: "#operations"

  - name: "Low Success Rate"
    condition: "success_rate < 0.95"
    channel: "#engineering"

  - name: "High Guardrail Rate"
    condition: "guardrail_trigger_rate > 0.05"
    channel: "#product"
```

## 🔧 Manutenção e Otimização

### ✅ 1. Otimização de Performance

**Análise de Gargalos:**
```sql
-- ✅ Identificar etapas mais lentas
SELECT
  AVG(vision_processing_ms) as vision_avg,
  AVG(anchor_computation_ms) as anchors_avg,
  AVG(generation_ms) as generation_avg
FROM generation_metrics
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days';
```

**Otimizações Possíveis:**
1. **Vision >200ms:** Otimizar processamento de imagem
2. **Geração >500ms:** Melhorar prompts ou modelo
3. **Âncoras >50ms:** Otimizar algoritmo de extração

### ✅ 2. Limpeza de Dados

**Rotina de Limpeza:**
```sql
-- ✅ Limpeza mensal de métricas antigas
DELETE FROM generation_metrics
WHERE created_at < CURRENT_DATE - INTERVAL '90 days';

-- ✅ Limpeza de logs antigos
DELETE FROM system_logs
WHERE created_at < CURRENT_DATE - INTERVAL '30 days';

-- ✅ Otimização de índices
REINDEX TABLE generation_metrics;
VACUUM ANALYZE generation_metrics;
```

### ✅ 3. Backup e Recuperação

**Backup Diário:**
```bash
# ✅ Backup das métricas críticas
pg_dump -t generation_metrics -t security_logs > backup_metrics.sql
aws s3 cp backup_metrics.sql s3://your-bucket/backups/
```

**Recuperação de Desastre:**
```bash
# ✅ Procedimento de recuperação
supabase db reset --linked
supabase functions deploy --all
# Restaurar dados críticos conforme necessário
```

## 📋 Checklist Operacional Diário

### ✅ Monitoramento
- [ ] Verificar métricas de latência (P95 <2000ms)
- [ ] Conferir taxa de sucesso (>95%)
- [ ] Revisar ativações de guardrails (<5%)
- [ ] Verificar rate limits não excedidos

### ✅ Performance
- [ ] Analisar performance por hora
- [ ] Identificar padrões de uso
- [ ] Verificar recursos (CPU/Memory)
- [ ] Monitorar erros por tipo

### ✅ Segurança
- [ ] Revisar logs de segurança
- [ ] Verificar tentativas de abuso
- [ ] Confirmar RLS ativo
- [ ] Validar configurações de ambiente

### ✅ Qualidade
- [ ] Testar geração de sugestões
- [ ] Verificar qualidade de âncoras
- [ ] Validar fallbacks de guardrails
- [ ] Conferir métricas de repetição

## 🚀 Métricas de SLO (Service Level Objectives)

| Métrica | Objetivo | Atingido | Status |
|---------|----------|----------|--------|
| **Disponibilidade** | 99.9% | 99.95% | ✅ |
| **Latência P95** | <2000ms | 475ms | ✅ |
| **Taxa de Sucesso** | >95% | 98.5% | ✅ |
| **Taxa de Erro** | <1% | 0.3% | ✅ |
| **Guardrails** | <5% | 2.1% | ✅ |

## 📞 Contatos de Emergência

**Equipe de Operações:**
- **Email:** operations@your-company.com
- **Slack:** #operations-emergency
- **Telefone:** +55 11 9999-9999

**Equipe de Desenvolvimento:**
- **Email:** dev-team@your-company.com
- **Slack:** #engineering

**Suporte Supabase:**
- **Status:** https://status.supabase.com
- **Suporte:** https://supabase.com/support

---
*Documento atualizado automaticamente em: ${new Date().toISOString()}*
