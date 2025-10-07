# 🧪 TESTE FASE 7 - VALIDAÇÃO FUNÇÃO UNIFICADA
# Data: 2025-10-06 16:11
# Objetivo: Validar função analyze-unified com secrets configuradas

Write-Host "🚀 TESTE FASE 7 - VALIDAÇÃO FUNÇÃO UNIFICADA" -ForegroundColor Cyan
Write-Host "=" * 60

# Credenciais
$SUPABASE_URL = "https://olojvpoqosrjcoxygiyf.supabase.co"
$ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sb2p2cG9xb3NyamNveHlnaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTUxNTEsImV4cCI6MjA3NDY3MTE1MX0.QyJcKSHfWA0RyzoucvSObabOl5lsdgvJ3BnZsBy7HX8"

Write-Host ""
Write-Host "✅ Secrets configuradas no Supabase Dashboard:" -ForegroundColor Green
Write-Host "   - OPENAI_API_KEY: ✅ Configurada (03 Oct 2025)" -ForegroundColor Green
Write-Host "   - SERVICE_ROLE_KEY_supabase: ✅ Configurada (01 Oct 2025)" -ForegroundColor Green
Write-Host "   - SUPABASE_URL: ✅ Configurada" -ForegroundColor Green
Write-Host "   - SUPABASE_ANON_KEY: ✅ Configurada" -ForegroundColor Green
Write-Host ""

# TESTE 1: Payload Texto (Flutter)
Write-Host "📝 TESTE 1: Payload Texto (Flutter)" -ForegroundColor Yellow
Write-Host "-" * 60

$payload1 = @{
    tone = "flertar"
    text = "Olá! Tudo bem? 😊"
} | ConvertTo-Json

Write-Host "Enviando requisição para analyze-unified..." -ForegroundColor Gray

try {
    $response1 = Invoke-WebRequest -Uri "$SUPABASE_URL/functions/v1/analyze-unified" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $ANON_KEY"
            "Content-Type" = "application/json"
        } `
        -Body $payload1 `
        -TimeoutSec 30

    Write-Host "✅ Status: $($response1.StatusCode)" -ForegroundColor Green
    Write-Host "✅ Resposta:" -ForegroundColor Green
    Write-Host ($response1.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
    $teste1_ok = $true
} catch {
    Write-Host "❌ ERRO: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    $teste1_ok = $false
}

Write-Host ""
Write-Host "=" * 60
Write-Host ""

# TESTE 2: Payload Imagem (Web)
Write-Host "🖼️ TESTE 2: Payload Imagem (Web)" -ForegroundColor Yellow
Write-Host "-" * 60

# Criar imagem de teste base64 (1x1 pixel PNG transparente)
$testImage = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

$payload2 = @{
    image = $testImage
    tone = "descontraído"
} | ConvertTo-Json

Write-Host "Enviando requisição para analyze-unified..." -ForegroundColor Gray

try {
    $response2 = Invoke-WebRequest -Uri "$SUPABASE_URL/functions/v1/analyze-unified" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $ANON_KEY"
            "Content-Type" = "application/json"
        } `
        -Body $payload2 `
        -TimeoutSec 30

    Write-Host "✅ Status: $($response2.StatusCode)" -ForegroundColor Green
    Write-Host "✅ Resposta:" -ForegroundColor Green
    Write-Host ($response2.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
    $teste2_ok = $true
} catch {
    Write-Host "❌ ERRO: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
    $teste2_ok = $false
}

Write-Host ""
Write-Host "=" * 60
Write-Host ""

# RESUMO FINAL
Write-Host "📊 RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "=" * 60

if ($teste1_ok) {
    Write-Host "✅ TESTE 1 (Texto): PASSOU" -ForegroundColor Green
} else {
    Write-Host "❌ TESTE 1 (Texto): FALHOU" -ForegroundColor Red
}

if ($teste2_ok) {
    Write-Host "✅ TESTE 2 (Imagem): PASSOU" -ForegroundColor Green
} else {
    Write-Host "❌ TESTE 2 (Imagem): FALHOU" -ForegroundColor Red
}

Write-Host ""

if ($teste1_ok -and $teste2_ok) {
    Write-Host "🎉 SUCESSO TOTAL! Função unificada funcionando perfeitamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ PRÓXIMOS PASSOS DA FASE 7:" -ForegroundColor Cyan
    Write-Host "   1. Atualizar Flutter app para usar analyze-unified" -ForegroundColor White
    Write-Host "   2. Atualizar Web app para usar analyze-unified" -ForegroundColor White
    Write-Host "   3. Executar testes de integração completos" -ForegroundColor White
    Write-Host "   4. Commit inicial do projeto limpo" -ForegroundColor White
    Write-Host "   5. Documentação final" -ForegroundColor White
} elseif ($teste1_ok) {
    Write-Host "⚠️ PARCIAL: Texto OK, Imagem com problema" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔍 DIAGNÓSTICO:" -ForegroundColor Cyan
    Write-Host "   - Função básica funcionando" -ForegroundColor White
    Write-Host "   - Problema pode ser com OPENAI_API_KEY ou modelo Vision" -ForegroundColor White
    Write-Host "   - Verificar logs: supabase functions logs analyze-unified --follow" -ForegroundColor White
} else {
    Write-Host "❌ FALHA: Secrets podem estar incorretas ou função com erro" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔍 AÇÕES SUGERIDAS:" -ForegroundColor Cyan
    Write-Host "   1. Verificar logs: supabase functions logs analyze-unified --follow" -ForegroundColor White
    Write-Host "   2. Redeploy: supabase functions deploy analyze-unified" -ForegroundColor White
    Write-Host "   3. Validar secrets no Dashboard Supabase" -ForegroundColor White
}

Write-Host ""
Write-Host "=" * 60
