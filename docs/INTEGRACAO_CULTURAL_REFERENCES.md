# 🇧🇷 Integração: Cultural References + IA FlertAI

Documentação técnica sobre como integrar as referências culturais brasileiras com o sistema de IA do FlertAI.

---

## 📋 Visão Geral

A tabela `cultural_references` fornece contexto cultural brasileiro para enriquecer as sugestões de mensagens geradas pela IA. Ao incorporar gírias, memes e referências culturais autênticas, as sugestões se tornam mais naturais, relevantes e conectadas com a realidade brasileira.

---

## 🎯 Objetivos da Integração

1. **Autenticidade:** Mensagens com gírias e expressões brasileiras reais
2. **Regionalização:** Adaptação por região do Brasil
3. **Atualidade:** Referências culturais modernas (memes, músicas recentes)
4. **Contextualização:** Uso apropriado no contexto de flerte
5. **Diversidade:** Evitar repetição, rotacionar referências

---

## 🔧 Integração com Edge Function

### Localização da Integração

**Arquivo:** `supabase/functions/analyze-conversation/index.ts`

### Passo 1: Importar Cliente Supabase Admin

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

### Passo 2: Buscar Referências Culturais

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

### Passo 3: Enriquecer System Prompt

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

### Passo 4: Integrar no Fluxo Principal

```typescript
// Na função principal de análise
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

### Passo 5: (Opcional) Detectar Região do Usuário

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

---

## 📊 Exemplos de Uso

### Exemplo 1: Tom Flertante com Gíria

**Input:**
```json
{
  "tone": "😘 Flertar",
  "image_description": "Pessoa na praia ao pôr do sol",
  "person_name": "Ana"
}
```

**Cultural References Buscadas:**
```json
[
  {
    "termo": "Crush",
    "tipo": "giria",
    "significado": "Paquera, pessoa que se gosta",
    "exemplo_uso": "Posso te chamar de meu crush?",
    "contexto_flerte": "Flerte moderno"
  },
  {
    "termo": "Evidências",
    "tipo": "musica",
    "significado": "Música romântica de Chitãozinho & Xororó",
    "exemplo_uso": "Tipo Evidências: quando te vejo, me rendo",
    "contexto_flerte": "Romântico clássico"
  }
]
```

**Output (Sugestão Gerada):**
```
"Ana, posso ser sincero? Você me conquistou tipo Evidências... quando vi seu perfil, já me rendi! 😍🌅"
```

### Exemplo 2: Tom Descontraído com Meme

**Input:**
```json
{
  "tone": "😏 Descontraído",
  "image_description": "Pessoa jogando vôlei",
  "person_name": "Carlos"
}
```

**Cultural References:**
```json
[
  {
    "termo": "Vibe check",
    "tipo": "meme",
    "significado": "Verificar a energia/clima",
    "exemplo_uso": "Passou no vibe check!",
    "contexto_flerte": "Aprovação"
  },
  {
    "termo": "Açaí",
    "tipo": "comida",
    "significado": "Fruta amazônica popular",
    "exemplo_uso": "Bora tomar um açaí e conversar?",
    "contexto_flerte": "Convite casual"
  }
]
```

**Output:**
```
"Carlos! Jogando vôlei? Passou no vibe check hein! 😎 Bora marcar um açaí depois do treino?"
```

### Exemplo 3: Tom Genuíno Regional (Nordeste)

**Input:**
```json
{
  "tone": "💬 Genuíno",
  "region": "nordeste",
  "image_description": "Pessoa tocando violão",
  "person_name": "Joana"
}
```

**Cultural References:**
```json
[
  {
    "termo": "Massa",
    "tipo": "giria",
    "significado": "Legal, bacana",
    "exemplo_uso": "Seu perfil tá massa!",
    "regiao": "nordeste",
    "contexto_flerte": "Elogio autêntico"
  },
  {
    "termo": "Acarajé",
    "tipo": "comida",
    "significado": "Comida baiana típica",
    "exemplo_uso": "Bora num acarajé?",
    "regiao": "nordeste",
    "contexto_flerte": "Convite regional"
  }
]
```

**Output:**
```
"Joana, achei massa demais você tocando violão! 🎸 Se você topa, bora num acarajé pra gente trocar uma ideia?"
```

---

## 🎨 Estratégias de Uso Inteligente

### 1. Seleção Contextual

```typescript
/**
 * Seleciona referências baseado em múltiplos fatores
 */
function selectContextualReferences(
  imageDescription: string,
  tone: string,
  region: string,
  allRefs: any[]
): any[] {
  // Detectar palavras-chave na descrição
  const keywords = extractKeywords(imageDescription)
  
  // Priorizar referências relacionadas
  const scored = allRefs.map(ref => ({
    ...ref,
    score: calculateRelevanceScore(ref, keywords, tone, region)
  }))
  
  // Ordenar por score e pegar top 3
  return scored
    .sort((a, b) => b.score - a.score)
    .slice(0, 3)
}

function calculateRelevanceScore(
  ref: any,
  keywords: string[],
  tone: string,
  region: string
): number {
  let score = 0
  
  // Região match
  if (ref.regiao === region) score += 2
  else if (ref.regiao === 'nacional') score += 1
  
  // Keyword match
  keywords.forEach(keyword => {
    if (ref.significado.toLowerCase().includes(keyword)) score += 3
    if (ref.contexto_flerte.toLowerCase().includes(keyword)) score += 2
  })
  
  // Tipo apropriado para tom
  const appropriateTypes = getCulturalTypesForTone(tone)
  if (appropriateTypes.includes(ref.tipo)) score += 2
  
  return score
}
```

### 2. Rotação Inteligente

```typescript
/**
 * Evita repetição de referências para o mesmo usuário
 */
async function getRotatedReferences(
  userId: string,
  tone: string,
  region: string
): Promise<any[]> {
  // Buscar histórico de referências usadas
  const usedRefs = await getUserReferencesHistory(userId)
  
  // Buscar novas referências não usadas
  const { data: newRefs } = await supabaseAdmin
    .from('cultural_references')
    .select('*')
    .not('id', 'in', `(${usedRefs.join(',')})`)
    .eq('regiao', region)
    .limit(10)
  
  // Salvar referências usadas
  await saveReferencesHistory(userId, newRefs.map(r => r.id))
  
  return newRefs.slice(0, 3)
}
```

### 3. A/B Testing

```typescript
/**
 * Teste A/B: Com vs Sem referências culturais
 */
async function generateWithABTest(
  userId: string,
  ...params: any[]
): Promise<any> {
  const usesCulturalRefs = Math.random() < 0.5  // 50/50
  
  if (usesCulturalRefs) {
    const culturalRefs = await getCulturalReferences(...)
    // Gerar com referências
    return generateWithCulturalContext(culturalRefs, ...params)
  } else {
    // Gerar sem referências (baseline)
    return generateBaseline(...params)
  }
}
```

---

## 📈 Métricas e Analytics

### Eventos a Rastrear

```typescript
// Após geração de sugestões
await logAnalyticsEvent({
  event_name: 'suggestions_generated',
  user_id: userId,
  cultural_refs_used: culturalRefs.map(r => r.id),
  cultural_refs_count: culturalRefs.length,
  tone: tone,
  region: region,
  timestamp: new Date().toISOString()
})
```

### Queries de Análise

```sql
-- Referências mais usadas
SELECT 
  cr.termo,
  cr.tipo,
  COUNT(*) as usage_count
FROM analytics_events ae
CROSS JOIN JSONB_ARRAY_ELEMENTS_TEXT(ae.cultural_refs_used::jsonb) AS ref_id
JOIN cultural_references cr ON cr.id::text = ref_id
WHERE ae.event_name = 'suggestions_generated'
GROUP BY cr.id, cr.termo, cr.tipo
ORDER BY usage_count DESC
LIMIT 20;

-- Taxa de conversão por referência
SELECT 
  cr.termo,
  COUNT(*) FILTER (WHERE ae.conversion = true) / COUNT(*)::float as conversion_rate
FROM analytics_events ae
JOIN cultural_references cr ON cr.id = ANY(ae.cultural_refs_used)
WHERE ae.event_name = 'suggestions_generated'
GROUP BY cr.id, cr.termo
HAVING COUNT(*) > 10
ORDER BY conversion_rate DESC;
```

---

## 🧪 Testes

### Teste 1: Verificar Busca de Referências

```typescript
// test/cultural_references_test.ts
import { assertEquals } from "https://deno.land/std@0.192.0/testing/asserts.ts"

Deno.test("getCulturalReferences returns valid data", async () => {
  const refs = await getCulturalReferences('flertar', 'nacional', 3)
  
  assertEquals(refs.length <= 3, true)
  refs.forEach(ref => {
    assertEquals(typeof ref.termo, 'string')
    assertEquals(typeof ref.tipo, 'string')
    assertEquals(typeof ref.significado, 'string')
  })
})
```

### Teste 2: Validar Integração no Prompt

```typescript
Deno.test("buildEnrichedSystemPrompt includes cultural context", () => {
  const mockRefs = [{
    termo: 'Crush',
    tipo: 'giria',
    significado: 'Paquera',
    exemplo_uso: 'Você é meu crush',
    contexto_flerte: 'Moderno'
  }]
  
  const prompt = buildEnrichedSystemPrompt(
    'flertar',
    'praia',
    'Pessoa na praia',
    'Ana',
    mockRefs
  )
  
  assertEquals(prompt.includes('Crush'), true)
  assertEquals(prompt.includes('REFERÊNCIAS CULTURAIS'), true)
})
```

---

## 🚀 Deploy e Rollout

### Fase 1: Soft Launch (10% de usuários)

```typescript
// Feature flag
const CULTURAL_REFS_ROLLOUT_PERCENTAGE = 0.10

function shouldUseCulturalRefs(userId: string): boolean {
  const hash = hashUserId(userId)
  return (hash % 100) < (CULTURAL_REFS_ROLLOUT_PERCENTAGE * 100)
}
```

### Fase 2: Monitoramento

- Taxa de uso de referências
- Qualidade das sugestões (feedback)
- Performance (latência adicional)
- Erros de busca

### Fase 3: Rollout Completo

- 100% após validação
- Documentação atualizada
- Treinamento de suporte

---

## 📝 Checklist de Implementação

- [ ] Tabela `cultural_references` criada
- [ ] Seed data inserido (80+ refs)
- [ ] Funções RPC testadas
- [ ] Edge Function modificada
- [ ] `getCulturalReferences()` implementada
- [ ] `buildEnrichedSystemPrompt()` implementada
- [ ] Integração no fluxo principal
- [ ] Testes unitários criados
- [ ] Feature flag configurado
- [ ] Métricas configuradas
- [ ] Documentação atualizada
- [ ] Deploy em staging
- [ ] Testes manuais
- [ ] Deploy em produção
- [ ] Monitoramento ativo

---

## 🎯 Resultados Esperados

### Antes da Integração

**Sugestão típica:**
```
"Oi, vi que você gosta de praia! Que lugar incrível. Bora marcar de ir juntos?"
```

### Depois da Integração

**Sugestão enriquecida:**
```
"Oi, crush! 😍 Vi que você arrasa na praia... tipo Garota de Ipanema! Bora marcar um açaí e depois curtir o pôr do sol?"
```

**Benefícios:**
- ✅ Mais autêntico e brasileiro
- ✅ Uso natural de gírias
- ✅ Referências culturais relevantes
- ✅ Maior engajamento esperado
- ✅ Diferenciação no mercado

---

## 📞 Suporte

- **Documentação:** Este arquivo
- **Schema:** `supabase/migrations/20251001_create_cultural_references.sql`
- **Scripts:** `scripts/scraper/`
- **Auditoria:** `AUDITORIA_COMPLETA.md`

---

**Desenvolvido com ❤️ para criar conexões autenticamente brasileiras** 🇧🇷✨
