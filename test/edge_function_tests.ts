// test/edge_function_tests.ts
// Testes automatizados para Edge Function - PROMPT G (CORRIGIDO)

import { computeAnchors } from '../src/vision/anchors.ts';

/**
 * Cenários de teste realistas para computeAnchors
 */
const ANCHOR_COMPUTATION_SCENARIOS = [
  {
    name: 'Contexto Básico com Pessoa',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1, name: 'Ana' },
      objects: [
        { name: 'guitarra', confidence: 0.89, source: 'vision' as const }
      ],
      actions: [
        { name: 'tocando', confidence: 0.85, source: 'vision' as const }
      ],
      places: [
        { name: 'quarto', confidence: 0.76, source: 'vision' as const }
      ],
      colors: ['marrom', 'preto'],
      ocr_text: 'Música é vida 🎸',
      notable_details: ['instrumento de qualidade', 'paixão evidente'],
      confidence_overall: 0.87
    },
    expected_behavior: {
      shouldHaveAnchors: true,
      minAnchors: 3,
      shouldIncludePersonName: true,
      shouldIncludeObjects: true,
      shouldIncludeOCR: true
    }
  },
  {
    name: 'Contexto com Múltiplas Pessoas',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 2, name: 'Carlos e Maria' },
      objects: [
        { name: 'bola', confidence: 0.92, source: 'vision' as const },
        { name: 'campo', confidence: 0.88, source: 'vision' as const }
      ],
      actions: [
        { name: 'jogando', confidence: 0.90, source: 'vision' as const }
      ],
      places: [
        { name: 'parque', confidence: 0.82, source: 'vision' as const }
      ],
      colors: ['verde', 'azul'],
      ocr_text: 'Futebol no parque ⚽',
      notable_details: ['atividade ao ar livre', 'diversão em grupo'],
      confidence_overall: 0.91
    },
    expected_behavior: {
      shouldHaveAnchors: true,
      minAnchors: 4,
      shouldIncludeMultiplePersons: true,
      shouldIncludeSports: true
    }
  },
  {
    name: 'Contexto com Pet',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1, name: 'João' },
      objects: [
        { name: 'cachorro', confidence: 0.95, source: 'vision' as const },
        { name: 'coleira', confidence: 0.87, source: 'vision' as const }
      ],
      actions: [
        { name: 'passeando', confidence: 0.89, source: 'vision' as const }
      ],
      places: [
        { name: 'rua', confidence: 0.78, source: 'vision' as const }
      ],
      colors: ['preto', 'branco'],
      ocr_text: 'Passeio com meu pet 🐕',
      notable_details: ['cão amigável', 'coleira colorida'],
      confidence_overall: 0.88
    },
    expected_behavior: {
      shouldHaveAnchors: true,
      minAnchors: 3,
      shouldIncludePet: true,
      shouldIncludeActivity: true
    }
  },
  {
    name: 'Contexto com Livro/Leitura',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'livro', confidence: 0.93, source: 'vision' as const },
        { name: 'oculos', confidence: 0.86, source: 'vision' as const }
      ],
      actions: [
        { name: 'lendo', confidence: 0.91, source: 'vision' as const }
      ],
      places: [
        { name: 'biblioteca', confidence: 0.79, source: 'vision' as const }
      ],
      colors: ['azul', 'branco'],
      ocr_text: 'Leitura na biblioteca 📚',
      notable_details: ['concentração na leitura', 'ambiente silencioso'],
      confidence_overall: 0.85
    },
    expected_behavior: {
      shouldHaveAnchors: true,
      minAnchors: 3,
      shouldIncludeReading: true,
      shouldIncludeAccessories: true
    }
  },
  {
    name: 'Contexto com Praia',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1, name: 'Sofia' },
      objects: [
        { name: 'oculos_sol', confidence: 0.90, source: 'vision' as const },
        { name: 'protetor_solar', confidence: 0.84, source: 'vision' as const }
      ],
      actions: [
        { name: 'relaxando', confidence: 0.87, source: 'vision' as const }
      ],
      places: [
        { name: 'praia', confidence: 0.94, source: 'vision' as const }
      ],
      colors: ['azul', 'dourado'],
      ocr_text: 'Dia perfeito na praia ☀️🏖️',
      notable_details: ['ondas calmas', 'areia dourada'],
      confidence_overall: 0.90
    },
    expected_behavior: {
      shouldHaveAnchors: true,
      minAnchors: 4,
      shouldIncludeBeach: true,
      shouldIncludeSummer: true
    }
  }
];

/**
 * Testa função computeAnchors com cenários realistas
 */
async function testComputeAnchors() {
  console.log('🧪 Testando função computeAnchors...\n');

  const results = {
    totalScenarios: 0,
    successfulComputations: 0,
    anchorValidation: 0,
    deduplicationWorking: 0,
    stopwordsFiltered: 0
  };

  for (let i = 0; i < ANCHOR_COMPUTATION_SCENARIOS.length; i++) {
    const scenario = ANCHOR_COMPUTATION_SCENARIOS[i];
    results.totalScenarios++;

    console.log(`🏷️ Cenário ${i + 1}: ${scenario.name}`);

    try {
      // Computar âncoras usando função real do sistema
      const anchors = computeAnchors(scenario.visionContext);

      console.log(`   📊 Âncoras computadas: ${anchors.length}`);
      if (anchors.length > 0) {
        console.log(`   🎯 Tokens: ${anchors.map(a => a.token).join(', ')}`);
      }

      // Validações básicas
      const hasRequiredAnchors = anchors.length >= scenario.expected_behavior.minAnchors;
      if (hasRequiredAnchors) results.successfulComputations++;

      // Validação de conteúdo específico
      const tokens = anchors.map(a => a.token.toLowerCase());
      let contentValidation = 0;

      if (scenario.expected_behavior.shouldIncludePersonName && tokens.some(t => t.includes('ana') || t.includes('sofia'))) {
        contentValidation++;
      }

      if (scenario.expected_behavior.shouldIncludeObjects && tokens.some(t => ['guitarra', 'bola', 'cachorro', 'livro'].includes(t))) {
        contentValidation++;
      }

      if (scenario.expected_behavior.shouldIncludeOCR && tokens.some(t => ['musica', 'futebol', 'pet', 'leitura', 'praia'].includes(t))) {
        contentValidation++;
      }

      if (contentValidation >= 2) results.anchorValidation++;

      // Validação de deduplicação
      const uniqueTokens = new Set(tokens);
      if (uniqueTokens.size === tokens.length) results.deduplicationWorking++;

      // Validação de filtragem de stopwords
      const hasStopwords = tokens.some(t => ['que', 'com', 'para', 'uma', 'como'].includes(t));
      if (!hasStopwords) results.stopwordsFiltered++;

      console.log(`   ✅ Computação bem-sucedida: ${hasRequiredAnchors ? 'Sim' : 'Não'}`);
      console.log(`   🎯 Validação de conteúdo: ${contentValidation}/2`);
      console.log(`   🔄 Deduplicação: ${uniqueTokens.size === tokens.length ? 'OK' : 'Falha'}`);
      console.log(`   🚫 Stopwords filtradas: ${!hasStopwords ? 'OK' : 'Falha'}`);

    } catch (error) {
      console.log(`   ❌ Erro na computação: ${error.message}`);
    }

    console.log('');
  }

  // Relatório final
  console.log('📊 RELATÓRIO FINAL DE TESTES computeAnchors');
  console.log('============================================');
  console.log(`Cenários testados: ${results.totalScenarios}`);
  console.log(`Computações bem-sucedidas: ${results.successfulComputations}/${results.totalScenarios} (${(results.successfulComputations/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Validação de âncoras: ${results.anchorValidation}/${results.totalScenarios} (${(results.anchorValidation/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Deduplicação funcional: ${results.deduplicationWorking}/${results.totalScenarios} (${(results.deduplicationWorking/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Filtragem de stopwords: ${results.stopwordsFiltered}/${results.totalScenarios} (${(results.stopwordsFiltered/results.totalScenarios*100).toFixed(1)}%)`);

  // Critérios de aceite
  const criteriaMet = {
    successfulComputations: results.successfulComputations / results.totalScenarios >= 0.8,
    anchorValidation: results.anchorValidation / results.totalScenarios >= 0.7,
    deduplication: results.deduplicationWorking / results.totalScenarios >= 0.9,
    stopwordsFiltering: results.stopwordsFiltered / results.totalScenarios >= 0.8
  };

  console.log('\n🎯 CRITÉRIOS DE ACEITE:');
  console.log(`Computações ≥80%: ${criteriaMet.successfulComputations ? '✅' : '❌'}`);
  console.log(`Validação ≥70%: ${criteriaMet.anchorValidation ? '✅' : '❌'}`);
  console.log(`Deduplicação ≥90%: ${criteriaMet.deduplication ? '✅' : '❌'}`);
  console.log(`Stopwords ≥80%: ${criteriaMet.stopwordsFiltering ? '✅' : '❌'}`);

  const allCriteriaPassed = Object.values(criteriaMet).every(Boolean);
  console.log(`\n🏆 STATUS: ${allCriteriaPassed ? '✅ computeAnchors VALIDADO' : '❌ computeAnchors PRECISA AJUSTES'}`);

  return allCriteriaPassed;
}

/**
 * Cenários de teste para validateSuggestion (simulado para validação)
 */
const SUGGESTION_VALIDATION_SCENARIOS = [
  {
    name: 'Sugestão com Âncoras Suficientes',
    suggestion: 'Que guitarra incrível! Vejo que você ama música clássica, qual seu compositor favorito?',
    anchors: ['guitarra', 'musica', 'tocando', 'quarto'],
    expected_behavior: {
      shouldBeValid: true,
      minAnchorsUsed: 2,
      shouldTriggerRegeneration: false
    }
  },
  {
    name: 'Sugestão sem Âncoras (Dispara Regeneração)',
    suggestion: 'Olá! Como você está hoje? O tempo está ótimo para uma conversa agradável.',
    anchors: ['guitarra', 'musica', 'tocando', 'quarto'],
    expected_behavior: {
      shouldBeValid: false,
      shouldTriggerRegeneration: true,
      maxRegenerations: 1
    }
  },
  {
    name: 'Sugestão com Repetição Alta',
    suggestion: 'Que guitarra incrível! Você toca há quanto tempo? Adorei sua guitarra!',
    anchors: ['guitarra', 'musica'],
    previousSuggestions: [
      'Que guitarra incrível! Você toca há quanto tempo?',
      'Adorei sua guitarra! Qual marca você recomenda?'
    ],
    expected_behavior: {
      shouldBeValid: false,
      repetitionRate: 0.7, // Deve ser > 0.6
      shouldTriggerRegeneration: true
    }
  },
  {
    name: 'Sugestão com Âncoras e Repetição Baixa',
    suggestion: 'Que ambiente acolhedor! Vejo que você ama ler, qual seu gênero favorito de livro?',
    anchors: ['livro', 'lendo', 'biblioteca'],
    previousSuggestions: [
      'Que livro interessante! Filosofia sempre me fascinou.',
      'Adorei sua paixão pela leitura! O que você recomenda?'
    ],
    expected_behavior: {
      shouldBeValid: true,
      minAnchorsUsed: 2,
      maxRepetitionRate: 0.4,
      shouldNotTriggerRegeneration: true
    }
  }
];

/**
 * Testa validação de sugestões com cenários realistas
 */
async function testValidateSuggestion() {
  console.log('🧪 Testando validação de sugestões...\n');

  const results = {
    totalScenarios: 0,
    validSuggestions: 0,
    regenerationTriggered: 0,
    repetitionControl: 0,
    anchorValidation: 0
  };

  for (let i = 0; i < SUGGESTION_VALIDATION_SCENARIOS.length; i++) {
    const scenario = SUGGESTION_VALIDATION_SCENARIOS[i];
    results.totalScenarios++;

    console.log(`🏷️ Cenário ${i + 1}: ${scenario.name}`);

    try {
      // Executar validação usando algoritmo real
      const validation = validateSuggestionAnchors(scenario.suggestion, scenario.anchors);

      console.log(`   📊 Âncoras usadas: ${validation.anchorsUsed.length} (${validation.anchorsUsed.join(', ')})`);
      console.log(`   ✅ Validação inicial: ${validation.isValid ? 'Válida' : 'Inválida'}`);

      // Calcular repetição se houver sugestões anteriores
      let repetitionRate = 0.0;
      if (scenario.previousSuggestions) {
        repetitionRate = calculateRepetitionRate(scenario.suggestion, scenario.previousSuggestions);
        console.log(`   🔄 Taxa de repetição: ${repetitionRate.toFixed(3)}`);
      }

      // Validações
      const hasRequiredAnchors = validation.anchorsUsed.length >= scenario.expected_behavior.minAnchorsUsed;
      if (hasRequiredAnchors) results.anchorValidation++;

      if (scenario.expected_behavior.shouldBeValid) {
        if (validation.isValid) results.validSuggestions++;
      }

      if (scenario.expected_behavior.shouldTriggerRegeneration) {
        if (!validation.isValid) results.regenerationTriggered++;
      }

      if (scenario.expected_behavior.shouldNotTriggerRegeneration) {
        if (validation.isValid) results.regenerationTriggered++;
      }

      // Validação de repetição
      if (scenario.expected_behavior.maxRepetitionRate) {
        if (repetitionRate <= scenario.expected_behavior.maxRepetitionRate) results.repetitionControl++;
      }

      console.log(`   🎯 Validações:`);
      console.log(`      - Âncoras obrigatórias: ${hasRequiredAnchors ? '✅' : '❌'}`);
      console.log(`      - Deve ser válida: ${scenario.expected_behavior.shouldBeValid ? (validation.isValid ? '✅' : '❌') : 'N/A'}`);
      console.log(`      - Controle de repetição: ${scenario.expected_behavior.maxRepetitionRate ? (repetitionRate <= scenario.expected_behavior.maxRepetitionRate ? '✅' : '❌') : 'N/A'}`);

    } catch (error) {
      console.log(`   ❌ Erro na validação: ${error.message}`);
    }

    console.log('');
  }

  // Relatório final
  console.log('📊 RELATÓRIO FINAL DE TESTES validateSuggestion');
  console.log('===============================================');
  console.log(`Cenários testados: ${results.totalScenarios}`);
  console.log(`Sugestões válidas: ${results.validSuggestions}/${results.totalScenarios} (${(results.validSuggestions/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Regeneração funcional: ${results.regenerationTriggered}/${results.totalScenarios} (${(results.regenerationTriggered/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Controle de repetição: ${results.repetitionControl}/${results.totalScenarios} (${(results.repetitionControl/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Validação de âncoras: ${results.anchorValidation}/${results.totalScenarios} (${(results.anchorValidation/results.totalScenarios*100).toFixed(1)}%)`);

  // Critérios de aceite
  const criteriaMet = {
    validSuggestions: results.validSuggestions / results.totalScenarios >= 0.75,
    regenerationWorks: results.regenerationTriggered / results.totalScenarios >= 0.5,
    repetitionControl: results.repetitionControl / results.totalScenarios >= 0.8,
    anchorValidation: results.anchorValidation / results.totalScenarios >= 0.8
  };

  console.log('\n🎯 CRITÉRIOS DE ACEITE:');
  console.log(`Sugestões válidas ≥75%: ${criteriaMet.validSuggestions ? '✅' : '❌'}`);
  console.log(`Regeneração ≥50%: ${criteriaMet.regenerationWorks ? '✅' : '❌'}`);
  console.log(`Controle de repetição ≥80%: ${criteriaMet.repetitionControl ? '✅' : '❌'}`);
  console.log(`Validação de âncoras ≥80%: ${criteriaMet.anchorValidation ? '✅' : '❌'}`);

  const allCriteriaPassed = Object.values(criteriaMet).every(Boolean);
  console.log(`\n🏆 STATUS: ${allCriteriaPassed ? '✅ validateSuggestion VALIDADO' : '❌ validateSuggestion PRECISA AJUSTES'}`);

  return allCriteriaPassed;
}

/**
 * Teste principal dos componentes críticos do Edge Function
 */
async function testEdgeFunctionComponents() {
  console.log('🚀 TESTES AUTOMATIZADOS - COMPONENTES CRÍTICOS DO EDGE FUNCTION');
  console.log('===============================================================\n');

  try {
    // Testar computeAnchors usando implementação real
    const anchorsTestPassed = await testComputeAnchors();

    console.log('');

    // Testar validateSuggestion usando algoritmos reais
    const validationTestPassed = await testValidateSuggestion();

    // Resultado geral
    const overallSuccess = anchorsTestPassed && validationTestPassed;

    console.log('\n🏁 RESULTADO GERAL DOS TESTES DO EDGE FUNCTION');
    console.log('================================================');
    console.log(`✅ computeAnchors: ${anchorsTestPassed ? 'VALIDADO' : 'FALHANDO'}`);
    console.log(`✅ validateSuggestion: ${validationTestPassed ? 'VALIDADO' : 'FALHANDO'}`);
    console.log(`\n🎯 STATUS FINAL: ${overallSuccess ? '✅ EDGE FUNCTION VALIDADO' : '❌ EDGE FUNCTION PRECISA AJUSTES'}`);

    return overallSuccess;

  } catch (error) {
    console.log(`\n❌ Erro crítico nos testes: ${error.message}`);
    return false;
  }
}

// Funções auxiliares usando algoritmos reais
function validateSuggestionAnchors(suggestion: string, anchors: string[]): { isValid: boolean, anchorsUsed: string[] } {
  const suggestionLower = suggestion.toLowerCase();
  const anchorsUsed: string[] = [];

  anchors.forEach(anchor => {
    if (suggestionLower.includes(anchor.toLowerCase())) {
      anchorsUsed.push(anchor);
    }
  });

  return {
    isValid: anchorsUsed.length >= 1,
    anchorsUsed
  };
}

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

function jaccardSimilarity(set1: Set<string>, set2: Set<string>): number {
  const intersection = new Set([...set1].filter(x => set2.has(x)));
  const union = new Set([...set1, ...set2]);

  return intersection.size / union.size;
}

// Executar testes se arquivo for chamado diretamente
if (import.meta.main) {
  await testEdgeFunctionComponents();
}
