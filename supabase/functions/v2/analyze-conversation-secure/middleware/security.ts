// supabase/functions/v2/analyze-conversation-secure/middleware/security.ts
// Middleware de segurança para Edge Function v2

import { SecureEnvironment, InputValidator, SecurityLogger, RateLimiter } from '../../../../src/security/security.ts';

/**
 * Middleware completo de segurança para Edge Function v2
 */
export class SecurityMiddleware {
  /**
   * Validação completa de segurança da requisição
   */
  static async validateRequest(
    req: Request,
    body: any,
    requestId: string
  ): Promise<{ allowed: boolean; error?: string; status?: number; metadata?: any }> {
    try {
      // 1. Validar entrada
      const validation = InputValidator.validateRequest(body);
      if (!validation.valid) {
        SecurityLogger.log('warn', 'INVALID_INPUT', { requestId, errors: validation.errors });
        return { allowed: false, error: validation.errors.join('; '), status: 400 };
      }

      // 2. Rate limiting
      const userId = body.userId;
      const ip = this.extractClientIP(req);

      const rateLimitCheck = await RateLimiter.checkRateLimit(userId, 'user');
      if (!rateLimitCheck.allowed) {
        SecurityLogger.log('warn', 'RATE_LIMIT_EXCEEDED', {
          requestId,
          userId,
          ip,
          resetTime: rateLimitCheck.resetTime
        });
        return {
          allowed: false,
          error: 'Limite de uso excedido',
          status: 429,
          metadata: { resetTime: rateLimitCheck.resetTime }
        };
      }

      // 3. Registrar tentativa bem-sucedida
      await RateLimiter.recordAttempt(userId, 'user');
      SecurityLogger.log('info', 'REQUEST_ALLOWED', { requestId, userId, ip });

      return {
        allowed: true,
        metadata: {
          ip,
          remaining: rateLimitCheck.remaining,
          validationPassed: true
        }
      };

    } catch (error) {
      SecurityLogger.log('error', 'SECURITY_VALIDATION_ERROR', { requestId, error: error.message });
      return { allowed: false, error: 'Erro na validação de segurança', status: 500 };
    }
  }

  /**
   * Extrai IP do cliente considerando proxies
   */
  private static extractClientIP(req: Request): string {
    return req.headers.get('x-forwarded-for')?.split(',')[0] ||
           req.headers.get('x-real-ip') ||
           req.headers.get('cf-connecting-ip') ||
           'unknown';
  }

  /**
   * Valida origem da requisição
   */
  static validateOrigin(origin: string): boolean {
    return SecureEnvironment.validateOrigin(origin);
  }

  /**
   * Sanitiza texto de entrada
   */
  static sanitizeText(text: string): string {
    return InputValidator.sanitizeText(text);
  }
}

/**
 * Middleware de observabilidade integrado
 */
export class ObservabilityMiddleware {
  private requestId: string;
  private userId: string;
  private ip: string;
  private startTime: number;

  constructor(requestId: string, userId: string, ip: string) {
    this.requestId = requestId;
    this.userId = userId;
    this.ip = ip;
    this.startTime = Date.now();
  }

  /**
   * Registra evento estruturado
   */
  log(event: string, data: any): void {
    console.log(`📋 [${event.toUpperCase()}] ${this.requestId}:`, {
      timestamp: new Date().toISOString(),
      requestId: this.requestId,
      userId: this.userId,
      ip: this.ip,
      duration: Date.now() - this.startTime,
      ...data
    });
  }

  /**
   * Obtém tempo decorrido desde início
   */
  getElapsedTime(): number {
    return Date.now() - this.startTime;
  }

  /**
   * Finaliza observabilidade e retorna métricas
   */
  finalize(): { totalLatency: number; requestId: string } {
    const totalLatency = Date.now() - this.startTime;
    this.log('request_completed', { totalLatency });
    return { totalLatency, requestId: this.requestId };
  }
}
