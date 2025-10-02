# 🔧 05 - TROUBLESHOOTING

Documentação de **resolução de problemas** encontrados durante o desenvolvimento do FlertAI.

---

## 📚 ESTRUTURA DESTA SEÇÃO

### 💻 **frontend/** - Problemas Frontend (Flutter/Dart)
Problemas específicos do aplicativo móvel/web:

| Arquivo | Descrição |
|---------|-----------|
| `diagnostico-implementacao.md` | Diagnóstico completo de implementação |

### 🖥️ **backend/** - Problemas Backend (Supabase/Edge Functions)
Problemas relacionados ao backend:

| Arquivo | Descrição |
|---------|-----------|
| `edge-functions.md` | Problemas com Edge Functions |

### 🌐 **geral/** - Problemas Gerais
Problemas que afetam múltiplas partes:

| Arquivo | Descrição |
|---------|-----------|
| `erros-comuns.md` | Lista de erros comuns e soluções |

---

## 🎯 PROBLEMAS MAIS COMUNS

### **Deploy**
- ❌ **Submódulo flutter não encontrado** → Solução: Build manual + Netlify Drop
- ❌ **Erro de ambiente Ubuntu** → Solução: Deploy manual confiável
- ❌ **Problemas de cache npm** → Solução: Desabilitar cache desnecessário

### **AI/Alucinações**
- ❌ **"Sorriso" mencionado sem existir** → Solução: Prompt engineering específico
- ❌ **Perda de contexto em "Gerar Mais"** → Solução: Sistema previous_suggestions
- ❌ **Repetição de sugestões** → Solução: Instruções anti-repetição

### **Integrações**
- ❌ **Problemas de região sem auth** → Solução: Correção lógica de localização
- ❌ **Erro de stats na análise** → Solução: Tratamento adequado de dados

---

## 🔗 NAVEGAÇÃO

- **⬅️ Anterior:** [04-deploy/](../04-deploy/) - Deploy e produção
- **➡️ Próximo:** [06-auditoria/](../06-auditoria/) - Verificações e auditorias

---

**📅 Seção criada em:** 2025-10-02
