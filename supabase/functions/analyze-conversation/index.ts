import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

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

    // Build system prompt
    const systemPrompt = buildSystemPrompt(tone, focus)

    // Prepare messages for OpenAI
    const messages: OpenAIMessage[] = [
      {
        role: 'system',
        content: systemPrompt
      }
    ]

    // Add image analysis if image is provided
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
        const content: any[] = [
          {
            type: 'text',
            text: 'Analise detalhadamente a imagem do perfil. Foque nos seguintes elementos visuais: aparência física da pessoa, roupas/estilo, cenário/ambiente, expressão facial, atividades ou objetos visíveis, e qualquer elemento que possa indicar personalidade ou interesses. Use essas informações para criar mensagens contextuais e personalizadas.'
          },
          { type: 'image_url', image_url: { url: imageUrl, detail: 'high' } }
        ]
        
        if (text && text.trim().length > 0) {
          content.unshift({ type: 'text', text: `Contexto adicional de texto/bio: ${text}` })
        }
        
        messages.push({ role: 'user', content })
      } else {
        // Sem URL válida da imagem: fallback para modo texto
        const t = text && text.trim().length > 0 ? `Contexto de texto/bio: ${text}\n` : ''
        messages.push({ role: 'user', content: `${t}Gere 3 sugestões de mensagens criativas e envolventes seguindo as instruções do sistema.` })
      }
    } else {
      // Text-only analysis
      const t = text && text.trim().length > 0 ? `Contexto de texto/bio: ${text}\n` : ''
      messages.push({ role: 'user', content: `${t}Gere 3 sugestões de mensagens criativas e envolventes seguindo as instruções do sistema.` })
    }

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

function buildSystemPrompt(tone: string, focus?: string): string {
  const toneInstructions = getToneInstructions(tone)
  const hasTone = tone && tone.toLowerCase() !== 'nenhum'
  const hasFocus = focus && focus.toLowerCase() !== 'nenhum'
  
  const toneSection = hasTone 
    ? `**Tom Escolhido pelo Usuário:** ${tone}\n${toneInstructions}\n` 
    : `**Tom Escolhido pelo Usuário:** Nenhum (use tom descontraído e casual por padrão)\n`
  
  const focusSection = hasFocus 
    ? `**Foco Escolhido pelo Usuário:** ${focus}\n` 
    : `**Foco Escolhido pelo Usuário:** Nenhum\n`
  
  return `Você é o FlertAI, um cupido digital super observador e com um talento nato para criar mensagens de paquera autênticas e irresistíveis, focadas no mercado brasileiro. Sua missão é ajudar as pessoas a quebrar o gelo e iniciar conversas genuínas, como se um amigo próximo e divertido estivesse dando uma forcinha.

Sua tarefa é analisar a imagem de perfil fornecida com olhos de águia, extraindo cada detalhe visual e textual que possa inspirar uma conexão. Use essas observações para criar mensagens de paquera personalizadas, criativas e que soem 100% humanas.

**Informações Fornecidas:**
${toneSection}${focusSection}
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
- **Priorize Tom e Foco:**
${hasTone ? '    - APLIQUE RIGOROSAMENTE as instruções de tom fornecidas acima\n' : ''}${hasFocus ? `    - INTEGRE O FOCO "${focus}" de forma criativa e natural em pelo menos uma das mensagens, conectando-o com os elementos visuais da imagem\n` : ''}${!hasTone && !hasFocus ? '    - **Cenário de Fallback:** Gere as mensagens com um tom descontraído e casual, utilizando os elementos mais proeminentes da imagem para contextualização, como se você estivesse fazendo uma observação inteligente e espontânea\n' : ''}- **Conexão Genuína:** A mensagem deve criar uma ponte entre o que você observou na imagem e um possível interesse ou elogio. Se a pessoa está na praia, não diga apenas "gostei da praia", mas "Essa praia parece incrível! Me deu uma vontade de te chamar pra um mergulho por lá... 😉"
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
