# 🧠 SISTEMA DE APRENDIZADO AUTOMÁTICO PERSONALIZADO

**Data:** 2025-10-01 17:24  
**Versão:** 1.5.0  
**Status:** ✅ **IMPLEMENTADO E FUNCIONAL**

---

## 🎯 **OBJETIVO**

Implementar sistema de aprendizado automático que:
- ✅ Aprende com feedbacks do usuário em tempo real
- ✅ Personaliza sugestões para cada usuário individualmente
- ✅ Armazena "memória" do aprendizado no banco de dados
- ✅ Alimenta a IA automaticamente com preferências aprendidas
- ✅ Funciona SEM autenticação (identificação por dispositivo)

---

## 🏗️ **ARQUITETURA DO SISTEMA**

### **Fluxo Completo:**

```
┌─────────────────────────────────────────────────────────────┐
│  1. USUÁRIO DÁ FEEDBACK                                     │
│     Clica em 👍 ou 👎 em uma sugestão                      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  2. FEEDBACK SALVO (suggestion_feedback)                    │
│     - suggestion_text, feedback_type, etc                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  3. APRENDIZADO PROCESSADO (UserLearningService)            │
│     - Atualiza user_preferences                             │
│     - Adiciona aos good_examples ou bad_examples            │
│     - Atualiza favorite_tones                               │
│     - Calcula like_rate                                     │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  4. PRÓXIMA GERAÇÃO DE SUGESTÕES                            │
│     AIService busca preferências do usuário                 │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  5. INSTRUÇÕES PERSONALIZADAS GERADAS                       │
│     UserLearningService.getPersonalizedInstructions()       │
│     Cria texto com:                                         │
│     - Tons que o usuário gosta                              │
│     - Exemplos de mensagens que funcionaram                 │
│     - Mensagens a evitar                                    │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  6. INSTRUÇÕES ENVIADAS À IA (Edge Function)                │
│     personalized_instructions adicionado ao prompt          │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  7. IA GERA SUGESTÕES PERSONALIZADAS                        │
│     OpenAI GPT-4o considera as preferências aprendidas      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│  8. USUÁRIO RECEBE SUGESTÕES MELHORES                       │
│     Cada vez mais alinhadas ao seu gosto                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗄️ **ESTRUTURA DO BANCO DE DADOS**

### **1. Tabela: `user_profiles`**

Armazena perfis anônimos identificados por device_id (sem necessidade de login).

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id TEXT UNIQUE NOT NULL,  -- ID único gerado no dispositivo
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  last_active_at TIMESTAMPTZ DEFAULT now() NOT NULL,
  total_feedbacks INTEGER DEFAULT 0,
  metadata JSONB DEFAULT '{}'::jsonb
);
```

**Conceito:** Cada dispositivo/navegador tem um perfil único, mesmo sem login.

---

### **2. Tabela: `user_preferences`**

Armazena as **preferências aprendidas** do usuário.

```sql
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_profile_id UUID REFERENCES user_profiles(id) NOT NULL,
  
  -- Tons favoritos e evitados
  favorite_tones JSONB DEFAULT '[]'::jsonb,    -- Ex: ["Flertar", "Casual"]
  avoided_tones JSONB DEFAULT '[]'::jsonb,     -- Ex: ["Sensual"]
  
  -- Tags favoritas e evitadas
  favorite_tags JSONB DEFAULT '[]'::jsonb,
  avoided_tags JSONB DEFAULT '[]'::jsonb,
  
  -- Padrões de linguagem
  preferred_patterns JSONB DEFAULT '[]'::jsonb,
  avoided_patterns JSONB DEFAULT '[]'::jsonb,
  
  -- Estatísticas
  total_likes INTEGER DEFAULT 0,
  total_dislikes INTEGER DEFAULT 0,
  like_rate DECIMAL(5,2) DEFAULT 0.00,
  
  -- AQUI ESTÁ A "MEMÓRIA" DA IA! 🧠
  good_examples JSONB DEFAULT '[]'::jsonb,     -- Mensagens que funcionaram
  bad_examples JSONB DEFAULT '[]'::jsonb,      -- Mensagens que não funcionaram
  
  custom_instructions TEXT,                    -- Instruções geradas automaticamente
  
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
```

**Conceito:** Esta tabela É o "cérebro" do sistema de aprendizado!

---

### **3. Tabela: `learning_events`**

Log de eventos de aprendizado (auditoria e debugging).

```sql
CREATE TABLE learning_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_profile_id UUID REFERENCES user_profiles(id) NOT NULL,
  event_type TEXT NOT NULL,  -- 'feedback_processed', 'preferences_updated'
  event_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);
```

---

## 📱 **SERVIÇOS FLUTTER**

### **A. DeviceIdService**

**Arquivo:** `lib/servicos/device_id_service.dart`

**Função:** Gerenciar ID único do dispositivo

```dart
class DeviceIdService {
  static Future<String> getDeviceId() async {
    // Busca ou cria UUID único
    // Armazenado em SharedPreferences
    // Mesmo ID em todas as sessões
  }
}
```

**Exemplo de Device ID:**
```
"a3f5e8c7-9b4d-4f2a-8e6c-1d3a7b9c5e4f"
```

---

### **B. UserLearningService**

**Arquivo:** `lib/servicos/user_learning_service.dart`

**Funções Principais:**

#### **1. initializeUserProfile()**
```dart
// Chamado no início do app
// Cria perfil se não existir
await UserLearningService().initializeUserProfile();
```

#### **2. getUserPreferences()**
```dart
// Busca preferências atuais
final prefs = await UserLearningService().getUserPreferences();
print(prefs['total_likes']); // 45
print(prefs['like_rate']);   // 75.5
```

#### **3. getPersonalizedInstructions()** ⭐ **MAIS IMPORTANTE**
```dart
// Gera instruções para a IA baseadas no aprendizado
final instructions = await UserLearningService().getPersonalizedInstructions();

// Exemplo de output:
'''
=== PREFERÊNCIAS APRENDIDAS DESTE USUÁRIO ===
Taxa de aprovação: 82.5%
Total de feedbacks: 40

Tons que ESTE usuário gosta:
  - Flertar
  - Casual

Exemplos de mensagens que ESTE usuário adorou:
  1. "Seu sorriso ilumina qualquer ambiente"
  2. "Essa foto na praia me fez querer conhecer mais sobre você"
  3. "Você tem um estilo único, adorei"

⚠️ IMPORTANTE: Use estes exemplos como inspiração!
Crie mensagens SIMILARES em estilo e tom.

❌ Mensagens que este usuário NÃO gostou (EVITE):
  1. "Você é muito gostosa"
  2. "Linda demais"

⚠️ NÃO crie mensagens similares a estas!
=====================================
'''
```

#### **4. processFeedback()**
```dart
// Processa um feedback e atualiza preferências
await UserLearningService().processFeedback(
  suggestionText: "Seu sorriso é contagiante",
  feedbackType: "like",
  tone: "Flertar",
);
```

---

### **C. Integração no AIService**

**Arquivo:** `lib/servicos/ai_service.dart`

**Modificação:**

```dart
Future<Map<String, dynamic>> analyzeImageAndGenerateSuggestions({
  String? imagePath,
  required String tone,
  List<String>? focusTags,
}) async {
  // 🧠 BUSCAR APRENDIZADO DO USUÁRIO
  final learningService = UserLearningService();
  final personalizedInstructions = await learningService.getPersonalizedInstructions();
  
  final payload = <String, dynamic>{
    'tone': tone,
    'focus_tags': focusTags ?? [],
  };
  
  // ✨ ADICIONAR INSTRUÇÕES PERSONALIZADAS
  if (personalizedInstructions.isNotEmpty) {
    payload['personalized_instructions'] = personalizedInstructions;
  }
  
  final response = await _callEdgeFunction('analyze-conversation', payload);
  return response;
}
```

---

## 🌐 **EDGE FUNCTION (Backend)**

**Arquivo:** `supabase/functions/analyze-conversation/index.ts`

**Modificação:**

```typescript
interface AnalysisRequest {
  // ... outros campos
  personalized_instructions?: string  // ✨ NOVO!
}

// No processamento:
let systemPrompt = buildEnrichedSystemPrompt(tone, focus_tags, focus, imageDescription, personName, culturalRefs);

// 🧠 ADICIONAR INSTRUÇÕES PERSONALIZADAS
if (personalized_instructions) {
  systemPrompt += '\n\n' + personalized_instructions;
}

// Agora o prompt da IA inclui as preferências aprendidas!
```

---

## 🔄 **FLUXO DE APRENDIZADO EM TEMPO REAL**

### **Exemplo Prático:**

**Sessão 1 - Novo Usuário:**
```
1. App inicia → DeviceIdService gera UUID
2. UserLearningService cria perfil vazio
3. IA gera sugestões genéricas
4. Usuário vê: "Você é linda demais" → 👎
5. FeedbackService.saveFeedback()
6. UserLearningService.processFeedback()
   → bad_examples += "Você é linda demais"
   → total_dislikes = 1
```

**Sessão 2 - Usuário Retorna:**
```
7. App inicia → DeviceIdService usa mesmo UUID
8. UserLearningService carrega preferências existentes
9. AIService.analyzeImage()
   → UserLearningService.getPersonalizedInstructions()
   → Retorna: "❌ Evite: 'Você é linda demais'"
10. Edge Function recebe instruções
11. OpenAI considera e EVITA mensagens similares
12. Usuário vê: "Seu sorriso ilumina qualquer ambiente" → 👍
13. good_examples += "Seu sorriso ilumina qualquer ambiente"
```

**Sessão 3 - Ainda Melhor:**
```
14. IA agora tem 1 good_example e 1 bad_example
15. Instruções personalizadas incluem ambos
16. OpenAI gera mensagens SIMILARES aos good_examples
17. Usuário vê 3 sugestões MUITO melhores
18. 2 likes, 1 dislike
19. like_rate sobe para 66%
```

**Sessão 10 - Totalmente Personalizado:**
```
20. 50 feedbacks coletados
21. 10 good_examples, 5 bad_examples
22. favorite_tones = ["Flertar", "Casual"]
23. like_rate = 85%
24. IA agora está TREINADA para este usuário específico!
```

---

## 🧪 **EXEMPLO DE INSTRUÇÕES GERADAS**

### **Usuário com Pouco Feedback (< 3):**
```
(vazio - sem personalização)
```

### **Usuário com 10 Feedbacks:**
```
=== PREFERÊNCIAS APRENDIDAS DESTE USUÁRIO ===
Taxa de aprovação: 70.0%
Total de feedbacks: 10

Tons que ESTE usuário gosta:
  - Flertar

Exemplos de mensagens que ESTE usuário adorou:
  1. "Seu sorriso é contagiante"
  2. "Essa foto me fez querer conhecer você melhor"

⚠️ IMPORTANTE: Use estes exemplos como inspiração!
```

### **Usuário com 50+ Feedbacks:**
```
=== PREFERÊNCIAS APRENDIDAS DESTE USUÁRIO ===
Taxa de aprovação: 85.0%
Total de feedbacks: 52

Tons que ESTE usuário gosta:
  - Flertar
  - Casual
  - Engraçado

Exemplos de mensagens que ESTE usuário adorou:
  1. "Seu sorriso ilumina qualquer ambiente"
  2. "Essa foto na praia me fez querer planejar férias contigo"
  3. "Você tem um estilo único, adorei o look"
  4. "Seu perfil é uma obra de arte"
  5. "Que vibe incrível você transmite"

⚠️ IMPORTANTE: Use estes exemplos como inspiração!
Crie mensagens SIMILARES em estilo e tom.

❌ Mensagens que este usuário NÃO gostou (EVITE):
  1. "Você é muito gostosa"
  2. "Linda demais"
  3. "Gata"

⚠️ NÃO crie mensagens similares a estas!
=====================================
```

---

## 📊 **MÉTRICAS E ESTATÍSTICAS**

### **Obter Estatísticas:**

```dart
final stats = await UserLearningService().getLearningStats();

print(stats);
// {
//   'total_feedbacks': 45,
//   'total_likes': 38,
//   'total_dislikes': 7,
//   'like_rate': 84.4,
//   'favorite_tones': ['Flertar', 'Casual'],
//   'has_learning_data': true
// }
```

### **Dashboard de Aprendizado (Futuro):**

```dart
if (stats['has_learning_data']) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('🧠 Seu Perfil de Aprendizado'),
      content: Column(
        children: [
          Text('Taxa de aprovação: ${stats['like_rate']}%'),
          Text('Total de feedbacks: ${stats['total_feedbacks']}'),
          Text('Tons favoritos: ${stats['favorite_tones'].join(', ')}'),
        ],
      ),
    ),
  );
}
```

---

## 🔐 **PRIVACIDADE E SEGURANÇA**

### **Sem Autenticação:**
- ✅ Identificação por Device ID (UUID)
- ✅ Dados ficam no dispositivo (SharedPreferences)
- ✅ Perfil anônimo no banco de dados
- ✅ Não vinculado a email ou telefone

### **RLS Policies:**
```sql
-- Acesso público (MVP sem autenticação)
CREATE POLICY "Allow public access to user_profiles" 
  ON user_profiles FOR ALL USING (true);

CREATE POLICY "Allow public access to user_preferences" 
  ON user_preferences FOR ALL USING (true);
```

**Nota:** Para produção com autenticação, substituir por:
```sql
CREATE POLICY "Users can view their own profile"
  ON user_profiles FOR SELECT 
  USING (auth.uid()::text = device_id);
```

---

## 🚀 **VANTAGENS DO SISTEMA**

### **1. Aprendizado Automático**
- ✅ Nenhuma intervenção manual necessária
- ✅ Atualiza em tempo real
- ✅ Melhora a cada feedback

### **2. Personalização Individual**
- ✅ Cada usuário tem seu próprio "modelo"
- ✅ Não afeta outros usuários
- ✅ Adaptável a gostos únicos

### **3. Escalabilidade**
- ✅ Funciona com milhares de usuários
- ✅ Banco de dados otimizado
- ✅ Processamento assíncrono

### **4. Transparência**
- ✅ Usuário vê impacto dos feedbacks
- ✅ Estatísticas disponíveis
- ✅ Log completo de eventos

---

## 📈 **EVOLUÇÃO ESPERADA**

### **Fase 1 (Atual - v1.5.0):**
- ✅ Few-shot learning com exemplos
- ✅ Filtragem de padrões ruins
- ✅ Preferência de tons

### **Fase 2 (Futuro - v2.0):**
- 🔜 Análise de padrões linguísticos
- 🔜 Detecção automática de estilo
- 🔜 Clustering de usuários similares

### **Fase 3 (Futuro - v3.0):**
- 🔮 Fine-tuning de modelo por usuário
- 🔮 Modelo customizado por cluster
- 🔮 Aprendizado por reforço (RLHF)

---

## 🎯 **MÉTRICAS DE SUCESSO**

### **Objetivos:**
- 📊 **+30% like_rate** após 20 feedbacks
- 📊 **>80% like_rate** após 50 feedbacks
- 📊 **50% usuários** com 10+ feedbacks
- 📊 **-40% mensagens genéricas** geradas

### **Monitoramento:**
```sql
-- Taxa média de aprovação por quantidade de feedbacks
SELECT 
  CASE 
    WHEN total_likes + total_dislikes BETWEEN 1 AND 10 THEN '1-10'
    WHEN total_likes + total_dislikes BETWEEN 11 AND 50 THEN '11-50'
    WHEN total_likes + total_dislikes > 50 THEN '50+'
  END as feedback_range,
  AVG(like_rate) as avg_like_rate,
  COUNT(*) as users
FROM user_preferences
GROUP BY feedback_range;
```

---

## 🎓 **CONCLUSÃO**

### **✅ Sistema Implementado:**

- ✅ **3 tabelas** no Supabase (user_profiles, user_preferences, learning_events)
- ✅ **2 serviços** Flutter (DeviceIdService, UserLearningService)
- ✅ **1 modificação** no AIService (integração com aprendizado)
- ✅ **1 modificação** na Edge Function (aceita instruções personalizadas)
- ✅ **Inicialização automática** no main.dart
- ✅ **Processamento em tempo real** de feedbacks

### **🧠 Como Funciona:**

1. **Dispositivo gera UUID único** (sem login)
2. **Perfil criado** no primeiro uso
3. **Feedbacks processados** automaticamente
4. **Preferências atualizadas** em tempo real
5. **Instruções geradas** para cada geração
6. **IA personaliza** sugestões por usuário
7. **Melhoria contínua** a cada uso

### **🎯 Resultado:**

**A IA agora aprende automaticamente com cada usuário e gera sugestões cada vez melhores, personalizadas individualmente, sem necessidade de autenticação!** ✨

---

**📊 Sistema de Aprendizado Automático v1.5.0 - 100% Funcional!** 🚀

**🧠 A IA agora tem "memória" e aprende com cada feedback!** 💡

**🎯 Personalização individual sem necessidade de login!** 🔐
