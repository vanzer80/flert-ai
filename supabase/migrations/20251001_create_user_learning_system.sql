-- =====================================================
-- MIGRATION: Create User Learning System
-- Description: Sistema de aprendizado personalizado por usuário
-- Author: FlertAI Team
-- Date: 2025-10-01
-- =====================================================

-- =====================================================
-- 1. TABELA: user_profiles
-- Armazena perfis anônimos de usuários (sem autenticação)
-- =====================================================
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT UNIQUE NOT NULL, -- ID único do dispositivo
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  last_active_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  total_feedbacks INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}'::jsonb -- Dados adicionais flexíveis
);

CREATE INDEX idx_user_profiles_device_id ON user_profiles(device_id);
CREATE INDEX idx_user_profiles_last_active ON user_profiles(last_active_at DESC);

COMMENT ON TABLE user_profiles IS 'Perfis anônimos de usuários identificados por device_id';
COMMENT ON COLUMN user_profiles.device_id IS 'ID único gerado no dispositivo do usuário';

-- =====================================================
-- 2. TABELA: user_preferences
-- Armazena preferências aprendidas do usuário
-- =====================================================
CREATE TABLE IF NOT EXISTS user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_profile_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  
  -- Preferências de Tom
  favorite_tones JSONB DEFAULT '[]'::jsonb, -- Array de tons mais curtidos
  avoided_tones JSONB DEFAULT '[]'::jsonb,  -- Array de tons mais rejeitados
  
  -- Preferências de Focus Tags
  favorite_tags JSONB DEFAULT '[]'::jsonb,
  avoided_tags JSONB DEFAULT '[]'::jsonb,
  
  -- Padrões de Linguagem Preferidos
  preferred_patterns JSONB DEFAULT '[]'::jsonb, -- Padrões de mensagens curtidas
  avoided_patterns JSONB DEFAULT '[]'::jsonb,   -- Padrões rejeitados
  
  -- Estatísticas
  total_likes INTEGER DEFAULT 0,
  total_dislikes INTEGER DEFAULT 0,
  like_rate DECIMAL(5,2) DEFAULT 0.00,
  
  -- Exemplos de mensagens bem avaliadas (para few-shot learning)
  good_examples JSONB DEFAULT '[]'::jsonb,
  bad_examples JSONB DEFAULT '[]'::jsonb,
  
  -- Configurações personalizadas
  custom_instructions TEXT, -- Instruções específicas geradas para este usuário
  
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  
  UNIQUE(user_profile_id)
);

CREATE INDEX idx_user_preferences_profile ON user_preferences(user_profile_id);

COMMENT ON TABLE user_preferences IS 'Preferências aprendidas automaticamente baseadas em feedbacks';
COMMENT ON COLUMN user_preferences.favorite_tones IS 'Tons com maior taxa de aprovação';
COMMENT ON COLUMN user_preferences.preferred_patterns IS 'Padrões de linguagem que o usuário gosta';
COMMENT ON COLUMN user_preferences.good_examples IS 'Exemplos de mensagens bem avaliadas para usar no prompt';

-- =====================================================
-- 3. TABELA: learning_events
-- Log de eventos de aprendizado para auditoria
-- =====================================================
CREATE TABLE IF NOT EXISTS learning_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_profile_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE NOT NULL,
  event_type TEXT NOT NULL, -- 'feedback_processed', 'preferences_updated', 'pattern_detected'
  event_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX idx_learning_events_profile ON learning_events(user_profile_id);
CREATE INDEX idx_learning_events_type ON learning_events(event_type);
CREATE INDEX idx_learning_events_created ON learning_events(created_at DESC);

COMMENT ON TABLE learning_events IS 'Log de eventos do sistema de aprendizado';

-- =====================================================
-- 4. FUNÇÃO: update_user_preferences
-- Atualiza preferências baseado em novo feedback
-- =====================================================
CREATE OR REPLACE FUNCTION update_user_preferences_from_feedback()
RETURNS TRIGGER AS $$
DECLARE
  v_user_profile_id UUID;
  v_tone TEXT;
  v_focus_tags TEXT[];
BEGIN
  -- Buscar user_profile_id pela conversation
  SELECT up.id, c.tone, c.focus_tags
  INTO v_user_profile_id, v_tone, v_focus_tags
  FROM user_profiles up
  JOIN conversations c ON c.user_id::text = up.device_id
  WHERE c.id = NEW.conversation_id
  LIMIT 1;
  
  IF v_user_profile_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Atualizar contadores
  IF NEW.feedback_type = 'like' THEN
    UPDATE user_preferences
    SET 
      total_likes = total_likes + 1,
      like_rate = (total_likes + 1) * 100.0 / NULLIF(total_likes + total_dislikes + 1, 0),
      updated_at = now()
    WHERE user_profile_id = v_user_profile_id;
    
    -- Adicionar tom aos favoritos se ainda não estiver
    IF v_tone IS NOT NULL THEN
      UPDATE user_preferences
      SET favorite_tones = favorite_tones || jsonb_build_array(v_tone)
      WHERE user_profile_id = v_user_profile_id
        AND NOT favorite_tones ? v_tone;
    END IF;
    
    -- Adicionar às boas mensagens (máximo 10)
    UPDATE user_preferences
    SET good_examples = (
      SELECT jsonb_agg(elem)
      FROM (
        SELECT elem FROM jsonb_array_elements(good_examples) elem
        UNION ALL
        SELECT jsonb_build_object(
          'text', NEW.suggestion_text,
          'tone', v_tone,
          'timestamp', NEW.created_at
        )
        ORDER BY (elem->>'timestamp')::timestamptz DESC
        LIMIT 10
      ) subq
    )
    WHERE user_profile_id = v_user_profile_id;
    
  ELSE -- dislike
    UPDATE user_preferences
    SET 
      total_dislikes = total_dislikes + 1,
      like_rate = total_likes * 100.0 / NULLIF(total_likes + total_dislikes + 1, 0),
      updated_at = now()
    WHERE user_profile_id = v_user_profile_id;
    
    -- Adicionar às mensagens ruins (máximo 10)
    UPDATE user_preferences
    SET bad_examples = (
      SELECT jsonb_agg(elem)
      FROM (
        SELECT elem FROM jsonb_array_elements(bad_examples) elem
        UNION ALL
        SELECT jsonb_build_object(
          'text', NEW.suggestion_text,
          'tone', v_tone,
          'timestamp', NEW.created_at
        )
        ORDER BY (elem->>'timestamp')::timestamptz DESC
        LIMIT 10
      ) subq
    )
    WHERE user_profile_id = v_user_profile_id;
  END IF;
  
  -- Log do evento
  INSERT INTO learning_events (user_profile_id, event_type, event_data)
  VALUES (
    v_user_profile_id,
    'feedback_processed',
    jsonb_build_object(
      'feedback_type', NEW.feedback_type,
      'tone', v_tone,
      'suggestion_index', NEW.suggestion_index
    )
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
DROP TRIGGER IF EXISTS trigger_update_preferences_on_feedback ON suggestion_feedback;
CREATE TRIGGER trigger_update_preferences_on_feedback
  AFTER INSERT ON suggestion_feedback
  FOR EACH ROW
  EXECUTE FUNCTION update_user_preferences_from_feedback();

-- =====================================================
-- 5. FUNÇÃO: get_user_learning_prompt
-- Retorna instruções personalizadas baseadas no aprendizado
-- =====================================================
CREATE OR REPLACE FUNCTION get_user_learning_prompt(p_device_id TEXT)
RETURNS TEXT AS $$
DECLARE
  v_prompt TEXT := '';
  v_prefs RECORD;
BEGIN
  SELECT 
    up.*,
    array_length(array(SELECT jsonb_array_elements_text(up.favorite_tones)), 1) as fav_count,
    array_length(array(SELECT jsonb_array_elements_text(up.good_examples)), 1) as good_count
  INTO v_prefs
  FROM user_preferences up
  JOIN user_profiles prof ON prof.id = up.user_profile_id
  WHERE prof.device_id = p_device_id;
  
  IF v_prefs IS NULL THEN
    RETURN '';
  END IF;
  
  v_prompt := E'\n\n=== PREFERÊNCIAS DO USUÁRIO (APRENDIDAS) ===\n';
  
  -- Tons favoritos
  IF v_prefs.fav_count > 0 THEN
    v_prompt := v_prompt || E'Tons que este usuário GOSTA:\n';
    v_prompt := v_prompt || '- ' || array_to_string(
      array(SELECT jsonb_array_elements_text(v_prefs.favorite_tones)), 
      E'\n- '
    ) || E'\n\n';
  END IF;
  
  -- Exemplos de mensagens que funcionaram
  IF v_prefs.good_count > 0 THEN
    v_prompt := v_prompt || E'Exemplos de mensagens que ESTE USUÁRIO adorou:\n';
    SELECT string_agg('- "' || (elem->>'text') || '"', E'\n')
    INTO v_prompt
    FROM jsonb_array_elements(v_prefs.good_examples) elem;
  END IF;
  
  -- Estatísticas
  v_prompt := v_prompt || E'\n\nTaxa de aprovação deste usuário: ' || v_prefs.like_rate || '%';
  v_prompt := v_prompt || E'\nTotal de feedbacks: ' || (v_prefs.total_likes + v_prefs.total_dislikes);
  
  RETURN v_prompt;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- RLS Policies (permissivas para MVP sem auth)
-- =====================================================
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_events ENABLE ROW LEVEL SECURITY;

-- Permitir acesso público (MVP)
CREATE POLICY "Allow public access to user_profiles" ON user_profiles FOR ALL USING (true);
CREATE POLICY "Allow public access to user_preferences" ON user_preferences FOR ALL USING (true);
CREATE POLICY "Allow public access to learning_events" ON learning_events FOR ALL USING (true);

-- =====================================================
-- Migration concluída
-- =====================================================
COMMENT ON SCHEMA public IS 'Sistema de aprendizado personalizado implementado - v1.5.0';
