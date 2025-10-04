# 🚀 Deploy FlertAI no Netlify

## Guia Completo de Deploy via Drag & Drop

### 📋 Pré-requisitos

- ✅ Conta no Netlify (gratuita): https://app.netlify.com/signup
- ✅ Build da aplicação pronto em `build/web/`
- ✅ Navegador (Chrome, Edge ou Firefox)

---

## 🎯 Método 1: Deploy via Drag & Drop (Recomendado)

### **Passo a Passo:**

#### 1. **Acessar Netlify Drop**
```
🌐 URL: https://app.netlify.com/drop
```

#### 2. **Preparar a Pasta**
- Navegue até: `c:\Users\vanze\FlertAI\flerta_ai\build\web`
- **Importante:** Arraste apenas o **CONTEÚDO** da pasta `web`, não a pasta em si

#### 3. **Arrastar e Soltar**
- Selecione **TODOS os arquivos e pastas** dentro de `build/web/`:
  - `index.html`
  - `main.dart.js`
  - `flutter.js`
  - `assets/`
  - `canvaskit/`
  - `icons/`
  - etc.
- Arraste para a área "Drop your site folder here"

#### 4. **Aguardar Deploy**
- Upload: ~10-20 segundos (31.6 MB)
- Processing: ~10-30 segundos
- Deploy: Automático

#### 5. **Site Publicado! 🎉**
```
✅ URL Temporária: https://random-name-12345.netlify.app
```

---

## ⚙️ Método 2: Deploy via Netlify CLI

### **Instalação:**

```bash
# Instalar Netlify CLI
npm install -g netlify-cli

# Login
netlify login
```

### **Deploy:**

```bash
# Navegar para o projeto
cd c:\Users\vanze\FlertAI\flerta_ai

# Deploy de produção
netlify deploy --prod --dir=build/web

# Seguir instruções no terminal
```

---

## 🔧 Configurações Avançadas

### **1. Domínio Customizado**

Após deploy, no painel Netlify:
1. **Domain Settings** > **Add custom domain**
2. Digite seu domínio: `flertai.com`
3. Configure DNS conforme instruções
4. HTTPS automático via Let's Encrypt

### **2. Variáveis de Ambiente**

**⚠️ IMPORTANTE:** Remover chaves hardcoded antes de produção!

No painel Netlify:
1. **Site settings** > **Build & deploy** > **Environment**
2. Adicionar variáveis:
   ```
   SUPABASE_URL = https://seu-projeto.supabase.co
   SUPABASE_ANON_KEY = sua-chave-anonima
   ```

### **3. Redirects e Rewrites**

O arquivo `_redirects` já está incluído no build:
```
/*    /index.html   200
```

Isso garante que rotas SPA funcionem corretamente.

### **4. Headers de Segurança**

Criar `netlify.toml` na raiz do projeto:

```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://*.supabase.co"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

---

## 🎨 Customização do Site

### **Alterar Nome do Site:**

1. **Site settings** > **Site details** > **Change site name**
2. Novo nome: `flertai-app` (ou outro disponível)
3. Nova URL: `https://flertai-app.netlify.app`

### **Configurar Preview Deploys:**

- ✅ Deploy automático de branches
- ✅ Preview de Pull Requests
- ✅ Rollback fácil para versões anteriores

---

## 📊 Monitoramento

### **Analytics (Gratuito):**

1. **Analytics** > **Enable analytics**
2. Visualizar:
   - Visitantes únicos
   - Pageviews
   - Top pages
   - Fontes de tráfego

### **Logs:**

- **Deploys** > Selecionar deploy > **Deploy log**
- Verificar erros de build ou runtime

---

## 🚨 Troubleshooting

### **Problema: Site não carrega**

**Solução:**
1. Verificar console do navegador (F12)
2. Conferir que todos os arquivos foram enviados
3. Verificar redirects (`_redirects` presente)

### **Problema: Erro 404 em rotas**

**Solução:**
- Confirmar arquivo `_redirects` na raiz
- Conteúdo: `/*    /index.html   200`

### **Problema: CORS errors**

**Solução:**
1. Configurar Supabase para aceitar domínio Netlify
2. Adicionar URL do site em: Supabase Dashboard > Project Settings > API

---

## ✅ Checklist Pós-Deploy

- [ ] Site carregando corretamente
- [ ] Todas as rotas funcionando
- [ ] Upload de imagem funciona
- [ ] Análise de conversas funciona
- [ ] Nenhum erro no console
- [ ] Performance aceitável (Lighthouse > 80)
- [ ] Domínio customizado configurado (opcional)
- [ ] HTTPS ativo
- [ ] Analytics ativo
- [ ] Backup do site configurado

---

## 🎯 Deploy Contínuo (CI/CD)

Para deploys automáticos a cada push:

1. **Conectar repositório GitHub:**
   - Site settings > Build & deploy > Link repository
   - Autorizar Netlify no GitHub
   - Selecionar repositório: `vanzer80/flert-ai`

2. **Configurar Build:**
   ```
   Base directory: (deixar vazio)
   Build command: flutter build web --release
   Publish directory: build/web
   ```

3. **Branch de produção:**
   - Production branch: `main`
   - Deploy previews: `All branches`

---

## 📈 Performance

### **Métricas Esperadas:**

| Métrica | Valor Esperado |
|---------|----------------|
| **First Contentful Paint** | < 2s |
| **Time to Interactive** | < 5s |
| **Largest Contentful Paint** | < 4s |
| **Cumulative Layout Shift** | < 0.1 |
| **Total Blocking Time** | < 300ms |

### **Otimizações Ativas:**

- ✅ Compressão Gzip/Brotli automática
- ✅ CDN global (edge caching)
- ✅ HTTP/2 + HTTP/3
- ✅ Image optimization
- ✅ Asset fingerprinting

---

## 💰 Custos

### **Plano Gratuito (Starter):**
- ✅ 100 GB bandwidth/mês
- ✅ 300 build minutes/mês
- ✅ Sites ilimitados
- ✅ Deploy contínuo
- ✅ HTTPS automático
- ✅ Edge CDN global

### **Estimativa para FlertAI:**
- Site: 31.6 MB
- Visitantes estimados: 1000/mês
- Banda necessária: ~32 GB/mês
- **✅ Dentro do plano gratuito**

---

## 🔗 Links Úteis

- **Netlify Dashboard:** https://app.netlify.com
- **Documentação:** https://docs.netlify.com
- **Status:** https://www.netlifystatus.com
- **Suporte:** https://answers.netlify.com

---

## 🎉 Conclusão

**Deploy no Netlify é:**
- ✅ Gratuito
- ✅ Rápido (< 1 minuto)
- ✅ Confiável (99.9% uptime)
- ✅ Escalável
- ✅ Fácil de usar

**🚀 Seu FlertAI está pronto para o mundo!**
