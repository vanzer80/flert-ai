// supabase/functions/analyze-conversation/index.ts
// Edge Function com persistência de contexto e métricas - VERSÃO OTIMIZADA

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { extractVisionContext, VisionContext } from '../_shared/vision/extractor.ts';
import { computeAnchors, Anchor } from '../_shared/vision/anchors.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// Cliente admin para acessar cultural_references (Service Role Key)
const supabaseAdmin = createClient(
  Deno.env.get('URL_SUPABASE') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

// Cliente regular para operações do usuário
const supabaseClient = createClient(
  Deno.env.get('URL_SUPABASE') ?? '',
  Deno.env.get('SUPABASE_ANON_KEY') ?? ''
)

// Types para OpenAI
interface OpenAIMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}

interface ConversationSegment {
  autor: string
  texto: string
}

serve(async (req) => {
  const startTime = Date.now()

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const {
      image_base64,
      image_path,
      user_id,
      tone = 'nenhum',
      focus = 'nenhum',
      focus_tags,
      text,
      personalized_instructions,
      conversation_id, // NOVO: Para "Gerar mais" com contexto existente
      skip_vision = false // NOVO: Para "Gerar mais" sem re-analisar imagem
    } = await req.json()

    // Validar parâmetros obrigatórios
    if (!user_id) {
      return new Response(
        JSON.stringify({ error: 'user_id é obrigatório' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!image_base64 && !image_path && !conversation_id) {
      return new Response(
        JSON.stringify({ error: 'image_base64, image_path ou conversation_id é obrigatório' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // NOVO: Buscar contexto existente se for "Gerar mais"
    let existingConversation = null
    let existingVisionContext: VisionContext | null = null
    let existingAnchors: string[] = []
    let existingExhaustedAnchors: string[] = []
    let previousSuggestions: string[] = []

    if (conversation_id) {
      console.log(`🔄 Buscando contexto existente da conversa ${conversation_id}...`)

      const { data: conversation, error: convError } = await supabaseClient
        .from('conversations')
        .select('analysis_result, exhausted_anchors')
        .eq('id', conversation_id)
        .single()

      if (convError) {
        console.error('Erro ao buscar conversa existente:', convError)
      } else if (conversation) {
        existingConversation = conversation

        // Recuperar contexto de visão
        if (conversation.analysis_result?.vision_context) {
          existingVisionContext = conversation.analysis_result.vision_context
          console.log('✅ Contexto de visão recuperado')
        }

        // Recuperar âncoras
        if (conversation.analysis_result?.anchors) {
          existingAnchors = conversation.analysis_result.anchors
          console.log(`✅ Âncoras recuperadas: ${existingAnchors.length}`)
        }

        // Recuperar âncoras exauridas
        if (conversation.exhausted_anchors) {
          existingExhaustedAnchors = conversation.exhausted_anchors
          console.log(`✅ Âncoras exauridas recuperadas: ${existingExhaustedAnchors.length}`)
        }

        // Buscar sugestões anteriores
        const { data: suggestions, error: sugError } = await supabaseClient
          .from('suggestions')
          .select('suggestion_text')
          .eq('conversation_id', conversation_id)
          .order('created_at', { ascending: false })
          .limit(5)

        if (!sugError && suggestions) {
          previousSuggestions = suggestions.map(s => s.suggestion_text)
          console.log(`✅ Sugestões anteriores recuperadas: ${previousSuggestions.length}`)
        }
      }
    }

    // NOVO: Usar contexto existente ou extrair novo
    let visionResult = null
    let visionContextForAnchors: VisionContext | null = existingVisionContext

    if (!skip_vision && (image_base64 || image_path)) {
      // Análise de visão fresca
      console.log('🔍 Realizando nova análise de visão...')
      visionResult = await extractVisionContext(image_base64, image_path)

      if (visionResult.success && visionResult.data) {
        visionContextForAnchors = visionResult.data
      }
    } else if (existingVisionContext) {
      // Usar contexto existente para "Gerar mais"
      console.log('🔄 Usando contexto existente para geração adicional')
      visionResult = { success: true, data: existingVisionContext }
    }

    // Computar âncoras (novas ou existentes)
    const anchorList = visionContextForAnchors ? computeAnchors(visionContextForAnchors) : []
    const currentAnchors = anchorList.length > 0 ? anchorList.map(a => a.token) : existingAnchors

    // Mesclar âncoras exauridas existentes com novas
    const exhaustedAnchorsSet = new Set([...existingExhaustedAnchors])

    // Preparar variáveis para análise
    let personName = 'Nenhum'
    let imageDescription = 'Imagem não analisada'
    let conversationSegments: ConversationSegment[] = []

    if (visionResult && visionResult.success && visionResult.data) {
      personName = visionResult.data.detected_persons?.name || 'Nenhum'
      imageDescription = visionResult.data.description || 'Imagem não analisada'

      // Extrair segmentos de conversa se houver
      if (visionResult.data.conversation_segments) {
        conversationSegments = visionResult.data.conversation_segments
      }
    }

    // Add additional text context if provided
    if (text && text.trim().length > 0) {
      imageDescription += `\n\nContexto adicional de texto/bio: ${text}`
    }

    // NEW: Buscar referências culturais brasileiras
    const region = await getUserRegion(user_id)
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
    if (previousSuggestions && previousSuggestions.length > 0) {
      systemPrompt += `\n\n**⚠️ ATENÇÃO - EVITE REPETIÇÃO:**

Você JÁ gerou estas sugestões anteriormente:
${previousSuggestions.map((s, i) => `${i + 1}. ${s}`).join('\n')}

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
        'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
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

    if (currentAnchors.length > 0) {
      const validation = validateSuggestionAnchors(finalSuggestion, currentAnchors)
      anchorsUsed = validation.anchorsUsed

      // Se a sugestão não usa âncoras suficientes, tentar regenerar uma vez
      if (!validation.isValid) {
        console.log('⚠️ Sugestão inicial sem âncoras suficientes, tentando regenerar...')

        // Adicionar instrução específica para usar âncoras
        const reinforcedSystemPrompt = systemPrompt + `\n\n**⚠️ INSTRUÇÃO CRÍTICA - REGENERAÇÃO:**
A sugestão anterior não usou elementos suficientes da imagem/conversa. Use pelo menos uma das seguintes âncoras específicas: ${currentAnchors.slice(0, 3).join(', ')}
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
              'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
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
              const regenValidation = validateSuggestionAnchors(regenSuggestions[0], currentAnchors)
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
    let conversationId = conversation_id
    if (user_id && !conversation_id) {
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
              suggestions: [finalSuggestion],
              conversation_segments: conversationSegments,
              has_conversation: conversationSegments.length > 0,
              vision_context: !skip_vision && (image_base64 || image_path) ? {
                personName,
                imageDescription,
                conversationSegments: conversationSegments
              } : null,
              anchors: currentAnchors,
              anchors_used: anchorsUsed,
              low_confidence: lowConfidence,
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

    // NOVO: Salvar métricas detalhadas se conversation_id existir
    if (conversationId && user_id) {
      try {
        const endTime = Date.now()
        const latencyMs = endTime - startTime

        // Calcular taxa de repetição com sugestões anteriores
        let repetitionRate = 0.0
        if (previousSuggestions && previousSuggestions.length > 0) {
          repetitionRate = calculateRepetitionRate(finalSuggestion, previousSuggestions)
        }

        // Buscar suggestion_id para métricas
        const { data: suggestionData } = await supabaseClient
          .from('suggestions')
          .select('id')
          .eq('conversation_id', conversationId)
          .eq('suggestion_text', finalSuggestion)
          .order('created_at', { ascending: false })
          .limit(1)
          .single()

        await supabaseClient
          .from('generation_metrics')
          .insert({
            conversation_id: conversationId,
            suggestion_id: suggestionData?.id || null,
            latency_ms: latencyMs,
            tokens_input: openaiData.usage?.prompt_tokens || 0,
            tokens_output: openaiData.usage?.completion_tokens || 0,
            anchors_used: anchorsUsed.length,
            anchors_total: currentAnchors.length,
            repetition_rate: repetitionRate,
            low_confidence: lowConfidence
          })

        console.log(`📊 Métricas salvas: ${latencyMs}ms, ${anchorsUsed.length}/${currentAnchors.length} âncoras, ${repetitionRate.toFixed(2)} repetição`)
      } catch (metricsError) {
        console.error('Erro ao salvar métricas:', metricsError)
      }
    }

    // Return successful response with conversation segments
    const response: any = {
      success: true,
      suggestions: [finalSuggestion],
      conversation_id: conversationId,
      tone,
      focus,
      focus_tags,
      conversation_segments: conversationSegments,
      conversation_history_used: conversationHistory,
      has_conversation: conversationSegments.length > 0,
      usage_info: {
        model_used: image_base64 || image_path ? 'gpt-4o' : 'gpt-4o-mini',
        tokens_used: openaiData.usage?.total_tokens || 0,
        vision_capabilities: skip_vision ? 'context_reuse_enabled' : 'fresh_vision_analysis'
      },
      // NOVO: Informações sobre validação de âncoras
      anchors_info: {
        total_anchors: currentAnchors.length,
        anchors_used: anchorsUsed.length,
        low_confidence: lowConfidence,
        exhausted_anchors: Array.from(exhaustedAnchorsSet)
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
