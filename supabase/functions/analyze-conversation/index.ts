import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// Cliente admin para acessar cultural_references (Service Role Key)
const supabaseAdmin = createClient(
  Deno.env.get('URL_SUPABASE') ?? '',
  Deno.env.get('SERVICE_ROLE_KEY_supabase') ?? '',
  {
    auth: {
      persistSession: false
    }
  }
)

interface ConversationSegment {
  autor: string
  texto: string
}

interface AnalysisRequest {
  image_path?: string
  image_base64?: string
  tone: string
  focus_tags?: string[]
  focus?: string
  user_id?: string
  text?: string
  personalized_instructions?: string  // Instruções personalizadas do aprendizado
  previous_suggestions?: string[]  // Sugestões anteriores para evitar repetição
  skip_vision?: boolean  // Se true, pula análise de visão e usa contexto fornecido
  vision_context?: {  // Contexto da visão quando skip_vision é true
    personName: string
    imageDescription: string
    conversationSegments: ConversationSegment[]
}

interface VisionAnalysisResult {
  nome_da_pessoa_detectado: string
  descricao_visual: string
  texto_extraido_ocr?: string
  conversa_segmentada?: ConversationSegment[]
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

  const startTime = Date.now() // NOVO: Início da medição de latência

  try {
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('URL_SUPABASE') ?? '',
      Deno.env.get('ANON_KEY_SUPABASE') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Parse request body
    const { image_path, image_base64, tone, focus_tags, focus, user_id, text, personalized_instructions, previous_suggestions, skip_vision, vision_context }: AnalysisRequest = await req.json()

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

    // NOVO: Rate limiting para usuários não autenticados (50 requisições por hora por IP)
    if (!user_id) {
      const clientIP = req.headers.get('x-forwarded-for') ||
                      req.headers.get('x-real-ip') ||
                      'unknown'

      try {
        const { data: rateLimitData, error: rateLimitError } = await supabaseClient
          .rpc('check_anonymous_rate_limit', {
            client_ip: clientIP,
            max_requests: 50,
            window_minutes: 60
          })

        if (rateLimitError) {
          console.error('Rate limit check error:', rateLimitError)
        } else if (rateLimitData === false) {
          return new Response(
            JSON.stringify({
              error: 'Rate limit exceeded',
              message: 'Muitas requisições. Tente novamente em alguns minutos.',
              code: 'RATE_LIMIT_EXCEEDED'
            }),
            {
              status: 429,
              headers: {
                ...corsHeaders,
                'Content-Type': 'application/json',
                'Retry-After': '3600' // 1 hora
              }
            }
          )
        }
      } catch (rateLimitError) {
        console.error('Rate limit check failed:', rateLimitError)
        // Continua execução mesmo se rate limit falhar
      }
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

    // Extract detailed image information including person's name and conversation segmentation
    let imageDescription = 'Nenhuma imagem fornecida'
    let personName = 'Nenhum'
    let conversationSegments: ConversationSegment[] = []

    // Se skip_vision for true, usar contexto fornecido em vez de analisar imagem
    if (skip_vision && vision_context) {
      console.log('✅ Usando contexto de visão fornecido (skip_vision=true)')
      personName = vision_context.personName
      imageDescription = vision_context.imageDescription
      conversationSegments = vision_context.conversationSegments
    } else if (image_base64 || image_path) {
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
        // Step 1: Extract detailed information from image using GPT-4o Vision with conversation segmentation
        const visionPrompt = `Analise esta imagem com EXTREMA ATENÇÃO ao layout visual e retorne as informações no seguinte formato JSON:

{
  "nome_da_pessoa_detectado": "[Nome da pessoa se visível na imagem, caso contrário 'Nenhum']",
  "descricao_visual": "[Descrição detalhada da aparência, vestuário, cenário, expressão, objetos visíveis]",
  "texto_extraido_ocr": "[Qualquer texto visível na imagem: nome de usuário, legendas, placas, camisetas]",
  "conversa_segmentada": [
    {"autor": "match", "texto": "Mensagem do match"},
    {"autor": "user", "texto": "Sua mensagem"},
    {"autor": "match", "texto": "Outra mensagem do match"}
  ]
}

**INSTRUÇÕES CRÍTICAS PARA SEGMENTAÇÃO DE CONVERSA:**

Se a imagem contém uma conversa de aplicativo de namoro (Tinder, Bumble, etc.), identifique CADA mensagem e seu autor baseado em:

1. **LAYOUT VISUAL:**
   - Mensagens alinhadas à DIREITA geralmente são do USUÁRIO (user)
   - Mensagens alinhadas à ESQUERDA geralmente são do MATCH (match)
   
2. **CORES E DESIGN:**
   - Balões azuis/verdes escuros = user
   - Balões brancos/cinzas claros = match
   - Analise o padrão de cores consistente

3. **CONTEXTO E PADRÕES:**
   - Primeira mensagem geralmente é do match (quem iniciou)
   - Alternância natural de turnos
   - Analise timestamps se visíveis

4. **FORMATO DE SAÍDA:**
   - Liste TODAS as mensagens visíveis na ordem cronológica
   - Cada objeto deve ter "autor" ("user" ou "match") e "texto" (mensagem completa)
   - Se não houver conversa, deixe array vazio: []

**OUTRAS INFORMAÇÕES:**
- Identifique o NOME da pessoa se estiver visível (em username, legenda, texto na imagem)
- Descreva aparência física, vestuário e estilo
- Cenário e ambiente
- Objetos que indiquem hobbies ou interesses
- Qualquer texto visível na imagem

**IMPORTANTE:** Retorne **apenas** o JSON acima, **sem qualquer explicação ou texto adicional** fora do formato especificado.`

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
              max_tokens: 1000,  // Aumentado para acomodar conversas segmentadas
              temperature: 0.2,  // Reduzido para maior precisão na segmentação
              response_format: { type: "json_object" }  // Força resposta JSON
            }),
          })

          if (visionResponse.ok) {
            const visionData = await visionResponse.json()
            const visionResult = visionData.choices[0]?.message?.content || ''
            
            // Parse JSON response
            try {
              // Remove markdown code blocks if present
              const cleanedResult = visionResult.replace(/```json\n?|```\n?/g, '').trim()
              const parsedVision: VisionAnalysisResult = JSON.parse(cleanedResult)
              
              // Extract all information
              personName = parsedVision.nome_da_pessoa_detectado || 'Nenhum'
              const visualDesc = parsedVision.descricao_visual || ''
              const ocrText = parsedVision.texto_extraido_ocr || ''
              
              // Build description
              imageDescription = `Descrição Visual: ${visualDesc}\n\nTexto Extraído (OCR): ${ocrText}`
              
              // Extract conversation segments if available
              if (parsedVision.conversa_segmentada && Array.isArray(parsedVision.conversa_segmentada) && parsedVision.conversa_segmentada.length > 0) {
                conversationSegments = parsedVision.conversa_segmentada

                console.log(`✅ Conversa segmentada detectada: ${conversationSegments.length} mensagens totais`)

                // Não adicionar ao imageDescription - será tratado separadamente no system prompt
              }
            } catch (parseError) {
              console.error('Erro ao parsear resposta JSON do Vision:', parseError)
              console.log('Resposta original:', visionResult)

              // Fallback: usar resposta bruta
              imageDescription = visionResult

              // Tentar extrair nome manualmente
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

    // NOVO: Extrair âncoras da análise de visão
    const anchors = extractAnchors(personName, imageDescription, conversationSegments)

    // Add additional text context if provided
    if (text && text.trim().length > 0) {
      imageDescription += `\n\nContexto adicional de texto/bio: ${text}`
    }

    // NEW: Buscar referências culturais brasileiras
    const region = await getUserRegion(user_id) // Detecta região do usuário (ou 'nacional')
    const culturalRefs = await getCulturalReferences(tone, region, 3)
    
    // Extrair histórico de conversa (últimas 3-5 mensagens)
    const conversationHistory = extractConversationHistory(conversationSegments, 5)
    
    // Build system prompt with extracted information + cultural references + conversation history
    let systemPrompt = buildEnrichedSystemPrompt(tone, focus_tags, focus, imageDescription, personName, culturalRefs, conversationHistory)
    
    // Adicionar instruções personalizadas do aprendizado do usuário
    if (personalized_instructions) {
      systemPrompt += '\n\n' + personalized_instructions
    }
    
    // Adicionar sugestões anteriores para evitar repetição
    if (previous_suggestions && previous_suggestions.length > 0) {
      systemPrompt += `\n\n**⚠️ ATENÇÃO - EVITE REPETIÇÃO:**

Você JÁ gerou estas sugestões anteriormente:
${previous_suggestions.map((s, i) => `${i + 1}. ${s}`).join('\n')}

**INSTRUÇÕES CRÍTICAS:**
- NÃO repita os mesmos conceitos, palavras-chave ou abordagens das sugestões anteriores
- NÃO mencione novamente os mesmos elementos visuais já explorados (ex: se já falou de praia, foque em outro aspecto)
- EXPLORE novos ângulos e aspectos da imagem/conversa que ainda não foram abordados
- SEJA CRIATIVO e traga perspectivas completamente diferentes
- Mantenha a qualidade alta, mas com ORIGINALIDADE TOTAL em relação às anteriores

**Exemplo:**
Se anteriores mencionaram "praia", "sol", "vibe", agora foque em "aventura", "personalidade", "estilo de vida" etc.`
    }

    // Prepare messages for OpenAI
    const messages: OpenAIMessage[] = [
      {
        role: 'system',
        content: systemPrompt
      },
      {
        role: 'user',
        content: 'Gere apenas 1 sugestão de mensagem criativa e envolvente seguindo todas as instruções do sistema, utilizando as informações da imagem e o nome da pessoa se disponível.'
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

    // NOVO: Validar âncoras na sugestão e regenerar se necessário
    let finalSuggestion = suggestions[0]
    let anchorsUsed: string[] = []
    let lowConfidence = false

    if (anchors.length > 0) {
      const validation = validateSuggestionAnchors(finalSuggestion, anchors)
      anchorsUsed = validation.anchorsUsed

      // Se a sugestão não usa âncoras suficientes, tentar regenerar uma vez
      if (!validation.isValid) {
        console.log('⚠️ Sugestão inicial sem âncoras suficientes, tentando regenerar...')

        // Adicionar instrução específica para usar âncoras
        const reinforcedSystemPrompt = systemPrompt + `\n\n**⚠️ INSTRUÇÃO CRÍTICA - REGENERAÇÃO:**
A sugestão anterior não usou elementos suficientes da imagem/conversa. Use pelo menos uma das seguintes âncoras específicas: ${anchors.slice(0, 3).join(', ')}
Certifique-se de que sua resposta contenha pelo menos uma dessas palavras/expressões!`

        const regenerationMessages: OpenAIMessage[] = [
          {
            role: 'system',
            content: reinforcedSystemPrompt
          },
          {
            role: 'user',
            content: 'Gere apenas 1 sugestão de mensagem que use elementos específicos da imagem/conversa fornecida, especialmente as âncoras mencionadas.'
          }
        ]

        try {
          const regenResponse = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${openaiApiKey}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              model: image_base64 || image_path ? 'gpt-4o' : 'gpt-4o-mini',
              messages: regenerationMessages,
              max_tokens: 500,
              temperature: 0.8,
            }),
          })

          if (regenResponse.ok) {
            const regenData = await regenResponse.json()
            const regenAiResponse = regenData.choices[0]?.message?.content || ''
            const regenSuggestions = parseSuggestions(regenAiResponse)

            if (regenSuggestions.length > 0) {
              const regenValidation = validateSuggestionAnchors(regenSuggestions[0], anchors)
              if (regenValidation.isValid) {
                finalSuggestion = regenSuggestions[0]
                anchorsUsed = regenValidation.anchorsUsed
                console.log('✅ Sugestão regenerada com sucesso usando âncoras!')
              } else {
                lowConfidence = true
                console.log('⚠️ Mesmo após regeneração, sugestão ainda não usa âncoras suficientes')
              }
            }
          }
        } catch (regenError) {
          console.error('Erro na regeneração:', regenError)
          lowConfidence = true
        }
      }
    }

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
              focus_tags,
              ai_response: aiResponse,
              suggestions: [finalSuggestion], // Usar sugestão final validada
              conversation_segments: conversationSegments, // NOVO: Salvar segmentos detectados
              has_conversation: conversationSegments.length > 0,
              vision_context: !skip_vision && (image_base64 || image_path) ? {
                personName,
                imageDescription,
                conversationSegments: conversationSegments
              } : null, // NOVO: Salvar contexto de visão quando disponível
              anchors: anchors, // NOVO: Salvar âncoras extraídas
              anchors_used: anchorsUsed, // NOVO: Âncoras usadas na sugestão final
              low_confidence: lowConfidence, // NOVO: Flag de baixa confiança
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

          // NOVO: Salvar segmentos de conversa em tabela separada para análise
          if (conversationSegments.length > 0) {
            const segmentInserts = conversationSegments.map((segment, index) => ({
              conversation_id: conversationId,
              segment_index: index,
              autor: segment.autor,
              texto: segment.texto,
              created_at: new Date().toISOString()
            }))

            const { error: segError } = await supabaseClient
              .from('conversation_segments')
              .insert(segmentInserts)

            if (segError) {
              console.error('Error saving conversation segments:', segError)
            } else {
              console.log(`✅ Salvou ${conversationSegments.length} segmentos de conversa`)
            }
          }
        }
      } catch (dbError) {
        console.error('Database error:', dbError)
        // Continue execution even if database save fails
      }
    }

    // Return successful response with conversation segments
    const response: any = {
      success: true,
      suggestions: [finalSuggestion], // Usar sugestão final validada
      conversation_id: conversationId,
      tone,
      focus,
      focus_tags,
      conversation_segments: conversationSegments,  // Todas as mensagens
      conversation_history_used: conversationHistory,  // Últimas 3-5 usadas no prompt
      has_conversation: conversationSegments.length > 0,  // Flag indicadora
      usage_info: {
        model_used: image_base64 || image_path ? 'gpt-4o' : 'gpt-4o-mini',
        tokens_used: openaiData.usage?.total_tokens || 0,
        vision_capabilities: 'conversation_segmentation_enabled'
      },
      // NOVO: Informações sobre validação de âncoras
      anchors_info: {
        total_anchors: anchors.length,
        anchors_used: anchorsUsed.length,
        low_confidence: lowConfidence
      }
    }

    // Add vision_context if this was a fresh vision analysis (not skip_vision)
    if (!skip_vision && (image_base64 || image_path)) {
      response.vision_context = {
        personName,
        imageDescription,
        conversationSegments: conversationSegments
      }
    }

    // NOVO: Calcular métricas de qualidade e repetição
    const endTime = Date.now()
    const latencyMs = endTime - startTime

    // Calcular taxa de repetição com sugestões anteriores
    let repetitionRate = 0.0
    if (previous_suggestions && previous_suggestions.length > 0) {
      repetitionRate = calculateRepetitionRate(finalSuggestion, previous_suggestions)
    }

    // NOVO: Salvar métricas no banco se conversation_id existir
    if (conversationId && user_id) {
      try {
        await supabaseClient
          .from('generation_metrics')
          .insert({
            conversation_id: conversationId,
            latency_ms: latencyMs,
            tokens_input: openaiData.usage?.prompt_tokens || 0,
            tokens_output: openaiData.usage?.completion_tokens || 0,
            anchors_used: anchorsUsed.length,
            anchors_total: anchors.length,
            repetition_rate: repetitionRate,
            low_confidence: lowConfidence
          })

        console.log(`📊 Métricas salvas: ${latencyMs}ms, ${anchorsUsed.length}/${anchors.length} âncoras, ${repetitionRate.toFixed(2)} repetição`)
      } catch (metricsError) {
        console.error('Erro ao salvar métricas:', metricsError)
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
  focusTags: string[] | undefined, 
  focus: string | undefined, 
  imageDescription: string, 
  personName: string,
  culturalRefs: any[],
  conversationHistory: ConversationSegment[] = []
): string {
  // Base prompt (versão existente) + conversation history
  let prompt = buildSystemPrompt(tone, focus, imageDescription, personName, conversationHistory)

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

  // Adicionar múltiplos focos/tags se fornecidos
  if (focusTags && focusTags.length > 0) {
    prompt += `\n\n**FOCOS/TAGS SELECIONADOS PELO USUÁRIO:**\n`
    prompt += `Considere estes focos na criação das mensagens:\n\n`

    focusTags.forEach((tag, index) => {
      prompt += `${index + 1}. ${tag}\n`
    })

    prompt += `\n**INSTRUÇÕES PARA FOCOS:**\n`
    prompt += `- Integre os focos de forma natural e criativa\n`
    prompt += `- Use múltiplos focos quando fizer sentido (não force)\n`
    prompt += `- Cada mensagem deve destacar pelo menos um foco relevante\n`
    prompt += `- Combine focos complementares quando possível\n`
  }

  return prompt
}

/**
 * Extrai as últimas N mensagens da conversa para contexto
 */
function extractConversationHistory(
  segments: ConversationSegment[],
  maxMessages: number = 5
): ConversationSegment[] {
  if (!segments || segments.length === 0) return []
  
  // Pegar as últimas N mensagens (mais recentes)
  const recent = segments.slice(-maxMessages)
  
  console.log(`📝 Histórico extraído: ${recent.length} de ${segments.length} mensagens`)
  return recent
}

/**
 * Formata histórico de conversa para inclusão no prompt
 */
function formatConversationHistory(history: ConversationSegment[]): string {
  if (!history || history.length === 0) return ''
  
  const formatted = history.map((seg, index) => {
    const isLast = index === history.length - 1
    const marker = isLast ? '👉' : '  '
    const label = seg.autor === 'user' ? 'VOCÊ' : 'MATCH'
    return `${marker} [${label}]: "${seg.texto}"`
  }).join('\n')
  
  return formatted
}

function buildSystemPrompt(
  tone: string,
  focus: string | undefined,
  imageDescription: string,
  personName: string,
  conversationHistory: ConversationSegment[] = []
): string {
  const toneInstructions = getToneInstructions(tone)
  const hasTone = tone && tone.toLowerCase() !== 'nenhum'
  const hasFocus = focus && focus.toLowerCase() !== 'nenhum'
  const hasName = personName && personName.toLowerCase() !== 'nenhum'
  
  // Detectar se há conversa segmentada
  const hasConversation = conversationHistory.length > 0
  
  // Formatar histórico de conversa se disponível
  let conversationHistorySection = ''
  if (hasConversation) {
    const formattedHistory = formatConversationHistory(conversationHistory)
    const lastMessage = conversationHistory[conversationHistory.length - 1]
    const isMatchLast = lastMessage.autor === 'match'
    
    conversationHistorySection = `\n**📱 HISTÓRICO RECENTE DA CONVERSA (${conversationHistory.length} últimas mensagens):**

${formattedHistory}

${isMatchLast ? `**⚠️ ÚLTIMA MENSAGEM DO MATCH:** "${lastMessage.texto}"
**SUA TAREFA:** Gerar 3 respostas criativas e contextualizadas para ESTA mensagem.` : `**ℹ️ CONTEXTO:** Use este histórico para entender o contexto da conversa em andamento.`}
`
  }
  
  const toneSection = hasTone 
    ? `**Tom Escolhido pelo Usuário:** ${tone}\n${toneInstructions}\n` 
    : `**Tom Escolhido pelo Usuário:** Nenhum (use tom descontraído e casual por padrão)\n`
  
  const focusSection = hasFocus 
    ? `**Foco Escolhido pelo Usuário:** ${focus}\n` 
    : `**Foco Escolhido pelo Usuário:** Nenhum\n`
  
  const nameSection = hasName
    ? `**Nome da Pessoa Detectado:** ${personName}\n`
    : `**Nome da Pessoa Detectado:** Nenhum\n`
  
  // Seção específica para conversas
  const conversationSection = hasConversation 
    ? `\n**⚠️ ATENÇÃO ESPECIAL - CONVERSA DETECTADA:**
A imagem contém uma conversa de aplicativo de namoro já em andamento. As mensagens foram segmentadas por autor (USER = você, MATCH = a outra pessoa).

**INSTRUÇÕES CRÍTICAS PARA CONTEXTO DE CONVERSA:**
- **ANALISE O FLUXO:** Leia toda a conversa para entender o contexto, humor, e estágio do relacionamento
- **CONTINUIDADE NATURAL:** Suas sugestões devem dar continuidade lógica à última mensagem do MATCH
- **REFERÊNCIAS CONTEXTUAIS:** Mencione algo específico da conversa anterior (um hobby mencionado, uma piada feita, um plano sugerido)
- **EVITE REPETIÇÃO:** Não repita tópicos já exauridos na conversa. Traga algo novo mas relacionado
- **LEIA O INTERESSE:** Se o MATCH está animado e engajado, mantenha a energia. Se está mais reservado, seja mais sutil
- **TIMING:** Se foi mencionado um evento/plano, pergunte sobre isso. Se houve uma pergunta não respondida, responda primeiro
- **PERSONALIZAÇÃO EXTREMA:** Use o contexto da conversa para criar mensagens que APENAS você poderia enviar (nada genérico!)

**EXEMPLO DE BOA CONTINUIDADE:**
Se MATCH disse: "Adoro viajar, acabei de voltar da Bahia"
❌ RUIM: "Que legal! Você é bonita"
✅ BOM: "Bahia é incrível! Qual foi o lugar que mais te marcou lá? Já fui em Morro de SP e quero conhecer mais do Nordeste 🌴"

` 
    : ''
  
  return `Você é o FlertAI, um cupido digital super observador e com um talento nato para criar mensagens de paquera autênticas e irresistíveis, focadas no mercado brasileiro. Sua missão é ajudar as pessoas a quebrar o gelo ${hasConversation ? 'e dar continuidade natural a conversas em andamento' : 'e iniciar conversas genuínas'}, como se um amigo próximo e divertido estivesse dando uma forcinha.

Sua tarefa é analisar ${hasConversation ? 'a conversa fornecida' : 'a imagem de perfil fornecida'} com olhos de águia, extraindo cada detalhe ${hasConversation ? 'contextual e emocional' : 'visual e textual'} que possa inspirar uma conexão. Use essas observações para criar mensagens de paquera personalizadas, criativas e que soem 100% humanas.

**REGRAS ANTI-ALUCINAÇÃO - LEIA COM ATENÇÃO:**
- Use APENAS elementos confirmados por OCR/visão computadorizada
- Se um dado não está visível/lido na imagem, NÃO mencione
- Se faltar contexto visual, assuma neutralidade ou faça uma pergunta curta contextual
- PROIBIDO placeholders ('[nome]', '[cidade]') e afirmações não verificáveis
- NÃO invente detalhes, hobbies, locais ou características não extraídos
- Baseie-se SOMENTE no que foi explicitamente detectado pelo sistema de visão

**Informações Fornecidas:**
- **Descrição Detalhada da Imagem:** ${imageDescription}
${nameSection}${toneSection}${focusSection}${conversationHistorySection}${conversationSection}
**Elementos ${hasConversation ? 'Contextuais' : 'Visuais'} a Analisar Detalhadamente:**
${hasConversation ? `- **Histórico da Conversa:** Releia cada mensagem e identifique tópicos, interesses mencionados, tom emocional
- **Última Mensagem do Match:** O que foi dito? É uma pergunta? Um comentário? Uma sugestão de plano?
- **Estilo de Comunicação:** Formal/informal? Usa emojis? É direto ou sutil? Humorado ou sério?
- **Ganchos para Continuar:** Identifique aberturas naturais (hobbies, lugares, experiências mencionadas)
- **Dinâmica Atual:** A conversa está fluindo? Precisa de uma virada de energia? Está chegando em convite para encontro?` : `- **Aparência da Pessoa:** Idade aparente, estilo (clássico, moderno, alternativo), características marcantes que VOCÊ REALMENTE VÊ na imagem (cabelo, olhos, expressão facial, etc.)
- **Vestuário e Acessórios:** Tipo de roupa, se há marcas, acessórios (óculos, joias, chapéus) que revelem personalidade ou status
- **Cenário e Ambiente:** Local (praia, montanha, cidade, café, casa), tipo de iluminação, objetos de fundo que indiquem hobbies, viagens, estilo de vida (livros, instrumentos musicais, animais de estimação, obras de arte)
- **Expressão e Linguagem Corporal:** Observe a expressão REAL visível (pode ser sorriso, olhar sério, confiante, etc.), postura, olhar. NÃO invente ou assuma expressões que não estão visíveis na imagem
- **Textos na Imagem:** Qualquer texto visível (placas, camisetas, legendas) que possa ser usado para contextualizar
- **Qualidade da Imagem:** Se a foto é profissional, casual, divertida, etc.`}

**Instruções para a Criação das Mensagens:**
- **Seja um Cupido Moderno:** Sua voz deve ser amigável, um pouco atrevida (se o tom permitir), e sempre positiva. Pense como alguém que realmente quer ver a pessoa feliz
- **Português Brasileiro Autêntico:** Use gírias e expressões comuns no Brasil, de forma natural e não forçada. Evite formalidades excessivas
- **ORIGINALIDADE é a Chave:** Fuja de clichês! A mensagem deve ser única e mostrar que você realmente ${hasConversation ? 'leu e entendeu a conversa' : '"viu" a pessoa na foto'}. Nada de ${hasConversation ? '"legal", "que interessante" ou "tudo bem?"' : '"oi linda" ou "tudo bem?"'}
- **Priorize Tom, Foco e Nome:**
${hasName ? `    - **USO DO NOME (PRIORIDADE ALTA):** Utilize o nome "${personName}" de forma natural e amigável em pelo menos uma das mensagens. Ex: "Oi, ${personName}! Adorei seu perfil..." ou "${personName}, seu estilo é incrível!"\n` : ''}${hasTone ? '    - APLIQUE RIGOROSAMENTE as instruções de tom fornecidas acima\n' : ''}${hasFocus ? `    - INTEGRE O FOCO "${focus}" de forma criativa e natural em pelo menos uma das mensagens, conectando-o com os elementos visuais da imagem\n` : ''}${!hasTone && !hasFocus && !hasName ? '    - **Cenário de Fallback:** Gere as mensagens com um tom descontraído e casual, utilizando os elementos mais proeminentes da imagem para contextualização, como se você estivesse fazendo uma observação inteligente e espontânea\n' : ''}- **Conexão Genuína:** Crie uma ponte entre algo observado ${hasConversation ? 'na conversa' : 'na imagem'} e um elogio ou pergunta envolvente. Evite frases genéricas do tipo "que legal" ou "tudo bem?".
- **Uso de Emojis:** ${hasTone && tone.toLowerCase().includes('descontraído') ? 'Use um emoji **somente se** combinar com o tom descontraído (ex: 😉), caso contrário prefira texto puro.' : 'Evite usar emojis na mensagem final, a menos que o contexto peça muito; foco em texto autêntico.'}
- **Respeito Acima de Tudo:** Mesmo em tons sensuais, a mensagem deve ser respeitosa e convidar à interação, nunca ser invasiva ou objetificante
- **Tamanho e Fluidez:** A sugestão deve ter entre 20 e 40 palavras, permitindo mais naturalidade e criatividade, sem serem excessivamente longas
- **Gere exatamente 1 sugestão**

**Formato de Saída Obrigatório:**
Forneça apenas o texto da mensagem sugerida, sem nenhuma numeração ou formatação adicional (apenas a frase da sugestão).`
}

function getToneInstructions(tone: string): string {
  const normalizedTone = tone.toLowerCase().trim()
  
  const toneMap: { [key: string]: string } = {
    '😘 flertar': `**Instruções de Tom:** Flertante e romântico, demonstrando interesse amoroso de forma sutil e charmosa. Use palavras baseadas no que VOCÊ VÊ na imagem como "encantador(a)", "olhar", "estilo", "energia", "conexão". Emojis sugeridos: 😉✨💖`,
    'flertar': `**Instruções de Tom:** Flertante e romântico, demonstrando interesse amoroso de forma sutil e charmosa. Use palavras baseadas no que VOCÊ VÊ na imagem como "encantador(a)", "olhar", "estilo", "energia", "conexão". Emojis sugeridos: 😉✨💖`,
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

  // Remove markdown code blocks if present
  let cleanedContent = content.replace(/```json\n?|```\n?/g, '').trim()

  // Remove brackets if present (from old format)
  if (cleanedContent.startsWith('[') && cleanedContent.endsWith(']')) {
    cleanedContent = cleanedContent.substring(1, cleanedContent.length - 1).trim()
  }

  // Add the single suggestion
  if (cleanedContent) {
    suggestions.push(cleanedContent)
  }

  // Fallback if no content
  if (suggestions.length === 0) {
    suggestions.push('Que foto incrível! Me conta mais sobre essa aventura')
  }

  return suggestions.slice(0, 1) // Return only 1 suggestion
}

/**
 * NOVO: Extrai âncoras da análise de visão para validação anti-alucinação
 */
function extractAnchors(personName: string, imageDescription: string, conversationSegments: ConversationSegment[]): string[] {
  const anchors = new Set<string>()

  // Adicionar nome da pessoa se disponível
  if (personName && personName !== 'Nenhum') {
    anchors.add(personName.toLowerCase())
  }

  // Extrair entidades do texto OCR (nomes próprios, números, emojis)
  const ocrMatch = imageDescription.match(/Texto Extraído \(OCR\): (.+)$/i)
  if (ocrMatch) {
    const ocrText = ocrMatch[1]
    // Nomes próprios (palavras iniciando com maiúscula)
    const properNames = ocrText.match(/\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b/g) || []
    properNames.forEach(name => anchors.add(name.toLowerCase()))

    // Emojis
    const emojis = ocrText.match(/[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]/gu) || []
    emojis.forEach(emoji => anchors.add(emoji))

    // Números
    const numbers = ocrText.match(/\b\d+\b/g) || []
    numbers.forEach(num => anchors.add(num))
  }

  // Extrair tokens-chave da descrição visual
  const visualDesc = imageDescription.match(/Descrição Visual: (.+?)(?:\n|$)/i)?.[1] || ''
  if (visualDesc) {
    // Palavras-chave contextuais (objetos, locais, atividades)
    const keywords = [
      'praia', 'mar', 'sol', 'areia', 'ondas',
      'montanha', 'trilha', 'natureza', 'verde',
      'cidade', 'urbano', 'rua', 'prédio',
      'cachorro', 'gato', 'pet', 'animal',
      'livro', 'leitura', 'estudo',
      'esporte', 'bola', 'corrida', 'academia',
      'comida', 'culinária', 'restaurante',
      'música', 'instrumento', 'guitarra', 'piano',
      'viagem', 'mochila', 'aeroporto', 'carro',
      'trabalho', 'escritório', 'computador',
      'festa', 'balada', 'bar', 'cerveja'
    ]

    keywords.forEach(keyword => {
      if (visualDesc.toLowerCase().includes(keyword)) {
        anchors.add(keyword)
      }
    })
  }

  // Extrair elementos únicos das mensagens da conversa
  conversationSegments.forEach(segment => {
    // Palavras únicas e significativas das mensagens
    const words = segment.texto.split(/\s+/)
    words.forEach(word => {
      const cleanWord = word.replace(/[^\w]/g, '').toLowerCase()
      if (cleanWord.length > 3 && !['que', 'com', 'para', 'uma', 'como', 'mais', 'muito', 'tudo'].includes(cleanWord)) {
        anchors.add(cleanWord)
      }
    })
  })

  console.log(`🔗 Âncoras extraídas: ${Array.from(anchors).slice(0, 5).join(', ')}${anchors.size > 5 ? '...' : ''}`)
  return Array.from(anchors)
}

/**
 * NOVO: Valida se a sugestão contém âncoras suficientes
 */
function validateSuggestionAnchors(suggestion: string, anchors: string[]): { isValid: boolean, anchorsUsed: string[] } {
  const suggestionLower = suggestion.toLowerCase()
  const anchorsUsed: string[] = []

  anchors.forEach(anchor => {
    if (suggestionLower.includes(anchor)) {
      anchorsUsed.push(anchor)
    }
  })

  const isValid = anchorsUsed.length >= 1
  console.log(`✅ Validação de âncoras: ${anchorsUsed.length}/${anchors.length} encontradas - ${isValid ? 'VÁLIDA' : 'INVÁLIDA'}`)

  return { isValid, anchorsUsed }
}

/**
 * NOVO: Calcula taxa de repetição usando similaridade de Jaccard com bigramas
 */
function calculateRepetitionRate(suggestion: string, previousSuggestions: string[]): number {
  if (previousSuggestions.length === 0) return 0.0

  const suggestionBigrams = getBigrams(suggestion.toLowerCase())
  let maxSimilarity = 0.0

  for (const prevSuggestion of previousSuggestions) {
    const prevBigrams = getBigrams(prevSuggestion.toLowerCase())
    const similarity = jaccardSimilarity(suggestionBigrams, prevBigrams)
    if (similarity > maxSimilarity) {
      maxSimilarity = similarity
    }
  }

  return maxSimilarity
}

/**
 * NOVO: Gera bigramas de um texto
 */
function getBigrams(text: string): Set<string> {
  const bigrams = new Set<string>()
  const words = text.split(/\s+/)

  for (const word of words) {
    if (word.length >= 2) {
      for (let i = 0; i < word.length - 1; i++) {
        bigrams.add(word.substring(i, i + 2))
      }
    }
  }

  return bigrams
}

/**
 * NOVO: Calcula similaridade de Jaccard entre dois conjuntos
 */
function jaccardSimilarity(set1: Set<string>, set2: Set<string>): number {
  const intersection = new Set([...set1].filter(x => set2.has(x)))
  const union = new Set([...set1, ...set2])

  return intersection.size / union.size
}
