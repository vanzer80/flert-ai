#!/usr/bin/env bash
set -euo pipefail

# Netlify build script for Flutter Web
# Installs Flutter SDK and builds the web app

FLUTTER_VERSION="3.13.0"
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"

echo "[Netlify] Downloading Flutter ${FLUTTER_VERSION}..."
curl -L -o ${FLUTTER_TAR} ${FLUTTER_URL}

echo "[Netlify] Extracting Flutter..."
tar -xf ${FLUTTER_TAR}
export PATH="$PWD/flutter/bin:$PATH"

# Pre-cache and enable web just in case
flutter --version
flutter config --enable-web

# Fetch dependencies
echo "[Netlify] Running flutter pub get..."
flutter pub get

# Build web
echo "[Netlify] Building Flutter web (release)..."
flutter build web --release --no-tree-shake-icons

echo "[Netlify] Build completed. Output at build/web"
