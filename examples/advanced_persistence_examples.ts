// Exemplo de uso avançado do sistema de persistência

/**
 * EXEMPLO 1: Nova conversa com análise completa
 */
const newConversationFlow = async () => {
  console.log('🔄 FLUXO: Nova conversa com análise visual completa');

  // 1. Análise inicial - salva contexto completo
  const initialAnalysis = {
    image_base64: 'base64_image_data',
    user_id: 'user_123',
    tone: 'descontraído',
    focus_tags: ['pet', 'diversão']
  };

  // Sistema automaticamente:
  // ✅ Extrai contexto visual detalhado
  // ✅ Computa âncoras estruturadas
  // ✅ Salva em conversations.analysis_result
  // ✅ Cria entrada em generation_metrics
  // ✅ Retorna conversation_id para uso futuro

  return {
    conversation_id: 'conv_456',
    vision_context_saved: true,
    anchors_computed: ['cachorro', 'bola', 'brincando'],
    metrics_recorded: true
  };
};

/**
 * EXEMPLO 2: "Gerar mais" com reutilização inteligente
 */
const regenerateFlow = async (conversationId: string) => {
  console.log('🔄 FLUXO: Geração adicional reutilizando contexto');

  // 2. Geração adicional - reutiliza contexto existente
  const regenerateRequest = {
    conversation_id: conversationId,
    user_id: 'user_123',
    tone: 'flertar',              // Pode mudar tom
    focus_tags: ['conexão'],      // Pode ajustar foco
    skip_vision: true             // Não re-analisa imagem
  };

  // Sistema automaticamente:
  // ✅ Recupera contexto visual do banco
  // ✅ Usa âncoras existentes
  // ✅ Evita âncoras exauridas
  // ✅ Calcula repetição com sugestões anteriores
  // ✅ Salva novas métricas de qualidade

  return {
    context_reused: true,
    anchors_avoided: ['cachorro'], // Exauridas anteriormente
    repetition_calculated: 0.234,
    new_metrics_saved: true,
    different_anchors_used: true
  };
};

/**
 * EXEMPLO 3: Consulta analítica de métricas
 */
const analyticsQuery = async (userId: string) => {
  console.log('📊 CONSULTA: Métricas analíticas de qualidade');

  // Consulta SQL para análise de qualidade
  const query = `
    SELECT
      gm.*,
      c.analysis_result->'anchors' as anchors,
      c.analysis_result->'anchors_used' as anchors_used,
      c.analysis_result->'low_confidence' as low_confidence,
      s.suggestion_text,
      gm.created_at as generation_time
    FROM generation_metrics gm
    JOIN conversations c ON gm.conversation_id = c.id
    LEFT JOIN suggestions s ON gm.suggestion_id = s.id
    WHERE c.user_id = $1
    ORDER BY gm.created_at DESC
    LIMIT 50;
  `;

  // Resultados analíticos:
  return {
    total_generations: 50,
    average_anchors_used: 2.3,
    average_repetition_rate: 0.187,
    average_latency_ms: 1240,
    low_confidence_rate: 0.02,
    most_used_tone: 'descontraído',
    improvement_over_time: true
  };
};

/**
 * EXEMPLO 4: Sistema de feedback e aprendizado
 */
const feedbackSystem = async () => {
  console.log('🎯 SISTEMA: Feedback e melhoria contínua');

  // Dados salvos permitem:
  // ✅ Análise de padrões de uso
  // ✅ Identificação de âncoras mais eficazes
  // ✅ Otimização de prompts baseada em métricas
  // ✅ Detecção de problemas de qualidade
  // ✅ Personalização baseada em histórico

  return {
    patterns_identified: [
      'Âncoras visuais geram melhor engajamento',
      'Tom "genuíno" tem menor taxa de repetição',
      'Sugestões com ≥2 âncoras têm melhor qualidade'
    ],
    optimizations_applied: [
      'Prompt ajustado para priorizar âncoras visuais',
      'Threshold de repetição reduzido para tom genuíno',
      'Sistema incentiva uso de múltiplas âncoras'
    ],
    quality_improvements: {
      before: { average_anchors: 1.2, repetition_rate: 0.45 },
      after: { average_anchors: 2.3, repetition_rate: 0.187 }
    }
  };
};

console.log('📋 EXEMPLOS AVANÇADOS DO PROMPT E - PERSISTÊNCIA IMPLEMENTADA');
