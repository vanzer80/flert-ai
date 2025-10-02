# 🚀 04 - DEPLOY

Documentação completa de **deploy e CI/CD** do FlertAI.

---

## 📚 ESTRUTURA DESTA SEÇÃO

### 📦 **manual/** - Deploy Manual (Recomendado)
Método 100% confiável:

| Arquivo | Método | Confiabilidade |
|---------|--------|----------------|
| `DEPLOY_MANUAL_NETLIFY.md` | **Guia completo de deploy manual** | ✅ **100%** |

### 🤖 **automatico/** - Deploy Automático (Histórico)
Tentativas de automatização:

| Status | Descrição |
|--------|-----------|
| ⚠️ **Em investigação** | GitHub Actions com problemas de submódulo |

### 🔧 **troubleshooting/** - Problemas de Deploy
Resolução de problemas encontrados:

| Arquivo | Problema Resolvido |
|---------|-------------------|
| `ANALISE_ERROS_DEPLOY_GITHUB_ACTIONS.md` | Análise profunda de erros de submódulo |
| `ERROS_DEPLOY_AUTOMATICO.md` | Erros gerais de deploy automático |
| `ESTRATEGIAS_TESTADAS_DEPLOY.md` | 6 estratégias testadas (histórico) |
| `PENDENCIAS_DEPLOY_AUTOMATICO.md` | Pendências para automação futura |

### 📋 **Arquivos Raiz**
| Arquivo | Descrição |
|---------|-----------|
| `GUIA_DEPLOY_FLERTAI.md` | Guia geral e histórico |
| `VERIFICACAO_DEPLOY.md` | Verificações de deploy |
| `SUCESSO_DEPLOY_PRODUCAO.md` | Deploy bem-sucedido em produção |

---

## 🎯 MÉTODO ATUAL (RECOMENDADO)

### **Deploy Manual via Netlify Drop**

**Passo 1: Build Local**
```bash
flutter build web --release --no-tree-shake-icons
```

**Passo 2: Upload**
- Acesse: https://app.netlify.com/drop
- Arraste a pasta `build/web`
- Aguarde 10-30 segundos

**Confiabilidade:** ✅ **100%**  
**Tempo total:** 2 minutos  
**Complexidade:** ⭐ Muito Simples

---

## ⚠️ PROBLEMAS CONHECIDOS

### **GitHub Actions**
- ❌ **Erro de submódulo:** "No url found for submodule path 'flutter'"
- ❌ **Causa:** Histórico do Git contém referência ao submódulo
- ✅ **Solução:** Deploy manual (evita clone do repositório)

### **Netlify Build Automático**
- ❌ **Problema:** Ambiente Ubuntu com diferenças de Windows local
- ❌ **Tree-shaking:** Falhas específicas no CI/CD
- ✅ **Solução:** Build local + upload manual

---

## 🔗 NAVEGAÇÃO

- **⬅️ Anterior:** [03-integracao/](../03-integracao/) - Integrações externas
- **➡️ Próximo:** [05-troubleshooting/](../05-troubleshooting/) - Resolução de problemas

---

**📅 Seção criada em:** 2025-10-02
