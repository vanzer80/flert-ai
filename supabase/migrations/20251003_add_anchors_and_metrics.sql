-- Migration: Add anchors, vision_context and generation_metrics support
-- Created: 2025-10-03

-- Add new fields to conversations.analysis_result (JSONB) for anchors and validation
-- Note: Since analysis_result is already JSONB, we don't need schema changes here
-- The new fields will be: anchors, anchors_used, low_confidence, vision_context

-- Create generation_metrics table for tracking quality and performance
CREATE TABLE IF NOT EXISTS generation_metrics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid REFERENCES conversations(id) ON DELETE CASCADE,
  suggestion_id uuid REFERENCES suggestions(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  latency_ms integer,
  tokens_input integer,
  tokens_output integer,
  anchors_used integer,
  anchors_total integer,
  repetition_rate numeric, -- 0..1
  low_confidence boolean DEFAULT false
);

-- Create index for queries by conversation
CREATE INDEX IF NOT EXISTS idx_generation_metrics_conv ON generation_metrics(conversation_id);

-- Create index for queries by suggestion
CREATE INDEX IF NOT EXISTS idx_generation_metrics_suggestion ON generation_metrics(suggestion_id);

-- Add comments for documentation
COMMENT ON TABLE generation_metrics IS 'Tracks quality metrics for each message generation including latency, token usage, anchor usage, and confidence scores';
COMMENT ON COLUMN generation_metrics.latency_ms IS 'Total time taken for the generation in milliseconds';
COMMENT ON COLUMN generation_metrics.tokens_input IS 'Number of input tokens used';
COMMENT ON COLUMN generation_metrics.tokens_output IS 'Number of output tokens generated';
COMMENT ON COLUMN generation_metrics.anchors_used IS 'Number of anchors found in the suggestion';
COMMENT ON COLUMN generation_metrics.anchors_total IS 'Total number of anchors available from vision analysis';
COMMENT ON COLUMN generation_metrics.repetition_rate IS 'Similarity rate with previous suggestions (0-1 scale)';
COMMENT ON COLUMN generation_metrics.low_confidence IS 'Flag indicating if the suggestion failed anchor validation';
