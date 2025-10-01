#!/usr/bin/env python3
"""
Script de Análise de Feedback - FlertAI
========================================

Este script analisa os feedbacks dos usuários sobre as sugestões geradas pela IA,
identificando padrões, problemas e oportunidades de melhoria.

Execução: python analyze_feedback.py
Frequência recomendada: Semanal ou sob demanda
"""

import os
import json
from datetime import datetime, timedelta
from collections import defaultdict
from typing import Dict, List, Tuple
import pandas as pd
from supabase import create_client, Client

# Configuração do Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL', '')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_KEY', '')  # Service key para acesso admin

def init_supabase() -> Client:
    """Inicializa cliente Supabase"""
    if not SUPABASE_URL or not SUPABASE_KEY:
        raise ValueError("Variáveis de ambiente SUPABASE_URL e SUPABASE_SERVICE_KEY são obrigatórias")
    
    return create_client(SUPABASE_URL, SUPABASE_KEY)

def fetch_feedback_data(supabase: Client, days_ago: int = 7) -> pd.DataFrame:
    """
    Busca dados de feedback dos últimos N dias
    
    Args:
        supabase: Cliente Supabase
        days_ago: Número de dias para buscar feedback
        
    Returns:
        DataFrame com feedbacks
    """
    cutoff_date = (datetime.now() - timedelta(days=days_ago)).isoformat()
    
    try:
        # Buscar feedbacks com joins para obter dados relacionados
        response = supabase.table('suggestion_feedback') \
            .select('*, conversations(tone, focus_tags, analysis_result)') \
            .gte('created_at', cutoff_date) \
            .execute()
        
        if not response.data:
            print(f"⚠️  Nenhum feedback encontrado nos últimos {days_ago} dias")
            return pd.DataFrame()
        
        # Converter para DataFrame
        df = pd.DataFrame(response.data)
        print(f"✅ {len(df)} feedbacks carregados")
        return df
        
    except Exception as e:
        print(f"❌ Erro ao buscar feedbacks: {e}")
        return pd.DataFrame()

def analyze_feedback_metrics(df: pd.DataFrame) -> Dict:
    """
    Analisa métricas gerais de feedback
    
    Args:
        df: DataFrame com feedbacks
        
    Returns:
        Dicionário com métricas
    """
    if df.empty:
        return {}
    
    total = len(df)
    likes = len(df[df['feedback_type'] == 'like'])
    dislikes = len(df[df['feedback_type'] == 'dislike'])
    like_rate = (likes / total * 100) if total > 0 else 0
    dislike_rate = (dislikes / total * 100) if total > 0 else 0
    
    return {
        'total_feedbacks': total,
        'likes': likes,
        'dislikes': dislikes,
        'like_rate': round(like_rate, 2),
        'dislike_rate': round(dislike_rate, 2),
    }

def analyze_by_tone(df: pd.DataFrame) -> List[Dict]:
    """
    Analisa feedback por tom de mensagem
    
    Args:
        df: DataFrame com feedbacks
        
    Returns:
        Lista com análise por tom
    """
    if df.empty or 'conversations' not in df.columns:
        return []
    
    # Extrair tom de cada conversa
    df['tone'] = df['conversations'].apply(
        lambda x: x.get('tone', 'unknown') if isinstance(x, dict) else 'unknown'
    )
    
    tone_stats = []
    for tone in df['tone'].unique():
        tone_df = df[df['tone'] == tone]
        total = len(tone_df)
        likes = len(tone_df[tone_df['feedback_type'] == 'like'])
        dislikes = len(tone_df[tone_df['feedback_type'] == 'dislike'])
        
        tone_stats.append({
            'tone': tone,
            'total': total,
            'likes': likes,
            'dislikes': dislikes,
            'like_rate': round((likes / total * 100) if total > 0 else 0, 2),
            'dislike_rate': round((dislikes / total * 100) if total > 0 else 0, 2),
        })
    
    # Ordenar por taxa de dislike (problemas primeiro)
    tone_stats.sort(key=lambda x: x['dislike_rate'], reverse=True)
    return tone_stats

def analyze_by_focus_tags(df: pd.DataFrame) -> List[Dict]:
    """
    Analisa feedback por focus_tags
    
    Args:
        df: DataFrame com feedbacks
        
    Returns:
        Lista com análise por focus_tags
    """
    if df.empty or 'conversations' not in df.columns:
        return []
    
    # Extrair focus_tags de cada conversa
    tag_stats = defaultdict(lambda: {'likes': 0, 'dislikes': 0, 'total': 0})
    
    for _, row in df.iterrows():
        conv = row.get('conversations', {})
        if isinstance(conv, dict):
            focus_tags = conv.get('focus_tags', [])
            if isinstance(focus_tags, list):
                for tag in focus_tags:
                    tag_stats[tag]['total'] += 1
                    if row['feedback_type'] == 'like':
                        tag_stats[tag]['likes'] += 1
                    else:
                        tag_stats[tag]['dislikes'] += 1
    
    # Converter para lista
    results = []
    for tag, stats in tag_stats.items():
        total = stats['total']
        results.append({
            'focus_tag': tag,
            'total': total,
            'likes': stats['likes'],
            'dislikes': stats['dislikes'],
            'like_rate': round((stats['likes'] / total * 100) if total > 0 else 0, 2),
            'dislike_rate': round((stats['dislikes'] / total * 100) if total > 0 else 0, 2),
        })
    
    # Ordenar por taxa de dislike
    results.sort(key=lambda x: x['dislike_rate'], reverse=True)
    return results

def identify_problem_suggestions(df: pd.DataFrame, threshold: float = 70.0) -> List[Dict]:
    """
    Identifica sugestões com alta taxa de rejeição
    
    Args:
        df: DataFrame com feedbacks
        threshold: Percentual mínimo de dislikes para considerar problemático
        
    Returns:
        Lista de sugestões problemáticas
    """
    if df.empty:
        return []
    
    # Agrupar por texto da sugestão
    suggestion_stats = df.groupby('suggestion_text').agg({
        'feedback_type': lambda x: {
            'total': len(x),
            'likes': (x == 'like').sum(),
            'dislikes': (x == 'dislike').sum(),
        }
    }).reset_index()
    
    problems = []
    for _, row in suggestion_stats.iterrows():
        stats = row['feedback_type']
        total = stats['total']
        dislikes = stats['dislikes']
        dislike_rate = (dislikes / total * 100) if total > 0 else 0
        
        if dislike_rate >= threshold and total >= 3:  # Mínimo 3 feedbacks
            problems.append({
                'suggestion_text': row['suggestion_text'],
                'total_feedbacks': total,
                'dislikes': dislikes,
                'dislike_rate': round(dislike_rate, 2),
            })
    
    # Ordenar por taxa de dislike
    problems.sort(key=lambda x: x['dislike_rate'], reverse=True)
    return problems

def generate_report(metrics: Dict, tone_analysis: List[Dict], 
                   tag_analysis: List[Dict], problems: List[Dict]) -> str:
    """
    Gera relatório em formato texto
    
    Args:
        metrics: Métricas gerais
        tone_analysis: Análise por tom
        tag_analysis: Análise por focus_tags
        problems: Sugestões problemáticas
        
    Returns:
        Relatório formatado
    """
    report = []
    report.append("=" * 80)
    report.append("RELATÓRIO DE ANÁLISE DE FEEDBACK - FlertAI")
    report.append(f"Data: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append("=" * 80)
    report.append("")
    
    # Métricas gerais
    if metrics:
        report.append("📊 MÉTRICAS GERAIS")
        report.append("-" * 40)
        report.append(f"Total de feedbacks: {metrics['total_feedbacks']}")
        report.append(f"Likes (👍): {metrics['likes']} ({metrics['like_rate']}%)")
        report.append(f"Dislikes (👎): {metrics['dislikes']} ({metrics['dislike_rate']}%)")
        report.append("")
    
    # Análise por tom
    if tone_analysis:
        report.append("🎭 ANÁLISE POR TOM DE MENSAGEM")
        report.append("-" * 40)
        for tone in tone_analysis[:5]:  # Top 5
            report.append(f"\nTom: {tone['tone']}")
            report.append(f"  Total: {tone['total']}")
            report.append(f"  👍 {tone['likes']} ({tone['like_rate']}%)")
            report.append(f"  👎 {tone['dislikes']} ({tone['dislike_rate']}%)")
        report.append("")
    
    # Análise por focus_tags
    if tag_analysis:
        report.append("🎯 ANÁLISE POR FOCUS_TAGS")
        report.append("-" * 40)
        for tag in tag_analysis[:10]:  # Top 10
            report.append(f"\nTag: {tag['focus_tag']}")
            report.append(f"  Total: {tag['total']}")
            report.append(f"  👍 {tag['likes']} ({tag['like_rate']}%)")
            report.append(f"  👎 {tag['dislikes']} ({tag['dislike_rate']}%)")
        report.append("")
    
    # Sugestões problemáticas
    if problems:
        report.append("🚨 SUGESTÕES PROBLEMÁTICAS (>70% dislikes)")
        report.append("-" * 40)
        for prob in problems[:10]:  # Top 10
            report.append(f"\nTexto: {prob['suggestion_text'][:100]}...")
            report.append(f"  Feedbacks: {prob['total_feedbacks']}")
            report.append(f"  👎 {prob['dislikes']} ({prob['dislike_rate']}%)")
        report.append("")
    
    # Recomendações
    report.append("💡 RECOMENDAÇÕES")
    report.append("-" * 40)
    
    if metrics and metrics['dislike_rate'] > 30:
        report.append("⚠️  Taxa de dislike acima de 30% - revisar prompts urgentemente")
    
    if tone_analysis:
        worst_tone = tone_analysis[0]
        if worst_tone['dislike_rate'] > 50:
            report.append(f"⚠️  Tom '{worst_tone['tone']}' com {worst_tone['dislike_rate']}% de rejeição - ajustar instruções")
    
    if tag_analysis:
        worst_tag = tag_analysis[0]
        if worst_tag['dislike_rate'] > 50:
            report.append(f"⚠️  Focus_tag '{worst_tag['focus_tag']}' com {worst_tag['dislike_rate']}% de rejeição - revisar contexto")
    
    if len(problems) > 5:
        report.append(f"⚠️  {len(problems)} sugestões com alta rejeição - revisar padrões e templates")
    
    if not metrics or metrics['dislike_rate'] < 15:
        report.append("✅ Sistema funcionando bem! Continuar monitorando.")
    
    report.append("")
    report.append("=" * 80)
    
    return "\n".join(report)

def save_report(report: str, filename: str = None):
    """
    Salva relatório em arquivo
    
    Args:
        report: Conteúdo do relatório
        filename: Nome do arquivo (opcional)
    """
    if not filename:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"feedback_report_{timestamp}.txt"
    
    reports_dir = os.path.join(os.path.dirname(__file__), '..', 'reports')
    os.makedirs(reports_dir, exist_ok=True)
    
    filepath = os.path.join(reports_dir, filename)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"\n✅ Relatório salvo em: {filepath}")

def main():
    """Função principal"""
    print("\n" + "=" * 80)
    print("📊 INICIANDO ANÁLISE DE FEEDBACK - FlertAI")
    print("=" * 80 + "\n")
    
    # Inicializar Supabase
    try:
        supabase = init_supabase()
    except ValueError as e:
        print(f"❌ Erro: {e}")
        print("\n💡 Configure as variáveis de ambiente:")
        print("   export SUPABASE_URL='sua_url'")
        print("   export SUPABASE_SERVICE_KEY='sua_key'")
        return
    
    # Buscar dados
    days = int(os.getenv('ANALYSIS_DAYS', '7'))
    print(f"🔍 Buscando feedbacks dos últimos {days} dias...")
    df = fetch_feedback_data(supabase, days_ago=days)
    
    if df.empty:
        print("\n⚠️  Sem dados para analisar. Encerrando.")
        return
    
    # Análises
    print("\n📈 Calculando métricas...")
    metrics = analyze_feedback_metrics(df)
    
    print("🎭 Analisando por tom...")
    tone_analysis = analyze_by_tone(df)
    
    print("🎯 Analisando por focus_tags...")
    tag_analysis = analyze_by_focus_tags(df)
    
    print("🚨 Identificando sugestões problemáticas...")
    problems = identify_problem_suggestions(df, threshold=70.0)
    
    # Gerar relatório
    print("\n📝 Gerando relatório...")
    report = generate_report(metrics, tone_analysis, tag_analysis, problems)
    
    # Exibir relatório
    print("\n" + report)
    
    # Salvar relatório
    save_report(report)
    
    print("\n✅ Análise concluída com sucesso!")
    print("=" * 80 + "\n")

if __name__ == "__main__":
    main()
