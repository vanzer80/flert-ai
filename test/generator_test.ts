// test/generator_test.ts
// Teste do gerador de sugestões com 5 cenários diferentes

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

/**
 * Cenários de teste para validação do gerador
 */
const TEST_SCENARIOS = [
  {
    name: 'Perfil com Pet',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'dog', confidence: 0.92, source: 'vision' as const },
        { name: 'sofa', confidence: 0.85, source: 'vision' as const }
      ],
      actions: [
        { name: 'playing', confidence: 0.78, source: 'vision' as const }
      ],
      places: [
        { name: 'living room', confidence: 0.71, source: 'vision' as const }
      ],
      colors: ['brown', 'white'],
      ocr_text: 'Best dog ever! 🐶',
      notable_details: ['golden retriever', 'couch with pillows'],
      confidence_overall: 0.85
    },
    tone: 'descontraído',
    focus_tags: ['pet', 'diversão'],
    previous_suggestions: []
  },
  {
    name: 'Foto de Praia',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'sunglasses', confidence: 0.88, source: 'vision' as const }
      ],
      actions: [
        { name: 'smiling', confidence: 0.82, source: 'vision' as const }
      ],
      places: [
        { name: 'beach', confidence: 0.95, source: 'vision' as const }
      ],
      colors: ['blue', 'yellow'],
      ocr_text: 'Summer vibes ☀️',
      notable_details: ['ocean waves', 'sand'],
      confidence_overall: 0.90
    },
    tone: 'flertar',
    focus_tags: ['praia', 'verão'],
    previous_suggestions: []
  },
  {
    name: 'Foto de Livro',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'book', confidence: 0.90, source: 'vision' as const }
      ],
      actions: [
        { name: 'reading', confidence: 0.85, source: 'vision' as const }
      ],
      places: [
        { name: 'library', confidence: 0.75, source: 'vision' as const }
      ],
      colors: ['brown', 'white'],
      ocr_text: 'Currently reading 📚',
      notable_details: ['coffee cup', 'cozy atmosphere'],
      confidence_overall: 0.88
    },
    tone: 'genuíno',
    focus_tags: ['leitura', 'intelectual'],
    previous_suggestions: []
  },
  {
    name: 'Foto de Montanha',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'backpack', confidence: 0.87, source: 'vision' as const }
      ],
      actions: [
        { name: 'hiking', confidence: 0.83, source: 'vision' as const }
      ],
      places: [
        { name: 'mountain', confidence: 0.92, source: 'vision' as const }
      ],
      colors: ['green', 'blue'],
      ocr_text: 'Adventure awaits ⛰️',
      notable_details: ['trail path', 'forest'],
      confidence_overall: 0.89
    },
    tone: 'casual',
    focus_tags: ['aventura', 'natureza'],
    previous_suggestions: []
  },
  {
    name: 'Foto de Cozinha',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'coffee', confidence: 0.86, source: 'vision' as const }
      ],
      actions: [
        { name: 'cooking', confidence: 0.80, source: 'vision' as const }
      ],
      places: [
        { name: 'kitchen', confidence: 0.88, source: 'vision' as const }
      ],
      colors: ['red', 'white'],
      ocr_text: 'Morning coffee ☕',
      notable_details: ['fresh ingredients', 'warm lighting'],
      confidence_overall: 0.87
    },
    tone: 'sensual',
    focus_tags: ['culinária', 'manhã'],
    previous_suggestions: []
  }
];

/**
 * Testa o gerador com todos os cenários
 */
async function testGenerator() {
  console.log('🧪 Testando gerador de sugestões com 5 cenários...\n');

  for (let i = 0; i < TEST_SCENARIOS.length; i++) {
    const scenario = TEST_SCENARIOS[i];
    console.log(`\n🏷️ Cenário ${i + 1}: ${scenario.name}`);
    console.log(`   Tom: ${scenario.tone}`);
    console.log(`   Focos: ${scenario.focus_tags.join(', ')}`);

    try {
      // Computar âncoras
      const anchors = computeAnchors(scenario.visionContext);
      console.log(`   Âncoras disponíveis: ${anchors.map(a => a.token).join(', ')}`);

      // Gerar sugestão
      const result = await generateSuggestion({
        tone: scenario.tone,
        focus_tags: scenario.focus_tags,
        anchors,
        previous_suggestions: scenario.previous_suggestions,
        exhausted_anchors: new Set()
      });

      if (result.success && result.suggestion) {
        console.log(`\n   ✅ SUGESTÃO GERADA:`);
        console.log(`   "${result.suggestion}"`);
        console.log(`   📊 Métricas:`);
        console.log(`      - Âncoras usadas: ${result.anchors_used.length} (${result.anchors_used.join(', ')})`);
        console.log(`      - Taxa de repetição: ${result.repetition_rate.toFixed(2)}`);
        console.log(`      - Tentativas: ${result.regenerations_attempted}`);
        console.log(`      - Baixa confiança: ${result.low_confidence ? 'Sim' : 'Não'}`);

        // Validações específicas
        const hasAnchors = result.anchors_used.length >= 1;
        const lowRepetition = result.repetition_rate <= 0.6;
        const reasonableLength = result.suggestion.length <= 120;

        console.log(`   🎯 Validações:`);
        console.log(`      - Usa âncoras: ${hasAnchors ? '✅' : '❌'}`);
        console.log(`      - Repetição baixa: ${lowRepetition ? '✅' : '❌'}`);
        console.log(`      - Tamanho adequado: ${reasonableLength ? '✅' : '❌'}`);

      } else {
        console.log(`   ❌ Falha na geração: ${result.error}`);
      }

    } catch (error) {
      console.log(`   💥 Erro inesperado: ${error.message}`);
    }
  }

  console.log('\n🏁 Testes de geração concluídos!');
}

// Executar testes se arquivo for chamado diretamente
if (import.meta.main) {
  await testGenerator();
}
