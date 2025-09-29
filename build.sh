#!/bin/bash

# Instalar Flutter
git clone https://github.com/flutter/flutter.git -b stable _flutter
export PATH="$PATH:`pwd`/_flutter/bin"

# Verificar Flutter
flutter doctor

# Instalar dependências
flutter pub get

# Build para web
flutter build web --release --web-renderer html

# Mover build para o diretório esperado pelo Vercel
mv build/web build_output

# Criar arquivo .nojekyll para GitHub Pages (se necessário)
echo "" > build_output/.nojekyll
