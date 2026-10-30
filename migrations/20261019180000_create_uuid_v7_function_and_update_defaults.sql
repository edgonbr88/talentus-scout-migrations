-- migrate:up
-- 1. Habilitar extensión pgcrypto para generación de bytes pseudoaleatorios seguros
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Función canónica para generación de UUID v7 (RFC 9562) en PostgreSQL
CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS uuid
AS $$
DECLARE
    unix_time_ms bytea;
    uuid_bytes bytea;
BEGIN
    -- 6 bytes (48 bits) conteniendo la marca de tiempo Unix epoch en milisegundos
    unix_time_ms := substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3 for 6);
    -- 10 bytes pseudoaleatorios criptográficos para completar los 16 bytes (128 bits)
    uuid_bytes := unix_time_ms || gen_random_bytes(10);
    -- Establecer la versión 7 (0111xxxx) en el byte 7 (índice 6 base 0)
    uuid_bytes := set_byte(uuid_bytes, 6, (get_byte(uuid_bytes, 6) & 15) | 112);
    -- Establecer la variante RFC 4122/9562 (10xxxxxx) en el byte 9 (índice 8 base 0)
    uuid_bytes := set_byte(uuid_bytes, 8, (get_byte(uuid_bytes, 8) & 63) | 128);
    RETURN encode(uuid_bytes, 'hex')::uuid;
END;
$$ LANGUAGE plpgsql VOLATILE;

-- 3. Actualización de valores por defecto en tablas existentes a uuid_generate_v7()
ALTER TABLE users ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE tutor_legal_consents ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE clubs_organizations ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE verifier_delegates ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE athletes ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE athlete_videos ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE athlete_badges ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE payment_transactions ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE athlete_subscriptions ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE scout_profiles ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE scout_activity_logs ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE user_social_identities ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE email_verification_tokens ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE discount_codes ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE discount_code_redemptions ALTER COLUMN id SET DEFAULT uuid_generate_v7();
ALTER TABLE certification_requests ALTER COLUMN id SET DEFAULT uuid_generate_v7();

-- migrate:down
-- Restaurar defaults a uuid_generate_v4() / gen_random_uuid()
ALTER TABLE certification_requests ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE discount_code_redemptions ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE discount_codes ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE email_verification_tokens ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE user_social_identities ALTER COLUMN id SET DEFAULT gen_random_uuid();
ALTER TABLE scout_activity_logs ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE scout_profiles ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE athlete_subscriptions ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE payment_transactions ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE athlete_badges ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE athlete_videos ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE athletes ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE verifier_delegates ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE clubs_organizations ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE tutor_legal_consents ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE users ALTER COLUMN id SET DEFAULT uuid_generate_v4();

DROP FUNCTION IF EXISTS uuid_generate_v7();
