# TESTE WEB APP CORRIGIDO
# Data: 2025-10-06 16:47
# Objetivo: Validar correção do erro forEach

Write-Host "TESTE WEB APP - ANALISE UNIFICADA" -ForegroundColor Cyan
Write-Host "=" * 50
Write-Host ""

$url = "https://olojvpoqosrjcoxygiyf.supabase.co/functions/v1/analyze-unified"
$key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sb2p2cG9xb3NyamNveHlnaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTUxNTEsImV4cCI6MjA3NDY3MTE1MX0.QyJcKSHfWA0RyzoucvSObabOl5lsdgvJ3BnZsBy7HX8"

Write-Host "Testando payload de imagem..." -ForegroundColor Yellow

# Imagem teste (1x1 pixel PNG)
$img = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

$body = @{
    image = $img
    tone = "descontraído"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $url -Method POST -Headers @{
        "Authorization" = "Bearer $key"
        "Content-Type" = "application/json"
    } -Body $body -TimeoutSec 30
    
    Write-Host "OK - Status 200" -ForegroundColor Green
    Write-Host ""
    Write-Host "ESTRUTURA DA RESPOSTA:" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    
    # Mostrar estrutura para verificar campos
    Write-Host "success:" $response.success
    
    if ($response.suggestions) {
        Write-Host "suggestions[0]:" $response.suggestions[0]
    }
    
    if ($response.visual_analysis) {
        Write-Host "visual_analysis:" $response.visual_analysis
    }
    
    if ($response.elements_detected) {
        Write-Host "elements_detected:" ($response.elements_detected -join ", ")
    }
    
    if ($response.processing_time_ms) {
        Write-Host "processing_time_ms:" $response.processing_time_ms
    }
    
    Write-Host ""
    Write-Host "RESPOSTA COMPLETA:" -ForegroundColor Cyan
    Write-Host ($response | ConvertTo-Json -Depth 5)
    
    Write-Host ""
    Write-Host "SUCESSO! Web app deveria funcionar agora!" -ForegroundColor Green
    
} catch {
    Write-Host "ERRO:" $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "=" * 50
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Atualizar deploy do web_app no Netlify"
Write-Host "2. Testar upload de imagem real"
Write-Host "3. Verificar se erro forEach foi resolvido"
