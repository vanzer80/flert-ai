// src/observability/observability.ts
// Sistema de observabilidade e métricas - PROMPT H

/**
 * Interface para métricas estruturadas de geração
 */
export interface GenerationMetrics {
  requestId: string;
  timestamp: number;
  userId: string;
  ip: string;

  // Tempos por etapa (ms)
  visionProcessingMs: number;
  anchorComputationMs: number;
  generationMs: number;
  totalLatencyMs: number;

  // Métricas de qualidade
  anchorCount: number;
  anchorsUsed: number;
  repetitionRate: number;
  suggestionLength: number;

  // Status e resultados
  success: boolean;
  guardrailTriggered: boolean;
  guardrailReason?: string;
  errorType?: string;

  // Recursos utilizados
  inputImageSize: number;
  outputTokens: number;
}

/**
 * Classe de observabilidade para produção
 */
export class ObservabilityManager {
  private static metrics: GenerationMetrics[] = [];
  private static readonly MAX_METRICS = 10000;

  /**
   * Registra métricas de uma geração
   */
  static recordGeneration(metrics: GenerationMetrics): void {
    this.metrics.push(metrics);

    // Manter apenas métricas recentes em memória
    if (this.metrics.length > this.MAX_METRICS) {
      this.metrics = this.metrics.slice(-this.MAX_METRICS);
    }

    // Log estruturado
    this.logStructured('generation', metrics);

    // Em produção, enviar para serviço de métricas (Datadog, etc.)
    console.log('📊 Métricas registradas:', {
      requestId: metrics.requestId,
      latency: metrics.totalLatencyMs,
      success: metrics.success,
      anchors: `${metrics.anchorsUsed}/${metrics.anchorCount}`,
      repetition: metrics.repetitionRate.toFixed(3)
    });
  }

  /**
   * Obtém métricas recentes
   */
  static getRecentMetrics(hours: number = 24): GenerationMetrics[] {
    const cutoff = Date.now() - (hours * 60 * 60 * 1000);
    return this.metrics.filter(m => m.timestamp > cutoff);
  }

  /**
   * Calcula estatísticas agregadas
   */
  static getAggregatedStats(hours: number = 24): {
    totalRequests: number;
    successRate: number;
    avgLatency: number;
    p95Latency: number;
    avgAnchorCoverage: number;
    avgRepetitionRate: number;
    guardrailTriggerRate: number;
  } {
    const recent = this.getRecentMetrics(hours);

    if (recent.length === 0) {
      return {
        totalRequests: 0,
        successRate: 0,
        avgLatency: 0,
        p95Latency: 0,
        avgAnchorCoverage: 0,
        avgRepetitionRate: 0,
        guardrailTriggerRate: 0
      };
    }

    const successful = recent.filter(m => m.success).length;
    const latencies = recent.map(m => m.totalLatencyMs).sort((a, b) => a - b);
    const p95Index = Math.floor(latencies.length * 0.95);

    return {
      totalRequests: recent.length,
      successRate: successful / recent.length,
      avgLatency: recent.reduce((sum, m) => sum + m.totalLatencyMs, 0) / recent.length,
      p95Latency: latencies[p95Index] || 0,
      avgAnchorCoverage: recent.reduce((sum, m) => sum + (m.anchorsUsed / m.anchorCount), 0) / recent.length,
      avgRepetitionRate: recent.reduce((sum, m) => sum + m.repetitionRate, 0) / recent.length,
      guardrailTriggerRate: recent.filter(m => m.guardrailTriggered).length / recent.length
    };
  }

  /**
   * Log estruturado para produção
   */
  private static logStructured(event: string, data: any): void {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level: 'info',
      event,
      ...data
    };

    // Em produção, enviar para serviço de logging estruturado
    console.log(`📋 [${event.toUpperCase()}]`, JSON.stringify(logEntry, null, 2));
  }

  /**
   * Registra início de processamento
   */
  static startRequest(requestId: string, userId: string, ip: string): {
    requestId: string;
    startTime: number;
    log: (event: string, data: any) => void;
  } {
    const startTime = Date.now();

    return {
      requestId,
      startTime,
      log: (event: string, data: any) => {
        this.logStructured(event, {
          requestId,
          userId,
          ip,
          duration: Date.now() - startTime,
          ...data
        });
      }
    };
  }

  /**
   * Registra evento de guardrail
   */
  static recordGuardrail(
    requestId: string,
    userId: string,
    triggered: boolean,
    reason?: string,
    metadata?: any
  ): void {
    this.logStructured('guardrail', {
      requestId,
      userId,
      triggered,
      reason,
      metadata
    });
  }

  /**
   * Registra erro de sistema
   */
  static recordError(
    requestId: string,
    userId: string,
    errorType: string,
    error: Error,
    context?: any
  ): void {
    this.logStructured('error', {
      requestId,
      userId,
      errorType,
      message: error.message,
      stack: error.stack,
      context
    });
  }

  /**
   * Gera relatório diário para painel
   */
  static generateDailyReport(): {
    date: string;
    stats: ReturnType<typeof this.getAggregatedStats>;
    topErrors: Array<{ type: string; count: number }>;
    performanceByHour: Array<{ hour: number; avgLatency: number; requests: number }>;
  } {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todaysMetrics = this.metrics.filter(m =>
      m.timestamp >= today.getTime()
    );

    // Estatísticas por hora
    const hourlyStats = Array.from({ length: 24 }, (_, hour) => {
      const hourMetrics = todaysMetrics.filter(m => {
        const metricDate = new Date(m.timestamp);
        return metricDate.getHours() === hour;
      });

      return {
        hour,
        avgLatency: hourMetrics.length > 0 ?
          hourMetrics.reduce((sum, m) => sum + m.totalLatencyMs, 0) / hourMetrics.length : 0,
        requests: hourMetrics.length
      };
    });

    // Erros mais comuns
    const errorCounts: Record<string, number> = {};
    todaysMetrics.forEach(m => {
      if (m.errorType) {
        errorCounts[m.errorType] = (errorCounts[m.errorType] || 0) + 1;
      }
    });

    const topErrors = Object.entries(errorCounts)
      .map(([type, count]) => ({ type, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    return {
      date: today.toISOString().split('T')[0],
      stats: this.getAggregatedStats(24),
      topErrors,
      performanceByHour: hourlyStats
    };
  }
}

/**
 * Middleware de observabilidade para Edge Function
 */
export function applyObservabilityMiddleware(
  requestId: string,
  userId: string,
  ip: string
): {
  log: (event: string, data: any) => void;
  recordMetrics: (metrics: Partial<GenerationMetrics>) => void;
  end: () => GenerationMetrics | null;
} {
  const startTime = Date.now();
  let finalMetrics: Partial<GenerationMetrics> | null = null;

  const logger = ObservabilityManager.startRequest(requestId, userId, ip);

  return {
    log: logger.log,

    recordMetrics: (metrics: Partial<GenerationMetrics>) => {
      finalMetrics = {
        ...finalMetrics,
        ...metrics,
        requestId,
        timestamp: Date.now(),
        userId,
        ip
      };
    },

    end: () => {
      if (finalMetrics) {
        const completeMetrics: GenerationMetrics = {
          requestId,
          timestamp: Date.now(),
          userId,
          ip,
          visionProcessingMs: 0,
          anchorComputationMs: 0,
          generationMs: 0,
          totalLatencyMs: Date.now() - startTime,
          anchorCount: 0,
          anchorsUsed: 0,
          repetitionRate: 0,
          suggestionLength: 0,
          success: true,
          guardrailTriggered: false,
          ...finalMetrics
        };

        ObservabilityManager.recordGeneration(completeMetrics);
        return completeMetrics;
      }
      return null;
    }
  };
}

/**
 * Query SQL para painel de métricas diárias
 */
export const DAILY_METRICS_QUERY = `
-- Métricas diárias agregadas
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

-- Performance por hora (últimas 24h)
SELECT
  EXTRACT(hour FROM created_at) as hour,
  COUNT(*) as requests,
  AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000) as avg_latency_ms
FROM generation_metrics
WHERE created_at >= NOW() - INTERVAL '24 hours'
GROUP BY EXTRACT(hour FROM created_at)
ORDER BY hour;

-- Top erros por tipo
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
`;

/**
 * Query SQL para métricas de guardrails
 */
export const GUARDRAIL_METRICS_QUERY = `
-- Estatísticas de guardrails por tipo
SELECT
  guardrail_reason,
  COUNT(*) as count,
  SUM(CASE WHEN success = true THEN 1 ELSE 0 END) as successful_fallbacks,
  AVG(EXTRACT(EPOCH FROM (ended_at - started_at)) * 1000) as avg_fallback_latency_ms
FROM generation_metrics
WHERE guardrail_triggered = true
  AND created_at >= CURRENT_DATE - INTERVAL '1 day'
GROUP BY guardrail_reason
ORDER BY count DESC;

-- Usuários com mais ativações de guardrail
SELECT
  user_id,
  COUNT(*) as guardrail_activations,
  ARRAY_AGG(DISTINCT guardrail_reason) as reasons
FROM generation_metrics
WHERE guardrail_triggered = true
  AND created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY user_id
HAVING COUNT(*) > 3
ORDER BY guardrail_activations DESC;
`;
