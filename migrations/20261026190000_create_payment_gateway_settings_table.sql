-- migrate:up
CREATE TABLE payment_gateway_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    pago_movil_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    pago_movil_bank VARCHAR(100) NOT NULL,
    pago_movil_phone VARCHAR(50) NOT NULL,
    pago_movil_id_number VARCHAR(50) NOT NULL,
    pago_movil_account_holder VARCHAR(150) NOT NULL,
    binance_manual_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    binance_pay_id VARCHAR(50),
    binance_wallet_address VARCHAR(150),
    binance_network VARCHAR(50) DEFAULT 'USDT (TRC-20 / BEP-20)',
    binance_qr_image_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Seed de configuración inicial canónica (singleton)
INSERT INTO payment_gateway_settings (
    pago_movil_enabled,
    pago_movil_bank,
    pago_movil_phone,
    pago_movil_id_number,
    pago_movil_account_holder,
    binance_manual_enabled,
    binance_pay_id,
    binance_wallet_address,
    binance_network,
    binance_qr_image_url
) VALUES (
    TRUE,
    'Banco Nacional de Crédito (BNC)',
    '04141234567',
    'J-50123456-7',
    'Talentus Scout C.A.',
    TRUE,
    '283918273',
    'TLsV5289FjK93kdJ8193jd93kd9',
    'USDT (TRC-20 / BEP-20)',
    '/assets/images/binance-qr-sample.png'
);

-- migrate:down
DROP TABLE IF EXISTS payment_gateway_settings;
