# 🔗 GUIA INTEGRAÇÃO IA - Passo a Passo com Links e Comandos

**Data:** 2025-10-01 08:23
**Status:** Sistema Cultural References ✅ | Integração IA ⏳

---

## 🎯 **PASSO A PASSO - INTEGRAÇÃO COM EDGE FUNCTION**

### **📍 PASSO 1: Localizar Edge Function**

**🔗 URL Edge Functions:**
```
https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/functions
```

**📋 Ação:**
1. Clique em **"Edge Functions"** no menu lateral esquerdo
2. Procure por: `analyze-conversation` (ou crie nova)

---

### **📍 PASSO 2: Editar Edge Function**

**🔗 URL Editor de Functions:**
```
https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/functions/analyze-conversation
```

**📋 Código TypeScript para Adicionar:**

**COMANDO 1/5 - Imports (adicione no topo):**
```typescript
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Cliente admin para acessar cultural_references
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)
```

**COMANDO 2/5 - Função Buscar Referências:**
```typescript
/**
 * Busca referências culturais relevantes para o contexto
 */
async function getCulturalReferences(
  tone: string,
  region: string = 'nacional',
  count: number = 3
): Promise<any[]> {
  try {
    const references = []

    // Determinar tipos relevantes baseado no tom
    const types = getCulturalTypesForTone(tone)

    // Buscar referências de cada tipo
    for (const type of types) {
      const { data, error } = await supabaseAdmin
        .rpc('get_random_cultural_reference', {
          reference_type: type,
          reference_region: region
        })

      if (data && data.length > 0) {
        references.push(data[0])
      }
    }

    return references.slice(0, count)
  } catch (error) {
    console.error('Error fetching cultural references:', error)
    return []
  }
}

/**
 * Mapeia tom para tipos de referências culturais apropriadas
 */
function getCulturalTypesForTone(tone: string): string[] {
  const toneNormalized = tone.toLowerCase()

  const toneTypeMap: Record<string, string[]> = {
    'flertar': ['giria', 'musica', 'expressao_regional'],
    'descontraído': ['giria', 'meme', 'comida'],
    'casual': ['giria', 'meme', 'lugar'],
    'genuíno': ['musica', 'novela', 'personalidade'],
    'sensual': ['musica', 'giria', 'meme']
  }

  // Encontrar tipos baseado no tom (com fallback)
  for (const [key, types] of Object.entries(toneTypeMap)) {
    if (toneNormalized.includes(key)) {
      return types
    }
  }

  return ['giria', 'meme']  // Default
}
```

**COMANDO 3/5 - Função Enriquecer Prompt:**
```typescript
/**
 * Constrói system prompt enriquecido com cultura brasileira
 */
function buildEnrichedSystemPrompt(
  tone: string,
  focus: string,
  imageDescription: string,
  personName: string,
  culturalRefs: any[]
): string {

  // Base prompt (já existente)
  let prompt = buildSystemPrompt(tone, focus, imageDescription, personName)

  // Adicionar contexto cultural se disponível
  if (culturalRefs.length > 0) {
    prompt += `\n\n**REFERÊNCIAS CULTURAIS BRASILEIRAS:**\n`
    prompt += `Use estas referências de forma natural e contextualizada:\n\n`

    culturalRefs.forEach((ref, index) => {
      prompt += `${index + 1}. **${ref.termo}** (${ref.tipo})\n`
      prompt += `   - Significado: ${ref.significado}\n`
      prompt += `   - Exemplo: "${ref.exemplo_uso}"\n`
      prompt += `   - Contexto: ${ref.contexto_flerte}\n\n`
    })

    prompt += `**INSTRUÇÕES DE USO:**\n`
    prompt += `- Incorpore naturalmente (não force)\n`
    prompt += `- Use 1-2 referências por sugestão (máximo)\n`
    prompt += `- Adapte ao contexto da conversa\n`
    prompt += `- Mantenha autenticidade brasileira\n`
    prompt += `- Considere a região se relevante\n`
  }

  return prompt
}
```

**COMANDO 4/5 - Função Detectar Região (opcional):**
```typescript
/**
 * Detecta região do usuário baseado em perfil ou localização
 */
async function getUserRegion(userId: string): Promise<string> {
  if (!userId) return 'nacional'

  try {
    const { data, error } = await supabaseAdmin
      .from('profiles')
      .select('region')
      .eq('id', userId)
      .single()

    if (data && data.region) {
      return data.region
    }
  } catch (error) {
    console.error('Error fetching user region:', error)
  }

  return 'nacional'  // Fallback
}
```

**COMANDO 5/5 - Integração no Fluxo Principal:**
```typescript
// Na função principal de análise (substitua a existente)
Deno.serve(async (req) => {
  try {
    const { image_path, tone, focus, user_id } = await req.json()

    // ... código existente de análise de imagem ...

    // NOVO: Buscar referências culturais
    const region = await getUserRegion(user_id) // Opcional: detectar região do usuário
    const culturalRefs = await getCulturalReferences(tone, region, 3)

    // Construir prompt enriquecido
    const enrichedPrompt = buildEnrichedSystemPrompt(
      tone,
      focus,
      imageDescription,
      personName,
      culturalRefs
    )

    // Chamar GPT-4o com prompt enriquecido
    const completion = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: enrichedPrompt },
        { role: 'user', content: 'Gere 3 sugestões de mensagem...' }
      ],
      max_tokens: 500,
      temperature: 0.8
    })

    // ... resto do código ...
  } catch (error) {
    // ... error handling ...
  }
})
```

---

### **📍 PASSO 3: Deploy da Edge Function**

**🔗 URL Deploy:**
```
https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/functions/analyze-conversation/deploy
```

**📋 Comando para Deploy (via Supabase CLI - opcional):**
```bash
# Se tiver Supabase CLI instalado
supabase functions deploy analyze-conversation
```

**📋 Deploy via Dashboard:**
1. Vá para a URL acima
2. Clique em **"Deploy function"**
3. Aguarde o deploy completar

---

### **📍 PASSO 4: Testar Integração**

**🔗 URL Table Editor (verificar dados):**
```
https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/editor
```

**📋 Teste no Supabase SQL Editor:**
```sql
-- Verificar dados estão lá
SELECT COUNT(*) FROM cultural_references;

-- Testar função que será usada pela IA
SELECT * FROM get_random_cultural_reference('giria', 'nacional');

-- Ver estatísticas
SELECT * FROM get_cultural_references_stats();
```

**Resultado esperado:**
```
total_count: 97

tipo_counts: {
  "giria": 39,
  "meme": 15,
  "musica": 8,
  ...
}

regiao_counts: {
  "nacional": 60,
  "sudeste": 13,
  "nordeste": 9,
  ...
}
```

---

### **📍 PASSO 5: Testar no App**

**📋 Como Testar:**

1. **Abra o app FlertAI**
2. **Vá para a tela de análise**
3. **Faça upload de uma imagem**
4. **Selecione um tom** (ex: "Flertar", "Descontraído")
5. **Clique em "Gerar sugestões"**

**📋 Verificar Logs (se houver erro):**
```bash
# Ver logs da Edge Function no Supabase
# Dashboard → Edge Functions → analyze-conversation → Logs
```

---

## 🎯 **CHECKLIST DE EXECUÇÃO**

### **Integração IA:**
- [ ] **PASSO 1:** Localizar Edge Function
- [ ] **PASSO 2:** Adicionar código TypeScript (5 comandos)
- [ ] **PASSO 3:** Deploy da função
- [ ] **PASSO 4:** Testar dados no banco
- [ ] **PASSO 5:** Testar no app

### **Comandos SQL para Verificar:**
- [ ] **Verificar dados:** `SELECT COUNT(*) FROM cultural_references;`
- [ ] **Testar funções:** `SELECT * FROM get_random_cultural_reference('giria', 'nacional');`
- [ ] **Ver estatísticas:** `SELECT * FROM get_cultural_references_stats();`

---

## 📊 **URLs IMPORTANTES:**

### **🔗 Principais:**
- **Dashboard Geral:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf
- **Edge Functions:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/functions
- **SQL Editor:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/sql/new
- **Table Editor:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/editor

### **📄 Documentação:**
- **Guia Integração:** `docs/INTEGRACAO_CULTURAL_REFERENCES.md`
- **Exemplos Código:** Mesmo arquivo acima

---

## ✅ **Resultado Esperado:**

### **Antes (sem integração):**
```
Sugestão genérica:
"Oi, vi que você gosta de praia! Bora marcar?"
```

### **Depois (com integração):**
```
Sugestão enriquecida:
"Oi crush! 😍 Curti demais sua vibe de praia... você é tipo
a Garota de Ipanema moderna! Bora marcar um açaí e trocar
uma ideia? Seu sorriso é meu gatilho! ✨"
```

---

## 🚨 **Problemas Comuns:**

### **"Function not found":**
- Verifique se executou todos os comandos SQL da migration

### **"Permission denied":**
- Verifique se a Service Role Key está correta no .env

### **Erro no deploy:**
- Verifique se o código TypeScript está correto
- Verifique logs no dashboard da Edge Function

---

## 📋 **RESUMO EXECUÇÃO:**

**⏱️ Tempo estimado:** 10-15 minutos

1. **🔗 Acesse:** https://supabase.com/dashboard/project/olojvpoqosrjcoxygiyf/functions
2. **📝 Edite:** analyze-conversation function
3. **📋 Cole:** 5 comandos TypeScript (um por vez)
4. **🚀 Deploy:** Clique em "Deploy function"
5. **✅ Teste:** Execute comandos SQL de verificação
6. **🎯 Teste:** Use o app e veja sugestões enriquecidas

---

**🎉 Pronto! Com esses passos você terá sugestões de IA usando referências culturais brasileiras!** 🇧🇷✨
