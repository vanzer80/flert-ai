# Script de Reorganização Completa da Documentação
# FlertAI - Centralização Profissional

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  FlertAI - Reorganização de Documentação" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$moved = 0
$errors = 0

# Função para mover arquivo com log
function Move-Doc {
    param($Source, $Dest)
    if (Test-Path $Source) {
        try {
            Move-Item -Path $Source -Destination $Dest -Force
            Write-Host "[OK] $Source -> $Dest" -ForegroundColor Green
            $script:moved++
        } catch {
            Write-Host "[ERRO] $Source : $_" -ForegroundColor Red
            $script:errors++
        }
    } else {
        Write-Host "[SKIP] $Source (não existe)" -ForegroundColor Yellow
    }
}

Write-Host "[1/5] Movendo arquivos da RAIZ..." -ForegroundColor Cyan
Write-Host ""

# 01-inicio/
Move-Doc "INICIO_RAPIDO.md" "documentacao/01-inicio/"
Move-Doc "EXECUTAR_SETUP.md" "documentacao/01-inicio/"

# 02-desenvolvimento/
Move-Doc "PROXIMOS_PASSOS_IMPORTANTES.md" "documentacao/02-desenvolvimento/"
Move-Doc "RESUMO_EXECUCAO.md" "documentacao/02-desenvolvimento/historico/"
Move-Doc "RESUMO_IMPLEMENTACAO_CONVERSAS.md" "documentacao/02-desenvolvimento/features/"

# 03-integracao/
Move-Doc "GUIA_INTEGRACAO_IA.md" "documentacao/03-integracao/openai/"
Move-Doc "RESUMO_INTEGRACAO_IA.md" "documentacao/03-integracao/openai/"
Move-Doc "GUIA_SUPABASE_LINKS_SQL.md" "documentacao/03-integracao/supabase/"
Move-Doc "docs/INTEGRACAO_CULTURAL_REFERENCES.md" "documentacao/03-integracao/cultural-references/"

# 04-deploy/
Move-Doc "VERIFICACAO_DEPLOY.md" "documentacao/04-deploy/"

# 05-troubleshooting/
Move-Doc "CORRECAO_ERRO_STATS.md" "documentacao/05-troubleshooting/geral/"

# 06-auditoria/
Move-Doc "AUDITORIA_COMPLETA.md" "documentacao/06-auditoria/completa/"
Move-Doc "STATUS_FINAL.md" "documentacao/06-auditoria/status/"
Move-Doc "VERIFICACAO_FINAL_V2.1.0.md" "documentacao/06-auditoria/"

# 07-relatorios/
Move-Doc "RELATORIO_FINAL_IMPLEMENTACAO.md" "documentacao/07-relatorios/v2.0.0/"
Move-Doc "RELATORIO_V2.1.0.md" "documentacao/07-relatorios/v2.1.0/"

Write-Host ""
Write-Host "[2/5] Movendo arquivos de SQL..." -ForegroundColor Cyan
Write-Host ""

# 08-sql/
Move-Doc "supabase_schema.sql" "documentacao/08-sql/schema/"
Move-Doc "sql_comandos/01_criar_tabela.sql" "documentacao/08-sql/migrations/"
Move-Doc "sql_comandos/02_indices_rls.sql" "documentacao/08-sql/migrations/"
Move-Doc "sql_comandos/03_funcoes_helper.sql" "documentacao/08-sql/migrations/"
Move-Doc "sql_comandos/03_funcoes_helper_corrigida.sql" "documentacao/08-sql/migrations/"
Move-Doc "sql_comandos/04_funcoes_avancadas.sql" "documentacao/08-sql/migrations/"
Move-Doc "sql_comandos/05_triggers.sql" "documentacao/08-sql/migrations/"
Move-Doc "sql_comandos/06_views.sql" "documentacao/08-sql/migrations/"
Move-Doc "sql_comandos/README.md" "documentacao/08-sql/"

Write-Host ""
Write-Host "[3/5] Reorganizando arquivos internos..." -ForegroundColor Cyan
Write-Host ""

# Mover arquivos de desenvolvimento para subpastas
Move-Doc "documentacao/desenvolvimento/IMPLEMENTACAO_CONVERSAS_SEGMENTADAS.md" "documentacao/02-desenvolvimento/features/"
Move-Doc "documentacao/desenvolvimento/IMPLEMENTACAO_DETECCAO_REGIAO.md" "documentacao/02-desenvolvimento/features/"
Move-Doc "documentacao/desenvolvimento/IMPLEMENTACAO_SELETOR_FOCOS.md" "documentacao/02-desenvolvimento/features/"
Move-Doc "documentacao/desenvolvimento/IMPLEMENTACAO_SISTEMA_FEEDBACK.md" "documentacao/02-desenvolvimento/features/"
Move-Doc "documentacao/desenvolvimento/SISTEMA_APRENDIZADO_AUTOMATICO.md" "documentacao/02-desenvolvimento/features/"
Move-Doc "documentacao/desenvolvimento/HISTORICO_CONVERSA_SYSTEM_PROMPT.md" "documentacao/02-desenvolvimento/features/"

Move-Doc "documentacao/desenvolvimento/CORRECOES_ALUCINACOES_E_CONTEXTO.md" "documentacao/02-desenvolvimento/correcoes/"
Move-Doc "documentacao/desenvolvimento/CORRECAO_REGIAO_SEM_AUTH.md" "documentacao/02-desenvolvimento/correcoes/"

# Mover troubleshooting
Move-Doc "documentacao/troubleshooting/ERROS_DEPLOY_AUTOMATICO.md" "documentacao/04-deploy/troubleshooting/"
Move-Doc "documentacao/troubleshooting/ESTRATEGIAS_TESTADAS_DEPLOY.md" "documentacao/04-deploy/troubleshooting/"
Move-Doc "documentacao/troubleshooting/PENDENCIAS_DEPLOY_AUTOMATICO.md" "documentacao/04-deploy/troubleshooting/"

# Mover guias de deploy
Move-Doc "documentacao/guias/deploy/DEPLOY_MANUAL_NETLIFY.md" "documentacao/04-deploy/manual/"
Move-Doc "documentacao/guias/deploy/ANALISE_ERROS_DEPLOY_GITHUB_ACTIONS.md" "documentacao/04-deploy/troubleshooting/"
Move-Doc "documentacao/guias/deploy/GUIA_DEPLOY_FLERTAI.md" "documentacao/04-deploy/"

Write-Host ""
Write-Host "[4/5] Deletando arquivos temporários..." -ForegroundColor Cyan
Write-Host ""

# Deletar temporários
if (Test-Path "COMMIT_MESSAGE.txt") {
    Remove-Item "COMMIT_MESSAGE.txt" -Force
    Write-Host "[DEL] COMMIT_MESSAGE.txt" -ForegroundColor Yellow
}
if (Test-Path "COMMIT_MESSAGE_CONVERSAS_SEGMENTADAS.txt") {
    Remove-Item "COMMIT_MESSAGE_CONVERSAS_SEGMENTADAS.txt" -Force
    Write-Host "[DEL] COMMIT_MESSAGE_CONVERSAS_SEGMENTADAS.txt" -ForegroundColor Yellow
}
if (Test-Path ".temp_deploy_index.ts") {
    Remove-Item ".temp_deploy_index.ts" -Force
    Write-Host "[DEL] .temp_deploy_index.ts" -ForegroundColor Yellow
}
if (Test-Path "DOCUMENTACAO_CENTRALIZADA.md") {
    Remove-Item "DOCUMENTACAO_CENTRALIZADA.md" -Force
    Write-Host "[DEL] DOCUMENTACAO_CENTRALIZADA.md (será recriado)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[5/5] Deletando pastas antigas vazias..." -ForegroundColor Cyan
Write-Host ""

# Deletar pastas antigas se estiverem vazias
$oldFolders = @("docs", "sql_comandos", "documentacao/desenvolvimento", "documentacao/troubleshooting", "documentacao/guias/deploy", "documentacao/guias/inicio-rapido", "documentacao/guias/integracao", "documentacao/guias/setup", "documentacao/auditoria")

foreach ($folder in $oldFolders) {
    if (Test-Path $folder) {
        $items = Get-ChildItem $folder -Recurse
        if ($items.Count -eq 0) {
            Remove-Item $folder -Recurse -Force
            Write-Host "[DEL] $folder (vazia)" -ForegroundColor Yellow
        } else {
            Write-Host "[KEEP] $folder (contém $($items.Count) itens)" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  REORGANIZAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Arquivos movidos: $moved" -ForegroundColor Green
Write-Host "Erros: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Cyan
Write-Host "1. Revisar estrutura em documentacao/" -ForegroundColor White
Write-Host "2. Executar: git add ." -ForegroundColor White
Write-Host "3. Executar: git commit -m 'docs: Reorganizacao completa - centralizacao profissional'" -ForegroundColor White
Write-Host "4. Executar: git push origin main" -ForegroundColor White
Write-Host ""
