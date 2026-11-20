-- migrate:up

-- 1. Saneamiento previo de registros anómalos existentes con fecha de nacimiento futura o igual a hoy
UPDATE athletes
SET deleted_at = COALESCE(deleted_at, CURRENT_TIMESTAMP),
    is_public = FALSE
WHERE birth_date >= CURRENT_DATE;

-- 2. Constraint a nivel de motor PostgreSQL para impedir fechas futuras o iguales a hoy en atletas activos
ALTER TABLE athletes
ADD CONSTRAINT chk_athletes_birth_date_past
CHECK (birth_date < CURRENT_DATE OR deleted_at IS NOT NULL);

-- migrate:down

ALTER TABLE athletes
DROP CONSTRAINT IF EXISTS chk_athletes_birth_date_past;
