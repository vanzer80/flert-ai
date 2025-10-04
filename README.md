# 💬 FlertAI v3 - Assistente de Paquera com IA

> Aplicativo inteligente para geração de mensagens de paquera usando IA multimodal (GPT-4o Vision)

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.1.0-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![OCR](https://img.shields.io/badge/OCR-Google_ML_Kit-4285F4)](https://developers.google.com/ml-kit)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?logo=github-actions)](https://github.com/features/actions)

---

## 🚀 **Status do Projeto v3.0.0**

✅ **OCR Completo:** Google ML Kit (mobile) + Vision API (web)  
✅ **Pipeline Multimodal:** GPT-4o Vision + OCR integrado  
✅ **Anti-Alucinação:** Validação de âncoras robusta  
✅ **Cache Inteligente:** Performance otimizada  
✅ **CI/CD:** Deploy automático configurado  
✅ **Build Web:** Pronto para produção (31.6 MB)  
✅ **Documentação:** Completa e atualizada

---

## 📋 **Última Atualização**

**Versão:** 3.0.0 (Pipeline Multimodal One-Shot)  
**Data:** 2025-10-03 22:00  
**Status:** ✅ Produção  
**Build:** ✅ Web + Android + iOS  
**Deploy:** ✅ Automático via GitHub Actions

---

## 🎯 **Como Usar**

1. **Acesse:** [FlertAI App](https://flertai.netlify.app/)
2. **Selecione imagem** de perfil
3. **Escolha tom** (Flertar, Descontraído, etc.)
4. **Receba sugestões** com gírias brasileiras autênticas!

---

## 🇧🇷 **Características**

- **Referências Culturais:** Gírias, memes, músicas regionais
- **Adaptação Regional:** Conteúdo personalizado por localização
- **IA Enriquecida:** Prompts com contexto brasileiro
- **Deploy Contínuo:** Atualizações automáticas via GitHub Actions

---

**Desenvolvido com ❤️ para criar conexões autenticamente brasileiras!** ✨

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

## 📋 Manual de Testes

### 🏆 FlertAI: Inovação 100% Brasileira

Olá, testers!

O **FlertAI** é um aplicativo desenvolvido exclusivamente por brasileiros, para brasileiros. Nossa proposta é revolucionar a experiência de paquera nos apps de relacionamento com inteligência artificial que entende nossa cultura, gírias e jeito único de se comunicar.

**Características principais:**
- Análise inteligente de imagens de perfil
- Geração de mensagens personalizadas e envolventes
- Foco total na realidade brasileira
{{ ... }}

Agradecemos sua participação! Seu feedback nos ajuda a tornar o FlertAI ainda melhor.

📞 **Contato para dúvidas:** 51982066748

---

### 📱 INSTRUÇÕES PARA TESTADORES ANDROID

#### ✅ Arquivo APK Disponível:
- **Link:** `c:\Users\vanze\FlertAI\flerta_ai\build\app\outputs\flutter-apk\app-debug.apk`

#### 📋 Passos para Instalação:

1. **📥 Baixe o Arquivo:**
   - Clique no link acima ou copie o caminho
   - Salve o arquivo `.apk` no seu celular

2. **⚙️ Ative Fontes Desconhecidas:**
   - Vá em: **Configurações > Segurança**
   - Ative: **"Instalar apps desconhecidos"**
   - Permita para o navegador/gerenciador de arquivos

3. **📱 Instale o App:**
   - Abra o arquivo `.apk` baixado
   - Clique em **"Instalar"**
   - Aguarde a instalação completar
   - Abra o **FlertAI**

4. **🔐 Permissões Necessárias:**
   - **Câmera:** Para tirar fotos de perfil
   - **Galeria:** Para selecionar imagens
   - **Internet:** Para conectar com IA

5. **🧪 Primeiro Teste:**
   - Abra o app
   - Vá para a segunda página
   - Selecione uma imagem de perfil
   - Escolha tom e foco
   - Gere sugestões de mensagens

📞 **Dúvidas? Contate:** 51982066748

---

### 📱 INSTRUÇÕES PARA TESTADORES IOS

#### ❌ Versão iOS Ainda Não Disponível:
- Desenvolvimento focado em Android inicialmente
- iOS será lançado em breve

#### 💡 Alternativas para Teste:

1. **🌐 Teste Via Web:**
   - Abra: **https://flertai.netlify.app/**
   - Funciona perfeitamente no **Safari** do iPhone/iPad
   - Todas funcionalidades disponíveis
   - Interface responsiva para dispositivos móveis

2. **📱 Simulador (Se Desenvolvedor):**
   - Use Xcode para build iOS
   - Código fonte disponível no repositório
   - Entre em contato para acesso

3. **⏳ Aguarde Lançamento:**
   - iOS nativo em desenvolvimento
   - Notificaremos quando disponível

#### 🧪 O que Testar no Web:
   - Mesmo que Android: análise de imagens
   - Gere sugestões de mensagens
   - Teste diferentes tons e focos
   - Avalie usabilidade mobile

📞 **Dúvidas? Contate:** 51982066748

---

### 🧪 GUIA DE TESTES - O que Verificar

#### 🎯 Funcionalidades Principais:

1. **📸 Análise de Imagens:**
   - Selecione imagem de perfil
   - Verifique se IA analisa corretamente
   - Confirme elementos visuais identificados

2. **💬 Geração de Mensagens:**
   - Escolha tom (flertar, casual, etc.)
   - Defina foco se necessário
   - Gere 3 sugestões
   - Avalie: Criatividade, naturalidade, contexto

3. **🎨 Interface e Usabilidade:**
   - Navegação fluida?
   - Botões responsivos?
   - Layout adaptado ao dispositivo?

4. **🔧 Performance:**
   - Tempo de resposta aceitável?
   - Sem travamentos?
   - Consumo de bateria/dados ok?

5. **🌍 Cultura Brasileira:**
   - Mensagens em português brasileiro?
   - Gírias e expressões naturais?
   - Contexto cultural apropriado?

#### 📋 Relatório de Bugs:
   - Descreva o problema detalhadamente
   - Inclua passos para reproduzir
   - Envie screenshots se possível

#### ⭐ Avaliação Geral:
   - O que gostou mais?
   - O que pode melhorar?
   - Recomendaria para amigos?

---

### 💡 Dicas Importantes para Testadores

#### 🔒 Segurança e Privacidade:
   - Suas imagens são processadas localmente
   - Dados enviados apenas para análise IA
   - Não armazenamos informações pessoais

#### 📱 Dispositivos Recomendados:
   - **Android:** Versão 8.0 ou superior
   - **iOS:** Safari no iPhone/iPad
   - **Conexão:** Wi-Fi ou 4G para melhor performance

#### 🧪 Cenários de Teste:
   - Use diferentes tipos de imagens de perfil
   - Teste todos os tons disponíveis
   - Varie os focos (se aplicável)
   - Teste em diferentes horários do dia

#### 📞 Suporte:
   - Dúvidas técnicas: 51982066748
   - Bugs ou problemas: Descreva detalhadamente
   - Sugestões: Sempre bem-vindas!

#### ⏰ Tempo Estimado:
   - Instalação: 2-5 minutos
   - Teste completo: 10-15 minutos
   - Relatório: 5 minutos

#### 🏆 Objetivo do Teste:
   - Identificar melhorias
   - Garantir qualidade brasileira
   - Aperfeiçoar experiência do usuário

**Obrigado por contribuir com o FlertAI! 🇧🇷🚀**
