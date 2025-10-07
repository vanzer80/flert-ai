// test/generator_simple_test.ts
// Teste simples do gerador com um cenário básico

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

/**
 * Teste simples para validar funcionamento básico
 */
async function testSimpleGeneration() {
  console.log('🧪 Teste simples do gerador...\n');

  // Cenário básico: gato na cadeira
  const visionContext = {
    schema_version: '1.0',
    detected_persons: { count: 1 },
    objects: [
      { name: 'gato', confidence: 0.92, source: 'vision' as const },
      { name: 'cadeira', confidence: 0.85, source: 'vision' as const }
    ],
    actions: [
      { name: 'sentado', confidence: 0.78, source: 'vision' as const }
    ],
    places: [
      { name: 'sala', confidence: 0.71, source: 'vision' as const }
    ],
    colors: ['rosa', 'bege'],
    ocr_text: 'OMG! Gatinho fofo na cadeira rosa!',
    notable_details: ['estampa divertida', 'tecido macio'],
    confidence_overall: 0.85
  };

  try {
    // Computar âncoras
    const anchors = computeAnchors(visionContext);
    console.log(`🔗 Âncoras disponíveis: ${anchors.map(a => a.token).join(', ')}`);

    // Gerar sugestão
    const result = await generateSuggestion({
      tone: 'descontraído',
      focus_tags: ['pet', 'diversão'],
      anchors,
      previous_suggestions: [],
      exhausted_anchors: new Set()
    });

    if (result.success && result.suggestion) {
      console.log(`\n✅ SUGESTÃO GERADA:`);
      console.log(`"${result.suggestion}"`);
      console.log(`📊 Âncoras usadas: ${result.anchors_used.join(', ')}`);
      console.log(`🔄 Repetição: ${result.repetition_rate.toFixed(2)}`);
      console.log(`🎯 Tentativas: ${result.regenerations_attempted}`);

    } else {
      console.log(`❌ Falha: ${result.error}`);
    }

  } catch (error) {
    console.log(`💥 Erro: ${error.message}`);
  }

  console.log('\n🏁 Teste simples concluído!');
}

// Executar teste se arquivo for chamado diretamente
if (import.meta.main) {
  await testSimpleGeneration();
}
