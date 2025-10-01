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
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('URL_SUPABASE') ?? '',
      Deno.env.get('ANON_KEY_SUPABASE') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    const { image_path, image_base64, tone, focus, user_id, text }: AnalysisRequest = await req.json()

    if (!tone) {
      return new Response(
        JSON.stringify({ error: 'Tone is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OpenAI API key not configured')
    }

    // Test response to verify deployment
    return new Response(
      JSON.stringify({
        success: true,
        message: 'Edge Function v16 deployed successfully with ANON_KEY_SUPABASE',
        config_check: {
          URL_SUPABASE: !!Deno.env.get('URL_SUPABASE'),
          ANON_KEY_SUPABASE: !!Deno.env.get('ANON_KEY_SUPABASE'),
          SERVICE_ROLE_KEY_supabase: !!Deno.env.get('SERVICE_ROLE_KEY_supabase'),
          OPENAI_API_KEY: !!Deno.env.get('OPENAI_API_KEY')
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
