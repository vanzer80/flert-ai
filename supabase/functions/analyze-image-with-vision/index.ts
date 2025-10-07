import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const startTime = Date.now()
    console.log('🚀 Iniciando análise de imagem com GPT-4 Vision...')

    // Parse request
    const { image, tone } = await req.json()
    
    if (!image) {
      throw new Error('Imagem não fornecida')
    }

    console.log('📸 Imagem recebida, tamanho:', image.length, 'caracteres')
    console.log('🎨 Tom selecionado:', tone)

    // Get OpenAI API key
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OPENAI_API_KEY não configurada')
    }

    console.log('🔑 OpenAI API Key configurada:', openaiApiKey.substring(0, 10) + '...')

    // 1. Analisar imagem com GPT-4 Vision
    console.log('🤖 Chamando GPT-4 Vision API...')
    const visionAnalysis = await analyzeImageWithGPT4Vision(image, openaiApiKey)
    console.log('✅ Análise visual concluída. Tamanho:', visionAnalysis.length, 'caracteres')
    console.log('📝 Primeiros 300 caracteres:', visionAnalysis.substring(0, 300))

    // Validar qualidade da análise (menos restritivo)
    if (visionAnalysis.length < 50) {
      console.warn('⚠️ ALERTA: Análise muito curta!')
      throw new Error('Análise inválida - resposta muito curta')
    }

    // 2. Extrair âncoras da análise
    const anchors = extractAnchorsFromAnalysis(visionAnalysis)
    console.log('🎯 Âncoras extraídas:', anchors)

    if (anchors.length === 0 || (anchors.length === 1 && anchors[0] === 'pessoa')) {
      console.warn('⚠️ ALERTA: Âncoras muito genéricas!')
    }

    // 3. Gerar mensagem contextual baseada na análise
    console.log('💬 Gerando mensagem contextual...')
    const message = await generateContextualMessage(visionAnalysis, anchors, tone, openaiApiKey)
    console.log('✅ Mensagem gerada:', message)

    const processingTime = Date.now() - startTime
    console.log(`⏱️ Tempo total de processamento: ${processingTime}ms`)

    // Return result
    return new Response(
      JSON.stringify({
        success: true,
        suggestion: message,
        anchors: anchors,
        visionAnalysis: visionAnalysis,
        processingTime: processingTime,
        confidence: 0.92,
        anchorCount: anchors.length,
        debug: {
          analysisLength: visionAnalysis.length,
          anchorCount: anchors.length,
          modelUsed: 'gpt-4o-mini'
        }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('❌ Erro completo:', error)
    console.error('❌ Stack trace:', error.stack)
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        errorStack: error.stack,
        suggestion: 'Que foto interessante! Me conta mais sobre você?',
        anchors: ['foto', 'momento'],
        visionAnalysis: 'Erro ao analisar imagem. Por favor, tente novamente.',
        processingTime: 0,
        confidence: 0.5,
        anchorCount: 2
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200, // Return 200 even on error to show fallback
      }
    )
  }
})

/**
 * Analisa imagem usando GPT-4 Vision com fallback inteligente
 */
async function analyzeImageWithGPT4Vision(imageBase64: string, apiKey: string): Promise<string> {
  console.log('📡 Iniciando análise de imagem com IA...')
  
  // Lista de modelos para tentar com diferentes estratégias
  const models = [
    { name: 'gpt-4o-mini', supportsVision: true, detail: 'high', maxTokens: 800 },
    { name: 'gpt-4o-mini', supportsVision: true, detail: 'low', maxTokens: 600 },
    { name: 'gpt-4o', supportsVision: true, detail: 'high', maxTokens: 1000 },
    { name: 'gpt-4-turbo', supportsVision: true, detail: 'high', maxTokens: 800 }
  ]

  let lastError = null

  // Tentar cada modelo até um funcionar
  for (const model of models) {
    try {
      console.log(`🔄 Tentando modelo: ${model.name}`)
      
      if (model.supportsVision) {
        // Modelos com suporte a visão
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`
          },
          body: JSON.stringify({
            model: model.name,
            messages: [
              {
                role: 'system',
                content: `Você é um SUPER ANALISTA ESPECIALIZADO em descrever imagens para apps de namoro.

SUA MISSÃO:
- Analisar MINUCIOSAMENTE cada detalhe da imagem
- Descrever EXATAMENTE o que vê, sem inventar
- Ser ESPECÍFICO e DETALHADO em cada aspecto
- Identificar elementos que tornam a foto única

VOCÊ É EXPERT EM:
- Identificar pessoas, animais, objetos
- Descrever ambientes e cenários
- Captar emoções e expressões
- Notar detalhes de vestimenta e acessórios
- Reconhecer cores, padrões e texturas
- Entender o contexto e atmosfera da foto`
              },
              {
                role: 'user',
                content: [
                  {
                    type: 'text',
                    text: `Analise esta imagem como um SUPER ANALISTA e descreva MINUCIOSAMENTE:

👥 PESSOAS/ANIMAIS (se houver):
   - Quantas pessoas/animais
   - Características físicas visíveis
   - Expressões faciais e linguagem corporal
   - Cabelo: cor, estilo, comprimento
   - Roupa: tipo, cor, estilo
   - Acessórios: óculos, joias, chapéus, etc

🏙️ AMBIENTE:
   - Tipo de local (casa, rua, praia, carro, etc)
   - Interno ou externo
   - Iluminação (natural, artificial, dia, noite)
   - Objetos e móveis visíveis
   - Decoração e elementos ao fundo

🎨 CORES E ESTÉTICA:
   - Cores predominantes
   - Padrões e estampas
   - Estilo geral da foto
   - Qualidade da imagem

🎭 CONTEXTO E ATMOSFERA:
   - O que está acontecendo na foto
   - Atividade sendo realizada
   - Clima/vibe da imagem
   - Elementos que chamam atenção

⚡ DETALHES ESPECIAIS:
   - Qualquer coisa única ou interessante
   - Elementos que contam uma história
   - Aspectos que tornam a foto memorável

EXEMPLO DE ANÁLISE BOA:
"A imagem mostra um gato cinza de pelagem uniforme deitado confortavelmente em uma cadeira estilo mid-century com estofado rosa claro. O gato tem olhos verdes e está em posição relaxada. Sobre a cadeira há um cobertor infantil colorido com estampa de dinossauros em tons de verde, laranja e azul. Ao fundo, vê-se uma mesa branca com uma almofada personalizada escrita 'Mãe', um porta-pinceis vermelho e alguns objetos decorativos. O ambiente é interno, bem iluminado com luz natural, com piso de cerâmica bege. A atmosfera é aconchegante e caseira."

AGORA ANALISE ESTA IMAGEM COM O MESMO NÍVEL DE DETALHE:`
                  },
                  {
                    type: 'image_url',
                    image_url: {
                      url: `data:image/jpeg;base64,${imageBase64}`,
                      detail: model.detail
                    }
                  }
                ]
              }
            ],
            max_tokens: model.maxTokens,
            temperature: 0.4
          })
        })

        if (response.ok) {
          const data = await response.json()
          const analysis = data.choices[0].message.content
          console.log(`✅ Análise bem-sucedida com ${model.name}:`, analysis)
          
          // Validar qualidade da análise
          if (analysis.length > 80 && 
              !analysis.includes('não consigo') && 
              !analysis.includes('não posso') &&
              !analysis.includes('desculpe')) {
            console.log(`✅ Análise válida de ${model.name}`)
            return analysis
          } else {
            console.warn(`⚠️ Análise insuficiente de ${model.name} (${analysis.length} chars), tentando próximo`)
            continue
          }
        }

        const errorData = await response.json()
        lastError = errorData.error?.message || 'Unknown error'
        console.warn(`⚠️ Modelo ${model.name} falhou:`, lastError)
      }

    } catch (error) {
      console.error(`❌ Erro ao tentar ${model.name}:`, error)
      lastError = error.message
      continue
    }
  }

  // Se todos os modelos falharam, lançar erro para tentar fallback
  console.error('❌ Todos os modelos falharam.')
  console.error('❌ Último erro:', lastError)
  throw new Error(`Todos os modelos de visão falharam: ${lastError}`)
}

/**
 * Extrai âncoras (palavras-chave) da análise visual
 */
function extractAnchorsFromAnalysis(analysis: string): string[] {
  console.log('🔍 Extraindo âncoras da análise...')
  console.log('📝 Análise recebida:', analysis.substring(0, 300))
  
  const keywords: string[] = []
  
  // Lista expandida de palavras relevantes
  const relevantWords = [
    // Animais
    'cachorro', 'gato', 'pet', 'animal', 'felino', 'canino',
    // Pessoas
    'mulher', 'homem', 'pessoa', 'sorriso', 'sorrindo', 'feliz', 'alegre',
    // Lugares
    'praia', 'mar', 'parque', 'cidade', 'montanha', 'casa', 'quarto', 'carro', 'veículo',
    // Objetos
    'guitarra', 'violão', 'livro', 'café', 'bicicleta', 'moto', 'bola', 'óculos',
    'cadeira', 'sofá', 'mesa', 'cobertor', 'almofada', 'quadro',
    // Cores
    'rosa', 'azul', 'verde', 'vermelho', 'amarelo', 'cinza', 'branco', 'preto',
    // Padrões
    'dinossauro', 'flor', 'listrado', 'estampado',
    // Atividades
    'tocando', 'lendo', 'correndo', 'caminhando', 'jogando', 'cozinhando', 'deitado', 'relaxando',
    // Ambientes
    'sol', 'céu', 'árvore', 'flores', 'água', 'areia', 'grama', 'interno', 'externo',
    // Emoções
    'felicidade', 'alegria', 'tranquilidade', 'energia', 'calmo', 'relaxado'
  ]
  
  const lowerAnalysis = analysis.toLowerCase()
  
  // Extrair palavras relevantes
  for (const word of relevantWords) {
    if (lowerAnalysis.includes(word)) {
      keywords.push(word)
    }
  }
  
  console.log('🎯 Palavras-chave encontradas:', keywords)
  
  // Se não encontrou palavras específicas, extrair substantivos importantes
  if (keywords.length < 2) {
    console.warn('⚠️ Poucas âncoras encontradas, extraindo substantivos...')
    
    // Extrair palavras maiores que 4 letras que não sejam comuns
    const commonWords = ['está', 'essa', 'esse', 'para', 'com', 'uma', 'foto', 'imagem', 'perfil', 'mostrando']
    const words = analysis.toLowerCase()
      .replace(/[.,!?;:()]/g, '')
      .split(/\s+/)
      .filter(w => w.length > 4 && !commonWords.includes(w))
      .slice(0, 8)
    
    console.log('📚 Substantivos extraídos:', words)
    keywords.push(...words)
  }
  
  // Remover duplicatas e limitar
  const uniqueKeywords = [...new Set(keywords)].slice(0, 6)
  
  console.log('✅ Âncoras finais:', uniqueKeywords)
  return uniqueKeywords.length > 0 ? uniqueKeywords : ['foto', 'momento']
}

/**
 * Gera mensagem contextual usando GPT-4 baseado na análise visual
 */
async function generateContextualMessage(
  visionAnalysis: string,
  anchors: string[],
  tone: string,
  apiKey: string
): Promise<string> {
  console.log('💬 Gerando mensagem contextual...')
  
  const toneInstructions = {
    'descontraído': 'Tom leve, natural e espontâneo. Como um amigo puxando papo.',
    'flertar': 'Tom sedutor mas respeitoso. Charmoso e interessado romanticamente.',
    'amigável': 'Tom acolhedor e gentil. Interessado genuinamente na pessoa.',
    'profissional': 'Tom respeitoso e admirador. Educado e intelectual.'
  }
  
  const instruction = toneInstructions[tone as keyof typeof toneInstructions] || toneInstructions['descontraído']
  
  // Tentar gpt-4o-mini primeiro (mais acessível)
  const models = ['gpt-4o-mini', 'gpt-4o', 'gpt-4-turbo']
  
  for (const model of models) {
    try {
      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({
          model: model,
          messages: [
            {
              role: 'system',
              content: `Você é um especialista em criar mensagens de abertura para apps de namoro brasileiros.

REGRAS IMPORTANTES:
1. Use APENAS informações da análise visual fornecida
2. Seja ESPECÍFICO sobre o que viu na foto
3. Máximo 2 frases curtas
4. SEMPRE termine com uma pergunta
5. ${instruction}
6. Use português brasileiro natural
7. NÃO invente informações que não estão na análise`
            },
            {
              role: 'user',
              content: `ANÁLISE DA FOTO:
${visionAnalysis}

ELEMENTOS PRINCIPAIS: ${anchors.slice(0, 3).join(', ')}

TOM: ${tone}

Crie UMA mensagem de abertura que mencione algo ESPECÍFICO que você viu na análise acima:`
            }
          ],
          max_tokens: 100,
          temperature: 0.7
        })
      })

      if (response.ok) {
        const data = await response.json()
        const message = data.choices[0].message.content.trim()
        console.log(`✅ Mensagem gerada com ${model}:`, message)
        return message
      }
      
      console.warn(`⚠️ Modelo ${model} falhou, tentando próximo...`)
    } catch (error) {
      console.error(`❌ Erro com ${model}:`, error)
      continue
    }
  }
  
  // Fallback se todos falharem
  return `Adorei sua foto! Você parece ser uma pessoa muito interessante. Me conta mais sobre você?`
}
