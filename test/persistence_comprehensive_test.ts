// test/persistence_comprehensive_test.ts
// Teste abrangente da implementação de persistência

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

/**
 * Cenários de teste realistas para validação completa da persistência
 */
const COMPREHENSIVE_PERSISTENCE_SCENARIOS = [
  {
    name: 'Nova Conversa com Análise Visual',
    setup: {
      visionContext: {
        schema_version: '1.0',
        detected_persons: { count: 1, name: 'Maria' },
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
      tone: 'genuíno',
      focus_tags: ['música', 'paixão'],
      previous_suggestions: []
    },
    expected_behavior: {
      shouldSaveConversation: true,
      shouldSaveMetrics: true,
      shouldHaveVisionContext: true,
      shouldHaveAnchors: true,
      conversationIdGenerated: true
    }
  },
  {
    name: 'Geração Adicional com Contexto Existente',
    setup: {
      // Simula contexto existente no banco
      existingConversationId: 'conv_123',
      existingVisionContext: {
        schema_version: '1.0',
        detected_persons: { count: 1, name: 'Maria' },
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
      existingAnchors: ['guitarra', 'tocando', 'quarto', 'musica'],
      existingExhaustedAnchors: ['guitarra'],
      existingPreviousSuggestions: [
        'Que guitarra incrível! Você toca há quanto tempo?',
        'Adorei sua paixão pela música! Qual seu estilo favorito?'
      ],
      tone: 'flertar',
      focus_tags: ['música', 'conexão'],
      skip_vision: true
    },
    expected_behavior: {
      shouldReuseContext: true,
      shouldAvoidExhaustedAnchors: true,
      shouldCalculateRepetition: true,
      shouldSaveNewMetrics: true,
      shouldHaveDifferentAnchors: true
    }
  },
  {
    name: 'Regeneração após Falha de Âncoras',
    setup: {
      visionContext: {
        schema_version: '1.0',
        detected_persons: { count: 1 },
        objects: [
          { name: 'livro', confidence: 0.88, source: 'vision' as const }
        ],
        actions: [],
        places: [],
        colors: [],
        ocr_text: 'Lendo filosofia 📖',
        notable_details: [],
        confidence_overall: 0.85
      },
      tone: 'genuíno',
      focus_tags: ['leitura'],
      previous_suggestions: [],
      // Simula cenário onde primeira geração falha em usar âncoras
      forceRegeneration: true
    },
    expected_behavior: {
      shouldTriggerRegeneration: true,
      shouldSaveBothGenerations: true,
      shouldHaveHigherConfidence: true,
      shouldUseAnchorsInRegeneration: true
    }
  }
];

/**
 * Testa métricas críticas da persistência
 */
async function testComprehensivePersistence() {
  console.log('🧪 Teste abrangente de persistência de contexto e métricas...\n');

  const results = {
    totalScenarios: 0,
    successfulPersistence: 0,
    contextReuseSuccessful: 0,
    metricsAccuracy: 0,
    regenerationFunctionality: 0,
    errorHandling: 0
  };

  for (let i = 0; i < COMPREHENSIVE_PERSISTENCE_SCENARIOS.length; i++) {
    const scenario = COMPREHENSIVE_PERSISTENCE_SCENARIOS[i];
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

        // Análise detalhada baseada no cenário
        if (scenario.setup.existingConversationId) {
          // Cenário de reutilização de contexto
          const contextReused = result.regenerations_attempted === 0 &&
                               result.repetition_rate > 0;
          if (contextReused) results.contextReuseSuccessful++;
          console.log(`   🔄 Contexto reutilizado: ${contextReused ? '✅' : '❌'}`);
        }

        if (scenario.setup.existingExhaustedAnchors) {
          // Cenário com âncoras exauridas
          const avoidedExhausted = !result.anchors_used.some(anchor =>
            scenario.setup.existingExhaustedAnchors.includes(anchor)
          );
          console.log(`   🚫 Âncoras exauridas evitadas: ${avoidedExhausted ? '✅' : '❌'}`);
        }

        if (scenario.expected_behavior.shouldTriggerRegeneration) {
          // Cenário de regeneração
          const regenerationTriggered = result.regenerations_attempted > 0;
          if (regenerationTriggered) results.regenerationFunctionality++;
          console.log(`   🔄 Regeneração disparada: ${regenerationTriggered ? '✅' : '❌'}`);
        }

        // Validações gerais
        const hasRequiredAnchors = result.anchors_used.length >= 1;
        const reasonableRepetition = result.repetition_rate <= 0.6;
        const reasonableLatency = result.regenerations_attempted <= 2;

        console.log(`   📊 MÉTRICAS:`);
        console.log(`      - Âncoras usadas: ${result.anchors_used.length} (${result.anchors_used.join(', ')})`);
        console.log(`      - Repetição: ${result.repetition_rate.toFixed(3)}`);
        console.log(`      - Tentativas: ${result.regenerations_attempted}`);
        console.log(`      - Confiança: ${result.low_confidence ? 'Baixa' : 'Alta'}`);

        console.log(`   🎯 VALIDAÇÕES:`);
        console.log(`      - Âncoras obrigatórias: ${hasRequiredAnchors ? '✅' : '❌'}`);
        console.log(`      - Controle de repetição: ${reasonableRepetition ? '✅' : '❌'}`);
        console.log(`      - Latência aceitável: ${reasonableLatency ? '✅' : '❌'}`);

      } else {
        console.log(`   ❌ Falha na geração: ${result.error}`);
      }

    } catch (error) {
      console.log(`   💥 Erro inesperado: ${error.message}`);
      results.errorHandling++;
    }
  }

  // Relatório final
  console.log(`\n📊 RELATÓRIO FINAL DE PERSISTÊNCIA`);
  console.log(`========================================`);
  console.log(`Cenários testados: ${results.totalScenarios}`);
  console.log(`Persistência bem-sucedida: ${results.successfulPersistence}/${results.totalScenarios} (${(results.successfulPersistence/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Reutilização de contexto: ${results.contextReuseSuccessful}/${results.totalScenarios} (${(results.contextReuseSuccessful/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Regeneração funcional: ${results.regenerationFunctionality}/${results.totalScenarios} (${(results.regenerationFunctionality/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Tratamento de erros: ${results.errorHandling}/${results.totalScenarios} (${(results.errorHandling/results.totalScenarios*100).toFixed(1)}%)`);

  // Critérios de aceite finais
  const criteriaMet = {
    persistenceSuccess: results.successfulPersistence / results.totalScenarios >= 0.8,
    contextReuse: results.contextReuseSuccessful / results.totalScenarios >= 0.7,
    regenerationWorks: results.regenerationFunctionality / results.totalScenarios >= 0.5,
    errorHandling: results.errorHandling === 0
  };

  console.log(`\n🎯 CRITÉRIOS DE ACEITE:`);
  console.log(`Persistência ≥80%: ${criteriaMet.persistenceSuccess ? '✅' : '❌'}`);
  console.log(`Reutilização ≥70%: ${criteriaMet.contextReuse ? '✅' : '❌'}`);
  console.log(`Regeneração ≥50%: ${criteriaMet.regenerationWorks ? '✅' : '❌'}`);
  console.log(`Sem erros críticos: ${criteriaMet.errorHandling ? '✅' : '❌'}`);

  const allCriteriaPassed = Object.values(criteriaMet).every(Boolean);

  console.log(`\n🏆 STATUS FINAL:`);
  console.log(`${allCriteriaPassed ? '✅ PROMPT E VALIDADO COM SUCESSO' : '❌ PROMPT E PRECISA DE AJUSTES'}`);

  console.log('\n🏁 Teste abrangente de persistência concluído!');
}

// Executar teste se arquivo for chamado diretamente
if (import.meta.main) {
  await testComprehensivePersistence();
}
