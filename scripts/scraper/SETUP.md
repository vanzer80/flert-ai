# 🚀 SETUP COMPLETO - Cultural References

Guia passo a passo para configurar e popular a tabela `cultural_references` no Supabase.

---

## ✅ CHECKLIST DE EXECUÇÃO

### FASE 1: Aplicar Migration SQL

- [ ] **Passo 1.1:** Abrir Supabase Dashboard
  ```
  https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf
  ```

- [ ] **Passo 1.2:** Navegar para SQL Editor
  ```
  Dashboard → SQL Editor → New query
  ```

- [ ] **Passo 1.3:** Copiar SQL da migration
  ```
  Arquivo: supabase/migrations/20251001_create_cultural_references.sql
  ```

- [ ] **Passo 1.4:** Colar e executar SQL
  ```sql
  -- Verificar se tabela foi criada:
  SELECT * FROM cultural_references LIMIT 1;
  ```

- [ ] **Passo 1.5:** Verificar funções criadas
  ```sql
  SELECT * FROM get_cultural_references_stats();
  ```

**✅ RESULTADO ESPERADO:**
```
Tabela cultural_references criada
Índices criados (6 índices)
Trigger de updated_at criado
RLS policies ativas (4 policies)
Funções helper criadas (3 funções)
```

---

### FASE 2: Configurar Ambiente Python

- [ ] **Passo 2.1:** Navegar para diretório
  ```bash
  cd c:\Users\vanze\FlertAI\flerta_ai\scripts\scraper
  ```

- [ ] **Passo 2.2:** Criar ambiente virtual
  ```bash
  python -m venv venv
  ```

- [ ] **Passo 2.3:** Ativar ambiente virtual
  ```bash
  # Windows
  venv\Scripts\activate
  
  # Linux/Mac
  source venv/bin/activate
  ```

- [ ] **Passo 2.4:** Instalar dependências
  ```bash
  pip install -r requirements.txt
  ```

- [ ] **Passo 2.5:** Configurar variáveis de ambiente
  ```bash
  # Copiar arquivo de exemplo
  copy .env.example .env
  
  # Editar .env com suas credenciais
  notepad .env
  ```

**Configuração do `.env`:**
```env
SUPABASE_URL=https://olojvpoqosrjcoxygiyf.supabase.co
SUPABASE_KEY=your_service_role_key_here
```

**🔑 COMO OBTER SERVICE ROLE KEY:**

1. Abra: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/settings/api
2. Vá para: **Settings → API**
3. Seção: **Project API keys**
4. Copie: **service_role** (secret key)
5. Cole no `.env`

**⚠️ ATENÇÃO:** 
- **NÃO use Anon Key** (não tem permissão)
- **NÃO commite `.env`** no Git
- Service Role Key ignora RLS

---

### FASE 3: Popular com Seed Data

- [ ] **Passo 3.1:** Verificar seed data
  ```bash
  python seed_data.py
  ```
  
  **Output esperado:**
  ```
  Total seed data: 80 referencias
  
  Por tipo:
    giria: 41
    meme: 15
    musica: 8
    novela: 5
    personalidade: 5
    comida: 7
    lugar: 6
  
  Por região:
    nacional: 60
    sudeste: 10
    nordeste: 8
    sul: 2
  ```

- [ ] **Passo 3.2:** Executar inserção
  ```bash
  python insert_seed_data.py
  ```

  **Output esperado:**
  ```
  2025-10-01 01:00:00 - INFO - Loading seed data...
  2025-10-01 01:00:00 - INFO - Loaded 80 seed records
  2025-10-01 01:00:00 - INFO - Supabase client initialized
  2025-10-01 01:00:00 - INFO - Table 'cultural_references' exists
  2025-10-01 01:00:00 - INFO - Found 0 existing terms
  2025-10-01 01:00:00 - INFO - After filtering: 80 new records to insert
  2025-10-01 01:00:00 - INFO - Inserting 80 records in 2 batches
  Inserting batches: 100%|██████████| 2/2 [00:02<00:00,  1.2s/it]
  2025-10-01 01:00:02 - INFO - SEED DATA INSERTION COMPLETED
  2025-10-01 01:00:02 - INFO - Total inserted: 80
  2025-10-01 01:00:02 - INFO - Total errors: 0
  2025-10-01 01:00:02 - INFO - Database now has 80 total references
  ```

- [ ] **Passo 3.3:** Verificar dados no Supabase
  ```sql
  -- Total
  SELECT COUNT(*) FROM cultural_references;
  -- Deve retornar: 80
  
  -- Amostra
  SELECT termo, tipo, regiao FROM cultural_references LIMIT 10;
  ```

---

### FASE 4: Testar Funcionalidades

- [ ] **Passo 4.1:** Testar função de busca aleatória
  ```sql
  SELECT * FROM get_random_cultural_reference('giria', 'nacional');
  ```

- [ ] **Passo 4.2:** Testar busca textual
  ```sql
  SELECT * FROM search_cultural_references('crush', 5);
  ```

- [ ] **Passo 4.3:** Testar estatísticas
  ```sql
  SELECT * FROM get_cultural_references_stats();
  ```

- [ ] **Passo 4.4:** Testar RLS policies
  ```sql
  -- Como anon (leitura deve funcionar)
  SELECT * FROM cultural_references LIMIT 5;
  
  -- Inserção como anon (deve falhar)
  -- Isso é esperado! Apenas authenticated pode inserir
  ```

---

### FASE 5: (Opcional) Web Scraping

⚠️ **NOTA:** Script atual usa mock data. Para scraping real, adaptar código.

- [ ] **Passo 5.1:** Revisar código do scraper
  ```bash
  notepad scraper.py
  ```

- [ ] **Passo 5.2:** Adaptar para fontes reais
  ```python
  # Substituir _generate_mock_girias() por scraping real
  def scrape_dicionario_informal(self) -> List[Dict]:
      soup = self.fetch_page('https://fonte-real.com')
      # Implementar parsing
      ...
  ```

- [ ] **Passo 5.3:** Executar scraper
  ```bash
  python scraper.py
  ```

- [ ] **Passo 5.4:** Verificar logs
  ```bash
  type scraper.log
  ```

---

## 🧪 VALIDAÇÃO FINAL

### Testes SQL

```sql
-- 1. Verificar total de registros
SELECT COUNT(*) as total FROM cultural_references;
-- Esperado: >= 80

-- 2. Distribuição por tipo
SELECT tipo, COUNT(*) as count
FROM cultural_references
GROUP BY tipo
ORDER BY count DESC;

-- 3. Distribuição por região
SELECT regiao, COUNT(*) as count
FROM cultural_references
GROUP BY regiao
ORDER BY count DESC;

-- 4. Buscar por termo
SELECT * FROM cultural_references
WHERE termo ILIKE '%crush%';

-- 5. Full-text search
SELECT termo, significado
FROM cultural_references
WHERE to_tsvector('portuguese', termo || ' ' || significado) 
      @@ plainto_tsquery('portuguese', 'paquera')
LIMIT 10;

-- 6. Testar constraint de tipo inválido (deve falhar)
INSERT INTO cultural_references (termo, tipo, significado)
VALUES ('Teste', 'tipo_invalido', 'Teste');
-- Esperado: ERROR - constraint "tipo_valido" violated

-- 7. Testar unique constraint (deve falhar)
INSERT INTO cultural_references (termo, tipo, significado)
VALUES ('Crush', 'giria', 'Teste duplicado');
-- Esperado: ERROR - duplicate key "termo"
```

### Testes Python

```python
# Script de teste
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()

client = create_client(
    os.getenv('SUPABASE_URL'),
    os.getenv('SUPABASE_KEY')
)

# 1. Contar registros
result = client.table('cultural_references').select('id', count='exact').execute()
print(f"Total: {result.count}")

# 2. Buscar por tipo
result = client.table('cultural_references').select('*').eq('tipo', 'giria').limit(5).execute()
print(f"Gírias: {len(result.data)}")

# 3. Função random
result = client.rpc('get_random_cultural_reference', {
    'reference_type': 'meme',
    'reference_region': 'nacional'
}).execute()
print(f"Random meme: {result.data}")

# 4. Função search
result = client.rpc('search_cultural_references', {
    'search_query': 'vibe',
    'max_results': 5
}).execute()
print(f"Search results: {len(result.data)}")

# 5. Stats
result = client.rpc('get_cultural_references_stats').execute()
print(f"Stats: {result.data}")
```

---

## 📊 MÉTRICAS DE SUCESSO

### Objetivo: 1000+ Referências

**Status Atual:** ~80 (seed data inicial)

**Para alcançar 1000+:**

1. **Expandir seed_data.py**
   - Adicionar mais gírias (300+)
   - Adicionar mais memes (200+)
   - Adicionar mais músicas (150+)
   - Adicionar mais novelas/séries (100+)
   - Adicionar mais personalidades (100+)
   - Adicionar mais comidas/lugares (150+)

2. **Implementar scrapers reais**
   - Dicionário Informal (gírias)
   - Know Your Meme Brasil (memes)
   - Letras.mus.br (músicas)
   - Wikipedia PT (novelas/personalidades)
   - Reddit Brasil (expressões modernas)
   - TikTok/YouTube (tendências)

3. **Curadoria manual**
   - Revisar qualidade
   - Validar contexto cultural
   - Garantir relevância para flerte

---

## 🚨 TROUBLESHOOTING

### Erro: "relation does not exist"

**Causa:** Tabela não criada  
**Solução:** Executar migration SQL (Fase 1)

### Erro: "permission denied"

**Causa:** Usando Anon Key ao invés de Service Role Key  
**Solução:** Trocar key no `.env`

### Erro: "ModuleNotFoundError"

**Causa:** Dependências não instaladas  
**Solução:** `pip install -r requirements.txt`

### Erro: "duplicate key value"

**Causa:** Termo já existe  
**Solução:** Normal! Script pula automaticamente

### Scraper retorna 0 resultados

**Causa:** Mock data ou scraping falhou  
**Solução:** Verificar logs `scraper.log`

---

## 📈 PRÓXIMOS PASSOS

Após setup completo:

1. **Integrar com Edge Function**
   ```typescript
   // supabase/functions/analyze-conversation/index.ts
   
   // Buscar referências aleatórias
   const { data: refs } = await supabaseAdmin
     .rpc('get_random_cultural_reference', {
       reference_type: 'giria',
       reference_region: 'nacional'
     });
   
   // Incluir no prompt do GPT
   const culturalContext = `Referência cultural: ${refs[0].termo} - ${refs[0].exemplo_uso}`;
   ```

2. **Criar endpoint REST**
   ```dart
   // Flutter: Buscar referências
   final response = await supabase
     .from('cultural_references')
     .select()
     .eq('tipo', 'meme')
     .limit(10);
   ```

3. **Dashboard de curadoria**
   - Interface web para revisar
   - Aprovar/rejeitar referências
   - Editar dados manualmente

4. **Automação**
   - Cron job para scraping diário
   - Alertas de qualidade de dados
   - Backup automático

---

## ✅ CONCLUSÃO

Após completar todos os passos, você terá:

- ✅ Tabela `cultural_references` criada
- ✅ Índices e full-text search configurados
- ✅ RLS policies ativas
- ✅ 3 funções helper disponíveis
- ✅ 80+ referências culturais inseridas
- ✅ Scripts Python funcionais
- ✅ Sistema escalável para 1000+ refs

**Status:** 🟢 Pronto para expansão

**Próximo milestone:** 1000 referências catalogadas

---

**Desenvolvido com ❤️ para o FlertAI** 🇧🇷🚀
