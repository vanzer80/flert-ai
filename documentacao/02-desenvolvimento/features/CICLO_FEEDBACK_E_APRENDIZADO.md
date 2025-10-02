# 🔄 CICLO DE FEEDBACK E APRENDIZADO DA IA

**Data:** 2025-10-01 16:57  
**Versão:** 1.0  
**Status:** 📚 Guia Técnico Completo

---

## 🎯 **OBJETIVO DESTE DOCUMENTO**

Explicar de forma detalhada e técnica:
1. Como extrair os dados de feedback coletados
2. Como esses dados são usados para melhorar a IA
3. O fluxo completo desde a coleta até o refinamento
4. Onde e como o "aprendizado" é armazenado

---

## ⚠️ **IMPORTANTE: ENTENDENDO O SISTEMA**

### **🔍 O que o sistema FAZ:**
✅ Coleta feedbacks dos usuários (👍 👎)  
✅ Armazena dados estruturados no Supabase  
✅ Gera relatórios de análise  
✅ Identifica padrões e problemas  
✅ Fornece recomendações para ajustes  

### **❌ O que o sistema NÃO FAZ:**
❌ Treinar um modelo de Machine Learning automaticamente  
❌ Fazer a IA "aprender sozinha" com os feedbacks  
❌ Ajustar prompts automaticamente  
❌ Fine-tuning do modelo OpenAI  

### **🎯 Modelo Atual:**
> **CICLO MANUAL DE MELHORIA CONTÍNUA**
> 
> Feedbacks → Análise Humana → Ajustes Manuais → Prompts Refinados → IA Melhorada

---

## 📊 **1. COMO EXTRAIR OS DADOS DE FEEDBACK**

### **A. Via Script Python (Recomendado)**

**Arquivo:** `scripts/analyze_feedback.py`

```bash
# Configurar credenciais
cd scripts
export SUPABASE_URL='sua-url'
export SUPABASE_SERVICE_KEY='sua-service-key'

# Executar análise
python analyze_feedback.py
```

**O que o script faz:**
1. Conecta ao Supabase usando credenciais
2. Busca feedbacks dos últimos 7 dias (configurável)
3. Calcula métricas gerais (likes/dislikes)
4. Analisa por tom de mensagem
5. Analisa por focus_tags
6. Identifica sugestões problemáticas
7. Gera relatório em `reports/feedback_report_YYYYMMDD_HHMMSS.txt`

**Exemplo de output:**
```
📊 MÉTRICAS GERAIS
Total de feedbacks: 1,234
Likes (👍): 987 (80%)
Dislikes (👎): 247 (20%)

🎭 ANÁLISE POR TOM
Tom: Flertar - 85% likes
Tom: Casual - 78% likes
Tom: Sensual - 45% likes ⚠️

🚨 SUGESTÕES PROBLEMÁTICAS
"Você é gostosa" - 92% dislikes (23 feedbacks) ⚠️
```

---

### **B. Via SQL Direto no Supabase**

**1. Query Básica - Todos os Feedbacks:**
```sql
SELECT 
  id,
  user_id,
  conversation_id,
  suggestion_text,
  suggestion_index,
  feedback_type,
  comentario,
  created_at
FROM suggestion_feedback
ORDER BY created_at DESC
LIMIT 100;
```

**2. Métricas Gerais:**
```sql
SELECT 
  feedback_type,
  COUNT(*) as total,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentual
FROM suggestion_feedback
GROUP BY feedback_type;
```

**3. Análise por Tom:**
```sql
SELECT 
  c.tone,
  sf.feedback_type,
  COUNT(*) as total
FROM suggestion_feedback sf
JOIN conversations c ON sf.conversation_id = c.id
GROUP BY c.tone, sf.feedback_type
ORDER BY c.tone, sf.feedback_type;
```

**4. Sugestões Mais Rejeitadas:**
```sql
SELECT 
  suggestion_text,
  COUNT(*) FILTER (WHERE feedback_type = 'dislike') as dislikes,
  COUNT(*) as total,
  ROUND(
    COUNT(*) FILTER (WHERE feedback_type = 'dislike') * 100.0 / COUNT(*),
    2
  ) as dislike_rate
FROM suggestion_feedback
GROUP BY suggestion_text
HAVING COUNT(*) >= 5
ORDER BY dislike_rate DESC
LIMIT 20;
```

**5. Timeline de Feedbacks:**
```sql
SELECT 
  DATE(created_at) as dia,
  feedback_type,
  COUNT(*) as total
FROM suggestion_feedback
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at), feedback_type
ORDER BY dia DESC, feedback_type;
```

---

### **C. Via API REST do Supabase**

**Exemplo em JavaScript:**
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://sua-url.supabase.co',
  'sua-service-key'
)

// Buscar feedbacks dos últimos 7 dias
const { data, error } = await supabase
  .from('suggestion_feedback')
  .select(`
    *,
    conversations(tone, focus_tags)
  `)
  .gte('created_at', new Date(Date.now() - 7*24*60*60*1000).toISOString())
  .order('created_at', { ascending: false })

if (error) console.error(error)
else console.log(data)
```

---

## 🤖 **2. COMO OS DADOS SÃO USADOS PELA IA**

### **⚠️ REALIDADE: Não é Aprendizado Automático**

**Modelo Atual:**
```
┌─────────────────────────────────────────────────────────┐
│  1. COLETA DE FEEDBACKS (Automática)                   │
│     - Usuários clicam 👍 ou 👎                         │
│     - Dados salvos no Supabase                         │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  2. ANÁLISE (Semi-Automática)                          │
│     - Script Python roda semanalmente                  │
│     - Gera relatório com métricas e problemas          │
│     - Humanos analisam o relatório                     │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  3. IDENTIFICAÇÃO DE PROBLEMAS (Manual)                │
│     - Equipe revisa relatório                          │
│     - Identifica padrões problemáticos                 │
│     - Define ações corretivas                          │
│       Exemplo: "Tom Sensual tem 55% de rejeição"       │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  4. AJUSTE DE PROMPTS (Manual)                         │
│     - Desenvolvedores editam código                    │
│     - Modificam instruções da IA                       │
│     - Ajustam temperatura, tom, exemplos               │
│     - Testam novas versões                             │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  5. DEPLOY (Manual)                                     │
│     - Commit das mudanças                              │
│     - Deploy em produção                               │
│     - IA usa novos prompts                             │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  6. VALIDAÇÃO (Automática)                             │
│     - Novos feedbacks coletados                        │
│     - Compara métricas antes/depois                    │
│     - Ciclo recomeça                                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 **3. EXEMPLO PRÁTICO: DO FEEDBACK AO REFINAMENTO**

### **Cenário Real:**

**Semana 1 - Coleta:**
```
Tom "Sensual" recebe 100 feedbacks:
- 45 likes (45%)
- 55 dislikes (55%) ⚠️ PROBLEMA!
```

**Semana 1 - Análise (Script Python):**
```
🚨 ALERTA: Tom Sensual com 55% de rejeição
Sugestões mais rejeitadas:
- "Você é muito gostosa" (85% dislikes)
- "Quero te comer" (90% dislikes)
- "Tá pedindo pra levar" (88% dislikes)

💡 RECOMENDAÇÃO: Ajustar tom para ser mais respeitoso
```

**Semana 2 - Identificação do Problema:**
```
Reunião de Equipe:
- Tom sensual está muito explícito
- Está desrespeitando usuários
- Precisa ser mais sutil e respeitoso
```

**Semana 2 - Ajuste de Prompts:**
```dart
// ANTES (arquivo: lib/servicos/ai_service.dart)
if (tone == 'Sensual') {
  toneInstruction = '''
    Seja direto, explícito e provocativo.
    Use linguagem sexualizada.
  ''';
}

// DEPOIS (ajustado manualmente)
if (tone == 'Sensual') {
  toneInstruction = '''
    Seja sutil, insinuante e respeitoso.
    Crie tensão sexual sem ser explícito.
    Use metáforas e sugestões elegantes.
    Mantenha o mistério e a sedução.
    Exemplos:
    - "Você tem um olhar que deixa qualquer um curioso"
    - "Essa foto me fez imaginar várias coisas interessantes"
    - "Tem algo em você que é impossível ignorar"
  ''';
}
```

**Semana 3 - Deploy:**
```bash
git add lib/servicos/ai_service.dart
git commit -m "refactor: Ajustar tom sensual para ser mais respeitoso"
git push origin main
# Deploy no Netlify
```

**Semana 4 - Validação:**
```
Tom "Sensual" recebe 100 feedbacks novos:
- 78 likes (78%) ✅ MELHOROU!
- 22 dislikes (22%)

✅ Redução de 60% na taxa de rejeição!
```

---

## 💾 **4. ONDE O "APRENDIZADO" É ARMAZENADO**

### **A. Prompts e Instruções (Código Fonte)**

**Localização:** `lib/servicos/ai_service.dart`

```dart
class AIService {
  // O "cérebro" está aqui - nas instruções que damos à IA
  String _getToneInstructions(String tone) {
    switch (tone) {
      case AppStrings.flirtTone:
        return '''
          Você é um especialista em flertes.
          Crie mensagens charmosas, divertidas e envolventes.
          Tom: Leve, descontraído, com um toque de charme.
          Objetivo: Despertar interesse e iniciar conversa.
          
          Exemplos de boas mensagens:
          - "Tenho que admitir, seu sorriso é contagiante"
          - "Essa foto tem uma vibe incrível, conta mais sobre você"
          
          Evite:
          - Ser muito direto ou invasivo
          - Comentários sobre corpo de forma objetificante
          - Mensagens genéricas ou clichês
        ''';
      
      case 'Sensual':
        return '''
          Seja sutil, insinuante e respeitoso.
          Crie tensão sexual SEM ser explícito.
          Use metáforas e sugestões elegantes.
          
          Exemplos refinados:
          - "Você tem um olhar que deixa qualquer um curioso"
          - "Essa foto tem algo... intrigante"
          
          NUNCA USE:
          - Linguagem sexual explícita
          - Comentários objetificantes
          - Propostas diretas
        ''';
      
      // Cada tom tem suas instruções refinadas
      default:
        return 'Crie uma mensagem amigável e respeitosa.';
    }
  }
}
```

**Este é o "aprendizado" - instruções cada vez mais refinadas!**

---

### **B. Configurações e Parâmetros**

**Localização:** `lib/servicos/ai_service.dart`

```dart
// Parâmetros ajustáveis baseados em feedback
final response = await openAI.chat.create(
  model: 'gpt-4o-mini',
  
  // Temperature: controla criatividade
  // Ajustado com base em feedback sobre variedade
  temperature: 0.8, // Era 1.0, reduziu após feedbacks de "muito aleatório"
  
  // Max tokens: controla tamanho
  maxTokens: 150, // Era 200, reduziu após feedbacks de "muito longo"
  
  // Top P: controla diversidade
  topP: 0.9, // Ajustado para evitar respostas muito previsíveis
  
  messages: [
    SystemMessage(content: systemPrompt),
    UserMessage(content: userPrompt),
  ],
);
```

---

### **C. Exemplos e Few-Shot Learning**

**Estratégia:** Incluir exemplos de boas/más mensagens no prompt

```dart
String _buildPromptWithExamples(String tone, List<String> focusTags) {
  return '''
    Gere 3 sugestões de mensagens no tom: $tone
    Focos: ${focusTags.join(', ')}
    
    EXEMPLOS DE MENSAGENS BEM AVALIADAS (👍):
    ${_getGoodExamples(tone)}
    
    EXEMPLOS DE MENSAGENS MAL AVALIADAS (👎) - EVITE:
    ${_getBadExamples(tone)}
    
    Agora gere 3 novas mensagens seguindo o estilo dos bons exemplos.
  ''';
}

// Exemplos extraídos da análise de feedbacks
String _getGoodExamples(String tone) {
  // Estes exemplos vêm da análise de feedbacks reais
  final goodExamples = {
    'Flertar': [
      'Seu sorriso ilumina qualquer ambiente',
      'Essa foto me fez querer conhecer mais sobre você',
    ],
    'Sensual': [
      'Você tem um olhar que deixa qualquer um curioso',
      'Tem algo em você que é impossível ignorar',
    ],
  };
  return goodExamples[tone]?.join('\n- ') ?? '';
}

String _getBadExamples(String tone) {
  // Estes exemplos vêm de sugestões com alto dislike
  final badExamples = {
    'Sensual': [
      'Você é muito gostosa', // 90% dislikes
      'Quero te conhecer melhor na cama', // 95% dislikes
    ],
  };
  return badExamples[tone]?.join('\n- ') ?? '';
}
```

---

### **D. Banco de Dados de Feedbacks (Histórico)**

**Localização:** Supabase - Tabela `suggestion_feedback`

```sql
-- Este é o "histórico de aprendizado"
SELECT 
  suggestion_text,
  COUNT(*) FILTER (WHERE feedback_type = 'like') as likes,
  COUNT(*) FILTER (WHERE feedback_type = 'dislike') as dislikes
FROM suggestion_feedback
WHERE feedback_type = 'like' AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY suggestion_text
ORDER BY likes DESC
LIMIT 50;

-- Top 50 mensagens mais curtidas dos últimos 30 dias
-- Estas podem ser usadas como exemplos no prompt!
```

---

## 🔄 **5. FLUXO TÉCNICO COMPLETO**

### **Diagrama de Dados:**

```
┌─────────────────────────────────────────────────────────┐
│  USUÁRIO (App Flutter)                                  │
│  - Vê sugestão: "Seu sorriso é contagiante"           │
│  - Clica 👍                                             │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼ FeedbackService.saveFeedback()
┌─────────────────────────────────────────────────────────┐
│  SUPABASE (PostgreSQL)                                  │
│  suggestion_feedback table:                             │
│  {                                                      │
│    user_id: "abc123",                                   │
│    conversation_id: "conv456",                          │
│    suggestion_text: "Seu sorriso é contagiante",       │
│    feedback_type: "like",                               │
│    created_at: "2025-10-01 16:00:00"                    │
│  }                                                      │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼ Scripts Python (semanal)
┌─────────────────────────────────────────────────────────┐
│  ANÁLISE (Python + Pandas)                              │
│  - Busca feedbacks da semana                            │
│  - Calcula estatísticas                                 │
│  - Identifica padrões                                   │
│  - Gera relatório .txt                                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼ Humano lê relatório
┌─────────────────────────────────────────────────────────┐
│  EQUIPE DE DESENVOLVIMENTO                              │
│  - Analisa relatório                                    │
│  - Identifica problemas                                 │
│  - Define ajustes necessários                           │
│  - Exemplo: "Tom Sensual precisa ser mais sutil"       │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼ Edita código
┌─────────────────────────────────────────────────────────┐
│  CÓDIGO FONTE (Dart)                                    │
│  lib/servicos/ai_service.dart                           │
│  - Ajusta prompts                                       │
│  - Adiciona exemplos                                    │
│  - Modifica parâmetros                                  │
│  - Refina instruções                                    │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼ Git commit + push
┌─────────────────────────────────────────────────────────┐
│  REPOSITÓRIO GIT                                        │
│  - Código atualizado                                    │
│  - Histórico de refinamentos                            │
│  - "Memória" das melhorias                              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼ Deploy
┌─────────────────────────────────────────────────────────┐
│  PRODUÇÃO (Netlify + OpenAI)                            │
│  - App atualizado                                       │
│  - IA usa novos prompts                                 │
│  - Gera sugestões melhores                              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼ Novo ciclo
┌─────────────────────────────────────────────────────────┐
│  VALIDAÇÃO                                              │
│  - Novos feedbacks coletados                            │
│  - Métricas comparadas                                  │
│  - Sucesso medido                                       │
│  - Ciclo recomeça                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🎓 **6. EVOLUÇÃO FUTURA: MACHINE LEARNING REAL**

### **Fase Atual (v1.4.0):**
✅ Feedback manual  
✅ Análise semi-automatizada  
✅ Ajustes manuais de prompts  

### **Fase 2 (Futuro - v2.0):**
🔜 Extração automática de padrões  
🔜 Sugestão automática de ajustes  
🔜 A/B testing automatizado  

### **Fase 3 (Futuro - v3.0):**
🔮 Fine-tuning do modelo com feedbacks  
🔮 Modelo customizado treinado  
🔮 Aprendizado contínuo real  

---

### **Como Implementar Fine-Tuning (Fase 3):**

**1. Preparar Dataset:**
```python
# Extrair feedbacks positivos como exemplos
positive_examples = []
for feedback in feedbacks_with_likes:
    positive_examples.append({
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_context},
            {"role": "assistant", "content": feedback.suggestion_text}
        ]
    })

# Salvar em JSONL
with open('training_data.jsonl', 'w') as f:
    for example in positive_examples:
        f.write(json.dumps(example) + '\n')
```

**2. Fine-Tune via OpenAI:**
```bash
# Upload dataset
openai api fine_tunes.create \
  -t training_data.jsonl \
  -m gpt-4o-mini \
  --suffix "flertai-v2"

# Aguardar treinamento (horas/dias)

# Usar modelo treinado
model="ft:gpt-4o-mini:flertai-v2:..."
```

**3. Usar Modelo Customizado:**
```dart
// Usar modelo fine-tuned
final response = await openAI.chat.create(
  model: 'ft:gpt-4o-mini:flertai-v2:abc123', // Modelo treinado
  messages: messages,
);
```

---

## 📊 **7. MÉTRICAS DE SUCESSO DO APRENDIZADO**

### **KPIs de Melhoria:**

```sql
-- Comparar taxa de likes antes/depois de ajustes
WITH before_adjustment AS (
  SELECT COUNT(*) FILTER (WHERE feedback_type = 'like') * 100.0 / COUNT(*) as like_rate
  FROM suggestion_feedback
  WHERE created_at BETWEEN '2025-10-01' AND '2025-10-07'
),
after_adjustment AS (
  SELECT COUNT(*) FILTER (WHERE feedback_type = 'like') * 100.0 / COUNT(*) as like_rate
  FROM suggestion_feedback
  WHERE created_at BETWEEN '2025-10-08' AND '2025-10-14'
)
SELECT 
  b.like_rate as before_rate,
  a.like_rate as after_rate,
  a.like_rate - b.like_rate as improvement
FROM before_adjustment b, after_adjustment a;
```

### **Meta de Melhoria:**
- ✅ **+15% likes** após cada ciclo de refinamento
- ✅ **-50% dislikes** em sugestões problemáticas
- ✅ **+30% engajamento** geral

---

## 📝 **RESUMO FINAL**

### **✅ Como Funciona HOJE:**

1. **Feedbacks coletados** → Salvos no Supabase
2. **Script Python analisa** → Gera relatórios
3. **Equipe revisa** → Identifica problemas
4. **Desenvolvedores ajustam** → Editam prompts no código
5. **Deploy** → IA usa novos prompts
6. **Validação** → Novos feedbacks mostram melhoria

### **💾 Onde está o "Aprendizado":**
- ✅ **Prompts refinados** no código (`ai_service.dart`)
- ✅ **Parâmetros ajustados** (temperature, max_tokens)
- ✅ **Exemplos curados** (boas/más mensagens)
- ✅ **Histórico de feedbacks** (Supabase para análise)
- ✅ **Repositório Git** (histórico de melhorias)

### **🚀 Evolução Futura:**
- 🔜 Fase 2: Análise mais automatizada
- 🔜 Fase 3: Fine-tuning com feedbacks reais
- 🔜 Fase 4: Modelo totalmente customizado

---

**📚 Este é um sistema de MELHORIA CONTÍNUA, não de aprendizado automático.**

**🎯 O "aprendizado" vem da análise humana + ajustes manuais de prompts.**

**✨ E funciona muito bem para refinar a qualidade das sugestões!**
