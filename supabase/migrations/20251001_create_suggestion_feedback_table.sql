-- =====================================================
-- MIGRATION: Create suggestion_feedback table
-- Description: Tabela para armazenar feedback dos usuários sobre sugestões
-- Author: FlertAI Team
-- Date: 2025-10-01
-- =====================================================

-- Criar tabela de feedbacks
CREATE TABLE IF NOT EXISTS suggestion_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
  suggestion_text TEXT NOT NULL, -- Armazena o texto da sugestão para referência
  suggestion_index INTEGER NOT NULL, -- Índice da sugestão (0, 1, 2)
  feedback_type TEXT NOT NULL CHECK (feedback_type IN ('like', 'dislike')),
  comentario TEXT, -- Campo opcional para feedback textual
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Criar índices para melhor performance
CREATE INDEX idx_suggestion_feedback_user_id ON suggestion_feedback(user_id);
CREATE INDEX idx_suggestion_feedback_conversation_id ON suggestion_feedback(conversation_id);
CREATE INDEX idx_suggestion_feedback_type ON suggestion_feedback(feedback_type);
CREATE INDEX idx_suggestion_feedback_created_at ON suggestion_feedback(created_at DESC);

-- Comentários nas colunas
COMMENT ON TABLE suggestion_feedback IS 'Armazena feedback dos usuários sobre as sugestões geradas pela IA';
COMMENT ON COLUMN suggestion_feedback.user_id IS 'ID do usuário que deu o feedback';
COMMENT ON COLUMN suggestion_feedback.conversation_id IS 'ID da conversa relacionada ao feedback';
COMMENT ON COLUMN suggestion_feedback.suggestion_text IS 'Texto completo da sugestão avaliada';
COMMENT ON COLUMN suggestion_feedback.suggestion_index IS 'Índice da sugestão na lista (0-2)';
COMMENT ON COLUMN suggestion_feedback.feedback_type IS 'Tipo de feedback: like ou dislike';
COMMENT ON COLUMN suggestion_feedback.comentario IS 'Comentário opcional do usuário';
COMMENT ON COLUMN suggestion_feedback.created_at IS 'Data e hora do feedback';

-- =====================================================
-- RLS (Row Level Security) Policies
-- =====================================================

-- Habilitar RLS
ALTER TABLE suggestion_feedback ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem ver apenas seus próprios feedbacks
CREATE POLICY "Users can view their own feedback"
  ON suggestion_feedback
  FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Usuários podem inserir seus próprios feedbacks
CREATE POLICY "Users can insert their own feedback"
  ON suggestion_feedback
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Usuários podem atualizar seus próprios feedbacks
CREATE POLICY "Users can update their own feedback"
  ON suggestion_feedback
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Política: Usuários podem deletar seus próprios feedbacks
CREATE POLICY "Users can delete their own feedback"
  ON suggestion_feedback
  FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- Migration aplicada com sucesso
-- =====================================================
