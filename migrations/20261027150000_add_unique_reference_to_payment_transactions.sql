-- migrate:up
-- Restricción de unicidad antifraude para referencias bancarias y hashes de pago
CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_transactions_reference_unique 
    ON payment_transactions(reference_number) 
    WHERE reference_number IS NOT NULL AND reference_number <> '';

-- migrate:down
DROP INDEX IF EXISTS idx_payment_transactions_reference_unique;
