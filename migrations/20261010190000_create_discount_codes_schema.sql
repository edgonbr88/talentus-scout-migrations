-- migrate:up
-- 1. Agregar nuevo valor al enum payment_method
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'DISCOUNT_CODE';

-- 2. Tabla de códigos de descuento y convenios
CREATE TABLE IF NOT EXISTS discount_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    discount_type VARCHAR(20) NOT NULL, -- 'PERCENTAGE', 'FIXED_AMOUNT'
    discount_value NUMERIC(10,2) NOT NULL,
    organization_id UUID REFERENCES clubs_organizations(id) ON DELETE SET NULL,
    applicable_plan_id VARCHAR(50) REFERENCES subscription_plans(id) ON DELETE SET NULL,
    max_uses INT DEFAULT NULL,
    current_uses INT NOT NULL DEFAULT 0,
    one_use_per_athlete BOOLEAN NOT NULL DEFAULT TRUE,
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_discount_codes_code ON discount_codes(code);
CREATE INDEX IF NOT EXISTS idx_discount_codes_org ON discount_codes(organization_id);
CREATE INDEX IF NOT EXISTS idx_discount_codes_active ON discount_codes(is_active);

-- 3. Tabla de canjes y redenciones de cupones
CREATE TABLE IF NOT EXISTS discount_code_redemptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    discount_code_id UUID NOT NULL REFERENCES discount_codes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    athlete_id UUID NOT NULL REFERENCES athletes(id) ON DELETE CASCADE,
    payment_transaction_id UUID REFERENCES payment_transactions(id) ON DELETE SET NULL,
    original_amount_usd NUMERIC(10,2) NOT NULL,
    discounted_amount_usd NUMERIC(10,2) NOT NULL,
    final_amount_usd NUMERIC(10,2) NOT NULL,
    redeemed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_redemptions_code_athlete ON discount_code_redemptions(discount_code_id, athlete_id);
CREATE INDEX IF NOT EXISTS idx_redemptions_user ON discount_code_redemptions(user_id);

-- 4. Modificaciones a payment_transactions para trazabilidad de cupones
ALTER TABLE payment_transactions 
    ADD COLUMN IF NOT EXISTS discount_code_id UUID REFERENCES discount_codes(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS discount_amount_usd NUMERIC(10,2) DEFAULT 0.00;

-- migrate:down
ALTER TABLE payment_transactions 
    DROP COLUMN IF EXISTS discount_amount_usd,
    DROP COLUMN IF EXISTS discount_code_id;

DROP TABLE IF EXISTS discount_code_redemptions CASCADE;
DROP TABLE IF EXISTS discount_codes CASCADE;
