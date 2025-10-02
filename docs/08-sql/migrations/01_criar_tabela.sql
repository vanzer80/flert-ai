-- =====================================================
-- COMANDO SQL 1/3: Criar Tabela cultural_references
-- =====================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS cultural_references (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    termo TEXT UNIQUE NOT NULL,
    tipo TEXT NOT NULL,
    significado TEXT NOT NULL,
    exemplo_uso TEXT,
    regiao TEXT DEFAULT 'nacional',
    contexto_flerte TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),

    -- Constraints
    CONSTRAINT tipo_valido CHECK (tipo IN (
        'giria',
        'meme',
        'novela',
        'musica',
        'personalidade',
        'evento',
        'expressao_regional',
        'filme',
        'serie',
        'esporte',
        'comida',
        'lugar'
    )),
    CONSTRAINT regiao_valida CHECK (regiao IN (
        'nacional',
        'norte',
        'nordeste',
        'centro-oeste',
        'sudeste',
        'sul'
    ))
);
