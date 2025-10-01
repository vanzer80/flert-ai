-- =====================================================
-- MIGRATION: Add focus_tags column to conversations table
-- Description: Adiciona coluna focus_tags como array de texto
--              para armazenar múltiplos focos selecionados pelo usuário
-- Author: FlertAI Team
-- Date: 2025-10-01
-- =====================================================

-- Adicionar coluna focus_tags como array de texto
ALTER TABLE conversations
ADD COLUMN IF NOT EXISTS focus_tags TEXT[] DEFAULT '{}';

-- Comentário na coluna
COMMENT ON COLUMN conversations.focus_tags IS 'Array de tags/focos selecionados pelo usuário para personalização das sugestões';

-- =====================================================
-- Migration aplicada com sucesso
-- =====================================================
