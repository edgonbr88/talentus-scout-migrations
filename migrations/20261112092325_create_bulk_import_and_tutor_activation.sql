-- migrate:up
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'bulk_import_source_type') THEN
        CREATE TYPE bulk_import_source_type AS ENUM ('FILE_EXCEL', 'FILE_CSV', 'GOOGLE_SHEET');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'bulk_import_status') THEN
        CREATE TYPE bulk_import_status AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS bulk_import_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scout_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    club_id UUID REFERENCES clubs_organizations(id) ON DELETE SET NULL,
    organization_name VARCHAR(150) NOT NULL,
    source_type bulk_import_source_type NOT NULL,
    file_name VARCHAR(255),
    sheet_id VARCHAR(255),
    status bulk_import_status NOT NULL DEFAULT 'PENDING',
    total_rows INT NOT NULL DEFAULT 0,
    processed_rows INT NOT NULL DEFAULT 0,
    successful_rows INT NOT NULL DEFAULT 0,
    failed_rows INT NOT NULL DEFAULT 0,
    error_summary TEXT,
    error_report_json JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bulk_import_jobs_scout ON bulk_import_jobs(scout_id);
CREATE INDEX IF NOT EXISTS idx_bulk_import_jobs_status ON bulk_import_jobs(status);

CREATE TABLE IF NOT EXISTS tutor_activation_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tutor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_tutor_activation_tokens_hash ON tutor_activation_tokens(token_hash);

-- Soft delete audit fields en athletes y users
ALTER TABLE athletes ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;

-- migrate:down
DROP TABLE IF EXISTS tutor_activation_tokens;
DROP TABLE IF EXISTS bulk_import_jobs;
DROP TYPE IF EXISTS bulk_import_status;
DROP TYPE IF EXISTS bulk_import_source_type;
