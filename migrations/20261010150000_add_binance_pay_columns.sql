-- migrate:up
ALTER TABLE payment_transactions 
    ADD COLUMN IF NOT EXISTS gateway_order_id VARCHAR(100),
    ADD COLUMN IF NOT EXISTS raw_webhook_payload TEXT;

CREATE INDEX IF NOT EXISTS idx_payment_tx_gateway_order ON payment_transactions(gateway_order_id);
CREATE INDEX IF NOT EXISTS idx_payment_tx_method_status ON payment_transactions(method, status);

-- migrate:down
DROP INDEX IF EXISTS idx_payment_tx_method_status;
DROP INDEX IF EXISTS idx_payment_tx_gateway_order;
ALTER TABLE payment_transactions 
    DROP COLUMN IF EXISTS raw_webhook_payload,
    DROP COLUMN IF EXISTS gateway_order_id;
