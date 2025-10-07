@echo off
echo ========================================
echo   DEPLOY - FlertaAI Edge Function
echo ========================================
echo.
echo Fazendo deploy da funcao corrigida...
echo.

cd /d "c:\Users\vanze\FlertAI\flerta_ai"
supabase functions deploy analyze-image-with-vision

echo.
echo ========================================
echo   Deploy concluido!
echo ========================================
echo.
pause
