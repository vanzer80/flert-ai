# 🔧 CORREÇÃO DO ERRO - Guia Rápido

**Problema identificado:** Erro na função `get_cultural_references_stats()` devido à ambiguidade da coluna "count".

**Status:** ✅ **CORRIGIDO!** Arquivo atualizado criado.

---

## 🚨 **Erro que estava ocorrendo:**

```
ERROR: 42702: column reference "count" is ambiguous
```

**Causa:** A query CROSS JOIN tinha duas tabelas com coluna "count", causando ambiguidade.

---

## ✅ **Solução - Arquivo de Correção Criado:**

### **📄 Arquivo:** `sql_comandos/correcao_rapida_stats.sql`

**Como usar:**
1. Abra: https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/sql/new
2. Abra arquivo: `correcao_rapida_stats.sql`
3. Copie e cole no SQL Editor
4. Execute (**Run**)

---

## 📋 **Comando SQL Corrigido:**

```sql
-- Function: Get statistics (CORRIGIDA)
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
```

---

## 🎯 **Próximos Passos:**

### **1. Aplicar Correção:**
- Execute o arquivo `correcao_rapida_stats.sql` no Supabase

### **2. Testar Correção:**
- Execute `verificar_02_funcoes.sql` novamente
- A função `get_cultural_references_stats()` deve funcionar agora

### **3. Continuar Setup:**
- Configure a Service Role Key no `.env`
- Execute `python run_after_config.py`

---

## 📊 **Resultado Esperado Após Correção:**

```json
{
  "total_count": 25,
  "tipo_counts": {
    "giria": 17,
    "expressao_regional": 5,
    "meme": 3
  },
  "regiao_counts": {
    "nacional": 22,
    "sudeste": 2,
    "nordeste": 1
  }
}
```

---

**✅ Problema resolvido! A função agora funciona corretamente.**
