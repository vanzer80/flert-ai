# FlertaAI 💕

**Aplicativo de paquera com IA focado no mercado brasileiro**

FlertaAI é um aplicativo inovador que utiliza inteligência artificial para ajudar usuários a criar mensagens de paquera criativas e envolventes para aplicativos de relacionamento. Desenvolvido especificamente para o mercado brasileiro, o app combina análise de imagens com geração de texto personalizada.

## 🚀 Funcionalidades Principais

### 📸 Captura e Análise de Conversa
- Captura de screenshots de conversas ou fotos de perfil
- Análise inteligente do contexto visual
- Interface intuitiva com gradiente rosa característico

### 🎭 Seleção de Tom Personalizada
- **😘 Flertar**: Romântico e charmoso
- **😏 Descontraído**: Casual e divertido
- **😎 Casual**: Natural e espontâneo
- **💬 Genuíno**: Autêntico e profundo
- **😈 Sensual**: Picante e sedutor (Premium)

### 🎯 Campo de Foco Personalizado
- Definição de tópicos específicos para conversar
- Sugestões rápidas: Estilo praia, Aventuras, Viagens, Hobbies
- Modal interativo para entrada personalizada

### ⚙️ Menu e Configurações
- Fale conosco
- Ajude-nos a crescer
- Obter suporte por texto
- Configurações de idioma (Português BR)
- Atualização para Pro
- Sistema de indicações e recompensas

### 💎 Sistema Premium
- Tons exclusivos (Sensual)
- Análises ilimitadas
- Suporte prioritário
- Sem anúncios

## 🛠️ Tecnologias Utilizadas

### Frontend (Flutter)
- **Flutter 3.1+**: Framework principal
- **Dart**: Linguagem de programação
- **Material Design 3**: Sistema de design
- **flutter_bloc**: Gerenciamento de estado
- **image_picker**: Captura de imagens
- **cached_network_image**: Cache de imagens

### Backend (Supabase)
- **Supabase**: Backend-as-a-Service
- **PostgreSQL**: Banco de dados
- **Row Level Security (RLS)**: Segurança
- **Storage**: Armazenamento de imagens
- **Edge Functions**: Processamento serverless

### Inteligência Artificial
- **OpenAI GPT-4**: Geração de texto
- **GPT-4 Vision**: Análise de imagens
- **Edge Functions**: Integração segura com APIs

## 📁 Estrutura do Projeto

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_localizations.dart
│   │   └── supabase_config.dart
│   └── tema/
│       └── app_theme.dart
├── apresentacao/
│   ├── paginas/
│   │   ├── home_screen.dart
│   │   ├── analysis_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/
│       ├── custom_app_bar.dart
│       ├── custom_floating_action_button.dart
│       ├── custom_card.dart
│       ├── suggestions_list.dart
│       ├── tone_dropdown.dart
│       └── custom_field_modal.dart
├── servicos/
│   ├── supabase_service.dart
│   └── ai_service.dart
└── main.dart

supabase/
├── functions/
│   └── analyze-conversation/
│       └── index.ts
├── config.toml
└── schema.sql

test/
├── core/
│   └── constants/
│       └── app_localizations_test.dart
├── servicos/
│   └── ai_service_test.dart
└── widgets/
    └── custom_app_bar_test.dart
```

## 🗄️ Esquema do Banco de Dados

### Tabelas Principais
- **profiles**: Perfis dos usuários
- **conversations**: Conversas analisadas
- **suggestions**: Sugestões geradas
- **referrals**: Sistema de indicações
- **transactions**: Histórico de pagamentos

### Funcionalidades do Banco
- Autenticação automática
- Políticas de segurança (RLS)
- Funções para limite diário
- Triggers automáticos
- Storage para imagens

## 🚀 Como Executar

### Pré-requisitos
- Flutter 3.1+
- Dart SDK
- Conta no Supabase
- Chave da API OpenAI

### Configuração

1. **Clone o repositório**
```bash
git clone <repository-url>
cd flerta_ai
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure o Supabase**
```bash
# Execute o schema SQL no Supabase SQL Editor
# Configure as variáveis de ambiente no Supabase
```

4. **Configure as variáveis de ambiente**
```dart
// lib/core/constants/supabase_config.dart
static const String url = 'SUA_SUPABASE_URL';
static const String anonKey = 'SUA_SUPABASE_ANON_KEY';
```

5. **Execute o aplicativo**
```bash
flutter run
```

### Testes
```bash
flutter test
```

## 🌟 Funcionalidades Específicas do Brasil

### Localização
- Português brasileiro como idioma padrão
- Formatação de moeda (R$)
- Formatação de data (DD/MM/AAAA)
- Validação de CPF e telefone brasileiro

### Contexto Cultural
- Gírias e expressões brasileiras
- Referências culturais (praia, carnaval, futebol)
- Atividades populares no Brasil
- Cidades e estados brasileiros

### Expressões de IA
- Linguagem natural brasileira
- Gírias regionais
- Contexto cultural nas sugestões
- Emojis populares no Brasil

## 💰 Modelo de Monetização

### Plano Gratuito
- 3 análises por dia
- Tons básicos
- Anúncios

### Plano Premium (R$ 19,90/mês)
- Análises ilimitadas
- Todos os tons disponíveis
- Sem anúncios
- Suporte prioritário

### Sistema de Indicações
- R$ 40 de desconto para indicador
- R$ 40 de desconto para indicado
- Programa "Dê R$ 40, ganhe R$ 40"

## 🧪 Testes Implementados

### Testes Unitários
- Serviços (AIService, SupabaseService)
- Constantes e configurações
- Utilitários de localização

### Testes de Widget
- CustomAppBar
- Componentes de UI
- Navegação

### Cobertura
- 28 testes passando
- Cobertura das funcionalidades principais
- Validação de entrada e saída

## 📱 Compatibilidade

- **iOS**: 12.0+
- **Android**: API 21+ (Android 5.0)
- **Orientação**: Portrait apenas
- **Idiomas**: Português brasileiro

## 🔒 Segurança e Privacidade

- Autenticação segura via Supabase
- Row Level Security (RLS)
- Criptografia de dados
- Políticas de privacidade LGPD
- Armazenamento seguro de imagens

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📞 Suporte

- **Email**: contato@flertaai.com
- **WhatsApp**: +55 11 99999-9999
- **Website**: https://flertaai.com

---

**Desenvolvido com ❤️ para o mercado brasileiro**

*FlertaAI - Transformando conversas em conexões*
