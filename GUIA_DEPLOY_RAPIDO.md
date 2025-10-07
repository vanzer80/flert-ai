# 🚀 GUIA DE DEPLOY RÁPIDO - FlertaAI

**Data:** 2025-10-06 16:23  
**Tempo estimado:** 15 minutos  
**Pré-requisitos:** Fase 7 concluída ✅

---

## 📱 DEPLOY FLUTTER APP (Mobile)

### **Opção 1: Build APK de Produção (Recomendado)**

```bash
# Limpar builds anteriores
flutter clean

# Instalar dependências
flutter pub get

# Build de produção
flutter build apk --release

# APK gerado em:
# build/app/outputs/flutter-apk/app-release.apk
```

**Tempo:** ~5 minutos

### **Distribuição:**
- **Testes internos:** Enviar APK diretamente
- **Google Play:** Upload via Google Play Console
- **Firebase App Distribution:** `firebase appdistribution:distribute`

---

## 💻 DEPLOY WEB APP (HTML/JS)

### **Opção 1: Netlify Drop (Mais Rápido)**

**Passos:**
1. Acessar: https://app.netlify.com/drop
2. Arrastar pasta: `web_app`
3. Aguardar upload (~30 segundos)
4. Copiar link público gerado

**Exemplo de link:**
```
https://flertai-app-abc123.netlify.app
```

**Tempo:** ~2 minutos

### **Opção 2: Netlify CLI**

```bash
# Instalar CLI (se necessário)
npm install -g netlify-cli

# Login
netlify login

# Deploy
cd web_app
netlify deploy --prod

# Seguir instruções no terminal
```

**Tempo:** ~3 minutos

### **Opção 3: Vercel**

```bash
# Instalar CLI (se necessário)
npm install -g vercel

# Deploy
cd web_app
vercel --prod
```

**Tempo:** ~3 minutos

---

## ⚡ VALIDAÇÃO PÓS-DEPLOY

### **Teste Rápido Web App:**

```bash
# Abrir link do deploy no navegador
# Testar:
# 1. Upload de imagem ✅
# 2. Seleção de tom ✅
# 3. Análise funciona ✅
# 4. Sugestão é gerada ✅
```

### **Teste Rápido Flutter App:**

```bash
# Instalar APK no dispositivo
adb install build/app/outputs/flutter-apk/app-release.apk

# Testar:
# 1. Tela inicial carrega ✅
# 2. Análise de conversa funciona ✅
# 3. Geração de sugestões funciona ✅
```

### **Teste Backend:**

```bash
# Executar script de validação
powershell -ExecutionPolicy Bypass -File teste_integracao_final.ps1

# Deve mostrar:
# Flutter App: PASSOU ✅
# Web App: PASSOU ✅
```

---

## 📊 MONITORAMENTO

### **Ver Logs em Tempo Real:**

```bash
# Logs da função unificada
supabase functions logs analyze-unified --follow

# Filtrar apenas erros
supabase functions logs analyze-unified --filter error

# Ver últimas 100 linhas
supabase functions logs analyze-unified --tail 100
```

### **Dashboard Supabase:**
1. Acessar: https://supabase.com/dashboard
2. Selecionar projeto: `olojvpoqosrjcoxygiyf`
3. Edge Functions → `analyze-unified`
4. Ver métricas, invocações, erros

---

## 🔧 TROUBLESHOOTING

### **Web App não carrega:**
```bash
# Verificar se arquivo correto foi deployado
# Deve ser: index_final.html
# Verificar console do navegador (F12)
```

### **Flutter App crasha:**
```bash
# Ver logs do dispositivo
adb logcat | grep -i flutter

# Rebuild com debug
flutter build apk --debug
flutter install
```

### **Backend retorna erro 500:**
```bash
# Verificar secrets configuradas
# Supabase Dashboard → Settings → Edge Functions → Secrets
# Deve ter:
# - OPENAI_API_KEY ✅
# - SERVICE_ROLE_KEY_supabase ✅

# Ver logs
supabase functions logs analyze-unified --filter error
```

---

## 📝 CHECKLIST DE DEPLOY

### **Pré-Deploy:**
- [x] Fase 7 concluída ✅
- [x] Testes locais passando ✅
- [x] Secrets configuradas ✅
- [x] Documentação atualizada ✅

### **Web App:**
- [ ] Build testado localmente
- [ ] Deployado no Netlify/Vercel
- [ ] Link público funcionando
- [ ] Teste de upload OK
- [ ] Teste de análise OK

### **Flutter App:**
- [ ] APK de release gerado
- [ ] Instalado em dispositivo teste
- [ ] Análise de conversa OK
- [ ] Geração de sugestões OK
- [ ] Performance aceitável

### **Backend:**
- [x] Função unificada deployada ✅
- [x] Testes de integração OK ✅
- [ ] Monitoramento configurado
- [ ] Logs sendo verificados

---

## 🎯 PRÓXIMOS 7 DIAS

### **Dia 1 (Hoje):**
- [ ] Deploy Web App
- [ ] Build Flutter APK
- [ ] Teste inicial com 2-3 usuários

### **Dia 2-3:**
- [ ] Coletar feedback inicial
- [ ] Monitorar logs e erros
- [ ] Ajustes rápidos se necessário

### **Dia 4-5:**
- [ ] Expandir testes (5-10 usuários)
- [ ] Analisar métricas de uso
- [ ] Validar performance

### **Dia 6-7:**
- [ ] Revisão completa
- [ ] Decisão sobre limpeza de código legacy
- [ ] Planejamento Fase 8

---

## 💡 DICAS IMPORTANTES

### **Web App:**
1. ✅ Sempre deployar pasta `web_app` completa
2. ✅ Verificar que `index_final.html` é o arquivo principal
3. ✅ Testar em múltiplos navegadores (Chrome, Firefox, Safari)
4. ✅ Testar em mobile (responsividade)

### **Flutter App:**
1. ✅ Sempre fazer `flutter clean` antes de build de produção
2. ✅ Testar em dispositivo real (não só emulador)
3. ✅ Verificar permissões (câmera, storage)
4. ✅ Testar com dados móveis (não só WiFi)

### **Backend:**
1. ✅ Monitorar custos da OpenAI API
2. ✅ Verificar rate limits
3. ✅ Manter funções antigas ativas por 1 semana
4. ✅ Backup de logs antes de limpar

---

## 📞 COMANDOS RÁPIDOS

### **Deploy Web (Netlify Drop):**
```
1. Abrir: https://app.netlify.com/drop
2. Arrastar: web_app
3. Pronto!
```

### **Build Flutter APK:**
```bash
flutter clean && flutter pub get && flutter build apk --release
```

### **Teste Integração:**
```bash
powershell -ExecutionPolicy Bypass -File teste_integracao_final.ps1
```

### **Ver Logs:**
```bash
supabase functions logs analyze-unified --follow
```

---

## 🎊 CONCLUSÃO

Você tem tudo pronto para deploy! Basta seguir este guia e em **15 minutos** seu sistema híbrido estará em produção.

**Boa sorte! 🚀**

---

**Criado:** 2025-10-06 16:23  
**Atualizado:** 2025-10-06 16:23  
**Versão:** 1.0
