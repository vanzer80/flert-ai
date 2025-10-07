// Exemplo prático de uso do gerador

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

// Exemplo de uso no contexto real da aplicação
async function exemploUsoPratico() {
  // 1. Contexto visual extraído
  const visionContext = {
    schema_version: '1.0',
    detected_persons: { count: 1 },
    objects: [
      { name: 'gato', confidence: 0.92, source: 'vision' as const },
      { name: 'cadeira', confidence: 0.85, source: 'vision' as const }
    ],
    actions: [{ name: 'sentado', confidence: 0.78, source: 'vision' as const }],
    places: [{ name: 'sala', confidence: 0.71, source: 'vision' as const }],
    colors: ['rosa', 'bege'],
    ocr_text: 'OMG! Gatinho fofo na cadeira rosa!',
    notable_details: ['estampa divertida', 'tecido macio'],
    confidence_overall: 0.85
  };

  // 2. Computar âncoras
  const anchors = computeAnchors(visionContext);

  // 3. Preparar entrada para geração
  const genInput: GenInput = {
    tone: 'descontraído',
    focus_tags: ['pet', 'diversão'],
    anchors,
    previous_suggestions: [
      'Que gato mais fofo! Qual a raça dele?',
      'Adorei essa cadeira rosa! Combina com o gato?'
    ],
    exhausted_anchors: new Set(['gato']), // Evitar repetir "gato"
    personalized_instructions: 'Seja leve e divertido, pergunte sobre brincadeiras'
  };

  // 4. Gerar sugestão
  const result = await generateSuggestion(genInput);

  if (result.success && result.suggestion) {
    console.log('✅ Sugestão gerada:', result.suggestion);
    console.log('📊 Âncoras usadas:', result.anchors_used);
    console.log('🔄 Repetição:', result.repetition_rate.toFixed(2));
    console.log('🎯 Tentativas:', result.regenerations_attempted);
  } else {
    console.log('❌ Falha:', result.error);
  }
}

// Exemplo de uso: await exemploUsoPratico();
