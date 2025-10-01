# 📊 Scripts de Análise - FlertAI

Scripts Python para análise e processamento de dados do FlertAI.

---

## 📁 Arquivos

### `analyze_feedback.py`
Script principal para análise de feedback dos usuários sobre sugestões da IA.

**Funcionalidades:**
- ✅ Análise de métricas gerais (likes/dislikes)
- ✅ Análise por tom de mensagem
- ✅ Análise por focus_tags
- ✅ Identificação de sugestões problemáticas
- ✅ Geração de relatórios detalhados
- ✅ Recomendações automáticas

---

## 🚀 Configuração

### 1. Instalar Dependências

```bash
cd scripts
pip install -r requirements.txt
```

### 2. Configurar Variáveis de Ambiente

Crie um arquivo `.env` no diretório `scripts/`:

```bash
SUPABASE_URL=https://sua-url.supabase.co
SUPABASE_SERVICE_KEY=sua-service-key-aqui
ANALYSIS_DAYS=7  # Número de dias para análise (opcional, padrão: 7)
```

⚠️ **Importante:** Use a **Service Key** (não a anon key) para acesso completo aos dados.

---

## 🔧 Uso

### Análise de Feedback

Executar análise dos últimos 7 dias:

```bash
python analyze_feedback.py
```

Analisar período personalizado:

```bash
ANALYSIS_DAYS=30 python analyze_feedback.py
```

### Relatórios Gerados

Os relatórios são salvos automaticamente em:
```
reports/feedback_report_YYYYMMDD_HHMMSS.txt
```

---

## 📊 Estrutura do Relatório

### Métricas Gerais
- Total de feedbacks
- Quantidade e percentual de likes
- Quantidade e percentual de dislikes

### Análise por Tom
- Performance de cada tom (Flertar, Casual, Engraçado, etc.)
- Taxa de aprovação/rejeição
- Identificação de tons problemáticos

### Análise por Focus_Tags
- Performance de cada focus_tag
- Combinações mais/menos efetivas
- Tags com alta rejeição

### Sugestões Problemáticas
- Lista de sugestões com >70% de dislikes
- Frequência de rejeição
- Padrões identificados

### Recomendações
- Ações sugeridas baseadas nos dados
- Prioridades de ajuste
- Status geral do sistema

---

## 🔄 Execução Periódica

### Cronjob (Linux/Mac)

Adicionar ao crontab para execução semanal:

```bash
# Executar toda segunda-feira às 9h
0 9 * * 1 cd /caminho/para/scripts && python analyze_feedback.py
```

### Task Scheduler (Windows)

1. Abrir "Agendador de Tarefas"
2. Criar nova tarefa
3. Configurar trigger (semanal)
4. Ação: Executar `python analyze_feedback.py`

### GitHub Actions

Exemplo de workflow para execução automática:

```yaml
name: Weekly Feedback Analysis

on:
  schedule:
    - cron: '0 9 * * 1'  # Toda segunda às 9h
  workflow_dispatch:  # Permitir execução manual

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          cd scripts
          pip install -r requirements.txt
      
      - name: Run analysis
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_SERVICE_KEY }}
        run: |
          cd scripts
          python analyze_feedback.py
      
      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: feedback-reports
          path: scripts/reports/
```

---

## 📈 Métricas de Sucesso

### Objetivos
- ✅ **+5.000 pontos de feedback** no primeiro mês
- ✅ **-15% na taxa de dislike** após primeiro ciclo
- ✅ **>85% de satisfação geral** (likes)

### KPIs Monitorados
- Taxa de aprovação por tom
- Taxa de aprovação por focus_tag
- Sugestões problemáticas identificadas
- Tempo de resposta para ajustes

---

## 🛠️ Manutenção

### Adicionar Nova Análise

1. Criar função de análise em `analyze_feedback.py`
2. Adicionar ao relatório em `generate_report()`
3. Atualizar documentação

### Ajustar Thresholds

Editar constantes no script:

```python
# Percentual mínimo de dislikes para considerar problemático
threshold = 70.0

# Mínimo de feedbacks para considerar estatisticamente significativo
min_feedbacks = 3
```

---

## 🐛 Troubleshooting

### Erro: "Variáveis de ambiente não configuradas"
**Solução:** Configure `SUPABASE_URL` e `SUPABASE_SERVICE_KEY`

### Erro: "Nenhum feedback encontrado"
**Possíveis causas:**
- Período muito curto (aumentar `ANALYSIS_DAYS`)
- Tabela vazia (usuários ainda não deram feedback)
- Problemas de conexão com Supabase

### Erro de import: "Module not found"
**Solução:**
```bash
cd scripts
pip install -r requirements.txt
```

---

## 📞 Suporte

Para questões ou sugestões sobre os scripts:
- Abrir issue no repositório
- Contatar equipe de desenvolvimento

---

**📊 Análise contínua para IA cada vez melhor!** ✨
