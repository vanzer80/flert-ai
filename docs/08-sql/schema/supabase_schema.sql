-- FlertaAI Database Schema
-- Execute este script no Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de usuários (profiles)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users PRIMARY KEY,
    email TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    subscription_type TEXT DEFAULT 'free',
    daily_suggestions_used INTEGER DEFAULT 0,
    last_usage_reset DATE DEFAULT CURRENT_DATE
);

-- Tabela de conversas analisadas
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    image_url TEXT,
    analysis_result JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de sugestões geradas
CREATE TABLE IF NOT EXISTS suggestions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    tone_type TEXT NOT NULL,
    suggestion_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de indicações (referrals)
CREATE TABLE IF NOT EXISTS referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    referred_email TEXT NOT NULL,
    referred_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'pending', -- pending, completed, rewarded
    reward_amount DECIMAL(10,2) DEFAULT 40.00,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- Tabela de transações/pagamentos
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- subscription, single_analysis, referral_reward
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'BRL',
    status TEXT DEFAULT 'pending', -- pending, completed, failed, refunded
    payment_method TEXT,
    external_transaction_id TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_created_at ON conversations(created_at);
CREATE INDEX IF NOT EXISTS idx_suggestions_conversation_id ON suggestions(conversation_id);
CREATE INDEX IF NOT EXISTS idx_suggestions_created_at ON suggestions(created_at);
CREATE INDEX IF NOT EXISTS idx_referrals_referrer_id ON referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referrals_referred_id ON referrals(referred_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);

-- RLS (Row Level Security) Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE suggestions ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Policies para profiles
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Policies para conversations
CREATE POLICY "Users can view own conversations" ON conversations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations" ON conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations" ON conversations
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversations" ON conversations
    FOR DELETE USING (auth.uid() = user_id);

-- Policies para suggestions
CREATE POLICY "Users can view suggestions from own conversations" ON suggestions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversations 
            WHERE conversations.id = suggestions.conversation_id 
            AND conversations.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert suggestions for own conversations" ON suggestions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM conversations 
            WHERE conversations.id = suggestions.conversation_id 
            AND conversations.user_id = auth.uid()
        )
    );

-- Policies para referrals
CREATE POLICY "Users can view own referrals" ON referrals
    FOR SELECT USING (auth.uid() = referrer_id OR auth.uid() = referred_id);

CREATE POLICY "Users can insert own referrals" ON referrals
    FOR INSERT WITH CHECK (auth.uid() = referrer_id);

-- Policies para transactions
CREATE POLICY "Users can view own transactions" ON transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Função para criar perfil automaticamente após signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email)
    VALUES (NEW.id, NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar perfil automaticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Função para resetar contador diário de uso
CREATE OR REPLACE FUNCTION public.reset_daily_usage()
RETURNS void AS $$
BEGIN
    UPDATE profiles 
    SET daily_suggestions_used = 0,
        last_usage_reset = CURRENT_DATE
    WHERE last_usage_reset < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar limite diário
CREATE OR REPLACE FUNCTION public.check_daily_limit(user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    user_profile profiles%ROWTYPE;
    daily_limit INTEGER := 3; -- Limite gratuito
BEGIN
    SELECT * INTO user_profile FROM profiles WHERE id = user_id;
    
    -- Reset contador se necessário
    IF user_profile.last_usage_reset < CURRENT_DATE THEN
        UPDATE profiles 
        SET daily_suggestions_used = 0,
            last_usage_reset = CURRENT_DATE
        WHERE id = user_id;
        user_profile.daily_suggestions_used := 0;
    END IF;
    
    -- Usuários premium têm limite ilimitado
    IF user_profile.subscription_type = 'premium' THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar limite para usuários gratuitos
    RETURN user_profile.daily_suggestions_used < daily_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para incrementar uso diário
CREATE OR REPLACE FUNCTION public.increment_daily_usage(user_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE profiles 
    SET daily_suggestions_used = daily_suggestions_used + 1
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Storage bucket para imagens
INSERT INTO storage.buckets (id, name, public) 
VALUES ('images', 'images', true)
ON CONFLICT (id) DO NOTHING;

-- Policy para storage bucket
CREATE POLICY "Users can upload images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'images' AND auth.role() = 'authenticated');

CREATE POLICY "Images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'images');

CREATE POLICY "Users can update own images" ON storage.objects
    FOR UPDATE USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own images" ON storage.objects
    FOR DELETE USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Comentários para documentação
COMMENT ON TABLE profiles IS 'Perfis dos usuários com informações de assinatura e uso';
COMMENT ON TABLE conversations IS 'Conversas/imagens analisadas pelos usuários';
COMMENT ON TABLE suggestions IS 'Sugestões de mensagens geradas pela IA';
COMMENT ON TABLE referrals IS 'Sistema de indicações e recompensas';
COMMENT ON TABLE transactions IS 'Histórico de transações e pagamentos';

COMMENT ON COLUMN profiles.subscription_type IS 'Tipo de assinatura: free, premium';
COMMENT ON COLUMN profiles.daily_suggestions_used IS 'Contador de sugestões usadas no dia atual';
COMMENT ON COLUMN conversations.analysis_result IS 'Resultado da análise da IA em formato JSON';
COMMENT ON COLUMN referrals.status IS 'Status da indicação: pending, completed, rewarded';
COMMENT ON COLUMN transactions.type IS 'Tipo de transação: subscription, single_analysis, referral_reward';
