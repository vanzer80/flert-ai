-- =====================================================
-- VERIFICAÇÃO 2/3: Testar Funções SQL (ATUALIZADA)
-- =====================================================

-- Testar função de busca aleatória
SELECT * FROM get_random_cultural_reference('giria', 'nacional');

-- Testar busca textual
SELECT * FROM search_cultural_references('crush', 5);

-- Ver estatísticas (AGORA FUNCIONA!)
SELECT * FROM get_cultural_references_stats();
