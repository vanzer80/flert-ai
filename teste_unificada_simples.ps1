# TESTE FUNCAO UNIFICADA - SIMPLES
# Data: 2025-10-06 16:11

Write-Host "TESTE FUNCAO UNIFICADA" -ForegroundColor Cyan
Write-Host "=" -NoNewline
Write-Host "=" -NoNewline
Write-Host "=" -NoNewline
Write-Host "=" -NoNewline
Write-Host "=" -NoNewline
Write-Host "="

$url = "https://olojvpoqosrjcoxygiyf.supabase.co/functions/v1/analyze-unified"
$key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sb2p2cG9xb3NyamNveHlnaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTUxNTEsImV4cCI6MjA3NDY3MTE1MX0.QyJcKSHfWA0RyzoucvSObabOl5lsdgvJ3BnZsBy7HX8"

Write-Host ""
Write-Host "TESTE 1: Payload Texto (Flutter)" -ForegroundColor Yellow

$body1 = '{"tone":"flertar","text":"Ola! Tudo bem?"}'

try {
    $resp1 = Invoke-RestMethod -Uri $url -Method POST -Headers @{
        "Authorization" = "Bearer $key"
        "Content-Type" = "application/json"
    } -Body $body1 -TimeoutSec 30
    
    Write-Host "OK Status 200" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Green
    Write-Host ($resp1 | ConvertTo-Json -Depth 5)
    $test1 = $true
} catch {
    Write-Host "ERRO:" $_.Exception.Message -ForegroundColor Red
    $test1 = $false
}

Write-Host ""
Write-Host "TESTE 2: Payload Imagem (Web)" -ForegroundColor Yellow

$img = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
$body2 = "{`"image`":`"$img`",`"tone`":`"descontraido`"}"

try {
    $resp2 = Invoke-RestMethod -Uri $url -Method POST -Headers @{
        "Authorization" = "Bearer $key"
        "Content-Type" = "application/json"
    } -Body $body2 -TimeoutSec 30
    
    Write-Host "OK Status 200" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Green
    Write-Host ($resp2 | ConvertTo-Json -Depth 5)
    $test2 = $true
} catch {
    Write-Host "ERRO:" $_.Exception.Message -ForegroundColor Red
    $test2 = $false
}

Write-Host ""
Write-Host "RESUMO" -ForegroundColor Cyan
Write-Host "=" -NoNewline
Write-Host "=" -NoNewline
Write-Host "=" -NoNewline
Write-Host "="

if ($test1) { 
    Write-Host "Teste 1 (Texto): PASSOU" -ForegroundColor Green 
} else { 
    Write-Host "Teste 1 (Texto): FALHOU" -ForegroundColor Red 
}

if ($test2) { 
    Write-Host "Teste 2 (Imagem): PASSOU" -ForegroundColor Green 
} else { 
    Write-Host "Teste 2 (Imagem): FALHOU" -ForegroundColor Red 
}

Write-Host ""
if ($test1 -and $test2) {
    Write-Host "SUCESSO TOTAL! Funcao unificada OK!" -ForegroundColor Green
    Write-Host ""
    Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
    Write-Host "1. Atualizar Flutter app" 
    Write-Host "2. Atualizar Web app"
    Write-Host "3. Testes completos"
    Write-Host "4. Commit inicial"
} elseif ($test1) {
    Write-Host "PARCIAL: Texto OK, Imagem com problema" -ForegroundColor Yellow
} else {
    Write-Host "FALHA: Verificar logs da funcao" -ForegroundColor Red
}
