// src/guardrails/guardrails.ts
// Guardrails de produção - PROMPT H

/**
 * Interface para resultado de validação de guardrails
 */
export interface GuardrailResult {
  allowed: boolean;
  reason?: string;
  fallback?: string;
  metadata?: {
    anchorCount: number;
    suggestionLength: number;
    repetitionRate: number;
  };
}

/**
 * Classe principal de guardrails para produção
 */
export class ProductionGuardrails {
  private static readonly MAX_REGENERATIONS = 1;
  private static readonly MIN_ANCHOR_COUNT = 1;
  private static readonly MAX_SUGGESTION_LENGTH = 500;
  private static readonly MAX_REPETITION_RATE = 0.6;

  /**
   * Valida se uma sugestão pode ser retornada para produção
   */
  static validateSuggestion(
    suggestion: string,
    anchors: string[],
    previousSuggestions: string[] = [],
    regenerationCount: number = 0
  ): GuardrailResult {
    const metadata = {
      anchorCount: anchors.length,
      suggestionLength: suggestion.length,
      repetitionRate: this.calculateRepetitionRate(suggestion, previousSuggestions)
    };

    // Guardrail 1: Rejeitar saída sem âncora
    if (anchors.length < this.MIN_ANCHOR_COUNT) {
      return {
        allowed: false,
        reason: 'GUARDRAIL_ANCHOR_MISSING',
        fallback: 'Que foto interessante! Me conte mais sobre você.',
        metadata
      };
    }

    // Guardrail 2: Limitar regeneração a 1x
    if (regenerationCount >= this.MAX_REGENERATIONS) {
      return {
        allowed: false,
        reason: 'GUARDRAIL_MAX_REGENERATIONS',
        fallback: 'Desculpe, já gerei o máximo de sugestões alternativas.',
        metadata
      };
    }

    // Guardrail 3: Controle de repetição
    if (metadata.repetitionRate > this.MAX_REPETITION_RATE) {
      return {
        allowed: false,
        reason: 'GUARDRAIL_HIGH_REPETITION',
        fallback: 'Que tal tentarmos uma abordagem diferente?',
        metadata
      };
    }

    // Guardrail 4: Comprimento máximo de sugestão
    if (suggestion.length > this.MAX_SUGGESTION_LENGTH) {
      return {
        allowed: false,
        reason: 'GUARDRAIL_SUGGESTION_TOO_LONG',
        fallback: suggestion.substring(0, this.MAX_SUGGESTION_LENGTH - 3) + '...',
        metadata
      };
    }

    // Todas as validações passaram
    return {
      allowed: true,
      metadata
    };
  }

  /**
   * Calcula taxa de repetição usando algoritmo Jaccard
   */
  private static calculateRepetitionRate(suggestion: string, previousSuggestions: string[]): number {
    if (previousSuggestions.length === 0) return 0.0;

    const suggestionBigrams = this.getBigrams(suggestion.toLowerCase());
    let maxSimilarity = 0.0;

    for (const prevSuggestion of previousSuggestions) {
      const prevBigrams = this.getBigrams(prevSuggestion.toLowerCase());
      const similarity = this.jaccardSimilarity(suggestionBigrams, prevBigrams);
      if (similarity > maxSimilarity) {
        maxSimilarity = similarity;
      }
    }

    return maxSimilarity;
  }

  /**
   * Gera bigramas para cálculo de similaridade
   */
  private static getBigrams(text: string): Set<string> {
    const bigrams = new Set<string>();
    const words = text.split(/\s+/);

    for (const word of words) {
      if (word.length >= 2) {
        for (let i = 0; i < word.length - 1; i++) {
          bigrams.add(word.substring(i, i + 2));
        }
      }
    }

    return bigrams;
  }

  /**
   * Calcula similaridade Jaccard entre dois conjuntos
   */
  private static jaccardSimilarity(set1: Set<string>, set2: Set<string>): number {
    const intersection = new Set([...set1].filter(x => set2.has(x)));
    const union = new Set([...set1, ...set2]);

    return intersection.size / union.size;
  }

  /**
   * Valida contexto de visão para produção
   */
  static validateVisionContext(visionContext: any): GuardrailResult {
    // Validar estrutura mínima do contexto
    if (!visionContext || !visionContext.schema_version) {
      return {
        allowed: false,
        reason: 'GUARDRAIL_INVALID_CONTEXT',
        fallback: 'Não foi possível analisar a imagem adequadamente.'
      };
    }

    // Validar confiança mínima
    if (visionContext.confidence_overall < 0.5) {
      return {
        allowed: false,
        reason: 'GUARDRAIL_LOW_CONFIDENCE',
        fallback: 'A imagem não está clara o suficiente para análise.'
      };
    }

    return { allowed: true };
  }

  /**
   * Valida rate limiting (simulado para validação)
   */
  static validateRateLimit(
    userId: string,
    ip: string,
    currentRequests: number = 0
  ): GuardrailResult {
    const MAX_REQUESTS_PER_HOUR = 100;
    const MAX_REQUESTS_PER_MINUTE = 10;

    if (currentRequests >= MAX_REQUESTS_PER_MINUTE) {
      return {
        allowed: false,
        reason: 'GUARDRAIL_RATE_LIMIT_MINUTE',
        fallback: 'Muitas solicitações. Tente novamente em alguns minutos.'
      };
    }

    if (currentRequests >= MAX_REQUESTS_PER_HOUR) {
      return {
        allowed: false,
        reason: 'GUARDRAIL_RATE_LIMIT_HOUR',
        fallback: 'Limite de uso excedido. Tente novamente mais tarde.'
      };
    }

    return { allowed: true };
  }

  /**
   * Gera pergunta curta como fallback
   */
  static generateShortFallbackQuestion(anchors: string[]): string {
    const fallbackQuestions = [
      'Que foto interessante! Me conte mais sobre você.',
      'Adorei! O que você gosta de fazer no tempo livre?',
      'Muito legal! Qual é sua paixão?',
      'Que incrível! Me fale sobre seus hobbies.',
      'Adorei ver isso! O que te motiva?'
    ];

    // Se temos âncoras, usar contexto
    if (anchors.length > 0) {
      const anchor = anchors[0];
      if (anchor.includes('praia')) {
        return 'Que praia incrível! Qual seu destino favorito?';
      } else if (anchor.includes('musica') || anchor.includes('guitarra')) {
        return 'Que talento musical! Qual instrumento você toca?';
      } else if (anchor.includes('livro')) {
        return 'Que ambiente acolhedor! Qual livro você recomenda?';
      } else if (anchor.includes('cachorro') || anchor.includes('pet')) {
        return 'Que pet fofinho! Como ele se chama?';
      }
    }

    // Fallback genérico
    return fallbackQuestions[Math.floor(Math.random() * fallbackQuestions.length)];
  }
}

/**
 * Middleware de guardrails para Edge Function
 */
export function applyGuardrailsMiddleware(
  suggestion: string,
  anchors: string[],
  visionContext: any,
  metadata: {
    userId?: string;
    ip?: string;
    regenerationCount?: number;
    previousSuggestions?: string[];
  }
): { suggestion: string; guardrailInfo?: any } {
  const startTime = Date.now();

  // Aplicar todos os guardrails
  const visionValidation = ProductionGuardrails.validateVisionContext(visionContext);
  if (!visionValidation.allowed) {
    return {
      suggestion: visionValidation.fallback || 'Erro interno na análise.',
      guardrailInfo: {
        triggered: true,
        reason: visionValidation.reason,
        duration: Date.now() - startTime
      }
    };
  }

  // Rate limiting (simulado)
  if (metadata.userId && metadata.ip) {
    const rateLimitValidation = ProductionGuardrails.validateRateLimit(
      metadata.userId,
      metadata.ip,
      Math.floor(Math.random() * 5) // Simulado
    );
    if (!rateLimitValidation.allowed) {
      return {
        suggestion: rateLimitValidation.fallback || 'Limite de uso excedido.',
        guardrailInfo: {
          triggered: true,
          reason: rateLimitValidation.reason,
          duration: Date.now() - startTime
        }
      };
    }
  }

  // Validação principal da sugestão
  const suggestionValidation = ProductionGuardrails.validateSuggestion(
    suggestion,
    anchors,
    metadata.previousSuggestions || [],
    metadata.regenerationCount || 0
  );

  if (!suggestionValidation.allowed) {
    return {
      suggestion: suggestionValidation.fallback || ProductionGuardrails.generateShortFallbackQuestion(anchors),
      guardrailInfo: {
        triggered: true,
        reason: suggestionValidation.reason,
        metadata: suggestionValidation.metadata,
        duration: Date.now() - startTime
      }
    };
  }

  // Sugestão aprovada
  return {
    suggestion,
    guardrailInfo: {
      triggered: false,
      metadata: suggestionValidation.metadata,
      duration: Date.now() - startTime
    }
  };
}
