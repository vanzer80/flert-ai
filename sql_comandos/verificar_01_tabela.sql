-- =====================================================
-- VERIFICAÇÃO 1/3: Verificar Criação da Tabela
-- =====================================================

-- Verificar se a tabela foi criada corretamente
SELECT COUNT(*) as total FROM cultural_references;

-- Ver amostra dos dados
SELECT termo, tipo, regiao FROM cultural_references LIMIT 10;
