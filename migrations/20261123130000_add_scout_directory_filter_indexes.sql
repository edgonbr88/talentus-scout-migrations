-- migrate:up
CREATE INDEX IF NOT EXISTS idx_athletes_height_cm
    ON public.athletes USING btree (height_cm)
    WHERE deleted_at IS NULL AND height_cm IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_athletes_weight_kg
    ON public.athletes USING btree (weight_kg)
    WHERE deleted_at IS NULL AND weight_kg IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_athletes_first_name_lower
    ON public.athletes USING btree (lower(first_name));

CREATE INDEX IF NOT EXISTS idx_athletes_last_name_lower
    ON public.athletes USING btree (lower(last_name));

CREATE INDEX IF NOT EXISTS idx_clubs_organizations_name_lower
    ON public.clubs_organizations USING btree (lower(name));

-- migrate:down
DROP INDEX IF EXISTS public.idx_clubs_organizations_name_lower;
DROP INDEX IF EXISTS public.idx_athletes_last_name_lower;
DROP INDEX IF EXISTS public.idx_athletes_first_name_lower;
DROP INDEX IF EXISTS public.idx_athletes_weight_kg;
DROP INDEX IF EXISTS public.idx_athletes_height_cm;
