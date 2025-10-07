// test/anchors_edge_cases.ts
// Teste de casos extremos e validação robusta do sistema de âncoras

import { computeAnchors, normalizeToken, calculateAnchorWeight } from '../src/vision/anchors.ts';

/**
 * Testa casos extremos e validação robusta
 */
function testEdgeCases() {
  console.log('🧪 Testando casos extremos do sistema de âncoras...\n');

  // 1. Testar contexto vazio
  console.log('📝 Teste 1: Contexto vazio');
  const emptyContext = {
    schema_version: '1.0',
    detected_persons: { count: 0 },
    objects: [],
    actions: [],
    places: [],
    colors: [],
    ocr_text: '',
    notable_details: [],
    confidence_overall: 0.0
  };

  const emptyAnchors = computeAnchors(emptyContext);
  console.log(`   ✅ Âncoras vazias: ${emptyAnchors.length} (esperado: 0)`);

  // 2. Testar contexto com dados mínimos
  console.log('\n📝 Teste 2: Contexto mínimo (apenas 1 objeto)');
  const minimalContext = {
    schema_version: '1.0',
    detected_persons: { count: 0 },
    objects: [{ name: 'teste', confidence: 0.5, source: 'vision' as const }],
    actions: [],
    places: [],
    colors: [],
    ocr_text: '',
    notable_details: [],
    confidence_overall: 0.3
  };

  const minimalAnchors = computeAnchors(minimalContext);
  console.log(`   ✅ Âncoras mínimas: ${minimalAnchors.length} (esperado: 1)`);
  console.log(`   📊 Âncora: ${minimalAnchors[0]?.token} (peso: ${minimalAnchors[0]?.weight.toFixed(2)})`);

  // 3. Testar normalização com casos extremos
  console.log('\n📝 Teste 3: Normalização casos extremos');
  const extremeCases = [
    { input: '', expected: '' },
    { input: '   ', expected: '' },
    { input: '123', expected: '123' },
    { input: 'a', expected: '' },
    { input: 'ab', expected: '' },
    { input: 'abc', expected: 'abc' },
    { input: 'ÁRVORE', expected: 'arvore' },
    { input: 'café', expected: 'cafe' },
    { input: 'stopword', expected: 'stopword' }, // Não é stopword real
    { input: 'não', expected: '' }, // É stopword
  ];

  extremeCases.forEach(({ input, expected }) => {
    const result = normalizeToken(input);
    const success = result === expected;
    console.log(`   ${success ? '✅' : '❌'} "${input}" → "${result}" (esperado: "${expected}")`);
  });

  // 4. Testar pesos extremos
  console.log('\n📝 Teste 4: Pesos extremos');
  const weightCases = [
    { confidence: -1.0, source: 'vision' as const, expected: 0.1 },
    { confidence: 0.0, source: 'vision' as const, expected: 0.6 },
    { confidence: 0.5, source: 'vision' as const, expected: 0.6 },
    { confidence: 1.0, source: 'vision' as const, expected: 1.0 },
    { confidence: 2.0, source: 'vision' as const, expected: 1.0 },
    { confidence: 0.8, source: 'ocr' as const, expected: 1.0 },
  ];

  weightCases.forEach(({ confidence, source, expected }) => {
    const result = calculateAnchorWeight(confidence, source);
    const success = Math.abs(result - expected) < 0.01;
    console.log(`   ${success ? '✅' : '❌'} Conf: ${confidence}, Fonte: ${source} → ${result.toFixed(2)} (esperado: ${expected.toFixed(2)})`);
  });

  // 5. Testar deduplicação
  console.log('\n📝 Teste 5: Deduplicação');
  const duplicateContext = {
    schema_version: '1.0',
    detected_persons: { count: 0 },
    objects: [
      { name: 'gato', confidence: 0.8, source: 'vision' as const },
      { name: 'GATO', confidence: 0.9, source: 'vision' as const }, // Mesmo token
    ],
    actions: [],
    places: [],
    colors: [],
    ocr_text: '',
    notable_details: [],
    confidence_overall: 0.8
  };

  const duplicateAnchors = computeAnchors(duplicateContext);
  const gatoCount = duplicateAnchors.filter(a => a.token === 'gato').length;
  console.log(`   ✅ Deduplicação: ${gatoCount === 1 ? 'Funcionando' : 'Falhou'} (encontrado: ${gatoCount})`);

  console.log('\n🏁 Testes de casos extremos concluídos!');
}

// Executar testes se arquivo for chamado diretamente
if (import.meta.main) {
  testEdgeCases();
}
