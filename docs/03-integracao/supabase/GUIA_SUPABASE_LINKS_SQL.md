# 🔗 GUIA SUPABASE - Links Diretos + Comandos SQL

**Data:** 2025-10-01 07:13  
**Projeto:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf

---

## 🎯 PASSO 1: APLICAR MIGRATION SQL

### 📍 **Link Direto:**
```
https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/sql/new
```

### 📋 **Comandos SQL para Copiar e Colar:**

**COMANDO 1/3 - Criar Tabela (Copie e Cole Este Primeiro):**
```sql
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
```

**COMANDO 2/3 - Verificar Criação da Tabela:**
```sql
-- Verificar se a tabela foi criada corretamente
SELECT COUNT(*) as total FROM cultural_references;

-- Ver amostra dos dados
SELECT termo, tipo, regiao FROM cultural_references LIMIT 10;
```

**COMANDO 3/3 - Testar Funções SQL:**
```sql
-- Testar função de busca aleatória
SELECT * FROM get_random_cultural_reference('giria', 'nacional');

-- Testar busca textual
SELECT * FROM search_cultural_references('crush', 5);

-- Ver estatísticas
SELECT * FROM get_cultural_references_stats();
```

---

## 🎯 PASSO 2: CONFIGURAR SERVICE ROLE KEY

### 📍 **Link Direto:**
```
https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/settings/api
```

### 📋 **Como Fazer:**

1. **Na página de API:**
   - Vá para: **Settings → API** (no menu lateral esquerdo)
   - Encontre a seção: **Project API keys**

2. **Copie a chave "service_role":**
   - Localize: **service_role** (secret)
   - Clique no botão **Copy** (ícone de copiar) ou **Reveal**
   - Copie a chave completa (começa com `eyJ...`)

3. **Cole no arquivo .env:**
   - Abra: `scripts/scraper/.env`
   - Encontre a linha: `SUPABASE_KEY=COLOQUE_SUA_SERVICE_ROLE_KEY_AQUI`
   - Substitua por: `SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

---

## 🎯 PASSO 3: TESTAR INSERÇÃO DE DADOS

### 📍 **Link Direto (para verificar dados depois):**
```
https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/editor
```

### 📋 **Comandos para Verificar Após Inserção:**

**COMANDO 1/3 - Ver Total de Registros:**
```sql
-- Verificar total de registros inseridos
SELECT COUNT(*) as total FROM cultural_references;
```

**COMANDO 2/3 - Ver Distribuição por Tipo:**
```sql
-- Ver distribuição por tipo
SELECT tipo, COUNT(*) as quantidade
FROM cultural_references
GROUP BY tipo
ORDER BY quantidade DESC;
```

**COMANDO 3/3 - Testar Todas as Funções:**
```sql
-- Testar busca aleatória por tipo e região
SELECT * FROM get_random_cultural_reference('giria', 'sudeste');

-- Testar busca textual
SELECT * FROM search_cultural_references('massa', 3);

-- Ver estatísticas completas
SELECT * FROM get_cultural_references_stats();
```

---

## 🎯 PASSO 4: (OPCIONAL) INSERIR MAIS DADOS

### 📍 **Link Direto:**
```
https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/sql/new
```

### 📋 **Comandos para Expandir Dados (Quando Quiser):**

**COMANDO 1/1 - Inserir Mais Referências (Exemplo):**
```sql
-- Exemplo de como inserir mais dados manualmente
INSERT INTO cultural_references (termo, tipo, significado, exemplo_uso, regiao, contexto_flerte) VALUES
    ('Dar match', 'giria', 'Quando duas pessoas se interessam mutuamente em app de namoro', 'Deu match! Vamos conversar?', 'nacional', 'Contexto de apps de relacionamento'),
    ('Ficar', 'giria', 'Sair junto, beijar sem compromisso sério', 'Quer ficar depois do rolê?', 'nacional', 'Relacionamento casual'),
    ('Paquera', 'expressao_regional', 'Ato de flertar, demonstrar interesse', 'Essa paquera tá rendendo!', 'nacional', 'Tom direto de flerte')
ON CONFLICT (termo) DO NOTHING;
```

---

## ✅ **CHECKLIST RÁPIDO - COPIE E EXECUTE**

### **1. Aplicar Migration:**
- [ ] Vá para: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/sql/new
- [ ] Cole o **COMANDO 1/3** e execute (Run)
- [ ] Cole o **COMANDO 2/3** e execute
- [ ] Cole o **COMANDO 3/3** e execute

### **2. Configurar Chave:**
- [ ] Vá para: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/settings/api
- [ ] Copie a chave **service_role**
- [ ] Cole no arquivo `scripts/scraper/.env`

### **3. Executar Script:**
```powershell
cd c:\Users\vanze\FlertAI\flerta_ai\scripts\scraper
python run_after_config.py
```

### **4. Verificar Dados:**
- [ ] Vá para: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/editor
- [ ] Execute os comandos de verificação

---

## 🚨 **COMANDOS SQL SEPARADOS PARA COPIAR:**

### **🔴 COMANDO SQL 1 - CRIAÇÃO DA TABELA (PRIORIDADE 1):**
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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
    CONSTRAINT tipo_valido CHECK (tipo IN ('giria', 'meme', 'novela', 'musica', 'personalidade', 'evento', 'expressao_regional', 'filme', 'serie', 'esporte', 'comida', 'lugar')),
    CONSTRAINT regiao_valida CHECK (regiao IN ('nacional', 'norte', 'nordeste', 'centro-oeste', 'sudeste', 'sul'))
);
```

### **🟡 COMANDO SQL 2 - ÍNDICES E FUNÇÕES (PRIORIDADE 2):**
```sql
CREATE INDEX idx_cultural_references_tipo ON cultural_references(tipo);
CREATE INDEX idx_cultural_references_regiao ON cultural_references(regiao);
CREATE INDEX idx_cultural_references_termo ON cultural_references(termo);
CREATE INDEX idx_cultural_references_created_at ON cultural_references(created_at DESC);
CREATE INDEX idx_cultural_references_termo_search ON cultural_references USING gin(to_tsvector('portuguese', termo));
CREATE INDEX idx_cultural_references_significado_search ON cultural_references USING gin(to_tsvector('portuguese', significado));

CREATE OR REPLACE FUNCTION get_random_cultural_reference(reference_type TEXT DEFAULT NULL, reference_region TEXT DEFAULT 'nacional')
RETURNS TABLE (id UUID, termo TEXT, tipo TEXT, significado TEXT, exemplo_uso TEXT, regiao TEXT, contexto_flerte TEXT) AS $$
BEGIN
    RETURN QUERY SELECT cr.id, cr.termo, cr.tipo, cr.significado, cr.exemplo_uso, cr.regiao, cr.contexto_flerte
    FROM cultural_references cr
    WHERE (reference_type IS NULL OR cr.tipo = reference_type)
    AND (reference_region = 'nacional' OR cr.regiao IN ('nacional', reference_region))
    ORDER BY RANDOM() LIMIT 1;
END; $$ LANGUAGE plpgsql SECURITY DEFINER;
```

### **🟢 COMANDO SQL 3 - SEED DATA (PRIORIDADE 3):**
```sql
INSERT INTO cultural_references (termo, tipo, significado, exemplo_uso, regiao, contexto_flerte) VALUES
    ('Crush', 'giria', 'Paquera, pessoa por quem se está interessado', 'Então você é meu novo crush?', 'nacional', 'Tom flertante moderno'),
    ('Mozão', 'giria', 'Apelido carinhoso para parceiro romântico', 'E aí, mozão, bora conhecer?', 'nacional', 'Tom carinhoso e descontraído'),
    ('Vibe', 'giria', 'Energia, clima de uma pessoa ou lugar', 'Curti sua vibe!', 'nacional', 'Tom descontraído moderno'),
    ('Red flag', 'meme', 'Sinal de alerta em relacionamento', 'Pelo menos não vi red flags no seu perfil', 'nacional', 'Tom humorístico sobre relacionamentos'),
    ('Green flag', 'meme', 'Sinal positivo em relacionamento', 'Gostar de pets é total green flag!', 'nacional', 'Tom positivo sobre qualidades'),
    ('Evidências', 'musica', 'Música romântica de Chitãozinho & Xororó', 'Tipo Evidências: quando te vejo, me rendo', 'nacional', 'Romântico clássico brasileiro')
ON CONFLICT (termo) DO NOTHING;
```

---

## 📊 **VERIFICAÇÃO FINAL - Comandos Prontos:**

### **Contar Registros:**
```sql
SELECT COUNT(*) FROM cultural_references;
```

### **Ver Amostra:**
```sql
SELECT termo, tipo, regiao FROM cultural_references LIMIT 10;
```

### **Testar Busca Aleatória:**
```sql
SELECT * FROM get_random_cultural_reference('giria', 'nacional');
```

### **Testar Busca Textual:**
```sql
SELECT * FROM search_cultural_references('crush', 5);
```

### **Ver Estatísticas:**
```sql
SELECT * FROM get_cultural_references_stats();
```

---

## ⚡ **RESUMO - 3 CLIQUES + 1 COLA:**

1. **🔗 Clique:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/sql/new
2. **📋 Cole:** COMANDO SQL 1 (Criação da Tabela)
3. **▶️ Clique:** Run
4. **🔗 Clique:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/settings/api
5. **📋 Copie:** service_role key
6. **📝 Cole:** no arquivo .env
7. **🚀 Execute:** `python run_after_config.py`

**⏱️ Tempo estimado: 5 minutos** ⚡

---

## ✅ **RESULTADO ESPERADO:**

- ✅ Tabela criada com 25 registros iniciais
- ✅ 87 referências inseridas pelo script
- ✅ Total: 112 referências culturais funcionando
- ✅ Sistema pronto para integração com IA

**🎉 PRONTO PARA USAR!** 🇧🇷✨
