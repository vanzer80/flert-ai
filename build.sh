#!/bin/bash

# Netlify Flutter Build Script
# Usa Flutter pré-instalado no ambiente de build

set -e  # Exit on any error

echo "🚀 Iniciando build do FlertAI..."

# Verificar se Flutter está disponível
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Usando versão do ambiente..."
    export PATH="$PATH:/opt/flutter/bin"
fi

# Verificar Flutter
echo "🔍 Verificando Flutter..."
flutter --version
flutter doctor -v

# Instalar dependências
echo "📦 Instalando dependências..."
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
mv build/web/* build_output/

# Criar arquivo .nojekyll para GitHub Pages (se necessário)
touch build_output/.nojekyll

echo "✅ Build concluído com sucesso!"
echo "📂 Arquivos em build_output prontos para deploy"
