--
-- PostgreSQL database dump
--

\restrict g3MZVP7CFAiUkdlRb2lx5p0mshEQzV6w1V3TYlYOYNNbamOzbbAGAwhL9e40X16

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-10-08 18:46:47

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
-- TOC entry 2 (class 3079 OID 19660)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 3 (class 3079 OID 19698)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 19709)
-- Name: EmailConfigurations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."EmailConfigurations" (
    "Id" uuid NOT NULL,
    "SchoolId" uuid NOT NULL,
    "SmtpServer" character varying(255) NOT NULL,
    "SmtpPort" integer NOT NULL,
    "SmtpUsername" character varying(255) NOT NULL,
    "SmtpPassword" text NOT NULL,
    "SmtpUseSsl" boolean NOT NULL,
    "SmtpUseTls" boolean NOT NULL,
    "FromEmail" character varying(255) NOT NULL,
    "FromName" character varying(255) NOT NULL,
    "IsActive" boolean NOT NULL,
    "CreatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UpdatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."EmailConfigurations" OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 19729)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 19734)
-- Name: activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    subject_id uuid,
    teacher_id uuid,
    group_id uuid,
    name character varying(100) NOT NULL,
    type character varying(20) NOT NULL,
    trimester character varying(5),
    pdf_url text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    grade_level_id uuid,
    "ActivityTypeId" uuid,
    "TrimesterId" uuid,
    due_date timestamp with time zone,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.activities OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 19744)
-- Name: activity_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    activity_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    storage_path character varying(500) NOT NULL,
    mime_type character varying(50) NOT NULL,
    uploaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.activity_attachments OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 19757)
-- Name: activity_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    school_id uuid,
    name character varying(30) NOT NULL,
    description text,
    icon character varying(50),
    color character varying(20),
    is_global boolean DEFAULT false NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


ALTER TABLE public.activity_types OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 19773)
-- Name: area; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.area (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    school_id uuid,
    name character varying(100) NOT NULL,
    description text,
    code character varying(20),
    is_global boolean DEFAULT false NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


ALTER TABLE public.area OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 19789)
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    teacher_id uuid,
    group_id uuid,
    grade_id uuid,
    date date NOT NULL,
    status character varying(10) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone,
    school_id uuid
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 19797)
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    user_id uuid,
    user_name character varying(100),
    user_role character varying(20),
    action character varying(30),
    resource character varying(50),
    details text,
    ip_address character varying(50),
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 19805)
-- Name: counselor_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.counselor_assignments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    user_id uuid NOT NULL,
    grade_id uuid,
    group_id uuid,
    is_counselor boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid
);


ALTER TABLE public.counselor_assignments OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 19818)
-- Name: discipline_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discipline_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid,
    teacher_id uuid,
    date timestamp with time zone NOT NULL,
    report_type character varying(50),
    description text,
    status character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    subject_id uuid,
    group_id uuid,
    grade_level_id uuid,
    created_by uuid,
    updated_by uuid,
    school_id uuid
);


ALTER TABLE public.discipline_reports OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 19828)
-- Name: email_configurations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    school_id uuid NOT NULL,
    smtp_server character varying(255) NOT NULL,
    smtp_port integer DEFAULT 587 NOT NULL,
    smtp_username character varying(255) NOT NULL,
    smtp_password text NOT NULL,
    smtp_use_ssl boolean DEFAULT true NOT NULL,
    smtp_use_tls boolean DEFAULT true NOT NULL,
    from_email character varying(255) NOT NULL,
    from_name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.email_configurations OWNER TO postgres;

--
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE email_configurations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.email_configurations IS 'Configuración de servidores SMTP para cada escuela';


--
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN email_configurations.smtp_use_ssl; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.email_configurations.smtp_use_ssl IS 'Usar SSL para conexión SMTP';


--
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN email_configurations.smtp_use_tls; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.email_configurations.smtp_use_tls IS 'Usar TLS para conexión SMTP';


--
-- TOC entry 232 (class 1259 OID 19851)
-- Name: grade_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grade_levels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone,
    school_id uuid
);


ALTER TABLE public.grade_levels OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 19860)
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(20) NOT NULL,
    grade character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    description text,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 19869)
-- Name: schools; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schools (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(200) DEFAULT ''::character varying NOT NULL,
    phone character varying(20) DEFAULT ''::character varying NOT NULL,
    logo_url character varying(500),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    admin_id uuid,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid
);


ALTER TABLE public.schools OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 19882)
-- Name: security_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.security_settings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    password_min_length integer DEFAULT 8,
    require_uppercase boolean DEFAULT true,
    require_lowercase boolean DEFAULT true,
    require_numbers boolean DEFAULT true,
    require_special boolean DEFAULT true,
    expiry_days integer DEFAULT 90,
    prevent_reuse integer DEFAULT 5,
    max_login_attempts integer DEFAULT 5,
    session_timeout_minutes integer DEFAULT 30,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.security_settings OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 19897)
-- Name: specialties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specialties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone,
    school_id uuid
);


ALTER TABLE public.specialties OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 19906)
-- Name: student_activity_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_activity_scores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    activity_id uuid NOT NULL,
    score numeric(2,1),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone,
    school_id uuid
);


ALTER TABLE public.student_activity_scores OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 19915)
-- Name: student_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    grade_id uuid NOT NULL,
    group_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.student_assignments OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 19924)
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(100) NOT NULL,
    birth_date date,
    grade character varying(20),
    group_name character varying(20),
    parent_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 19931)
-- Name: subject_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subject_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    specialty_id uuid NOT NULL,
    area_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    grade_level_id uuid NOT NULL,
    group_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(10),
    "SchoolId" uuid,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid
);


ALTER TABLE public.subject_assignments OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 19942)
-- Name: subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subjects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(100) NOT NULL,
    code character varying(10),
    description text,
    status boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "AreaId" uuid,
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.subjects OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 19952)
-- Name: teacher_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    teacher_id uuid NOT NULL,
    subject_assignment_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid
);


ALTER TABLE public.teacher_assignments OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 19960)
-- Name: trimester; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trimester (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    school_id uuid,
    name character varying(50) NOT NULL,
    description text,
    "order" integer NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    created_by uuid,
    updated_by uuid
);


ALTER TABLE public.trimester OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 19975)
-- Name: user_grades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_grades (
    user_id uuid NOT NULL,
    grade_id uuid NOT NULL
);


ALTER TABLE public.user_grades OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 19980)
-- Name: user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_groups (
    user_id uuid NOT NULL,
    group_id uuid NOT NULL
);


ALTER TABLE public.user_groups OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 19985)
-- Name: user_subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_subjects (
    user_id uuid NOT NULL,
    subject_id uuid NOT NULL
);


ALTER TABLE public.user_subjects OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 19990)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(100) NOT NULL,
    role character varying(20) NOT NULL,
    status character varying(10) DEFAULT 'active'::character varying,
    two_factor_enabled boolean DEFAULT false,
    last_login timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_name character varying(100) DEFAULT ''::character varying NOT NULL,
    document_id character varying(50),
    date_of_birth timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" timestamp with time zone,
    cellphone_primary character varying(20),
    cellphone_secondary character varying(20),
    created_by uuid,
    updated_by uuid,
    updated_at timestamp with time zone,
    disciplina boolean,
    inclusion text,
    orientacion boolean,
    inclusivo boolean,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('superadmin'::character varying)::text, ('admin'::character varying)::text, ('director'::character varying)::text, ('teacher'::character varying)::text, ('parent'::character varying)::text, ('student'::character varying)::text, ('estudiante'::character varying)::text]))),
    CONSTRAINT users_status_check CHECK (((status)::text = ANY (ARRAY[('active'::character varying)::text, ('inactive'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN users.cellphone_primary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.cellphone_primary IS 'Número de celular principal del usuario';


--
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN users.cellphone_secondary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.cellphone_secondary IS 'Número de celular secundario del usuario';


--
-- TOC entry 5410 (class 0 OID 19709)
-- Dependencies: 221
-- Data for Name: EmailConfigurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."EmailConfigurations" ("Id", "SchoolId", "SmtpServer", "SmtpPort", "SmtpUsername", "SmtpPassword", "SmtpUseSsl", "SmtpUseTls", "FromEmail", "FromName", "IsActive", "CreatedAt", "UpdatedAt") FROM stdin;
\.


--
-- TOC entry 5411 (class 0 OID 19729)
-- Dependencies: 222
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20250614054002_InitialCreate	9.0.3
20250614055224_AddSchoolLogoUrl	9.0.3
20250614061316_AddUserSchoolRelation	9.0.3
20250614061637_UpdateDateTimeColumns	9.0.3
20250615014045_AddSchoolIdToSubjectAssignment	9.0.3
20250706000831_AddDueDateToActivity	9.0.3
20250706025309_UpdateDateTimeColumnsToTimeZone	9.0.3
20250706025701_UpdateTrimesterDateTimeColumns	9.0.3
20250706030546_UpdateSubjectAssignmentDateTimeColumns	9.0.3
20250706031228_UpdateStudentAssignmentDateTimeColumns	9.0.3
20250706035555_UpdateDateTimeColumnsForCatalogEntities	9.0.3
20250706035923_FixDateTimeColumnsForCatalogEntities	9.0.3
20250706051930_AddDueDateToActivityType	9.0.3
20250706052315_ForceAddDueDateToActivityType	9.0.3
20250706053435_UpdateActivityDateTimeColumns	9.0.3
20250706183418_FixActivityDueDateTimezone	9.0.3
20250706184907_FixAllDateTimeTimezones	9.0.3
20250706185108_FixUserDateTimeTimezones	9.0.3
20250708002546_CheckSync	9.0.3
20250711021919_FixAttendanceDateTimeTimezone	9.0.3
20250711022902_FixAttendanceCreatedAtTimezone	9.0.3
20250711023056_ApplyAttendanceCreatedAtTimezoneFix	9.0.3
20250711024652_FixAttendanceCreatedAtOnly	9.0.3
20250906222853_AddEmailConfigurationModel	9.0.3
20250108000000_AddCellphoneFieldsToUser	8.0.0
\.


--
-- TOC entry 5412 (class 0 OID 19734)
-- Dependencies: 223
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (id, school_id, subject_id, teacher_id, group_id, name, type, trimester, pdf_url, created_at, grade_level_id, "ActivityTypeId", "TrimesterId", due_date, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5413 (class 0 OID 19744)
-- Dependencies: 224
-- Data for Name: activity_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_attachments (id, activity_id, file_name, storage_path, mime_type, uploaded_at, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5414 (class 0 OID 19757)
-- Dependencies: 225
-- Data for Name: activity_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_types (id, school_id, name, description, icon, color, is_global, display_order, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
\.


--
-- TOC entry 5415 (class 0 OID 19773)
-- Dependencies: 226
-- Data for Name: area; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.area (id, school_id, name, description, code, is_global, display_order, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
\.


--
-- TOC entry 5416 (class 0 OID 19789)
-- Dependencies: 227
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, student_id, teacher_id, group_id, grade_id, date, status, created_at, created_by, updated_by, updated_at, school_id) FROM stdin;
\.


--
-- TOC entry 5417 (class 0 OID 19797)
-- Dependencies: 228
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, school_id, user_id, user_name, user_role, action, resource, details, ip_address, "timestamp", created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5418 (class 0 OID 19805)
-- Dependencies: 229
-- Data for Name: counselor_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.counselor_assignments (id, school_id, user_id, grade_id, group_id, is_counselor, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
\.


--
-- TOC entry 5419 (class 0 OID 19818)
-- Dependencies: 230
-- Data for Name: discipline_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discipline_reports (id, student_id, teacher_id, date, report_type, description, status, created_at, updated_at, subject_id, group_id, grade_level_id, created_by, updated_by, school_id) FROM stdin;
\.


--
-- TOC entry 5420 (class 0 OID 19828)
-- Dependencies: 231
-- Data for Name: email_configurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_configurations (id, school_id, smtp_server, smtp_port, smtp_username, smtp_password, smtp_use_ssl, smtp_use_tls, from_email, from_name, is_active, created_at, updated_at) FROM stdin;
5138fe6e-e0ae-4b5d-a2f6-9473a78e27ec	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	smtp.gmail.com	587	irvingcorrosk19@gmail.com	mqxahytcidbjobad	f	t	irvingcorrosk19@gmail.com	IPT San Miguelito	t	2025-09-06 21:36:52.236737-05	2025-09-06 22:15:30.323577-05
\.


--
-- TOC entry 5421 (class 0 OID 19851)
-- Dependencies: 232
-- Data for Name: grade_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grade_levels (id, name, description, created_at, created_by, updated_by, updated_at, school_id) FROM stdin;
\.


--
-- TOC entry 5422 (class 0 OID 19860)
-- Dependencies: 233
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, school_id, name, grade, created_at, description, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5423 (class 0 OID 19869)
-- Dependencies: 234
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schools (id, name, address, phone, logo_url, created_at, admin_id, created_by, updated_at, updated_by) FROM stdin;
ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	IPT San Miguelito	Panamá, San Miguelito, Belisario Frias, Torrijos Carter, Calle Principal	260-9999	5d2faabb-a88e-44a0-beb5-32b7d951a194_ElPorvenir.png	2025-09-06 16:58:50.703258-05	21e66209-995a-4182-98e9-33d2ab635b48	\N	\N	\N
\.


--
-- TOC entry 5424 (class 0 OID 19882)
-- Dependencies: 235
-- Data for Name: security_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.security_settings (id, school_id, password_min_length, require_uppercase, require_lowercase, require_numbers, require_special, expiry_days, prevent_reuse, max_login_attempts, session_timeout_minutes, created_at, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5425 (class 0 OID 19897)
-- Dependencies: 236
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialties (id, name, description, created_at, created_by, updated_by, updated_at, school_id) FROM stdin;
\.


--
-- TOC entry 5426 (class 0 OID 19906)
-- Dependencies: 237
-- Data for Name: student_activity_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_activity_scores (id, student_id, activity_id, score, created_at, created_by, updated_by, updated_at, school_id) FROM stdin;
\.


--
-- TOC entry 5427 (class 0 OID 19915)
-- Dependencies: 238
-- Data for Name: student_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_assignments (id, student_id, grade_id, group_id, created_at, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5428 (class 0 OID 19924)
-- Dependencies: 239
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, school_id, name, birth_date, grade, group_name, parent_id, created_at, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5429 (class 0 OID 19931)
-- Dependencies: 240
-- Data for Name: subject_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subject_assignments (id, specialty_id, area_id, subject_id, grade_level_id, group_id, created_at, status, "SchoolId", created_by, updated_at, updated_by) FROM stdin;
\.


--
-- TOC entry 5430 (class 0 OID 19942)
-- Dependencies: 241
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, school_id, name, code, description, status, created_at, "AreaId", created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5431 (class 0 OID 19952)
-- Dependencies: 242
-- Data for Name: teacher_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_assignments (id, teacher_id, subject_assignment_id, created_at, created_by, updated_at, updated_by) FROM stdin;
\.


--
-- TOC entry 5432 (class 0 OID 19960)
-- Dependencies: 243
-- Data for Name: trimester; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trimester (id, school_id, name, description, "order", start_date, end_date, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
\.


--
-- TOC entry 5433 (class 0 OID 19975)
-- Dependencies: 244
-- Data for Name: user_grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_grades (user_id, grade_id) FROM stdin;
\.


--
-- TOC entry 5434 (class 0 OID 19980)
-- Dependencies: 245
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_groups (user_id, group_id) FROM stdin;
\.


--
-- TOC entry 5435 (class 0 OID 19985)
-- Dependencies: 246
-- Data for Name: user_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_subjects (user_id, subject_id) FROM stdin;
\.


--
-- TOC entry 5436 (class 0 OID 19990)
-- Dependencies: 247
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, school_id, name, email, password_hash, role, status, two_factor_enabled, last_login, created_at, last_name, document_id, date_of_birth, "UpdatedAt", cellphone_primary, cellphone_secondary, created_by, updated_by, updated_at, disciplina, inclusion, orientacion, inclusivo) FROM stdin;
b5cb04ba-8b09-4f7c-bf34-6fed01fa080b	\N	admin@correo.com	admin@correo.com	$2a$11$ijYC6tyYjXnk.l2uWu.0QeINxiYVKAVhEHwTbaTg5CUtEtlTEZ8i6	superadmin	active	f	2025-09-08 23:38:59.273493-05	2025-04-11 22:55:18.363537-05	Corro	DOC000016	2025-04-22 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
21e66209-995a-4182-98e9-33d2ab635b48	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Quenna	quenna.lopez@qlservice.net	$2a$11$ijYC6tyYjXnk.l2uWu.0QeINxiYVKAVhEHwTbaTg5CUtEtlTEZ8i6	admin	active	f	2025-10-08 18:09:15.265875-05	2025-09-06 11:58:51.905454-05	Lopez	\N	2025-09-05 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5089 (class 2606 OID 20011)
-- Name: EmailConfigurations PK_EmailConfigurations; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmailConfigurations"
    ADD CONSTRAINT "PK_EmailConfigurations" PRIMARY KEY ("Id");


--
-- TOC entry 5091 (class 2606 OID 20013)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 5097 (class 2606 OID 20015)
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- TOC entry 5103 (class 2606 OID 20017)
-- Name: activity_attachments activity_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 5108 (class 2606 OID 20019)
-- Name: activity_types activity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5112 (class 2606 OID 20021)
-- Name: area area_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--
-- TOC entry 5118 (class 2606 OID 20023)
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- TOC entry 5122 (class 2606 OID 20025)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 5124 (class 2606 OID 20027)
-- Name: counselor_assignments counselor_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5137 (class 2606 OID 20029)
-- Name: discipline_reports discipline_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 5139 (class 2606 OID 20031)
-- Name: email_configurations email_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_configurations
    ADD CONSTRAINT email_configurations_pkey PRIMARY KEY (id);


--
-- TOC entry 5143 (class 2606 OID 20033)
-- Name: grade_levels grade_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_levels
    ADD CONSTRAINT grade_levels_pkey PRIMARY KEY (id);


--
-- TOC entry 5146 (class 2606 OID 20035)
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- TOC entry 5149 (class 2606 OID 20037)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 5152 (class 2606 OID 20039)
-- Name: security_settings security_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 5155 (class 2606 OID 20041)
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- TOC entry 5159 (class 2606 OID 20043)
-- Name: student_activity_scores student_activity_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 5165 (class 2606 OID 20045)
-- Name: student_assignments student_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT student_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5169 (class 2606 OID 20047)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 5176 (class 2606 OID 20049)
-- Name: subject_assignments subject_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5180 (class 2606 OID 20051)
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 5183 (class 2606 OID 20053)
-- Name: teacher_assignments teacher_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5188 (class 2606 OID 20055)
-- Name: trimester trimester_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_pkey PRIMARY KEY (id);


--
-- TOC entry 5191 (class 2606 OID 20057)
-- Name: user_grades user_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT user_grades_pkey PRIMARY KEY (user_id, grade_id);


--
-- TOC entry 5194 (class 2606 OID 20059)
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (user_id, group_id);


--
-- TOC entry 5197 (class 2606 OID 20061)
-- Name: user_subjects user_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT user_subjects_pkey PRIMARY KEY (user_id, subject_id);


--
-- TOC entry 5204 (class 2606 OID 20063)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5087 (class 1259 OID 20064)
-- Name: IX_EmailConfigurations_SchoolId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_EmailConfigurations_SchoolId" ON public."EmailConfigurations" USING btree ("SchoolId");


--
-- TOC entry 5092 (class 1259 OID 20065)
-- Name: IX_activities_ActivityTypeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_ActivityTypeId" ON public.activities USING btree ("ActivityTypeId");


--
-- TOC entry 5093 (class 1259 OID 20066)
-- Name: IX_activities_TrimesterId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_TrimesterId" ON public.activities USING btree ("TrimesterId");


--
-- TOC entry 5094 (class 1259 OID 20067)
-- Name: IX_activities_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_school_id" ON public.activities USING btree (school_id);


--
-- TOC entry 5095 (class 1259 OID 20068)
-- Name: IX_activities_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_subject_id" ON public.activities USING btree (subject_id);


--
-- TOC entry 5105 (class 1259 OID 20069)
-- Name: IX_activity_types_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activity_types_school_id" ON public.activity_types USING btree (school_id);


--
-- TOC entry 5109 (class 1259 OID 20070)
-- Name: IX_area_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_area_school_id" ON public.area USING btree (school_id);


--
-- TOC entry 5113 (class 1259 OID 20071)
-- Name: IX_attendance_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_grade_id" ON public.attendance USING btree (grade_id);


--
-- TOC entry 5114 (class 1259 OID 20072)
-- Name: IX_attendance_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_group_id" ON public.attendance USING btree (group_id);


--
-- TOC entry 5115 (class 1259 OID 20073)
-- Name: IX_attendance_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_student_id" ON public.attendance USING btree (student_id);


--
-- TOC entry 5116 (class 1259 OID 20074)
-- Name: IX_attendance_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_teacher_id" ON public.attendance USING btree (teacher_id);


--
-- TOC entry 5119 (class 1259 OID 20075)
-- Name: IX_audit_logs_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_audit_logs_school_id" ON public.audit_logs USING btree (school_id);


--
-- TOC entry 5120 (class 1259 OID 20076)
-- Name: IX_audit_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_audit_logs_user_id" ON public.audit_logs USING btree (user_id);


--
-- TOC entry 5131 (class 1259 OID 20077)
-- Name: IX_discipline_reports_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_grade_level_id" ON public.discipline_reports USING btree (grade_level_id);


--
-- TOC entry 5132 (class 1259 OID 20078)
-- Name: IX_discipline_reports_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_group_id" ON public.discipline_reports USING btree (group_id);


--
-- TOC entry 5133 (class 1259 OID 20079)
-- Name: IX_discipline_reports_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_student_id" ON public.discipline_reports USING btree (student_id);


--
-- TOC entry 5134 (class 1259 OID 20080)
-- Name: IX_discipline_reports_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_subject_id" ON public.discipline_reports USING btree (subject_id);


--
-- TOC entry 5135 (class 1259 OID 20081)
-- Name: IX_discipline_reports_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_teacher_id" ON public.discipline_reports USING btree (teacher_id);


--
-- TOC entry 5144 (class 1259 OID 20082)
-- Name: IX_groups_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_groups_school_id" ON public.groups USING btree (school_id);


--
-- TOC entry 5147 (class 1259 OID 20083)
-- Name: IX_schools_admin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_schools_admin_id" ON public.schools USING btree (admin_id);


--
-- TOC entry 5150 (class 1259 OID 20084)
-- Name: IX_security_settings_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_security_settings_school_id" ON public.security_settings USING btree (school_id);


--
-- TOC entry 5161 (class 1259 OID 20085)
-- Name: IX_student_assignments_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_grade_id" ON public.student_assignments USING btree (grade_id);


--
-- TOC entry 5162 (class 1259 OID 20086)
-- Name: IX_student_assignments_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_group_id" ON public.student_assignments USING btree (group_id);


--
-- TOC entry 5163 (class 1259 OID 20087)
-- Name: IX_student_assignments_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_student_id" ON public.student_assignments USING btree (student_id);


--
-- TOC entry 5166 (class 1259 OID 20088)
-- Name: IX_students_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_students_parent_id" ON public.students USING btree (parent_id);


--
-- TOC entry 5167 (class 1259 OID 20089)
-- Name: IX_students_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_students_school_id" ON public.students USING btree (school_id);


--
-- TOC entry 5170 (class 1259 OID 20090)
-- Name: IX_subject_assignments_SchoolId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_SchoolId" ON public.subject_assignments USING btree ("SchoolId");


--
-- TOC entry 5171 (class 1259 OID 20091)
-- Name: IX_subject_assignments_area_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_area_id" ON public.subject_assignments USING btree (area_id);


--
-- TOC entry 5172 (class 1259 OID 20092)
-- Name: IX_subject_assignments_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_grade_level_id" ON public.subject_assignments USING btree (grade_level_id);


--
-- TOC entry 5173 (class 1259 OID 20093)
-- Name: IX_subject_assignments_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_group_id" ON public.subject_assignments USING btree (group_id);


--
-- TOC entry 5174 (class 1259 OID 20094)
-- Name: IX_subject_assignments_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_subject_id" ON public.subject_assignments USING btree (subject_id);


--
-- TOC entry 5177 (class 1259 OID 20095)
-- Name: IX_subjects_AreaId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subjects_AreaId" ON public.subjects USING btree ("AreaId");


--
-- TOC entry 5178 (class 1259 OID 20096)
-- Name: IX_subjects_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subjects_school_id" ON public.subjects USING btree (school_id);


--
-- TOC entry 5181 (class 1259 OID 20097)
-- Name: IX_teacher_assignments_subject_assignment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_teacher_assignments_subject_assignment_id" ON public.teacher_assignments USING btree (subject_assignment_id);


--
-- TOC entry 5185 (class 1259 OID 20098)
-- Name: IX_trimester_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_trimester_school_id" ON public.trimester USING btree (school_id);


--
-- TOC entry 5189 (class 1259 OID 20099)
-- Name: IX_user_grades_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_grades_grade_id" ON public.user_grades USING btree (grade_id);


--
-- TOC entry 5192 (class 1259 OID 20100)
-- Name: IX_user_groups_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_groups_group_id" ON public.user_groups USING btree (group_id);


--
-- TOC entry 5195 (class 1259 OID 20101)
-- Name: IX_user_subjects_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_subjects_subject_id" ON public.user_subjects USING btree (subject_id);


--
-- TOC entry 5198 (class 1259 OID 20102)
-- Name: IX_users_cellphone_primary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_cellphone_primary" ON public.users USING btree (cellphone_primary);


--
-- TOC entry 5199 (class 1259 OID 20103)
-- Name: IX_users_cellphone_secondary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_cellphone_secondary" ON public.users USING btree (cellphone_secondary);


--
-- TOC entry 5200 (class 1259 OID 20104)
-- Name: IX_users_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_school_id" ON public.users USING btree (school_id);


--
-- TOC entry 5106 (class 1259 OID 20105)
-- Name: activity_types_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX activity_types_name_school_key ON public.activity_types USING btree (name, school_id);


--
-- TOC entry 5110 (class 1259 OID 20106)
-- Name: area_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX area_name_school_key ON public.area USING btree (name, school_id);


--
-- TOC entry 5125 (class 1259 OID 20107)
-- Name: counselor_assignments_school_grade_group_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX counselor_assignments_school_grade_group_key ON public.counselor_assignments USING btree (school_id, grade_id, group_id) WHERE ((grade_id IS NOT NULL) AND (group_id IS NOT NULL));


--
-- TOC entry 5126 (class 1259 OID 20108)
-- Name: counselor_assignments_school_user_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX counselor_assignments_school_user_key ON public.counselor_assignments USING btree (school_id, user_id);


--
-- TOC entry 5141 (class 1259 OID 20109)
-- Name: grade_levels_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_levels_name_key ON public.grade_levels USING btree (name);


--
-- TOC entry 5098 (class 1259 OID 20110)
-- Name: idx_activities_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_group ON public.activities USING btree (group_id);


--
-- TOC entry 5099 (class 1259 OID 20111)
-- Name: idx_activities_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_teacher ON public.activities USING btree (teacher_id);


--
-- TOC entry 5100 (class 1259 OID 20112)
-- Name: idx_activities_trimester; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_trimester ON public.activities USING btree (trimester);


--
-- TOC entry 5101 (class 1259 OID 20113)
-- Name: idx_activities_unique_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_unique_lookup ON public.activities USING btree (name, type, subject_id, group_id, teacher_id, trimester);


--
-- TOC entry 5104 (class 1259 OID 20114)
-- Name: idx_attach_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attach_activity ON public.activity_attachments USING btree (activity_id);


--
-- TOC entry 5127 (class 1259 OID 20115)
-- Name: idx_counselor_assignments_grade; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_grade ON public.counselor_assignments USING btree (grade_id);


--
-- TOC entry 5128 (class 1259 OID 20116)
-- Name: idx_counselor_assignments_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_group ON public.counselor_assignments USING btree (group_id);


--
-- TOC entry 5129 (class 1259 OID 20117)
-- Name: idx_counselor_assignments_school; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_school ON public.counselor_assignments USING btree (school_id);


--
-- TOC entry 5130 (class 1259 OID 20118)
-- Name: idx_counselor_assignments_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_user ON public.counselor_assignments USING btree (user_id);


--
-- TOC entry 5140 (class 1259 OID 20119)
-- Name: idx_email_configurations_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_email_configurations_school_id ON public.email_configurations USING btree (school_id);


--
-- TOC entry 5156 (class 1259 OID 20120)
-- Name: idx_scores_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scores_activity ON public.student_activity_scores USING btree (activity_id);


--
-- TOC entry 5157 (class 1259 OID 20121)
-- Name: idx_scores_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scores_student ON public.student_activity_scores USING btree (student_id);


--
-- TOC entry 5153 (class 1259 OID 20122)
-- Name: specialties_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX specialties_name_key ON public.specialties USING btree (name);


--
-- TOC entry 5184 (class 1259 OID 20123)
-- Name: teacher_assignments_teacher_id_subject_assignment_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX teacher_assignments_teacher_id_subject_assignment_id_key ON public.teacher_assignments USING btree (teacher_id, subject_assignment_id);


--
-- TOC entry 5186 (class 1259 OID 20124)
-- Name: trimester_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX trimester_name_school_key ON public.trimester USING btree (name, school_id);


--
-- TOC entry 5160 (class 1259 OID 20125)
-- Name: uq_scores; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_scores ON public.student_activity_scores USING btree (student_id, activity_id);


--
-- TOC entry 5201 (class 1259 OID 20126)
-- Name: users_document_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_document_id_key ON public.users USING btree (document_id);


--
-- TOC entry 5202 (class 1259 OID 20127)
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- TOC entry 5205 (class 2606 OID 20128)
-- Name: EmailConfigurations FK_EmailConfigurations_schools_SchoolId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmailConfigurations"
    ADD CONSTRAINT "FK_EmailConfigurations_schools_SchoolId" FOREIGN KEY ("SchoolId") REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5206 (class 2606 OID 20133)
-- Name: activities FK_activities_activity_types_ActivityTypeId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_activity_types_ActivityTypeId" FOREIGN KEY ("ActivityTypeId") REFERENCES public.activity_types(id);


--
-- TOC entry 5207 (class 2606 OID 20138)
-- Name: activities FK_activities_trimester_TrimesterId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_trimester_TrimesterId" FOREIGN KEY ("TrimesterId") REFERENCES public.trimester(id);


--
-- TOC entry 5235 (class 2606 OID 20143)
-- Name: schools FK_schools_users_admin_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT "FK_schools_users_admin_id" FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- TOC entry 5245 (class 2606 OID 20148)
-- Name: subject_assignments FK_subject_assignments_schools_SchoolId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT "FK_subject_assignments_schools_SchoolId" FOREIGN KEY ("SchoolId") REFERENCES public.schools(id);


--
-- TOC entry 5251 (class 2606 OID 20153)
-- Name: subjects FK_subjects_area_AreaId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT "FK_subjects_area_AreaId" FOREIGN KEY ("AreaId") REFERENCES public.area(id);


--
-- TOC entry 5208 (class 2606 OID 20158)
-- Name: activities activities_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5209 (class 2606 OID 20163)
-- Name: activities activities_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5210 (class 2606 OID 20168)
-- Name: activities activities_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5211 (class 2606 OID 20173)
-- Name: activities activities_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5212 (class 2606 OID 20178)
-- Name: activity_attachments activity_attachments_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5213 (class 2606 OID 20183)
-- Name: activity_types activity_types_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5214 (class 2606 OID 20188)
-- Name: area area_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5215 (class 2606 OID 20193)
-- Name: attendance attendance_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5216 (class 2606 OID 20198)
-- Name: attendance attendance_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5217 (class 2606 OID 20203)
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5218 (class 2606 OID 20208)
-- Name: attendance attendance_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5222 (class 2606 OID 20213)
-- Name: audit_logs audit_logs_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- TOC entry 5223 (class 2606 OID 20218)
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5224 (class 2606 OID 20223)
-- Name: counselor_assignments counselor_assignments_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id) ON DELETE SET NULL;


--
-- TOC entry 5225 (class 2606 OID 20228)
-- Name: counselor_assignments counselor_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- TOC entry 5226 (class 2606 OID 20233)
-- Name: counselor_assignments counselor_assignments_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5227 (class 2606 OID 20238)
-- Name: counselor_assignments counselor_assignments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5228 (class 2606 OID 20243)
-- Name: discipline_reports discipline_reports_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5229 (class 2606 OID 20248)
-- Name: discipline_reports discipline_reports_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5230 (class 2606 OID 20253)
-- Name: discipline_reports discipline_reports_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5231 (class 2606 OID 20258)
-- Name: discipline_reports discipline_reports_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5232 (class 2606 OID 20263)
-- Name: discipline_reports discipline_reports_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5233 (class 2606 OID 20268)
-- Name: email_configurations email_configurations_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_configurations
    ADD CONSTRAINT email_configurations_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5219 (class 2606 OID 20405)
-- Name: attendance fk_attendance_created_by; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_created_by FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5220 (class 2606 OID 20415)
-- Name: attendance fk_attendance_school; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_school FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5221 (class 2606 OID 20410)
-- Name: attendance fk_attendance_updated_by; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_updated_by FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5240 (class 2606 OID 20273)
-- Name: student_assignments fk_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5241 (class 2606 OID 20278)
-- Name: student_assignments fk_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5242 (class 2606 OID 20283)
-- Name: student_assignments fk_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5237 (class 2606 OID 20400)
-- Name: student_activity_scores fk_student_activity_scores_school; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT fk_student_activity_scores_school FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5256 (class 2606 OID 20288)
-- Name: user_grades fk_user_grades_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5257 (class 2606 OID 20293)
-- Name: user_grades fk_user_grades_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5258 (class 2606 OID 20298)
-- Name: user_groups fk_user_groups_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5259 (class 2606 OID 20303)
-- Name: user_groups fk_user_groups_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5260 (class 2606 OID 20308)
-- Name: user_subjects fk_user_subjects_subject; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_subject FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5261 (class 2606 OID 20313)
-- Name: user_subjects fk_user_subjects_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5234 (class 2606 OID 20318)
-- Name: groups groups_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5236 (class 2606 OID 20323)
-- Name: security_settings security_settings_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5238 (class 2606 OID 20328)
-- Name: student_activity_scores student_activity_scores_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5239 (class 2606 OID 20333)
-- Name: student_activity_scores student_activity_scores_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5243 (class 2606 OID 20338)
-- Name: students students_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- TOC entry 5244 (class 2606 OID 20343)
-- Name: students students_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5246 (class 2606 OID 20348)
-- Name: subject_assignments subject_assignments_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.area(id);


--
-- TOC entry 5247 (class 2606 OID 20353)
-- Name: subject_assignments subject_assignments_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5248 (class 2606 OID 20358)
-- Name: subject_assignments subject_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5249 (class 2606 OID 20363)
-- Name: subject_assignments subject_assignments_specialty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES public.specialties(id);


--
-- TOC entry 5250 (class 2606 OID 20368)
-- Name: subject_assignments subject_assignments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5252 (class 2606 OID 20373)
-- Name: subjects subjects_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5253 (class 2606 OID 20378)
-- Name: teacher_assignments teacher_assignments_subject_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_subject_assignment_id_fkey FOREIGN KEY (subject_assignment_id) REFERENCES public.subject_assignments(id);


--
-- TOC entry 5254 (class 2606 OID 20383)
-- Name: teacher_assignments teacher_assignments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5255 (class 2606 OID 20388)
-- Name: trimester trimester_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5262 (class 2606 OID 20393)
-- Name: users users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


-- Completed on 2025-10-08 18:46:47

--
-- PostgreSQL database dump complete
--

\unrestrict g3MZVP7CFAiUkdlRb2lx5p0mshEQzV6w1V3TYlYOYNNbamOzbbAGAwhL9e40X16

