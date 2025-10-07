#!/bin/bash
# Script para aplicar migration de contexto e métricas
# Uso: ./apply_migration.sh

set -e

echo "🔄 Aplicando migration de contexto e métricas..."

# Verificar se supabase CLI está instalado
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI não encontrado. Instale com: npm install -g supabase"
    exit 1
fi

# Verificar se estamos no diretório correto
if [ ! -f "supabase/config.toml" ]; then
    echo "❌ Arquivo supabase/config.toml não encontrado. Execute no diretório raiz do projeto."
    exit 1
fi

# Aplicar migration
echo "📄 Aplicando migration: 20251005_add_context_and_metrics.sql"
supabase db push

if [ $? -eq 0 ]; then
    echo "✅ Migration aplicada com sucesso!"
    echo ""
    echo "📋 Mudanças aplicadas:"
    echo "   - conversations.analysis_result (jsonb)"
    echo "   - conversations.exhausted_anchors (text[])"
    echo "   - generation_metrics (nova tabela)"
    echo "   - Índices de performance criados"
    echo ""
    echo "🎯 Tabelas afetadas:"
    echo "   - conversations: +2 colunas"
    echo "   - generation_metrics: nova tabela"
    echo "   - Índices: +3 índices"
    echo ""
    echo "✅ Pronto para usar persistência de contexto!"
else
    echo "❌ Falha ao aplicar migration"
    exit 1
fi
