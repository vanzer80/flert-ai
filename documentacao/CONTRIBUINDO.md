# 🤝 Como Contribuir com a Documentação

**Guia para manter a documentação atualizada e útil**

---

## 🎯 **Princípios da Documentação**

1. **📝 Clareza:** Escreva de forma clara e objetiva
2. **🔄 Atualização:** Mantenha sempre atualizado
3. **📋 Completude:** Não deixe informações pela metade
4. **🔗 Conectividade:** Faça referências cruzadas
5. **✅ Testabilidade:** Comandos devem funcionar

---

## 📁 **Estrutura de Pastas**

```
documentacao/
├── README.md                    # Índice principal
├── INDICE_COMPLETO.md           # Índice detalhado
├── CONTRIBUINDO.md              # Este arquivo
│
├── guias/                       # Guias práticos
│   ├── inicio-rapido/          # Setup rápido
│   ├── setup/                  # Configurações
│   └── integracao/             # Integrações
│
├── auditoria/                   # Auditorias técnicas
├── troubleshooting/             # Resolução de problemas
└── desenvolvimento/             # Docs de desenvolvimento
```

---

## 📝 **Como Adicionar Nova Documentação**

### **Passo 1: Escolher Categoria**

**Pergunte-se:**
- 🚀 É um guia de como fazer algo? → `guias/`
- 📊 É uma auditoria ou status? → `auditoria/`
- 🔧 É resolução de problema? → `troubleshooting/`
- 🛠️ É sobre desenvolvimento? → `desenvolvimento/`

### **Passo 2: Criar o Arquivo**

**Nome do arquivo:**
- Use UPPERCASE para índices: `README.md`, `SETUP.md`
- Use kebab-case para específicos: `guia-feature-x.md`
- Use prefixo descritivo: `CORRECAO_ERRO_X.md`

**Template básico:**
```markdown
# Título do Documento

**Data:** YYYY-MM-DD
**Autor:** Seu Nome
**Status:** [Em Desenvolvimento | Completo | Deprecated]

---

## 🎯 **Objetivo**

Descreva claramente o que este documento faz.

---

## 📋 **Pré-requisitos**

- Requisito 1
- Requisito 2

---

## 🚀 **Passo a Passo**

### **Passo 1: Título**
Descrição detalhada...

**Comando:**
```bash
comando aqui
```

**Resultado esperado:**
```
output aqui
```

### **Passo 2: Próximo Passo**
...

---

## 🔧 **Troubleshooting**

### **Problema 1:**
- **Causa:** ...
- **Solução:** ...

---

## 📚 **Referências**

- [Link para doc relacionada](caminho/doc.md)
- URL externa: https://exemplo.com

---

**Atualizado em:** YYYY-MM-DD
```

### **Passo 3: Atualizar Índices**

1. **Adicione ao [`README.md`](README.md):**
   - Adicione link na seção apropriada
   - Mantenha organização por categoria

2. **Adicione ao [`INDICE_COMPLETO.md`](INDICE_COMPLETO.md):**
   - Adicione entrada completa com descrição
   - Atualize estatísticas

3. **Atualize referências cruzadas:**
   - Se outros docs mencionam esse tópico
   - Adicione links bidirecionais

---

## 🔄 **Como Atualizar Documentação Existente**

### **Quando Atualizar:**
- ✅ Após implementar feature
- ✅ Quando comandos mudarem
- ✅ Quando URLs mudarem
- ✅ Após resolver problemas novos
- ✅ Quando feedback indicar confusão

### **Como Atualizar:**

1. **Abra o documento**
2. **Atualize a data** no topo
3. **Faça as alterações** necessárias
4. **Teste os comandos** se aplicável
5. **Atualize links** se necessário
6. **Adicione nota de atualização** no final:

```markdown
---

## 📝 **Histórico de Atualizações**

### **v1.1.0 (2025-10-01)**
- ✅ Atualizado comando X
- ✅ Adicionado troubleshooting Y
```

---

## 📋 **Checklist de Qualidade**

Antes de finalizar um documento, verifique:

### **Conteúdo:**
- [ ] Objetivo claro no início
- [ ] Pré-requisitos listados
- [ ] Passo a passo detalhado
- [ ] Comandos testados e funcionando
- [ ] Resultados esperados descritos
- [ ] Seção de troubleshooting
- [ ] Links para docs relacionadas

### **Formatação:**
- [ ] Título principal em H1 (`#`)
- [ ] Seções principais em H2 (`##`)
- [ ] Subseções em H3 (`###`)
- [ ] Comandos em blocos de código
- [ ] URLs separadas de comandos
- [ ] Emojis para visual (opcional mas recomendado)

### **Links e Referências:**
- [ ] Todos os links funcionam
- [ ] Caminhos relativos corretos
- [ ] URLs externas acessíveis
- [ ] Referências cruzadas atualizadas

### **Testabilidade:**
- [ ] Comandos executados e testados
- [ ] Outputs validados
- [ ] Erros comuns documentados
- [ ] Alternativas apresentadas

---

## 🎨 **Padrões de Formatação**

### **Emojis Recomendados:**
- 🎯 Objetivo/Meta
- 📋 Lista/Checklist
- 🚀 Início/Execução
- ✅ Sucesso/Completo
- ⚠️ Atenção/Importante
- 🔧 Troubleshooting
- 📊 Dados/Estatísticas
- 🔗 Links/URLs
- 📁 Arquivos/Pastas
- 💡 Dica/Sugestão
- ⏱️ Tempo
- 📞 Contato/Suporte
- 🇧🇷 Brasil/Brasileiro

### **Blocos de Código:**

**Comandos Shell:**
```bash
comando shell
```

**SQL:**
```sql
SELECT * FROM tabela;
```

**TypeScript:**
```typescript
const variavel = 'valor'
```

**Python:**
```python
print("Hello")
```

### **Callouts:**

**Importante:**
```markdown
> ⚠️ **IMPORTANTE:** Mensagem importante aqui
```

**Nota:**
```markdown
> 💡 **NOTA:** Informação adicional aqui
```

**Dica:**
```markdown
> 💡 **DICA:** Sugestão útil aqui
```

---

## 🔍 **Review de Documentação**

### **Auto-Review (Antes de Commitar):**
1. Leia documento do início ao fim
2. Execute todos os comandos
3. Verifique todos os links
4. Confirme formatação consistente
5. Revise ortografia

### **Peer Review:**
1. Peça para outro dev ler
2. Solicite feedback de clareza
3. Teste com alguém novo no projeto
4. Implemente melhorias sugeridas

### **Review Periódico (Trimestral):**
- [ ] Verificar links quebrados
- [ ] Atualizar versões de software
- [ ] Remover conteúdo deprecated
- [ ] Consolidar docs similares
- [ ] Melhorar organização
- [ ] Atualizar screenshots (se houver)

---

## 📝 **Tipos de Documentação**

### **1. Guias (How-To):**
- Foco em **como fazer**
- Passo a passo claro
- Comandos executáveis
- Exemplo: `GUIA_INTEGRACAO_IA.md`

### **2. Referência (Reference):**
- Foco em **o que é**
- Informação estruturada
- Detalhes técnicos
- Exemplo: `AUDITORIA_COMPLETA.md`

### **3. Explicação (Explanation):**
- Foco em **por que**
- Contexto e decisões
- Arquitetura
- Exemplo: `INTEGRACAO_CULTURAL_REFERENCES.md`

### **4. Troubleshooting:**
- Foco em **resolver problemas**
- Problema → Causa → Solução
- Exemplos reais
- Exemplo: `CORRECAO_ERRO_STATS.md`

---

## 🚀 **Boas Práticas**

### **✅ Faça:**
- Escreva para quem não sabe nada
- Use exemplos reais do projeto
- Mantenha linguagem consistente
- Teste todos os comandos
- Inclua outputs esperados
- Adicione troubleshooting
- Faça links bidirecionais
- Atualize data de modificação

### **❌ Não Faça:**
- Assumir conhecimento prévio
- Usar jargões sem explicar
- Deixar comandos não testados
- Criar docs sem contexto
- Ignorar erros comuns
- Deixar links quebrados
- Esquecer de atualizar índices
- Usar informações desatualizadas

---

## 📞 **Contato e Suporte**

- **Documentação:** Esta pasta
- **Dúvidas sobre docs:** Abra issue ou contate o time
- **Sugestões:** Sempre bem-vindas!

---

## 🏷️ **Versionamento**

### **Formato de Versão:** MAJOR.MINOR.PATCH

**Quando incrementar:**
- **MAJOR:** Mudanças estruturais grandes
- **MINOR:** Adição de novo documento
- **PATCH:** Correções e atualizações

**Exemplo:**
- v1.0.0 → Criação inicial
- v1.1.0 → Adicionado novo guia
- v1.1.1 → Corrigido link quebrado

---

**📚 Obrigado por contribuir com a documentação do FlertAI!**

**Documentação de qualidade = Projeto de qualidade** ✨

**🇧🇷 Desenvolvido com ❤️ para criar conexões autenticamente brasileiras**
