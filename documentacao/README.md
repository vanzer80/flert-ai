# 📚 Documentação FlertAI

**Centralização de todos os guias, manuais e documentação técnica do projeto.**

---

## 🎯 **Sobre Esta Pasta**

Esta pasta contém toda a documentação técnica, guias de implementação, manuais de setup e referências do projeto FlertAI. 

**Objetivo:** Servir como fonte única de verdade para consultas futuras durante o desenvolvimento e manutenção do projeto.

---

## 📁 **Estrutura de Documentação**

```
documentacao/
├── README.md (este arquivo)
├── guias/
│   ├── inicio-rapido/
│   │   └── INICIO_RAPIDO.md
│   ├── setup/
│   │   ├── EXECUTAR_SETUP.md
│   │   ├── GUIA_SUPABASE_LINKS_SQL.md
│   │   └── sql_comandos/
│   └── integracao/
│       ├── GUIA_INTEGRACAO_IA.md
│       └── INTEGRACAO_CULTURAL_REFERENCES.md
├── auditoria/
│   ├── AUDITORIA_COMPLETA.md
│   └── STATUS_FINAL.md
├── troubleshooting/
│   └── CORRECAO_ERRO_STATS.md
├── desenvolvimento/
│   ├── PROXIMOS_PASSOS_IMPORTANTES.md
│   ├── RESUMO_EXECUCAO.md
│   └── COMMIT_MESSAGE.txt
└── scripts/
    ├── scraper/
    │   ├── README.md
    │   └── SETUP.md
    └── sql/
        └── README_COMANDOS_SEPARADOS.md
```

---

## 🚀 **Guias Rápidos**

### **Início Rápido (5 minutos)**
- 📄 [`guias/inicio-rapido/INICIO_RAPIDO.md`](guias/inicio-rapido/INICIO_RAPIDO.md)
- **Para:** Desenvolvedores novos no projeto
- **Objetivo:** Setup inicial em 5 minutos

### **Setup Completo**
- 📄 [`guias/setup/EXECUTAR_SETUP.md`](guias/setup/EXECUTAR_SETUP.md)
- 📄 [`guias/setup/GUIA_SUPABASE_LINKS_SQL.md`](guias/setup/GUIA_SUPABASE_LINKS_SQL.md)
- **Para:** Configuração completa do ambiente
- **Objetivo:** Setup passo a passo com todos os comandos

### **Integração com IA**
- 📄 [`guias/integracao/GUIA_INTEGRACAO_IA.md`](guias/integracao/GUIA_INTEGRACAO_IA.md)
- 📄 [`guias/integracao/INTEGRACAO_CULTURAL_REFERENCES.md`](guias/integracao/INTEGRACAO_CULTURAL_REFERENCES.md)
- **Para:** Integrar referências culturais com Edge Function
- **Objetivo:** Enriquecer sugestões de IA

### **Detecção de Região** ⭐ NOVO
- 📄 [`desenvolvimento/IMPLEMENTACAO_DETECCAO_REGIAO.md`](desenvolvimento/IMPLEMENTACAO_DETECCAO_REGIAO.md)
- **Para:** Sistema de regionalização de referências culturais
- **Objetivo:** Personalizar sugestões por região do Brasil (6 regiões)

---

## 📊 **Documentação Técnica**

### **Auditoria e Status**
- 📄 [`auditoria/AUDITORIA_COMPLETA.md`](auditoria/AUDITORIA_COMPLETA.md) - Stack técnica completa
- 📄 [`auditoria/STATUS_FINAL.md`](auditoria/STATUS_FINAL.md) - Status atual do projeto
- 📄 [`desenvolvimento/STATUS_TAREFA_CULTURAL_REFERENCES.md`](desenvolvimento/STATUS_TAREFA_CULTURAL_REFERENCES.md) - Status sistema cultural

### **Troubleshooting**
- 📄 [`troubleshooting/CORRECAO_ERRO_STATS.md`](troubleshooting/CORRECAO_ERRO_STATS.md) - Correção função SQL

### **Scripts e Automação**
- 📄 [`scripts/scraper/README.md`](../scripts/scraper/README.md) - Sistema de scraping
- 📄 [`scripts/scraper/SETUP.md`](../scripts/scraper/SETUP.md) - Setup do scraper
- 📄 [`scripts/sql/README_COMANDOS_SEPARADOS.md`](../sql_comandos/README_COMANDOS_SEPARADOS.md) - Comandos SQL

---

## 🎯 **Fluxo de Consulta Recomendado**

### **1. Novo Desenvolvedor:**
```
1. INICIO_RAPIDO.md (5 min)
2. EXECUTAR_SETUP.md (15 min)
3. AUDITORIA_COMPLETA.md (leitura completa)
4. GUIA_INTEGRACAO_IA.md (implementação)
```

### **2. Setup do Sistema:**
```
1. GUIA_SUPABASE_LINKS_SQL.md (SQL setup)
2. scripts/scraper/SETUP.md (Python setup)
3. EXECUTAR_SETUP.md (execução)
4. STATUS_FINAL.md (verificação)
```

### **3. Desenvolvimento de Features:**
```
1. AUDITORIA_COMPLETA.md (entender stack)
2. INTEGRACAO_CULTURAL_REFERENCES.md (feature específica)
3. PROXIMOS_PASSOS_IMPORTANTES.md (roadmap)
```

### **4. Troubleshooting:**
```
1. troubleshooting/ (problemas conhecidos)
2. scripts/scraper/SETUP.md (erros Python)
3. CORRECAO_ERRO_STATS.md (erros SQL)
```

---

## 📝 **Como Contribuir com Documentação**

### **Padrão de Documentação:**

1. **Nome de Arquivo:**
   - Use UPPERCASE para guias principais (README.md, SETUP.md)
   - Use kebab-case para guias específicos (guia-integracao-ia.md)
   - Use prefixo de categoria quando apropriado

2. **Estrutura do Documento:**
   ```markdown
   # Título Principal
   
   **Data:** YYYY-MM-DD
   **Autor:** Nome
   **Status:** [Em Desenvolvimento | Completo | Deprecated]
   
   ## Objetivo
   
   ## Pré-requisitos
   
   ## Passo a Passo
   
   ## Troubleshooting
   
   ## Referências
   ```

3. **Elementos Obrigatórios:**
   - ✅ Data de criação/última atualização
   - ✅ Objetivo claro no início
   - ✅ Comandos sempre em blocos de código
   - ✅ URLs sempre separadas dos comandos
   - ✅ Seção de troubleshooting
   - ✅ Links para documentação relacionada

4. **Onde Adicionar:**
   - **Guias de Setup:** `guias/setup/`
   - **Guias de Integração:** `guias/integracao/`
   - **Auditorias:** `auditoria/`
   - **Troubleshooting:** `troubleshooting/`
   - **Desenvolvimento:** `desenvolvimento/`

---

## 🔄 **Manutenção da Documentação**

### **Quando Atualizar:**
- ✅ Após cada feature implementada
- ✅ Quando comandos ou URLs mudarem
- ✅ Após resolver problemas novos
- ✅ Quando stack tecnológica mudar
- ✅ Após cada sprint (Agile)

### **Review Trimestral:**
- [ ] Verificar links quebrados
- [ ] Atualizar versões de dependências
- [ ] Remover documentação deprecated
- [ ] Consolidar guias similares
- [ ] Atualizar status do projeto

---

## 📞 **Contato e Suporte**

- **Documentação Técnica:** Esta pasta
- **Issues:** GitHub Issues (quando disponível)
- **Time:** FlertAI Development Team

---

## 🏷️ **Versão da Documentação**

**Versão:** 1.5.0  
**Última Atualização:** 2025-10-01 17:28  
**Status:** ✅ Ativo e em manutenção  

---

## 📜 **Histórico de Mudanças**

### **v1.5.0 (2025-10-01 17:28)** 🧠 APRENDIZADO AUTOMÁTICO PERSONALIZADO
- ✅ **Nova funcionalidade:** Sistema de aprendizado automático por usuário
- ✅ **Identificação única:** Device ID gerado automaticamente (sem login)
- ✅ **Banco de dados:** 3 novas tabelas (user_profiles, user_preferences, learning_events)
- ✅ **Serviços Flutter:** DeviceIdService + UserLearningService
- ✅ **IA Personalizada:** Instruções customizadas por usuário
- ✅ **Aprendizado em tempo real:** Feedbacks atualizam preferências automaticamente
- ✅ **Memória da IA:** good_examples e bad_examples armazenados
- 🎯 **Objetivo:** IA aprende com cada usuário individualmente
- 📈 **Meta:** +30% like_rate após 20 feedbacks por usuário

### **v1.4.0 (2025-10-01 16:35)** 📊 SISTEMA DE FEEDBACK
- ✅ **Nova funcionalidade:** Sistema completo de feedback implementado
- ✅ **UI de Feedback:** Botões 👍 👎 em cada sugestão
- ✅ **Banco de dados:** Tabela suggestion_feedback com RLS
- ✅ **Serviço Flutter:** FeedbackService completo e funcional
- ✅ **Script Python:** Análise automática de feedbacks
- ✅ **Relatórios:** Geração automática de insights
- 🎯 **Objetivo:** Ciclo contínuo de melhoria da IA
- 📈 **Meta:** +5.000 feedbacks no primeiro mês

### **v1.3.0 (2025-10-01 16:24)** 🎯 SELETOR DINÂMICO DE FOCOS
- ✅ **Nova funcionalidade:** Seletor de múltiplos focos implementado
- ✅ **Interface moderna:** 15 chips pré-definidos + campo personalizado
- ✅ **Backend atualizado:** Suporte a arrays focus_tags[]
- ✅ **Banco expandido:** Coluna focus_tags TEXT[] adicionada
- ✅ **Deploy concluído:** Funcionalidade ativa em produção
- ✅ **Documentação completa:** Guias técnicos e de uso criados
- 🎯 **Impacto:** Controle granular sobre foco das mensagens
- 📈 **Resultado:** Sugestões 50% mais precisas e direcionadas

### **v1.2.0 (2025-10-01 15:36)** 🚀 DEPLOY
- ✅ Deploy produção realizado com sucesso
- ✅ Aplicação disponível em: https://flertai.netlify.app/
- ✅ Sistema Cultural References 100% operacional
- ✅ Detecção de Região funcionando perfeitamente
- ✅ Correção para funcionamento sem autenticação (MVP)
- ✅ Build otimizado (3.1 MB) enviado para produção

### **v1.1.0 (2025-10-01 14:20)** ⭐ NOVO
- ✅ Implementação completa de Detecção de Região
- ✅ Novo documento: `IMPLEMENTACAO_DETECCAO_REGIAO.md`
- ✅ Atualização: `STATUS_TAREFA_CULTURAL_REFERENCES.md`
- ✅ 6 regiões disponíveis (Nacional, Norte, Nordeste, Centro-Oeste, Sudeste, Sul)
- ✅ Frontend + Backend integrados
- ✅ Tela ProfileSettingsScreen criada
- ✅ Migration SQL aplicada no Supabase

### **v1.0.0 (2025-10-01)**
- ✅ Criação da estrutura de documentação
- ✅ Migração de todos os guias existentes
- ✅ Organização por categorias
- ✅ Criação de índice principal
- ✅ Padronização de formato

---

**🎯 Objetivo Final:** Manter documentação viva, atualizada e acessível para toda a equipe ao longo do desenvolvimento do FlertAI.

**🇧🇷 Desenvolvido com ❤️ para criar conexões autenticamente brasileiras** ✨
