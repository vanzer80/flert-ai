# 📋 ÍNDICE - GUIAS DE DEPLOY

## 📚 Documentação Centralizada de Deploy

Esta pasta contém toda a documentação relacionada ao deploy do FlertAI para facilitar consultas futuras.

---

## 📁 Arquivos Disponíveis

### **📖 Guias Principais**

| Arquivo | Descrição | Última Atualização |
|---------|-----------|-------------------|
| `GUIA_DEPLOY_FLERTAI.md` | Guia geral e histórico de deploy | 2025-10-01 |
| `DEPLOY_MANUAL_NETLIFY.md` | **Guia completo de deploy manual (recomendado)** | 2025-10-02 |
| `ANALISE_ERROS_DEPLOY_GITHUB_ACTIONS.md` | Análise profunda dos erros no GitHub Actions | 2025-10-02 |

### **🔧 Scripts e Ferramentas**

- `deploy.bat` - Script automatizado para Windows (na raiz do projeto)

---

## 🎯 Método Recomendado Atualmente

**DEPLOY MANUAL** (100% confiável)

1. **Build local:** `flutter build web --release --no-tree-shake-icons`
2. **Deploy:** Arraste `build/web` para https://app.netlify.com/drop
3. **Tempo total:** 2 minutos

**Detalhes completos em:** `DEPLOY_MANUAL_NETLIFY.md`

---

## 📋 Estrutura da Pasta

```
documentacao/guias/deploy/
├── GUIA_DEPLOY_FLERTAI.md          # Guia histórico
├── DEPLOY_MANUAL_NETLIFY.md        # Guia atual (recomendado)
├── ANALISE_ERROS_DEPLOY_GITHUB_ACTIONS.md  # Análise técnica
└── README.md                       # Este arquivo (índice)
```

---

## 🔗 Links Relacionados

- **Projeto principal:** `../README.md` (raiz do projeto)
- **Troubleshooting geral:** `../troubleshooting/`
- **Desenvolvimento:** `../desenvolvimento/`

---

**📅 Última organização:** 2025-10-02  
**🎯 Objetivo:** Centralizar toda documentação de deploy para facilitar manutenção e consultas futuras.
