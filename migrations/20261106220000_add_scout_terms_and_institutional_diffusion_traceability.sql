-- migrate:up
ALTER TABLE scout_profiles
    ADD COLUMN IF NOT EXISTS accepted_terms BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS terms_version VARCHAR(20) NOT NULL DEFAULT '1.0',
    ADD COLUMN IF NOT EXISTS terms_accepted_at TIMESTAMP WITH TIME ZONE,
    ADD COLUMN IF NOT EXISTS terms_ip_address VARCHAR(45),
    ADD COLUMN IF NOT EXISTS terms_user_agent TEXT;

-- migrate:down
ALTER TABLE scout_profiles
    DROP COLUMN IF EXISTS terms_user_agent,
    DROP COLUMN IF EXISTS terms_ip_address,
    DROP COLUMN IF EXISTS terms_accepted_at,
    DROP COLUMN IF EXISTS terms_version,
    DROP COLUMN IF EXISTS accepted_terms;
