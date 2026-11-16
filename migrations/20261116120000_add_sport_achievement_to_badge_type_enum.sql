-- migrate:up
ALTER TYPE badge_type ADD VALUE IF NOT EXISTS 'SPORT_ACHIEVEMENT';

-- migrate:down
-- PostgreSQL no soporta eliminar valores de un tipo ENUM directamente
