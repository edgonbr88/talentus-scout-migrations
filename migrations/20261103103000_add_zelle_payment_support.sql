-- migrate:up
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'ZELLE';

ALTER TABLE payment_gateway_settings
    ADD COLUMN IF NOT EXISTS zelle_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS zelle_email VARCHAR(150) DEFAULT 'pagos@talentusscout.com',
    ADD COLUMN IF NOT EXISTS zelle_account_holder VARCHAR(150) DEFAULT 'Talentus Scout LLC',
    ADD COLUMN IF NOT EXISTS zelle_qr_image_url VARCHAR(255);

UPDATE payment_gateway_settings
SET zelle_enabled = TRUE,
    zelle_email = COALESCE(zelle_email, 'pagos@talentusscout.com'),
    zelle_account_holder = COALESCE(zelle_account_holder, 'Talentus Scout LLC')
WHERE zelle_email IS NULL OR zelle_account_holder IS NULL;

-- migrate:down
ALTER TABLE payment_gateway_settings
    DROP COLUMN IF EXISTS zelle_enabled,
    DROP COLUMN IF EXISTS zelle_email,
    DROP COLUMN IF EXISTS zelle_account_holder,
    DROP COLUMN IF EXISTS zelle_qr_image_url;
