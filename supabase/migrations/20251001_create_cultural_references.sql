-- =====================================================
-- MIGRATION: Create cultural_references table
-- Description: Banco de dados de referências culturais brasileiras
--              para enriquecer sugestões de IA com gírias, memes,
--              e padrões de flerte regionais
-- Author: FlertAI Team
-- Date: 2025-10-01
-- =====================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE: cultural_references
-- =====================================================
CREATE TABLE IF NOT EXISTS cultural_references (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    termo TEXT UNIQUE NOT NULL,
    tipo TEXT NOT NULL,
    significado TEXT NOT NULL,
    exemplo_uso TEXT,
    regiao TEXT DEFAULT 'nacional',
    contexto_flerte TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    
    -- Constraints
    CONSTRAINT tipo_valido CHECK (tipo IN (
        'giria', 
        'meme', 
        'novela', 
        'musica', 
        'personalidade', 
        'evento', 
        'expressao_regional',
        'filme',
        'serie',
        'esporte',
        'comida',
        'lugar'
    )),
    CONSTRAINT regiao_valida CHECK (regiao IN (
        'nacional',
        'norte',
        'nordeste',
        'centro-oeste',
        'sudeste',
        'sul'
    ))
);

-- =====================================================
-- INDEXES
-- =====================================================
CREATE INDEX idx_cultural_references_tipo ON cultural_references(tipo);
CREATE INDEX idx_cultural_references_regiao ON cultural_references(regiao);
CREATE INDEX idx_cultural_references_termo ON cultural_references(termo);
CREATE INDEX idx_cultural_references_created_at ON cultural_references(created_at DESC);

-- Full-text search index para busca por texto
CREATE INDEX idx_cultural_references_termo_search ON cultural_references USING gin(to_tsvector('portuguese', termo));
CREATE INDEX idx_cultural_references_significado_search ON cultural_references USING gin(to_tsvector('portuguese', significado));

-- =====================================================
-- TRIGGER: Update updated_at timestamp
-- =====================================================
CREATE OR REPLACE FUNCTION update_cultural_references_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_cultural_references_updated_at
    BEFORE UPDATE ON cultural_references
    FOR EACH ROW
    EXECUTE FUNCTION update_cultural_references_updated_at();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE cultural_references ENABLE ROW LEVEL SECURITY;

-- Policy: Public read access (todos podem ler)
CREATE POLICY "Public read access for cultural references"
    ON cultural_references
    FOR SELECT
    TO public
    USING (true);

-- Policy: Authenticated users can insert (para scripts/admin)
CREATE POLICY "Authenticated users can insert cultural references"
    ON cultural_references
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy: Authenticated users can update (para curadoria)
CREATE POLICY "Authenticated users can update cultural references"
    ON cultural_references
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policy: Service role can delete (apenas admin/scripts)
CREATE POLICY "Service role can delete cultural references"
    ON cultural_references
    FOR DELETE
    TO service_role
    USING (true);

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function: Get random cultural reference by type
CREATE OR REPLACE FUNCTION get_random_cultural_reference(
    reference_type TEXT DEFAULT NULL,
    reference_region TEXT DEFAULT 'nacional'
)
RETURNS TABLE (
    id UUID,
    termo TEXT,
    tipo TEXT,
    significado TEXT,
    exemplo_uso TEXT,
    regiao TEXT,
    contexto_flerte TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cr.id,
        cr.termo,
        cr.tipo,
        cr.significado,
        cr.exemplo_uso,
        cr.regiao,
        cr.contexto_flerte
    FROM cultural_references cr
    WHERE 
        (reference_type IS NULL OR cr.tipo = reference_type)
        AND (reference_region = 'nacional' OR cr.regiao IN ('nacional', reference_region))
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Search cultural references
CREATE OR REPLACE FUNCTION search_cultural_references(
    search_query TEXT,
    max_results INT DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    termo TEXT,
    tipo TEXT,
    significado TEXT,
    exemplo_uso TEXT,
    regiao TEXT,
    contexto_flerte TEXT,
    relevance REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cr.id,
        cr.termo,
        cr.tipo,
        cr.significado,
        cr.exemplo_uso,
        cr.regiao,
        cr.contexto_flerte,
        ts_rank(
            to_tsvector('portuguese', cr.termo || ' ' || cr.significado),
            plainto_tsquery('portuguese', search_query)
        ) AS relevance
    FROM cultural_references cr
    WHERE 
        to_tsvector('portuguese', cr.termo || ' ' || cr.significado) @@ 
        plainto_tsquery('portuguese', search_query)
    ORDER BY relevance DESC
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Get statistics
CREATE OR REPLACE FUNCTION get_cultural_references_stats()
RETURNS TABLE (
    total_count BIGINT,
    tipo_counts JSONB,
    regiao_counts JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT AS total_count,
        jsonb_object_agg(tipo, count) AS tipo_counts,
        jsonb_object_agg(regiao, count) AS regiao_counts
    FROM (
        SELECT tipo, COUNT(*) as count
        FROM cultural_references
        GROUP BY tipo
    ) t1
    CROSS JOIN (
        SELECT regiao, COUNT(*) as count
        FROM cultural_references
        GROUP BY regiao
    ) t2
    GROUP BY t1.tipo, t2.regiao;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- INITIAL SEED DATA (Sample)
-- =====================================================
INSERT INTO cultural_references (termo, tipo, significado, exemplo_uso, regiao, contexto_flerte) VALUES
    ('Mó cê', 'giria', 'Gíria carioca para "você está" ou "tipo você"', 'Mó cê linda(o) nessa foto!', 'sudeste', 'Casual e descontraído, muito usado no Rio'),
    ('Massa', 'giria', 'Expressão nordestina para algo legal, bacana', 'Seu perfil tá massa demais!', 'nordeste', 'Tom casual e autêntico'),
    ('Quebrar o gelo', 'expressao_regional', 'Iniciar uma conversa de forma leve', 'Vamos quebrar o gelo: qual teu lugar favorito?', 'nacional', 'Início de conversa, tom casual'),
    ('Deu match', 'giria', 'Expressão moderna de apps de namoro, significa combinaram', 'Deu match! Destino ou sorte?', 'nacional', 'Contexto de apps de relacionamento'),
    ('Crush', 'giria', 'Paquera, pessoa por quem se está interessado', 'Então você é meu novo crush?', 'nacional', 'Tom flertante moderno'),
    ('Chamar pra sair', 'expressao_regional', 'Convidar para um encontro', 'Que tal a gente chamar pra sair e conhecer melhor?', 'nacional', 'Convite direto mas respeitoso'),
    ('Gato(a)', 'giria', 'Pessoa bonita, atraente', 'Que gato(a) você é!', 'nacional', 'Elogio físico direto'),
    ('Mozão', 'giria', 'Apelido carinhoso para parceiro romântico', 'E aí, mozão, bora conhecer?', 'nacional', 'Tom carinhoso e descontraído'),
    ('Peguete', 'giria', 'Ficante, relacionamento casual', 'Já tem algum peguete por aí?', 'nacional', 'Contexto de relacionamento casual'),
    ('Rolê', 'giria', 'Passeio, programa', 'Bora marcar um rolê?', 'nacional', 'Convite casual para sair'),
    ('Shippar', 'giria', 'Torcer por um casal, imaginar junto', 'Já tô shippando a gente', 'nacional', 'Tom moderno e divertido'),
    ('Zap', 'giria', 'WhatsApp, usado para pedir contato', 'Me passa teu zap?', 'nacional', 'Pedido de contato casual'),
    ('Tamo junto', 'giria', 'Expressão de apoio, estar presente', 'Qualquer coisa, tamo junto!', 'nacional', 'Tom solidário e parceiro'),
    ('Beleza', 'giria', 'Concordância, tudo bem', 'Beleza, vamos marcar então!', 'nacional', 'Confirmação casual'),
    ('Top', 'giria', 'Algo muito bom, excelente', 'Seu perfil tá top!', 'nacional', 'Elogio casual'),
    ('Mano(a)', 'giria', 'Amigo, parceiro (pode ser usado em flerte)', 'E aí mano(a), bora trocar uma ideia?', 'sudeste', 'Tom descontraído paulista'),
    ('Arraso', 'giria', 'Estar arrasando, estar incrível', 'Você arrasa nessa foto!', 'nacional', 'Elogio empolgado'),
    ('Gatilho', 'meme', 'Algo que desencadeia memória ou emoção forte', 'Seu sorriso é meu gatilho', 'nacional', 'Tom romântico moderno'),
    ('Red flag', 'meme', 'Sinal de alerta em relacionamento', 'Pelo menos não vi red flags no seu perfil', 'nacional', 'Tom humorístico sobre relacionamentos'),
    ('Green flag', 'meme', 'Sinal positivo em relacionamento', 'Gostar de pets é total green flag!', 'nacional', 'Tom positivo sobre qualidades'),
    ('Flerte', 'expressao_regional', 'Ato de paquerar, demonstrar interesse romântico', 'Esse é um flerte ou só conversa?', 'nacional', 'Contexto direto de paquera'),
    ('Sorte sua', 'expressao_regional', 'Expressão brincalhona de autoconfiança', 'Match comigo? Sorte sua!', 'nacional', 'Tom confiante e brincalhão'),
    ('Papo reto', 'giria', 'Conversa sincera, direta', 'Papo reto: achei você interessante', 'nacional', 'Tom genuíno e direto'),
    ('Vibe', 'giria', 'Energia, clima de uma pessoa ou lugar', 'Curti sua vibe!', 'nacional', 'Tom descontraído moderno'),
    ('Cara metade', 'expressao_regional', 'Parceiro ideal, alma gêmea', 'Será que você é minha cara metade?', 'nacional', 'Tom romântico tradicional')
ON CONFLICT (termo) DO NOTHING;

-- =====================================================
-- COMMENTS
-- =====================================================
COMMENT ON TABLE cultural_references IS 'Banco de dados de referências culturais brasileiras para enriquecer IA';
COMMENT ON COLUMN cultural_references.termo IS 'A gíria, meme ou referência cultural';
COMMENT ON COLUMN cultural_references.tipo IS 'Tipo de referência: giria, meme, novela, musica, etc';
COMMENT ON COLUMN cultural_references.significado IS 'Explicação concisa do termo';
COMMENT ON COLUMN cultural_references.exemplo_uso IS 'Exemplo de uso em contexto de flerte';
COMMENT ON COLUMN cultural_references.regiao IS 'Região do Brasil onde é mais comum';
COMMENT ON COLUMN cultural_references.contexto_flerte IS 'Contexto de flerte onde o termo se encaixa';

-- =====================================================
-- GRANTS (opcional, depende da configuração)
-- =====================================================
-- GRANT SELECT ON cultural_references TO anon;
-- GRANT SELECT ON cultural_references TO authenticated;

-- =====================================================
-- VERIFICATION QUERY
-- =====================================================
-- Para verificar a criação:
-- SELECT * FROM cultural_references LIMIT 10;
-- SELECT * FROM get_cultural_references_stats();
-- SELECT * FROM search_cultural_references('vibe');
-- SELECT * FROM get_random_cultural_reference('giria', 'nacional');

-- =====================================================
-- END OF MIGRATION
-- =====================================================
