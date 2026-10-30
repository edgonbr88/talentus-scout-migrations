-- migrate:up
INSERT INTO subscription_plans (id, name, price_usd, duration_days, max_videos, has_radar_views, has_pdf_cv, is_active)
VALUES 
    ('PRO_MONTHLY', 'Plan Pro Mensual', 5.00, 30, 5, TRUE, TRUE, TRUE),
    ('PRO_ANNUAL', 'Plan Pro Anual (Pase de Temporada)', 50.00, 365, 10, TRUE, TRUE, TRUE)
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    price_usd = EXCLUDED.price_usd,
    duration_days = EXCLUDED.duration_days,
    max_videos = EXCLUDED.max_videos,
    has_radar_views = EXCLUDED.has_radar_views,
    has_pdf_cv = EXCLUDED.has_pdf_cv,
    is_active = EXCLUDED.is_active;

ALTER TABLE payment_transactions 
    ADD COLUMN IF NOT EXISTS payment_date DATE DEFAULT CURRENT_DATE,
    ADD COLUMN IF NOT EXISTS origin_bank VARCHAR(100),
    ADD COLUMN IF NOT EXISTS origin_phone VARCHAR(30);

ALTER TABLE payment_transactions ALTER COLUMN proof_image_url DROP NOT NULL;

-- migrate:down
DELETE FROM subscription_plans WHERE id IN ('PRO_MONTHLY', 'PRO_ANNUAL');
ALTER TABLE payment_transactions DROP COLUMN IF EXISTS payment_date;
ALTER TABLE payment_transactions DROP COLUMN IF EXISTS origin_bank;
ALTER TABLE payment_transactions DROP COLUMN IF EXISTS origin_phone;
