-- =====================================================
-- VERIFICAÇÃO FINAL: Após Inserção dos Dados
-- =====================================================

-- 1. Contar total de registros
SELECT COUNT(*) as total FROM cultural_references;

-- 2. Ver distribuição por tipo
SELECT tipo, COUNT(*) as quantidade
FROM cultural_references
GROUP BY tipo
ORDER BY quantidade DESC;

-- 3. Ver distribuição por região
SELECT regiao, COUNT(*) as quantidade
FROM cultural_references
GROUP BY regiao
ORDER BY quantidade DESC;

-- 4. Testar busca aleatória por tipo e região
SELECT * FROM get_random_cultural_reference('giria', 'sudeste');

-- 5. Testar busca textual
SELECT * FROM search_cultural_references('massa', 3);

-- 6. Ver estatísticas completas
SELECT * FROM get_cultural_references_stats();
