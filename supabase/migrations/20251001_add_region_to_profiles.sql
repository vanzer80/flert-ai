-- =====================================================
-- MIGRATION: Add region column to profiles table
-- Description: Adiciona coluna region para permitir
--              regionalização de referências culturais
-- Author: FlertAI Team
-- Date: 2025-10-01
-- =====================================================

-- Adicionar coluna region
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS region TEXT DEFAULT 'nacional';

-- Adicionar constraint de validação
ALTER TABLE profiles 
ADD CONSTRAINT region_valida CHECK (region IN (
    'nacional',
    'norte',
    'nordeste',
    'centro-oeste',
    'sudeste',
    'sul'
));

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_profiles_region ON profiles(region);

-- Comentário na coluna
COMMENT ON COLUMN profiles.region IS 'Região do Brasil do usuário para personalização de referências culturais';

-- =====================================================
-- Atualizar registros existentes para 'nacional'
-- =====================================================
UPDATE profiles SET region = 'nacional' WHERE region IS NULL;
