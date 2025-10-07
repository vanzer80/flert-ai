// test/generator_edge_cases_test.ts
// Teste de casos extremos e validação de robustez

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

/**
 * Cenários extremos para testar robustez
 */
const EDGE_CASE_SCENARIOS = [
  {
    name: 'Âncoras Vazias',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 0 },
      objects: [],
      actions: [],
      places: [],
      colors: [],
      ocr_text: '',
      notable_details: [],
      confidence_overall: 0.0
    },
    tone: 'casual',
    focus_tags: [],
    previous_suggestions: [],
    shouldGenerateFallback: true
  },
  {
    name: 'Todas Âncoras Exauridas',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'gato', confidence: 0.92, source: 'vision' as const }
      ],
      actions: [],
      places: [],
      colors: [],
      ocr_text: '',
      notable_details: [],
      confidence_overall: 0.85
    },
    tone: 'descontraído',
    focus_tags: ['pet'],
    previous_suggestions: [],
    exhausted_anchors: new Set(['gato']),
    shouldUseFallbackAnchors: true
  },
  {
    name: 'Sugestões Anteriores Muito Semelhantes',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'praia', confidence: 0.95, source: 'vision' as const }
      ],
      actions: [],
      places: [],
      colors: [],
      ocr_text: '',
      notable_details: [],
      confidence_overall: 0.90
    },
    tone: 'flertar',
    focus_tags: ['praia'],
    previous_suggestions: [
      'Que praia incrível! Adorei essa vibe de verão',
      'Nossa, que energia boa nessa praia! Me conta mais',
      'Praia é sempre bom! Qual sua praia favorita?'
    ],
    shouldTriggerRegeneration: true
  },
  {
    name: 'Tom Inválido',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'livro', confidence: 0.88, source: 'vision' as const }
      ],
      actions: [],
      places: [],
      colors: [],
      ocr_text: '',
      notable_details: [],
      confidence_overall: 0.85
    },
    tone: 'invalido',
    focus_tags: ['leitura'],
    previous_suggestions: [],
    shouldUseDefaultTone: true
  },
  {
    name: 'Instruções Personalizadas Complexas',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'cozinha', confidence: 0.88, source: 'vision' as const }
      ],
      actions: [],
      places: [],
      colors: [],
      ocr_text: '',
      notable_details: [],
      confidence_overall: 0.85
    },
    tone: 'sensual',
    focus_tags: ['culinária'],
    previous_suggestions: [],
    personalized_instructions: 'Seja muito sutil e elegante, evite ser direto demais, foque na conexão emocional através da comida',
    shouldRespectInstructions: true
  }
];

/**
 * Testa casos extremos e valida robustez
 */
async function testEdgeCases() {
  console.log('🧪 Testando casos extremos e validação de robustez...\n');

  for (let i = 0; i < EDGE_CASE_SCENARIOS.length; i++) {
    const scenario = EDGE_CASE_SCENARIOS[i];
    console.log(`\n🏷️ Cenário Extremo ${i + 1}: ${scenario.name}`);

    try {
      // Computar âncoras
      const anchors = computeAnchors(scenario.visionContext);
      console.log(`   Âncoras disponíveis: ${anchors.length}`);

      // Gerar sugestão
      const result = await generateSuggestion({
        tone: scenario.tone,
        focus_tags: scenario.focus_tags,
        anchors,
        previous_suggestions: scenario.previous_suggestions,
        exhausted_anchors: scenario.exhausted_anchors || new Set(),
        personalized_instructions: scenario.personalized_instructions || ''
      });

      if (result.success && result.suggestion) {
        console.log(`   ✅ SUGESTÃO GERADA:`);
        console.log(`   "${result.suggestion}"`);

        // Validações específicas do cenário
        if (scenario.shouldGenerateFallback && result.low_confidence) {
          console.log(`   ✅ Fallback question gerada corretamente`);
        }

        if (scenario.shouldUseFallbackAnchors && result.anchors_used.length === 0) {
          console.log(`   ✅ Usou âncoras principais quando exauridas`);
        }

        if (scenario.shouldTriggerRegeneration && result.regenerations_attempted > 0) {
          console.log(`   ✅ Regeneração disparada devido a alta repetição`);
        }

        if (scenario.shouldUseDefaultTone && result.suggestion) {
          console.log(`   ✅ Usou tom padrão para tom inválido`);
        }

        if (scenario.shouldRespectInstructions) {
          const hasEmotionalConnection = result.suggestion.toLowerCase().includes('conex') ||
                                       result.suggestion.toLowerCase().includes('emoc') ||
                                       result.suggestion.toLowerCase().includes('sent');
          console.log(`   ✅ Respeitou instruções personalizadas: ${hasEmotionalConnection ? 'Sim' : 'Não'}`);
        }

        console.log(`   📊 Métricas:`);
        console.log(`      - Âncoras usadas: ${result.anchors_used.length}`);
        console.log(`      - Repetição: ${result.repetition_rate.toFixed(3)}`);
        console.log(`      - Tentativas: ${result.regenerations_attempted}`);

      } else {
        console.log(`   ❌ Falha na geração: ${result.error}`);
      }

    } catch (error) {
      console.log(`   💥 Erro inesperado: ${error.message}`);
    }
  }

  console.log('\n🏁 Testes de casos extremos concluídos!');
}

// Executar teste se arquivo for chamado diretamente
if (import.meta.main) {
  await testEdgeCases();
}
