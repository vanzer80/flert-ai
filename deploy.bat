@echo off
echo ============================================
echo   FlertAI - Deploy para Netlify
echo ============================================
echo.

echo [1/3] Verificando Flutter...
flutter --version
if errorlevel 1 (
    echo ERRO: Flutter nao encontrado!
    pause
    exit /b 1
)

echo.
echo [2/3] Building Flutter web (release)...
echo Este processo pode levar 30-60 segundos...
call flutter build web --release --no-tree-shake-icons
if errorlevel 1 (
    echo.
    echo ERRO: Build falhou!
    echo Verifique os erros acima e tente novamente.
    pause
    exit /b 1
)

echo.
echo [3/3] Preparando para deploy...
echo.
echo === BUILD CONCLUIDO COM SUCESSO! ===
echo.
echo Pasta gerada: build\web
echo.
echo PROXIMOS PASSOS:
echo 1. Acesse: https://app.netlify.com/drop
echo 2. Arraste a pasta 'build\web' para o navegador
echo 3. Aguarde upload (10-30 segundos)
echo 4. Pronto!
echo.
echo OU use Netlify CLI (se instalado):
echo   netlify deploy --prod --dir=build/web
echo.
echo ============================================
pause
