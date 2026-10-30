-- migrate:up
-- 1. Incorporar PENDING_EMAIL_VERIFICATION al enum account_status si no existe
ALTER TYPE account_status ADD VALUE IF NOT EXISTS 'PENDING_EMAIL_VERIFICATION';

-- 2. Tabla para tokens criptográficos de verificación de correo
CREATE TABLE IF NOT EXISTS email_verification_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_token ON email_verification_tokens(token);
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);

-- 3. Campos de documento de identidad en tutor_legal_consents
ALTER TABLE tutor_legal_consents
    ADD COLUMN IF NOT EXISTS id_document_type VARCHAR(30),
    ADD COLUMN IF NOT EXISTS id_document_number VARCHAR(50),
    ADD COLUMN IF NOT EXISTS id_document_file_url VARCHAR(500);

-- 4. Campos de documento de identidad en athletes
ALTER TABLE athletes
    ADD COLUMN IF NOT EXISTS identity_document_type VARCHAR(30),
    ADD COLUMN IF NOT EXISTS identity_document_number VARCHAR(50),
    ADD COLUMN IF NOT EXISTS identity_document_file_url VARCHAR(500);

-- migrate:down
ALTER TABLE athletes
    DROP COLUMN IF EXISTS identity_document_file_url,
    DROP COLUMN IF EXISTS identity_document_number,
    DROP COLUMN IF EXISTS identity_document_type;

ALTER TABLE tutor_legal_consents
    DROP COLUMN IF EXISTS id_document_file_url,
    DROP COLUMN IF EXISTS id_document_number,
    DROP COLUMN IF EXISTS id_document_type;

DROP TABLE IF EXISTS email_verification_tokens;
