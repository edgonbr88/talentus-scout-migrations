-- migrate:up
-- Tabla de identidades sociales vinculadas a usuarios
CREATE TABLE IF NOT EXISTS user_social_identities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL, -- 'GOOGLE', 'MICROSOFT'
    provider_user_id VARCHAR(255) NOT NULL,
    provider_email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT uq_social_identity_provider_uid UNIQUE (provider, provider_user_id),
    CONSTRAINT uq_social_identity_user_provider UNIQUE (user_id, provider)
);

CREATE INDEX IF NOT EXISTS idx_user_social_identities_user_id ON user_social_identities(user_id);
CREATE INDEX IF NOT EXISTS idx_user_social_identities_provider_email ON user_social_identities(provider_email);

-- Agregar columna is_profile_completed a users para controlar usuarios preliminares
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_profile_completed BOOLEAN NOT NULL DEFAULT TRUE;

-- migrate:down
ALTER TABLE users DROP COLUMN IF EXISTS is_profile_completed;
DROP TABLE IF EXISTS user_social_identities;
