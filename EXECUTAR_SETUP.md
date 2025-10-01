# 🚀 COMANDOS PARA EXECUTAR SETUP

**Data:** 2025-10-01 00:53  
**Status:** Pronto para execução manual

---

## ⚠️ IMPORTANTE: MIGRATION SQL NO SUPABASE

**Eu não tenho acesso direto ao projeto FlertAI no Supabase.**  
Você precisa executar a migration SQL manualmente:

### PASSO 1: Aplicar Migration SQL

1. **Abra o Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf
   ```

2. **Vá para SQL Editor:**
   - Dashboard → SQL Editor → New query

3. **Copie e cole o SQL:**
   ```
   Arquivo: supabase/migrations/20251001_create_cultural_references.sql
   ```
   
4. **Execute o SQL** (botão "Run" ou Ctrl+Enter)

5. **Verifique a criação:**
   ```sql
   SELECT * FROM cultural_references LIMIT 5;
   ```

**✅ RESULTADO ESPERADO:**
- Tabela `cultural_references` criada
- 25 registros iniciais inseridos
- Funções `get_random_cultural_reference`, `search_cultural_references`, `get_cultural_references_stats` criadas

---

## 🐍 COMANDOS PYTHON

### PASSO 2: Configurar Ambiente Virtual

```powershell
# Navegar para diretório
cd c:\Users\vanze\FlertAI\flerta_ai\scripts\scraper

# Criar venv (já executei)
python -m venv venv

# Ativar venv
.\venv\Scripts\activate

# Verificar ativação (deve mostrar (venv) no prompt)
```

### PASSO 3: Instalar Dependências

```powershell
# Com venv ativado
pip install -r requirements.txt
```

### PASSO 4: Configurar .env

```powershell
# Copiar exemplo
copy .env.example .env

# Editar .env
notepad .env
```

**Configure no .env:**
```env
SUPABASE_URL=https://olojvpoqosrjcoxygiyf.supabase.co
SUPABASE_KEY=your_service_role_key_here
```

**🔑 Como obter Service Role Key:**
1. Vá para: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/settings/api
2. Settings → API → Project API keys
3. Copie a **service_role** key (não a anon key!)
4. Cole no `.env`

### PASSO 5: Testar Seed Data

```powershell
# Ver quantos registros serão inseridos
python seed_data.py
```

**Output esperado:**
```
Total seed data: 80 referencias

Por tipo:
  giria: 41
  meme: 15
  musica: 8
  ...
```

### PASSO 6: Inserir Dados no Supabase

```powershell
# Com venv ativado e .env configurado
python insert_seed_data.py
```

**Output esperado:**
```
2025-10-01 00:55:00 - INFO - Loading seed data...
2025-10-01 00:55:00 - INFO - Loaded 80 seed records
2025-10-01 00:55:00 - INFO - Supabase client initialized
2025-10-01 00:55:00 - INFO - Table 'cultural_references' exists
2025-10-01 00:55:00 - INFO - Found 25 existing terms
2025-10-01 00:55:00 - INFO - After filtering: 55 new records to insert
Inserting batches: 100%|██████████| 2/2 [00:02<00:00]
2025-10-01 00:55:02 - INFO - Total inserted: 55
2025-10-01 00:55:02 - INFO - Database now has 80 total references
```

---

## ✅ VERIFICAÇÃO FINAL

### No Supabase SQL Editor:

```sql
-- 1. Contar total
SELECT COUNT(*) as total FROM cultural_references;
-- Esperado: 80

-- 2. Ver amostra
SELECT termo, tipo, regiao FROM cultural_references LIMIT 10;

-- 3. Testar função random
SELECT * FROM get_random_cultural_reference('giria', 'nacional');

-- 4. Testar busca
SELECT * FROM search_cultural_references('crush', 5);

-- 5. Ver estatísticas
SELECT * FROM get_cultural_references_stats();
```

---

## 🎯 RESUMO DO QUE EXECUTAR

### ✅ O que já fiz:
- [x] Criado todos os arquivos necessários
- [x] Verificado Python instalado (3.13.5)
- [x] Iniciado criação do venv

### ⚠️ O que VOCÊ precisa fazer:

1. **CRÍTICO: Aplicar migration SQL no Supabase Dashboard**
   - Copiar `supabase/migrations/20251001_create_cultural_references.sql`
   - Colar e executar no SQL Editor
   - Verificar criação da tabela

2. **Configurar ambiente Python:**
   ```powershell
   cd c:\Users\vanze\FlertAI\flerta_ai\scripts\scraper
   .\venv\Scripts\activate
   pip install -r requirements.txt
   copy .env.example .env
   notepad .env  # Configurar SUPABASE_KEY
   ```

3. **Inserir seed data:**
   ```powershell
   python seed_data.py  # Testar
   python insert_seed_data.py  # Inserir
   ```

4. **Verificar no Supabase:**
   ```sql
   SELECT COUNT(*) FROM cultural_references;
   ```

---

## 📊 RESULTADO FINAL ESPERADO

Após executar todos os comandos:

- ✅ Tabela `cultural_references` criada no Supabase
- ✅ 80+ referências culturais inseridas
- ✅ 3 funções SQL helper ativas
- ✅ RLS policies configuradas
- ✅ Ambiente Python pronto
- ✅ Sistema escalável para 1000+ refs

---

## 🆘 TROUBLESHOOTING

### Erro: "relation does not exist"
**Solução:** Você não aplicou a migration SQL. Execute PASSO 1.

### Erro: "permission denied"
**Solução:** Está usando Anon Key. Use Service Role Key no `.env`.

### Erro: "No module named 'supabase'"
**Solução:** Ativar venv e executar `pip install -r requirements.txt`.

---

## 📞 PRÓXIMOS PASSOS

Após executar este setup:

1. **Expandir para 1000+ refs** editando `seed_data.py`
2. **Integrar com Edge Function** seguindo `docs/INTEGRACAO_CULTURAL_REFERENCES.md`
3. **Testar sugestões** com referências culturais no app

---

**Pronto para executar! 🚀**

Execute os comandos acima em ordem e você terá o sistema funcionando em 5-10 minutos.
