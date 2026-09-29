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
    'SUSPENDED'
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
-- Name: payment_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.payment_method AS ENUM (
    'PAGO_MOVIL',
    'BINANCE_PAY',
    'ZINLI_WALLY_ZELLE',
    'STRIPE'
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
    'ADMIN'
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: athlete_badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athlete_badges (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
-- Name: athlete_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athlete_subscriptions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: clubs_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clubs_organizations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
-- Name: payment_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_transactions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: scout_activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scout_activity_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    organization_name character varying(150) NOT NULL,
    scout_role character varying(100) NOT NULL,
    credentials_document_url text NOT NULL,
    linkedin_url text,
    verification_status public.scout_verification_status DEFAULT 'PENDING'::public.scout_verification_status NOT NULL,
    reviewed_by_admin_id uuid,
    reviewed_at timestamp with time zone,
    rejection_reason text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
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
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: tutor_legal_consents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tutor_legal_consents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tutor_id uuid NOT NULL,
    accepted_lopnna_terms boolean DEFAULT true NOT NULL,
    terms_version character varying(20) DEFAULT '1.0'::character varying NOT NULL,
    ip_address character varying(45) NOT NULL,
    user_agent text NOT NULL,
    accepted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(150) NOT NULL,
    phone_number character varying(30) NOT NULL,
    role public.user_role DEFAULT 'TUTOR'::public.user_role NOT NULL,
    status public.account_status DEFAULT 'ACTIVE'::public.account_status NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: verifier_delegates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.verifier_delegates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
-- Name: clubs_organizations clubs_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clubs_organizations
    ADD CONSTRAINT clubs_organizations_pkey PRIMARY KEY (id);


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
-- Name: idx_athletes_filter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_athletes_filter ON public.athletes USING btree (birth_date, primary_position, current_club_id);


--
-- Name: idx_athletes_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_athletes_slug ON public.athletes USING btree (slug);


--
-- Name: idx_badges_athlete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_badges_athlete ON public.athlete_badges USING btree (athlete_id, status);


--
-- Name: idx_scout_activity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_scout_activity ON public.scout_activity_logs USING btree (athlete_id, created_at DESC);


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
-- Name: athletes athletes_tutor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes
    ADD CONSTRAINT athletes_tutor_id_fkey FOREIGN KEY (tutor_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
-- Name: tutor_legal_consents tutor_legal_consents_tutor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tutor_legal_consents
    ADD CONSTRAINT tutor_legal_consents_tutor_id_fkey FOREIGN KEY (tutor_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
    ('20260929171117');
