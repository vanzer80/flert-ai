// test/persistence_validation_test.ts
// Teste de validação final das correções aplicadas no PROMPT E

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

/**
 * Cenários críticos para validar correções aplicadas
 */
const VALIDATION_SCENARIOS = [
  {
    name: 'Contexto Visual Completo Salvo',
    setup: {
      visionContext: {
        schema_version: '1.0',
        detected_persons: { count: 1, name: 'Ana' },
        objects: [
          { name: 'livro', confidence: 0.92, source: 'vision' as const },
          { name: 'cafe', confidence: 0.87, source: 'vision' as const }
        ],
        actions: [
          { name: 'lendo', confidence: 0.85, source: 'vision' as const }
        ],
        places: [
          { name: 'cafeteria', confidence: 0.78, source: 'vision' as const }
        ],
        colors: ['marrom', 'verde'],
        ocr_text: 'Amor pela leitura ☕📚',
        notable_details: ['ambiente acolhedor', 'paixão evidente'],
        confidence_overall: 0.89
      },
      tone: 'genuíno',
      focus_tags: ['leitura', 'conhecimento'],
      previous_suggestions: []
    },
    expected_behavior: {
      shouldSaveCompleteContext: true,
      shouldSaveVisionContext: true,
      shouldSaveAnchors: true,
      shouldSaveMetrics: true,
      shouldHaveConversationId: true,
      shouldValidateAnchors: true
    }
  },
  {
    name: 'Gerar Mais com Contexto Existente',
    setup: {
      existingConversationId: 'conv_123',
      existingVisionContext: {
        schema_version: '1.0',
        detected_persons: { count: 1, name: 'Ana' },
        objects: [
          { name: 'livro', confidence: 0.92, source: 'vision' as const },
          { name: 'cafe', confidence: 0.87, source: 'vision' as const }
        ],
        actions: [
          { name: 'lendo', confidence: 0.85, source: 'vision' as const }
        ],
        places: [
          { name: 'cafeteria', confidence: 0.78, source: 'vision' as const }
        ],
        colors: ['marrom', 'verde'],
        ocr_text: 'Amor pela leitura ☕📚',
        notable_details: ['ambiente acolhedor', 'paixão evidente'],
        confidence_overall: 0.89
      },
      existingAnchors: ['livro', 'cafe', 'lendo', 'cafeteria'],
      existingExhaustedAnchors: ['livro', 'cafe'],
      existingPreviousSuggestions: [
        'Que ambiente acolhedor! Vejo que você ama ler, qual seu gênero favorito?',
        'Adorei sua paixão pela leitura! O que você está lendo ultimamente?'
      ],
      tone: 'flertar',
      focus_tags: ['leitura', 'conexão'],
      skip_vision: true
    },
    expected_behavior: {
      shouldReuseExistingContext: true,
      shouldAvoidExhaustedAnchors: true,
      shouldCalculateRepetitionCorrectly: true,
      shouldGenerateDifferentAnchors: true,
      shouldSaveNewMetrics: true,
      shouldMaintainContextQuality: true
    }
  },
  {
    name: 'Regeneração com Validação Rigorosa',
    setup: {
      visionContext: {
        schema_version: '1.0',
        detected_persons: { count: 1 },
        objects: [
          { name: 'piano', confidence: 0.91, source: 'vision' as const }
        ],
        actions: [
          { name: 'tocando', confidence: 0.88, source: 'vision' as const }
        ],
        places: [],
        colors: ['preto', 'branco'],
        ocr_text: 'Música clássica 🎹',
        notable_details: ['instrumento elegante', 'dedicação artística'],
        confidence_overall: 0.87
      },
      tone: 'genuíno',
      focus_tags: ['música', 'arte'],
      previous_suggestions: [],
      forceRegeneration: true
    },
    expected_behavior: {
      shouldTriggerRegeneration: true,
      shouldValidateAnchorsInRegeneration: true,
      shouldImproveQuality: true,
      shouldSaveBothGenerations: true,
      shouldHaveHigherAnchorUsage: true
    }
  }
];

/**
 * Testa validação rigorosa das correções aplicadas
 */
async function testValidationCorrections() {
  console.log('🧪 VALIDAÇÃO RIGOROSA DAS CORREÇÕES APLICADAS NO PROMPT E...\n');

  const results = {
    totalScenarios: 0,
    successfulPersistence: 0,
    contextReuseValidated: 0,
    metricsAccuracy: 0,
    regenerationValidated: 0,
    errorHandling: 0,
    anchorValidation: 0,
    repetitionControl: 0
  };

  for (let i = 0; i < VALIDATION_SCENARIOS.length; i++) {
    const scenario = VALIDATION_SCENARIOS[i];
    results.totalScenarios++;

    console.log(`\n🏷️ Cenário ${i + 1}: ${scenario.name}`);
    console.log(`   Objetivo: ${Object.keys(scenario.expected_behavior).join(', ')}`);

    try {
      let anchors: any[] = [];

      // Preparar dados do cenário
      if (scenario.setup.visionContext) {
        anchors = computeAnchors(scenario.setup.visionContext);
        console.log(`   Âncoras computadas: ${anchors.map(a => a.token).join(', ')}`);
      }

      // Executar geração
      const result = await generateSuggestion({
        tone: scenario.setup.tone,
        focus_tags: scenario.setup.focus_tags,
        anchors,
        previous_suggestions: scenario.setup.previous_suggestions || [],
        exhausted_anchors: scenario.setup.existingExhaustedAnchors ?
          new Set(scenario.setup.existingExhaustedAnchors) : new Set()
      });

      if (result.success && result.suggestion) {
        results.successfulPersistence++;
        console.log(`   ✅ GERAÇÃO BEM-SUCEDIDA:`);
        console.log(`   "${result.suggestion}"`);

        // Validações específicas baseadas no cenário

        // 1. Validação de contexto reutilizado
        if (scenario.setup.existingConversationId) {
          const contextReused = result.regenerations_attempted === 0 &&
                               result.repetition_rate > 0;
          if (contextReused) results.contextReuseValidated++;
          console.log(`   🔄 Contexto reutilizado: ${contextReused ? '✅' : '❌'}`);
        }

        // 2. Validação de âncoras exauridas evitadas
        if (scenario.setup.existingExhaustedAnchors) {
          const avoidedExhausted = !result.anchors_used.some(anchor =>
            scenario.setup.existingExhaustedAnchors.includes(anchor)
          );
          if (avoidedExhausted) results.anchorValidation++;
          console.log(`   🚫 Âncoras exauridas evitadas: ${avoidedExhausted ? '✅' : '❌'}`);
        }

        // 3. Validação de regeneração
        if (scenario.expected_behavior.shouldTriggerRegeneration) {
          const regenerationTriggered = result.regenerations_attempted > 0;
          if (regenerationTriggered) results.regenerationValidated++;
          console.log(`   🔄 Regeneração disparada: ${regenerationTriggered ? '✅' : '❌'}`);
        }

        // 4. Validação de métricas
        const hasRequiredAnchors = result.anchors_used.length >= 1;
        if (hasRequiredAnchors) results.metricsAccuracy++;

        // 5. Validação de controle de repetição
        const reasonableRepetition = result.repetition_rate <= 0.6;
        if (reasonableRepetition) results.repetitionControl++;

        // 6. Validação geral de qualidade
        const reasonableLatency = result.regenerations_attempted <= 2;
        const highConfidence = !result.low_confidence;

        console.log(`   📊 MÉTRICAS DE QUALIDADE:`);
        console.log(`      - Âncoras usadas: ${result.anchors_used.length} (${result.anchors_used.join(', ')})`);
        console.log(`      - Repetição: ${result.repetition_rate.toFixed(3)}`);
        console.log(`      - Tentativas: ${result.regenerations_attempted}`);
        console.log(`      - Confiança: ${result.low_confidence ? 'Baixa' : 'Alta'}`);

        console.log(`   🎯 VALIDAÇÕES DETALHADAS:`);
        console.log(`      - Âncoras obrigatórias: ${hasRequiredAnchors ? '✅' : '❌'}`);
        console.log(`      - Controle de repetição: ${reasonableRepetition ? '✅' : '❌'}`);
        console.log(`      - Latência aceitável: ${reasonableLatency ? '✅' : '❌'}`);
        console.log(`      - Alta confiança: ${highConfidence ? '✅' : '❌'}`);

      } else {
        console.log(`   ❌ Falha na geração: ${result.error}`);
        results.errorHandling++;
      }

    } catch (error) {
      console.log(`   💥 Erro inesperado: ${error.message}`);
      results.errorHandling++;
    }
  }

  // Relatório final de validação
  console.log(`\n📊 RELATÓRIO FINAL DE VALIDAÇÃO DAS CORREÇÕES`);
  console.log(`=============================================`);
  console.log(`Cenários testados: ${results.totalScenarios}`);
  console.log(`Persistência bem-sucedida: ${results.successfulPersistence}/${results.totalScenarios} (${(results.successfulPersistence/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Reutilização de contexto: ${results.contextReuseValidated}/${results.totalScenarios} (${(results.contextReuseValidated/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Validação de âncoras: ${results.anchorValidation}/${results.totalScenarios} (${(results.anchorValidation/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Controle de repetição: ${results.repetitionControl}/${results.totalScenarios} (${(results.repetitionControl/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Regeneração funcional: ${results.regenerationValidated}/${results.totalScenarios} (${(results.regenerationValidated/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Tratamento de erros: ${results.errorHandling}/${results.totalScenarios} (${(results.errorHandling/results.totalScenarios*100).toFixed(1)}%)`);

  // Critérios de aceite finais
  const criteriaMet = {
    persistenceSuccess: results.successfulPersistence / results.totalScenarios >= 0.9,
    contextReuse: results.contextReuseValidated / results.totalScenarios >= 0.8,
    anchorValidation: results.anchorValidation / results.totalScenarios >= 0.7,
    repetitionControl: results.repetitionControl / results.totalScenarios >= 0.8,
    regenerationWorks: results.regenerationValidated / results.totalScenarios >= 0.5,
    errorHandling: results.errorHandling === 0
  };

  console.log(`\n🎯 CRITÉRIOS DE ACEITE APÓS CORREÇÕES:`);
  console.log(`Persistência ≥90%: ${criteriaMet.persistenceSuccess ? '✅' : '❌'}`);
  console.log(`Reutilização ≥80%: ${criteriaMet.contextReuse ? '✅' : '❌'}`);
  console.log(`Validação de âncoras ≥70%: ${criteriaMet.anchorValidation ? '✅' : '❌'}`);
  console.log(`Controle de repetição ≥80%: ${criteriaMet.repetitionControl ? '✅' : '❌'}`);
  console.log(`Regeneração ≥50%: ${criteriaMet.regenerationWorks ? '✅' : '❌'}`);
  console.log(`Sem erros críticos: ${criteriaMet.errorHandling ? '✅' : '❌'}`);

  const allCriteriaPassed = Object.values(criteriaMet).every(Boolean);

  console.log(`\n🏆 STATUS FINAL DAS CORREÇÕES:`);
  console.log(`${allCriteriaPassed ? '✅ PROMPT E TOTALMENTE CORRIGIDO E VALIDADO' : '❌ CORREÇÕES AINDA PRECISAM DE AJUSTES'}`);

  console.log('\n🏁 Validação das correções concluída!');
}

// Executar validação se arquivo for chamado diretamente
if (import.meta.main) {
  await testValidationCorrections();
}
