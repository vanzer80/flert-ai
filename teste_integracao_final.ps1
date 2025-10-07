# TESTE INTEGRACAO FINAL - FASE 7
# Data: 2025-10-06 16:20
# Valida sistema hibrido completo

Write-Host "TESTE INTEGRACAO FINAL - SISTEMA HIBRIDO" -ForegroundColor Cyan
Write-Host "=========================================="
Write-Host ""

$url_base = "https://olojvpoqosrjcoxygiyf.supabase.co"
$anon = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sb2p2cG9xb3NyamNveHlnaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTUxNTEsImV4cCI6MjA3NDY3MTE1MX0.QyJcKSHfWA0RyzoucvSObabOl5lsdgvJ3BnZsBy7HX8"

# TESTE FLUTTER (texto)
Write-Host "1. TESTE FLUTTER APP (texto)" -ForegroundColor Yellow
$body_flutter = '{"tone":"flertar","text":"Oi! Como vai?"}'
try {
    $r1 = Invoke-RestMethod -Uri "$url_base/functions/v1/analyze-unified" -Method POST -Headers @{
        "Authorization" = "Bearer $anon"
        "Content-Type" = "application/json"
    } -Body $body_flutter -TimeoutSec 30
    Write-Host "   OK - Status 200" -ForegroundColor Green
    Write-Host "   Sugestoes: $($r1.suggestions.Count)" -ForegroundColor Green
    $t1 = $true
} catch {
    Write-Host "   ERRO: $($_.Exception.Message)" -ForegroundColor Red
    $t1 = $false
}

Write-Host ""

# TESTE WEB (imagem)
Write-Host "2. TESTE WEB APP (imagem)" -ForegroundColor Yellow
$img_base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
$body_web = "{`"image`":`"$img_base64`",`"tone`":`"romantico`"}"
try {
    $r2 = Invoke-RestMethod -Uri "$url_base/functions/v1/analyze-unified" -Method POST -Headers @{
        "Authorization" = "Bearer $anon"
        "Content-Type" = "application/json"
    } -Body $body_web -TimeoutSec 30
    Write-Host "   OK - Status 200" -ForegroundColor Green
    Write-Host "   Analise visual: OK" -ForegroundColor Green
    $t2 = $true
} catch {
    Write-Host "   ERRO: $($_.Exception.Message)" -ForegroundColor Red
    $t2 = $false
}

Write-Host ""
Write-Host "=========================================="
Write-Host "RESULTADO FINAL" -ForegroundColor Cyan
Write-Host "=========================================="

if ($t1) { Write-Host "Flutter App: PASSOU" -ForegroundColor Green } 
else { Write-Host "Flutter App: FALHOU" -ForegroundColor Red }

if ($t2) { Write-Host "Web App: PASSOU" -ForegroundColor Green } 
else { Write-Host "Web App: FALHOU" -ForegroundColor Red }

Write-Host ""
if ($t1 -and $t2) {
    Write-Host "SUCESSO TOTAL! Sistema hibrido funcionando!" -ForegroundColor Green
    Write-Host ""
    Write-Host "FASE 7: COMPLETA (95%)" -ForegroundColor Cyan
    Write-Host "- Backend unificado: OK" -ForegroundColor White
    Write-Host "- Flutter app: OK" -ForegroundColor White
    Write-Host "- Web app: OK" -ForegroundColor White
    Write-Host ""
    Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
    Write-Host "1. Deploy Web App no Netlify" -ForegroundColor White
    Write-Host "2. Build Flutter APK para testes" -ForegroundColor White
    Write-Host "3. Periodo de validacao com usuarios" -ForegroundColor White
} else {
    Write-Host "ATENCAO: Alguns testes falharam" -ForegroundColor Yellow
}
