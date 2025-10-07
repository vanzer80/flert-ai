// test/generator_comprehensive_test.ts
// Teste abrangente do gerador com validações rigorosas

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

/**
 * Cenários de teste realistas para validação completa
 */
const COMPREHENSIVE_SCENARIOS = [
  {
    name: 'Perfil Básico com Nome',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'camisa', confidence: 0.85, source: 'vision' as const }
      ],
      actions: [],
      places: [],
      colors: ['azul'],
      ocr_text: 'Maria',
      notable_details: ['sorriso amigável'],
      confidence_overall: 0.80
    },
    tone: 'flertar',
    focus_tags: ['personalidade'],
    previous_suggestions: [],
    expected_anchors: ['maria', 'camisa', 'azul']
  },
  {
    name: 'Foto de Praia com Conversa',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'oculos', confidence: 0.90, source: 'vision' as const }
      ],
      actions: [
        { name: 'sorrindo', confidence: 0.85, source: 'vision' as const }
      ],
      places: [
        { name: 'praia', confidence: 0.95, source: 'vision' as const }
      ],
      colors: ['azul', 'branco'],
      ocr_text: 'Verão 2024 ☀️',
      notable_details: ['ondas', 'areia dourada'],
      confidence_overall: 0.92
    },
    tone: 'descontraído',
    focus_tags: ['praia', 'verão'],
    previous_suggestions: [
      'Que dia incrível na praia! Qual sua praia favorita?',
      'Adorei essa vibe de verão! O que você gosta de fazer na praia?'
    ],
    expected_anchors: ['praia', 'oculos', 'sorrindo', 'verao']
  },
  {
    name: 'Foto de Livro - Genuíno',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'livro', confidence: 0.88, source: 'vision' as const }
      ],
      actions: [
        { name: 'lendo', confidence: 0.82, source: 'vision' as const }
      ],
      places: [
        { name: 'biblioteca', confidence: 0.75, source: 'vision' as const }
      ],
      colors: ['marrom', 'branco'],
      ocr_text: 'Lendo sobre filosofia 📖',
      notable_details: ['expressão concentrada', 'ambiente acolhedor'],
      confidence_overall: 0.87
    },
    tone: 'genuíno',
    focus_tags: ['leitura', 'intelectual'],
    previous_suggestions: [],
    expected_anchors: ['livro', 'lendo', 'biblioteca', 'filosofia']
  },
  {
    name: 'Foto de Pet - Casual',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'cachorro', confidence: 0.92, source: 'vision' as const },
        { name: 'bola', confidence: 0.78, source: 'vision' as const }
      ],
      actions: [
        { name: 'brincando', confidence: 0.85, source: 'vision' as const }
      ],
      places: [
        { name: 'parque', confidence: 0.80, source: 'vision' as const }
      ],
      colors: ['verde', 'marrom'],
      ocr_text: 'Meu melhor amigo 🐕',
      notable_details: ['golden retriever', 'energia alta'],
      confidence_overall: 0.89
    },
    tone: 'casual',
    focus_tags: ['pet', 'diversão'],
    previous_suggestions: [
      'Que cachorro fofo! Qual a raça dele?',
      'Adorei essa energia! Ele é muito brincalhão?'
    ],
    expected_anchors: ['cachorro', 'bola', 'brincando', 'parque']
  },
  {
    name: 'Foto de Cozinha - Sensual',
    visionContext: {
      schema_version: '1.0',
      detected_persons: { count: 1 },
      objects: [
        { name: 'cafe', confidence: 0.86, source: 'vision' as const }
      ],
      actions: [
        { name: 'cozinhando', confidence: 0.80, source: 'vision' as const }
      ],
      places: [
        { name: 'cozinha', confidence: 0.88, source: 'vision' as const }
      ],
      colors: ['vermelho', 'branco'],
      ocr_text: 'Café da manhã especial ☕',
      notable_details: ['luz matinal', 'ingredientes frescos'],
      confidence_overall: 0.87
    },
    tone: 'sensual',
    focus_tags: ['culinária', 'manhã'],
    previous_suggestions: [
      'Que cozinha acolhedora! O que você gosta de preparar?',
      'Adorei essa iluminação! Qual seu café favorito?'
    ],
    expected_anchors: ['cafe', 'cozinhando', 'cozinha', 'manha']
  }
];

/**
 * Testa métricas críticas do sistema
 */
async function testComprehensiveMetrics() {
  console.log('🧪 Teste abrangente do gerador com métricas críticas...\n');

  const results = {
    totalScenarios: 0,
    successfulGenerations: 0,
    anchorValidationPassed: 0,
    repetitionControlPassed: 0,
    lengthValidationPassed: 0,
    averageAnchorsUsed: 0,
    averageRepetitionRate: 0,
    averageRegenerations: 0
  };

  for (let i = 0; i < COMPREHENSIVE_SCENARIOS.length; i++) {
    const scenario = COMPREHENSIVE_SCENARIOS[i];
    results.totalScenarios++;

    console.log(`\n🏷️ Cenário ${i + 1}: ${scenario.name}`);
    console.log(`   Tom: ${scenario.tone}`);
    console.log(`   Focos: ${scenario.focus_tags.join(', ')}`);
    console.log(`   Sugestões anteriores: ${scenario.previous_suggestions.length}`);

    try {
      // Computar âncoras
      const anchors = computeAnchors(scenario.visionContext);
      console.log(`   Âncoras computadas: ${anchors.length}`);
      console.log(`   Âncoras esperadas: ${scenario.expected_anchors.join(', ')}`);

      // Verificar se âncoras esperadas foram extraídas
      const expectedFound = scenario.expected_anchors.filter(expected =>
        anchors.some(anchor => anchor.token === expected)
      );
      console.log(`   ✅ Âncoras encontradas: ${expectedFound.length}/${scenario.expected_anchors.length}`);

      // Gerar sugestão
      const result = await generateSuggestion({
        tone: scenario.tone,
        focus_tags: scenario.focus_tags,
        anchors,
        previous_suggestions: scenario.previous_suggestions,
        exhausted_anchors: new Set()
      });

      if (result.success && result.suggestion) {
        results.successfulGenerations++;
        console.log(`\n   ✅ SUGESTÃO GERADA:`);
        console.log(`   "${result.suggestion}"`);

        // Métricas detalhadas
        results.averageAnchorsUsed += result.anchors_used.length;
        results.averageRepetitionRate += result.repetition_rate;
        results.averageRegenerations += result.regenerations_attempted;

        // Validações críticas
        const hasAnchors = result.anchors_used.length >= 1;
        const lowRepetition = result.repetition_rate <= 0.6;
        const reasonableLength = result.suggestion.length >= 10 && result.suggestion.length <= 120;

        if (hasAnchors) results.anchorValidationPassed++;
        if (lowRepetition) results.repetitionControlPassed++;
        if (reasonableLength) results.lengthValidationPassed++;

        console.log(`   📊 MÉTRICAS:`);
        console.log(`      - Âncoras usadas: ${result.anchors_used.length} (${result.anchors_used.join(', ')})`);
        console.log(`      - Taxa de repetição: ${result.repetition_rate.toFixed(3)}`);
        console.log(`      - Tentativas: ${result.regenerations_attempted}`);
        console.log(`      - Baixa confiança: ${result.low_confidence ? 'Sim' : 'Não'}`);

        console.log(`   🎯 VALIDAÇÕES:`);
        console.log(`      - Usa âncoras obrigatórias: ${hasAnchors ? '✅' : '❌'}`);
        console.log(`      - Controle de repetição: ${lowRepetition ? '✅' : '❌'}`);
        console.log(`      - Comprimento adequado: ${reasonableLength ? '✅' : '❌'}`);

      } else {
        console.log(`   ❌ Falha na geração: ${result.error}`);
      }

    } catch (error) {
      console.log(`   💥 Erro inesperado: ${error.message}`);
    }
  }

  // Calcular médias
  const totalTests = results.totalScenarios;
  results.averageAnchorsUsed /= totalTests;
  results.averageRepetitionRate /= totalTests;
  results.averageRegenerations /= totalTests;

  // Relatório final
  console.log(`\n📊 RELATÓRIO FINAL DE VALIDAÇÃO`);
  console.log(`========================================`);
  console.log(`Cenários testados: ${results.totalScenarios}`);
  console.log(`Gerações bem-sucedidas: ${results.successfulGenerations}/${results.totalScenarios} (${(results.successfulGenerations/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Validação de âncoras: ${results.anchorValidationPassed}/${results.totalScenarios} (${(results.anchorValidationPassed/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Controle de repetição: ${results.repetitionControlPassed}/${results.totalScenarios} (${(results.repetitionControlPassed/results.totalScenarios*100).toFixed(1)}%)`);
  console.log(`Comprimento adequado: ${results.lengthValidationPassed}/${results.totalScenarios} (${(results.lengthValidationPassed/results.totalScenarios*100).toFixed(1)}%)`);

  console.log(`\n📈 MÉDICAS DE PERFORMANCE:`);
  console.log(`Âncoras médias usadas: ${results.averageAnchorsUsed.toFixed(2)}`);
  console.log(`Taxa de repetição média: ${results.averageRepetitionRate.toFixed(3)}`);
  console.log(`Tentativas médias: ${results.averageRegenerations.toFixed(2)}`);

  // Critérios de aceite finais
  const criteriaMet = {
    successRate: results.successfulGenerations / results.totalScenarios >= 0.8,
    anchorValidation: results.anchorValidationPassed / results.totalScenarios >= 0.9,
    repetitionControl: results.repetitionControlPassed / results.totalScenarios >= 0.8,
    lengthValidation: results.lengthValidationPassed / results.totalScenarios >= 0.9,
    averageAnchors: results.averageAnchorsUsed >= 1.0,
    averageRepetition: results.averageRepetitionRate <= 0.4
  };

  console.log(`\n🎯 CRITÉRIOS DE ACEITE:`);
  console.log(`Taxa de sucesso ≥80%: ${criteriaMet.successRate ? '✅' : '❌'}`);
  console.log(`Validação de âncoras ≥90%: ${criteriaMet.anchorValidation ? '✅' : '❌'}`);
  console.log(`Controle de repetição ≥80%: ${criteriaMet.repetitionControl ? '✅' : '❌'}`);
  console.log(`Comprimento adequado ≥90%: ${criteriaMet.lengthValidation ? '✅' : '❌'}`);
  console.log(`Âncoras médias ≥1.0: ${criteriaMet.averageAnchors ? '✅' : '❌'}`);
  console.log(`Repetição média ≤0.4: ${criteriaMet.averageRepetition ? '✅' : '❌'}`);

  const allCriteriaPassed = Object.values(criteriaMet).every(Boolean);

  console.log(`\n🏆 STATUS FINAL:`);
  console.log(`${allCriteriaPassed ? '✅ PROMPT D VALIDADO COM SUCESSO' : '❌ PROMPT D PRECISA DE AJUSTES'}`);

  console.log('\n🏁 Teste abrangente concluído!');
}

// Executar teste se arquivo for chamado diretamente
if (import.meta.main) {
  await testComprehensiveMetrics();
}
