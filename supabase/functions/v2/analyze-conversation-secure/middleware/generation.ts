// supabase/functions/v2/analyze-conversation-secure/middleware/generation.ts
// Middleware de geração de sugestões para Edge Function v2

/**
 * Middleware de geração de sugestões com contexto
 */
export class GenerationMiddleware {
  /**
   * Gera sugestão baseada em âncoras e contexto
   */
  static async generateSuggestion(
    anchors: any[],
    tone: string,
    visionContext: any,
    observability: any
  ): Promise<{ suggestion: string; generationTime: number }> {
    const startTime = Date.now();

    try {
      observability.log('suggestion_generation_started', {
        anchorCount: anchors.length,
        tone,
        contextConfidence: visionContext.confidence_overall
      });

      const suggestion = await this.createContextualSuggestion(anchors, tone, visionContext);

      const generationTime = Date.now() - startTime;

      observability.log('suggestion_generation_completed', {
        suggestionLength: suggestion.length,
        generationTime,
        tokensUsed: suggestion.split(' ').length
      });

      return {
        suggestion,
        generationTime
      };

    } catch (error) {
      const generationTime = Date.now() - startTime;
      observability.log('suggestion_generation_error', {
        error: error.message,
        generationTime
      });
      throw error;
    }
  }

  /**
   * Cria sugestão contextual baseada em âncoras
   */
  private static async createContextualSuggestion(
    anchors: any[],
    tone: string,
    visionContext: any
  ): Promise<string> {
    // Simulação de geração (em produção usar LLM)
    await new Promise(resolve => setTimeout(resolve, 200));

    const tokens = anchors.map(a => a.token.toLowerCase()).slice(0, 3);

    // Geração baseada em contexto visual
    let baseSuggestion = '';

    if (tokens.includes('praia')) {
      baseSuggestion = 'Que vibe incrível nessa praia! O verão combina tanto com você';
    } else if (tokens.includes('guitarra')) {
      baseSuggestion = 'Que guitarra incrível! Vejo que música é sua paixão';
    } else if (tokens.includes('cachorro')) {
      baseSuggestion = 'Que cachorro mais animado! O que ele gosta de fazer pra se divertir?';
    } else if (tokens.includes('livro')) {
      baseSuggestion = 'Que ambiente acolhedor! Vejo que você ama ler, qual seu gênero favorito?';
    } else if (tokens.includes('bola')) {
      baseSuggestion = 'Que esporte incrível! Futebol é mesmo apaixonante';
    } else if (tokens.includes('panela')) {
      baseSuggestion = 'Que cozinha aconchegante! Cozinhar é uma arte';
    } else if (tokens.includes('montanha')) {
      baseSuggestion = 'Que aventura incrível! Montanhas sempre inspiram';
    } else if (tokens.includes('quadro')) {
      baseSuggestion = 'Que talento artístico! Arte é expressão pura';
    } else if (tokens.includes('halteres')) {
      baseSuggestion = 'Que dedicação aos treinos! Saúde em primeiro lugar';
    } else if (tokens.includes('cafe')) {
      baseSuggestion = 'Que ambiente perfeito! Café e boa companhia';
    } else {
      baseSuggestion = 'Que foto incrível! Me conta mais sobre essa aventura';
    }

    // Adaptar tom da sugestão
    const toneAdaptation = this.getToneAdaptation(tone);
    if (toneAdaptation) {
      baseSuggestion += toneAdaptation;
    }

    // Adicionar contexto específico se disponível
    if (visionContext.detected_persons?.name) {
      const personName = visionContext.detected_persons.name;
      baseSuggestion = baseSuggestion.replace('Que vibe incrível', `Ei ${personName}, que vibe incrível`);
    }

    return baseSuggestion;
  }

  /**
   * Obtém adaptação baseada no tom
   */
  private static getToneAdaptation(tone: string): string {
    const toneAdaptations: Record<string, string> = {
      'flertar': ' Estou curioso para conhecer melhor essa sua energia contagiante!',
      'amigável': ' Parece que você tem histórias incríveis para contar!',
      'profissional': ' Admiro sua dedicação e conquistas!',
      'descontraído': ' Vamos continuar essa conversa animada!',
      'romântico': ' Seu sorriso ilumina tudo ao redor...',
      'motivacional': ' Você é uma inspiração! Continue assim!',
      'humorístico': ' Que situação engraçada! Adorei seu senso de humor!'
    };

    return toneAdaptations[tone] || '';
  }

  /**
   * Valida qualidade da sugestão gerada
   */
  static validateSuggestionQuality(
    suggestion: string,
    anchors: string[]
  ): { valid: boolean; issues: string[] } {
    const issues: string[] = [];

    // Verificar comprimento mínimo
    if (suggestion.length < 20) {
      issues.push('Sugestão muito curta');
    }

    // Verificar comprimento máximo
    if (suggestion.length > 500) {
      issues.push('Sugestão muito longa');
    }

    // Verificar uso de âncoras
    const suggestionLower = suggestion.toLowerCase();
    const anchorsUsed = anchors.filter(anchor =>
      suggestionLower.includes(anchor.toLowerCase())
    );

    if (anchorsUsed.length === 0) {
      issues.push('Nenhuma âncora utilizada na sugestão');
    }

    return {
      valid: issues.length === 0,
      issues
    };
  }
}
