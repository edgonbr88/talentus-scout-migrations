-- migrate:up
ALTER TABLE scout_profiles ADD COLUMN IF NOT EXISTS bulk_import_enabled BOOLEAN NOT NULL DEFAULT FALSE;

-- migrate:down
ALTER TABLE scout_profiles DROP COLUMN IF EXISTS bulk_import_enabled;
