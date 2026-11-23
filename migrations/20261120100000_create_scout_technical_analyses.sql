-- migrate:up
CREATE TABLE IF NOT EXISTS scout_technical_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    athlete_id UUID NOT NULL REFERENCES athletes(id) ON DELETE CASCADE,
    scout_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    strengths JSONB NOT NULL,
    improvement_areas JSONB NOT NULL,
    scouting_verdict TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_scout_technical_analyses_athlete_scout UNIQUE (athlete_id, scout_id),
    CONSTRAINT chk_scout_tech_analyses_strengths_array CHECK (
        jsonb_typeof(strengths) = 'array' AND jsonb_array_length(strengths) >= 1
    ),
    CONSTRAINT chk_scout_tech_analyses_improvements_array CHECK (
        jsonb_typeof(improvement_areas) = 'array' AND jsonb_array_length(improvement_areas) >= 1
    ),
    CONSTRAINT chk_scout_tech_analyses_verdict_nonempty CHECK (
        length(trim(scouting_verdict)) > 0
    )
);

CREATE INDEX IF NOT EXISTS idx_scout_tech_analyses_athlete
    ON scout_technical_analyses(athlete_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_scout_tech_analyses_scout
    ON scout_technical_analyses(scout_id);

-- migrate:down
DROP INDEX IF EXISTS idx_scout_tech_analyses_scout;
DROP INDEX IF EXISTS idx_scout_tech_analyses_athlete;
DROP TABLE IF EXISTS scout_technical_analyses;
