-- migrate:up
-- 1. Agregar columnas de verificación legal y patria potestad en athletes
ALTER TABLE athletes
    ADD COLUMN IF NOT EXISTS legal_verification_status VARCHAR(30) NOT NULL DEFAULT 'PENDING_REVIEW',
    ADD COLUMN IF NOT EXISTS legal_verification_notes TEXT,
    ADD COLUMN IF NOT EXISTS legal_verified_by UUID REFERENCES users(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS legal_verified_at TIMESTAMP WITH TIME ZONE;

-- 2. Crear índice para optimizar consultas de auditoría administrativa y directorio
CREATE INDEX IF NOT EXISTS idx_athletes_legal_verification_status ON athletes(legal_verification_status);

-- migrate:down
DROP INDEX IF EXISTS idx_athletes_legal_verification_status;

ALTER TABLE athletes
    DROP COLUMN IF EXISTS legal_verified_at,
    DROP COLUMN IF EXISTS legal_verified_by,
    DROP COLUMN IF EXISTS legal_verification_notes,
    DROP COLUMN IF EXISTS legal_verification_status;
