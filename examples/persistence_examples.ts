// Exemplo de uso do sistema de persistência de contexto e métricas

/**
 * EXEMPLO 1: Nova conversa com análise visual fresca
 */
const newConversationExample = {
  image_base64: 'base64_image_data',
  user_id: 'user_123',
  tone: 'descontraído',
  focus_tags: ['pet', 'diversão'],
  text: 'Perfil de alguém com um cachorro fofo'
};

/**
 * EXEMPLO 2: "Gerar mais" usando contexto existente
 */
const regenerateExample = {
  conversation_id: 'conv_456', // Contexto existente será recuperado
  user_id: 'user_123',
  tone: 'flertar',
  focus_tags: ['personalidade'],
  skip_vision: true // Não re-analisa a imagem
};

/**
 * EXEMPLO 3: Consulta de métricas salvas
 */
const metricsQueryExample = `
SELECT
  gm.*,
  c.analysis_result->'anchors' as anchors,
  c.analysis_result->'anchors_used' as anchors_used,
  c.analysis_result->'low_confidence' as low_confidence
FROM generation_metrics gm
JOIN conversations c ON gm.conversation_id = c.id
WHERE c.user_id = 'user_123'
ORDER BY gm.created_at DESC
LIMIT 10;
`;

/**
 * RESULTADO ESPERADO DA MIGRATION:
 * ✅ Tabela conversations: +2 colunas (analysis_result, exhausted_anchors)
 * ✅ Tabela generation_metrics: nova tabela com métricas detalhadas
 * ✅ Índices criados para performance
 * ✅ Relacionamentos configurados corretamente
 */

console.log('📋 EXEMPLOS DE USO DO PROMPT E - PERSISTÊNCIA IMPLEMENTADA');
