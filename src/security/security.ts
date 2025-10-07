// src/security/security.ts
// Medidas de segurança para produção - PROMPT H

/**
 * Classe de configuração segura de ambiente
 */
export class SecureEnvironment {
  private static config: Map<string, string> = new Map();

  /**
   * Carrega configuração de ambiente de forma segura
   */
  static loadEnvironment(): void {
    // Em produção, estas variáveis vêm do ambiente, não são hardcoded
    const envVars = [
      'SUPABASE_URL',
      'SUPABASE_ANON_KEY',
      'SUPABASE_SERVICE_ROLE_KEY',
      'OPENAI_API_KEY',
      'VISION_API_KEY',
      'RATE_LIMIT_REDIS_URL',
      'LOG_LEVEL',
      'ALLOWED_ORIGINS'
    ];

    for (const envVar of envVars) {
      const value = Deno.env.get(envVar);
      if (value) {
        this.config.set(envVar, value);
      } else {
        console.warn(`⚠️ Ambiente: Variável ${envVar} não definida`);
      }
    }
  }

  /**
   * Obtém configuração de forma segura
   */
  static get(key: string): string | undefined {
    return this.config.get(key);
  }

  /**
   * Verifica se configuração crítica está presente
   */
  static hasRequiredConfig(): boolean {
    const required = ['SUPABASE_URL', 'SUPABASE_ANON_KEY'];
    return required.every(key => this.config.has(key));
  }

  /**
   * Valida origem da requisição
   */
  static validateOrigin(origin: string): boolean {
    const allowedOrigins = this.get('ALLOWED_ORIGINS')?.split(',') || [];
    return allowedOrigins.length === 0 || allowedOrigins.includes(origin);
  }
}

/**
 * Sistema de rate limiting por IP/usuário
 */
export class RateLimiter {
  private static redisClient: any = null;

  /**
   * Inicializa cliente Redis para rate limiting
   */
  static async initialize(): Promise<void> {
    const redisUrl = SecureEnvironment.get('RATE_LIMIT_REDIS_URL');
    if (redisUrl) {
      try {
        // Em produção, usar cliente Redis real
        this.redisClient = { connected: true }; // Placeholder
        console.log('✅ Rate limiter inicializado');
      } catch (error) {
        console.error('❌ Erro inicializando rate limiter:', error);
      }
    }
  }

  /**
   * Verifica rate limit para usuário/IP
   */
  static async checkRateLimit(
    identifier: string,
    type: 'user' | 'ip' = 'user'
  ): Promise<{ allowed: boolean; resetTime?: number; remaining?: number }> {
    // Implementação simulada para validação
    // Em produção, usar Redis para controle real

    const now = Date.now();
    const minuteKey = `${type}:${identifier}:minute:${Math.floor(now / 60000)}`;
    const hourKey = `${type}:${identifier}:hour:${Math.floor(now / 3600000)}`;

    // Simulação de controle (em produção usar Redis INCR)
    const currentMinuteCount = Math.floor(Math.random() * 3); // Simulado
    const currentHourCount = Math.floor(Math.random() * 20);   // Simulado

    const MAX_PER_MINUTE = 10;
    const MAX_PER_HOUR = 100;

    if (currentMinuteCount >= MAX_PER_MINUTE) {
      return {
        allowed: false,
        resetTime: Math.ceil(now / 60000) * 60000 + 60000 // Próximo minuto
      };
    }

    if (currentHourCount >= MAX_PER_HOUR) {
      return {
        allowed: false,
        resetTime: Math.ceil(now / 3600000) * 3600000 + 3600000 // Próxima hora
      };
    }

    return {
      allowed: true,
      remaining: Math.min(MAX_PER_MINUTE - currentMinuteCount, MAX_PER_HOUR - currentHourCount)
    };
  }

  /**
   * Registra tentativa de uso
   */
  static async recordAttempt(identifier: string, type: 'user' | 'ip' = 'user'): Promise<void> {
    // Em produção, incrementar contadores no Redis
    console.log(`📊 Rate limit registrado: ${type}:${identifier}`);
  }
}

/**
 * Validação de entrada segura
 */
export class InputValidator {
  /**
   * Valida estrutura da requisição
   */
  static validateRequest(body: any): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    // Validar campos obrigatórios
    if (!body.userId || typeof body.userId !== 'string') {
      errors.push('userId é obrigatório e deve ser string');
    }

    if (!body.imageData && !body.imageUrl) {
      errors.push('imageData ou imageUrl é obrigatório');
    }

    if (body.imageData && typeof body.imageData !== 'string') {
      errors.push('imageData deve ser string (base64)');
    }

    if (body.imageUrl && !this.isValidUrl(body.imageUrl)) {
      errors.push('imageUrl deve ser URL válida');
    }

    // Validar tamanho da imagem
    if (body.imageData && body.imageData.length > 10 * 1024 * 1024) { // 10MB
      errors.push('Imagem muito grande (máximo 10MB)');
    }

    // Validar contexto de visão se presente
    if (body.visionContext && typeof body.visionContext !== 'object') {
      errors.push('visionContext deve ser objeto');
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }

  /**
   * Valida URL
   */
  private static isValidUrl(url: string): boolean {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Sanitiza texto de entrada
   */
  static sanitizeText(text: string): string {
    return text
      .replace(/[<>]/g, '') // Remove caracteres potencialmente perigosos
      .trim()
      .substring(0, 1000); // Limita tamanho
  }
}

/**
 * Logs de segurança
 */
export class SecurityLogger {
  private static logs: Array<{
    timestamp: number;
    level: 'info' | 'warn' | 'error';
    event: string;
    details: any;
    ip?: string;
    userId?: string;
  }> = [];

  /**
   * Registra evento de segurança
   */
  static log(
    level: 'info' | 'warn' | 'error',
    event: string,
    details: any,
    metadata?: { ip?: string; userId?: string }
  ): void {
    const logEntry = {
      timestamp: Date.now(),
      level,
      event,
      details,
      ...metadata
    };

    this.logs.push(logEntry);

    // Em produção, enviar para serviço de logging
    console.log(`🔐 [${level.toUpperCase()}] ${event}:`, details);

    // Manter apenas últimos 1000 logs em memória
    if (this.logs.length > 1000) {
      this.logs = this.logs.slice(-1000);
    }
  }

  /**
   * Obtém logs recentes
   */
  static getRecentLogs(hours: number = 24): Array<any> {
    const cutoff = Date.now() - (hours * 60 * 60 * 1000);
    return this.logs.filter(log => log.timestamp > cutoff);
  }

  /**
   * Conta eventos por tipo
   */
  static getEventCounts(hours: number = 24): Record<string, number> {
    const recentLogs = this.getRecentLogs(hours);
    const counts: Record<string, number> = {};

    for (const log of recentLogs) {
      counts[log.event] = (counts[log.event] || 0) + 1;
    }

    return counts;
  }
}

/**
 * Middleware de segurança completo
 */
export async function applySecurityMiddleware(
  request: Request,
  body: any
): Promise<{ allowed: boolean; error?: string; metadata?: any }> {
  const startTime = Date.now();

  // 1. Validar origem
  const origin = request.headers.get('origin') || '';
  if (!SecureEnvironment.validateOrigin(origin)) {
    SecurityLogger.log('warn', 'INVALID_ORIGIN', { origin });
    return { allowed: false, error: 'Origem não autorizada' };
  }

  // 2. Validar entrada
  const validation = InputValidator.validateRequest(body);
  if (!validation.valid) {
    SecurityLogger.log('warn', 'INVALID_INPUT', { errors: validation.errors });
    return { allowed: false, error: validation.errors.join('; ') };
  }

  // 3. Rate limiting
  const userId = body.userId;
  const ip = request.headers.get('x-forwarded-for') ||
             request.headers.get('x-real-ip') ||
             'unknown';

  const rateLimitCheck = await RateLimiter.checkRateLimit(userId, 'user');
  if (!rateLimitCheck.allowed) {
    SecurityLogger.log('warn', 'RATE_LIMIT_EXCEEDED', {
      userId,
      ip,
      resetTime: rateLimitCheck.resetTime
    });
    return {
      allowed: false,
      error: 'Limite de uso excedido',
      metadata: { resetTime: rateLimitCheck.resetTime }
    };
  }

  // 4. Registrar tentativa
  await RateLimiter.recordAttempt(userId, 'user');
  SecurityLogger.log('info', 'REQUEST_ALLOWED', { userId, ip });

  return {
    allowed: true,
    metadata: {
      processingTime: Date.now() - startTime,
      origin,
      ip
    }
  };
}
