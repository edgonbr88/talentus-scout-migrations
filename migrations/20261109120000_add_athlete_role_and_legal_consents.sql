-- migrate:up
-- 1. Incorporar el nuevo rol ATHLETE al enum user_role
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'ATHLETE';

-- 2. Crear tabla de trazabilidad legal para consentimiento de atletas mayores de edad
CREATE TABLE IF NOT EXISTS athlete_legal_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    athlete_id UUID NOT NULL REFERENCES athletes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    accepted_terms BOOLEAN NOT NULL DEFAULT TRUE,
    accepted_institutional_diffusion BOOLEAN NOT NULL DEFAULT TRUE,
    terms_version VARCHAR(20) NOT NULL DEFAULT '1.0',
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NOT NULL,
    accepted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_athlete_legal_consents_athlete ON athlete_legal_consents(athlete_id);
CREATE INDEX IF NOT EXISTS idx_athlete_legal_consents_user ON athlete_legal_consents(user_id);

-- migrate:down
DROP TABLE IF EXISTS athlete_legal_consents;
