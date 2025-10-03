# Script de teste simplificado para FlertAI
$headers = @{
    'Authorization' = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sb2p2cG9xb3NyamNveHlnaXlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwOTUxNTEsImV4cCI6MjA3NDY3MTE1MX0.QyJcKSHfWA0RyzoucvSObabOl5lsdgvJ3BnZsBy7HX8'
    'Content-Type' = 'application/json'
}

$body = '{"tone":"flertar","text":"Teste sistema operacional"}'

try {
    $response = Invoke-WebRequest -Uri 'https://olojvpoqosrjcoxygiyf.supabase.co/functions/v1/analyze-conversation' -Method POST -Headers $headers -Body $body -UseBasicParsing
    Write-Host "SUCESSO: Status $($response.StatusCode)"
    $json = $response.Content | ConvertFrom-Json
    Write-Host "Modelo usado: $($json.usage_info.model_used)"
    Write-Host "Tokens: $($json.usage_info.tokens_used)"
    Write-Host "Sugestao: $($json.suggestions[0])"
    Write-Host "Sistema operacional confirmado!"
} catch {
    Write-Host "ERRO: $($_.Exception.Message)"
}
