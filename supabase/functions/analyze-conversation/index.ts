import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// Cliente admin para acessar cultural_references (Service Role Key)
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

interface AnalysisRequest {
  image_path?: string
  image_base64?: string
  tone: string
  focus?: string
  user_id?: string
  text?: string
}

interface OpenAIMessage {
  role: 'system' | 'user' | 'assistant'
  content: string | Array<{
    type: 'text' | 'image_url'
    text?: string
    image_url?: {
      url: string
      detail?: 'low' | 'high' | 'auto'
    }
  }>
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Parse request body
    const { image_path, image_base64, tone, focus, user_id, text }: AnalysisRequest = await req.json()

    // Validate required fields
    if (!tone) {
      return new Response(
        JSON.stringify({ error: 'Tone is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check daily usage limit if user_id is provided
    if (user_id) {
      const { data: canUse, error: limitError } = await supabaseClient
        .rpc('check_daily_limit', { user_id })

      if (limitError) {
        console.error('Error checking daily limit:', limitError)
      } else if (!canUse) {
        return new Response(
          JSON.stringify({ 
            error: 'Daily limit reached',
            code: 'DAILY_LIMIT_EXCEEDED'
          }),
          { 
            status: 429, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }
    }

    // Prepare OpenAI API call
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OpenAI API key not configured')
    }

    // Extract detailed image information including person's name
    let imageDescription = 'Nenhuma imagem fornecida'
    let personName = 'Nenhum'

    if (image_base64 || image_path) {
      let imageUrl = ''
      
      if (image_base64) {
        imageUrl = `data:image/jpeg;base64,${image_base64}`
      } else if (image_path) {
        // If image_path is an absolute URL, use it directly. Otherwise, treat as storage path.
        const isAbsoluteUrl = /^https?:\/\//i.test(image_path)
        if (isAbsoluteUrl) {
          imageUrl = image_path
        } else {
          // Get public URL from Supabase Storage bucket 'images'
          const { data } = supabaseClient.storage
            .from('images')
            .getPublicUrl(image_path)
          imageUrl = data.publicUrl
        }
      }

      if (imageUrl) {
        // Step 1: Extract detailed information from image using GPT-4o Vision
        const visionPrompt = `Analise esta imagem de perfil em detalhes e retorne as informações no seguinte formato JSON:
{
  "nome_da_pessoa_detectado": "[Nome da pessoa se visível na imagem, caso contrário 'Nenhum']",
  "descricao_visual": "[Descrição detalhada da aparência, vestuário, cenário, expressão, objetos visíveis]",
  "texto_extraido_ocr": "[Qualquer texto visível na imagem: nome de usuário, legendas, placas, camisetas]"
}

Foque especialmente em:
- Identificar o NOME da pessoa se estiver visível (em username, legenda, texto na imagem)
- Aparência física e estilo
- Cenário e ambiente
- Objetos que indiquem hobbies ou interesses
- Qualquer texto visível na imagem`

        const visionMessages: OpenAIMessage[] = [
          {
            role: 'user',
            content: [
              { type: 'text', text: visionPrompt },
              { type: 'image_url', image_url: { url: imageUrl, detail: 'high' } }
            ]
          }
        ]

        try {
          const visionResponse = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${openaiApiKey}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              model: 'gpt-4o',
              messages: visionMessages,
              max_tokens: 500,
              temperature: 0.3,
            }),
          })

          if (visionResponse.ok) {
            const visionData = await visionResponse.json()
            const visionResult = visionData.choices[0]?.message?.content || ''
            
            // Try to parse JSON response
            try {
              const parsedVision = JSON.parse(visionResult)
              personName = parsedVision.nome_da_pessoa_detectado || 'Nenhum'
              const visualDesc = parsedVision.descricao_visual || ''
              const ocrText = parsedVision.texto_extraido_ocr || ''
              imageDescription = `Descrição Visual: ${visualDesc}\n\nTexto Extraído (OCR): ${ocrText}`
            } catch {
              // If JSON parsing fails, use the raw response
              imageDescription = visionResult
              // Try to extract name from the response text
              const nameMatch = visionResult.match(/nome[:\s]+([\w\s]+)/i)
              if (nameMatch) {
                personName = nameMatch[1].trim()
              }
            }
          }
        } catch (visionError) {
          console.error('Vision API error:', visionError)
          // Fallback to basic description
          imageDescription = 'Imagem de perfil fornecida, mas não foi possível extrair informações detalhadas.'
        }
      }
    }

    // Add additional text context if provided
    if (text && text.trim().length > 0) {
      imageDescription += `\n\nContexto adicional de texto/bio: ${text}`
    }

    // NEW: Buscar referências culturais brasileiras
    const region = await getUserRegion(user_id) // Detecta região do usuário (ou 'nacional')
    const culturalRefs = await getCulturalReferences(tone, region, 3)
    
    // Build system prompt with extracted information + cultural references
    const systemPrompt = buildEnrichedSystemPrompt(tone, focus, imageDescription, personName, culturalRefs)

    // Prepare messages for OpenAI
    const messages: OpenAIMessage[] = [
      {
        role: 'system',
        content: systemPrompt
      },
      {
        role: 'user',
        content: 'Gere 3 sugestões de mensagens criativas e envolventes seguindo todas as instruções do sistema, utilizando as informações da imagem e o nome da pessoa se disponível.'
      }
    ]

    // Call OpenAI API
    const openaiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: image_base64 || image_path ? 'gpt-4o' : 'gpt-4o-mini',
        messages,
        max_tokens: 500,
        temperature: 0.8,
      }),
    })

    if (!openaiResponse.ok) {
      const errorText = await openaiResponse.text()
      console.error('OpenAI API error:', openaiResponse.status, errorText)
      return new Response(
        JSON.stringify({
          error: 'OPENAI_ERROR',
          httpStatus: openaiResponse.status,
          details: errorText,
        }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const openaiData = await openaiResponse.json()
    const aiResponse = openaiData.choices[0]?.message?.content || ''

    // Parse suggestions from AI response
    const suggestions = parseSuggestions(aiResponse)

    // Save conversation and suggestions to database if user_id is provided
    let conversationId = null
    if (user_id) {
      try {
        // Save conversation
        const { data: conversation, error: convError } = await supabaseClient
          .from('conversations')
          .insert({
            user_id,
            image_url: image_path || null,
            analysis_result: {
              tone,
              focus,
              ai_response: aiResponse,
              suggestions,
              timestamp: new Date().toISOString()
            }
          })
          .select()
          .single()

        if (convError) {
          console.error('Error saving conversation:', convError)
        } else {
          conversationId = conversation.id

          // Save individual suggestions
          const suggestionInserts = suggestions.map(suggestion => ({
            conversation_id: conversationId,
            tone_type: tone,
            suggestion_text: suggestion
          }))

          const { error: sugError } = await supabaseClient
            .from('suggestions')
            .insert(suggestionInserts)

          if (sugError) {
            console.error('Error saving suggestions:', sugError)
          }

          // Increment daily usage
          await supabaseClient.rpc('increment_daily_usage', { user_id })
        }
      } catch (dbError) {
        console.error('Database error:', dbError)
        // Continue execution even if database save fails
      }
    }

    // Return successful response
    const response = {
      success: true,
      suggestions,
      conversation_id: conversationId,
      tone,
      focus,
      usage_info: {
        model_used: image_base64 || image_path ? 'gpt-4o' : 'gpt-4o-mini',
        tokens_used: openaiData.usage?.total_tokens || 0
      }
    }

    return new Response(
      JSON.stringify(response),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Function error:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        message: (error as Error).message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

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
      
      if (references.length >= count) break
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

/**
 * Detecta região do usuário baseado em perfil ou localização
 */
async function getUserRegion(userId: string | undefined): Promise<string> {
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

/**
 * Constrói system prompt enriquecido com cultura brasileira
 */
function buildEnrichedSystemPrompt(
  tone: string, 
  focus: string | undefined, 
  imageDescription: string, 
  personName: string,
  culturalRefs: any[]
): string {
  // Base prompt (versão existente)
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

function buildSystemPrompt(tone: string, focus: string | undefined, imageDescription: string, personName: string): string {
  const toneInstructions = getToneInstructions(tone)
  const hasTone = tone && tone.toLowerCase() !== 'nenhum'
  const hasFocus = focus && focus.toLowerCase() !== 'nenhum'
  const hasName = personName && personName.toLowerCase() !== 'nenhum'
  
  const toneSection = hasTone 
    ? `**Tom Escolhido pelo Usuário:** ${tone}\n${toneInstructions}\n` 
    : `**Tom Escolhido pelo Usuário:** Nenhum (use tom descontraído e casual por padrão)\n`
  
  const focusSection = hasFocus 
    ? `**Foco Escolhido pelo Usuário:** ${focus}\n` 
    : `**Foco Escolhido pelo Usuário:** Nenhum\n`
  
  const nameSection = hasName
    ? `**Nome da Pessoa Detectado:** ${personName}\n`
    : `**Nome da Pessoa Detectado:** Nenhum\n`
  
  return `Você é o FlertAI, um cupido digital super observador e com um talento nato para criar mensagens de paquera autênticas e irresistíveis, focadas no mercado brasileiro. Sua missão é ajudar as pessoas a quebrar o gelo e iniciar conversas genuínas, como se um amigo próximo e divertido estivesse dando uma forcinha.

Sua tarefa é analisar a imagem de perfil fornecida com olhos de águia, extraindo cada detalhe visual e textual que possa inspirar uma conexão. Use essas observações para criar mensagens de paquera personalizadas, criativas e que soem 100% humanas.

**Informações Fornecidas:**
- **Descrição Detalhada da Imagem:** ${imageDescription}
${nameSection}${toneSection}${focusSection}
**Elementos Visuais e Contextuais a Analisar Detalhadamente:**
- **Aparência da Pessoa:** Idade aparente, estilo (clássico, moderno, alternativo), características marcantes (cabelo, olhos, sorriso)
- **Vestuário e Acessórios:** Tipo de roupa, se há marcas, acessórios (óculos, joias, chapéus) que revelem personalidade ou status
- **Cenário e Ambiente:** Local (praia, montanha, cidade, café, casa), tipo de iluminação, objetos de fundo que indiquem hobbies, viagens, estilo de vida (livros, instrumentos musicais, animais de estimação, obras de arte)
- **Expressão e Linguagem Corporal:** Sorriso (aberto, misterioso), postura, olhar, que transmitam confiança, alegria, serenidade
- **Textos na Imagem:** Qualquer texto visível (placas, camisetas, legendas) que possa ser usado para contextualizar
- **Qualidade da Imagem:** Se a foto é profissional, casual, divertida, etc.

**Instruções para a Criação das Mensagens:**
- **Seja um Cupido Moderno:** Sua voz deve ser amigável, um pouco atrevida (se o tom permitir), e sempre positiva. Pense como alguém que realmente quer ver a pessoa feliz
- **Português Brasileiro Autêntico:** Use gírias e expressões comuns no Brasil, de forma natural e não forçada. Evite formalidades excessivas
- **ORIGINALIDADE é a Chave:** Fuja de clichês! A mensagem deve ser única e mostrar que você realmente "viu" a pessoa na foto. Nada de "oi linda" ou "tudo bem?"
- **Priorize Tom, Foco e Nome:**
${hasName ? `    - **USO DO NOME (PRIORIDADE ALTA):** Utilize o nome "${personName}" de forma natural e amigável em pelo menos uma das mensagens. Ex: "Oi, ${personName}! Adorei seu perfil..." ou "${personName}, seu sorriso ilumina mais que qualquer pôr do sol!"\n` : ''}${hasTone ? '    - APLIQUE RIGOROSAMENTE as instruções de tom fornecidas acima\n' : ''}${hasFocus ? `    - INTEGRE O FOCO "${focus}" de forma criativa e natural em pelo menos uma das mensagens, conectando-o com os elementos visuais da imagem\n` : ''}${!hasTone && !hasFocus && !hasName ? '    - **Cenário de Fallback:** Gere as mensagens com um tom descontraído e casual, utilizando os elementos mais proeminentes da imagem para contextualização, como se você estivesse fazendo uma observação inteligente e espontânea\n' : ''}- **Conexão Genuína:** A mensagem deve criar uma ponte entre o que você observou na imagem e um possível interesse ou elogio. Se a pessoa está na praia, não diga apenas "gostei da praia", mas "Essa praia parece incrível! Me deu uma vontade de te chamar pra um mergulho por lá... 😉"
- **Uso de Emojis:** Use emojis de forma sutil e estratégica para adicionar emoção e personalidade, mas sem exageros. Escolha emojis que complementem o tom da mensagem
- **Respeito Acima de Tudo:** Mesmo em tons sensuais, a mensagem deve ser respeitosa e convidar à interação, nunca ser invasiva ou objetificante
- **Tamanho e Fluidez:** As sugestões devem ter entre 20 e 40 palavras, permitindo mais naturalidade e criatividade, sem serem excessivamente longas
- **Gere exatamente 3 sugestões numeradas**

**Formato de Saída Obrigatório:**
1. [Mensagem criativa e contextualizada, com emoji]
2. [Mensagem criativa e contextualizada, com emoji]
3. [Mensagem criativa e contextualizada, com emoji]`
}

function getToneInstructions(tone: string): string {
  const normalizedTone = tone.toLowerCase().trim()
  
  const toneMap: { [key: string]: string } = {
    '😘 flertar': `**Instruções de Tom:** Flertante e romântico, demonstrando interesse amoroso de forma sutil e charmosa. Use palavras como "encantador(a)", "olhar", "sorriso", "conexão". Emojis sugeridos: 😉✨💖`,
    'flertar': `**Instruções de Tom:** Flertante e romântico, demonstrando interesse amoroso de forma sutil e charmosa. Use palavras como "encantador(a)", "olhar", "sorriso", "conexão". Emojis sugeridos: 😉✨💖`,
    '😏 descontraído': `**Instruções de Tom:** Casual e divertido, com um toque de humor e leveza. Use expressões como "que vibe", "curti", "top". Emojis sugeridos: 😂😎✌️`,
    'descontraído': `**Instruções de Tom:** Casual e divertido, com um toque de humor e leveza. Use expressões como "que vibe", "curti", "top". Emojis sugeridos: 😂😎✌️`,
    '😎 casual': `**Instruções de Tom:** Natural e espontâneo, como uma conversa entre amigos. Foque em observações simples e convites abertos. Emojis sugeridos: 👋😊💬`,
    'casual': `**Instruções de Tom:** Natural e espontâneo, como uma conversa entre amigos. Foque em observações simples e convites abertos. Emojis sugeridos: 👋😊💬`,
    '💬 genuíno': `**Instruções de Tom:** Autêntico e profundo, mostrando interesse real na pessoa e em seus hobbies/paixões. Use palavras como "interessante", "curiosidade", "apaixonado(a)". Emojis sugeridos: 🤔💡❤️`,
    'genuíno': `**Instruções de Tom:** Autêntico e profundo, mostrando interesse real na pessoa e em seus hobbies/paixões. Use palavras como "interessante", "curiosidade", "apaixonado(a)". Emojis sugeridos: 🤔💡❤️`,
    '😈 sensual': `**Instruções de Tom:** Picante e sedutor, com um toque de sensualidade respeitosa e confiante. Use palavras como "irresistível", "provocante", "química". Emojis sugeridos: 🔥😈😏`,
    'sensual': `**Instruções de Tom:** Picante e sedutor, com um toque de sensualidade respeitosa e confiante. Use palavras como "irresistível", "provocante", "química". Emojis sugeridos: 🔥😈😏`,
    'nenhum': ''
  }
  
  return toneMap[normalizedTone] || `**Instruções de Tom:** Use um tom descontraído e casual por padrão, adaptando-se aos elementos visuais da imagem. Emojis sugeridos: 😊✨👋`
}

function parseSuggestions(content: string): string[] {
  const suggestions: string[] = []
  const lines = content.split('\n')
  
  for (const line of lines) {
    const trimmed = line.trim()
    if (trimmed && /^\d+\./.test(trimmed)) {
      // Remove the number and dot from the beginning
      const suggestion = trimmed.replace(/^\d+\.\s*/, '')
      if (suggestion) {
        suggestions.push(suggestion)
      }
    }
  }
  
  // If parsing failed, try to extract any meaningful content
  if (suggestions.length === 0 && content.trim()) {
    // Split by common separators and take first 3 meaningful parts
    const parts = content.split(/[.!?]/).filter(part => part.trim().length > 10)
    suggestions.push(...parts.slice(0, 3).map(part => part.trim()))
  }
  
  // Ensure we have at least some suggestions
  if (suggestions.length === 0) {
    suggestions.push(
      'Que foto incrível! Me conta mais sobre essa aventura',
      'Adorei seu estilo, você tem um sorriso contagiante',
      'Essa imagem me deixou curioso para te conhecer melhor'
    )
  }
  
  return suggestions.slice(0, 3) // Ensure max 3 suggestions
}
