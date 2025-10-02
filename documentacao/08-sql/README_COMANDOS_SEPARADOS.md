# 📋 COMANDOS SQL SEPARADOS - Guia de Uso

**Agora você tem comandos SQL separados para facilitar a cópia e cola!**

---

## 📁 **Arquivos Criados:**

### **1. Criação da Tabela:**
- 📄 `01_criar_tabela.sql` - Cria a tabela com constraints

### **2. Índices e Segurança:**
- 📄 `02_indices_rls.sql` - Índices, trigger, RLS policies

### **3. Funções Helper:**
- 📄 `03_funcoes_helper.sql` - 3 funções SQL úteis

### **4. Dados Iniciais:**
- 📄 `04_seed_data.sql` - 25 referências iniciais

### **5. Verificações:**
- 📄 `verificar_01_tabela.sql` - Verificar criação da tabela
- 📄 `verificar_02_funcoes.sql` - Testar funções SQL
- 📄 `verificar_final.sql` - Verificação completa após dados

---

## 🚀 **Como Usar - Passo a Passo:**

### **📍 PASSO 1: Criar Tabela**
1. Abra: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/sql/new
2. Abra arquivo: `sql_comandos/01_criar_tabela.sql`
3. Copie TODO o conteúdo (Ctrl+A, Ctrl+C)
4. Cole no SQL Editor do Supabase (Ctrl+V)
5. Clique em **Run** (ou Ctrl+Enter)

### **📍 PASSO 2: Índices e RLS**
1. Abra arquivo: `sql_comandos/02_indices_rls.sql`
2. Copie TODO o conteúdo
3. Cole no SQL Editor
4. Clique em **Run**

### **📍 PASSO 3: Funções Helper**
1. Abra arquivo: `sql_comandos/03_funcoes_helper.sql`
2. Copie TODO o conteúdo
3. Cole no SQL Editor
4. Clique em **Run**

### **📍 PASSO 4: Seed Data Inicial**
1. Abra arquivo: `sql_comandos/04_seed_data.sql`
2. Copie TODO o conteúdo
3. Cole no SQL Editor
4. Clique em **Run**

### **📍 PASSO 5: Verificar**
1. Abra arquivo: `sql_comandos/verificar_01_tabela.sql`
2. Copie e execute no SQL Editor
3. Abra arquivo: `sql_comandos/verificar_02_funcoes.sql`
4. Copie e execute

---

## ✅ **Resultado Esperado Após Passo 5:**

```
total: 25

termo         | tipo             | regiao
-------------+------------------+--------
Crush        | giria            | nacional
Mozão        | giria            | nacional
Vibe         | giria            | nacional
...          | ...              | ...

id                                   | termo | tipo  | significado | exemplo_uso | regiao   | contexto_flerte
-------------------------------------+-------+-------+-------------+-------------+----------+----------------
123e4567-e89b-12d3-a456-426614174000 | Crush | giria | Paquera...  | Então você...| nacional | Tom flertante...

id                                   | termo | tipo  | significado | exemplo_uso | regiao   | contexto_flerte | relevance
-------------------------------------+-------+-------+-------------+-------------+----------+----------------+-----------
123e4567-e89b-12d3-a456-426614174000 | Crush | giria | Paquera...  | Então você...| nacional | Tom flertante...| 0.5
...
```

---

## 🎯 **Próximos Passos:**

### **1. Configurar Service Role Key**
- Vá para: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/settings/api
- Copie a chave **service_role**
- Cole no arquivo: `scripts/scraper/.env`

### **2. Executar Script Python**
```powershell
cd c:\Users\vanze\FlertAI\flerta_ai\scripts\scraper
python run_after_config.py
```

### **3. Verificação Final**
- Abra arquivo: `sql_comandos/verificar_final.sql`
- Copie e execute no Supabase

---

## ⚡ **Vantagens Agora:**

✅ **Cada comando em arquivo separado**  
✅ **Fácil de copiar e colar**  
✅ **Sem confusão entre comandos**  
✅ **Pode executar um por vez**  
✅ **Verificações separadas**  

---

## 📊 **Links Importantes:**

- **🔗 Supabase SQL Editor:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/sql/new
- **🔗 API Settings:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/settings/api
- **📁 Arquivos SQL:** `sql_comandos/` (todos os comandos separados)

---

**🎉 Pronto! Agora é só copiar e colar um arquivo de cada vez!** 🚀
