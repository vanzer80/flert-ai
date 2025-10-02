# 🔍 AUDITORIA TÉCNICA COMPLETA - FLERTAI

**Data:** 30/09/2025 | **Versão:** 1.0.0 | **Projeto:** FlertAI

---

## 📊 RESUMO EXECUTIVO

**FlertAI** é um aplicativo mobile multiplataforma que utiliza IA (GPT-4o Vision) para gerar sugestões de mensagens de paquera personalizadas. Desenvolvido em Flutter/Dart com backend Supabase e integração OpenAI.

### Métricas Principais
- **Plataformas:** Android, iOS, Web
- **Linguagem:** Dart 3.1+, TypeScript (backend)
- **Performance:** <3s por análise
- **Limite Free:** 3 análises/dia
- **Stack:** Flutter + Supabase + OpenAI GPT-4o

---

## 🛠️ STACK TECNOLÓGICA COMPLETA

### 1. FRONTEND

#### Framework e Linguagem
- **Flutter 3.1+** (SDK principal)
- **Dart >=3.1.0** (Null Safety ativado)
- **Material Design 3** (UI/UX)
- **Orientação:** Portrait apenas

#### Bibliotecas Principais
```yaml
dependencies:
  # Backend/Database
  supabase_flutter: ^2.0.0      # Cliente Supabase oficial
  supabase_auth_ui: ^0.3.0      # UI auth (não usado)
  
  # IA e HTTP
  dart_openai: ^5.0.0           # Cliente OpenAI (referência)
  http: ^1.1.0                  # HTTP client
  
  # State Management
  flutter_bloc: ^8.1.3          # BLoC pattern (declarado)
  equatable: ^2.0.5             # Value equality
  
  # Funcionalidades Mobile
  image_picker: ^1.0.4          # Câmera/galeria
  cached_network_image: ^3.3.0  # Cache de imagens
  geolocator: ^10.1.0           # GPS (declarado)
  flutter_card_swiper: ^7.0.1   # Swipe cards (declarado)
  
  # Persistência e Utils
  shared_preferences: ^2.2.2    # Storage local
  cupertino_icons: ^1.0.2       # Ícones iOS
  flutter_localizations: (SDK)  # i18n PT-BR
```

### 2. BACKEND

#### Supabase (BaaS)
- **URL:** https://olojvpoqosrjcoxygiyf.supabase.co
- **Região:** São Paulo (sa-east-1)
- **PostgreSQL:** Versão 15
- **Host:** aws-1-sa-east-1.pooler.supabase.com:6543
- **Database:** postgres

#### Funcionalidades Ativas
- ✅ **Auth:** JWT-based (email/password)
- ✅ **Database:** PostgreSQL + RLS
- ✅ **Storage:** Bucket `images` (50MB limit)
- ✅ **Edge Functions:** Deno/TypeScript
- ✅ **Realtime:** Subscriptions (declarado)

#### Edge Function: analyze-conversation
```typescript
// Runtime: Deno
// File: supabase/functions/analyze-conversation/index.ts
// Endpoint: /functions/v1/analyze-conversation
// Método: POST
// Headers: Authorization Bearer + apikey

// Lógica:
1. Valida parâmetros (tone obrigatório)
2. Checa daily limit (RPC)
3. **Etapa 1 - Vision:** 
   - Chama GPT-4o Vision API
   - Analisa imagem + OCR nome
   - Retorna JSON estruturado
4. **Etapa 2 - Text:**
   - Usa descrição + nome + tom + foco
   - Chama GPT-4o/mini
   - Gera 3 sugestões personalizadas
5. Salva no DB (conversations + suggestions)
6. Incrementa daily_usage
7. Retorna response
```

### 3. INTELIGÊNCIA ARTIFICIAL

#### OpenAI API
- **GPT-4o (Vision):**
  - Análise de imagem + OCR
  - Temperature: 0.3
  - Max tokens: 500
  - Detail: high
  
- **GPT-4o-mini (Text):**
  - Geração de sugestões
  - Temperature: 0.8
  - Max tokens: 500
  - Fallback econômico

#### Prompts Estruturados
```
Vision Prompt:
Analise imagem → JSON {
  nome_da_pessoa_detectado,
  descricao_visual,
  texto_extraido_ocr
}

System Prompt:
"Você é FlertAI, cupido digital..."
+ Descrição da imagem
+ Nome detectado (prioridade alta)
+ Tom escolhido (5 opções)
+ Foco escolhido
→ Gere 3 sugestões (20-40 palavras, PT-BR, com emoji)
```

#### Tons Disponíveis (5)
1. **😘 Flertar** - Romântico e charmoso
2. **😏 Descontraído** - Casual e divertido
3. **😎 Casual** - Natural e espontâneo
4. **💬 Genuíno** - Autêntico e profundo
5. **😈 Sensual** - Picante e sedutor

**Todos liberados gratuitamente (isPremium: false)**

### 4. INFRAESTRUTURA

#### Hospedagem
- **Frontend:** Netlify
  - URL: https://flertai.netlify.app
  - Deploy: Manual (drag & drop build/web)
  - CDN: Global
  
- **Backend:** Supabase Cloud
  - Região: São Paulo
  - Auto-scaling
  - SLA: 99.9% uptime

#### Controle de Versão
- **Git + GitHub**
- **Repositório:** https://github.com/vanzer80/flert-ai
- **Branch:** main
- **Commits:** Semânticos convencionais

---

## 📁 ESTRUTURA DO PROJETO

### Arquitetura em Camadas

```
┌─────────────────────────────────────┐
│   PRESENTATION LAYER (UI)           │
│   lib/apresentacao/                 │
│   ├── paginas/                      │
│   │   ├── home_screen.dart          │
│   │   ├── analysis_screen.dart      │
│   │   └── settings_screen.dart      │
│   └── widgets/ (10 widgets)         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   BUSINESS LOGIC LAYER              │
│   lib/servicos/                     │
│   ├── ai_service.dart               │
│   └── supabase_service.dart         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   CORE LAYER (Config)               │
│   lib/core/                         │
│   ├── constants/ (4 arquivos)       │
│   └── tema/app_theme.dart           │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│   BACKEND LAYER                     │
│   supabase/functions/               │
│   └── analyze-conversation/         │
│       └── index.ts (426 linhas)     │
└─────────────────────────────────────┘
```

### Diretórios Principais

```
flerta_ai/
├── android/              # Android nativo (Kotlin)
├── assets/              
│   └── images/
│       └── profile_karinny.jpg  # Mockup (15.9 KB)
├── build/               # Build outputs (gitignored)
├── ios/                 # iOS nativo (Swift)
├── lib/                 # Código Dart (18 arquivos)
│   ├── apresentacao/    # UI (13 arquivos)
│   ├── core/            # Config (4 arquivos)
│   ├── servicos/        # Services (2 arquivos)
│   └── main.dart        # Entry point (81 linhas)
├── supabase/
│   ├── functions/       # Edge Functions
│   └── config.toml      # Config local
├── test/                # Testes (3 arquivos)
├── web/                 # Flutter Web
├── .gitignore
├── pubspec.yaml         # Dependências
└── README.md            # Documentação (417 linhas)
```

---

## 🗄️ BANCO DE DADOS

### Schema PostgreSQL (Inferido)

```sql
-- PROFILES
profiles (
  id UUID PK,
  email TEXT UNIQUE,
  subscription_type TEXT DEFAULT 'free',
  daily_suggestions_used INT DEFAULT 0,
  created_at, updated_at TIMESTAMPTZ
) + RLS enabled

-- CONVERSATIONS
conversations (
  id UUID PK,
  user_id UUID FK → profiles,
  image_url TEXT,
  analysis_result JSONB,  -- {tone, focus, ai_response, suggestions, timestamp}
  created_at TIMESTAMPTZ
) + RLS enabled

-- SUGGESTIONS
suggestions (
  id UUID PK,
  conversation_id UUID FK → conversations,
  tone_type TEXT,
  suggestion_text TEXT,
  created_at TIMESTAMPTZ
) + RLS enabled

-- RPCs
check_daily_limit(user_id) → BOOLEAN
increment_daily_usage(user_id) → VOID
```

### Storage

**Bucket: images**
- Público: Read
- Autenticado: Upload
- Limite: 50MB/arquivo
- Formatos: JPG, PNG

---

## 🔐 SEGURANÇA

### Autenticação
- **JWT** via Supabase Auth
- **Expiry:** 3600s (1 hora)
- **Refresh token rotation:** Ativado

### Row Level Security (RLS)
```sql
-- Políticas ativas em todas as tabelas
- profiles: Usuário vê apenas próprio perfil
- conversations: Usuário vê apenas próprias conversas
- suggestions: Usuário vê apenas suggestions de suas conversas
```

### Variáveis Sensíveis
```bash
# Supabase Dashboard → Secrets
OPENAI_API_KEY=sk-proj-...

# lib/core/constants/supabase_config.dart
SUPABASE_URL=https://olojvpoqosrjcoxygiyf.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**⚠️ ATENÇÃO:** Chaves expostas no código devem ser rotacionadas em produção!

---

## 🎨 DESIGN E UX

### Paleta de Cores
```dart
// lib/core/constants/app_colors.dart
primaryGradient: [#FF6B6B, #FF8E8E]  // Coral suave
secondaryColor: #FFE7E7              // Rosa claro
accentColor: #FF7043                 // Laranja terra
backgroundColor: #FFFBFB              // Branco rosado
textPrimary: #2A2A2A                 // Cinza escuro
premiumGradient: [#FFD700, #FFA500]  // Ouro
```

### Tema Material Design 3
- Fonte: Nunito (comentada, não configurada)
- Border radius: 15-25px
- Elevation: 2-8
- Transições: Smooth
- Responsivo: Mobile-first

### Assets
- **Imagens:** 1 arquivo (profile_karinny.jpg)
- **Ícones:** Vazio (usando Material/Cupertino icons)
- **Fontes:** Comentadas (não implementadas)

---

## 🚀 FUNCIONALIDADES IMPLEMENTADAS

### 1. Análise de Imagem
- ✅ Upload via image_picker
- ✅ Storage no Supabase
- ✅ Análise com GPT-4o Vision
- ✅ OCR automático para nomes
- ✅ Descrição visual estruturada

### 2. Geração de Mensagens
- ✅ 3 sugestões por análise
- ✅ 5 tons personalizáveis
- ✅ Campo de foco customizável
- ✅ 24 chips de foco rápidos
- ✅ Uso natural do nome detectado
- ✅ Gírias e emojis brasileiros

### 3. Interface do Usuário
- ✅ Home screen com mockup
- ✅ Analysis screen completa
- ✅ Settings screen
- ✅ Modais customizados
- ✅ Tone dropdown
- ✅ Suggestions list
- ✅ Custom app bar
- ✅ Floating action button

### 4. Backend e Persistência
- ✅ Edge Function deploy
- ✅ Salvamento de conversas
- ✅ Salvamento de suggestions
- ✅ Tracking de uso diário
- ✅ Limite free: 3/dia
- ✅ RLS policies

### 5. Premium (Declarado)
- ⚠️ Todos os tons liberados gratuitamente
- ⚠️ Sistema de assinatura não implementado
- ⚠️ Gateway de pagamento ausente
- ⚠️ Referral system não implementado

---

## 📊 FLUXO DE DADOS COMPLETO

```
1. Usuário seleciona imagem (HomeScreen)
   ↓ image_picker
2. Frontend: Upload para Supabase Storage (ai_service.dart)
   ↓ uploadImageToStorage()
3. Frontend: Chama Edge Function (ai_service.dart)
   ↓ analyzeImageAndGenerateSuggestions()
   POST /functions/v1/analyze-conversation
4. Edge Function: Valida + Checa limite (index.ts)
   ↓ check_daily_limit RPC
5. Edge Function: Recupera imagem do Storage
   ↓ getPublicUrl()
6. Edge Function: Chama GPT-4o Vision API
   ↓ POST https://api.openai.com/v1/chat/completions
   Body: { model: 'gpt-4o', messages: [...], max_tokens: 500, temperature: 0.3 }
7. GPT-4o: Analisa imagem + extrai nome via OCR
   ↓ Retorna JSON: {nome_da_pessoa_detectado, descricao_visual, texto_extraido_ocr}
8. Edge Function: Parse JSON + fallback regex
   ↓ personName, imageDescription
9. Edge Function: Constrói system prompt
   ↓ buildSystemPrompt(tone, focus, imageDescription, personName)
10. Edge Function: Chama GPT-4o/mini Text API
   ↓ POST https://api.openai.com/v1/chat/completions
   Body: { model: 'gpt-4o-mini', messages: [...], max_tokens: 500, temperature: 0.8 }
11. GPT-4o-mini: Gera 3 sugestões personalizadas
   ↓ Retorna texto com 3 mensagens numeradas
12. Edge Function: Parse suggestions (parseSuggestions)
   ↓ Extrai 3 strings
13. Edge Function: Salva no DB (conversations + suggestions)
   ↓ INSERT INTO conversations, suggestions
14. Edge Function: Incrementa daily_usage
   ↓ increment_daily_usage RPC
15. Edge Function: Retorna response ao Frontend
   ↓ { success, suggestions[], conversation_id, tone, focus, usage_info }
16. Frontend: Recebe response (AnalysisScreen)
   ↓ setState() atualiza UI
17. Frontend: Exibe 3 sugestões (SuggestionsList widget)
   ✓ Usuário vê mensagens personalizadas
```

---

## ⚙️ CONFIGURAÇÕES CRÍTICAS

### 1. Flutter/Dart
```yaml
# pubspec.yaml
name: flerta_ai
version: 1.0.0+1
environment:
  sdk: '>=3.1.0 <4.0.0'
```

### 2. Android
```gradle
// android/app/build.gradle
namespace: com.example.flerta_ai
applicationId: com.example.flerta_ai
minSdk: 21 (Android 5.0)
targetSdk: 34
compileSdk: 34
```

### 3. Supabase Local
```toml
# supabase/config.toml
project_id = "flerta_ai"
[api]
port = 54321
[db]
port = 54322
major_version = 15
[storage]
file_size_limit = "50MiB"
```

### 4. Git
```gitignore
# .gitignore
/build/           # ← Build não commitado
.dart_tool/
.pub-cache/
*.iml
.idea/
```

---

## 🧪 TESTES

### Estrutura
```
test/
├── core/constants/
│   └── app_localizations_test.dart
├── servicos/
│   └── ai_service_test.dart
└── widgets/
    └── custom_app_bar_test.dart
```

### Status
- ✅ **28 testes** implementados
- ✅ Cobertura: Funcionalidades principais
- ✅ Framework: flutter_test
- ⚠️ Cobertura de código: Não medida

---

## 📈 MONITORAMENTO E LOGS

### Supabase Dashboard
- **URL:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf
- **Métricas:**
  - Execution time: 247ms (média)
  - Max execution time: 6.085s
  - Invocations: 2+
  - Worker Logs: Disponíveis
  - Sem erros críticos

### Logs da Edge Function
```typescript
console.log('[SupabaseConfig] Supabase inicializado com sucesso!')
console.error('OpenAI API error:', error)
console.error('Vision API error:', visionError)
console.error('Error saving conversation:', convError)
```

---

## 🔄 CI/CD E DEPLOY

### Processo Atual

#### Frontend (Netlify)
```bash
# Local
flutter clean
flutter pub get
flutter build web --release

# Manual Deploy
1. Abrir https://app.netlify.com/drop
2. Arrastar pasta build/web
3. URL gerada: https://[random].netlify.app
4. Renomear para: flertai

# Resultado
URL final: https://flertai.netlify.app
```

#### Backend (Supabase)
```bash
# Deploy Edge Function
supabase functions deploy analyze-conversation

# Configurar secrets
supabase secrets set OPENAI_API_KEY=sk-proj-...

# Verificar
supabase functions list
```

### Limitações
- ❌ **Sem CI/CD automático**
- ❌ **Sem GitHub Actions**
- ❌ **Deploy manual obrigatório**
- ❌ **Sem staging environment**

### Recomendação
```yaml
# .github/workflows/deploy.yml (NÃO EXISTE)
# TODO: Implementar pipeline CI/CD
# - Flutter build on push
# - Supabase function deploy
# - Testes automáticos
```

---

## 💰 MODELO DE NEGÓCIO

### Plano Gratuito (Atual)
- ✅ 3 análises/dia
- ✅ **Todos os 5 tons** (liberados)
- ✅ Todas funcionalidades
- ❌ Sem anúncios (não implementado)

### Plano Premium (Planejado)
- 💎 Análises ilimitadas
- 💎 Suporte prioritário
- 💎 Sem anúncios
- 💎 Acesso antecipado
- **Preço:** R$ 19,90/mês (definido no README)

### Sistema de Referral
- 💸 R$ 40 para indicador
- 💸 R$ 40 para indicado
- 💸 2 indicações = 1 ano grátis
- ⚠️ **Não implementado**

---

## 📋 CHECKLIST DE PRODUÇÃO

### ✅ Implementado
- [x] Flutter app funcional
- [x] Supabase configurado
- [x] OpenAI integrado
- [x] Edge Function deployed
- [x] Storage configurado
- [x] RLS policies
- [x] Análise de imagem + OCR
- [x] Geração de mensagens
- [x] 5 tons disponíveis
- [x] Interface completa
- [x] Testes básicos

### ⚠️ Parcial/Declarado
- [ ] Sistema de autenticação (UI não implementada)
- [ ] State management (BLoC declarado, não usado)
- [ ] Geolocalização (pacote instalado, não usado)
- [ ] Card swiper (pacote instalado, não usado)
- [ ] Fontes customizadas (comentadas)

### ❌ Não Implementado
- [ ] Gateway de pagamento
- [ ] Sistema de assinatura premium
- [ ] Referral system
- [ ] Anúncios
- [ ] Push notifications
- [ ] Analytics
- [ ] CI/CD pipeline
- [ ] iOS build configurado
- [ ] Staging environment
- [ ] Monitoring/alertas
- [ ] Backup automático
- [ ] Rate limiting

---

## 🚨 VULNERABILIDADES E MELHORIAS

### Segurança
1. **⚠️ CRÍTICO:** Chaves expostas no código
   - `SUPABASE_ANON_KEY` em supabase_config.dart
   - Deve usar variáveis de ambiente
   
2. **⚠️ ALTO:** OPENAI_API_KEY no Edge Function
   - Configurado corretamente como secret
   - ✅ Não exposta no frontend

3. **⚠️ MÉDIO:** Sem rate limiting adicional
   - Depende apenas do limite diário (3/dia free)
   - Vulnerável a abuse

### Performance
1. **Tempo de resposta:** 247ms média (✅ BOM)
2. **Max execution time:** 6.085s (⚠️ ATENÇÃO)
3. **Tokens por análise:** ~450-500 (✅ OTIMIZADO)

### Escalabilidade
1. **Database:** PostgreSQL managed (✅ ESCALÁVEL)
2. **Storage:** Supabase Storage (✅ ESCALÁVEL)
3. **Edge Functions:** Serverless (✅ AUTO-SCALING)
4. **Frontend:** Static CDN (✅ ESCALÁVEL)

---

## 📚 DOCUMENTAÇÃO EXISTENTE

### Arquivos
1. **README.md** (417 linhas)
   - Funcionalidades
   - Tecnologias
   - Como executar
   - Manual de testes
   
2. **Este documento** (AUDITORIA_COMPLETA.md)
   - Stack técnica
   - Arquitetura
   - Configurações

### Faltando
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Component library (Storybook)
- [ ] Database schema diagram
- [ ] Architecture decision records (ADRs)
- [ ] Deployment guide
- [ ] Troubleshooting guide

---

## 🔮 ROADMAP DE EXPANSÃO

### Curto Prazo (1-3 meses)
1. **Autenticação completa**
   - UI de login/signup
   - Social auth (Google, Apple)
   - Password reset

2. **Sistema Premium**
   - Gateway de pagamento (Stripe/Mercado Pago)
   - Subscriptions management
   - Upgrade flow

3. **Analytics**
   - Firebase Analytics
   - Event tracking
   - User behavior

4. **CI/CD**
   - GitHub Actions
   - Automated tests
   - Deployment pipeline

### Médio Prazo (3-6 meses)
1. **Funcionalidades Avançadas**
   - Chat history
   - Favoritar sugestões
   - Compartilhamento
   - Notificações push

2. **Melhorias IA**
   - Fine-tuning para PT-BR
   - Context memory
   - Personalização por usuário

3. **Expansão**
   - iOS App Store
   - Android Play Store
   - Web PWA

### Longo Prazo (6-12 meses)
1. **Internacionalização**
   - Espanhol (Latam)
   - Inglês (US)
   - Novos mercados

2. **Funcionalidades Premium**
   - Análise de voz
   - Vídeo analysis
   - Real-time suggestions

3. **Gamificação**
   - Achievements
   - Leaderboards
   - Referral rewards

---

## 👥 REQUISITOS PARA NOVOS DESENVOLVEDORES

### Skills Obrigatórias
- ✅ Flutter/Dart (intermediário+)
- ✅ REST APIs e HTTP
- ✅ Git/GitHub
- ✅ PostgreSQL básico

### Skills Recomendadas
- ⭐ TypeScript/Deno
- ⭐ Supabase ecosystem
- ⭐ OpenAI APIs
- ⭐ Material Design
- ⭐ State management (BLoC)

### Ferramentas
- **IDE:** VS Code ou Android Studio
- **Flutter SDK:** 3.1+
- **Supabase CLI:** Latest
- **Git:** 2.0+
- **Postman:** Para testes de API

### Onboarding
1. Clone repositório
2. `flutter pub get`
3. Configure .env (criar)
4. `flutter run`
5. Teste Edge Function local
6. Leia esta auditoria completa
7. Execute testes: `flutter test`

---

## 📞 CONTATOS E SUPORTE

### Repositório
- **GitHub:** https://github.com/vanzer80/flert-ai
- **Issues:** https://github.com/vanzer80/flert-ai/issues

### Deploy
- **Frontend:** https://flertai.netlify.app
- **Backend:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf

### Suporte
- **Contato:** 51982066748 (mencionado no README)

---

## ✅ CONCLUSÃO

### Pontos Fortes
- ✅ Arquitetura moderna e escalável
- ✅ Stack tecnológica robusta
- ✅ Integração IA avançada (GPT-4o Vision)
- ✅ Funcionalidade core completa
- ✅ Performance aceitável
- ✅ Código organizado

### Áreas de Melhoria
- ⚠️ Segurança (chaves expostas)
- ⚠️ Autenticação incompleta
- ⚠️ Monetização não implementada
- ⚠️ CI/CD ausente
- ⚠️ Documentação técnica limitada
- ⚠️ Testes com cobertura baixa

### Pronto para Produção?
**⚠️ PARCIALMENTE**
- ✅ MVP funcional
- ✅ Core features operacionais
- ❌ Falta sistema de pagamento
- ❌ Falta segurança adicional
- ❌ Falta CI/CD
- ❌ Falta monitoring

### Próximos Passos Recomendados
1. **Urgente:** Rotacionar chaves expostas
2. **Urgente:** Implementar sistema de pagamento
3. **Alta:** Setup CI/CD
4. **Alta:** Implementar auth completo
5. **Média:** Adicionar monitoring
6. **Média:** Melhorar cobertura de testes

---

**Documento gerado automaticamente via auditoria de código**  
**Última atualização:** 30/09/2025 23:08  
**Versão:** 1.0.0  
**Revisores:** [Adicionar nomes]

---

## 📎 ANEXOS

### A. Variáveis de Ambiente (Template)
```env
# .env (NÃO EXISTE - CRIAR)
SUPABASE_URL=https://olojvpoqosrjcoxygiyf.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
OPENAI_API_KEY=sk-proj-...
ENVIRONMENT=production
```

### B. Comandos Úteis
```bash
# Flutter
flutter clean && flutter pub get
flutter run
flutter build web --release
flutter test
flutter doctor

# Supabase
supabase login
supabase init
supabase start
supabase functions list
supabase functions deploy analyze-conversation
supabase db push

# Git
git clone https://github.com/vanzer80/flert-ai.git
git checkout -b feature/nova-funcionalidade
git add .
git commit -m "feat: descrição"
git push origin feature/nova-funcionalidade
```

### C. Links Importantes
- Flutter Docs: https://docs.flutter.dev
- Supabase Docs: https://supabase.com/docs
- OpenAI API: https://platform.openai.com/docs
- Dart Packages: https://pub.dev

---

**FIM DA AUDITORIA TÉCNICA COMPLETA**

