# 🚀 GUIA DE DEPLOY MANUAL NO NETLIFY

**Método:** Build local + Deploy manual (100% confiável)  
**Motivo:** Evita problemas de submódulo e ambiente no CI/CD do Netlify

---

## ⚡ MÉTODO 1: Netlify Drop (Mais Simples - Recomendado)

### Passo 1: Build Local
```bash
flutter build web --release --no-tree-shake-icons
```
**Tempo:** 30-60 segundos  
**Resultado:** Arquivos gerados em `build/web/`

### Passo 2: Deploy via Drag & Drop
1. Acesse: https://app.netlify.com/drop
2. Faça login (se necessário)
3. **Arraste a pasta** `build/web` para a janela do navegador
4. Aguarde upload (10-30 segundos)
5. Pronto! Netlify gera URL automaticamente

**Vantagens:**
- ✅ Rápido (2 minutos total)
- ✅ Sem configuração necessária
- ✅ Sem erros de ambiente/submódulo
- ✅ 100% de confiabilidade

**Desvantagens:**
- ❌ Manual (precisa repetir a cada atualização)
- ❌ Não integrado ao Git

---

## ⚡ MÉTODO 2: Netlify CLI (Automático via Linha de Comando)

### Passo 1: Instalar Netlify CLI (Uma vez)
```bash
npm install -g netlify-cli
```

### Passo 2: Fazer Login (Uma vez)
```bash
netlify login
```
**Ação:** Abre navegador para autorização

### Passo 3: Build + Deploy
```bash
# Build local
flutter build web --release --no-tree-shake-icons

# Deploy para produção
netlify deploy --prod --dir=build/web
```

**Primeira vez:** O CLI pedirá para selecionar/criar site no Netlify

**Vantagens:**
- ✅ Mais rápido que arrastar pasta
- ✅ Pode ser scriptado/automatizado
- ✅ Mantém histórico de deploys
- ✅ 100% de confiabilidade

**Desvantagens:**
- ❌ Requer instalação do CLI
- ❌ Precisa rodar comando manualmente

---

## ⚡ MÉTODO 3: Git + Netlify (Deploy Automático)

**STATUS:** ❌ **NÃO RECOMENDADO NO MOMENTO**

**Problema:** Histórico do Git contém referência a submódulo `flutter/` que causa erro:
```
Error checking out submodules: fatal: No url found for submodule path 'flutter' in .gitmodules
```

**Solução futura:** Limpar histórico do Git ou aguardar que Netlify ignore submódulos ausentes.

Por ora, use **Método 1** ou **Método 2**.

---

## 📋 WORKFLOW RECOMENDADO

### Para Desenvolvimento Diário:

**Opção A: Deploy Manual (Simples)**
```bash
# 1. Fazer mudanças no código
# 2. Testar localmente
flutter run -d chrome

# 3. Build para produção
flutter build web --release --no-tree-shake-icons

# 4. Deploy via Netlify Drop
# Arrastar build/web para https://app.netlify.com/drop
```

**Opção B: Deploy via CLI (Mais Rápido)**
```bash
# 1. Fazer mudanças no código
# 2. Testar localmente
flutter run -d chrome

# 3. Build + Deploy em um comando
flutter build web --release --no-tree-shake-icons && netlify deploy --prod --dir=build/web
```

---

## 🔧 TROUBLESHOOTING

### Problema: "Build takes too long"
**Solução:** 
- Use `flutter build web --release` (sem outras flags)
- Build incremental é rápido (10-20s após primeiro build)

### Problema: "Netlify Drop não aceita minha pasta"
**Solução:**
- Certifique-se de arrastar **build/web**, não **build**
- Verifique se há arquivo `index.html` em `build/web/`

### Problema: "Site não atualiza após deploy"
**Solução:**
- Limpe cache do navegador (Ctrl+Shift+R)
- Aguarde 30-60s para propagação do CDN do Netlify
- Verifique se fez deploy para o site correto

### Problema: "Netlify CLI não encontra site"
**Solução:**
```bash
# Vincular CLI ao site existente
netlify link

# OU criar novo site
netlify sites:create
```

---

## 📊 COMPARAÇÃO DE MÉTODOS

| Método | Tempo | Complexidade | Automação | Confiabilidade |
|--------|-------|--------------|-----------|----------------|
| **Netlify Drop** | 2 min | ⭐ Simples | ❌ Manual | ✅ 100% |
| **Netlify CLI** | 1 min | ⭐⭐ Médio | ⚠️ Script | ✅ 100% |
| **Git + Netlify** | Auto | ⭐⭐⭐⭐ Alto | ✅ Total | ❌ Falha |

---

## ✅ CHECKLIST DE DEPLOY

### Pré-Deploy:
- [ ] Código testado localmente (`flutter run -d chrome`)
- [ ] Todas as mudanças commitadas no Git
- [ ] Sem erros no console do navegador

### Deploy:
- [ ] Build local concluído (`flutter build web`)
- [ ] Pasta `build/web/` contém `index.html`
- [ ] Deploy via Netlify Drop ou CLI
- [ ] URL do site acessível

### Pós-Deploy:
- [ ] Site abre sem erros
- [ ] Funcionalidades testadas:
  - [ ] Upload de imagem
  - [ ] Geração de sugestões
  - [ ] Botão "Gerar Mais"
  - [ ] Seleção de tom
- [ ] Versão correta deployada

---

## 🎯 RECOMENDAÇÃO FINAL

**Para agora:** Use **Netlify Drop** (Método 1)
- Mais simples
- Mais rápido
- Zero configuração
- 100% confiável

**Para futuro:** Migrar para **Netlify CLI** (Método 2)
- Pode ser scriptado
- Mais profissional
- Mantém confiabilidade

**Git + Netlify:** Aguardar resolução do problema de submódulo ou limpar histórico do Git (operação avançada).

---

## 📝 SCRIPT AUXILIAR (OPCIONAL)

Crie um arquivo `deploy.bat` (Windows) ou `deploy.sh` (Linux/Mac):

**Windows (deploy.bat):**
```batch
@echo off
echo === FlertAI - Deploy para Netlify ===
echo.

echo [1/2] Building Flutter web...
call flutter build web --release --no-tree-shake-icons
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo [2/2] Deploying to Netlify...
call netlify deploy --prod --dir=build/web
if errorlevel 1 (
    echo ERROR: Deploy failed!
    pause
    exit /b 1
)

echo.
echo === Deploy completed successfully! ===
pause
```

**Uso:** Duplo clique em `deploy.bat`

---

**Última atualização:** 2025-10-02 08:04  
**Versão:** 1.0  
**Status:** ✅ Método manual 100% funcional
