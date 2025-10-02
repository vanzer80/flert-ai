-- =====================================================
-- COMANDO SQL 3/3: Funções Helper
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
