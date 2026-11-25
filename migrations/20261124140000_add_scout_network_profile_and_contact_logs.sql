-- migrate:up
ALTER TABLE public.scout_profiles
    ADD COLUMN IF NOT EXISTS profile_photo_url TEXT,
    ADD COLUMN IF NOT EXISTS show_in_network BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS show_whatsapp_in_network BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS show_email_in_network BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS public.scout_network_contact_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    requester_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    target_scout_profile_id UUID NOT NULL REFERENCES public.scout_profiles(id) ON DELETE CASCADE,
    channel VARCHAR(20) NOT NULL CHECK (channel IN ('WHATSAPP', 'EMAIL')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_scout_profiles_network_visible
    ON public.scout_profiles (verification_status, show_in_network, organization_name);

CREATE INDEX IF NOT EXISTS idx_scout_network_contact_logs_requester
    ON public.scout_network_contact_logs (requester_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_scout_network_contact_logs_target
    ON public.scout_network_contact_logs (target_scout_profile_id, created_at DESC);

-- migrate:down
DROP INDEX IF EXISTS public.idx_scout_network_contact_logs_target;
DROP INDEX IF EXISTS public.idx_scout_network_contact_logs_requester;
DROP INDEX IF EXISTS public.idx_scout_profiles_network_visible;
DROP TABLE IF EXISTS public.scout_network_contact_logs;
ALTER TABLE public.scout_profiles
    DROP COLUMN IF EXISTS updated_at,
    DROP COLUMN IF EXISTS show_email_in_network,
    DROP COLUMN IF EXISTS show_whatsapp_in_network,
    DROP COLUMN IF EXISTS show_in_network,
    DROP COLUMN IF EXISTS profile_photo_url;
