// Exemplo de uso prático do sistema de geração ancorada

import { generateSuggestion } from '../src/generation/generator.ts';
import { computeAnchors } from '../src/vision/anchors.ts';

// Simulação de contexto real de produção
async function exemploProducao() {
  console.log('🚀 Exemplo de uso em produção do gerador de mensagens ancoradas\n');

  // 1. Contexto visual de uma foto de perfil real
  const realProfileContext = {
    schema_version: '1.0',
    detected_persons: { count: 1 },
    objects: [
      { name: 'guitarra', confidence: 0.89, source: 'vision' as const },
      { name: 'cadeira', confidence: 0.82, source: 'vision' as const }
    ],
    actions: [
      { name: 'tocando', confidence: 0.85, source: 'vision' as const }
    ],
    places: [
      { name: 'quarto', confidence: 0.76, source: 'vision' as const }
    ],
    colors: ['marrom', 'preto', 'madeira'],
    ocr_text: 'Música é vida 🎸 #guitarra #musica',
    notable_details: ['instrumento de qualidade', 'ambiente aconchegante', 'paixão evidente'],
    confidence_overall: 0.87
  };

  // 2. Histórico de conversa (usuário já interagiu antes)
  const conversationHistory = [
    'Ei, vi sua guitarra na foto! Que instrumento incrível!',
    'Obrigada! É minha paixão. Toco desde os 15 anos.',
    'Sério? Que legal! Qual estilo você curte tocar?'
  ];

  // 3. Sugestões anteriores geradas pelo sistema
  const previousSuggestions = [
    'Que guitarra linda! Qual marca é essa?',
    'Adorei seu quarto! Tem uma vibe muito acolhedora',
    'Música é tudo pra mim também! Qual seu artista favorito?'
  ];

  // 4. Âncoras já utilizadas (para evitar repetição)
  const exhaustedAnchors = new Set(['guitarra', 'tocando']);

  try {
    // Computar âncoras atuais
    const anchors = computeAnchors(realProfileContext);
    console.log(`🔗 Âncoras disponíveis: ${anchors.map(a => a.token).join(', ')}`);

    // Gerar nova sugestão ancorada
    const result = await generateSuggestion({
      tone: 'genuíno',
      focus_tags: ['música', 'paixão', 'conexão'],
      anchors,
      previous_suggestions: previousSuggestions,
      exhausted_anchors: exhaustedAnchors,
      personalized_instructions: 'Seja autêntico e mostre interesse real na jornada musical da pessoa',
      max_regenerations: 2
    });

    if (result.success && result.suggestion) {
      console.log(`\n✅ NOVA SUGESTÃO GERADA:`);
      console.log(`"${result.suggestion}"`);

      console.log(`\n📊 ANÁLISE DE QUALIDADE:`);
      console.log(`- Âncoras usadas: ${result.anchors_used.join(', ')} (${result.anchors_used.length} de ${anchors.length})`);
      console.log(`- Taxa de repetição: ${result.repetition_rate.toFixed(3)} (ideal: ≤0.6)`);
      console.log(`- Tentativas: ${result.regenerations_attempted} (ideal: ≤2)`);
      console.log(`- Confiança: ${result.low_confidence ? 'Baixa' : 'Alta'}`);

      // Validações críticas
      const qualityChecks = {
        hasAnchors: result.anchors_used.length >= 1,
        lowRepetition: result.repetition_rate <= 0.6,
        reasonableAttempts: result.regenerations_attempted <= 2,
        highConfidence: !result.low_confidence,
        appropriateLength: result.suggestion.length >= 10 && result.suggestion.length <= 120
      };

      console.log(`\n🎯 VALIDAÇÕES DE QUALIDADE:`);
      console.log(`- Usa âncoras obrigatórias: ${qualityChecks.hasAnchors ? '✅' : '❌'}`);
      console.log(`- Evita repetição excessiva: ${qualityChecks.lowRepetition ? '✅' : '❌'}`);
      console.log(`- Número de tentativas aceitável: ${qualityChecks.reasonableAttempts ? '✅' : '❌'}`);
      console.log(`- Alta confiança: ${qualityChecks.highConfidence ? '✅' : '❌'}`);
      console.log(`- Comprimento adequado: ${qualityChecks.appropriateLength ? '✅' : '❌'}`);

      const allQualityPassed = Object.values(qualityChecks).every(Boolean);
      console.log(`\n🏆 QUALIDADE GERAL: ${allQualityPassed ? 'EXCELENTE' : 'PRECISA MELHORAR'}`);

    } else {
      console.log(`❌ Falha na geração: ${result.error}`);
    }

  } catch (error) {
    console.log(`💥 Erro inesperado: ${error.message}`);
  }

  console.log('\n🏁 Exemplo de produção concluído!');
}

// Executar exemplo se arquivo for chamado diretamente
if (import.meta.main) {
  await exemploProducao();
}
