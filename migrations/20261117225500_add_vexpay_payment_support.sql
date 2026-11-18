-- migrate:up
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'VEXPAY';
ALTER TYPE payment_status ADD VALUE IF NOT EXISTS 'PENDING_GATEWAY';
ALTER TYPE payment_status ADD VALUE IF NOT EXISTS 'REVERSED';

ALTER TABLE payment_transactions
    ADD COLUMN IF NOT EXISTS vexpay_session_id VARCHAR(120),
    ADD COLUMN IF NOT EXISTS vexpay_payment_id VARCHAR(120),
    ADD COLUMN IF NOT EXISTS vexpay_sub_method VARCHAR(50),
    ADD COLUMN IF NOT EXISTS applied_subscription_id UUID REFERENCES athlete_subscriptions(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS previous_subscription_end_date TIMESTAMP WITH TIME ZONE;

CREATE INDEX IF NOT EXISTS idx_payment_tx_vexpay_session ON payment_transactions(vexpay_session_id);
CREATE INDEX IF NOT EXISTS idx_payment_tx_vexpay_payment ON payment_transactions(vexpay_payment_id);

CREATE TABLE IF NOT EXISTS vexpay_webhook_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    event_id VARCHAR(120) UNIQUE NOT NULL,
    event_type VARCHAR(80) NOT NULL,
    livemode BOOLEAN NOT NULL DEFAULT FALSE,
    payload TEXT NOT NULL,
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE payment_gateway_settings
    ADD COLUMN IF NOT EXISTS vexpay_enabled BOOLEAN NOT NULL DEFAULT TRUE;

UPDATE payment_gateway_settings
SET vexpay_enabled = TRUE
WHERE vexpay_enabled IS NULL;

-- migrate:down
ALTER TABLE payment_gateway_settings
    DROP COLUMN IF EXISTS vexpay_enabled;

DROP TABLE IF EXISTS vexpay_webhook_events;

DROP INDEX IF EXISTS idx_payment_tx_vexpay_payment;
DROP INDEX IF EXISTS idx_payment_tx_vexpay_session;

ALTER TABLE payment_transactions
    DROP COLUMN IF EXISTS previous_subscription_end_date,
    DROP COLUMN IF EXISTS applied_subscription_id,
    DROP COLUMN IF EXISTS vexpay_sub_method,
    DROP COLUMN IF EXISTS vexpay_payment_id,
    DROP COLUMN IF EXISTS vexpay_session_id;
