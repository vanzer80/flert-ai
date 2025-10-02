-- =====================================================
-- COMANDO SQL 2/3: Índices, Trigger e RLS
-- =====================================================

-- Índices
CREATE INDEX idx_cultural_references_tipo ON cultural_references(tipo);
CREATE INDEX idx_cultural_references_regiao ON cultural_references(regiao);
CREATE INDEX idx_cultural_references_termo ON cultural_references(termo);
CREATE INDEX idx_cultural_references_created_at ON cultural_references(created_at DESC);

-- Full-text search index para busca por texto
CREATE INDEX idx_cultural_references_termo_search ON cultural_references USING gin(to_tsvector('portuguese', termo));
CREATE INDEX idx_cultural_references_significado_search ON cultural_references USING gin(to_tsvector('portuguese', significado));

-- =====================================================
-- TRIGGER: Update updated_at timestamp
-- =====================================================
CREATE OR REPLACE FUNCTION update_cultural_references_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_cultural_references_updated_at
    BEFORE UPDATE ON cultural_references
    FOR EACH ROW
    EXECUTE FUNCTION update_cultural_references_updated_at();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE cultural_references ENABLE ROW LEVEL SECURITY;

-- Policy: Public read access (todos podem ler)
CREATE POLICY "Public read access for cultural references"
    ON cultural_references
    FOR SELECT
    TO public
    USING (true);

-- Policy: Authenticated users can insert (para scripts/admin)
CREATE POLICY "Authenticated users can insert cultural references"
    ON cultural_references
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy: Authenticated users can update (para curadoria)
CREATE POLICY "Authenticated users can update cultural references"
    ON cultural_references
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Policy: Service role can delete (apenas admin/scripts)
CREATE POLICY "Service role can delete cultural references"
    ON cultural_references
    FOR DELETE
    TO service_role
    USING (true);
