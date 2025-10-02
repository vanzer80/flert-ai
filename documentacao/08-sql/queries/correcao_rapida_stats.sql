-- =====================================================
-- CORREÇÃO RÁPIDA: Apenas a função com problema
-- Execute APENAS este comando para corrigir o erro
-- =====================================================

-- Function: Get statistics (CORRIGIDA - resolve ambiguidade de coluna "count")
CREATE OR REPLACE FUNCTION get_cultural_references_stats()
RETURNS TABLE (
    total_count BIGINT,
    tipo_counts JSONB,
    regiao_counts JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*)::BIGINT FROM cultural_references) AS total_count,
        (SELECT jsonb_object_agg(tipo, tipo_count) FROM (
            SELECT tipo, COUNT(*) as tipo_count
            FROM cultural_references
            GROUP BY tipo
        ) tipo_stats) AS tipo_counts,
        (SELECT jsonb_object_agg(regiao, regiao_count) FROM (
            SELECT regiao, COUNT(*) as regiao_count
            FROM cultural_references
            GROUP BY regiao
        ) regiao_stats) AS regiao_counts;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
