\restrict dbmate

-- Dumped from database version 16.15
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: account_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.account_status AS ENUM (
    'PENDING_VERIFICATION',
    'ACTIVE',
    'SUSPENDED',
    'PENDING_EMAIL_VERIFICATION'
);


--
-- Name: badge_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.badge_status AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


--
-- Name: badge_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.badge_type AS ENUM (
    'FEDERATION_LICENSE',
    'CLUB_AFFILIATION',
    'MEDICAL_ANTHRO',
    'SCOUT_ENDORSEMENT'
);


--
-- Name: bulk_import_source_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.bulk_import_source_type AS ENUM (
    'FILE_EXCEL',
    'FILE_CSV',
    'GOOGLE_SHEET'
);


--
-- Name: bulk_import_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.bulk_import_status AS ENUM (
    'PENDING',
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);


--
-- Name: payment_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_method AS ENUM (
    'PAGO_MOVIL',
    'BINANCE_PAY',
    'ZINLI_WALLY_ZELLE',
    'STRIPE',
    'DISCOUNT_CODE',
    'ZELLE'
);


--
-- Name: payment_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_status AS ENUM (
    'PENDING_AUDIT',
    'APPROVED',
    'REJECTED',
    'AUTO_CONFIRMED'
);


--
-- Name: scout_verification_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.scout_verification_status AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscription_status AS ENUM (
    'ACTIVE',
    'EXPIRED',
    'CANCELLED'
);


--
-- Name: user_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role AS ENUM (
    'TUTOR',
    'SCOUT',
    'VERIFIER_ORG',
    'ADMIN',
    'ATHLETE'
);


--
-- Name: video_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.video_status AS ENUM (
    'PENDING_UPLOAD',
    'PROCESSING',
    'READY',
    'FAILED'
);


--
-- Name: uuid_generate_v7(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.uuid_generate_v7() RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    unix_time_ms bytea;
    uuid_bytes bytea;
BEGIN
    -- 6 bytes (48 bits) conteniendo la marca de tiempo Unix epoch en milisegundos
    unix_time_ms := substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3 for 6);
    -- 10 bytes pseudoaleatorios criptográficos para completar los 16 bytes (128 bits)
    uuid_bytes := unix_time_ms || gen_random_bytes(10);
    -- Establecer la versión 7 (0111xxxx) en el byte 7 (índice 6 base 0)
    uuid_bytes := set_byte(uuid_bytes, 6, (get_byte(uuid_bytes, 6) & 15) | 112);
    -- Establecer la variante RFC 4122/9562 (10xxxxxx) en el byte 9 (índice 8 base 0)
    uuid_bytes := set_byte(uuid_bytes, 8, (get_byte(uuid_bytes, 8) & 63) | 128);
    RETURN encode(uuid_bytes, 'hex')::uuid;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: athlete_badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athlete_badges (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    athlete_id uuid NOT NULL,
    badge_type public.badge_type NOT NULL,
    organization_id uuid,
    verified_by_user_id uuid,
    status public.badge_status DEFAULT 'PENDING'::public.badge_status NOT NULL,
    evidence_document_url text,
    verification_notes text,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: athlete_legal_consents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athlete_legal_consents (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    athlete_id uuid NOT NULL,
    user_id uuid NOT NULL,
    accepted_terms boolean DEFAULT true NOT NULL,
    accepted_institutional_diffusion boolean DEFAULT true NOT NULL,
    terms_version character varying(20) DEFAULT '1.0'::character varying NOT NULL,
    ip_address character varying(45) NOT NULL,
    user_agent text NOT NULL,
    accepted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: athlete_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athlete_subscriptions (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    athlete_id uuid NOT NULL,
    plan_id character varying(50) NOT NULL,
    start_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    end_date timestamp with time zone NOT NULL,
    status public.subscription_status DEFAULT 'ACTIVE'::public.subscription_status NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: athlete_videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athlete_videos (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    athlete_id uuid NOT NULL,
    title character varying(150) NOT NULL,
    category character varying(50) DEFAULT 'HIGHLIGHTS'::character varying NOT NULL,
    provider_video_id character varying(100) NOT NULL,
    playback_url text,
    thumbnail_url text,
    duration_seconds integer DEFAULT 0,
    status public.video_status DEFAULT 'PENDING_UPLOAD'::public.video_status NOT NULL,
    sort_order integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: athletes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athletes (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    tutor_id uuid NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    birth_date date NOT NULL,
    gender character varying(10) DEFAULT 'MALE'::character varying NOT NULL,
    primary_position character varying(50) NOT NULL,
    secondary_position character varying(50),
    preferred_foot character varying(20) NOT NULL,
    nationality character varying(50) DEFAULT 'Venezolana'::character varying NOT NULL,
    secondary_passports character varying(150),
    current_club_id uuid,
    federation_license_number character varying(50),
    height_cm numeric(5,2),
    weight_kg numeric(5,2),
    profile_photo_url text,
    bio text,
    slug character varying(120) NOT NULL,
    is_public boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    identity_document_type character varying(30),
    identity_document_number character varying(50),
    identity_document_file_url character varying(500),
    legal_verification_status character varying(30) DEFAULT 'PENDING_REVIEW'::character varying NOT NULL,
    legal_verification_notes text,
    legal_verified_by uuid,
    legal_verified_at timestamp with time zone,
    deleted_at timestamp with time zone
);


--
-- Name: bulk_import_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_import_jobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    scout_id uuid NOT NULL,
    club_id uuid,
    organization_name character varying(150) NOT NULL,
    source_type public.bulk_import_source_type NOT NULL,
    file_name character varying(255),
    sheet_id character varying(255),
    status public.bulk_import_status DEFAULT 'PENDING'::public.bulk_import_status NOT NULL,
    total_rows integer DEFAULT 0 NOT NULL,
    processed_rows integer DEFAULT 0 NOT NULL,
    successful_rows integer DEFAULT 0 NOT NULL,
    failed_rows integer DEFAULT 0 NOT NULL,
    error_summary text,
    error_report_json jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: certification_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certification_requests (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    athlete_id uuid NOT NULL,
    badge_type public.badge_type NOT NULL,
    request_method character varying(30) NOT NULL,
    status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    title character varying(150) NOT NULL,
    description text,
    evidence_document_url text,
    reviewed_by_admin_id uuid,
    target_email character varying(150),
    target_name character varying(150),
    target_organization character varying(150),
    token_hash character varying(255),
    token_expires_at timestamp with time zone,
    certifier_full_name character varying(150),
    certifier_license_id character varying(100),
    certifier_notes text,
    certifier_ip character varying(50),
    certification_data_json text,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    badge_id uuid
);


--
-- Name: clubs_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clubs_organizations (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    name character varying(150) NOT NULL,
    federation_code character varying(50),
    city character varying(100) NOT NULL,
    state character varying(100) NOT NULL,
    country character varying(100) DEFAULT 'Venezuela'::character varying NOT NULL,
    logo_url text,
    verified_official boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: discount_code_redemptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discount_code_redemptions (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    discount_code_id uuid NOT NULL,
    user_id uuid NOT NULL,
    athlete_id uuid NOT NULL,
    payment_transaction_id uuid,
    original_amount_usd numeric(10,2) NOT NULL,
    discounted_amount_usd numeric(10,2) NOT NULL,
    final_amount_usd numeric(10,2) NOT NULL,
    redeemed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: discount_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discount_codes (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    code character varying(50) NOT NULL,
    description character varying(255),
    discount_type character varying(20) NOT NULL,
    discount_value numeric(10,2) NOT NULL,
    organization_id uuid,
    applicable_plan_id character varying(50),
    max_uses integer,
    current_uses integer DEFAULT 0 NOT NULL,
    one_use_per_athlete boolean DEFAULT true NOT NULL,
    starts_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: email_verification_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_verification_tokens (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: payment_gateway_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_gateway_settings (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    pago_movil_enabled boolean DEFAULT true NOT NULL,
    pago_movil_bank character varying(100) NOT NULL,
    pago_movil_phone character varying(50) NOT NULL,
    pago_movil_id_number character varying(50) NOT NULL,
    pago_movil_account_holder character varying(150) NOT NULL,
    binance_manual_enabled boolean DEFAULT true NOT NULL,
    binance_pay_id character varying(50),
    binance_wallet_address character varying(150),
    binance_network character varying(50) DEFAULT 'USDT (TRC-20 / BEP-20)'::character varying,
    binance_qr_image_url character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    zelle_enabled boolean DEFAULT true NOT NULL,
    zelle_email character varying(150) DEFAULT 'pagos@talentusscout.com'::character varying,
    zelle_account_holder character varying(150) DEFAULT 'Talentus Scout LLC'::character varying,
    zelle_qr_image_url character varying(255)
);


--
-- Name: payment_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_transactions (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    athlete_id uuid NOT NULL,
    plan_id character varying(50) NOT NULL,
    method public.payment_method NOT NULL,
    amount_usd numeric(10,2) NOT NULL,
    amount_ves numeric(15,2),
    bcv_exchange_rate numeric(10,4),
    reference_number character varying(100),
    proof_image_url text,
    status public.payment_status DEFAULT 'PENDING_AUDIT'::public.payment_status NOT NULL,
    audited_by_admin_id uuid,
    audited_at timestamp with time zone,
    rejection_reason text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    payment_date date DEFAULT CURRENT_DATE,
    origin_bank character varying(100),
    origin_phone character varying(30),
    gateway_order_id character varying(100),
    raw_webhook_payload text,
    discount_code_id uuid,
    discount_amount_usd numeric(10,2) DEFAULT 0.00
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: scout_activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scout_activity_logs (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    scout_id uuid NOT NULL,
    athlete_id uuid NOT NULL,
    video_id uuid,
    activity_type character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: scout_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scout_profiles (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    organization_name character varying(150) NOT NULL,
    scout_role character varying(100) NOT NULL,
    credentials_document_url text NOT NULL,
    linkedin_url text,
    verification_status public.scout_verification_status DEFAULT 'PENDING'::public.scout_verification_status NOT NULL,
    reviewed_by_admin_id uuid,
    reviewed_at timestamp with time zone,
    rejection_reason text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    id_document_type character varying(30),
    id_document_number character varying(50),
    id_document_url text,
    selfie_url text,
    accepted_terms boolean DEFAULT false NOT NULL,
    terms_version character varying(20) DEFAULT '1.0'::character varying NOT NULL,
    terms_accepted_at timestamp with time zone,
    terms_ip_address character varying(45),
    terms_user_agent text,
    bulk_import_enabled boolean DEFAULT false NOT NULL
);


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_plans (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    price_usd numeric(10,2) DEFAULT 0.00 NOT NULL,
    duration_days integer DEFAULT 30 NOT NULL,
    max_videos integer DEFAULT 1 NOT NULL,
    has_radar_views boolean DEFAULT false NOT NULL,
    has_pdf_cv boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: tutor_activation_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tutor_activation_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tutor_id uuid NOT NULL,
    token_hash character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: tutor_legal_consents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tutor_legal_consents (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    tutor_id uuid NOT NULL,
    accepted_lopnna_terms boolean DEFAULT true NOT NULL,
    terms_version character varying(20) DEFAULT '1.0'::character varying NOT NULL,
    ip_address character varying(45) NOT NULL,
    user_agent text NOT NULL,
    accepted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    id_document_type character varying(30),
    id_document_number character varying(50),
    id_document_file_url character varying(500),
    relationship_type character varying(30) DEFAULT 'PARENT'::character varying NOT NULL,
    selfie_file_url text,
    representation_document_file_url text
);


--
-- Name: user_social_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_social_identities (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    provider character varying(50) NOT NULL,
    provider_user_id character varying(255) NOT NULL,
    provider_email character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(150) NOT NULL,
    phone_number character varying(30) NOT NULL,
    role public.user_role DEFAULT 'TUTOR'::public.user_role NOT NULL,
    status public.account_status DEFAULT 'ACTIVE'::public.account_status NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_profile_completed boolean DEFAULT true NOT NULL,
    country character varying(100),
    state character varying(100),
    address character varying(255),
    deleted_at timestamp with time zone
);


--
-- Name: verifier_delegates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.verifier_delegates (
    id uuid DEFAULT public.uuid_generate_v7() NOT NULL,
    user_id uuid NOT NULL,
    organization_id uuid NOT NULL,
    position_title character varying(100) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: athlete_badges athlete_badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_badges
    ADD CONSTRAINT athlete_badges_pkey PRIMARY KEY (id);


--
-- Name: athlete_legal_consents athlete_legal_consents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_legal_consents
    ADD CONSTRAINT athlete_legal_consents_pkey PRIMARY KEY (id);


--
-- Name: athlete_subscriptions athlete_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_subscriptions
    ADD CONSTRAINT athlete_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: athlete_videos athlete_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_videos
    ADD CONSTRAINT athlete_videos_pkey PRIMARY KEY (id);


--
-- Name: athletes athletes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes
    ADD CONSTRAINT athletes_pkey PRIMARY KEY (id);


--
-- Name: athletes athletes_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes
    ADD CONSTRAINT athletes_slug_key UNIQUE (slug);


--
-- Name: bulk_import_jobs bulk_import_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_import_jobs
    ADD CONSTRAINT bulk_import_jobs_pkey PRIMARY KEY (id);


--
-- Name: certification_requests certification_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_requests
    ADD CONSTRAINT certification_requests_pkey PRIMARY KEY (id);


--
-- Name: certification_requests certification_requests_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_requests
    ADD CONSTRAINT certification_requests_token_hash_key UNIQUE (token_hash);


--
-- Name: clubs_organizations clubs_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clubs_organizations
    ADD CONSTRAINT clubs_organizations_pkey PRIMARY KEY (id);


--
-- Name: discount_code_redemptions discount_code_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_code_redemptions
    ADD CONSTRAINT discount_code_redemptions_pkey PRIMARY KEY (id);


--
-- Name: discount_codes discount_codes_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_codes
    ADD CONSTRAINT discount_codes_code_key UNIQUE (code);


--
-- Name: discount_codes discount_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_codes
    ADD CONSTRAINT discount_codes_pkey PRIMARY KEY (id);


--
-- Name: email_verification_tokens email_verification_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_pkey PRIMARY KEY (id);


--
-- Name: email_verification_tokens email_verification_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_token_key UNIQUE (token);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_token_key UNIQUE (token);


--
-- Name: payment_gateway_settings payment_gateway_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_gateway_settings
    ADD CONSTRAINT payment_gateway_settings_pkey PRIMARY KEY (id);


--
-- Name: payment_transactions payment_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scout_activity_logs scout_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scout_activity_logs
    ADD CONSTRAINT scout_activity_logs_pkey PRIMARY KEY (id);


--
-- Name: scout_profiles scout_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scout_profiles
    ADD CONSTRAINT scout_profiles_pkey PRIMARY KEY (id);


--
-- Name: scout_profiles scout_profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scout_profiles
    ADD CONSTRAINT scout_profiles_user_id_key UNIQUE (user_id);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: tutor_activation_tokens tutor_activation_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor_activation_tokens
    ADD CONSTRAINT tutor_activation_tokens_pkey PRIMARY KEY (id);


--
-- Name: tutor_activation_tokens tutor_activation_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor_activation_tokens
    ADD CONSTRAINT tutor_activation_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: tutor_legal_consents tutor_legal_consents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor_legal_consents
    ADD CONSTRAINT tutor_legal_consents_pkey PRIMARY KEY (id);


--
-- Name: verifier_delegates unique_user_org; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verifier_delegates
    ADD CONSTRAINT unique_user_org UNIQUE (user_id, organization_id);


--
-- Name: user_social_identities uq_social_identity_provider_uid; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_social_identities
    ADD CONSTRAINT uq_social_identity_provider_uid UNIQUE (provider, provider_user_id);


--
-- Name: user_social_identities uq_social_identity_user_provider; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_social_identities
    ADD CONSTRAINT uq_social_identity_user_provider UNIQUE (user_id, provider);


--
-- Name: user_social_identities user_social_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_social_identities
    ADD CONSTRAINT user_social_identities_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: verifier_delegates verifier_delegates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verifier_delegates
    ADD CONSTRAINT verifier_delegates_pkey PRIMARY KEY (id);


--
-- Name: idx_athlete_legal_consents_athlete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_athlete_legal_consents_athlete ON public.athlete_legal_consents USING btree (athlete_id);


--
-- Name: idx_athlete_legal_consents_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_athlete_legal_consents_user ON public.athlete_legal_consents USING btree (user_id);


--
-- Name: idx_athletes_filter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_athletes_filter ON public.athletes USING btree (birth_date, primary_position, current_club_id);


--
-- Name: idx_athletes_legal_verification_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_athletes_legal_verification_status ON public.athletes USING btree (legal_verification_status);


--
-- Name: idx_athletes_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_athletes_slug ON public.athletes USING btree (slug);


--
-- Name: idx_badges_athlete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_badges_athlete ON public.athlete_badges USING btree (athlete_id, status);


--
-- Name: idx_bulk_import_jobs_scout; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bulk_import_jobs_scout ON public.bulk_import_jobs USING btree (scout_id);


--
-- Name: idx_bulk_import_jobs_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bulk_import_jobs_status ON public.bulk_import_jobs USING btree (status);


--
-- Name: idx_cert_req_athlete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cert_req_athlete ON public.certification_requests USING btree (athlete_id, status);


--
-- Name: idx_cert_req_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cert_req_status ON public.certification_requests USING btree (status);


--
-- Name: idx_cert_req_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cert_req_token ON public.certification_requests USING btree (token_hash);


--
-- Name: idx_discount_codes_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_discount_codes_active ON public.discount_codes USING btree (is_active);


--
-- Name: idx_discount_codes_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_discount_codes_code ON public.discount_codes USING btree (code);


--
-- Name: idx_discount_codes_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_discount_codes_org ON public.discount_codes USING btree (organization_id);


--
-- Name: idx_email_verification_tokens_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_verification_tokens_token ON public.email_verification_tokens USING btree (token);


--
-- Name: idx_email_verification_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_verification_tokens_user_id ON public.email_verification_tokens USING btree (user_id);


--
-- Name: idx_password_reset_tokens_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_token ON public.password_reset_tokens USING btree (token);


--
-- Name: idx_password_reset_tokens_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_tokens_user_id ON public.password_reset_tokens USING btree (user_id);


--
-- Name: idx_payment_transactions_reference_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_payment_transactions_reference_unique ON public.payment_transactions USING btree (reference_number) WHERE ((reference_number IS NOT NULL) AND ((reference_number)::text <> ''::text));


--
-- Name: idx_payment_tx_gateway_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_tx_gateway_order ON public.payment_transactions USING btree (gateway_order_id);


--
-- Name: idx_payment_tx_method_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_tx_method_status ON public.payment_transactions USING btree (method, status);


--
-- Name: idx_redemptions_code_athlete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_redemptions_code_athlete ON public.discount_code_redemptions USING btree (discount_code_id, athlete_id);


--
-- Name: idx_redemptions_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_redemptions_user ON public.discount_code_redemptions USING btree (user_id);


--
-- Name: idx_scout_activity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_scout_activity ON public.scout_activity_logs USING btree (athlete_id, created_at DESC);


--
-- Name: idx_tutor_activation_tokens_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tutor_activation_tokens_hash ON public.tutor_activation_tokens USING btree (token_hash);


--
-- Name: idx_user_social_identities_provider_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_social_identities_provider_email ON public.user_social_identities USING btree (provider_email);


--
-- Name: idx_user_social_identities_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_social_identities_user_id ON public.user_social_identities USING btree (user_id);


--
-- Name: idx_videos_athlete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_videos_athlete ON public.athlete_videos USING btree (athlete_id, sort_order);


--
-- Name: athlete_badges athlete_badges_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_badges
    ADD CONSTRAINT athlete_badges_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: athlete_badges athlete_badges_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_badges
    ADD CONSTRAINT athlete_badges_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.clubs_organizations(id) ON DELETE SET NULL;


--
-- Name: athlete_badges athlete_badges_verified_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_badges
    ADD CONSTRAINT athlete_badges_verified_by_user_id_fkey FOREIGN KEY (verified_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: athlete_legal_consents athlete_legal_consents_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_legal_consents
    ADD CONSTRAINT athlete_legal_consents_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: athlete_legal_consents athlete_legal_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_legal_consents
    ADD CONSTRAINT athlete_legal_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: athlete_subscriptions athlete_subscriptions_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_subscriptions
    ADD CONSTRAINT athlete_subscriptions_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: athlete_subscriptions athlete_subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_subscriptions
    ADD CONSTRAINT athlete_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id);


--
-- Name: athlete_videos athlete_videos_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_videos
    ADD CONSTRAINT athlete_videos_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: athletes athletes_current_club_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes
    ADD CONSTRAINT athletes_current_club_id_fkey FOREIGN KEY (current_club_id) REFERENCES public.clubs_organizations(id) ON DELETE SET NULL;


--
-- Name: athletes athletes_legal_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes
    ADD CONSTRAINT athletes_legal_verified_by_fkey FOREIGN KEY (legal_verified_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: athletes athletes_tutor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes
    ADD CONSTRAINT athletes_tutor_id_fkey FOREIGN KEY (tutor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bulk_import_jobs bulk_import_jobs_club_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_import_jobs
    ADD CONSTRAINT bulk_import_jobs_club_id_fkey FOREIGN KEY (club_id) REFERENCES public.clubs_organizations(id) ON DELETE SET NULL;


--
-- Name: bulk_import_jobs bulk_import_jobs_scout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_import_jobs
    ADD CONSTRAINT bulk_import_jobs_scout_id_fkey FOREIGN KEY (scout_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: certification_requests certification_requests_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_requests
    ADD CONSTRAINT certification_requests_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: certification_requests certification_requests_badge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_requests
    ADD CONSTRAINT certification_requests_badge_id_fkey FOREIGN KEY (badge_id) REFERENCES public.athlete_badges(id) ON DELETE SET NULL;


--
-- Name: certification_requests certification_requests_reviewed_by_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certification_requests
    ADD CONSTRAINT certification_requests_reviewed_by_admin_id_fkey FOREIGN KEY (reviewed_by_admin_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: discount_code_redemptions discount_code_redemptions_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_code_redemptions
    ADD CONSTRAINT discount_code_redemptions_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: discount_code_redemptions discount_code_redemptions_discount_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_code_redemptions
    ADD CONSTRAINT discount_code_redemptions_discount_code_id_fkey FOREIGN KEY (discount_code_id) REFERENCES public.discount_codes(id) ON DELETE CASCADE;


--
-- Name: discount_code_redemptions discount_code_redemptions_payment_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_code_redemptions
    ADD CONSTRAINT discount_code_redemptions_payment_transaction_id_fkey FOREIGN KEY (payment_transaction_id) REFERENCES public.payment_transactions(id) ON DELETE SET NULL;


--
-- Name: discount_code_redemptions discount_code_redemptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_code_redemptions
    ADD CONSTRAINT discount_code_redemptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: discount_codes discount_codes_applicable_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_codes
    ADD CONSTRAINT discount_codes_applicable_plan_id_fkey FOREIGN KEY (applicable_plan_id) REFERENCES public.subscription_plans(id) ON DELETE SET NULL;


--
-- Name: discount_codes discount_codes_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discount_codes
    ADD CONSTRAINT discount_codes_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.clubs_organizations(id) ON DELETE SET NULL;


--
-- Name: email_verification_tokens email_verification_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: password_reset_tokens password_reset_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payment_transactions payment_transactions_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: payment_transactions payment_transactions_audited_by_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_audited_by_admin_id_fkey FOREIGN KEY (audited_by_admin_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: payment_transactions payment_transactions_discount_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_discount_code_id_fkey FOREIGN KEY (discount_code_id) REFERENCES public.discount_codes(id) ON DELETE SET NULL;


--
-- Name: payment_transactions payment_transactions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id);


--
-- Name: payment_transactions payment_transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_transactions
    ADD CONSTRAINT payment_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: scout_activity_logs scout_activity_logs_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scout_activity_logs
    ADD CONSTRAINT scout_activity_logs_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: scout_activity_logs scout_activity_logs_scout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scout_activity_logs
    ADD CONSTRAINT scout_activity_logs_scout_id_fkey FOREIGN KEY (scout_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: scout_activity_logs scout_activity_logs_video_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scout_activity_logs
    ADD CONSTRAINT scout_activity_logs_video_id_fkey FOREIGN KEY (video_id) REFERENCES public.athlete_videos(id) ON DELETE SET NULL;


--
-- Name: scout_profiles scout_profiles_reviewed_by_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scout_profiles
    ADD CONSTRAINT scout_profiles_reviewed_by_admin_id_fkey FOREIGN KEY (reviewed_by_admin_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: scout_profiles scout_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scout_profiles
    ADD CONSTRAINT scout_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tutor_activation_tokens tutor_activation_tokens_tutor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor_activation_tokens
    ADD CONSTRAINT tutor_activation_tokens_tutor_id_fkey FOREIGN KEY (tutor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tutor_legal_consents tutor_legal_consents_tutor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor_legal_consents
    ADD CONSTRAINT tutor_legal_consents_tutor_id_fkey FOREIGN KEY (tutor_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_social_identities user_social_identities_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_social_identities
    ADD CONSTRAINT user_social_identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: verifier_delegates verifier_delegates_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verifier_delegates
    ADD CONSTRAINT verifier_delegates_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.clubs_organizations(id) ON DELETE CASCADE;


--
-- Name: verifier_delegates verifier_delegates_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.verifier_delegates
    ADD CONSTRAINT verifier_delegates_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict dbmate


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20260929171117'),
    ('20261009120000'),
    ('20261010150000'),
    ('20261010153000'),
    ('20261010183000'),
    ('20261010190000'),
    ('20261011120000'),
    ('20261013140000'),
    ('20261013150000'),
    ('20261015220000'),
    ('20261019180000'),
    ('20261026190000'),
    ('20261027120000'),
    ('20261027150000'),
    ('20261030103000'),
    ('20261103103000'),
    ('20261106140000'),
    ('20261106220000'),
    ('20261109120000'),
    ('20261112092325'),
    ('20261112111949');
