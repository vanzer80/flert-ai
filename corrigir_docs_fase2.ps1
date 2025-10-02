# Script de Correção Fase 2 - Limpar Duplicações e Completar Reorganização
# FlertAI - Documentação Profissional

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  FlertAI - Correção Fase 2" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$moved = 0
$deleted = 0

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
        }
    }
}

Write-Host "[1/5] Movendo arquivos de documentacao/desenvolvimento/ para 02-desenvolvimento/..." -ForegroundColor Cyan
Write-Host ""

# Mover arquivos restantes de desenvolvimento
Move-Doc "documentacao/desenvolvimento/ANALISE_COMPLETA_IMPLEMENTACAO.md" "documentacao/02-desenvolvimento/features/"
Move-Doc "documentacao/desenvolvimento/CICLO_FEEDBACK_E_APRENDIZADO.md" "documentacao/02-desenvolvimento/features/"
Move-Doc "documentacao/desenvolvimento/DIAGNOSTICO_IMPLEMENTACAO_FRONTEND.md" "documentacao/05-troubleshooting/frontend/"
Move-Doc "documentacao/desenvolvimento/INTEGRACAO_IA_EXECUTADA.md" "documentacao/03-integracao/openai/"
Move-Doc "documentacao/desenvolvimento/RESUMO_IMPLEMENTACAO_REGIAO.md" "documentacao/02-desenvolvimento/features/"
Move-Doc "documentacao/desenvolvimento/STATUS_TAREFA_CULTURAL_REFERENCES.md" "documentacao/03-integracao/cultural-references/"
Move-Doc "documentacao/desenvolvimento/SUCESSO_DEPLOY_PRODUCAO.md" "documentacao/04-deploy/"
Move-Doc "documentacao/desenvolvimento/SUCESSO_IMPLEMENTACAO_SELETOR_FOCOS.md" "documentacao/02-desenvolvimento/features/"

# Deletar COMMIT_MESSAGE.txt se existir
if (Test-Path "documentacao/desenvolvimento/COMMIT_MESSAGE.txt") {
    Remove-Item "documentacao/desenvolvimento/COMMIT_MESSAGE.txt" -Force
    Write-Host "[DEL] documentacao/desenvolvimento/COMMIT_MESSAGE.txt" -ForegroundColor Yellow
    $script:deleted++
}

# Mover arquivos restantes gerais (PROXIMOS_PASSOS já foi movido antes)
if (Test-Path "documentacao/desenvolvimento/RESUMO_EXECUCAO.md") {
    # Já deve estar em historico/, verificar
    Write-Host "[SKIP] RESUMO_EXECUCAO.md (já movido)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[2/5] Movendo arquivos de sql_comandos/ para 08-sql/..." -ForegroundColor Cyan
Write-Host ""

# Mover arquivos SQL restantes
Move-Doc "sql_comandos/04_seed_data.sql" "documentacao/08-sql/migrations/"
Move-Doc "sql_comandos/README_COMANDOS_SEPARADOS.md" "documentacao/08-sql/"
Move-Doc "sql_comandos/correcao_rapida_stats.sql" "documentacao/08-sql/queries/"
Move-Doc "sql_comandos/verificar_01_tabela.sql" "documentacao/08-sql/queries/"
Move-Doc "sql_comandos/verificar_02_funcoes.sql" "documentacao/08-sql/queries/"
Move-Doc "sql_comandos/verificar_final.sql" "documentacao/08-sql/queries/"

Write-Host ""
Write-Host "[3/5] Limpando pastas antigas vazias..." -ForegroundColor Cyan
Write-Host ""

# Deletar pastas antigas se vazias
$oldFolders = @("documentacao/desenvolvimento", "documentacao/auditoria", "sql_comandos", "documentacao/troubleshooting", "documentacao/guias")

foreach ($folder in $oldFolders) {
    if (Test-Path $folder) {
        $items = Get-ChildItem $folder -Recurse -File
        if ($items.Count -eq 0) {
            Remove-Item $folder -Recurse -Force
            Write-Host "[DEL] $folder/ (vazia)" -ForegroundColor Yellow
            $script:deleted++
        } else {
            Write-Host "[KEEP] $folder/ (contém $($items.Count) arquivo(s))" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "[4/5] Movendo arquivos temporários da raiz..." -ForegroundColor Cyan
Write-Host ""

# Mover arquivos temporários
Move-Doc "PLANO_REORGANIZACAO_DOCUMENTACAO.md" "documentacao/"
Move-Doc "ANALISE_REORGANIZACAO.md" "documentacao/"

# Deletar script após uso ou mover para scripts/
if (Test-Path "reorganizar_docs.ps1") {
    Move-Item "reorganizar_docs.ps1" "scripts/" -Force
    Write-Host "[OK] reorganizar_docs.ps1 -> scripts/" -ForegroundColor Green
    $script:moved++
}

Write-Host ""
Write-Host "[5/5] Resumo final..." -ForegroundColor Cyan
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  CORREÇÃO FASE 2 CONCLUÍDA!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Arquivos movidos: $moved" -ForegroundColor Green
Write-Host "Itens deletados: $deleted" -ForegroundColor Yellow
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Cyan
Write-Host "1. Criar READMEs faltando (02, 04, 06, 08)" -ForegroundColor White
Write-Host "2. Executar: git add ." -ForegroundColor White
Write-Host "3. Executar: git commit -m 'docs: Corrigir duplicacoes e completar reorganizacao'" -ForegroundColor White
Write-Host "4. Executar: git push origin main" -ForegroundColor White
Write-Host ""
