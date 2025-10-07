// src/generation/generator.ts
// Gerador de mensagens ancoradas em evidências visuais - VERSÃO CORRIGIDA

import { Anchor } from '../vision/anchors.ts';

export interface GenInput {
  tone: string;
  focus_tags?: string[];
  anchors: Anchor[];
  previous_suggestions: string[];
  exhausted_anchors?: Set<string>;
  personalized_instructions?: string;
  max_regenerations?: number;
}

export interface GenOutput {
  success: boolean;
  suggestion?: string;
  anchors_used: string[];
  repetition_rate: number;
  low_confidence?: boolean;
  regenerations_attempted: number;
  error?: string;
}

/**
 * Gera uma única sugestão de mensagem ancorada em evidências
 */
export async function generateSuggestion(input: GenInput): Promise<GenOutput> {
  const {
    tone,
    focus_tags = [],
    anchors,
    previous_suggestions,
    exhausted_anchors = new Set(),
    personalized_instructions = '',
    max_regenerations = 2
  } = input;

  // Validar entrada mínima
  if (!tone || !anchors || anchors.length === 0) {
    return {
      success: false,
      error: 'Parâmetros obrigatórios ausentes: tone e anchors',
      anchors_used: [],
      repetition_rate: 0,
      regenerations_attempted: 0
    };
  }

  const openaiApiKey = Deno.env.get('OPENAI_API_KEY');
  if (!openaiApiKey) {
    return {
      success: false,
      error: 'OpenAI API key não configurada',
      anchors_used: [],
      repetition_rate: 0,
      regenerations_attempted: 0
    };
  }

  // Preparar âncoras disponíveis (não exauridas)
  const availableAnchors = anchors.filter(anchor => !exhausted_anchors.has(anchor.token));

  if (availableAnchors.length === 0) {
    console.log('⚠️ Todas as âncoras foram exauridas, usando âncoras principais');
  }

  const anchorsToUse = availableAnchors.length > 0 ? availableAnchors : anchors.slice(0, 3);

  let currentSuggestion = '';
  let anchorsUsed: string[] = [];
  let repetitionRate = 0;
  let regenerationsAttempted = 0;

  // Sistema de geração com re-tentativas
  for (let attempt = 0; attempt <= max_regenerations; attempt++) {
    regenerationsAttempted = attempt;

    try {
      console.log(`🔄 Tentativa ${attempt + 1} de geração de sugestão...`);

      // Construir system prompt
      const systemPrompt = buildGenerationSystemPrompt(
        tone,
        focus_tags,
        anchorsToUse,
        previous_suggestions,
        personalized_instructions,
        attempt > 0 // Indicar se é regeneração
      );

      // Preparar mensagens para OpenAI
      const messages = [
        {
          role: 'system' as const,
          content: systemPrompt
        },
        {
          role: 'user' as const,
          content: 'Gere apenas UMA mensagem seguindo todas as regras fornecidas.'
        }
      ];

      // Chamar OpenAI API
      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${openaiApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          messages,
          max_tokens: 120, // Moderado como solicitado
          temperature: 0.6,
          top_p: 0.9,
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error(`OpenAI API error (${response.status}):`, errorText);

        if (attempt === max_regenerations) {
          return {
            success: false,
            error: `OpenAI API error: ${response.status}`,
            anchors_used: [],
            repetition_rate: 0,
            regenerations_attempted
          };
        }
        continue;
      }

      const data = await response.json();
      currentSuggestion = data.choices[0]?.message?.content?.trim() || '';

      if (!currentSuggestion) {
        if (attempt === max_regenerations) {
          return {
            success: false,
            error: 'Resposta vazia da OpenAI',
            anchors_used: [],
            repetition_rate: 0,
            regenerations_attempted
          };
        }
        continue;
      }

      // Pós-processamento: validar âncoras e repetição
      const validation = validateSuggestionAnchors(currentSuggestion, anchors);
      anchorsUsed = validation.anchorsUsed;
      repetitionRate = calculateRepetitionRate(currentSuggestion, previous_suggestions);

      console.log(`📊 Validação: ${anchorsUsed.length} âncoras usadas, repetição: ${repetitionRate.toFixed(2)}`);

      // Verificar critérios de sucesso
      const hasAnchors = anchorsUsed.length >= 1;
      const lowRepetition = repetitionRate <= 0.6;

      if (hasAnchors && lowRepetition) {
        console.log(`✅ Sugestão válida gerada em ${attempt + 1} tentativa(s)`);
        return {
          success: true,
          suggestion: currentSuggestion,
          anchors_used: anchorsUsed,
          repetition_rate: repetitionRate,
          regenerations_attempted
        };
      }

      // Se chegou aqui, precisa de regeneração
      if (attempt === max_regenerations) {
        console.log('⚠️ Máximo de tentativas atingido, retornando sugestão com baixa confiança');

        // Retornar pergunta curta se não conseguiu usar âncoras
        if (!hasAnchors) {
          return {
            success: true,
            suggestion: generateFallbackQuestion(anchorsToUse),
            anchors_used: [],
            repetition_rate: repetitionRate,
            low_confidence: true,
            regenerations_attempted
          };
        }

        // Caso contrário, retornar a sugestão mesmo com alta repetição
        return {
          success: true,
          suggestion: currentSuggestion,
          anchors_used: anchorsUsed,
          repetition_rate: repetitionRate,
          low_confidence: true,
          regenerations_attempted
        };
      }

      console.log(`🔄 Regenerando: ${!hasAnchors ? 'sem âncoras' : 'alta repetição'}`);

    } catch (error) {
      console.error(`Erro na tentativa ${attempt + 1}:`, error);

      if (attempt === max_regenerations) {
        return {
          success: false,
          error: `Erro interno: ${error.message}`,
          anchors_used: [],
          repetition_rate: 0,
          regenerations_attempted
        };
      }
    }
  }

  // Fallback final
  return {
    success: true,
    suggestion: generateFallbackQuestion(anchorsToUse),
    anchors_used: [],
    repetition_rate: 0,
    low_confidence: true,
    regenerations_attempted: max_regenerations + 1
  };
}

/**
 * Constrói o system prompt do gerador seguindo especificações
 */
function buildGenerationSystemPrompt(
  tone: string,
  focusTags: string[],
  anchors: Anchor[],
  previousSuggestions: string[],
  personalizedInstructions: string,
  isRegeneration: boolean
): string {
  const anchorNames = anchors.map(a => a.token).slice(0, 5); // Máximo 5 âncoras

  let prompt = `Você gera UMA mensagem de abertura de conversa, curta, natural e original.

REGRAS DURAS:
- Baseie-se EXCLUSIVAMENTE nas evidências fornecidas em ANCHORS.
- É OBRIGATÓRIO usar PELO MENOS 1 âncora pelo NOME (ou flexão simples).
- PROIBIDO: placeholders, clichês genéricos, afirmar o que não está em evidência.
- Se não houver âncoras suficientes, RETORNE UMA PERGUNTA CURTA contextual (duas linhas no máx).
- Evite repetir ideias/palavras de PREVIOUS_SUGGESTIONS; traga ângulo novo.
- Respeite o TONE selecionado (${tone}).
- Saída: APENAS o texto da mensagem, sem aspas, sem bullets, sem preâmbulo.

ÂNCORAS DISPONÍVEIS:
${anchorNames.join(', ')}`;

  // Adicionar instruções de tom específicas
  const toneInstructions = getToneInstructions(tone);
  if (toneInstructions) {
    prompt += `\n\nINSTRUÇÕES DE TOM (${tone.toUpperCase()}):
${toneInstructions}`;
  }

  // Adicionar foco/tags se disponível
  if (focusTags.length > 0) {
    prompt += `\n\nFOCOS/TAGS SELECIONADOS:
${focusTags.join(', ')}`;
  }

  // Adicionar instruções personalizadas se disponível
  if (personalizedInstructions) {
    prompt += `\n\nINSTRUÇÕES PERSONALIZADAS:
${personalizedInstructions}`;
  }

  // Adicionar instruções de regeneração se necessário
  if (isRegeneration) {
    prompt += `\n\n⚠️ INSTRUÇÃO DE REGENERAÇÃO:
A geração anterior não atendeu aos critérios. Certifique-se de usar pelo menos uma âncora e evitar repetição.`;
  }

  // Adicionar aviso sobre repetição se houver sugestões anteriores
  if (previousSuggestions.length > 0) {
    prompt += `\n\nSUGESTÕES ANTERIORES (EVITE REPETIÇÃO):
${previousSuggestions.map((s, i) => `${i + 1}. ${s}`).join('\n')}

INSTRUÇÕES PARA VARIEDADE:
- Não repita conceitos, palavras-chave ou abordagens das sugestões anteriores
- Explore ângulos completamente diferentes
- Use âncoras diferentes das já utilizadas
- Mantenha autenticidade mas traga perspectiva nova`;
  }

  return prompt;
}

/**
 * Retorna instruções específicas para cada tom
 */
function getToneInstructions(tone: string): string {
  const toneLower = tone.toLowerCase();

  if (toneLower.includes('flertar') || toneLower.includes('flertante')) {
    return 'Flertante e romântico, demonstrando interesse sutil e charmoso. Use palavras como "encantador", "olhar", "estilo", "energia", "conexão".';
  }

  if (toneLower.includes('descontraído')) {
    return 'Casual e divertido, com toque de humor e leveza. Use expressões como "que vibe", "curti", "top".';
  }

  if (toneLower.includes('casual')) {
    return 'Natural e espontâneo, como conversa entre amigos. Foque em observações simples e convites abertos.';
  }

  if (toneLower.includes('genuíno')) {
    return 'Autêntico e profundo, mostrando interesse real. Use palavras como "interessante", "curiosidade", "apaixonado".';
  }

  if (toneLower.includes('sensual') || toneLower.includes('picante')) {
    return 'Picante e sedutor, com sensualidade respeitosa. Use palavras como "irresistível", "química", "conexão".';
  }

  return 'Use tom descontraído e casual por padrão.';
}

/**
 * Valida se a sugestão usa âncoras suficientes
 */
function validateSuggestionAnchors(suggestion: string, anchors: Anchor[]): { isValid: boolean, anchorsUsed: string[] } {
  const suggestionLower = suggestion.toLowerCase();
  const anchorsUsed: string[] = [];

  for (const anchor of anchors) {
    if (suggestionLower.includes(anchor.token)) {
      anchorsUsed.push(anchor.token);
    }
  }

  return {
    isValid: anchorsUsed.length >= 1,
    anchorsUsed
  };
}

/**
 * Calcula taxa de repetição usando similaridade de Jaccard com bigramas
 */
function calculateRepetitionRate(suggestion: string, previousSuggestions: string[]): number {
  if (previousSuggestions.length === 0) return 0.0;

  const suggestionBigrams = getBigrams(suggestion.toLowerCase());
  let maxSimilarity = 0.0;

  for (const prevSuggestion of previousSuggestions) {
    const prevBigrams = getBigrams(prevSuggestion.toLowerCase());
    const similarity = jaccardSimilarity(suggestionBigrams, prevBigrams);
    if (similarity > maxSimilarity) {
      maxSimilarity = similarity;
    }
  }

  return maxSimilarity;
}

/**
 * Gera bigramas de um texto
 */
function getBigrams(text: string): Set<string> {
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
 * Calcula similaridade de Jaccard entre dois conjuntos
 */
function jaccardSimilarity(set1: Set<string>, set2: Set<string>): number {
  const intersection = new Set([...set1].filter(x => set2.has(x)));
  const union = new Set([...set1, ...set2]);

  return intersection.size / union.size;
}

/**
 * Gera pergunta curta como fallback quando não há âncoras suficientes
 */
function generateFallbackQuestion(anchors: Anchor[]): string {
  if (anchors.length === 0) {
    return 'O que você gosta de fazer no tempo livre?';
  }

  const randomAnchor = anchors[Math.floor(Math.random() * anchors.length)];
  return `Me conta mais sobre ${randomAnchor.token}?`;
}
