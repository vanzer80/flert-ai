# 📖 Documentação Técnica - FlertAI v3

## 🎯 Visão Geral

**FlertAI** é uma aplicação Flutter para geração inteligente de mensagens de paquera, utilizando IA multimodal (GPT-4o Vision) com análise de screenshots de conversas e perfis.

### **Versão:** 3.0.0 (Pipeline Multimodal One-Shot)
### **Status:** ✅ Pronto para Produção
### **Última Atualização:** 03/10/2025

---

## 🏗️ Arquitetura

### **Stack Tecnológico**

#### **Frontend:**
- **Framework:** Flutter 3.16.0+
- **Linguagem:** Dart 3.1.0+
- **State Management:** Flutter BLoC 8.1.3
- **Plataformas:** Web, Android, iOS

#### **Backend:**
- **BaaS:** Supabase
- **Edge Functions:** Deno (TypeScript)
- **Banco de Dados:** PostgreSQL
- **Storage:** Supabase Storage
- **Auth:** Supabase Auth

#### **IA/ML:**
- **Modelo Principal:** OpenAI GPT-4o (via Edge Functions)
- **OCR Mobile:** Google ML Kit Text Recognition
- **OCR Web:** OpenAI Vision API (backend)
- **Processamento de Imagem:** Biblioteca `image` (Dart)

---

## 📂 Estrutura do Projeto

```
flerta_ai/
├── lib/
│   ├── apresentacao/           # UI Layer
│   │   ├── screens/            # Telas principais
│   │   └── widgets/            # Widgets reutilizáveis
│   │       ├── context_preview.dart       # Preview do contexto extraído
│   │       ├── custom_app_bar.dart        # AppBar customizado
│   │       ├── custom_floating_action_button.dart
│   │       └── tone_dropdown.dart         # Seletor de tom
│   ├── core/
│   │   └── constants/
│   │       └── supabase_config.dart       # Configurações Supabase
│   ├── servicos/               # Services Layer
│   │   ├── ai_service.dart     # Serviço principal de IA
│   │   ├── ocr_service.dart    # Serviço OCR (mobile)
│   │   └── user_learning_service.dart     # Aprendizado do usuário
│   ├── utils/                  # Utilitários
│   │   └── preprocess_screenshot.dart     # Pré-processamento de imagem
│   └── main.dart               # Entry point
├── supabase/
│   ├── functions/
│   │   └── analyze-conversation/
│   │       └── index.ts        # Edge Function principal
│   └── migrations/
│       └── 20251003_add_anchors_and_metrics.sql
├── test/                       # Testes
├── build/web/                  # Build de produção
├── pubspec.yaml                # Dependências
└── README.md
```

---

## 🔧 Componentes Principais

### **1. AIService (`lib/servicos/ai_service.dart`)**

**Responsabilidade:** Orquestração de IA e comunicação com backend.

**Funcionalidades:**
- ✅ Upload de imagens para Supabase Storage
- ✅ Pré-processamento automático de imagens
- ✅ Execução de OCR (mobile)
- ✅ Chamadas à Edge Function de análise
- ✅ Cache de `vision_context` para otimização
- ✅ Fallback para base64 quando upload falha
- ✅ Singleton pattern

**Métodos Principais:**

```dart
// Upload de imagem com fallback base64
Future<String?> uploadImageToStorage({required String imagePath})

// Análise completa com OCR + Vision
Future<Map<String, dynamic>> analyzeImageAndGenerateSuggestions({
  String? imagePath,
  required String tone,
  List<String>? focusTags,
})

// Geração adicional usando cache
Future<Map<String, dynamic>> generateMoreSuggestions({
  required String imageId,
  required String tone,
  List<String>? previousSuggestions,
})
```

**Exemplo de Uso:**

```dart
final aiService = AIService();

// Fazer upload da imagem
final imagePath = await aiService.uploadImageToStorage(
  imagePath: pickedImage.path,
);

// Analisar e gerar sugestão
final result = await aiService.analyzeImageAndGenerateSuggestions(
  imagePath: imagePath,
  tone: '😘 flertar',
  focusTags: ['hobbies', 'viagem'],
);

print(result['suggestions']); // Lista com 1 sugestão
```

---

### **2. OCRService (`lib/servicos/ocr_service.dart`)**

**Responsabilidade:** Extração de texto de imagens (mobile).

**Funcionalidades:**
- ✅ OCR em Android/iOS via Google ML Kit
- ✅ Detecção automática de dimensões da imagem
- ✅ Suporte a múltiplos idiomas (Latin script)
- ✅ Logs detalhados para debug
- ✅ Web delegado ao backend

**Métodos Principais:**

```dart
// Extrair texto de bytes de imagem
Future<String> extractText(Uint8List imageBytes)

// Limpeza de recursos
void dispose()
```

**Exemplo de Uso:**

```dart
final ocrService = OCRService();
final imageBytes = await File(imagePath).readAsBytes();
final text = await ocrService.extractText(imageBytes);

print('Texto extraído: $text');
```

---

### **3. ImagePreprocessor (`lib/utils/preprocess_screenshot.dart`)**

**Responsabilidade:** Otimização de imagens antes do upload.

**Funcionalidades:**
- ✅ Resize para largura máxima de 1280px
- ✅ Crop automático de status bar
- ✅ Ajuste de contraste e gamma
- ✅ Compressão JPEG 85%
- ✅ Redução de ~30-60% no tamanho do arquivo

**Métodos Principais:**

```dart
// Pré-processar imagem completa
static Future<Uint8List> preprocessImage(Uint8List imageBytes)
```

**Pipeline de Processamento:**

```
Imagem Original
    ↓
1. Decodificar
    ↓
2. Crop Status Bar (se detectada)
    ↓
3. Resize (max 1280px largura)
    ↓
4. Ajuste de Contraste (+20%)
    ↓
5. Ajuste de Gamma (0.9)
    ↓
6. Encode JPEG (85%)
    ↓
Imagem Otimizada
```

---

### **4. ContextPreview Widget (`lib/apresentacao/widgets/context_preview.dart`)**

**Responsabilidade:** Exibir contexto extraído da imagem.

**Funcionalidades:**
- ✅ Mostra nome detectado
- ✅ Mostra descrição visual
- ✅ Mostra texto OCR
- ✅ Estado vazio com mensagem
- ✅ Design responsivo

**Exemplo de Uso:**

```dart
ContextPreview(
  visionContext: {
    'personName': 'Ana',
    'imageDescription': 'Mulher sorrindo na praia',
    'conversationSegments': [...],
  },
)
```

---

### **5. Edge Function (`supabase/functions/analyze-conversation/index.ts`)**

**Responsabilidade:** Processamento backend de IA.

**Funcionalidades:**
- ✅ Análise multimodal (Vision + Text)
- ✅ Geração de 1 sugestão contextualizada
- ✅ Extração e validação de âncoras
- ✅ Anti-alucinação rigorosa
- ✅ Rate limiting por IP
- ✅ Métricas de qualidade
- ✅ Cache de vision_context

**Fluxo de Processamento:**

```
1. Receber Request
   ↓
2. Validar Rate Limit
   ↓
3. Processar Imagem (se skip_vision = false)
   ├─ Chamar GPT-4o Vision
   └─ Extrair nome, descrição, OCR
   ↓
4. Extrair Âncoras
   ├─ Nome da pessoa
   ├─ Palavras-chave visuais
   └─ Entidades do texto OCR
   ↓
5. Gerar Sugestão
   ├─ Prompt anti-alucinação
   └─ Tom personalizado
   ↓
6. Validar Âncoras
   ├─ Verificar ≥1 âncora presente
   └─ Regenerar se inválida
   ↓
7. Calcular Métricas
   ├─ Latência
   ├─ Tokens
   ├─ Cobertura de âncoras
   └─ Taxa de repetição
   ↓
8. Salvar em DB
   └─ generation_metrics
   ↓
9. Retornar Response
```

**Endpoints:**

```typescript
POST /analyze-conversation
Body: {
  image_path?: string,
  image_base64?: string,
  tone: string,
  focus_tags?: string[],
  ocr_text_raw?: string,
  skip_vision?: boolean,
  vision_context?: {...},
  previous_suggestions?: string[]
}

Response: {
  suggestions: string[],
  vision_context: {
    personName: string,
    imageDescription: string,
    conversationSegments: {...}[]
  },
  anchors: string[],
  anchors_used: string[],
  low_confidence: boolean,
  metrics: {...}
}
```

---

## 🗄️ Banco de Dados

### **Tabelas Principais**

#### **1. conversations**
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  image_url TEXT,
  tone TEXT,
  focus_tags TEXT[],
  analysis_result JSONB,  -- Inclui: vision_context, anchors, anchors_used
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### **2. suggestions**
```sql
CREATE TABLE suggestions (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations,
  suggestion_text TEXT,
  was_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### **3. generation_metrics**
```sql
CREATE TABLE generation_metrics (
  id UUID PRIMARY KEY,
  conversation_id UUID REFERENCES conversations,
  suggestion_id UUID REFERENCES suggestions,
  latency_ms INTEGER,
  tokens_input INTEGER,
  tokens_output INTEGER,
  anchors_used INTEGER,
  anchors_total INTEGER,
  repetition_rate NUMERIC,
  low_confidence BOOLEAN,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### **4. user_learning**
```sql
CREATE TABLE user_learning (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  feedback_type TEXT,  -- 'like', 'dislike', 'edit', 'send'
  original_suggestion TEXT,
  modified_suggestion TEXT,
  context JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### **5. cultural_references**
```sql
CREATE TABLE cultural_references (
  id UUID PRIMARY KEY,
  reference_type TEXT,  -- 'giria', 'meme', 'musica', etc.
  reference_text TEXT,
  region TEXT,  -- 'sul', 'sudeste', 'nacional', etc.
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔐 Segurança

### **Práticas Implementadas:**

#### **1. Variáveis de Ambiente**
```dart
// ❌ ANTES (Inseguro)
static const url = 'https://projeto.supabase.co';

// ✅ AGORA (Seguro)
static String get url => const String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '' // Vazio em produção
);
```

#### **2. Rate Limiting**
```typescript
// 50 requests por hora por IP (anônimo)
const RATE_LIMIT = 50;
const WINDOW_MS = 3600000; // 1 hora
```

#### **3. Row Level Security (RLS)**
```sql
-- Usuários só acessam suas próprias conversas
CREATE POLICY "Users can view own conversations"
  ON conversations FOR SELECT
  USING (auth.uid() = user_id);
```

#### **4. Content Security Policy**
```
default-src 'self';
script-src 'self' 'unsafe-inline' 'unsafe-eval';
connect-src 'self' https://*.supabase.co;
```

---

## 📊 Métricas de Qualidade

### **Cobertura de Âncoras**

**Objetivo:** ≥95% das mensagens usam pelo menos 1 âncora

**Cálculo:**
```typescript
const coverage = (anchorsUsed / anchorsTotal) * 100;
```

**Ações se < 95%:**
- Regenerar mensagem
- Reforçar prompt anti-alucinação
- Marcar `low_confidence = true`

---

### **Taxa de Repetição**

**Objetivo:** <30% similaridade com mensagens anteriores

**Cálculo:** Similaridade de Jaccard com bigramas
```typescript
const similarity = intersection(bigrams1, bigrams2) / union(bigrams1, bigrams2);
```

---

### **Latência**

**Metas:**
- **1ª Geração:** <20s (com Vision API)
- **Gerar Mais:** <5s (com cache)

---

## 🧪 Testes

### **Estrutura de Testes**

```
test/
├── servicos/
│   ├── ai_service_test.dart
│   └── ocr_service_test.dart
├── widgets/
│   ├── context_preview_test.dart
│   └── custom_app_bar_test.dart
└── utils/
    └── preprocess_screenshot_test.dart
```

### **Executar Testes**

```bash
# Todos os testes
flutter test

# Testes específicos
flutter test test/servicos/ai_service_test.dart

# Com cobertura
flutter test --coverage
```

---

## 🚀 Deploy

### **Build de Produção**

```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### **Verificação de Build**

```bash
# Analisar código
flutter analyze

# Verificar dependências
flutter doctor -v

# Limpar cache
flutter clean && flutter pub get
```

---

## 📈 Performance

### **Otimizações Implementadas:**

1. **Cache de Vision Context**
   - Evita reprocessamento de imagem
   - Reduz latência em 75% para "Gerar mais"

2. **Pré-processamento On-Device**
   - Reduz tamanho de upload em 40%
   - Melhora qualidade OCR

3. **Lazy Loading**
   - Widgets carregados sob demanda
   - Reduz tempo de inicialização

4. **Singleton Services**
   - Menos instâncias em memória
   - Compartilhamento de recursos

---

## 🐛 Troubleshooting

### **Problema: OCR não detecta texto**

**Causa:** Imagem com baixa qualidade ou texto muito pequeno

**Solução:**
1. Verificar pré-processamento ativado
2. Aumentar resolução da imagem
3. Verificar logs: `debugPrint` no OCRService

---

### **Problema: "Too many positional arguments"**

**Causa:** API da biblioteca `image` desatualizada

**Solução:**
```dart
// ❌ ANTES
img.copyCrop(image, x, y, width, height)

// ✅ AGORA
img.copyCrop(image, x: 0, y: 80, width: w, height: h)
```

---

### **Problema: Upload de imagem falha**

**Causa:** Permissões do Supabase Storage

**Solução:**
1. Verificar RLS policies no bucket `images`
2. Usar fallback base64 (já implementado)
3. Verificar tamanho máximo permitido

---

## 📚 Referências

- **Flutter:** https://flutter.dev/docs
- **Supabase:** https://supabase.com/docs
- **OpenAI API:** https://platform.openai.com/docs
- **Google ML Kit:** https://developers.google.com/ml-kit
- **Dart Image:** https://pub.dev/packages/image

---

## 👥 Contribuindo

### **Workflow:**

1. Fork o repositório
2. Criar branch: `feat/nova-funcionalidade`
3. Commit: `feat: descrição da mudança`
4. Push e criar Pull Request
5. Aguardar code review

### **Padrões de Código:**

- Clean Code principles
- SOLID principles
- Test-Driven Development (TDD)
- Conventional Commits

---

## 📄 Licença

Este projeto é propriedade de **FlertAI** e está sob licença proprietária.

---

## 📞 Contato

**Desenvolvedor:** Vanzer80  
**Repositório:** https://github.com/vanzer80/flert-ai  
**Versão:** 3.0.0
