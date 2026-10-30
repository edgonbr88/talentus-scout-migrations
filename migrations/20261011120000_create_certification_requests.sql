-- migrate:up
CREATE TABLE IF NOT EXISTS certification_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    athlete_id UUID NOT NULL REFERENCES athletes(id) ON DELETE CASCADE,
    badge_type badge_type NOT NULL,
    request_method VARCHAR(30) NOT NULL, -- 'DOCUMENT_UPLOAD', 'TOKEN_LINK', 'DIRECT_ORGANIZATION'
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED', 'EXPIRED'
    title VARCHAR(150) NOT NULL,
    description TEXT,
    evidence_document_url TEXT,
    reviewed_by_admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    target_email VARCHAR(150),
    target_name VARCHAR(150),
    target_organization VARCHAR(150),
    token_hash VARCHAR(255) UNIQUE,
    token_expires_at TIMESTAMP WITH TIME ZONE,
    certifier_full_name VARCHAR(150),
    certifier_license_id VARCHAR(100),
    certifier_notes TEXT,
    certifier_ip VARCHAR(50),
    certification_data_json TEXT,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    badge_id UUID REFERENCES athlete_badges(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_cert_req_athlete ON certification_requests(athlete_id, status);
CREATE INDEX IF NOT EXISTS idx_cert_req_token ON certification_requests(token_hash);
CREATE INDEX IF NOT EXISTS idx_cert_req_status ON certification_requests(status);

-- migrate:down
DROP TABLE IF EXISTS certification_requests;
