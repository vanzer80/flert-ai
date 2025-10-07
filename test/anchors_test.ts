// test/anchors_test.ts
// Teste específico para o sistema de âncoras

import { computeAnchors, normalizeToken, calculateAnchorWeight } from '../src/vision/anchors.ts';

// Exemplo de contexto visual baseado no exemplo do gato na cadeira
const mockVisionContext = {
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
  colors: ['rosa', 'bege', 'marrom'],
  ocr_text: 'OMG! Gatinho fofo na cadeira rosa!',
  notable_details: ['cadeira rosa', 'tecido com dinossauros', 'estampa divertida'],
  confidence_overall: 0.85
};

/**
 * Testa o sistema de âncoras com dados mockados
 */
function testAnchorsSystem() {
  console.log('🧪 Testando sistema de âncoras...\n');

  // 1. Testar normalização de tokens
  console.log('📝 Testando normalização de tokens:');
  const testTokens = ['Gato', 'CADEIRA rosa', 'dinossauros', 'OMG!', 'stopword'];
  testTokens.forEach(token => {
    const normalized = normalizeToken(token);
    console.log(`   "${token}" → "${normalized}"`);
  });

  console.log('\n🎯 Testando cálculo de pesos:');
  const testWeights = [
    { confidence: 0.9, source: 'vision' as const },
    { confidence: 0.8, source: 'ocr' as const },
    { confidence: 0.5, source: 'vision' as const }
  ];
  testWeights.forEach(({ confidence, source }) => {
    const weight = calculateAnchorWeight(confidence, source);
    console.log(`   Confiança: ${confidence}, Fonte: ${source} → Peso: ${weight.toFixed(2)}`);
  });

  // 2. Testar computação de âncoras
  console.log('\n🔗 Computando âncoras do contexto visual:');
  const anchors = computeAnchors(mockVisionContext);

  console.log(`\n📊 Resultado:`);
  console.log(`   - Total de âncoras: ${anchors.length}`);
  console.log(`   - Top 5 âncoras:`);

  anchors.slice(0, 5).forEach((anchor, index) => {
    console.log(`     ${index + 1}. "${anchor.token}" (peso: ${anchor.weight.toFixed(2)}, fonte: ${anchor.source}, categoria: ${anchor.category})`);
  });

  // 3. Verificar se inclui os elementos esperados do exemplo
  const expectedTokens = ['gato', 'cadeira', 'rosa', 'dinossauro', 'omg'];
  const foundTokens = anchors.map(a => a.token);

  console.log(`\n✅ Verificação do exemplo "gato na cadeira":`);
  expectedTokens.forEach(token => {
    const found = foundTokens.includes(token);
    console.log(`   ${found ? '✅' : '❌'} "${token}" ${found ? 'encontrado' : 'não encontrado'}`);
  });

  // 4. Verificar ausência de stopwords
  const stopwords = ['que', 'com', 'para', 'uma', 'como'];
  const hasStopwords = anchors.some(anchor => stopwords.includes(anchor.token));

  console.log(`\n🚫 Verificação de stopwords:`);
  console.log(`   ${hasStopwords ? '❌' : '✅'} ${hasStopwords ? 'Stopwords encontradas' : 'Sem stopwords (correto)'}`);

  // 5. Verificar ausência de tokens curtos
  const shortTokens = anchors.filter(anchor => anchor.token.length < 3);
  console.log(`\n📏 Verificação de tokens curtos:`);
  console.log(`   ${shortTokens.length === 0 ? '✅' : '❌'} ${shortTokens.length === 0 ? 'Sem tokens curtos' : `${shortTokens.length} tokens curtos encontrados`}`);

  console.log('\n🏁 Testes concluídos!');
}

// Executar testes se arquivo for chamado diretamente
if (import.meta.main) {
  testAnchorsSystem();
}
