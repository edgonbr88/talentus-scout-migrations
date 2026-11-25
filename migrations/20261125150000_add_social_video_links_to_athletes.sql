-- migrate:up
ALTER TABLE public.athletes
    ADD COLUMN IF NOT EXISTS instagram_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS tiktok_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS youtube_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS other_video_platform_url VARCHAR(500),
    ADD COLUMN IF NOT EXISTS other_video_platform_label VARCHAR(60);

-- migrate:down
ALTER TABLE public.athletes
    DROP COLUMN IF EXISTS other_video_platform_label,
    DROP COLUMN IF EXISTS other_video_platform_url,
    DROP COLUMN IF EXISTS youtube_url,
    DROP COLUMN IF EXISTS tiktok_url,
    DROP COLUMN IF EXISTS instagram_url;
