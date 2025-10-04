# 🔐 Configurar Secrets para CI/CD

## Guia Completo de Configuração de Secrets no GitHub

Para que o pipeline CI/CD funcione automaticamente, você precisa configurar os seguintes secrets no GitHub.

---

## 📋 Secrets Necessários

### **1. NETLIFY_AUTH_TOKEN**

**O que é:** Token de autenticação para deploy automático no Netlify.

**Como obter:**

1. Acesse: https://app.netlify.com
2. Faça login
3. Clique no seu avatar (canto superior direito)
4. **User settings** > **Applications**
5. Seção **Personal access tokens**
6. **New access token**
7. Nome: `GitHub Actions FlertAI`
8. **Generate token**
9. ⚠️ **Copie o token imediatamente** (não será mostrado novamente)

**Exemplo:**
```
nfp_aBcD1234567890eFgH1234567890iJkL1234567890
```

---

### **2. NETLIFY_SITE_ID**

**O que é:** ID único do seu site no Netlify.

**Como obter:**

1. Acesse: https://app.netlify.com
2. Selecione seu site (ou crie um novo)
3. **Site settings** > **General**
4. Seção **Site details**
5. Copie o **API ID**

**Exemplo:**
```
12345678-abcd-4321-efgh-567890123456
```

---

### **3. SUPABASE_ACCESS_TOKEN**

**O que é:** Token de acesso à API do Supabase para deploy de Edge Functions.

**Como obter:**

1. Acesse: https://app.supabase.com
2. Faça login
3. Clique no ícone de usuário (canto superior direito)
4. **Account Settings**
5. **Access Tokens**
6. **Generate new token**
7. Nome: `GitHub Actions`
8. Escopo: `All`
9. **Generate token**
10. ⚠️ **Copie o token imediatamente**

**Exemplo:**
```
sbp_1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t
```

---

### **4. SUPABASE_PROJECT_REF**

**O que é:** Referência única do seu projeto Supabase.

**Como obter:**

1. Acesse: https://app.supabase.com
2. Selecione seu projeto
3. **Settings** > **General**
4. Seção **General settings**
5. Copie o **Reference ID**

**Exemplo:**
```
olojvpoqosrjcoxygiyf
```

**Ou extrair da URL do projeto:**
```
https://app.supabase.com/project/olojvpoqosrjcoxygiyf
                                    ^^^^^^^^^^^^^^^^^^^
                                    Este é o Project Ref
```

---

## ⚙️ Como Adicionar Secrets no GitHub

### **Passo a Passo:**

1. **Acessar Repositório:**
   ```
   https://github.com/vanzer80/flert-ai
   ```

2. **Navegar para Settings:**
   - Clique em **Settings** (aba superior)

3. **Acessar Secrets:**
   - Menu lateral: **Secrets and variables** > **Actions**

4. **Adicionar Novo Secret:**
   - Clique em **New repository secret**

5. **Preencher Dados:**
   - **Name:** Nome do secret (exatamente como listado acima)
   - **Secret:** Valor copiado
   - Clique em **Add secret**

6. **Repetir para Cada Secret:**
   - `NETLIFY_AUTH_TOKEN`
   - `NETLIFY_SITE_ID`
   - `SUPABASE_ACCESS_TOKEN`
   - `SUPABASE_PROJECT_REF`

---

## ✅ Verificar Secrets Configurados

### **Lista de Verificação:**

Após adicionar todos os secrets, você deve ver 4 secrets listados:

```
✅ NETLIFY_AUTH_TOKEN         ••••••••
✅ NETLIFY_SITE_ID            ••••••••
✅ SUPABASE_ACCESS_TOKEN      ••••••••
✅ SUPABASE_PROJECT_REF       ••••••••
```

---

## 🔄 Testar Pipeline

### **Método 1: Push para Main**

```bash
# Fazer qualquer alteração
git add .
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

### **Método 2: Re-run Workflow**

1. Acesse: **Actions** (aba superior)
2. Selecione workflow mais recente
3. Clique em **Re-run all jobs**

---

## 📊 Verificar Execução

### **Acompanhar Pipeline:**

1. **GitHub Actions:**
   - https://github.com/vanzer80/flert-ai/actions

2. **Status Esperado:**
   ```
   ✅ 🧪 Flutter Tests
   ✅ 🦕 Deno Edge Functions Tests
   ✅ 🌐 Build Web App
   ✅ 🚀 Deploy to Netlify
   ✅ 🔧 Deploy Supabase Edge Functions
   ✅ 🤖 Build Android APK
   ✅ 📢 Notify Status
   ```

3. **Netlify Deploy:**
   - Acesse: https://app.netlify.com/sites/seu-site/deploys
   - Deve aparecer um novo deploy com status **Published**

4. **Supabase Functions:**
   - Acesse: https://app.supabase.com/project/seu-projeto/functions
   - Versão atualizada de `analyze-conversation`

---

## 🚨 Troubleshooting

### **Erro: "Secret not found"**

**Causa:** Nome do secret incorreto ou não configurado.

**Solução:**
1. Verificar exatamente o nome (case-sensitive)
2. Confirmar que o secret foi adicionado
3. Re-adicionar se necessário

---

### **Erro: "Unauthorized" no Netlify**

**Causa:** Token inválido ou expirado.

**Solução:**
1. Gerar novo token no Netlify
2. Atualizar secret `NETLIFY_AUTH_TOKEN`
3. Re-run workflow

---

### **Erro: "Invalid project reference" no Supabase**

**Causa:** Project Ref incorreto.

**Solução:**
1. Verificar URL do projeto Supabase
2. Copiar exatamente o ID do projeto
3. Atualizar secret `SUPABASE_PROJECT_REF`

---

### **Pipeline falha mas não mostra erro**

**Causa:** Permissões insuficientes.

**Solução:**
1. **GitHub Token:** Verificar permissões em Settings > Actions > General
2. Habilitar: **Read and write permissions**
3. Salvar alterações

---

## 🔒 Segurança dos Secrets

### **Boas Práticas:**

✅ **FAZER:**
- Rotacionar tokens periodicamente (a cada 90 dias)
- Usar tokens com escopo mínimo necessário
- Nunca compartilhar tokens publicamente
- Verificar logs de acesso regularmente
- Revogar tokens não utilizados

❌ **NÃO FAZER:**
- Commitar secrets no código
- Compartilhar tokens via email/chat
- Usar o mesmo token para múltiplos projetos
- Deixar tokens com permissões excessivas
- Ignorar notificações de segurança

---

## 📝 Renovar Tokens

### **Quando renovar:**

- ⏰ **Periodicamente:** A cada 90 dias
- 🚨 **Imediatamente se:**
  - Token foi exposto publicamente
  - Membro da equipe saiu
  - Suspeita de comprometimento
  - Notificação de segurança recebida

### **Como renovar:**

1. **Gerar novo token** (siga passos acima)
2. **Atualizar secret** no GitHub:
   - Actions > Settings > Secrets
   - Selecione o secret
   - **Update secret**
   - Cole novo valor
   - **Update secret**
3. **Revogar token antigo** na plataforma original
4. **Testar pipeline** com novo token

---

## 🎯 Checklist Final

Antes de considerar a configuração completa:

- [ ] Todos os 4 secrets adicionados no GitHub
- [ ] Netlify conectado e funcionando
- [ ] Supabase Edge Functions deployáveis
- [ ] Pipeline executado com sucesso
- [ ] Deploy automático funcionando
- [ ] Site acessível no Netlify
- [ ] Logs não mostram erros de autenticação
- [ ] Documentação dos secrets salva em local seguro

---

## 📞 Suporte

### **Recursos Úteis:**

- **Netlify Docs:** https://docs.netlify.com/configure-builds/environment-variables/
- **Supabase Docs:** https://supabase.com/docs/guides/functions/deploy
- **GitHub Actions:** https://docs.github.com/en/actions/security-guides/encrypted-secrets

### **Problemas Comuns:**

- **Netlify:** https://answers.netlify.com
- **Supabase:** https://github.com/supabase/supabase/discussions
- **GitHub:** https://github.community

---

## ✅ Conclusão

Com os secrets configurados corretamente, seu pipeline CI/CD está **100% automatizado**:

- ✅ **Push → Tests → Build → Deploy**
- ✅ **Zero intervenção manual**
- ✅ **Deploy em < 5 minutos**
- ✅ **Rollback fácil**
- ✅ **Histórico completo**

**🚀 FlertAI pronto para desenvolvimento contínuo!**
