# 🗄️ 08 - SQL

Documentação completa de **scripts SQL, schema e migrações** do FlertAI.

---

## 📚 ESTRUTURA DESTA SEÇÃO

### 📋 **schema/** - Schema do Banco de Dados
Estrutura completa do PostgreSQL:

| Arquivo | Descrição |
|---------|-----------|
| `supabase_schema.sql` | **Schema completo** do banco de dados |

### 🔄 **migrations/** - Migrações
Scripts de migração ordenados:

| Arquivo | Ordem | Descrição |
|---------|-------|-----------|
| `01_criar_tabela.sql` | 1️⃣ | Criação de tabelas principais |
| `02_indices_rls.sql` | 2️⃣ | Índices e Row Level Security (RLS) |
| `03_funcoes_helper.sql` | 3️⃣ | Funções helper do PostgreSQL |
| `03_funcoes_helper_corrigida.sql` | 3️⃣ (correção) | Versão corrigida das funções |
| `04_seed_data.sql` | 4️⃣ | Dados iniciais (seed) |

### 🔍 **queries/** - Queries Úteis
Consultas SQL para manutenção:

| Arquivo | Finalidade |
|---------|------------|
| `correcao_rapida_stats.sql` | Correção rápida de estatísticas |
| `verificar_01_tabela.sql` | Verificação de tabelas |
| `verificar_02_funcoes.sql` | Verificação de funções |
| `verificar_final.sql` | Verificação final completa |

### 📋 **Arquivos Raiz**
| Arquivo | Descrição |
|---------|-----------|
| `README_COMANDOS_SEPARADOS.md` | Guia de comandos SQL separados |

---

## 🎯 TABELAS PRINCIPAIS

### **profiles**
Perfis de usuários:
```sql
- id (uuid, PK)
- user_id (uuid, FK)
- name (text)
- region (text)
- created_at (timestamp)
```

### **conversations**
Conversas do usuário:
```sql
- id (uuid, PK)
- user_id (uuid, FK)
- image_path (text)
- tone (text)
- focus (text)
- created_at (timestamp)
```

### **suggestions**
Sugestões geradas pela IA:
```sql
- id (uuid, PK)
- conversation_id (uuid, FK)
- suggestion_text (text)
- feedback_score (int)
- created_at (timestamp)
```

### **cultural_references**
Referências culturais brasileiras:
```sql
- id (uuid, PK)
- category (text)
- reference (text)
- context (text)
- region (text)
```

---

## 🔒 SEGURANÇA

### **Row Level Security (RLS)**
Todas as tabelas possuem RLS habilitado:
- ✅ **profiles:** Usuário só acessa próprio perfil
- ✅ **conversations:** Usuário só acessa próprias conversas
- ✅ **suggestions:** Usuário só acessa próprias sugestões
- ✅ **cultural_references:** Leitura pública, escrita restrita

### **Políticas Implementadas:**
- `SELECT`: Baseado em `user_id = auth.uid()`
- `INSERT`: Validação de autenticação
- `UPDATE`: Apenas próprios registros
- `DELETE`: Apenas próprios registros

---

## 📦 ORDEM DE EXECUÇÃO

Para configurar banco de dados do zero:

```bash
# 1. Criar schema completo
psql -f documentacao/08-sql/schema/supabase_schema.sql

# OU executar migrações em ordem:
psql -f documentacao/08-sql/migrations/01_criar_tabela.sql
psql -f documentacao/08-sql/migrations/02_indices_rls.sql
psql -f documentacao/08-sql/migrations/03_funcoes_helper_corrigida.sql
psql -f documentacao/08-sql/migrations/04_seed_data.sql

# 2. Verificar instalação
psql -f documentacao/08-sql/queries/verificar_final.sql
```

---

## 🔗 NAVEGAÇÃO

- **⬅️ Anterior:** [07-relatorios/](../07-relatorios/) - Relatórios por versão
- **➡️ Próximo:** [09-referencias/](../09-referencias/) - Referências externas

---

**📅 Seção criada em:** 2025-10-02
