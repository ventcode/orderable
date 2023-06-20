SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: basic_models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.basic_models (
    id integer NOT NULL,
    name character varying NOT NULL,
    "position" integer
);


--
-- Name: basic_models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.basic_models_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: basic_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.basic_models_id_seq OWNED BY public.basic_models.id;


--
-- Name: model_with_many_scopes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.model_with_many_scopes (
    id integer NOT NULL,
    name character varying NOT NULL,
    kind character varying,
    "group" character varying,
    "position" integer
);


--
-- Name: model_with_many_scopes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.model_with_many_scopes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: model_with_many_scopes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.model_with_many_scopes_id_seq OWNED BY public.model_with_many_scopes.id;


--
-- Name: model_with_one_scopes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.model_with_one_scopes (
    id integer NOT NULL,
    name character varying NOT NULL,
    kind character varying,
    "position" integer
);


--
-- Name: model_with_one_scopes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.model_with_one_scopes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: model_with_one_scopes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.model_with_one_scopes_id_seq OWNED BY public.model_with_one_scopes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: basic_models id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basic_models ALTER COLUMN id SET DEFAULT nextval('public.basic_models_id_seq'::regclass);


--
-- Name: model_with_many_scopes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_with_many_scopes ALTER COLUMN id SET DEFAULT nextval('public.model_with_many_scopes_id_seq'::regclass);


--
-- Name: model_with_one_scopes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_with_one_scopes ALTER COLUMN id SET DEFAULT nextval('public.model_with_one_scopes_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: basic_models basic_models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basic_models
    ADD CONSTRAINT basic_models_pkey PRIMARY KEY (id);


--
-- Name: basic_models basic_models_position_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.basic_models
    ADD CONSTRAINT basic_models_position_key UNIQUE ("position") DEFERRABLE INITIALLY DEFERRED;


--
-- Name: model_with_many_scopes model_with_many_scopes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_with_many_scopes
    ADD CONSTRAINT model_with_many_scopes_pkey PRIMARY KEY (id);


--
-- Name: model_with_many_scopes model_with_many_scopes_position_kind_group_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_with_many_scopes
    ADD CONSTRAINT model_with_many_scopes_position_kind_group_key UNIQUE ("position", kind, "group") DEFERRABLE INITIALLY DEFERRED;


--
-- Name: model_with_one_scopes model_with_one_scopes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_with_one_scopes
    ADD CONSTRAINT model_with_one_scopes_pkey PRIMARY KEY (id);


--
-- Name: model_with_one_scopes model_with_one_scopes_position_kind_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.model_with_one_scopes
    ADD CONSTRAINT model_with_one_scopes_position_kind_key UNIQUE ("position", kind) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20220727164055'),
('20220819131546'),
('20220905093935'),
('20220905094043'),
('20220905094138'),
('20220905094233');


