-- migrate:up
-- 1. Agregar campos de expediente de identidad a scout_profiles
ALTER TABLE scout_profiles
    ADD COLUMN IF NOT EXISTS id_document_type VARCHAR(30),
    ADD COLUMN IF NOT EXISTS id_document_number VARCHAR(50),
    ADD COLUMN IF NOT EXISTS id_document_url TEXT,
    ADD COLUMN IF NOT EXISTS selfie_url TEXT;

-- 2. Agregar campos de parentesco, selfie y poder de representación a tutor_legal_consents
ALTER TABLE tutor_legal_consents
    ADD COLUMN IF NOT EXISTS relationship_type VARCHAR(30) NOT NULL DEFAULT 'PARENT',
    ADD COLUMN IF NOT EXISTS selfie_file_url TEXT,
    ADD COLUMN IF NOT EXISTS representation_document_file_url TEXT;

-- migrate:down
ALTER TABLE tutor_legal_consents
    DROP COLUMN IF EXISTS representation_document_file_url,
    DROP COLUMN IF EXISTS selfie_file_url,
    DROP COLUMN IF EXISTS relationship_type;

ALTER TABLE scout_profiles
    DROP COLUMN IF EXISTS selfie_url,
    DROP COLUMN IF EXISTS id_document_url,
    DROP COLUMN IF EXISTS id_document_number,
    DROP COLUMN IF EXISTS id_document_type;
