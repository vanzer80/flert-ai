#!/bin/bash

# Netlify Flutter Build Script
# Instala Flutter durante o build (não como submodule)

set -e  # Exit on any error

echo "🚀 Iniciando build do FlertAI..."

# Verificar se Flutter já está instalado
if ! command -v flutter &> /dev/null; then
    echo "📦 Flutter não encontrado. Instalando..."
    
    # Definir versão do Flutter
    FLUTTER_VERSION=${FLUTTER_VERSION:-"3.13.0"}
    FLUTTER_DIR="/tmp/flutter"
    
    # Baixar Flutter SDK
    echo "⬇️ Baixando Flutter $FLUTTER_VERSION..."
    wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -O /tmp/flutter.tar.xz
    
    # Extrair Flutter
    echo "📂 Extraindo Flutter..."
    tar xf /tmp/flutter.tar.xz -C /tmp/
    
    # Adicionar Flutter ao PATH
    export PATH="$PATH:$FLUTTER_DIR/bin"
    export PATH="$PATH:$FLUTTER_DIR/bin/cache/dart-sdk/bin"
    
    # Configurar Flutter
    echo "⚙️ Configurando Flutter..."
    flutter config --no-analytics
    flutter precache --web
    
    echo "✅ Flutter instalado com sucesso!"
else
    echo "✅ Flutter já está disponível"
fi

# Verificar Flutter
echo "🔍 Verificando Flutter..."
flutter --version
flutter doctor -v

# Instalar dependências
echo "📦 Instalando dependências do projeto..."
flutter pub get

# Build para web (otimizado para produção)
echo "🔨 Fazendo build para web..."
flutter build web --release --web-renderer html

# Verificar se build foi criado
if [ ! -d "build/web" ]; then
    echo "❌ Falha no build: diretório build/web não encontrado"
    exit 1
fi

# Criar diretório de output se necessário
mkdir -p build_output

# Mover build para o diretório esperado
echo "📁 Movendo build para build_output..."
cp -r build/web/* build_output/

# Criar arquivo .nojekyll
touch build_output/.nojekyll

echo "✅ Build concluído com sucesso!"
echo "📂 Arquivos em build_output prontos para deploy"
