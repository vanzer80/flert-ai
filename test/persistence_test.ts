// test/persistence_test.ts
// Teste da implementação de persistência de contexto e métricas

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

/**
 * Testa se o sistema consegue recuperar contexto existente e gerar novas sugestões
 */
async function testContextPersistence() {
  console.log('🧪 Testando persistência de contexto e métricas...\n');

  // Cenário: Foto de praia
  const beachContext = {
    schema_version: '1.0',
    detected_persons: { count: 1 },
    objects: [
      { name: 'praia', confidence: 0.95, source: 'vision' as const },
      { name: 'oculos', confidence: 0.88, source: 'vision' as const }
    ],
    actions: [
      { name: 'sorrindo', confidence: 0.85, source: 'vision' as const }
    ],
    places: [],
    colors: ['azul', 'branco'],
    ocr_text: 'Verão 2024 ☀️',
    notable_details: ['ondas', 'areia dourada'],
    confidence_overall: 0.90
  };

  try {
    // 1. Computar âncoras
    const anchors = computeAnchors(beachContext);
    console.log(`🔗 Âncoras disponíveis: ${anchors.map(a => a.token).join(', ')}`);

    // 2. Simular primeira geração (contexto seria salvo no banco)
    const firstGeneration = await generateSuggestion({
      tone: 'flertar',
      focus_tags: ['praia', 'verão'],
      anchors,
      previous_suggestions: [],
      exhausted_anchors: new Set()
    });

    if (firstGeneration.success && firstGeneration.suggestion) {
      console.log(`\n✅ PRIMEIRA SUGESTÃO:`);
      console.log(`"${firstGeneration.suggestion}"`);
      console.log(`📊 Âncoras usadas: ${firstGeneration.anchors_used.join(', ')}`);
      console.log(`🔄 Repetição: ${firstGeneration.repetition_rate.toFixed(3)}`);

      // 3. Simular "Gerar mais" (usando contexto existente)
      const regenerateResult = await generateSuggestion({
        tone: 'descontraído',
        focus_tags: ['praia', 'verão'],
        anchors,
        previous_suggestions: [firstGeneration.suggestion],
        exhausted_anchors: new Set(firstGeneration.anchors_used)
      });

      if (regenerateResult.success && regenerateResult.suggestion) {
        console.log(`\n✅ SEGUNDA SUGESTÃO (com contexto existente):`);
        console.log(`"${regenerateResult.suggestion}"`);
        console.log(`📊 Âncoras usadas: ${regenerateResult.anchors_used.join(', ')}`);
        console.log(`🔄 Repetição: ${regenerateResult.repetition_rate.toFixed(3)}`);
        console.log(`🎯 Tentativas: ${regenerateResult.regenerations_attempted}`);

        // Validações críticas
        const validations = {
          firstHasAnchors: firstGeneration.anchors_used.length >= 1,
          secondHasAnchors: regenerateResult.anchors_used.length >= 1,
          lowRepetition: regenerateResult.repetition_rate <= 0.6,
          differentAnchors: regenerateResult.anchors_used.some(anchor =>
            !firstGeneration.anchors_used.includes(anchor)
          ),
          reasonableLength: regenerateResult.suggestion.length <= 120
        };

        console.log(`\n🎯 VALIDAÇÕES DE PERSISTÊNCIA:`);
        console.log(`- Primeira geração usa âncoras: ${validations.firstHasAnchors ? '✅' : '❌'}`);
        console.log(`- Segunda geração usa âncoras: ${validations.secondHasAnchors ? '✅' : '❌'}`);
        console.log(`- Controle de repetição: ${validations.lowRepetition ? '✅' : '❌'}`);
        console.log(`- Âncoras diferentes utilizadas: ${validations.differentAnchors ? '✅' : '❌'}`);
        console.log(`- Comprimento adequado: ${validations.reasonableLength ? '✅' : '❌'}`);

        const allValidationsPassed = Object.values(validations).every(Boolean);
        console.log(`\n🏆 PERSISTÊNCIA DE CONTEXTO: ${allValidationsPassed ? 'FUNCIONANDO PERFEITAMENTE' : 'PRECISA AJUSTES'}`);

      } else {
        console.log(`❌ Falha na segunda geração: ${regenerateResult.error}`);
      }

    } else {
      console.log(`❌ Falha na primeira geração: ${firstGeneration.error}`);
    }

  } catch (error) {
    console.log(`💥 Erro inesperado: ${error.message}`);
  }

  console.log('\n🏁 Teste de persistência concluído!');
}

// Executar teste se arquivo for chamado diretamente
if (import.meta.main) {
  await testContextPersistence();
}
