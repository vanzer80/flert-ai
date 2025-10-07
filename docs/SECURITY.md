# 📋 Documentação de Segurança - PROMPT H

## 🛡️ Visão Geral de Segurança

Este documento descreve as medidas de segurança implementadas no sistema de grounding v2 para garantir operação segura em produção.

## 🔐 Medidas de Segurança Implementadas

### ✅ 1. Configuração de Ambiente Seguro
```typescript
// ✅ Ambiente - variáveis não hardcoded
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key
OPENAI_API_KEY=your-openai-key
VISION_API_KEY=your-vision-key
RATE_LIMIT_REDIS_URL=your-redis-url
```

**Configuração Flutter Web:**
```bash
# ✅ Build com variáveis de ambiente
flutter build web --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### ✅ 2. Rate Limiting por IP/Usuário
```typescript
// ✅ Controle de taxa implementado
const rateLimitCheck = await RateLimiter.checkRateLimit(userId, 'user');
if (!rateLimitCheck.allowed) {
  return { allowed: false, error: 'Limite de uso excedido' };
}
```

**Limites Configurados:**
- **Por minuto:** 10 requisições
- **Por hora:** 100 requisições
- **Reset automático** baseado em janela temporal

### ✅ 3. Validação de Entrada
```typescript
// ✅ Sanitização e validação
const validation = InputValidator.validateRequest(body);
if (!validation.valid) {
  return { allowed: false, error: validation.errors.join('; ') };
}
```

**Validações Implementadas:**
- ✅ Campos obrigatórios (`userId`, `imageData` ou `imageUrl`)
- ✅ Tipos de dados corretos
- ✅ Tamanho de imagem limitado (máximo 10MB)
- ✅ URLs válidas para imagens externas
- ✅ Sanitização de texto (remoção de caracteres especiais)

### ✅ 4. Row Level Security (RLS) - Supabase
```sql
-- ✅ RLS habilitado em tabelas críticas
ALTER TABLE conversation_context ENABLE ROW LEVEL SECURITY;
ALTER TABLE generation_logs ENABLE ROW LEVEL SECURITY;

-- ✅ Políticas de acesso
CREATE POLICY "Users can only access their own conversations"
ON conversation_context FOR ALL USING (auth.uid() = user_id);
```

### ✅ 5. Logs de Segurança
```typescript
// ✅ Registro de eventos de segurança
SecurityLogger.log('warn', 'RATE_LIMIT_EXCEEDED', {
  userId,
  ip,
  resetTime: rateLimitCheck.resetTime
});
```

**Eventos Monitorados:**
- ✅ Tentativas de rate limit excedido
- ✅ Requisições de origens não autorizadas
- ✅ Entradas inválidas ou maliciosas
- ✅ Erros internos do sistema

## 🔍 Guardrails de Produção

### ✅ 1. Rejeição de Saída sem Âncora
```typescript
// ✅ Validação obrigatória de âncoras
if (anchors.length < MIN_ANCHOR_COUNT) {
  return {
    allowed: false,
    reason: 'GUARDRAIL_ANCHOR_MISSING',
    fallback: 'Que foto interessante! Me conte mais sobre você.'
  };
}
```

### ✅ 2. Controle de Regeneração
```typescript
// ✅ Limitação de regenerações
if (regenerationCount >= MAX_REGENERATIONS) {
  return {
    allowed: false,
    reason: 'GUARDRAIL_MAX_REGENERATIONS',
    fallback: 'Desculpe, já gerei o máximo de sugestões alternativas.'
  };
}
```

### ✅ 3. Controle de Repetição
```typescript
// ✅ Algoritmo Jaccard para detectar repetição
if (repetitionRate > MAX_REPETITION_RATE) {
  return {
    allowed: false,
    reason: 'GUARDRAIL_HIGH_REPETITION',
    fallback: 'Que tal tentarmos uma abordagem diferente?'
  };
}
```

### ✅ 4. Limitação de Comprimento
```typescript
// ✅ Controle de tamanho de resposta
if (suggestion.length > MAX_SUGGESTION_LENGTH) {
  return {
    allowed: false,
    reason: 'GUARDRAIL_SUGGESTION_TOO_LONG',
    fallback: suggestion.substring(0, 497) + '...'
  };
}
```

## 📊 Observabilidade e Monitoramento

### ✅ 1. Logs Estruturados por Etapa
```typescript
// ✅ Métricas detalhadas por geração
observability.log('vision_completed', {
  confidence: visionContext.confidence_overall,
  anchorCount: visionContext.objects?.length || 0
});

observability.log('anchors_computed', {
  anchorCount: anchors.length,
  topAnchors: anchors.slice(0, 3).map(a => a.token)
});
```

**Métricas Coletadas:**
- ✅ `visionProcessingMs` - Tempo de processamento de visão
- ✅ `anchorComputationMs` - Tempo de computação de âncoras
- ✅ `generationMs` - Tempo de geração de sugestão
- ✅ `totalLatencyMs` - Latência total
- ✅ `anchorCount` - Número total de âncoras
- ✅ `anchorsUsed` - Âncoras efetivamente usadas
- ✅ `repetitionRate` - Taxa de repetição calculada
- ✅ `suggestionLength` - Comprimento da sugestão

### ✅ 2. Painel de Métricas Diárias
```sql
-- ✅ Query para painel de métricas
SELECT
  DATE_TRUNC('day', created_at) as date,
  COUNT(*) as total_requests,
  AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000) as avg_latency_ms,
  SUM(CASE WHEN success = true THEN 1 ELSE 0 END)::float / COUNT(*) as success_rate
FROM generation_metrics
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE_TRUNC('day', created_at);
```

### ✅ 3. Monitoramento de Guardrails
```sql
-- ✅ Análise de ativações de guardrails
SELECT
  guardrail_reason,
  COUNT(*) as count,
  AVG(avg_fallback_latency_ms) as avg_fallback_latency_ms
FROM guardrail_metrics
WHERE created_at >= CURRENT_DATE - INTERVAL '1 day'
GROUP BY guardrail_reason;
```

## 🚨 Procedimentos de Segurança

### ✅ 1. Resposta a Incidentes de Segurança

**Rate Limit Excedido:**
```typescript
// ✅ Resposta automática
{
  "error": "Limite de uso excedido",
  "retryAfter": 3600, // Segundos até reset
  "requestId": "uuid"
}
```

**Entrada Inválida:**
```typescript
// ✅ Sanitização automática
{
  "error": "Dados de entrada inválidos",
  "details": ["userId é obrigatório", "imageData deve ser string"]
}
```

### ✅ 2. Monitoramento Contínuo

**Métricas a Monitorar:**
- ✅ Taxa de sucesso de gerações (>95%)
- ✅ Latência média (<1000ms)
- ✅ Ativações de guardrails (<5%)
- ✅ Erros por tipo e frequência

**Alertas Configurados:**
- ✅ Latência > 5s (P95)
- ✅ Taxa de erro > 10%
- ✅ Guardrails ativados > 50 vezes/hora
- ✅ Rate limits excedidos > 100/hora

## 🔧 Configuração para Produção

### ✅ 1. Variáveis de Ambiente Obrigatórias
```bash
# ✅ Produção - variáveis reais
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
OPENAI_API_KEY=sk-your-openai-key
RATE_LIMIT_REDIS_URL=redis://your-redis-instance
ALLOWED_ORIGINS=https://your-domain.com,https://app.your-domain.com
```

### ✅ 2. Configuração Flutter Web
```bash
# ✅ Build seguro
flutter build web \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --release \
  --web-renderer html
```

### ✅ 3. Deploy Edge Functions
```bash
# ✅ Deploy com configuração de produção
supabase functions deploy analyze-conversation \
  --project-ref your-project-ref \
  --env-file .env.production
```

## 📈 Métricas de Segurança

### ✅ Indicadores de Saúde
- **Uptime:** >99.9%
- **MTTR (Mean Time To Recovery):** <30 minutos
- **Taxa de falsos positivos:** <1%
- **Cobertura de logs:** 100% de requisições

### ✅ SLOs (Service Level Objectives)
- **Disponibilidade:** 99.9% mensal
- **Latência P95:** <2000ms
- **Taxa de erro:** <1%
- **Taxa de guardrails:** <5%

## 🚀 Validações Implementadas

### ✅ Simulação de Limite Atingido
```bash
# ✅ Teste de rate limit
curl -X POST https://your-edge-function.supabase.co/functions/v1/analyze-conversation \
  -H "Content-Type: application/json" \
  -d '{"userId": "test", "imageData": "base64..."}'
# Retorna 429 após 10ª requisição no mesmo minuto
```

### ✅ Logs com Métricas por Geração
```json
{
  "timestamp": "2025-01-05T20:25:00Z",
  "level": "info",
  "event": "generation",
  "requestId": "uuid",
  "userId": "user123",
  "visionProcessingMs": 150,
  "anchorComputationMs": 25,
  "generationMs": 300,
  "totalLatencyMs": 475,
  "anchorCount": 4,
  "anchorsUsed": 4,
  "repetitionRate": 0.0,
  "success": true
}
```

## 🔒 Checklist de Segurança para Produção

- ✅ [ ] Variáveis de ambiente configuradas
- ✅ [ ] Rate limiting habilitado e testado
- ✅ [ ] RLS habilitado em todas as tabelas
- ✅ [ ] Logs estruturados configurados
- ✅ [ ] Guardrails validados com testes
- ✅ [ ] Monitoramento de métricas ativo
- ✅ [ ] Procedimentos de incidente documentados
- ✅ [ ] Backups de configuração seguros

---
*Documento atualizado automaticamente em: ${new Date().toISOString()}*
