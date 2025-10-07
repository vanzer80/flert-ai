-- Migration: 20251005_add_context_and_metrics.sql
-- Adiciona suporte para contexto visual e métricas de geração - VERSÃO OTIMIZADA

-- Adicionar colunas à tabela conversations para armazenar contexto e âncoras
alter table conversations
  add column if not exists analysis_result jsonb default '{}',
  add column if not exists exhausted_anchors text[] default '{}';

-- Criar tabela para métricas de geração com estrutura aprimorada
create table if not exists generation_metrics (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations(id) on delete cascade,
  suggestion_id uuid references suggestions(id) on delete cascade,
  created_at timestamptz default now(),
  latency_ms int default 0,
  tokens_input int default 0,
  tokens_output int default 0,
  anchors_used int default 0,
  anchors_total int default 0,
  repetition_rate numeric default 0.0,
  low_confidence boolean default false,
  generation_mode text default 'fresh', -- 'fresh' | 'regenerate' | 'context_reuse'
  model_used text default 'gpt-4o-mini',
  temperature_used numeric default 0.8,
  user_feedback_score int, -- Para futuras avaliações de qualidade
  metadata jsonb default '{}' -- Campos adicionais para extensibilidade
);

-- Índices para performance otimizada
create index if not exists idx_gen_metrics_conv_created on generation_metrics(conversation_id, created_at DESC);
create index if not exists idx_gen_metrics_suggestion on generation_metrics(suggestion_id);
create index if not exists idx_gen_metrics_quality on generation_metrics(low_confidence, repetition_rate);
create index if not exists idx_gen_metrics_performance on generation_metrics(latency_ms, tokens_input);

-- Índice composto para consultas analíticas
create index if not exists idx_gen_metrics_analytics on generation_metrics(
  created_at DESC,
  low_confidence,
  repetition_rate,
  anchors_used
);

-- Comentários para documentação aprimorada
comment on table generation_metrics is 'Métricas detalhadas de cada geração de sugestão com analytics avançados';
comment on column generation_metrics.latency_ms is 'Tempo de resposta em milissegundos (otimizado para < 2000ms)';
comment on column generation_metrics.tokens_input is 'Tokens de entrada (prompt) - monitorado para custo';
comment on column generation_metrics.tokens_output is 'Tokens de saída (sugestão) - monitorado para qualidade';
comment on column generation_metrics.anchors_used is 'Número de âncoras utilizadas na sugestão (meta: ≥1)';
comment on column generation_metrics.anchors_total is 'Número total de âncoras disponíveis (fonte de variedade)';
comment on column generation_metrics.repetition_rate is 'Taxa de similaridade com sugestões anteriores (meta: ≤0.4)';
comment on column generation_metrics.low_confidence is 'Flag indicando baixa qualidade/confiança na geração';
comment on column generation_metrics.generation_mode is 'Modo de geração: fresh (nova), regenerate (regerada), context_reuse (contexto existente)';
comment on column generation_metrics.user_feedback_score is 'Score de feedback do usuário (1-5, futuro uso)';
comment on column generation_metrics.metadata is 'Campos adicionais para extensibilidade futura';

-- Trigger para atualizar timestamp automaticamente
create or replace function update_generation_metrics_timestamp()
returns trigger as $$
begin
  new.created_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trigger_generation_metrics_timestamp
  before update on generation_metrics
  for each row
  execute function update_generation_metrics_timestamp();

-- Política RLS para segurança (se necessário no futuro)
-- alter table generation_metrics enable row level security;
-- create policy "Users can view their own metrics" on generation_metrics
--   for select using (
--     conversation_id in (
--       select id from conversations where user_id = auth.uid()
--     )
--   );
