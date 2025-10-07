// src/vision/extractor.ts
// Extrator determinístico de contexto visual usando GPT-4o Vision

import { VisionContextSchema, validateVisionContext, formatValidationErrors } from './schema.ts';

export interface VisionInput {
  imageUrl?: string;
  imageBase64?: string;
  ocrTextRaw?: string;
}

export interface VisionContext {
  schema_version: string;
  detected_persons: {
    count: number;
  };
  objects: Array<{
    name: string;
    confidence: number;
    source: string;
  }>;
  actions: Array<{
    name: string;
    confidence: number;
    source: string;
  }>;
  places: Array<{
    name: string;
    confidence: number;
    source: string;
  }>;
  colors: string[];
  ocr_text: string;
  notable_details: string[];
  confidence_overall: number;
}

export interface VisionExtractorResult {
  success: boolean;
  data?: VisionContext;
  low_confidence?: boolean;
  error?: string;
  attempts: number;
}

/**
 * Extrai contexto visual determinístico de uma imagem usando GPT-4o Vision
 */
export async function extractVisionContext(input: VisionInput): Promise<VisionExtractorResult> {
  const { imageUrl, imageBase64, ocrTextRaw } = input;

  // Validar input
  if (!imageUrl && !imageBase64) {
    return {
      success: false,
      error: 'imageUrl ou imageBase64 é obrigatório',
      attempts: 0
    };
  }

  const openaiApiKey = Deno.env.get('OPENAI_API_KEY');
  if (!openaiApiKey) {
    return {
      success: false,
      error: 'OpenAI API key não configurada',
      attempts: 0
    };
  }

  // Preparar URL da imagem
  let imageUrlFinal = '';
  if (imageBase64) {
    imageUrlFinal = `data:image/jpeg;base64,${imageBase64}`;
  } else if (imageUrl) {
    imageUrlFinal = imageUrl;
  }

  const systemPrompt = `Você é um extrator de CONTEXTO VISUAL e TEXTO de uma imagem.

REGRAS:
- Descreva APENAS o que está VISÍVEL/LEGÍVEL.
- NÃO infira profissão, emoções, relação, local exato ou preferências.
- Se houver texto, transcreva de forma normalizada em "ocr_text".
- Saída OBRIGATORIAMENTE em JSON, no esquema especificado, sem comentários, sem texto extra.
- "confidence_overall" ∈ [0.0,1.0].
- Em cada item {objects, actions, places} inclua "name" (minúsculo) e "confidence". Use "source":"vision".
- Se um campo não tiver dados, use vazio (ex.: [] ou ""), NUNCA invente.

SCHEMA JSON:
{
  "schema_version": "1.0",
  "detected_persons": { "count": 0 },
  "objects": [ { "name": "cat", "confidence": 0.92, "source": "vision" } ],
  "actions": [ { "name": "cleaning", "confidence": 0.71, "source": "vision" } ],
  "places":  [ { "name": "kitchen",  "confidence": 0.78, "source": "vision" } ],
  "colors": ["pink","beige"],
  "ocr_text": "texto normalizado (ou vazio)",
  "notable_details": ["cadeira rosa","tecido com dinossauros com 'OMG'"],
  "confidence_overall": 0.0
}`;

  const userPrompt = `Analise esta imagem e extraia informações visuais seguindo exatamente o schema JSON especificado acima.

INSTRUÇÕES:
- Liste apenas elementos claramente visíveis na imagem
- Para texto, transcreva exatamente o que conseguir ler (normalize caracteres especiais)
- Para objetos, ações e lugares: use nomes simples em minúsculo, apenas o que for óbvio
- Para cores: liste apenas cores dominantes claramente identificáveis
- Para detalhes notáveis: mencione elementos únicos mas visíveis (ex: padrões, texturas, objetos específicos)
- Se não conseguir identificar algo com confiança, deixe o campo vazio ou com baixa confidence
- NÃO adicione elementos que não estão na imagem`;

  const messages = [
    {
      role: 'system' as const,
      content: systemPrompt
    },
    {
      role: 'user' as const,
      content: [
        { type: 'text' as const, text: userPrompt },
        { type: 'image_url' as const, image_url: { url: imageUrlFinal, detail: 'high' } }
      ]
    }
  ];

  let attempts = 0;
  const maxAttempts = 2;

  while (attempts < maxAttempts) {
    attempts++;

    try {
      console.log(`🔍 Tentativa ${attempts} de extração de visão...`);

      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${openaiApiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-4o',
          messages,
          max_tokens: 800, // Conservador para garantir JSON completo
          temperature: 0.0, // Determinístico
          response_format: { type: "json_object" }
        }),
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error(`OpenAI API error (${response.status}):`, errorText);

        if (attempts === maxAttempts) {
          return {
            success: false,
            error: `OpenAI API error: ${response.status}`,
            attempts
          };
        }
        continue;
      }

      const data = await response.json();
      const content = data.choices[0]?.message?.content || '';

      if (!content.trim()) {
        if (attempts === maxAttempts) {
          return {
            success: false,
            error: 'Resposta vazia da OpenAI',
            attempts
          };
        }
        continue;
      }

      // Tentar fazer parse do JSON
      let visionData: VisionContext;
      try {
        visionData = JSON.parse(content);
      } catch (parseError) {
        console.error('Erro ao fazer parse do JSON:', parseError);
        console.log('Resposta bruta:', content);

        if (attempts === maxAttempts) {
          return {
            success: false,
            error: 'JSON inválido retornado pela OpenAI',
            attempts
          };
        }
        continue;
      }

      // Validar com Zod
      const validation = validateVisionContext(visionData);
      if (!validation.success) {
        console.error('Erro de validação Zod:', formatValidationErrors(validation.errors!));

        if (attempts === maxAttempts) {
          return {
            success: false,
            error: 'Dados não correspondem ao schema esperado',
            attempts
          };
        }
        continue;
      }

      const validatedData = validation.data!;

      console.log(`✅ Extração de visão bem-sucedida em ${attempts} tentativa(s)`);
      console.log(`📊 Confiança geral: ${validatedData.confidence_overall.toFixed(2)}`);
      console.log(`🎯 Objetos: ${validatedData.objects.length}, Cores: ${validatedData.colors.length}`);

      return {
        success: true,
        data: validatedData,
        attempts
      };

    } catch (error) {
      console.error(`Erro na tentativa ${attempts}:`, error);

      if (attempts === maxAttempts) {
        return {
          success: false,
          error: `Erro interno: ${error instanceof Error ? error.message : String(error)}`,
          attempts
        };
      }
    }
  }

  // Fallback para baixa confiança se todas as tentativas falharam
  return {
    success: true,
    data: {
      schema_version: '1.0',
      detected_persons: { count: 0 },
      objects: [],
      actions: [],
      places: [],
      colors: [],
      ocr_text: '',
      notable_details: [],
      confidence_overall: 0.1 // Baixa confiança
    },
    low_confidence: true,
    attempts: maxAttempts
  };
}
