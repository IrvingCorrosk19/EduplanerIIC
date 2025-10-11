--
-- PostgreSQL database dump
--

\restrict YByRdQ9wcetVAl5UcyolaTCwAAC76prP5Por0LW09DfXKHaBPHxiuwMHrhLfatY

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

-- Started on 2025-10-10 19:59:42

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
-- TOC entry 5468 (class 0 OID 0)
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
-- TOC entry 5469 (class 0 OID 0)
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
    school_id uuid,
    category text,
    documents text
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
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE email_configurations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.email_configurations IS 'Configuración de servidores SMTP para cada escuela';


--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN email_configurations.smtp_use_ssl; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.email_configurations.smtp_use_ssl IS 'Usar SSL para conexión SMTP';


--
-- TOC entry 5472 (class 0 OID 0)
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
-- TOC entry 248 (class 1259 OID 20775)
-- Name: orientation_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orientation_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    school_id uuid,
    student_id uuid,
    teacher_id uuid,
    date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    report_type character varying(50),
    description text,
    status character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    subject_id uuid,
    group_id uuid,
    grade_level_id uuid,
    category text,
    documents text
);


ALTER TABLE public.orientation_reports OWNER TO postgres;

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
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN users.cellphone_primary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.cellphone_primary IS 'Número de celular principal del usuario';


--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN users.cellphone_secondary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.cellphone_secondary IS 'Número de celular secundario del usuario';


--
-- TOC entry 5435 (class 0 OID 19709)
-- Dependencies: 221
-- Data for Name: EmailConfigurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."EmailConfigurations" ("Id", "SchoolId", "SmtpServer", "SmtpPort", "SmtpUsername", "SmtpPassword", "SmtpUseSsl", "SmtpUseTls", "FromEmail", "FromName", "IsActive", "CreatedAt", "UpdatedAt") FROM stdin;
\.


--
-- TOC entry 5436 (class 0 OID 19729)
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
-- TOC entry 5437 (class 0 OID 19734)
-- Dependencies: 223
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (id, school_id, subject_id, teacher_id, group_id, name, type, trimester, pdf_url, created_at, grade_level_id, "ActivityTypeId", "TrimesterId", due_date, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5438 (class 0 OID 19744)
-- Dependencies: 224
-- Data for Name: activity_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_attachments (id, activity_id, file_name, storage_path, mime_type, uploaded_at, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5439 (class 0 OID 19757)
-- Dependencies: 225
-- Data for Name: activity_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_types (id, school_id, name, description, icon, color, is_global, display_order, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
\.


--
-- TOC entry 5440 (class 0 OID 19773)
-- Dependencies: 226
-- Data for Name: area; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.area (id, school_id, name, description, code, is_global, display_order, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
e85a77a3-135e-4138-8146-61b7db2f0811	\N	HUMANISTICA	\N	\N	f	0	f	2025-10-10 18:23:21.662645-05	\N	\N	\N
09007542-2861-468d-ab6b-0dd7db77d50b	\N	CIENTÍFICA	\N	\N	f	0	f	2025-10-10 18:23:24.684104-05	\N	\N	\N
bd5acf6a-7e90-49af-8a61-a42276a6772f	\N	TECNOLÓGICA	\N	\N	f	0	f	2025-10-10 18:23:30.955943-05	\N	\N	\N
\.


--
-- TOC entry 5441 (class 0 OID 19789)
-- Dependencies: 227
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, student_id, teacher_id, group_id, grade_id, date, status, created_at, created_by, updated_by, updated_at, school_id) FROM stdin;
\.


--
-- TOC entry 5442 (class 0 OID 19797)
-- Dependencies: 228
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, school_id, user_id, user_name, user_role, action, resource, details, ip_address, "timestamp", created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5443 (class 0 OID 19805)
-- Dependencies: 229
-- Data for Name: counselor_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.counselor_assignments (id, school_id, user_id, grade_id, group_id, is_counselor, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
42affbe9-0ab4-4e79-bf6c-dd00cfe597c0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	0047c2f0-00ad-44f2-a862-ab94cdf69b51	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	t	t	2025-10-10 18:30:06.665472-05	2025-10-10 18:30:06.665562-05	\N	\N
97b6c947-722d-43c3-9210-b8b693ee67a8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	0069610c-0488-43c1-b9d7-5781e25c66d2	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	t	t	2025-10-10 18:30:13.504315-05	2025-10-10 18:30:13.504315-05	\N	\N
47735026-4669-43d8-b3e2-b238ecf9b8b3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	0651744d-e62a-4d7c-969d-925281acaf1f	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	t	t	2025-10-10 18:30:19.804421-05	2025-10-10 18:30:19.804422-05	\N	\N
4cbba484-5c5f-4e90-b416-5311b06f1113	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	1ba15f92-dca9-46f0-be12-a1ee95f0befb	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	t	t	2025-10-10 18:30:25.795343-05	2025-10-10 18:30:25.795343-05	\N	\N
be439c4e-3d5d-4558-aa25-3cb70a74880c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	14f633ab-ebdb-4e0c-8604-77f3704a1bee	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	t	t	2025-10-10 18:30:30.234828-05	2025-10-10 18:30:30.234828-05	\N	\N
79019913-f595-444f-8d72-0708bb9f80fd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	199a1eb3-9a34-44be-bb68-9d3a78028d90	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	t	t	2025-10-10 18:30:34.671893-05	2025-10-10 18:30:34.671893-05	\N	\N
89074466-5b0f-4e37-b8ad-60bf1e0cec9b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	t	t	2025-10-10 18:30:52.909124-05	2025-10-10 18:30:52.909124-05	\N	\N
95040f55-c434-4905-8c9c-39b0689e7eb7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	t	t	2025-10-10 18:30:57.367722-05	2025-10-10 18:30:57.367722-05	\N	\N
6a8887a0-15c1-498e-bcc2-e59291221649	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	t	t	2025-10-10 18:31:02.135817-05	2025-10-10 18:31:02.135817-05	\N	\N
fd601166-3c44-4cb3-9c2f-c5df27d4e399	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	1fc1a78b-c3ef-47a3-92f9-9c0ac089f48a	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	t	t	2025-10-10 18:31:06.916465-05	2025-10-10 18:31:06.916465-05	\N	\N
a0a041a2-2a02-4065-a434-484dc27c7aee	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	50e46fb5-886b-458c-aecf-5694d6200ce4	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	t	t	2025-10-10 18:31:13.316921-05	2025-10-10 18:31:13.316921-05	\N	\N
1ea98ae7-b63a-4e0f-b2ff-8d4eb59d0a3e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	27bc06b3-05b6-4a3f-bc37-5ab40bab96bd	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	t	t	2025-10-10 18:31:30.770193-05	2025-10-10 18:31:30.770194-05	\N	\N
86c8a656-984c-40ff-98d2-f497e3598aca	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	3fddc702-8526-4054-9bf3-e84a9cb956c7	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	t	t	2025-10-10 18:31:34.877195-05	2025-10-10 18:31:34.877195-05	\N	\N
7f5653e2-dc62-4c87-8fa2-9d7a8c134941	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	2f91f6aa-11bd-4acd-8890-f73ab32d6eda	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	t	t	2025-10-10 18:31:38.757102-05	2025-10-10 18:31:38.757102-05	\N	\N
acb09a43-48fd-4ebe-829d-70b2805e52cd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	4186bdcb-6366-4462-ae37-fd5fd118bdec	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	t	t	2025-10-10 18:31:44.738084-05	2025-10-10 18:31:44.738084-05	\N	\N
2810df31-fdae-4965-b9ee-6945191ac5cd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	475fa05a-949e-4b65-b790-e84f7e61396b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	t	t	2025-10-10 18:31:49.69639-05	2025-10-10 18:31:49.69639-05	\N	\N
\.


--
-- TOC entry 5444 (class 0 OID 19818)
-- Dependencies: 230
-- Data for Name: discipline_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discipline_reports (id, student_id, teacher_id, date, report_type, description, status, created_at, updated_at, subject_id, group_id, grade_level_id, created_by, updated_by, school_id, category, documents) FROM stdin;
5f8b7f71-2b1e-46ee-b320-ae61900f6958	e81baeed-58c7-4d0d-b971-ae136c434b1d	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	2025-10-11 19:10:00-05	Citacion	aqaqaqaqa	Pendiente	2025-10-10 19:10:37.328903-05	\N	75b5394f-2870-4a1b-ac2b-f7a908f985d5	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	669bb230-dc3b-421d-8031-ed36fc6f52d7	\N	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Comportamiento	
d0a0ca04-ae29-4b16-be2a-664f4a3cf9a8	e81baeed-58c7-4d0d-b971-ae136c434b1d	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	2025-10-11 19:10:00-05	Citacion	qaqaqaqaqa	Resuelto	2025-10-10 19:10:54.356449-05	\N	75b5394f-2870-4a1b-ac2b-f7a908f985d5	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	669bb230-dc3b-421d-8031-ed36fc6f52d7	\N	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Comportamiento	
9642d32e-b7c4-4151-b224-544c181161ef	5c0ba75c-b42a-4b5e-b801-28bb70660d1d	1ba15f92-dca9-46f0-be12-a1ee95f0befb	2025-10-11 19:47:00-05	Citacion	swswswswsw	Pendiente	2025-10-10 19:47:43.061922-05	\N	5302c538-2dd6-45bf-bfd9-997f248b2a7f	52b97915-ba61-4604-8e7f-556627573f87	ac4e4383-37d3-4ad0-8f1e-08d3af713665	\N	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Comportamiento	
860be808-8d5d-4d7a-bff7-6bf87f204b21	6009c952-c058-4e71-9936-c88c0940386d	1ba15f92-dca9-46f0-be12-a1ee95f0befb	2025-10-11 19:47:00-05	Citacion	aqaqaqaqaqaqaq	Resuelto	2025-10-10 19:48:13.406641-05	\N	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	ac4e4383-37d3-4ad0-8f1e-08d3af713665	\N	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Comportamiento	
ed0a5540-b87e-4fae-adb9-371142f886ea	93adcde6-ffd0-4d8e-be1c-1bf08389afcd	1ba15f92-dca9-46f0-be12-a1ee95f0befb	2025-10-11 19:55:00-05	Citacion	q1q1q1q1q1q1	Resuelto	2025-10-10 19:55:13.966224-05	\N	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	ac4e4383-37d3-4ad0-8f1e-08d3af713665	1ba15f92-dca9-46f0-be12-a1ee95f0befb	1ba15f92-dca9-46f0-be12-a1ee95f0befb	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Comportamiento	
88d18bad-9cd2-4a5a-b90d-40cdc4b13c13	e505f903-d5de-4847-a44b-97de8f414913	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	2025-10-11 19:57:00-05	Citacion	swswswswswsw	Pendiente	2025-10-10 19:57:56.942198-05	\N	43de5530-61aa-49f0-8efb-d6c76d6ea294	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Comportamiento	
\.


--
-- TOC entry 5445 (class 0 OID 19828)
-- Dependencies: 231
-- Data for Name: email_configurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_configurations (id, school_id, smtp_server, smtp_port, smtp_username, smtp_password, smtp_use_ssl, smtp_use_tls, from_email, from_name, is_active, created_at, updated_at) FROM stdin;
5138fe6e-e0ae-4b5d-a2f6-9473a78e27ec	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	smtp.gmail.com	587	irvingcorrosk19@gmail.com	mqxahytcidbjobad	f	t	irvingcorrosk19@gmail.com	IPT San Miguelito	t	2025-09-06 21:36:52.236737-05	2025-09-06 22:15:30.323577-05
\.


--
-- TOC entry 5446 (class 0 OID 19851)
-- Dependencies: 232
-- Data for Name: grade_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grade_levels (id, name, description, created_at, created_by, updated_by, updated_at, school_id) FROM stdin;
e3567ff9-6ed1-4409-ac09-d325528cdc70	10	\N	2025-10-10 18:23:22.104715-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:22.104715-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
778c75fc-b7ac-4e94-81f1-30e42f0763ed	11	\N	2025-10-10 18:23:23.998351-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:23.998351-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
669bb230-dc3b-421d-8031-ed36fc6f52d7	12	\N	2025-10-10 18:23:24.213292-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.213292-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
7ee6d015-2a27-4d2d-ae49-a96f67977c2d	8	\N	2025-10-10 18:23:24.73935-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.73935-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
485a50cd-786c-4521-89b9-2f9d4b58d8d9	9	\N	2025-10-10 18:23:29.66797-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:29.66797-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
ac4e4383-37d3-4ad0-8f1e-08d3af713665	7	\N	2025-10-10 18:23:35.923165-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:35.923165-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
\.


--
-- TOC entry 5447 (class 0 OID 19860)
-- Dependencies: 233
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, school_id, name, grade, created_at, description, created_by, updated_by, updated_at) FROM stdin;
52a67838-d37f-4715-8611-d8f92f2da652	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	C2	\N	2025-10-10 18:23:22.291033-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:22.291033-05
242a4218-0497-4858-8794-ab337d875e53	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	S2	\N	2025-10-10 18:23:23.821759-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:23.821759-05
5e87d290-1647-46cb-a054-c7cce0c7a117	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	A2	\N	2025-10-10 18:23:24.243094-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.243094-05
83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	E2	\N	2025-10-10 18:23:24.549975-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.549975-05
ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	G	\N	2025-10-10 18:23:24.766925-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.766925-05
df2c7532-e7c6-4881-8fe7-2e0679549c20	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	F	\N	2025-10-10 18:23:25.520356-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:25.520356-05
634dfd62-debc-4036-b826-327959dec881	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	A1	\N	2025-10-10 18:23:26.479652-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:26.479652-05
84d3af3f-896d-45d6-8bc6-097c7d2b3044	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	C1	\N	2025-10-10 18:23:26.642455-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:26.642455-05
d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	E1	\N	2025-10-10 18:23:26.815998-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:26.815998-05
c4a5368c-d643-4007-88da-6e5da7351a2b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TM1	\N	2025-10-10 18:23:27.051787-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:27.051787-05
d1947aad-3932-47e2-84d3-d9c379a4d3b2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	M	\N	2025-10-10 18:23:27.262533-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:27.262533-05
4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	H	\N	2025-10-10 18:23:28.082896-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:28.082896-05
e59c6f29-7b46-4a28-bc90-1c0fd317e7db	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	I	\N	2025-10-10 18:23:28.262729-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:28.262729-05
e1c7dd13-15db-47ed-80fe-7d91eda0e136	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	J	\N	2025-10-10 18:23:28.443016-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:28.443016-05
01167bfe-013a-4a90-97bd-77315bdef68d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	K	\N	2025-10-10 18:23:28.680497-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:28.680497-05
6ccdbbff-f974-4d28-81ab-47fa4d03b95c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	L	\N	2025-10-10 18:23:28.924994-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:28.924994-05
b70d948a-2b27-4f41-831d-c2f504d2df91	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	N	\N	2025-10-10 18:23:29.399116-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:29.399116-05
037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	A	\N	2025-10-10 18:23:35.952212-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:35.952212-05
51616e82-2b9e-417b-b213-84280a617f47	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	B	\N	2025-10-10 18:23:36.664481-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:36.664481-05
52b97915-ba61-4604-8e7f-556627573f87	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	C	\N	2025-10-10 18:23:36.792675-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:36.792675-05
b1f272d1-f36c-4ecc-b5ff-00c47b593375	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	D	\N	2025-10-10 18:23:36.919389-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:36.919389-05
3d19fab4-b7fd-4819-a70a-8f22d83b62b7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	E	\N	2025-10-10 18:23:37.057343-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:37.057343-05
8567b860-540a-420a-8f7d-aca6c3e13efa	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	O	\N	2025-10-10 18:23:39.951459-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:39.951459-05
8f36b81f-546f-4443-9afe-45d07ee96662	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	P	\N	2025-10-10 18:23:40.078183-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:40.078183-05
8c5f05c0-519b-4a81-bf2d-89c688cfc211	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	S1	\N	2025-10-10 18:23:42.867012-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:42.867012-05
\.


--
-- TOC entry 5462 (class 0 OID 20775)
-- Dependencies: 248
-- Data for Name: orientation_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orientation_reports (id, school_id, student_id, teacher_id, date, report_type, description, status, created_at, created_by, updated_at, updated_by, subject_id, group_id, grade_level_id, category, documents) FROM stdin;
8e90c9b8-adc1-4b4f-976f-20fcb8587817	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	3f6f2113-41ff-4f66-8300-be100c112aca	1ba15f92-dca9-46f0-be12-a1ee95f0befb	2025-10-11 19:30:00-05	Citacion	aqaqaqaqa	Pendiente	2025-10-10 19:30:41.197206-05	1ba15f92-dca9-46f0-be12-a1ee95f0befb	\N	1ba15f92-dca9-46f0-be12-a1ee95f0befb	\N	634dfd62-debc-4036-b826-327959dec881	e3567ff9-6ed1-4409-ac09-d325528cdc70	Comportamiento	[{"fileName":"EL PODER DE LAS FRECUENCIAS Y LOS PROMEDIOS EN INVESTIGACI\\u00D3N DE MERCADO.docx","savedName":"ecc9631e-200c-4427-8e71-f0b2bc801a08_EL PODER DE LAS FRECUENCIAS Y LOS PROMEDIOS EN INVESTIGACI\\u00D3N DE MERCADO.docx","size":54184,"uploadDate":"2025-10-11T00:30:41.1718261Z"}]
3ebce386-466d-49f0-bf70-5d9343cace35	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	1082138b-b33d-4fdc-a46c-42f85755fcd0	1ba15f92-dca9-46f0-be12-a1ee95f0befb	2025-10-11 19:46:00-05	Citacion	w222w2w2w2	Escalado	2025-10-10 19:47:10.02399-05	1ba15f92-dca9-46f0-be12-a1ee95f0befb	\N	1ba15f92-dca9-46f0-be12-a1ee95f0befb	\N	634dfd62-debc-4036-b826-327959dec881	e3567ff9-6ed1-4409-ac09-d325528cdc70	Comportamiento	
\.


--
-- TOC entry 5448 (class 0 OID 19869)
-- Dependencies: 234
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schools (id, name, address, phone, logo_url, created_at, admin_id, created_by, updated_at, updated_by) FROM stdin;
ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	IPT San Miguelito	Panamá, San Miguelito, Belisario Frias, Torrijos Carter, Calle Principal	260-9999	5d2faabb-a88e-44a0-beb5-32b7d951a194_ElPorvenir.png	2025-09-06 16:58:50.703258-05	21e66209-995a-4182-98e9-33d2ab635b48	\N	\N	\N
\.


--
-- TOC entry 5449 (class 0 OID 19882)
-- Dependencies: 235
-- Data for Name: security_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.security_settings (id, school_id, password_min_length, require_uppercase, require_lowercase, require_numbers, require_special, expiry_days, prevent_reuse, max_login_attempts, session_timeout_minutes, created_at, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5450 (class 0 OID 19897)
-- Dependencies: 236
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialties (id, name, description, created_at, created_by, updated_by, updated_at, school_id) FROM stdin;
a184096f-96fe-47c7-ba19-892a020ec5f1	BACHILLER INDUSTRIAL EN  CONSTRUCCIÓN	\N	2025-10-10 18:23:21.448899-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:21.448899-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
9d54c08e-ebc0-4945-87ba-a96b357fc8e4	BACHILLER INDUSTRIAL EN  SOLDADURA	\N	2025-10-10 18:23:23.75865-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:23.75865-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
c8322762-40dd-4cce-944c-a51fb0fa88da	BACHILLER INDUSTRIAL EN  AUTOTRÓNICA	\N	2025-10-10 18:23:24.146714-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.146714-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
ae5fa357-e612-440e-a179-8f40f94c80ef	BACHILLER INDUSTRIAL EN  ELECTRÓNICA	\N	2025-10-10 18:23:24.492532-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.492532-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	PRE-MEDIA	\N	2025-10-10 18:23:24.653726-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.653726-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
a7e13742-0ab6-467e-abfb-54a93adbb803	BACHILLER INDUSTRIAL EN  TECNOLOGÍA MECÁNICA	\N	2025-10-10 18:23:26.978236-05	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:26.978236-05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
\.


--
-- TOC entry 5451 (class 0 OID 19906)
-- Dependencies: 237
-- Data for Name: student_activity_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_activity_scores (id, student_id, activity_id, score, created_at, created_by, updated_by, updated_at, school_id) FROM stdin;
\.


--
-- TOC entry 5452 (class 0 OID 19915)
-- Dependencies: 238
-- Data for Name: student_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_assignments (id, student_id, grade_id, group_id, created_at, created_by, updated_by, updated_at) FROM stdin;
b48b422f-6d8d-453c-a10b-a44e18544409	33af2a1b-8a2f-4dda-b6e5-a23c3191af10	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:25:15.084164-05	\N	\N	\N
cc9f9876-360a-497c-aabe-727b6b05878d	fe99e819-a50f-4597-aca7-17bd7296e1ff	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:25:15.684707-05	\N	\N	\N
de193791-3dbf-415d-b930-139f586fed48	258b05f1-56e7-452d-b2ec-30abbb78f1be	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:25:16.226496-05	\N	\N	\N
4c1ba68a-1449-4110-aee1-34f8d1bd82f0	deb2e827-0377-403d-aca7-8e78ce7ddd23	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:25:16.777344-05	\N	\N	\N
a36641ff-4ae0-4341-a700-22181f02ae12	c66e050f-b242-4060-94e0-4c91806dab77	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:25:17.31712-05	\N	\N	\N
5c954c8b-d623-422a-b7d5-d2f3d3db76a4	8016e639-8ea2-4fd5-a56f-b1ceaf303a53	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:25:17.855387-05	\N	\N	\N
e7e0e279-441b-4b91-9351-f699534006b1	4a1f5a5d-58d0-4f73-9208-7e1b6d73a700	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:25:18.40812-05	\N	\N	\N
14352ab0-722b-42f5-8d55-73119a43ff3a	f6f982b8-86a2-4c76-b97b-b951f48e4422	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:25:18.971615-05	\N	\N	\N
78464bb9-b75a-448f-9b6d-82ce658b0554	420bdefc-0164-4076-b17e-d3dfbbef7a8e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:25:19.512659-05	\N	\N	\N
5c922a08-385c-4531-9d92-2cc7a7bd8fca	2f238165-5660-46bf-a0e9-c072bc7d92cb	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:25:20.035303-05	\N	\N	\N
d2840dda-cd05-43c7-b43e-0c6ca71f7271	c1bda3f6-cccb-4cfc-b43d-4e2d294f61f6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:25:20.531851-05	\N	\N	\N
d16262f5-927a-4af3-aa1a-15e4d6b3733d	21941532-f100-4443-b5de-7c7e3cc0ae29	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:25:21.002497-05	\N	\N	\N
666229d7-8afc-4f03-a5c9-072ba47582a9	ccbeddd6-84b3-4fc6-b0c7-196a906844f2	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:25:21.505323-05	\N	\N	\N
48915c7d-0bcf-452c-8cd6-10347f40dd11	ada12236-b69b-4c27-b306-144475244e34	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:25:22.044409-05	\N	\N	\N
5abbb0cd-00ea-48d3-b889-233384566818	32ef5836-f964-470f-b223-08e9c1dda3d5	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:25:22.590422-05	\N	\N	\N
cacf45bd-7af3-47a4-9d4d-930f5dbe2db3	79fd0959-e9d5-49c6-838e-de575dd01046	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:25:23.136666-05	\N	\N	\N
370db602-a337-4e2e-92f6-71f4450bfc7f	52a1d689-c422-4437-bbdc-d8566687a8e4	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:25:23.709624-05	\N	\N	\N
4acc9023-6fe1-47ae-8af3-592a61d0d411	eba7a548-2a47-4134-a94f-4154e41c37bf	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:25:24.263992-05	\N	\N	\N
05eb738e-52cb-4f40-adaa-132b7f12b6ba	54fba2ed-ca2f-4d6d-b467-a5ec03ac3d74	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:25:24.825989-05	\N	\N	\N
60c850c1-703c-448a-9e79-2253fdbfa793	aef65908-4be2-489d-83ea-65a3b0e7f0f6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:25:25.39939-05	\N	\N	\N
239aa85e-cc28-45c8-9f03-753cbf9da0fa	43758908-403d-4d68-8295-483e708b7499	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:25:25.95466-05	\N	\N	\N
f16e8d8d-5cd4-472b-bc98-fe157f36245c	285150a0-2a1c-44b5-a984-0b8e4a5c2ec1	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:25:26.584897-05	\N	\N	\N
8a8d6c23-e605-4382-aa8f-ae54950e46d4	86be87b0-1a03-4a9f-b820-6ea8700d59c4	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:25:27.123254-05	\N	\N	\N
4c6a947d-56be-442d-ac29-8d2d0cedfceb	6009c952-c058-4e71-9936-c88c0940386d	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:25:27.672401-05	\N	\N	\N
74e52020-5c98-40be-b50c-977ca0bf7d3c	39165dd5-9245-48e3-901c-3ddafffbee17	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:25:28.218758-05	\N	\N	\N
0631c10b-3520-47d5-a907-ff6d63751ba7	85857aba-7343-4a97-83f7-b330b280e48b	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:25:28.68978-05	\N	\N	\N
1d4c7757-1564-427b-8e99-e2aac1573eec	8c4af287-a170-42d2-a58d-44713fa83db5	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:25:29.215838-05	\N	\N	\N
7d3240d2-3351-4f4b-b570-479fe0b35803	5a4a085b-1a0a-43ad-ae61-9b2a3d10dba6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:25:29.754037-05	\N	\N	\N
646b6086-8373-495b-9feb-7226309c01ec	2c86740b-7e67-4731-ab39-975b03d93920	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:25:30.279451-05	\N	\N	\N
dbf2333a-0f24-4258-a875-84447d8122d2	c3381cf1-effb-4dc6-aebc-1f50c5abde9a	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:25:30.824358-05	\N	\N	\N
06291fad-975c-45bc-b8df-ccf7b348d518	7639b757-5b70-44c0-8f8d-48f70757fe03	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:25:31.374275-05	\N	\N	\N
30bdc2e8-0668-40e7-a65e-d787a04e2d23	5253ef90-3ee0-41c2-a626-173c2c41f9c9	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:25:31.926041-05	\N	\N	\N
e053185e-a7d4-4ed8-a770-0df4410ce477	cc8be287-43e4-42ac-aa27-92efe7d0152b	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:25:32.454933-05	\N	\N	\N
cbcc3566-3e1d-4677-b591-5e084cfcb0e4	137313cd-89df-45ef-ae9e-c32b79a8d068	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:25:33.010135-05	\N	\N	\N
435ec35f-a3e9-4810-a161-7334eacdf0dd	d59a3bd1-2853-4849-afba-62eedd22fda5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:25:33.566677-05	\N	\N	\N
844eed87-46a2-4ef2-964f-536502f51d7d	e505f903-d5de-4847-a44b-97de8f414913	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:25:34.13736-05	\N	\N	\N
94eb8d42-046b-472b-920e-a74e6cbc1225	5b813d33-6dfb-4337-acbb-df34f138ca56	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:25:34.699732-05	\N	\N	\N
3df7912c-ac8c-4e9e-ad17-bef03b12f9a5	df87630f-56c8-4355-80cf-1222f24cdc8a	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:25:35.262168-05	\N	\N	\N
50b49ca1-a3db-4b60-802a-b913dac82b9a	4ed3e409-37fb-49f4-b5fa-603f1fddab03	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:25:35.816061-05	\N	\N	\N
d7ca9a10-4c09-4dc9-b8d7-c9281b3337e9	087cba2d-608e-4cb4-bbbd-4d472077c63d	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:25:36.344043-05	\N	\N	\N
b65c16e8-b4e1-4a01-be03-8444670243b7	e0e8ff8e-0f77-4948-ab5e-b7fadd9f00e3	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:25:36.890688-05	\N	\N	\N
a4179a7a-4565-4a18-b204-ca8d62ee3853	5499af9b-c7ba-4a8f-b3d3-2a1fcffc31dd	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:25:37.453745-05	\N	\N	\N
0fbf91fa-33d7-48dc-9138-bba323d0e24f	ab3f3e93-1a93-4a32-a61c-d8a10ebbfe7d	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:25:38.027709-05	\N	\N	\N
d7447258-f4ac-4f72-945e-a42d66af692b	3df11abd-74ba-40e3-8d5f-b04c27556c29	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:25:38.601141-05	\N	\N	\N
030f8813-894c-42b6-97bc-1ec0448e926f	3a477bec-ae02-4de8-8d14-36886d2f4f2c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:25:39.168248-05	\N	\N	\N
a2bae0b8-877e-4c49-8640-59314a726e0b	fcf4db68-1c51-4c60-8c5f-c4023b810906	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:25:39.739355-05	\N	\N	\N
7c218a85-8550-4987-9153-2e92a0d504e7	3f6f2113-41ff-4f66-8300-be100c112aca	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:25:40.31421-05	\N	\N	\N
2e56bb8f-dc86-46ab-b292-9f320a47224e	011ad327-b5cd-4cfa-8614-1668b44e4ccb	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:25:40.890641-05	\N	\N	\N
465ddf3c-a554-461a-826b-12b9c5fa2c96	3cebf0bf-bb60-4196-9a77-ce79105e3b04	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:25:41.446489-05	\N	\N	\N
408e4d3f-d80b-4878-b882-0a9735314bba	92d7d4a8-0e7d-4e5b-86de-8a3722800797	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:25:42.001299-05	\N	\N	\N
3f3374fd-b468-40c8-affd-39ad68be5bf0	6ae07ea2-cf1e-449b-9848-570b7cd7189f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:25:42.573451-05	\N	\N	\N
51d69771-2dc5-47ad-890b-831ed4ed25b5	e81baeed-58c7-4d0d-b971-ae136c434b1d	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:25:43.138148-05	\N	\N	\N
efeb535d-0568-4385-b89e-fbb31978b0e4	8c269315-004f-43e3-b897-305633b40d8f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:25:43.69488-05	\N	\N	\N
68bd4913-2d81-4d84-b5a5-fbb566466860	e4dc376f-fa40-4133-a21e-e6ae0bf5f20b	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:25:44.248526-05	\N	\N	\N
a013f9da-7a6e-4f18-82c5-8f07392d8fd2	7e381731-1233-4b80-9ab2-5c8e8a0da04e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:25:44.806155-05	\N	\N	\N
3f7258e2-a1a4-4329-95f6-149068034ea1	67cfa05f-d1f4-4d67-adaf-5e95a21020fe	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:25:45.380246-05	\N	\N	\N
4de27d8f-dd1d-4d0b-bbae-4f2eaf466771	f71f9124-9db0-48f2-a758-e39fd98afa6f	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:25:45.935671-05	\N	\N	\N
b389025c-6c01-4710-a173-825b929c1b27	0fc388ca-a6fd-403a-9f62-cf243b60bcf5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:25:46.49188-05	\N	\N	\N
f0d6a8bb-cb25-4de3-9b06-4ebde95abf67	7f2c2253-6085-4b8e-9272-a1cdd30b6ebe	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:25:47.030814-05	\N	\N	\N
bb8df928-7609-4cf8-bc10-90055dc4f800	87935e6e-7c17-4053-91fb-f1ece7edbecd	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:25:47.602951-05	\N	\N	\N
2c60975a-9c99-4c0f-9eba-f0c94238f70f	6e0bfcaf-7c5b-4316-bb95-b46b06a164e7	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:25:48.161511-05	\N	\N	\N
5b485a6f-5739-4aca-ab54-cdc28dc248fd	4f9c22f5-ca06-4f50-ae88-698aee8113dd	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:25:48.719608-05	\N	\N	\N
bbaf9752-27a2-4e26-9133-060a013451db	2df4385c-e2c8-4f3a-b03b-6b2566ac11bf	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:25:49.273824-05	\N	\N	\N
4b565b21-7874-464a-bb69-3be8b2b4af66	55d6942c-fab1-4687-8dca-d1e336e34bb0	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:25:49.849534-05	\N	\N	\N
0ef22d74-8bef-45d9-a929-2c2a83a45c21	bfcfa3ed-7180-4d1b-b590-e495a9bc86b7	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:25:50.421726-05	\N	\N	\N
d8e4c468-24a1-4129-a37b-1bbbef605b31	e91a08cf-b8df-4310-b949-4df3bd7c50b1	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:25:50.97691-05	\N	\N	\N
20a2016d-263f-42cc-b302-ba64fb3a49ef	de4c1f92-46da-4e97-9786-870808611a84	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:25:51.543731-05	\N	\N	\N
dba4cb97-4f7b-47b7-ad89-65135a2d66ef	693740ad-88d3-4ebf-a0ba-05d12a229564	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:25:52.109157-05	\N	\N	\N
5dd3436f-2485-4d3c-af0d-abdcd7d634d0	7ee49798-9dae-44e0-bbd8-28b793d87615	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:25:52.682756-05	\N	\N	\N
278cd3a9-64bc-42d3-ae66-831d68edfe36	ebee7a34-7faf-48fe-8b11-2e74d6113c5a	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:25:53.240914-05	\N	\N	\N
14fbe9c4-07e3-41d0-b227-0e616037d1de	8589d09a-e202-498b-8e72-e1b5a8fcb05c	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:25:53.798433-05	\N	\N	\N
978a62ba-1e1c-4c7a-9ced-9cfbe49a99c3	5e48f5dd-3583-41bb-89b5-74f06b78d5d9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:25:54.363365-05	\N	\N	\N
18e78704-7493-4bd3-aa6d-1e93a1ee504a	9325940e-d4c1-406f-894b-2116508c850e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:25:54.933249-05	\N	\N	\N
2f46f0ff-f36c-4e02-9a8c-95a1f5fb7020	0560a821-469d-46e8-9344-de66c1921bbd	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:25:55.498405-05	\N	\N	\N
1df874c1-0882-47fb-bb54-8dd10774f4eb	1082138b-b33d-4fdc-a46c-42f85755fcd0	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:25:56.055918-05	\N	\N	\N
4a8b73e8-df28-4ae3-82f4-9024a9c68a6e	cc36e9d7-44e5-47cc-a3fd-2d44f34a2d4c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:25:56.633537-05	\N	\N	\N
3cd8e25c-7afa-4044-aea5-ddfc5a80541f	11b11cf3-01af-4e4a-8292-339b8c160768	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:25:57.193808-05	\N	\N	\N
cf7d4e43-e6b9-4a0e-bff5-814c2ee033ce	41ff85d9-c1e0-4934-b8da-d9ec78fd4789	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:25:57.761205-05	\N	\N	\N
4dc0a24c-0013-4e8e-949b-fa0cda1fa4df	f2bd2aa0-b2b5-4fe9-935d-cd7fc926d8a7	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:25:58.337885-05	\N	\N	\N
1d9874fa-ad13-4c2a-b51c-a8fcbb7ef0b3	3437673d-e4aa-4cb3-91e8-2a32925896db	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:25:58.918807-05	\N	\N	\N
e64acc27-5864-4119-9e91-1f05c5058bf0	f137f787-1b81-4c31-b9c6-fd09945d6512	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:25:59.492913-05	\N	\N	\N
7b09ff76-e0ea-4744-a547-1bf881339241	3e3e91d4-1c84-420c-9db3-e1086dddc7d0	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:26:00.050197-05	\N	\N	\N
48cd9e47-a201-4f26-83d7-9aadbd60979a	ba1024d6-b0c6-4c44-ac71-fca1eee217f6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:26:00.590452-05	\N	\N	\N
59f6db51-d0ea-4f4f-8b38-3eb2be8d0d67	7855c257-0b74-4c09-adc5-453043d08f53	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:26:01.157785-05	\N	\N	\N
3bf0ff08-3b1d-4689-aba4-dd5bba5ec74d	337a9697-91b1-4cbe-a1a1-f4bbcac2d6e1	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:26:01.721102-05	\N	\N	\N
5613bac4-a61c-47ff-980b-9b64cc4c3b04	8fa7e9e9-e9cc-4f6a-b048-2233eef8c33d	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:26:02.288598-05	\N	\N	\N
360c30dc-de41-4e20-bf09-5192e3659fbd	9212b75d-34f6-41d9-a46e-efa683281eb0	778c75fc-b7ac-4e94-81f1-30e42f0763ed	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:26:02.864562-05	\N	\N	\N
1d88e2b1-3db6-41eb-a872-ef1007ad64ae	9153e3d4-5daf-4b2c-ae15-460cd464a904	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:26:03.429338-05	\N	\N	\N
79a1fb29-c223-4f12-99c1-41a39df44140	234f0231-9d36-49b8-96fe-a2c947bf4fe8	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:26:03.993028-05	\N	\N	\N
ed44d071-1d8d-4da6-927c-d30fbcc1818a	503d6773-e7fb-4f8e-b17d-112f894f8818	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:26:04.570158-05	\N	\N	\N
fe4f11a5-3193-4e8f-9ae5-d6169de01ab4	4e0959c6-3cd4-4931-b743-73e377dfd012	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:26:05.143041-05	\N	\N	\N
a5a318b5-e423-4545-9283-39c5a0d12ddd	5c0ba75c-b42a-4b5e-b801-28bb70660d1d	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:26:05.689943-05	\N	\N	\N
ad167adc-2a44-46d1-8977-f006f3eb65c7	4d733cb5-7d14-41bd-94ef-d788166b8466	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:26:06.262474-05	\N	\N	\N
6999e8d6-8a51-4ae8-bc70-c66a63a87a30	3e408117-002c-4cb5-8d3d-180590dc9f7f	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:26:06.819506-05	\N	\N	\N
d42718a0-a468-40c3-8e76-42fca36078cd	e0cab3cf-ad31-4cc6-8ba7-3663699d0704	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:26:07.382657-05	\N	\N	\N
1fba6d41-ad13-45d1-9831-98fd60162c4f	f1cfb3d7-7019-4a5d-8204-6de953256bf6	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:26:07.923149-05	\N	\N	\N
346aa13a-4348-4f52-8b3e-accbae6f0834	3d8dfff4-b487-4191-8a95-91c9753eae76	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:26:08.462436-05	\N	\N	\N
c08ff960-50f5-4ad3-bac0-126c12465a7c	4de59fb6-9395-4378-82d1-48a60a61cac0	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:26:09.019326-05	\N	\N	\N
50fc3867-6355-4c3c-866a-e26eb6b39b24	88563ca3-f643-4514-a10d-153406e412c6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:26:09.570763-05	\N	\N	\N
49d2cfa0-a664-4536-8050-ebff22b1b34d	94af83b3-8ee4-425a-885b-b3e4e7996ed7	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:26:10.11874-05	\N	\N	\N
8810da83-056f-4c65-9883-a2591471d468	8ec49143-7765-47f7-bba8-68f12b1ebf6b	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:26:10.680777-05	\N	\N	\N
82e0eae6-a159-4ae2-87bd-0db5f39887d4	e70acca8-93cb-4897-80bd-848da12f4d38	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:26:11.234841-05	\N	\N	\N
9bbe1879-1ed4-4750-9035-9f6652904296	5fc375a8-6587-4bfd-8cad-b89eae0072b2	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:26:11.778398-05	\N	\N	\N
208535c3-4b15-406f-ade7-df9d452ff6d1	a970dd46-082a-4f45-8bd1-f887150de9d0	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:26:12.314744-05	\N	\N	\N
5f822a3a-daec-492f-adf4-771cd08d3ab5	57a87153-287b-400e-adc0-fe360f53f799	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:26:12.88201-05	\N	\N	\N
e51fe234-2612-48f0-bfd5-df805a3971f2	197681ed-5ed9-4f2c-97d4-e92f3a13f1b6	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:26:13.427195-05	\N	\N	\N
ef533692-ddd0-4e96-b6cb-1e4786d5e6b0	351f16fb-b5a8-44ba-ad24-5a01abf8f170	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:26:13.981566-05	\N	\N	\N
c594ae8e-e0fd-4968-a0f3-48e97e4a9a7d	d5ff762f-e8ec-41aa-9ff5-d222c3d2505a	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:26:14.670025-05	\N	\N	\N
f4bbd681-a879-4a73-91e4-b58d32d188d4	fcee0e38-99c2-442f-9116-f23b092bcad6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:26:15.232253-05	\N	\N	\N
9c425cfb-9e8d-407e-b4d9-219b8bb30e2a	3151da6f-45b3-44ec-9f8a-150603af2686	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:26:15.770418-05	\N	\N	\N
f773cd16-3ad6-40b7-a8b5-f93f3b774825	fefc0b80-697e-411b-84be-b00c77809d2f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:26:16.341666-05	\N	\N	\N
a2fc4e83-08e1-4d41-927c-6ef45e427e95	6c294215-0f4e-426d-97fe-af1ed11e1409	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:26:16.914878-05	\N	\N	\N
45b9e0c5-2a02-48e5-a7ce-efac316910d7	05e60ed1-414d-4f5b-b16a-65f92e561a13	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:26:17.47735-05	\N	\N	\N
1a1d5c39-ca95-4f89-9fc3-6c12609fb61e	93adcde6-ffd0-4d8e-be1c-1bf08389afcd	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:26:18.029445-05	\N	\N	\N
61187335-d160-44d1-8d93-4fd21b2ae5bf	91d30dc8-11c0-41ef-927c-5c7b3614945d	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:26:18.542739-05	\N	\N	\N
f8fb6b98-794a-4b50-bd72-7bc9e9a95fbf	a2229450-0965-4193-ba63-1b085600d8c4	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:26:19.07254-05	\N	\N	\N
056d8ea1-7186-444e-926f-30f1058d893b	cfbb36f5-e38c-446b-8624-a07fae229114	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:26:19.608336-05	\N	\N	\N
4133a53f-2db6-4350-95ce-cb2438cce606	60469364-649b-4749-a4cd-4f8ce2a63284	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:26:20.165373-05	\N	\N	\N
2e8129f2-f18a-4c3b-b1c8-e22df69a656d	b12c121b-3b04-41a1-a7f7-e4a1dd45b5db	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:26:20.728164-05	\N	\N	\N
2ca23d78-bf37-495e-950f-a10614498cf6	00f178e5-5eee-4c8a-a547-2ca86a31cad7	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:26:21.273608-05	\N	\N	\N
00fd8690-c775-41d2-ab6c-ce4758506712	9566a27a-6d11-490a-9e4f-b4268bd9afbf	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:26:21.835183-05	\N	\N	\N
12f762dd-4afe-4fac-9524-5daa497b631c	f909fcd5-647b-4dbf-a3d8-4caa8647f7bc	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:26:22.39894-05	\N	\N	\N
93a8ebf8-fd8c-4583-8963-81a271f5056c	a0f2f12c-ae92-4e9e-a839-b5bdfd9dbe04	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:26:22.962661-05	\N	\N	\N
d5f5dbd2-acf9-4bd1-816c-2df12db9a18e	0c5b9185-29fd-4a27-bd52-12a44649170f	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:26:23.531361-05	\N	\N	\N
f0b22d9a-e5f5-4735-87b3-d4e5bb450ea8	394d14d2-8848-4ae8-8575-44b4ed88f594	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:26:24.085133-05	\N	\N	\N
2dafc000-5520-41ad-a56f-bdb7e8ccb2db	97049860-09e7-4986-8364-4e53bb9f28dc	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:26:24.643813-05	\N	\N	\N
2bad0516-2f0f-45be-8ed3-2eacefe3d471	2575362f-5c68-408c-951b-4b38e2e9dc2a	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:26:25.207057-05	\N	\N	\N
0a362bbc-ef4b-450b-a55b-351158e61d63	a499748e-3a63-477d-9042-2c9a1a9756b5	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:26:25.760295-05	\N	\N	\N
36500015-0115-4e69-8841-5fb30db51a39	0dfc31b6-95e2-49fd-b0c1-6234ed2538ca	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:26:26.351418-05	\N	\N	\N
9199110e-f43b-43c6-ba75-b879d88ed688	49491300-4816-49a7-b5da-a01fa46b2adf	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:26:26.973159-05	\N	\N	\N
529725bc-4914-4994-80b6-dfb03b128724	5577810e-8764-469f-9934-a37212a7774d	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:26:27.547268-05	\N	\N	\N
9f7938af-9473-42d0-aea9-b48079a04b7d	23c9a17c-dfb2-407c-a4a5-c7ebc56fa2da	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:26:28.075692-05	\N	\N	\N
2c48213f-ed42-4e99-8be6-31749b3d78ed	2b584260-f73d-4979-b3e4-5f42089d6e8d	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:26:28.60747-05	\N	\N	\N
0d545bf2-885c-4c74-baf1-284862295421	18ebd144-7fcc-4d00-9c59-252f48acec5c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:26:29.141201-05	\N	\N	\N
14338fe3-631b-436a-9084-adad99f78b20	d04e098c-f799-4e4a-bb84-28d3dad41071	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:26:29.729562-05	\N	\N	\N
ee7c7208-7730-453a-9426-9454b709cc8f	6c269aed-96fa-4dcf-aab9-fc7fd870f387	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:26:30.312119-05	\N	\N	\N
2aa2daa0-17ca-4870-9b6f-8770d3ecf242	b940d46a-4f70-4a21-8b7c-932db040fd0c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:26:30.87177-05	\N	\N	\N
7629601a-a875-4a09-b513-42590e792a60	abd7e8c9-31b9-444f-aca3-d40c562a79e7	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:26:31.466837-05	\N	\N	\N
5328dde3-3cd9-461d-bc08-b5286e902773	84ce7867-57c6-48d4-a908-c8cfd2688242	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:26:32.052681-05	\N	\N	\N
c30c709d-f84b-4f2b-b8e2-956d78127b64	ef769bdd-9095-4765-9326-c2e1ae5eb54a	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:26:32.639517-05	\N	\N	\N
b1251451-2c44-4253-9657-b1c26dee2229	15f57479-ce5f-4740-9e42-3ff478f9eba8	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:26:33.228298-05	\N	\N	\N
57813843-6f95-4588-a54f-575a609eb381	c89eb03e-6c6d-43b9-9fa7-5f8d3cae968f	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:26:33.809806-05	\N	\N	\N
4acb8c9c-4466-4d8b-a9e2-280a42700cc8	a3345544-6389-4352-8ee4-23d21d871755	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:26:34.390961-05	\N	\N	\N
5d7b2bb4-be4e-4bde-8205-65563aaa51d2	a65a6166-7814-4aba-8133-009b2a2bf870	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:26:34.977606-05	\N	\N	\N
730504db-1eb0-4540-923e-0fbb11d88a74	dec57b2d-8488-4d9d-9922-bbf28cc43f56	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:26:35.567309-05	\N	\N	\N
903baad3-7d63-430f-9edc-f3189dc6cc1e	76f605c6-f730-4d16-939f-bd82c7fdd8c6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:26:36.144469-05	\N	\N	\N
0253bdca-ea4f-409e-8e10-ff37bf49eac2	6d056566-7b9b-4f53-bb1b-9136d27f59a5	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:26:36.742821-05	\N	\N	\N
e78528b6-7dcf-4985-b9f3-f6e1ce77bf96	b64e21f6-a598-4b0d-9508-73af614f7331	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:26:37.349637-05	\N	\N	\N
286590fa-0165-488e-9a17-43ab37789867	953804ef-ab28-414a-adbd-7f1d92a13fae	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:26:37.947849-05	\N	\N	\N
c4bae38c-329f-4847-ad34-f517e285fdd9	7914a9e8-8e52-46fe-9297-879733772af1	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:26:38.487285-05	\N	\N	\N
7b457455-cbec-400e-8b6f-61e0ff3355b4	4f332e1f-9ad6-440f-a28c-f7f93d71ad5b	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:26:39.039315-05	\N	\N	\N
f746757e-3a24-4e9f-b277-e81f01a2d6a0	73cbef6e-6faf-48f6-94cb-61c8f2632322	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:26:39.610344-05	\N	\N	\N
93e5d79a-5412-4064-bcdd-ea91b6bc06cc	41d60db3-c8cf-4f81-88ca-140a7b80d8ae	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:26:40.147421-05	\N	\N	\N
69388441-7cb9-494f-9e8c-4d4d5bc4d208	97b86396-e4d0-4468-a9b0-024e7c7c3b44	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:26:40.690432-05	\N	\N	\N
eb7bb165-df25-4748-807a-d0efa0d6295c	352a4e5c-c260-4161-9e77-fb00ad1b26d5	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:26:41.226774-05	\N	\N	\N
8051fd4e-715b-4d55-826e-07b1d59c7a13	8face643-2dc4-40b1-8573-4f7035156be7	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:26:41.795244-05	\N	\N	\N
8cb67131-490c-4202-bc98-cea0ccc696be	cf61c3b1-5ab9-4758-9e7c-a6880cf4f765	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:26:42.355152-05	\N	\N	\N
3626ca1e-9078-4d39-b9fb-59ff1bfdb986	62f3fb90-72db-498e-8d49-377b1c144dda	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:26:42.919895-05	\N	\N	\N
eae737fc-a2e8-40ee-b2cd-2b06217d8d15	fc2ad202-eccc-473e-8e25-cecbb4896793	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:26:43.472552-05	\N	\N	\N
d4bf1e1e-5d95-4080-bc79-d372eb617eb1	c205da2e-65e7-497a-8060-6b2816314d5b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:26:44.027026-05	\N	\N	\N
eeb98cdf-295b-4d3d-9b13-8e5c47aaa6f4	2724570a-d845-487d-8ab9-54be2b9ed547	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:26:44.583983-05	\N	\N	\N
dc836d89-d8eb-4d3a-a582-c1c08caedd99	9f5a0be8-97f6-4827-8672-0949cdc59c36	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:26:45.148096-05	\N	\N	\N
f246f718-2012-420d-862e-fc1c84105bd2	36cf8945-2a34-4d32-98fa-03e5a76e0e59	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:26:45.704376-05	\N	\N	\N
54970fad-edfb-4465-b00c-94922fc3baf7	ab1986bc-dbae-4e72-ad75-f41ee51ba734	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:26:46.274022-05	\N	\N	\N
c8589c64-0349-42b3-a925-04ba06a5a37c	e2f5ff94-5ff2-4413-932e-6876af4ad872	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:26:46.845976-05	\N	\N	\N
b0d0d189-74ed-4269-822f-c36b82fff591	e7744c87-b37d-4010-ab99-472d19a79ce4	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:26:47.411191-05	\N	\N	\N
5270785d-90f0-4ae2-abd0-f86ad4ceca2f	b9e2f09c-9bf4-4022-bcf7-1f0af1a0e738	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:26:47.967983-05	\N	\N	\N
386b1bb0-1162-4765-a445-029ace553343	61690be7-fa15-47eb-81c6-4b2b4a8142ec	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:26:48.529937-05	\N	\N	\N
ec81fa84-d808-4444-9cd4-0f2f769f4579	f876b81a-dacf-4c5d-92d7-4aaaa424065a	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:26:49.089696-05	\N	\N	\N
edd3bdfc-d501-4427-909b-d68f38c4bfaf	f941d8c8-4517-43b4-a714-00446c443df7	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:26:49.665093-05	\N	\N	\N
729fe781-84b8-4e11-bc41-b83075d4972c	e7bae2ad-5ce8-4189-871f-c547f1d16b3f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:26:50.231917-05	\N	\N	\N
c905fdde-f676-4a33-9abe-5035a509c978	e8fef0b3-641c-47bb-840d-0035fcfd58a4	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:26:50.800381-05	\N	\N	\N
6c45e9d5-6d80-400c-b4e5-a973eca4cf6b	578a5431-eefe-456f-9e45-f971fe1e3078	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:26:51.368199-05	\N	\N	\N
0cb4b87d-8304-4028-9edd-272fd7df773c	08d1d83d-0ac1-4feb-bb42-a1cb737ddc56	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:26:51.944015-05	\N	\N	\N
bbcd98fa-86fe-40df-96e0-371e9bc339ea	905d98cf-8218-4bdc-a220-68c699c2a99f	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:26:52.53253-05	\N	\N	\N
aa1d672e-bb70-4e06-8b6e-20846bf62619	d3f85a84-c943-4c3f-ab83-990d5a5acb38	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:26:53.118393-05	\N	\N	\N
bd277ca6-df89-4d92-b1a2-f838898d95e9	90fbd08f-4583-4cf7-adbf-146fd54f1381	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:26:53.686274-05	\N	\N	\N
9931753c-4b0c-4cf2-b0cd-63a30b0c5ab3	933ca263-fc10-44dc-8469-5ef14210dfd3	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:26:54.24868-05	\N	\N	\N
dd6e52f0-e46c-4845-bca9-ff3dc0d288e6	96433773-0735-495f-8aa8-769141604f54	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:26:54.79397-05	\N	\N	\N
508f4ac5-45db-4a7d-867c-979969f44281	807d4de6-0dad-439a-ba4a-a91c4abf7ed3	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:26:55.342331-05	\N	\N	\N
6b82c53a-e361-4fa0-95cc-c6f75a135939	95d58772-8f08-437e-b9a1-e6322c9076ad	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:26:55.913905-05	\N	\N	\N
2ee12f6e-2490-47ae-be6a-16d3ee038234	855fded0-9310-497b-873d-c666d895c43a	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:26:56.486784-05	\N	\N	\N
dfce38c2-8785-4b8e-9b47-d29919bd4f3a	dc16dde0-552d-4be6-91ba-11a3952b34c9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:26:57.049604-05	\N	\N	\N
a09a7136-a7b3-450e-8933-25282a077058	0dfb7afa-9cd5-4b63-838b-f3823a561392	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:26:57.585636-05	\N	\N	\N
745b959f-096d-4236-979e-057867082a1c	78557a2b-8341-4bcd-b193-00dc015f7f05	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:26:58.151716-05	\N	\N	\N
6c5b51a0-9f13-458e-b612-d1d5affa18a0	14b1b07d-8d18-4222-b704-671e61ec2436	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:26:58.713847-05	\N	\N	\N
aac4fbcc-c32b-4f04-b785-3281e9805804	f46ffd37-466b-477a-b68c-3f792ae0c524	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:26:59.268768-05	\N	\N	\N
4c915ad4-abbd-497c-8cdd-ec5cd73264ee	993bcfb4-fb9d-4fa9-9591-33a9e3f4c2bb	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:26:59.845195-05	\N	\N	\N
ca85f368-6d88-46dc-9c07-b5749fbd88ac	b7cd69e1-5aa3-4692-9b9e-790cb1baee98	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:27:00.399594-05	\N	\N	\N
3eee4954-2991-4998-a694-3006a93649df	e0c2c8a5-7d98-4987-9bd5-9f4c5d45a154	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:27:00.969048-05	\N	\N	\N
0c5ab6b7-2b6f-4eee-9562-2222de8393d0	7f64631b-29df-479e-a968-dc266723d37e	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:27:01.548525-05	\N	\N	\N
2b939a91-f444-4eb3-8e74-93a28361e4b5	bb212762-bd19-4ca1-ab3f-110e7d7f8856	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:27:02.116078-05	\N	\N	\N
ba7a9c9c-8a9b-423f-8bed-3f0ec0d9126c	bb162f50-7f00-4c42-9208-523cd007f3d2	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:27:02.675774-05	\N	\N	\N
714a4892-fb39-4021-bc24-8dbd04b9cef8	21f49c80-1916-418d-b9cc-b736e88201b9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:27:03.204123-05	\N	\N	\N
10b1afcb-fc06-4be9-a6a0-28f6a47f1408	f1cee740-c8e2-46ac-957d-03b8b0fde7a8	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:27:03.762381-05	\N	\N	\N
80d7c7a7-8db5-43d5-a301-728348410c78	21021cf3-216e-4196-a283-77dac9c46511	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:27:04.341992-05	\N	\N	\N
7fed74a2-1727-40e3-a296-3c8aa7319992	6672c810-ead7-4f84-8808-005dd893f9b5	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:27:04.909783-05	\N	\N	\N
ec1499c5-0484-4f4b-b6d0-5fb900349275	cdbac3d0-038f-4ed1-9e75-6bac24201eb9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:27:05.48025-05	\N	\N	\N
57548696-7ffd-4ffd-9734-bed8c1851d3b	2056531c-a2b8-4130-94bd-fa36da64b516	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:27:06.056912-05	\N	\N	\N
c743bb1a-b0e5-4dc6-aea6-d40c603d322c	f55d7df6-8cbe-4610-8adc-f1fededc8dad	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:27:06.636104-05	\N	\N	\N
f52081c0-fba7-4bc8-a8bb-d648d0d08fa8	84073095-07a1-4dd8-aea4-611fe5121760	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:27:07.211803-05	\N	\N	\N
94b37d61-e8f1-4f40-be51-b0391332809c	a6cb93b7-7b92-4e06-b0cd-47529861b744	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:27:07.772179-05	\N	\N	\N
7d0cf608-5001-4f43-9b3e-52943fec40bb	b97a3f36-c18e-42f9-8f2a-57becd595f6b	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:27:08.307934-05	\N	\N	\N
857fff3c-4c66-44e5-9585-56bef9d28d1f	d87e2d83-ab84-4ad3-9015-fceb7bdff402	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:27:08.873593-05	\N	\N	\N
f3e64afd-288a-44a2-9029-0a09b946f9f4	c431bbc7-cc3f-495e-9034-e54456f3c145	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:27:09.440267-05	\N	\N	\N
9bb0d9b7-0481-40ab-8956-eafd817e4d38	e9664e46-5c4b-4d6c-8193-dd928137df3e	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:27:10.01612-05	\N	\N	\N
68a45e75-60f8-49d0-8c11-520c376f121c	60f7dc9f-6244-4f23-80b1-4372b0cea625	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:27:10.552369-05	\N	\N	\N
81824f63-4463-4430-9e9f-91f659fcc83f	f5166fa2-2d58-44b0-b430-8a8122110d62	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:27:11.118081-05	\N	\N	\N
c1b9cb83-e658-4cc7-af64-51bde3f1d967	339ca863-b90c-46bb-9c97-810db9bd8080	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:27:11.686232-05	\N	\N	\N
1b763440-d1f4-4169-9c67-a82324336ada	250585a8-00a3-42e0-a2d2-8df03dd9b6c3	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:27:12.220451-05	\N	\N	\N
94dac3ec-2fb4-446a-8d98-9fa4289096e6	5fe2bf3f-41f3-44c1-bd2f-da73b0492563	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:27:12.79049-05	\N	\N	\N
73b52c2a-5cfc-4959-8bf6-d37d3626cdcb	1390a165-d4da-4fd9-93d6-6a1c06024c92	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:27:13.354404-05	\N	\N	\N
c1286241-9d52-473d-8d19-5ed92806dd36	1c787e73-1851-4239-85e1-4866388364fe	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:27:13.921905-05	\N	\N	\N
03ca2716-55a7-4d85-a2a2-d2bb6834eb33	91df104f-373b-42bf-9846-45bec2a4433c	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:27:14.501457-05	\N	\N	\N
b91abb21-d15d-4a08-af72-7c4b6feb724b	153d5614-e732-41aa-ae26-e62ac5f40799	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:27:15.046488-05	\N	\N	\N
3e185bec-53a7-4bf0-b970-a1ed8c251af1	0c44f3f8-7e2e-471e-b3db-106d7f356ae8	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:27:15.601484-05	\N	\N	\N
690153d5-2f0a-4c84-be4e-b8b5526b545d	93dc72b7-0603-405e-b244-a6b2d8cb9308	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:27:16.16199-05	\N	\N	\N
9c9fa62c-1d9b-41ea-bcff-9de49f93550b	b646c8bc-7062-4136-836a-2276b039ce84	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:27:16.73461-05	\N	\N	\N
44810c49-8c7b-46a8-857a-80dcfa731a5f	605fe520-84db-4397-bb3d-f16b603516be	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:27:17.326305-05	\N	\N	\N
f7118d11-0209-421d-b5f3-3d639aabf444	4300ba30-d315-4cdc-b4e6-b0c68f9d76cd	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:27:17.909253-05	\N	\N	\N
1adabc2c-b40a-4954-880d-c994117b4f80	4f4bd828-7895-438b-9827-53d1e12d116d	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:27:18.483112-05	\N	\N	\N
eee80d90-4632-49e0-8704-9ba133a58de1	91b8453c-1216-457a-9917-f6f40acb0880	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:27:19.059944-05	\N	\N	\N
8529777f-ffdb-4aa3-906d-e9629ecea18b	3a7a291f-099f-4ece-9075-22d1d633a4fd	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:27:19.62416-05	\N	\N	\N
61d9c88d-eb50-4379-b3e6-4411339387a2	66db6165-4b24-4cb5-a22c-7d7f2a4660b0	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:27:20.184258-05	\N	\N	\N
7523fb7c-b5a0-49b0-b77a-4488dcad7db4	fb4c9ec3-7004-40a1-b2bf-3f71b443b47d	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:27:20.765167-05	\N	\N	\N
63876618-e586-4dd3-9fe8-4af7307442f8	fff02275-ab05-4195-a963-1a1209d00bd8	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:27:21.321128-05	\N	\N	\N
e7748102-ef06-4d65-8630-79c26cdb1134	d982e836-08b4-41fa-8ca9-67012b3e8d19	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:27:21.904545-05	\N	\N	\N
226a30d7-e6fd-47cc-83a2-d659afa00de0	2a513be4-f454-4d50-aece-4d348287d498	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:27:22.495697-05	\N	\N	\N
130b43ec-d1ad-4d23-a345-535c6653ad9d	f224ef0f-bb03-4327-83e5-85d1d9567fed	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:27:23.069127-05	\N	\N	\N
68f0f448-4f92-4754-aeab-49a86786aa7e	cdb95b87-c33b-4dba-8666-6ff94cca379c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:27:23.660347-05	\N	\N	\N
af4ad459-63ea-4af6-a7e7-8c1640281a34	e6468d00-b9aa-48d7-bc1c-33e2e440e5b6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:27:24.220867-05	\N	\N	\N
238ca427-f794-4b06-a0dd-744f211d269f	a920e183-2112-4217-929c-51b4602e43d9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:27:24.807202-05	\N	\N	\N
33ec14eb-fcef-4e73-a3de-59453efa2a9d	8d7ab715-30c2-4f81-9028-929f72e19123	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:27:25.396508-05	\N	\N	\N
4414ca62-2034-4ee8-b309-c049b72fdf91	fa7261e5-ea54-4d86-b04b-64771d538ac0	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:27:25.971027-05	\N	\N	\N
00ce28ad-649a-4c1b-93ea-c0c0bc12c5a9	e4ea14b8-b0c8-43ed-81a3-acc303d89312	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:27:26.543871-05	\N	\N	\N
1276a6a4-84cc-4848-8862-be67c9822eda	314394e7-14fa-4d2c-a5a1-20f2aa1004ec	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:27:27.128231-05	\N	\N	\N
84f408f4-40b1-440e-810d-a28e1bef662e	57e9f58f-1115-4a43-9de2-df9717cf6b0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:27:27.699054-05	\N	\N	\N
b47b9714-7894-49d4-aab4-34c67dbe0427	2514e0c9-cefd-4781-ad18-2c74c282c90e	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:27:28.275061-05	\N	\N	\N
d0d7d931-efe9-4687-bccf-4ed46596d7df	ccb2b663-81cd-453f-93a7-ff7921dd0752	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:27:28.778597-05	\N	\N	\N
668dfd98-0eea-4748-adc0-23e218a74960	e2100893-cc25-40e8-8bde-8d22be80084b	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:27:29.345226-05	\N	\N	\N
d46acca6-a321-4b6a-81b0-3a60b9da6fe6	ec0f45df-c01e-4ecc-abd8-888b06d85184	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:27:29.92744-05	\N	\N	\N
e3dadcd1-fe6b-4f5b-876b-bed5f795dac4	6a4f95a9-d46d-420b-bb78-e395bf686f6d	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:27:30.552788-05	\N	\N	\N
8f5eeddf-00f3-4363-afd3-add114ddd3e3	9dc819d8-344b-4990-a31f-420dbf2cc8cf	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:27:31.105522-05	\N	\N	\N
6a6b0af5-6832-4268-90a1-421b25802787	1b549b20-c6d4-4399-a510-7380abd3d243	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:27:31.667749-05	\N	\N	\N
f42183ef-cf34-4ffa-9643-918495acce0e	4fd860fa-397c-4579-aa93-f1eaf214f84e	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:27:32.233957-05	\N	\N	\N
8c38b886-c059-425b-8838-e5b2ca1081c2	7b219bc3-cbe1-4e25-a3f0-409b9ad4ce34	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:27:32.794571-05	\N	\N	\N
ee43a36c-7605-427f-aebb-a08905284e77	a1fca2fb-d651-4c8e-8c3f-0c2076308f6b	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:27:33.357911-05	\N	\N	\N
378f7a4d-f46e-4937-9826-ed94a66dd54f	48dcff2a-16e6-4fd5-bb3b-7b0257c5be32	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:27:34.024718-05	\N	\N	\N
4c65e3a1-e843-4e8c-9cde-aef4e409b574	d1c9968c-8fa5-4468-b602-d12d66be29cf	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:27:34.599981-05	\N	\N	\N
98bac927-e35f-4aa4-a762-73da7eadc848	6f7e9820-b708-46e8-94f3-b8a104451fcc	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:27:35.184071-05	\N	\N	\N
5506081f-db6f-4077-9c69-7ec809a97b49	5811e4ba-7ae1-44c8-a85b-5bacef999b00	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:27:35.753247-05	\N	\N	\N
855b11ea-1573-42df-b038-08604510393b	a831fb42-46d1-4aaf-a8c8-b3ccacd7350d	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:27:36.32632-05	\N	\N	\N
f2164297-829e-44f7-8e1c-a4ac62467cf4	4702a195-e173-483e-aecb-2b433494f6d3	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:27:36.908385-05	\N	\N	\N
a0f8280c-cecb-456f-9daf-89602aa64b23	217cca08-d2b8-42a9-8d20-f137910efc5f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:27:37.513257-05	\N	\N	\N
a273d462-ad40-4f15-bfac-19a3b051cba5	74f0f5fb-adb5-4cdf-ba29-6a131966e36d	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:27:38.092044-05	\N	\N	\N
20b3183f-04ff-4e75-aee8-44e68c8d1674	ec60c83d-40bc-4477-bed1-e5c9881c4fc8	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:27:38.690177-05	\N	\N	\N
e09ac0cd-2beb-42a9-9194-570a78a1e715	0812d4bf-75a0-4c30-861d-0da8d936d2e6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:27:39.257496-05	\N	\N	\N
dc74e069-b995-4f34-a7f6-3072360435b1	2e135b3c-9145-4810-b745-baca1b65c70a	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:27:39.843256-05	\N	\N	\N
060703a5-5fe6-479c-90a7-6a488224f209	19118f32-5cf3-4cb3-8a5a-72fca55f0173	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:27:40.421505-05	\N	\N	\N
85256b6c-2fdf-494e-818f-397d490d7025	52698c70-bd3d-4945-9f9b-5028ba7027cb	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:27:41.009883-05	\N	\N	\N
965646f9-de74-4c92-858d-5ef32eaa4622	03933950-2bb7-434f-b29b-96147a19c5c4	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:27:41.578403-05	\N	\N	\N
e1606811-30aa-4b40-ada9-2343f896689c	51b3a2cd-2492-4964-887d-5caa361d1cdd	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:27:42.160828-05	\N	\N	\N
8ddb5b77-6f91-4aa1-9579-c7536e1226f5	203c8bfd-fc25-4ccf-84d1-2f34448e3776	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:27:42.762125-05	\N	\N	\N
ad3dd79e-a2c4-4b15-8baa-3c2f46773b1a	9a68d015-77fd-455d-92c8-d41a59230282	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:27:43.348917-05	\N	\N	\N
9644ca63-04fd-45fd-8401-3359438646ce	b872ff1c-d143-4f34-88bc-6aee099ee5a1	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:27:43.937226-05	\N	\N	\N
f6ed2275-1a52-4b54-b010-da55818b3044	3b3d74d6-d8e1-4f37-bc01-d908d864c0b0	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:27:44.539595-05	\N	\N	\N
1a2ce48d-2740-45c3-98d6-88ab77a5e9f7	604cf805-2379-4b94-99d5-523740c3a58c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:27:45.132194-05	\N	\N	\N
99f9aff0-da6b-491a-b7a2-f2e949659188	10d3e650-cd1c-4994-85e2-d0ce61720877	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:27:45.721068-05	\N	\N	\N
aaff77e5-cafe-43cc-97c3-74064bb0094f	205b7b98-2a57-4973-b1ed-2f5aec96123e	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:27:46.307787-05	\N	\N	\N
88c17d42-252e-4050-ab8e-464c20349577	2ef83911-71fe-4bc7-b13a-7cc16030fad8	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:27:46.894471-05	\N	\N	\N
5b610e13-2d13-4846-bc4b-3f75480d9a37	48fa3c1d-2280-45ff-9038-61d3f4f2cf20	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:27:47.491267-05	\N	\N	\N
e73f9e86-0917-4cc8-8f4c-81ce5c3d30fe	cc378c43-cbd8-4fc6-9c83-7e45abb3e6e1	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:27:48.073741-05	\N	\N	\N
836663e4-97ef-4cef-9c95-b0b69d349e1d	499eda58-03cc-40c3-9633-11812c8a03a3	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:27:48.63739-05	\N	\N	\N
6debfe37-bb90-4730-a975-24fd59245155	f7cb07b2-2f94-4e81-8799-8b60128ff583	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:27:49.233074-05	\N	\N	\N
4dcf6b06-97d4-43d7-a66d-c2ec521c16d5	5a140fb2-abed-42f7-b52d-f7197c3c312c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:27:49.821359-05	\N	\N	\N
dd447805-5ba2-4505-9be0-651939b1470a	21349f4f-5082-48c2-99ab-54c9acff9ac1	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:27:50.411466-05	\N	\N	\N
6d259b7c-4a0f-4059-834a-4cd3468acf68	bd7bc8f8-b7b5-407f-aa82-47ae5e9ff59e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:27:50.999459-05	\N	\N	\N
ae1fc8f5-ca06-4bcb-a08f-c24421ec1a42	8f6e378b-a980-4d31-986a-5343ca8b04fe	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:27:51.568037-05	\N	\N	\N
a01e0dfa-2853-4603-8a1f-9d9d94453572	d43de11b-ba9a-44f1-aace-d294a85f9c81	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:27:52.146456-05	\N	\N	\N
7a537f86-f69c-4a67-bef9-ea014bd02808	967ac167-7d4d-4ff7-acb1-b635ea406419	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:27:52.724937-05	\N	\N	\N
cc4afbf6-4f44-42b7-8f5a-1e1ed4cf4612	22ba018d-5dc1-47eb-8137-2a8344f06f20	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:27:53.320279-05	\N	\N	\N
464dd6f5-2bfd-437c-b81d-fe7a63fbb621	972472ce-7790-42a3-a969-6cc8b78564ff	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:27:53.903387-05	\N	\N	\N
ecf3a338-270c-492f-b57d-f8fa9ebe2738	a545956a-1117-49ec-8b53-4561a595ba24	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:27:54.485983-05	\N	\N	\N
d3b4c15e-1509-4f54-a331-e4855755c7a8	55176420-23db-4d89-8fa4-22b17e66203b	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:27:55.065506-05	\N	\N	\N
e655459d-46ac-4dc6-be61-117dcc0d3b43	d90acba5-5656-45b9-a2d8-2dd1468a9ce8	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:27:55.657805-05	\N	\N	\N
948ccf5a-b619-4daa-bb6a-052ed3f3df56	888beba2-b251-4dad-a8dc-a413221c7cb5	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:27:56.245703-05	\N	\N	\N
67d8aead-f6df-41c6-802d-422d55670807	b7b99f47-592e-428d-aa0d-e318b6f4f82d	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:27:56.839753-05	\N	\N	\N
917046f9-a015-40aa-90d5-f836cb8a3422	3e2b2a06-72f2-4ab6-b698-79cac1003b29	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:27:57.433341-05	\N	\N	\N
4ec8eea5-7fac-457e-b89f-e2b6b94ec765	0e094829-0526-4a10-b712-c3ce8ad70ef2	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:27:58.037586-05	\N	\N	\N
69a633c5-2534-4488-85d3-d91752aa5ea3	1a509d63-0d87-465d-b713-6b5c0e347212	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:27:58.639248-05	\N	\N	\N
2fa95d0f-5520-4c08-9482-c7abc64ad342	eee03708-1677-4e52-9f95-bf3135b42153	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:27:59.237838-05	\N	\N	\N
153a08c3-cce6-495b-9542-7ecf45863eb2	9e0096a6-e21f-4fd2-8775-2045072e9d41	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:27:59.821176-05	\N	\N	\N
3498e4e1-3ac5-4733-9dd1-5a96a2965c20	d6a1de81-fc2f-4455-8c0d-b77bcd89a20f	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:28:00.415907-05	\N	\N	\N
4b6b2d23-d826-4c1a-a444-938e9cd266e6	bcef825f-3068-445e-aba9-d3d1022ec351	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:28:00.999163-05	\N	\N	\N
3d9a3e13-b668-4427-964e-f529dcc61eb4	c0e5dd95-9c70-4da2-b17e-1f93224f094a	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:28:01.563165-05	\N	\N	\N
0a0b0bdb-99ca-457c-8118-46d4534b532e	522ad9e8-e820-435a-b48a-05a2190c88dd	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:28:02.167939-05	\N	\N	\N
794f7892-ee4d-4248-8486-2a8637f27b73	b9065d1a-6e83-4b1f-88e5-7c6f25f030f3	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:28:02.754485-05	\N	\N	\N
25545d14-e022-4dc3-8091-a9a51d34dc11	cfb51bfe-77c6-4346-b425-e8aa89de0927	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:28:03.317916-05	\N	\N	\N
8eac58f3-e8a4-4aa1-b8cc-3c54212e7e37	9b3255d2-a64f-41c2-add9-c739cf25b882	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:28:03.913466-05	\N	\N	\N
2b1caa48-5bc4-4672-9b48-df5ac02c4110	5b017e78-7b51-4bc2-9718-5b7e36b0b589	778c75fc-b7ac-4e94-81f1-30e42f0763ed	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:28:04.508135-05	\N	\N	\N
cf06dd78-c8c9-459a-89d1-d64ea11563e9	d06d026c-e4d1-4418-b0e2-5a82ce94c9ea	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:28:05.088883-05	\N	\N	\N
8d243393-8010-44db-833f-a22761eb40b9	f97b6146-5d44-47e6-840c-a76bd793dfba	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:28:05.698725-05	\N	\N	\N
d989a2a7-fecf-4d27-a3b3-7c5ca7e68a94	e9bb6f6c-ca29-4700-8106-ea3d746a4de3	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:28:06.288376-05	\N	\N	\N
8da9e4ef-3813-4643-918a-b5bd87bd88a6	42ad3c6c-6304-426d-baca-d9646e924d65	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:28:06.905375-05	\N	\N	\N
3674ad4c-15a9-4e0b-9c11-ca0b38f8328b	b5db6150-e122-46d7-ab5c-39c8b77c92c0	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:28:07.515933-05	\N	\N	\N
0f2ea127-e014-43f8-9fbd-8fd750f5e357	a067cc63-6f6a-4047-828a-44d01a46f6f2	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:28:08.109647-05	\N	\N	\N
6312629f-0695-4f89-be58-036ef560343f	09076bb4-77e6-46db-b3ce-9011558af5de	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:28:08.725366-05	\N	\N	\N
19466bd4-7a5f-4584-8050-905e2d795946	b308aca5-bb8c-4a68-b47b-0f5fd42c7865	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:28:09.318761-05	\N	\N	\N
408e557b-b8ea-4c5e-acb9-6c1d429d120f	685aa1d5-b7b8-4a1f-b011-8395527b9df1	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:28:09.935816-05	\N	\N	\N
55a1bc0d-36eb-40c2-a248-75c7328cc555	9d0e4ddc-c032-489c-8a48-7e3ab846811f	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:28:10.523301-05	\N	\N	\N
2d4c909c-4feb-4432-a9f7-7e3b344937cf	29023be9-0ce9-45e4-9825-10e1e50bd711	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:28:11.119187-05	\N	\N	\N
121b61ef-890d-4a17-98df-5d8804af5e51	0ee32c2d-4a6b-4c12-b32c-b5da19a364aa	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:28:11.709645-05	\N	\N	\N
6265a749-d08f-420e-bc97-e994f533f654	915f956d-4245-4752-819f-f33f62ef54b9	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:28:12.328227-05	\N	\N	\N
f7b5478c-75cd-40a7-9208-8abc24fac25d	f3100163-c493-49a0-a64f-17acd13560e1	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:28:12.933201-05	\N	\N	\N
5f5a4efb-7475-4ca0-ac93-a5a715fb7568	df761407-3f75-4060-90f3-6e57bcbdbda3	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:28:13.539437-05	\N	\N	\N
9eb3c685-8f84-435e-9117-55486fbdc329	fb226c58-54ae-481d-a979-f4ce97c1cfd3	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:28:14.150974-05	\N	\N	\N
18cdecc8-3ff1-4bc0-9c45-fa18d7206a70	178ea05d-cd89-48cb-add1-618e03cda92e	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:28:14.851475-05	\N	\N	\N
4d2cacc5-89f9-4a02-a266-975a51d02565	faa222e7-b797-432b-866f-ab90dc2a7de5	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:28:15.435328-05	\N	\N	\N
152ec48f-9084-42a7-a7f0-31508fc8c88e	6f1b7dfa-4c0b-43d5-89ab-cb58adf40eae	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:28:15.992182-05	\N	\N	\N
3429799b-1559-4b2a-83c9-3114493742fa	ad10675d-a0bd-4aa3-8111-d5d2232583f5	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:28:16.566209-05	\N	\N	\N
1cb74055-627e-40cb-9182-3646c879cfef	d5a44021-692b-4d81-aafb-c1868da9521b	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:28:17.113717-05	\N	\N	\N
854cc89b-04c9-47e4-94b7-03fe2d07f4b8	5ad73058-f6fd-46ec-a4ab-9abfae1766ad	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:28:17.708213-05	\N	\N	\N
22013d97-8236-4ffd-ab23-e5a7875715b6	c1c171f4-3e60-4b07-81de-8b036e499310	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:28:18.292077-05	\N	\N	\N
dae718f0-4f7d-418e-9d68-949d95dcff67	712b3798-af76-4b1a-8ec5-1c1405f79b68	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:28:18.866849-05	\N	\N	\N
a0270a0d-8b5e-4780-9c91-ad5b19cb1c8f	0306bd74-4817-459a-b38a-151fc2d95122	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:28:19.44426-05	\N	\N	\N
f06f158c-9171-4fcf-8c4b-573218dd6a11	6cd0f4e3-f920-4997-9b61-b5a68dea5b19	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:28:20.030489-05	\N	\N	\N
6d6ccc00-d640-4dc5-a20f-4a1ad064d526	9bec12be-dc03-4eb2-ac7f-6d68efd08363	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:28:20.596341-05	\N	\N	\N
add70ebf-e19a-4ff7-a067-07dc1ca29966	dc041efc-a199-49a7-9dc9-b3cada840c78	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:28:21.170467-05	\N	\N	\N
d86c5fc7-9017-4ca7-a56e-0c056ce3f180	ef68c0e8-ab58-49d6-93f3-d65cb44b9bf0	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:28:21.752744-05	\N	\N	\N
16fa637f-026c-405b-af2d-1ec98e80ec03	110e3708-dde4-4ae5-a418-2139e468035c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:28:22.332299-05	\N	\N	\N
4910db7d-8f98-4233-b65e-030c98e0beed	ca292815-f26e-45a8-8259-d711b8caaab2	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:28:22.911933-05	\N	\N	\N
bfece04a-7517-48d5-bc11-03408dfea99e	42d1cb7e-2bb9-413d-af9b-18357a2917ef	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:28:23.400777-05	\N	\N	\N
202b4107-28bc-4116-b51d-6e81f3a1346b	d759553c-6ab0-4b26-b7c6-b3f86e8cacba	778c75fc-b7ac-4e94-81f1-30e42f0763ed	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:28:23.96038-05	\N	\N	\N
9783ea51-5b8f-4c83-9108-9ec91ac2e29a	876462f9-386b-4cf2-841e-a297b2324ee0	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:28:24.574803-05	\N	\N	\N
8c623d2c-dc74-4d23-a7a2-9b2586243f60	d2d1892e-a89f-4123-bdb0-9fad28c317bc	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:28:25.160349-05	\N	\N	\N
ec2997be-341e-4102-9fd4-1b580d4bcf55	838a7c9f-86ca-4d48-a084-e4986071df7b	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:28:25.743653-05	\N	\N	\N
7c9f5f34-3f4e-4e0f-96a4-dd853f06b836	cb77f441-dbb3-4134-84d0-3b8399a77cf3	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:28:26.330349-05	\N	\N	\N
873fae89-6c36-4265-bcca-c7c4e34f3c0a	d5bb34a3-a7a0-4835-ab3e-3ac7299eaf0a	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:28:26.882074-05	\N	\N	\N
2f32f602-dada-48b7-8dfc-fe135e2b4145	f9760330-71e6-4f8d-bdc2-7a23992c217e	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:28:27.43606-05	\N	\N	\N
bfe1c9d7-ffe7-4885-8365-0d13d242c87f	a572d935-8b25-4e52-b5c6-1ebcfd364575	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:28:28.03269-05	\N	\N	\N
76d72387-62e1-42e2-a2c4-8b013e6d67fd	3aee7ee1-2de8-4d53-9650-dbdd643781f5	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:28:28.581605-05	\N	\N	\N
bdb6363c-a70e-4372-875c-b4cc34392f1d	33f62692-2c55-4d15-be14-7cfe4e6ecaf6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:28:29.144887-05	\N	\N	\N
b2dbe407-ea24-4484-8a04-3897a838c2b7	14c36a0c-4c0f-4193-92c4-905610d87d89	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:28:29.725974-05	\N	\N	\N
3901ff02-4d74-48c1-9d6a-67ed55cd78a1	c8947a8f-4e2d-4f7b-9363-e9e7b6a35531	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:28:30.295542-05	\N	\N	\N
af09cae1-693f-4c1b-ab17-b818f808f8ae	e559912b-40ce-41af-b08f-cac0c2f6c98d	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:28:30.873155-05	\N	\N	\N
b1a15087-6499-4d07-b6f9-a5f8e6b3df7a	7099fd8a-e49d-4668-92d3-b34bb97e3d6e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:28:31.45281-05	\N	\N	\N
eb0007ee-deb1-4240-a0c9-8b8b609526a5	1c61ebec-4ec3-4f5d-82b1-a6e7d4f53f6a	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:28:32.031011-05	\N	\N	\N
e3b3f6f9-7e51-463b-83b9-a74f6e99d281	25b93aeb-cb68-4a55-8ba0-4a8d08687e29	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:28:32.617876-05	\N	\N	\N
309e12d8-46ad-4534-9b0b-5f2ef14f590d	9d3dd5e4-bad3-4dea-8e4b-f535bd36fe6b	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:28:33.192962-05	\N	\N	\N
6e8ebcb4-4526-4e8c-ad07-89c0d33993fa	44c2b6d1-1206-48f8-9fcb-d1e76af89034	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:28:33.776667-05	\N	\N	\N
2826510c-ca91-4d1b-985b-530e7cb7eeb0	68be66ae-a6db-4b18-9445-152167b99dae	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:28:34.353675-05	\N	\N	\N
fa2da46a-6901-417d-8834-c116c6ffcf2a	92a68a3c-9712-41a7-b6eb-4b48e568ead8	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:28:34.926851-05	\N	\N	\N
b6e2e462-eb9a-4ab7-b9ed-e9171fc25f8b	c8f7f33f-63d3-427f-85d8-aa64fd3c89d2	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:28:35.512785-05	\N	\N	\N
b0600205-e29e-4506-86fb-d0447b4a42a9	7836670e-23ac-4781-8fcd-2e742dac468d	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:28:36.102108-05	\N	\N	\N
13e4cb0c-003c-41a4-8c23-58c1dc08cb75	fa32c00c-3fe1-48a3-8ca0-c196e1fa1e58	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:28:36.691661-05	\N	\N	\N
2abd6828-2348-4943-97eb-5224c5c070e5	74956414-21ff-4b7c-8cc3-7b49d460325f	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:28:37.304337-05	\N	\N	\N
3ba61a2d-667e-4aa0-b423-94fc6b40fa73	a0e57c49-9afc-4e6c-8a16-137f18b41814	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:28:37.877703-05	\N	\N	\N
0162e0c7-aaeb-41f4-b6bc-9724b6370988	35f0d242-a2cb-4060-b26f-c59195146b79	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:28:38.457476-05	\N	\N	\N
14e34b1b-c7e6-4b8b-8c4f-d6626c4a8208	758fcabb-0006-4fdf-bb0e-c2d8f5e8f779	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:28:39.035167-05	\N	\N	\N
46d46522-cb71-402c-8159-197d01cc3a62	4d2d8382-6d8d-41b9-943d-461d04b75526	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:28:39.63208-05	\N	\N	\N
05196475-219c-4b4d-8ddd-c1a76010b6e7	d430b226-0c8c-41c5-9941-640d99da2d8f	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:28:40.21413-05	\N	\N	\N
a3eaba61-3308-4513-a21e-92ee29647a84	066717ce-64e8-42cb-82e5-26ad45c9302e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:28:40.805627-05	\N	\N	\N
d49e43af-ab1f-4498-a556-9fb0d8e031f8	6b614b15-09ca-42fb-a58d-375845d26412	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:28:41.385373-05	\N	\N	\N
ef7c918f-28fa-4041-bd1e-e9a5f2d9ab77	f5a389b7-3804-4711-aa26-24c4165d42b0	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:28:41.977471-05	\N	\N	\N
f1dbe670-ab1d-44b9-a2c8-e39a757c8f6d	50b3d7ae-4142-45d4-b3e3-b2f11827daad	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:28:42.558422-05	\N	\N	\N
ccad16d2-2ce8-4c5f-aa87-6646e7b4512a	8a8c9472-7d18-4b54-af77-139504543d4d	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:28:43.15144-05	\N	\N	\N
ce1cace7-6ba8-46b9-ac16-e6c04a1d36b1	869bb49c-25ff-4830-89c7-231eaa6461bc	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:28:43.73403-05	\N	\N	\N
d142c33c-d28a-45c7-99d2-2501cc0c7141	da25eddc-c94c-4a3d-b0af-ad35c5a8d076	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:28:44.323942-05	\N	\N	\N
10133f9d-92b0-4dfe-a87c-1cf836f57313	e77b28ca-bc20-4ec8-bfc0-6eb7165d9bb7	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:28:44.909267-05	\N	\N	\N
48986aeb-b6dc-4f7e-809d-2a7e52437a46	fe7695e4-42c1-43f5-9e58-1376d191b1e2	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:28:45.494972-05	\N	\N	\N
b723e584-a0f8-4304-99d5-04d8f4d951d6	0895be20-cb13-4e22-a1bb-c347081d7aef	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:28:46.081736-05	\N	\N	\N
27e0ea76-b4bd-455d-8219-ce3332e85e18	b3c2d678-70bf-4c07-abc4-b19ae8437bd5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:28:46.693837-05	\N	\N	\N
708de1b5-b258-4677-8f29-f2bcf3a23af4	e994cb6c-df9b-40a6-a28a-0265389da25e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:28:47.178214-05	\N	\N	\N
c85e09f9-098c-4fc8-9660-b64500598e41	e7ebe45d-58eb-40c5-89dd-0604b654d25a	778c75fc-b7ac-4e94-81f1-30e42f0763ed	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:28:47.762824-05	\N	\N	\N
55218f3a-75f8-4ad2-8559-6831a57ba08b	637287c0-ae08-437c-86e4-639f5b4be9be	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:28:48.331655-05	\N	\N	\N
dbc57855-6849-47b9-b4ad-0949fe2d0654	d5b0f8fe-2ae1-4a6e-a812-f2545b22baa2	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:28:48.920892-05	\N	\N	\N
a2a51d11-5671-4633-99ea-44b325b22e66	0337e5cf-a51d-404d-9cd0-aa65b3bd9a00	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:28:49.521812-05	\N	\N	\N
26f8e5ce-ff4c-4355-8b4f-5277782a83d3	655d2e73-a379-4165-8b4a-4c53ed855409	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:28:50.111456-05	\N	\N	\N
6cd99c52-4d61-46ab-9e0e-312b620b0ef0	52197395-aa1a-4906-b5cb-bbabe98ecf62	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:28:50.707507-05	\N	\N	\N
0ca9feeb-9955-4d6e-9b4a-055165869f71	47f52a98-3c46-49be-bc22-c85a38ff284f	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:28:51.289188-05	\N	\N	\N
55ccf211-dcc5-46ef-b3a0-c928540bc7e0	0b1ebe2e-c112-499f-a898-0ce02ec3f68c	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:28:51.862453-05	\N	\N	\N
7dbe68db-6794-4437-9fd4-2230271f3ba5	717c1acd-b2bf-4bb0-a9e5-06f6e9342954	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:28:52.452889-05	\N	\N	\N
5c807d44-0fe3-4b8b-949a-fff9901a7fa1	2ed9d651-6bee-499b-aa29-8398b6f4984a	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:28:53.064283-05	\N	\N	\N
2f05cf16-f425-4a11-821c-5a35d0d38f21	eb94a9b3-78ce-4c9d-a135-8423af016ae8	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:28:53.647752-05	\N	\N	\N
53634065-c3df-4aec-85de-93c73cefd741	fe65612f-8a69-4cbb-ace5-bc4c5129416b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:28:54.231365-05	\N	\N	\N
5ebeb41a-c376-4670-a5cd-113c456bf865	8c46517a-7560-43aa-9ecd-ea76e180a1dc	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:28:54.803598-05	\N	\N	\N
cfafc582-7ef5-4a2d-b0a8-984854846cca	66be866f-0099-4832-894b-62afd1314776	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:28:55.352712-05	\N	\N	\N
ea15a83a-cfe3-43db-9e25-af79bef5e018	2c13241c-12a6-4d86-b020-91f55c7a41eb	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:28:55.919924-05	\N	\N	\N
26c6a83a-4e45-405d-b758-d89ff51c703d	9f678622-dbde-4ef6-b325-c8c613bd2dad	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:28:56.511989-05	\N	\N	\N
0e10dc5f-fcd7-4b4a-8289-e6fa85417893	9392aedc-121e-4b6b-93f5-23cfaf6d772b	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:28:57.088153-05	\N	\N	\N
\.


--
-- TOC entry 5453 (class 0 OID 19924)
-- Dependencies: 239
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, school_id, name, birth_date, grade, group_name, parent_id, created_at, created_by, updated_by, updated_at) FROM stdin;
\.


--
-- TOC entry 5454 (class 0 OID 19931)
-- Dependencies: 240
-- Data for Name: subject_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subject_assignments (id, specialty_id, area_id, subject_id, grade_level_id, group_id, created_at, status, "SchoolId", created_by, updated_at, updated_by) FROM stdin;
a257f5db-422b-4948-be3e-f8f08be474b0	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:23:22.552548-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4e27b0ec-5b4c-42ea-a236-c66aeec95cd4	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:23:23.850214-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
56037be1-5c57-47aa-be75-25d3d6e358a1	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:23:24.042922-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
bfacb240-b8f0-4000-806c-00cda2d3000c	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	75b5394f-2870-4a1b-ac2b-f7a908f985d5	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:23:24.26899-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
13cf27a8-4974-4190-a18c-ee578ce58966	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	75b5394f-2870-4a1b-ac2b-f7a908f985d5	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:23:24.405958-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
98546205-cfbd-4e11-a00b-2e6888d2bcd1	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	75b5394f-2870-4a1b-ac2b-f7a908f985d5	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:23:24.578387-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e25edb94-8480-4909-8e5e-1ad8e41aa327	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:24.798753-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
82bb2423-3440-418c-ae5b-79e28cad41c5	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:23:25.548104-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7c28b1b9-3061-4419-840a-08d075adb76f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:23:26.145368-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
01268eac-832c-4bcb-a873-cf34a9fde688	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:26.277619-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b1d3e427-ef69-4537-85bf-a39b6aa4d0d6	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	df17b496-a9fc-4cc7-b785-e6cbab6e3393	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:23:26.509953-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
856971bb-2c95-4bee-96fb-f700efd7f042	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	df17b496-a9fc-4cc7-b785-e6cbab6e3393	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:23:26.677633-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
947de356-c0de-4a61-b30e-74826655145e	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	df17b496-a9fc-4cc7-b785-e6cbab6e3393	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:23:26.860701-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5e7e9d07-41ee-4467-99cf-22bf7a78b1d1	a7e13742-0ab6-467e-abfb-54a93adbb803	09007542-2861-468d-ab6b-0dd7db77d50b	df17b496-a9fc-4cc7-b785-e6cbab6e3393	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:23:27.090801-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fec88b11-2419-4a98-babe-91a80007c63c	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:23:27.297046-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d3a91519-5f92-4fe3-a8cf-5aca756d5d5d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:28.116075-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
bca4a824-8112-47d0-8b0f-d79fb48b1367	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:28.296913-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
cf49b9ad-b8a0-488d-8b8a-0b22596d5d50	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:28.479376-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9a904b71-50bd-473a-b1ae-14e852988194	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:28.726403-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5422745b-045f-4c69-9ec0-397cd060b4e9	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:28.975612-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6a46c7d0-912d-4154-9190-9d7d0917d362	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:23:29.193084-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0e3eadb3-b382-40a4-8228-71038d15ea35	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:23:29.449158-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c618e66c-fccf-4100-8609-b9f2a0f841ae	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:29.720989-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
83f60b9d-2a76-4a2c-8c7c-d2f4881a8244	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:29.915429-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
16acca24-084d-4b92-957a-879c4317c47b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:30.096892-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
039e1cf1-1f2e-4086-9dda-a3605f102d22	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:30.275896-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
35a79053-7525-47f0-b5e0-9cad51b49137	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:30.446949-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4842c1d6-aaad-4803-8a51-93176b774469	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:30.612123-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c7f4ca7d-ffc3-4a2a-b145-0d5eaf77e434	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:23:30.813262-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
61b5c91d-62f9-4c87-a6e2-ef5fc9594381	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:31.065647-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
75462afe-10cb-459e-8f9b-3073848c1458	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:31.798249-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0e460aa3-a8da-4241-bd85-2b08cbedc000	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:31.956147-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9a1dc82d-55cc-490f-97af-47e7f6d96012	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:32.10833-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
96e76265-d2be-4e8f-8e75-80edf6a0de42	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:32.271105-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f4794b16-f8be-4a9a-bcfa-9d9b8cd409a0	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:23:32.414385-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8ad1023a-6249-4ca4-8054-53f3dff3c8c0	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:23:32.561271-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e8652508-a2ef-4c25-9ba6-5026282b1849	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:32.719287-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b9f648cd-a2df-4530-82e4-02c86d771d0b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:32.888723-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
457f440e-8396-4b3e-8aeb-12f407d742c7	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:33.052808-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
43c3e2e9-6f99-4742-8b4c-bd98384ba183	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:33.197884-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
600c1fec-1ddf-442e-bac2-c687cf328a64	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:33.35254-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5e11f2a7-25a6-48a6-86a0-6c8291fb2f7e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:33.511862-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
47be5770-da3f-473b-9276-998e74c7f7d1	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:33.709385-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c5c5f0cb-dc9b-48e2-b370-e53994eff2aa	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:23:34.450974-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0e8ae7e8-a7c7-4bdb-891e-c3593c096b3b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:34.593216-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
51e83bb3-cde0-407f-8b8f-04ebe39ba534	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:34.751678-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c5b62fc8-98dc-4fb5-b5b9-9405506f70b8	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:23:34.886847-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7091673b-1d13-4f02-b536-c7d631d96c65	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:35.024722-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
564bae5f-cbc6-417f-8f0c-ceef7bdba135	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:35.155114-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
86c86954-90f8-493e-926e-1f7fea982735	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:35.277387-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d415bba8-ed40-4990-b32e-4323dc1007cb	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:35.401942-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f4d42493-a3a1-416e-87f1-13442c0d8247	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:35.53457-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8ffc16f3-d77c-428b-9224-6711c8717d14	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:35.669705-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
886b7a78-3ee4-496c-ba8e-9c2d76bf1fe6	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:35.800554-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
53cd803a-45bc-49ed-bf2c-49410fe85e2a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:23:35.983202-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
16b92d30-0f31-4034-abab-98ad67016a54	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:23:36.688504-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
53c768d0-acd9-435a-9492-7916d204cfd3	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:36.816831-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
78e01333-8306-47f3-bc3d-c48c39ed0ded	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:36.945091-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
579c2652-eb95-4bcd-8554-8409ddb58457	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:23:37.081624-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5fda2982-ab1b-4640-87dc-ab0e5e1e6b7d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:23:37.195017-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
41571564-d09c-47dc-9b43-1682e9d89fc2	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:23:37.330254-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c02b332d-ae31-4e94-ac15-d82c85924f00	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:23:37.969045-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
71911198-16b4-4ff8-8b84-f549a80a890d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:38.082422-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
1551f25c-b0dd-4bd4-a155-3b70dd448f23	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:38.192434-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c1c75aa4-8af6-4728-9b2c-0c316007c090	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:23:38.307332-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0fbc894c-87c2-41ce-b8b7-42512c9359a7	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:23:38.423897-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8cd15b1f-40be-4b95-ac4c-12ac662a40e7	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:38.549129-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9756327c-34c2-44ac-ae21-9fab22ddab79	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:38.66352-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b087d0a1-683b-4b5f-9734-b2ba9b561592	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	5302c538-2dd6-45bf-bfd9-997f248b2a7f	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:38.781103-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
454d988b-f89a-4c43-aa69-467f8bd37a77	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:38.894241-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fcac7885-4668-4e14-a1df-183717ba8545	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:39.520342-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3fae1d2c-e792-4621-9e2d-14ecc6e6b206	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:39.628514-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2f0a681a-859b-4d9c-a1fe-2ed4bac3b88e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:23:39.739401-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7415bcdb-02e6-4fd0-a09d-ea19cf77b266	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:23:39.852955-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
142f1dd4-1d6a-4fec-8881-e611db9b7837	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:23:39.976289-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4fab2ed8-8fe6-48ec-bb71-e1444c3dd913	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:23:40.10357-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3da546ad-613d-48e9-8fcf-40f09ea86f24	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:40.232787-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
48408009-3fec-4cec-9151-630e0a3f9a9b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:40.347123-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7727ab56-0e44-41c5-b3bf-69c05f223302	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:23:40.467078-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b4b91b7e-05d6-4a86-9986-1b83c060d38a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:40.57913-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
166dfbf3-8a67-4dd0-8564-7ef8bba2de24	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:23:40.687563-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b3eaa747-84e7-4502-9311-66e273dc612d	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:23:41.314024-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
538a3a1e-ef9e-44c9-a134-8b3eb67f71c1	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:23:41.41986-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c455c2c4-b78f-4448-b64a-207aacd0fb71	a7e13742-0ab6-467e-abfb-54a93adbb803	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:23:41.528894-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f4ef417e-1217-4105-84f9-095fef139879	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:23:41.642406-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4c45506f-2c1b-4db8-ab3d-d12470237132	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:23:41.762878-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c6965a6b-af0c-43be-9c9a-7fdfd22c822b	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:23:42.442612-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4454448b-6847-4e6b-b5e9-5a0246934341	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:23:42.554815-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8bb91ba4-0495-4a94-ba6d-35e3425e5f86	a7e13742-0ab6-467e-abfb-54a93adbb803	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:23:42.66161-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
bb9b51a9-9635-4ed6-a04c-382d00aa9f29	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:23:42.769971-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c46e53d0-6fc6-40b0-a49e-7fe0ca286e06	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:23:42.891009-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
30647c53-e1da-48dd-a63c-910cd6f06a54	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:23:43.012113-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7f11256c-804b-490d-8fd2-1bd61970f2fa	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:23:43.647978-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a8a5fde0-93ea-4d5b-adce-5921d5febe30	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:23:43.875195-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
76c908ed-ade9-4d21-86ea-29ca29d87321	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:23:44.002647-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b0258c3d-86f1-4064-b4c9-add2882e90f7	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:44.132814-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3ab5d654-9872-4087-846d-8f2265015336	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:23:44.75555-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
80fe785d-a1dd-49a8-9bfc-2130e9a5c89a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:44.874115-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
47421419-143e-4fb4-b57b-d953d7d1e2fb	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:44.995496-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
83a91bfc-8341-4d3c-aeea-6c34a0234c44	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:23:45.114996-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8a15fb09-dd86-4b58-883d-5207b24b2e9d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:45.226438-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8bc57d9b-b545-44fa-9dbb-95f904c78f1f	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:23:45.348091-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c464c796-35ba-4189-bb2a-399322fd32e1	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:23:45.927601-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a47fd403-d680-44f6-aec4-4f9af7d48f9e	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:23:46.053-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
927c27ca-4542-46cd-b0f4-6e3c003ae40e	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:23:46.171322-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
91ffbf79-a22b-4bbc-8d58-8dc032945fa3	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:23:46.290359-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b52fc616-7ef1-4be2-8a52-d7f2ba26c0a8	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:23:46.413508-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4d569bc2-7de4-4a06-8c17-a030f0f4dac9	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:23:46.564076-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ba223dbe-3134-4245-9d65-3b366950e1b8	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:23:48.245515-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3ed6d6c5-831c-4c6a-a29e-f33d6697bfea	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:23:48.372957-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
bebea98d-1670-4a79-b924-d65e1f367f4b	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:23:48.509126-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
28ba09b2-4302-46d2-a4df-9943b92709a3	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:23:48.638326-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b7a9c0ca-bb9e-4214-89e1-af890f6bcb52	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:23:48.757646-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
64dda0b1-4e14-4603-af91-a18ca6dd7388	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:23:48.889156-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e44091d3-edc1-4026-9b61-85dc2a946507	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:23:49.030807-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3f0547fc-f874-495c-82b0-7fcad1f7558f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:23:49.160391-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8469bdd2-ff27-4173-b2d6-d978fbfa3a5f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:23:49.890368-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
64e1c379-e560-48c9-8391-a3e89c197455	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:50.028869-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d61c6def-0752-4e4d-a63f-7c40de291256	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:50.163069-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f2d8871b-1f9b-4e7f-ae5b-befe60234525	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:23:50.293742-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e5c2081e-ee27-4d46-ba28-01621ae65626	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:23:50.427621-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
16ab2be4-1d80-4cb7-8a49-8c1b7d0c217f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:50.563255-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7602cd16-b7ef-456d-b457-72e44c0e43c2	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:50.689279-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
1162a332-420c-43f9-a014-0ac38fd28dde	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:50.807988-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
530059ee-db16-409f-b928-adc6eaab68f5	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	8a5781be-27dc-4569-9858-006b1c7b1f6c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:23:50.95192-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b9ac2246-84be-4551-b32d-c0e70bfea086	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	8a5781be-27dc-4569-9858-006b1c7b1f6c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:23:51.084413-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b1c5703e-fb13-4f8a-8739-1c146637a92d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	8a5781be-27dc-4569-9858-006b1c7b1f6c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:51.212477-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e475328e-39b6-4a71-970b-b268270ebb54	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	8a5781be-27dc-4569-9858-006b1c7b1f6c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:51.332979-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2495f62b-51ce-4f31-bcc4-65e0b9498a4f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	8a5781be-27dc-4569-9858-006b1c7b1f6c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:23:51.459934-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b61b2c6e-7090-4e2c-8939-35501ff51f22	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	8a5781be-27dc-4569-9858-006b1c7b1f6c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:23:51.584261-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c51caad9-c869-4460-a45f-bcc9e497b515	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	54caafb3-904d-4316-99bb-bb0ccac3629e	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:23:51.729592-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ef43e5fe-6e55-44ee-93c2-1bdd46e10653	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	42730a69-7bb1-4b86-99d7-d086b3d66808	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:23:52.394704-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c75603d1-f1c4-43a2-aa0e-328e9c082f83	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	1b75dcc4-d0c6-49ce-b9fa-0583bda3aa0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:23:52.546178-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
be4e2e42-742a-4c4c-ba1d-9100261f85be	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	deff267c-a77b-4952-882c-f8e86f8d585e	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:23:52.698317-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a65dc4a0-44b7-47ab-a179-2c56cca8f2c2	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:52.828034-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c0d582ea-ac4b-40b4-9089-a823034c887a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:53.468698-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
530166f3-5e8f-4f93-959c-609d9c418d4e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:53.594663-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
33faaea6-5017-4c5b-935a-ac94109881fc	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:53.717939-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8f6c193c-f4c0-4fe5-b95a-f57bb5930edd	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:53.83521-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
48d5537e-9830-4e6a-aff5-a28f5773621d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:53.954549-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9d6127a4-7467-4b5e-8c6d-33723d32ea43	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:54.09117-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
468f7991-9100-4362-93ad-89cf3f5ed02b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:54.221545-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4db44e34-6ba3-4c6d-af78-2a8f71277ddf	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:54.359262-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d1cadb35-b275-4a6d-9f57-802835316e59	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:54.493481-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
98b766c7-93fa-41c5-a0b4-93d5b9c172fd	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:23:54.615535-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
37c31675-1edb-4514-aa4f-a28eb202b6cd	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:23:54.739863-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3a3f57db-c50b-45ed-8452-4c365c0ab134	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:23:54.868864-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
46896cec-3b5b-411a-b5c7-c91c0d0916f0	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:23:54.995356-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7001f455-012d-4170-b393-ed91efe8751c	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:23:55.612815-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b967e182-bc93-4d9f-8cea-08c279838a5a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:55.739608-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c8128e7d-31e1-4bd4-b8b5-f84ee62aa43e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:55.866891-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
62a176b6-ea28-47b6-a5e1-2f4229de0a6f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:23:56.006026-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
bd990107-7727-44f0-96f6-190339c8dde8	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:23:56.137417-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ee4f94a5-1d2f-403a-9036-34d8d8fcd891	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:56.274189-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5936c507-e403-4e83-a2d6-d60264d5b362	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:56.40101-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c0e3e0ae-1a6f-4d80-afc4-f0ef4008ea75	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:23:56.521056-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b98b2dd9-22ad-4618-9b1a-24278e5a71fa	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:23:56.639412-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
08742323-666c-4985-9f30-951e6150da68	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:23:56.763669-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fa20354b-8395-46c8-a3d2-627f188a7604	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:56.888925-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b9fb7ffb-e6ac-4f4d-bb6b-0e4bc31a78b4	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:57.021978-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
33178778-990d-4620-926b-07522014c9b3	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:23:57.148714-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
52358b5c-8e38-4acc-a874-fccc735441e8	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:57.282048-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0d19c510-b82b-4cab-a7aa-060b41010e6b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:23:57.915264-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6b19cee9-a17d-47e1-ab64-b47cc6805ede	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:23:58.050339-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fc939f18-7e88-47de-b4f0-f9c68e0631eb	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:23:58.181048-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5f580155-aaa1-4167-9cca-a9ede0fa46c2	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:58.305878-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
82ed54a4-f7ef-4ddb-b349-7b945c2b2531	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:23:58.438008-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
905a2ebc-e4cf-4ac9-8498-2355716fe8b6	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:23:58.568608-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c4cb78e8-4929-41eb-be79-331256c5fdad	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:58.694241-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9cb9e2b7-ce2f-4702-b8f0-e706c42d86bc	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:58.823464-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8e378d72-05a0-4eef-a7f6-d002f49a2cd2	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:58.954429-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6f9a5bc5-2c3c-4684-8171-0362037d328e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:23:59.077256-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5d4ea0fe-8e21-4168-bc92-dda3ce3f840b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:23:59.226068-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c2d8e980-baac-4edf-b8a3-ba69d7b57ad3	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:23:59.351272-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
35842913-a173-4b02-bdf3-c385f0fe7902	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:23:59.485501-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
631d76ee-3931-40c0-82a9-ad9e6ebb545a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:23:59.61471-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7291d641-db5b-421d-a0ef-cd44b039802f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e5d4e482-571e-47a9-b984-fa4454d57bb6	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:23:59.744848-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f5e7679f-78f3-445e-8e75-6b32ffa36d1f	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	f30ac228-20b1-4dcb-b982-0e0b8f55c8b4	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:23:59.907889-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c11679a7-148c-4302-b4ca-97dcf46a7d64	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	22040ff7-8fe6-4f40-9885-fc2c4570b813	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:00.584573-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c82b6d05-0bf9-491d-8407-3c9b31258d4f	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	1b75dcc4-d0c6-49ce-b9fa-0583bda3aa0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:00.815715-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e582d123-8a04-4f21-93af-f6cf28135511	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	deff267c-a77b-4952-882c-f8e86f8d585e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:01.043154-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
414c5370-da2f-444b-91c0-d62791698f4a	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	1b75dcc4-d0c6-49ce-b9fa-0583bda3aa0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:01.173647-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
41749162-bc96-4698-b405-633f2d469033	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	f30ac228-20b1-4dcb-b982-0e0b8f55c8b4	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:24:01.318895-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
00bd2b9d-7571-4c15-861e-f29a21636498	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	bd5acf6a-7e90-49af-8a61-a42276a6772f	2d050b7e-8670-43ae-a7f0-f9e84835673b	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:24:01.994993-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
262d1784-3f43-4076-8f0e-ffca1d91fa70	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	bd5acf6a-7e90-49af-8a61-a42276a6772f	1c195c3b-348a-4fc5-b595-3ce7de76f6c9	778c75fc-b7ac-4e94-81f1-30e42f0763ed	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:24:02.252832-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6dbf2693-d278-4ffa-bd49-f853f7144bd4	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:02.383772-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
46c91ff7-569b-4966-acb3-77b2f6188dda	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:03.025936-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
23a066e8-f642-4b5d-857b-ba9866f4b010	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:03.172503-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
78a657b3-6015-4b8c-ae69-380d0dcf58d6	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:03.322796-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e40338b3-eaf4-4095-bdf2-f69158f1c902	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:03.451769-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
38714e29-1efd-45db-8509-dd97d93e5fee	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:03.592076-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
64f6bfd6-e7d1-40ed-bfff-d7167a8b2005	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:03.733331-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4af80c20-dde7-4628-a84e-1a1fc609a5f7	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:03.864471-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
70fb8582-4233-4913-bb97-18c40dc5027b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:04.010804-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6606a0b5-2f1d-4dab-a845-4f83e438fc38	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:04.155303-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8d9cd57a-b15f-4afa-97cc-9e3e0e70009a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:04.301155-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c1737ed6-6a83-4b77-bdf9-4a2895305878	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:04.437235-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
355226ff-d00a-4403-9cf9-f75dfe0eb323	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:04.573809-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
cbd0a17b-6dda-45cf-8425-e5e09a092106	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:04.709582-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
20d53670-3fe8-46de-b3b4-677eb234324d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:04.84074-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
be861d32-3f7e-4df1-9ae9-632603e9ec47	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:24:05.509022-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
11079f22-d723-4a05-9ed6-82b649ca2a08	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:24:05.64829-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
899f0373-cbf3-4de4-bb5e-581c966f7e27	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:24:05.791901-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
53044f24-bb14-4afa-ad1a-ec8b502c2753	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:24:05.914954-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5206f896-9207-4151-a2b0-9d388f2803fc	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:24:06.049454-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
66d35b5d-c471-4557-9077-e8ffdc4ccb55	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:24:06.170238-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3ffa07a1-adf7-45dc-aae6-04156dce6682	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:24:06.298343-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6405fb64-63dc-43ff-8e0d-cd418b369f5f	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	75b5394f-2870-4a1b-ac2b-f7a908f985d5	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:06.442591-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
45b0c287-5f1e-4351-9144-fcf1ee804ed3	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	75b5394f-2870-4a1b-ac2b-f7a908f985d5	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:24:06.578905-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
1388f5bb-34f3-40dd-b91b-0ec1c1044d77	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	75b5394f-2870-4a1b-ac2b-f7a908f985d5	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:06.723596-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a9b5f3db-f5ae-4aaf-adbc-8728f9bc7245	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	75b5394f-2870-4a1b-ac2b-f7a908f985d5	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:24:06.852362-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a0d10bb8-307a-401b-9f4b-8a12bf66e683	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:06.975087-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ac97a39e-f685-497a-8459-80efc0acf4e2	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	669bb230-dc3b-421d-8031-ed36fc6f52d7	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:24:07.590063-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3149973b-6ccb-4d9e-a831-6af8436c6761	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:07.724839-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3cbc7436-9881-417c-a78f-20fbb6d3c249	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:24:07.850866-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9ec43481-7e27-4579-979e-76ef18d4cbbb	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:07.97808-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d457c2c0-7b2c-4c0d-a838-df985fa1c410	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:08.601954-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e39ca054-7c34-4de3-8a03-871cbec8d4b3	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:08.736897-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ba2d2e6f-345d-4607-b4f6-751a34928b09	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:08.858702-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ef3d0104-0553-4c48-8b54-26ec61ef3889	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:08.984633-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
52bbb895-e756-4752-8e32-f7547d924e57	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:09.101078-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
42f1d1aa-439a-4548-b36b-6ccf27f284ae	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	357d4e77-ac7f-4811-980e-7f36623435a4	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:09.245645-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0c86ae02-9555-4dcb-8d6e-5e8881b1d6e5	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	05d876a4-ded0-4c88-8062-df73e77b5356	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:09.903605-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e4459358-600a-4a6b-8df6-3007f328c1c2	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	4d996508-1506-496f-80a9-c8c672126a26	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:10.05096-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
1e47f6e1-87eb-4dda-962f-3ec754142fc1	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	bc5c98d8-86ec-4327-b9d9-365eaac3146e	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:10.193902-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
741927a9-90ad-4e57-96af-47d377e71813	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	05d876a4-ded0-4c88-8062-df73e77b5356	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:10.319393-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2183145f-d835-4fd2-bf90-e17d4ac79d6d	ae5fa357-e612-440e-a179-8f40f94c80ef	bd5acf6a-7e90-49af-8a61-a42276a6772f	deff267c-a77b-4952-882c-f8e86f8d585e	669bb230-dc3b-421d-8031-ed36fc6f52d7	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:10.454548-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3223a244-b6a4-4025-81d0-15ffa8d94445	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:24:10.606094-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
caddeb73-4e16-43b8-a46d-922d2de201fe	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:24:11.236034-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
bf8c62f2-286c-443a-aa1f-5637e075dc28	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:24:11.37363-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a1dbf3fc-3f0e-4eb8-b94e-89e4bd59213d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:24:11.496454-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
090fa507-3b5e-4bce-8f5c-ae809a078eca	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:24:11.620114-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c9abee51-8b28-4145-8082-5d30c8c35784	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:24:11.740369-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
822add8c-cfc2-4831-a175-2b1b1fccde77	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:11.876684-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
067ce140-cfb5-43cf-906e-b0d510f85a24	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	485a50cd-786c-4521-89b9-2f9d4b58d8d9	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:24:12.007972-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
94558f86-fdf7-4662-946b-4e6b874616d9	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	485a50cd-786c-4521-89b9-2f9d4b58d8d9	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:24:12.136678-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2c0e5943-c22c-48f1-aa6a-607e310a47ef	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	485a50cd-786c-4521-89b9-2f9d4b58d8d9	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:24:12.269341-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
79d136ae-3c99-41af-86da-97dc7f4cc5b9	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:24:12.401363-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0d3a6944-dbce-4d07-8ad9-12cce769585d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	485a50cd-786c-4521-89b9-2f9d4b58d8d9	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:24:12.530277-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2eba323e-7e93-483d-91af-73679c4dedda	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	485a50cd-786c-4521-89b9-2f9d4b58d8d9	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:24:12.650858-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fab143a9-5987-4504-abfc-8a81330b3ffa	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	485a50cd-786c-4521-89b9-2f9d4b58d8d9	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:24:12.782584-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6c4018e0-86b0-470d-bcc3-bb23346a7e71	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:12.958075-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
92a31a1e-b72d-4455-bb8c-6e935bbcf417	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:13.578288-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ce59463e-cd24-45ba-be24-017b0f630edd	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:13.702686-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
eac76333-a313-4641-8b9d-5ddb1fbc3b0d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:13.823141-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a32140d5-34fe-4dec-8b0d-3113b5345d50	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:13.958804-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
1fb2fb68-b243-457e-a93c-d5de68b66596	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:24:14.09381-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
cadac56f-8f3b-4b5d-8f02-cd2eb1278de3	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:24:14.232449-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c4eed450-3a17-40e3-8f4b-cdc97cab6ba8	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:14.36331-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0f875e41-18ca-4b45-9e99-a53e7b7ee23c	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	bfbc15ea-b92b-4ae9-8657-17c10927cdff	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:14.535934-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6c007685-ac73-4782-8f3f-801844b6292f	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	bfbc15ea-b92b-4ae9-8657-17c10927cdff	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:14.668842-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
01402794-35fb-4295-a579-07bd70d065cc	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	bfbc15ea-b92b-4ae9-8657-17c10927cdff	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:14.797274-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
81979a13-d99c-484c-9a6b-4de16907db33	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	df17b496-a9fc-4cc7-b785-e6cbab6e3393	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:14.937123-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
dacfdccb-1c16-4995-bf1e-4ce47f6ef4e0	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	df17b496-a9fc-4cc7-b785-e6cbab6e3393	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:15.594149-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
888ee102-4973-47be-8046-4b1c1137cd65	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	df17b496-a9fc-4cc7-b785-e6cbab6e3393	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:15.721849-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
14ade23d-96a3-4b32-a7ac-5b8bfaffb723	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	09007542-2861-468d-ab6b-0dd7db77d50b	1905b547-fd4b-4cca-a182-9f2122594d58	e3567ff9-6ed1-4409-ac09-d325528cdc70	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:24:15.867583-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3ccea26c-4216-40e7-8b61-ac18e60d9bc6	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	1905b547-fd4b-4cca-a182-9f2122594d58	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:15.98887-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
65fdcfbc-bf92-4998-a9a4-07b8bcbbbf99	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	1905b547-fd4b-4cca-a182-9f2122594d58	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:16.116612-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3375cbb4-6ba8-418d-919a-2eb1c6c8b503	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	1905b547-fd4b-4cca-a182-9f2122594d58	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:16.244507-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f42dde7c-c885-4376-940b-3310758fdf9a	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	09007542-2861-468d-ab6b-0dd7db77d50b	1905b547-fd4b-4cca-a182-9f2122594d58	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:24:16.372462-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7a455ed6-22e5-48f7-8e3f-13a4a274ee43	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	1905b547-fd4b-4cca-a182-9f2122594d58	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:16.511307-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
57be8635-780b-4aeb-8002-75d528a5198a	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	1905b547-fd4b-4cca-a182-9f2122594d58	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:16.647094-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b7122f66-b42b-4ab9-871b-464a965747b4	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	1905b547-fd4b-4cca-a182-9f2122594d58	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:16.791269-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f6b9d26a-bbfc-43a8-be0a-6083d6baa5fc	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:16.92089-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2af9a75f-5b96-4bbb-809c-f8c5102307bd	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:17.576182-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
cc69a533-7916-4d01-ab3c-4f12c797a7af	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:17.709753-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
71212f20-3431-49e8-9e12-01f4ea41f51d	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:17.843551-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7d74da5a-d24d-4c74-80f4-f53b1b9ccda5	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:17.965231-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f83e15b5-835e-4739-a7f6-5322041cbd24	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	327c4400-3362-4f7d-bc06-7fbb70eb3a0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:18.090915-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9759ba5a-70c7-4ac2-9baf-324a11771f35	c8322762-40dd-4cce-944c-a51fb0fa88da	bd5acf6a-7e90-49af-8a61-a42276a6772f	bc5c98d8-86ec-4327-b9d9-365eaac3146e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:18.212733-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
52a3a373-2e33-4a87-8937-4809ac5d4ef5	c8322762-40dd-4cce-944c-a51fb0fa88da	bd5acf6a-7e90-49af-8a61-a42276a6772f	05d876a4-ded0-4c88-8062-df73e77b5356	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:18.8579-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
66157dfc-2761-46a4-8e90-4350efcc4d00	c8322762-40dd-4cce-944c-a51fb0fa88da	bd5acf6a-7e90-49af-8a61-a42276a6772f	1b75dcc4-d0c6-49ce-b9fa-0583bda3aa0c	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:18.99267-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
17ec7f78-ecdb-40ed-995b-2296f2e00238	c8322762-40dd-4cce-944c-a51fb0fa88da	bd5acf6a-7e90-49af-8a61-a42276a6772f	deff267c-a77b-4952-882c-f8e86f8d585e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:19.127956-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b4b7b7ae-faf9-4585-bbed-c67a604f80f6	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	4d996508-1506-496f-80a9-c8c672126a26	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:19.268983-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
67ac3a21-429d-480c-8456-9088fc65b201	c8322762-40dd-4cce-944c-a51fb0fa88da	bd5acf6a-7e90-49af-8a61-a42276a6772f	05d876a4-ded0-4c88-8062-df73e77b5356	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:19.399581-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
60ba8be2-fa40-4522-bfd1-5de50c36b364	c8322762-40dd-4cce-944c-a51fb0fa88da	bd5acf6a-7e90-49af-8a61-a42276a6772f	1b75dcc4-d0c6-49ce-b9fa-0583bda3aa0c	669bb230-dc3b-421d-8031-ed36fc6f52d7	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:19.529167-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f896bf25-bdbf-4866-b432-a2d1ea2babf3	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	b2b85ada-db7f-4ed3-9293-cb0a00b94ea6	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:19.675964-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
452205c1-388b-4e94-9b84-f925717539ad	a184096f-96fe-47c7-ba19-892a020ec5f1	bd5acf6a-7e90-49af-8a61-a42276a6772f	22040ff7-8fe6-4f40-9885-fc2c4570b813	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:20.314498-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b9a39b35-ab36-4c24-bb0a-d7f006bad113	a184096f-96fe-47c7-ba19-892a020ec5f1	bd5acf6a-7e90-49af-8a61-a42276a6772f	54caafb3-904d-4316-99bb-bb0ccac3629e	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:20.453577-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
123d5acb-d6cb-4eb3-a8b4-d13297d0f532	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	cae755ec-b380-43c7-96e0-68194cf8922e	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:20.614027-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9312fe6c-628b-4423-a0e9-0f191006f3fb	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	1d482a68-a347-4095-b690-6e1a48ba92b5	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:20.76499-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8587545f-9df0-4872-ab6e-883850c70036	a184096f-96fe-47c7-ba19-892a020ec5f1	bd5acf6a-7e90-49af-8a61-a42276a6772f	735f189f-8820-4b7c-b08c-a235270ee808	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:20.909557-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0d8a5bb8-9d8e-4203-831a-ef9cbc81be23	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:21.039433-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
55664a6c-2a81-4808-a818-ccfda55ca51c	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:21.67511-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2ece3a5f-6050-4eac-93f1-774f5de15855	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:21.808712-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4ba54c06-f0d5-48ed-ba13-e32bb6f65822	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:21.92934-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
45c0ceef-11a2-4a88-8f89-b907f9fcdc69	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:22.057072-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4fbbb6c2-6f23-4ba1-b69b-de598052f62e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:22.198048-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
bcc3bd0d-3482-4a90-a242-051e4d24a2bc	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:22.335026-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3afc04fe-f77d-49d9-bb72-befea04cd0d9	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:22.469141-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
408340ae-389b-4449-a6ef-2bdc7e6d9381	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:22.594613-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3641aa87-7634-4636-9615-7a4bfcfb2a36	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:22.729747-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4d1cf06f-5894-4c45-a3f4-4b2f7b41b5c9	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:22.848291-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fcb22f32-ccb9-4fe7-8106-b362de679d04	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:22.981851-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6f880790-2dca-4cb6-8a05-2a878875f651	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:23.101928-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7339f530-12d8-471b-84df-c68ed74af03c	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:23.225124-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
1f4d6275-08c5-4d81-9b77-94aa6a4ea79d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:23.37873-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
45c95821-f371-47d6-8b61-f03e2f92372e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:24.018203-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e1a10ee2-5fc9-4c15-aa69-47f2b1630f22	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:24.149983-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
34e53d5c-0c2e-43ff-94f9-4eec7ac65f7a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:24.274569-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
de34c5ea-e9e1-48ac-b711-62b90faa9564	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:24.413344-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
31419fca-721e-4a6c-9214-c805cdfd8413	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:24:24.544185-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6bbace54-97dd-42fb-a5d8-1692d11d0538	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:24:24.685163-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
93d29de9-21cf-42dd-bf5d-0298f9ba66c8	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:24.824004-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
edacd143-2001-4445-b50c-f0fcddbd65d6	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:24.947792-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
bcc2c3c7-86c1-4415-b596-8295f95fca84	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:25.083633-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3cff96a8-e78a-4923-b44f-d8fca9e282dc	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:25.21361-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9116ebfd-9100-4d5a-a6f6-ba4e13668ecf	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:25.319939-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
18435931-1cf6-4751-a50a-70a3b9d42657	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:25.436615-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d3c0d383-b05a-4551-99de-d9611a06d4bb	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:25.555199-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
38f5d49a-b22b-4534-8c84-f4c762309c7e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:25.688881-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
cc99b028-2154-4ef3-ab3c-f5e6e6d44b45	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:25.815929-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3f513380-87b8-41c3-99e2-59688b0a8f9c	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:25.953282-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b4216c79-debc-40ff-a9c6-e0ab26c7ca78	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:26.09116-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b7fd211c-61a5-4ab2-9f14-560d130ab0b4	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:26.23555-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c477dda8-0485-47a3-9369-a172817257d9	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:26.368816-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
67be0dcf-a0b1-4e08-a303-122b846c580c	a184096f-96fe-47c7-ba19-892a020ec5f1	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:26.500466-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ef3a4a90-c90a-44b2-8a2c-3196cf4d7834	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:26.625922-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
6c758e94-d189-4e6b-ada6-6f2128337c2f	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	e61cc981-59fa-4c7e-a0e6-1a12d0796640	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:26.761994-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fdbf680d-06e7-4d9a-b663-f07c852dd48d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:26.905431-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
da46f294-bf21-4642-99bf-f6c97a101c76	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:27.525463-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b3d3ac3e-d3ed-417b-a5d1-2d91ff079aec	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:27.665926-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d6e99d06-9eca-42e8-948d-f3b4c579fee8	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:27.804844-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
40cfdcb1-b151-40e6-b74b-96dedd8cbf7c	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:27.945285-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d104273d-000e-4858-b7d6-fd900268bf8b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:28.090565-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
062e7bc6-8691-4a8c-ac4e-fb1375bc4e25	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	f58c3ce5-491f-4e7b-9272-4a309114c2cf	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:28.236405-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fdd7c708-6efb-483f-b1d5-a0043b504748	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:28.375347-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
dd658b34-3a91-487a-96fa-07344303e3aa	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:29.040951-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9a22a5b8-c0ad-4c8f-8225-49d1ab17e302	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:29.187074-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8797d2fe-1854-41d2-998e-ac90cdb14d54	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:29.345429-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
badc9fcf-707c-4414-a25d-473c1e91cb26	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:29.502853-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
313c728b-f62c-4343-998c-69e7251d41a2	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:29.666683-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9ec3ebd6-483d-4a1a-9c09-3a7efc9f6227	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:29.819923-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
89c72d1d-6d8e-4e32-96f0-5feaee8ec841	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:29.965114-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7df6e1fd-86b4-4d71-80d6-b614029c818b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:30.122076-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
34bdfe7f-65ac-48c0-8ca0-66f7647c0e36	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:30.281789-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
701c0ef0-82ec-4b8e-ad65-aeb7cbd08ed3	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:30.436712-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f46813fb-cbfd-4ca6-8bbb-da3a34a76da0	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:30.578604-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
810a4cb2-e918-4943-afb6-5f882958529f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:30.725802-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a94365aa-fe6b-4e1c-a4f3-8203df61189e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	4d598b2c-d08f-49c0-b3e4-87967843616c	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:30.901885-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
de29a11c-0f0f-4ebc-bc93-b0fdb3f90513	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:31.057175-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f180ea39-b924-4e22-a9a3-d8d9b1eee0ad	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:24:31.746054-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7be4a86d-b619-43f7-8d6f-a8d6f4fa2725	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:31.901319-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
74e61fd6-3be9-4983-ab29-3f542eccae5c	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:24:32.054617-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
92c1841c-1141-43b6-98fb-70a2f340519b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:24:32.209096-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3b41ad04-9a15-4280-a266-cbb2dd3a1750	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:24:32.35416-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8ccde2a5-0a71-48cd-b45f-10c8f491a03e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:24:32.51324-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
05bf9bc8-c2a2-4745-9c1d-721b6fb6e61a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:24:32.688209-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
1cbb77c7-8a15-47e4-a198-eee622dc0446	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	e3567ff9-6ed1-4409-ac09-d325528cdc70	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:32.834852-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
32f7b643-e6b3-4bc9-82dd-397076f1e28f	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	e3567ff9-6ed1-4409-ac09-d325528cdc70	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:24:32.989444-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
672e5da6-6844-45ac-bcf2-e74d65983643	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	e3567ff9-6ed1-4409-ac09-d325528cdc70	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:33.136947-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a2887698-29da-49b1-bcba-82e88dd9297f	a7e13742-0ab6-467e-abfb-54a93adbb803	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	e3567ff9-6ed1-4409-ac09-d325528cdc70	c4a5368c-d643-4007-88da-6e5da7351a2b	2025-10-10 18:24:33.29339-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
93f6cfcf-6df8-4a41-8d17-ed06cffa92aa	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	778c75fc-b7ac-4e94-81f1-30e42f0763ed	634dfd62-debc-4036-b826-327959dec881	2025-10-10 18:24:33.444999-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a8e9f30d-1ddd-479a-ad33-aa6c0be4ef1d	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	778c75fc-b7ac-4e94-81f1-30e42f0763ed	84d3af3f-896d-45d6-8bc6-097c7d2b3044	2025-10-10 18:24:33.590744-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
697d05e6-2422-481f-b241-39fa5eaf3707	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	778c75fc-b7ac-4e94-81f1-30e42f0763ed	d3d9c5a3-7aa5-45d5-88fd-6677e39094a1	2025-10-10 18:24:33.752108-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ba1183d7-3475-4d23-9231-c8196e63585f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:24:33.905196-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0f7e7abc-b09a-4bc3-b588-bc10dbb67fe4	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:24:34.573151-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
87bccbf8-614e-4a5f-9853-d59e9e8b5222	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:24:34.728003-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f8b8cfd9-73a6-4fd7-9a2d-807d0663bfab	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:24:34.887824-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f74ed1c0-e6a2-4508-940f-e8755becc9f0	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:35.033964-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b4db3919-615c-4a38-88c5-98b3d860a670	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:35.701367-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a0da0a7d-2dac-427f-9dc3-56919c5413d2	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:35.856766-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
40672d91-a7a7-4811-8ef4-fdc02f506e9d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:35.989389-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e61ddb8e-52ca-43b4-9ced-8df0efdbf9f6	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:36.136986-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8d96a108-96d2-4fbc-aed2-cc3c78a7b741	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:24:36.269188-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
f5b01127-b315-422a-bd3b-ed506ac8d5f2	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:24:36.405801-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
4e3a63e2-3490-4c1b-8f08-c0705f94ef9a	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:36.538793-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e8323462-912d-4397-9aa7-e41e6c7d1dac	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	e3567ff9-6ed1-4409-ac09-d325528cdc70	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:36.681585-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7eeace61-a00b-4e5e-a0f8-2901bae5e0d4	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:36.806418-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
61ed03f8-9725-40c2-bcaf-371e572e8ac4	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:36.935723-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
7939e9a7-3c9b-4f25-b063-57af6d98cf10	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:37.071677-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
cfe86afb-0b82-43ce-ae6e-7e4bc053dcea	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	e7756e7b-0d1d-4156-ab60-bce3a4007ba9	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:37.20474-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e06858c1-4d43-436c-acde-ec6907e7ab18	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:37.335298-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9fc8d24d-5cb7-4842-a361-9e39a5705dd6	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:37.979081-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e165a0f9-6bf4-4005-82e9-65c8b23b092d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:24:38.116446-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a800b2ec-5785-4f8b-8ff6-c606a53fad1f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	43de5530-61aa-49f0-8efb-d6c76d6ea294	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:24:38.261402-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
655d64e1-22ed-44b2-9a01-f2728c7b1f84	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:38.405472-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
217b60f6-8c85-4501-9888-e1f854a7f18b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:38.534947-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
12664e80-6f1a-4bb3-b2f4-29b629f4aafa	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:38.670482-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
c486189d-bf4a-42b5-be31-07d841b9824b	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:38.809842-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
da93a667-93e3-4745-92ee-c303452fcfcd	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:38.943068-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
9777399b-8a6b-4c9b-829c-96a7d687e3cc	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:24:39.082693-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
27432094-a85e-4c1f-bc4f-5419f6c9125a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	bd5acf6a-7e90-49af-8a61-a42276a6772f	b2370664-56bd-4a9a-b37c-8124a855f6ac	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:24:39.227169-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2ef7326a-4ff3-47be-a303-a9c355dcebc7	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	51616e82-2b9e-417b-b213-84280a617f47	2025-10-10 18:24:39.373934-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5681b265-db79-43fb-bd13-f1fb6bf419d9	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	037d8feb-29bd-4da2-a3ad-8ce7ce9a61ee	2025-10-10 18:24:40.028041-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
98f640b9-c7f7-4a77-a5f2-e0bc1288bfa6	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	52b97915-ba61-4604-8e7f-556627573f87	2025-10-10 18:24:40.194474-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3e1fa1d2-b7e8-4a10-bb91-ebe9882a0df6	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	b1f272d1-f36c-4ecc-b5ff-00c47b593375	2025-10-10 18:24:40.338914-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d4f1980c-574c-48ce-b2c9-989c7bbb1def	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	3d19fab4-b7fd-4819-a70a-8f22d83b62b7	2025-10-10 18:24:40.484495-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
8238c98e-4bf8-4991-8769-403ec061d84a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	df2c7532-e7c6-4881-8fe7-2e0679549c20	2025-10-10 18:24:40.624501-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5f7eb36e-7612-41b9-b143-4700f95450d0	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:40.773958-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5ca0e855-371c-4167-b824-3de1a93ef219	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:40.911395-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a24dddb3-0703-48c5-a1a1-d61c3f32ce86	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:41.560247-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
fed23641-1ee6-42b4-a453-9d4e78cb8b81	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:41.693825-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
89ceb766-ed91-4f81-8281-a1f5d12272df	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	d1947aad-3932-47e2-84d3-d9c379a4d3b2	2025-10-10 18:24:41.839995-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
65b9db8c-f38f-4564-ad71-2c43bd119d0a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	b70d948a-2b27-4f41-831d-c2f504d2df91	2025-10-10 18:24:41.985996-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d91143ab-8b21-4a31-b4a4-6b1a7beee251	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8567b860-540a-420a-8f7d-aca6c3e13efa	2025-10-10 18:24:42.131102-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ffd9214b-c386-4896-94f9-3728d57b9dd7	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	ac4e4383-37d3-4ad0-8f1e-08d3af713665	8f36b81f-546f-4443-9afe-45d07ee96662	2025-10-10 18:24:42.277526-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
81ed3b38-4354-4174-84af-7a6bf32354b8	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	82223ebf-ab42-4121-a766-705212f4cbdc	485a50cd-786c-4521-89b9-2f9d4b58d8d9	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:42.449851-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
457c36ef-a9e5-44bc-84ec-b503da05d13a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	82223ebf-ab42-4121-a766-705212f4cbdc	485a50cd-786c-4521-89b9-2f9d4b58d8d9	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:42.585389-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
1860ed49-ffb5-4324-afe2-af8aadbd5e6a	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	82223ebf-ab42-4121-a766-705212f4cbdc	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:42.714252-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
07689a05-1262-4b5b-8747-45f2832c4133	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	82223ebf-ab42-4121-a766-705212f4cbdc	485a50cd-786c-4521-89b9-2f9d4b58d8d9	e1c7dd13-15db-47ed-80fe-7d91eda0e136	2025-10-10 18:24:42.859099-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b75c76c9-159a-4d16-bc1d-1f9c4b9594a5	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	82223ebf-ab42-4121-a766-705212f4cbdc	485a50cd-786c-4521-89b9-2f9d4b58d8d9	01167bfe-013a-4a90-97bd-77315bdef68d	2025-10-10 18:24:42.999104-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
54c2a9ba-3077-49c0-8a24-a8284bdb5733	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	82223ebf-ab42-4121-a766-705212f4cbdc	485a50cd-786c-4521-89b9-2f9d4b58d8d9	6ccdbbff-f974-4d28-81ab-47fa4d03b95c	2025-10-10 18:24:43.135291-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0bea3617-6725-4f5d-8deb-e71d52a99b76	c8322762-40dd-4cce-944c-a51fb0fa88da	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	e3567ff9-6ed1-4409-ac09-d325528cdc70	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:43.283386-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
0ffb56a4-43c4-4a42-94e5-d70286b4dd7b	ae5fa357-e612-440e-a179-8f40f94c80ef	e85a77a3-135e-4138-8146-61b7db2f0811	2d609890-71eb-40cb-ad27-f7b7291416a9	e3567ff9-6ed1-4409-ac09-d325528cdc70	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:43.428813-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e51967ee-9714-47e5-ad34-c6503a83de6e	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	ac4e4383-37d3-4ad0-8f1e-08d3af713665	ac51af82-47ef-4b0e-aa34-fdd5e3f97cb4	2025-10-10 18:24:43.567992-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
d88560a3-ea0a-48df-bf2a-10a1a397be5f	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	ac4e4383-37d3-4ad0-8f1e-08d3af713665	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:44.200744-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
a511385c-0e46-4035-b82b-4f4a722afd7d	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	ac4e4383-37d3-4ad0-8f1e-08d3af713665	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:44.346271-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
83ea898b-4733-425a-94d0-58d0517fb82e	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	e85a77a3-135e-4138-8146-61b7db2f0811	3f602676-c9c1-43b9-b776-e37839287e8e	669bb230-dc3b-421d-8031-ed36fc6f52d7	8c5f05c0-519b-4a81-bf2d-89c688cfc211	2025-10-10 18:24:44.500963-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
582f5c24-65be-427b-ac2e-4b16c9ee5b48	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:44.644931-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
65ac0d17-96a5-4160-bf3b-114530b82111	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	33a80d19-1286-47cf-a02b-9a8066975ac7	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:45.294587-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
2fe293bd-aef9-4df5-b9af-c541f10d5ad0	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	e59c6f29-7b46-4a28-bc90-1c0fd317e7db	2025-10-10 18:24:45.432096-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e5f07d40-6838-49e9-a5a3-a85f338608e7	b6549dbf-75b5-4ddf-85d2-1600a6c67cc8	09007542-2861-468d-ab6b-0dd7db77d50b	ac6c030a-b183-4732-8bb3-d84598debcd5	7ee6d015-2a27-4d2d-ae49-a96f67977c2d	4e051d5a-943e-4fe3-9f94-1f9f0fd5c1f6	2025-10-10 18:24:45.577321-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
3637fb5a-df83-488d-9b3f-1f3574ec89fa	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	6ab7dc01-0a4e-4162-a9fb-408c815135d1	778c75fc-b7ac-4e94-81f1-30e42f0763ed	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:45.750782-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
b221ce38-a22d-47dc-8ad3-cf134af1608b	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	6ab7dc01-0a4e-4162-a9fb-408c815135d1	778c75fc-b7ac-4e94-81f1-30e42f0763ed	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:45.884817-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
ed484d78-7c48-4b79-9960-1ac3cb228462	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	6ab7dc01-0a4e-4162-a9fb-408c815135d1	778c75fc-b7ac-4e94-81f1-30e42f0763ed	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:46.034916-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
daba2d79-9991-4d29-a6d8-5ecec5524241	9d54c08e-ebc0-4945-87ba-a96b357fc8e4	09007542-2861-468d-ab6b-0dd7db77d50b	6ab7dc01-0a4e-4162-a9fb-408c815135d1	778c75fc-b7ac-4e94-81f1-30e42f0763ed	242a4218-0497-4858-8794-ab337d875e53	2025-10-10 18:24:46.180741-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
e394a74f-b153-49c1-9c43-e438014a62c0	c8322762-40dd-4cce-944c-a51fb0fa88da	09007542-2861-468d-ab6b-0dd7db77d50b	6ab7dc01-0a4e-4162-a9fb-408c815135d1	669bb230-dc3b-421d-8031-ed36fc6f52d7	5e87d290-1647-46cb-a054-c7cce0c7a117	2025-10-10 18:24:46.317191-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
5cb79a1e-0411-4674-aa9f-e7591e591c6e	a184096f-96fe-47c7-ba19-892a020ec5f1	09007542-2861-468d-ab6b-0dd7db77d50b	6ab7dc01-0a4e-4162-a9fb-408c815135d1	669bb230-dc3b-421d-8031-ed36fc6f52d7	52a67838-d37f-4715-8611-d8f92f2da652	2025-10-10 18:24:46.465819-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
33ec9930-eee9-4a8c-8c2e-3cd3a2d5ceb9	ae5fa357-e612-440e-a179-8f40f94c80ef	09007542-2861-468d-ab6b-0dd7db77d50b	6ab7dc01-0a4e-4162-a9fb-408c815135d1	669bb230-dc3b-421d-8031-ed36fc6f52d7	83ba7b82-ba7a-456d-8f86-8f4fbbc43bc8	2025-10-10 18:24:46.590494-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	\N	\N	\N
\.


--
-- TOC entry 5455 (class 0 OID 19942)
-- Dependencies: 241
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, school_id, name, code, description, status, created_at, "AreaId", created_by, updated_by, updated_at) FROM stdin;
2d609890-71eb-40cb-ad27-f7b7291416a9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	GEOGRAFÍA	\N	\N	t	2025-10-10 18:23:21.859813-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:21.859813-05
7e8b45ff-6eb9-45e1-948d-b4d531fdbd0b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	HISTORIA DE PANAMÁ	\N	\N	t	2025-10-10 18:23:23.967294-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:23.967294-05
75b5394f-2870-4a1b-ac2b-f7a908f985d5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	HISTORIA DE LAS RELACIONES ENTRE PANAMÁ Y LOS ESTADOS UNIDOS DE AMÉRICA	\N	\N	t	2025-10-10 18:23:24.186341-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.186341-05
33a80d19-1286-47cf-a02b-9a8066975ac7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	CIENCIAS NATURALES	\N	\N	t	2025-10-10 18:23:24.711868-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:24.711868-05
ac6c030a-b183-4732-8bb3-d84598debcd5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	LAB. DE CIENCIAS NAT.	\N	\N	t	2025-10-10 18:23:26.086636-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:26.086636-05
df17b496-a9fc-4cc7-b785-e6cbab6e3393	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	CIENCIAS NATURALES INTEGRALES	\N	\N	t	2025-10-10 18:23:26.443372-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:26.443372-05
2bb4abb8-3d03-4b78-9cc2-0a4d2e3f0970	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	CONSEJERÍA	\N	\N	t	2025-10-10 18:23:27.214438-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:27.214438-05
e7756e7b-0d1d-4156-ab60-bce3a4007ba9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	EDUCACIÓN FÍSICA	\N	\N	t	2025-10-10 18:23:28.035537-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:28.035537-05
b2370664-56bd-4a9a-b37c-8124a855f6ac	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TECNOLOGÍA FAM-DES	\N	\N	t	2025-10-10 18:23:30.998745-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:30.998745-05
e5d4e482-571e-47a9-b984-fa4454d57bb6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	MÚSICA	\N	\N	t	2025-10-10 18:23:33.641421-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:33.641421-05
327c4400-3362-4f7d-bc06-7fbb70eb3a0c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	ESPAÑOL	\N	\N	t	2025-10-10 18:23:35.892181-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:35.892181-05
5302c538-2dd6-45bf-bfd9-997f248b2a7f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	MECANOGRAFÍA	\N	\N	t	2025-10-10 18:23:37.287786-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:37.287786-05
43de5530-61aa-49f0-8efb-d6c76d6ea294	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	RELIGIÓN, MORAL Y VALORES	\N	\N	t	2025-10-10 18:23:40.188518-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:40.188518-05
f58c3ce5-491f-4e7b-9272-4a309114c2cf	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	MATEMÁTICAS	\N	\N	t	2025-10-10 18:23:41.723395-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:41.723395-05
3f602676-c9c1-43b9-b776-e37839287e8e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	INGLÉS	\N	\N	t	2025-10-10 18:23:46.514356-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:46.514356-05
8a5781be-27dc-4569-9858-006b1c7b1f6c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	GEOGRAFÍA DE PANAMÁ	\N	\N	t	2025-10-10 18:23:50.906859-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:50.906859-05
54caafb3-904d-4316-99bb-bb0ccac3629e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TÉC INFO	\N	\N	t	2025-10-10 18:23:51.680137-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:51.680137-05
42730a69-7bb1-4b86-99d7-d086b3d66808	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TIFYM	\N	\N	t	2025-10-10 18:23:52.343129-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:52.343129-05
1b75dcc4-d0c6-49ce-b9fa-0583bda3aa0c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TALLER IV	\N	\N	t	2025-10-10 18:23:52.493586-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:52.493586-05
deff267c-a77b-4952-882c-f8e86f8d585e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TALLER V	\N	\N	t	2025-10-10 18:23:52.650107-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:52.650107-05
f30ac228-20b1-4dcb-b982-0e0b8f55c8b4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	DIBUJO I	\N	\N	t	2025-10-10 18:23:59.851955-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:23:59.851955-05
22040ff7-8fe6-4f40-9885-fc2c4570b813	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TALLER I (FUNDAMENTOS DE MEDICIONES Y SEGURIDAD INDUSTRIAL)	\N	\N	t	2025-10-10 18:24:00.531406-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:00.531406-05
2d050b7e-8670-43ae-a7f0-f9e84835673b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	PROYECTO Y PRESUPUESTO	\N	\N	t	2025-10-10 18:24:01.941237-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:01.941237-05
1c195c3b-348a-4fc5-b595-3ce7de76f6c9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TEC. PRACT. TALLER	\N	\N	t	2025-10-10 18:24:02.194647-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:02.194647-05
357d4e77-ac7f-4811-980e-7f36623435a4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TECNOLOGÍA DE LA INFORMACIÓN	\N	\N	t	2025-10-10 18:24:09.199996-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:09.199996-05
05d876a4-ded0-4c88-8062-df73e77b5356	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TALLER III	\N	\N	t	2025-10-10 18:24:09.853528-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:09.853528-05
4d996508-1506-496f-80a9-c8c672126a26	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	GESTIÓN EMPRESARRIAL	\N	\N	t	2025-10-10 18:24:10.004777-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:10.004777-05
bc5c98d8-86ec-4327-b9d9-365eaac3146e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TALLER II	\N	\N	t	2025-10-10 18:24:10.141799-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:10.141799-05
10ecd567-e3ab-41db-b2c6-5bf8f4cbf849	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	ARTES INDUSTRIALES	\N	\N	t	2025-10-10 18:24:10.560789-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:10.560789-05
4d598b2c-d08f-49c0-b3e4-87967843616c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	EXPRESIONES ARTÍSTICAS	\N	\N	t	2025-10-10 18:24:12.889959-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:12.889959-05
bfbc15ea-b92b-4ae9-8657-17c10927cdff	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	BELLAS ARTES	\N	\N	t	2025-10-10 18:24:14.482027-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:14.482027-05
1905b547-fd4b-4cca-a182-9f2122594d58	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	FÍSICA	\N	\N	t	2025-10-10 18:24:15.82071-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:15.82071-05
b2b85ada-db7f-4ed3-9293-cb0a00b94ea6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	DIBUJO I (LINEAL)	\N	\N	t	2025-10-10 18:24:19.622875-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:19.622875-05
cae755ec-b380-43c7-96e0-68194cf8922e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	DIBUJO II	\N	\N	t	2025-10-10 18:24:20.560313-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:20.560313-05
1d482a68-a347-4095-b690-6e1a48ba92b5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	LEGISLACIÓN DE LA CONSTRUCCIÓN	\N	\N	t	2025-10-10 18:24:20.716742-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:20.716742-05
735f189f-8820-4b7c-b08c-a235270ee808	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	TALLER I Y II PRACT .P	\N	\N	t	2025-10-10 18:24:20.862851-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:20.862851-05
e61cc981-59fa-4c7e-a0e6-1a12d0796640	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	ORIENTACIÓN	\N	\N	t	2025-10-10 18:24:23.328872-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:23.328872-05
82223ebf-ab42-4121-a766-705212f4cbdc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	CÍVICA	\N	\N	t	2025-10-10 18:24:42.391945-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:42.391945-05
6ab7dc01-0a4e-4162-a9fb-408c815135d1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	QUÍMICA	\N	\N	t	2025-10-10 18:24:45.693229-05	\N	21e66209-995a-4182-98e9-33d2ab635b48	21e66209-995a-4182-98e9-33d2ab635b48	2025-10-10 18:24:45.693229-05
\.


--
-- TOC entry 5456 (class 0 OID 19952)
-- Dependencies: 242
-- Data for Name: teacher_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_assignments (id, teacher_id, subject_assignment_id, created_at, created_by, updated_at, updated_by) FROM stdin;
7af1e84b-dc64-4a77-b897-adcb1df9b47a	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	a257f5db-422b-4948-be3e-f8f08be474b0	2025-10-10 18:23:23.647247-05	\N	\N	\N
7844e346-853d-4df8-a04d-38ea174157fe	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	4e27b0ec-5b4c-42ea-a236-c66aeec95cd4	2025-10-10 18:23:23.904645-05	\N	\N	\N
0832169c-2941-46b2-a946-5a343aada79c	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	56037be1-5c57-47aa-be75-25d3d6e358a1	2025-10-10 18:23:24.114706-05	\N	\N	\N
0eed9a23-5209-49f8-a1fd-3b80523bacbd	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	bfacb240-b8f0-4000-806c-00cda2d3000c	2025-10-10 18:23:24.318099-05	\N	\N	\N
84b92fdf-bc33-4619-9adb-0939bbb7dfd8	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	13cf27a8-4974-4190-a18c-ee578ce58966	2025-10-10 18:23:24.461686-05	\N	\N	\N
6bc22065-c97f-45ac-98f2-bff4fe483d57	37ff9dbc-e400-4e6f-a6da-63bfe88ff602	98546205-cfbd-4e11-a00b-2e6888d2bcd1	2025-10-10 18:23:24.62681-05	\N	\N	\N
1c95c9cd-95ad-4fcf-a1fb-bc4163cfc08f	199a1eb3-9a34-44be-bb68-9d3a78028d90	e25edb94-8480-4909-8e5e-1ad8e41aa327	2025-10-10 18:23:25.441527-05	\N	\N	\N
3dc8cd8e-b17c-46cf-8104-8e53262cd2e8	199a1eb3-9a34-44be-bb68-9d3a78028d90	82bb2423-3440-418c-ae5b-79e28cad41c5	2025-10-10 18:23:25.60165-05	\N	\N	\N
1ef6ea14-5b45-4c7f-9d25-b615ca1137cd	199a1eb3-9a34-44be-bb68-9d3a78028d90	7c28b1b9-3061-4419-840a-08d075adb76f	2025-10-10 18:23:26.19631-05	\N	\N	\N
d8a70f1c-5d86-4426-bdc1-785728da8888	199a1eb3-9a34-44be-bb68-9d3a78028d90	01268eac-832c-4bcb-a873-cf34a9fde688	2025-10-10 18:23:26.396658-05	\N	\N	\N
28e63892-f822-4ac8-98c0-5a7911925d79	199a1eb3-9a34-44be-bb68-9d3a78028d90	b1d3e427-ef69-4537-85bf-a39b6aa4d0d6	2025-10-10 18:23:26.560619-05	\N	\N	\N
3038315f-bc99-4976-8fd0-66aee9e9faf5	199a1eb3-9a34-44be-bb68-9d3a78028d90	856971bb-2c95-4bee-96fb-f700efd7f042	2025-10-10 18:23:26.732696-05	\N	\N	\N
4014c694-71c4-4fea-9607-9287b646fe57	199a1eb3-9a34-44be-bb68-9d3a78028d90	947de356-c0de-4a61-b30e-74826655145e	2025-10-10 18:23:26.934953-05	\N	\N	\N
65a67fc7-beb2-4d5d-bd14-edfab8712482	199a1eb3-9a34-44be-bb68-9d3a78028d90	5e7e9d07-41ee-4467-99cf-22bf7a78b1d1	2025-10-10 18:23:27.158876-05	\N	\N	\N
5944c36c-4b07-470f-a5ea-76a4ae9fc21f	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	fec88b11-2419-4a98-babe-91a80007c63c	2025-10-10 18:23:27.978296-05	\N	\N	\N
75235da2-477b-46f1-90fa-39ee5dd069a2	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	d3a91519-5f92-4fe3-a8cf-5aca756d5d5d	2025-10-10 18:23:28.180656-05	\N	\N	\N
94b7613f-582c-419c-99fa-a0e8952882da	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	bca4a824-8112-47d0-8b0f-d79fb48b1367	2025-10-10 18:23:28.356452-05	\N	\N	\N
772c1220-7caf-483a-bb57-dfbaa28f9410	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	cf49b9ad-b8a0-488d-8b8a-0b22596d5d50	2025-10-10 18:23:28.54654-05	\N	\N	\N
a425dd0e-293c-4a88-aee9-bd76aa738f0a	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	9a904b71-50bd-473a-b1ae-14e852988194	2025-10-10 18:23:28.801612-05	\N	\N	\N
6764582a-93e7-44a0-b92f-1bd4ba41666d	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	5422745b-045f-4c69-9ec0-397cd060b4e9	2025-10-10 18:23:29.056561-05	\N	\N	\N
c9130b99-ce95-4f7c-bb8b-1611a532050a	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	6a46c7d0-912d-4154-9190-9d7d0917d362	2025-10-10 18:23:29.278806-05	\N	\N	\N
17c68ca6-a2ee-4cd7-9752-30ff956bce6f	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	0e3eadb3-b382-40a4-8228-71038d15ea35	2025-10-10 18:23:29.535684-05	\N	\N	\N
8ccae82d-9664-4dd2-a442-14a4ae44d47f	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	c618e66c-fccf-4100-8609-b9f2a0f841ae	2025-10-10 18:23:29.795627-05	\N	\N	\N
01b5eff0-faf5-4e57-9248-d6f17e60999a	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	83f60b9d-2a76-4a2c-8c7c-d2f4881a8244	2025-10-10 18:23:29.991344-05	\N	\N	\N
ce38ad4e-52e8-432b-86c2-1f41fa9c4c08	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	16acca24-084d-4b92-957a-879c4317c47b	2025-10-10 18:23:30.166892-05	\N	\N	\N
5e113499-3921-49c2-9f10-0db8595b7eba	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	039e1cf1-1f2e-4086-9dda-a3605f102d22	2025-10-10 18:23:30.346313-05	\N	\N	\N
b6cef3a7-0841-45c6-81da-96e3ac5bd820	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	35a79053-7525-47f0-b5e0-9cad51b49137	2025-10-10 18:23:30.513792-05	\N	\N	\N
09862c15-5802-4373-ac48-86bac3c10474	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	4842c1d6-aaad-4803-8a51-93176b774469	2025-10-10 18:23:30.689597-05	\N	\N	\N
28f7a190-41ed-42e9-8583-9039d2500b52	9311ba6b-0680-4f56-9e4b-801a4f3c99ca	c7f4ca7d-ffc3-4a2a-b145-0d5eaf77e434	2025-10-10 18:23:30.895041-05	\N	\N	\N
7160a3fb-b10f-493d-b476-0534a5cabaa7	c5bdb8d0-9109-48b2-837b-96e015293dce	61b5c91d-62f9-4c87-a6e2-ef5fc9594381	2025-10-10 18:23:31.706423-05	\N	\N	\N
3890b7f0-aa55-464a-95ec-1393511fcbd1	c5bdb8d0-9109-48b2-837b-96e015293dce	75462afe-10cb-459e-8f9b-3073848c1458	2025-10-10 18:23:31.860856-05	\N	\N	\N
ca5dac63-c612-4d75-82f8-600788af592f	c5bdb8d0-9109-48b2-837b-96e015293dce	0e460aa3-a8da-4241-bd85-2b08cbedc000	2025-10-10 18:23:32.020305-05	\N	\N	\N
6ccdae8f-d144-4dec-9d37-141a7e07ef46	c5bdb8d0-9109-48b2-837b-96e015293dce	9a1dc82d-55cc-490f-97af-47e7f6d96012	2025-10-10 18:23:32.170774-05	\N	\N	\N
3cf0288c-028c-4bcf-b43e-70c227835a37	c5bdb8d0-9109-48b2-837b-96e015293dce	96e76265-d2be-4e8f-8e75-80edf6a0de42	2025-10-10 18:23:32.322906-05	\N	\N	\N
b0c11562-0183-4dc9-9474-1dc520bf80cb	c5bdb8d0-9109-48b2-837b-96e015293dce	f4794b16-f8be-4a9a-bcfa-9d9b8cd409a0	2025-10-10 18:23:32.472128-05	\N	\N	\N
f717968c-f3c0-4b27-83fb-4514aaa9f917	c5bdb8d0-9109-48b2-837b-96e015293dce	8ad1023a-6249-4ca4-8054-53f3dff3c8c0	2025-10-10 18:23:32.612798-05	\N	\N	\N
290b2b10-080a-4f15-90e8-491adbee3c92	c5bdb8d0-9109-48b2-837b-96e015293dce	e8652508-a2ef-4c25-9ba6-5026282b1849	2025-10-10 18:23:32.783935-05	\N	\N	\N
ba0ae37e-40ee-407e-9032-e7592d523a1a	c5bdb8d0-9109-48b2-837b-96e015293dce	b9f648cd-a2df-4530-82e4-02c86d771d0b	2025-10-10 18:23:32.953876-05	\N	\N	\N
3d0aff74-54bb-45e0-a002-5211f3d30566	c5bdb8d0-9109-48b2-837b-96e015293dce	457f440e-8396-4b3e-8aeb-12f407d742c7	2025-10-10 18:23:33.107592-05	\N	\N	\N
342a8d26-3422-42c8-8d65-46a623c9ede3	c5bdb8d0-9109-48b2-837b-96e015293dce	43c3e2e9-6f99-4742-8b4c-bd98384ba183	2025-10-10 18:23:33.26412-05	\N	\N	\N
3f2d5495-f58e-43d8-bded-3a7c17e737f2	c5bdb8d0-9109-48b2-837b-96e015293dce	600c1fec-1ddf-442e-bac2-c687cf328a64	2025-10-10 18:23:33.40552-05	\N	\N	\N
2c0b0a89-8d7d-41f3-a528-1a77ff705770	c5bdb8d0-9109-48b2-837b-96e015293dce	5e11f2a7-25a6-48a6-86a0-6c8291fb2f7e	2025-10-10 18:23:33.56964-05	\N	\N	\N
ea851780-fefd-4fa1-88dc-26bea4469dec	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	47be5770-da3f-473b-9276-998e74c7f7d1	2025-10-10 18:23:34.364215-05	\N	\N	\N
873ef08d-d0fd-4568-a512-5026ef01d2df	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	c5c5f0cb-dc9b-48e2-b370-e53994eff2aa	2025-10-10 18:23:34.509859-05	\N	\N	\N
82176b80-5087-4716-bf7c-65265092cb25	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	0e8ae7e8-a7c7-4bdb-891e-c3593c096b3b	2025-10-10 18:23:34.660434-05	\N	\N	\N
16022d77-e5ad-46f7-911c-cdf9b2faf850	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	51e83bb3-cde0-407f-8b8f-04ebe39ba534	2025-10-10 18:23:34.804451-05	\N	\N	\N
709508a4-fabf-446b-8019-aaf24e090ff2	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	c5b62fc8-98dc-4fb5-b5b9-9405506f70b8	2025-10-10 18:23:34.937567-05	\N	\N	\N
32a439b9-7e01-4456-aa78-a41254a8c15a	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	7091673b-1d13-4f02-b536-c7d631d96c65	2025-10-10 18:23:35.079812-05	\N	\N	\N
eb6ca93f-cbda-4910-b29c-9754d1f2ac80	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	564bae5f-cbc6-417f-8f0c-ceef7bdba135	2025-10-10 18:23:35.203941-05	\N	\N	\N
03b8e0b0-bf4e-4326-9918-6f3ec3e40e82	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	86c86954-90f8-493e-926e-1f7fea982735	2025-10-10 18:23:35.32549-05	\N	\N	\N
6af065e2-fc40-4ded-8e9b-24a0a43d46e8	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	d415bba8-ed40-4990-b32e-4323dc1007cb	2025-10-10 18:23:35.453125-05	\N	\N	\N
ee012fa8-5ec1-4077-a2c9-530b5fd6edbf	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	f4d42493-a3a1-416e-87f1-13442c0d8247	2025-10-10 18:23:35.584698-05	\N	\N	\N
6c1416a7-d0d2-4376-973f-9a08ff7f279f	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	8ffc16f3-d77c-428b-9224-6711c8717d14	2025-10-10 18:23:35.721713-05	\N	\N	\N
7cc2bd87-2081-4813-bc34-be5df2547b03	e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	886b7a78-3ee4-496c-ba8e-9c2d76bf1fe6	2025-10-10 18:23:35.845007-05	\N	\N	\N
523b236f-08ee-430b-902e-9821632d47fe	ac815aa5-9166-4c35-ab28-1e35a5cdccd6	53cd803a-45bc-49ed-bf2c-49410fe85e2a	2025-10-10 18:23:36.600173-05	\N	\N	\N
4c695603-9605-47e8-bb66-6a227c00a65a	ac815aa5-9166-4c35-ab28-1e35a5cdccd6	16b92d30-0f31-4034-abab-98ad67016a54	2025-10-10 18:23:36.732586-05	\N	\N	\N
b3c9863d-d571-41db-bb17-d46bc72224b1	ac815aa5-9166-4c35-ab28-1e35a5cdccd6	53c768d0-acd9-435a-9492-7916d204cfd3	2025-10-10 18:23:36.85878-05	\N	\N	\N
2a9eb699-de36-4105-91c8-a72d3c54f8b1	ac815aa5-9166-4c35-ab28-1e35a5cdccd6	78e01333-8306-47f3-bc3d-c48c39ed0ded	2025-10-10 18:23:36.992615-05	\N	\N	\N
e072eb45-e0f8-4f5d-9ab5-bf308878f397	ac815aa5-9166-4c35-ab28-1e35a5cdccd6	579c2652-eb95-4bcd-8554-8409ddb58457	2025-10-10 18:23:37.123512-05	\N	\N	\N
56777670-a4b9-4638-ac52-37abdac60a0f	ac815aa5-9166-4c35-ab28-1e35a5cdccd6	5fda2982-ab1b-4640-87dc-ab0e5e1e6b7d	2025-10-10 18:23:37.240671-05	\N	\N	\N
c5f574ad-04ab-44aa-8183-e3f3c72e62f5	1ba15f92-dca9-46f0-be12-a1ee95f0befb	41571564-d09c-47dc-9b43-1682e9d89fc2	2025-10-10 18:23:37.901863-05	\N	\N	\N
f3683e3a-b500-4e26-99f7-3f1ae33ea7bb	1ba15f92-dca9-46f0-be12-a1ee95f0befb	c02b332d-ae31-4e94-ac15-d82c85924f00	2025-10-10 18:23:38.013298-05	\N	\N	\N
c8080841-2c94-4f22-97db-56936c474d8d	1ba15f92-dca9-46f0-be12-a1ee95f0befb	71911198-16b4-4ff8-8b84-f549a80a890d	2025-10-10 18:23:38.123062-05	\N	\N	\N
8798798c-2893-4b7a-900a-dfd1956bb64c	1ba15f92-dca9-46f0-be12-a1ee95f0befb	1551f25c-b0dd-4bd4-a155-3b70dd448f23	2025-10-10 18:23:38.236686-05	\N	\N	\N
5b1f63d9-ed37-4885-8809-edbc14f104fd	1ba15f92-dca9-46f0-be12-a1ee95f0befb	c1c75aa4-8af6-4728-9b2c-0c316007c090	2025-10-10 18:23:38.350811-05	\N	\N	\N
b9a70054-b98d-45b9-a006-93eb8cfec321	1ba15f92-dca9-46f0-be12-a1ee95f0befb	0fbc894c-87c2-41ce-b8b7-42512c9359a7	2025-10-10 18:23:38.473627-05	\N	\N	\N
04180e13-b9d8-43b6-89b0-8742e8300013	1ba15f92-dca9-46f0-be12-a1ee95f0befb	8cd15b1f-40be-4b95-ac4c-12ac662a40e7	2025-10-10 18:23:38.590655-05	\N	\N	\N
4be049fa-e61a-4cc1-be09-4a4bb385e2c1	1ba15f92-dca9-46f0-be12-a1ee95f0befb	9756327c-34c2-44ac-ae21-9fab22ddab79	2025-10-10 18:23:38.707519-05	\N	\N	\N
893631f7-5082-4445-927f-648357369ac4	1ba15f92-dca9-46f0-be12-a1ee95f0befb	b087d0a1-683b-4b5f-9734-b2ba9b561592	2025-10-10 18:23:38.822674-05	\N	\N	\N
fd0cb435-0653-46f7-b09c-f766ec9a7b04	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	454d988b-f89a-4c43-aa69-467f8bd37a77	2025-10-10 18:23:39.450425-05	\N	\N	\N
e67f3395-ab80-4cca-b298-778c8d840927	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	fcac7885-4668-4e14-a1df-183717ba8545	2025-10-10 18:23:39.561009-05	\N	\N	\N
5fe8552c-1add-4561-b251-b29803729489	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	3fae1d2c-e792-4621-9e2d-14ecc6e6b206	2025-10-10 18:23:39.671281-05	\N	\N	\N
d5a3914c-4a41-44ff-b565-53f9bf933141	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	2f0a681a-859b-4d9c-a1fe-2ed4bac3b88e	2025-10-10 18:23:39.77979-05	\N	\N	\N
4bf3573a-f0b5-4c08-a600-8f34df2df256	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	7415bcdb-02e6-4fd0-a09d-ea19cf77b266	2025-10-10 18:23:39.894353-05	\N	\N	\N
d09a3ae3-9df4-4879-a4f9-fadfc2f74b23	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	142f1dd4-1d6a-4fec-8881-e611db9b7837	2025-10-10 18:23:40.020623-05	\N	\N	\N
230ce196-e4f1-4656-999f-ac1371d9a562	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	4fab2ed8-8fe6-48ec-bb71-e1444c3dd913	2025-10-10 18:23:40.147016-05	\N	\N	\N
9ba0c5dd-f52a-4b62-9a2f-84d53e0f0c4c	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	3da546ad-613d-48e9-8fcf-40f09ea86f24	2025-10-10 18:23:40.274457-05	\N	\N	\N
1ab46a2a-357a-4e6b-bac6-99e2a07b3753	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	48408009-3fec-4cec-9151-630e0a3f9a9b	2025-10-10 18:23:40.394194-05	\N	\N	\N
77c06b3e-10a3-497a-8968-98403383a9dd	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	7727ab56-0e44-41c5-b3bf-69c05f223302	2025-10-10 18:23:40.512506-05	\N	\N	\N
3374d99e-782d-4d45-92cd-0da59577a299	1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	b4b91b7e-05d6-4a86-9986-1b83c060d38a	2025-10-10 18:23:40.618735-05	\N	\N	\N
63f5f50b-c986-4ea5-9984-e52a920a5854	4a382bcf-040a-40f4-91bf-0ea9f8f57afc	166dfbf3-8a67-4dd0-8564-7ef8bba2de24	2025-10-10 18:23:41.247125-05	\N	\N	\N
5768b7bf-ec41-47ac-94a9-aa41b41b6ed6	4a382bcf-040a-40f4-91bf-0ea9f8f57afc	b3eaa747-84e7-4502-9311-66e273dc612d	2025-10-10 18:23:41.353666-05	\N	\N	\N
3d3c8983-8c8d-4f27-86dd-6b064050d6a7	4a382bcf-040a-40f4-91bf-0ea9f8f57afc	538a3a1e-ef9e-44c9-a134-8b3eb67f71c1	2025-10-10 18:23:41.461021-05	\N	\N	\N
25c15a19-248b-45a3-8b13-c10f90111542	4a382bcf-040a-40f4-91bf-0ea9f8f57afc	c455c2c4-b78f-4448-b64a-207aacd0fb71	2025-10-10 18:23:41.570156-05	\N	\N	\N
5d982ea8-ff4d-4015-a2bf-2a42bec9e9ad	4a382bcf-040a-40f4-91bf-0ea9f8f57afc	f4ef417e-1217-4105-84f9-095fef139879	2025-10-10 18:23:41.684357-05	\N	\N	\N
f49a9779-87ec-4e45-a769-9bf35771f06b	2f91f6aa-11bd-4acd-8890-f73ab32d6eda	4c45506f-2c1b-4db8-ab3d-d12470237132	2025-10-10 18:23:42.297689-05	\N	\N	\N
dc3a88df-ec8f-456e-be8a-2f817b4a6d94	2f91f6aa-11bd-4acd-8890-f73ab32d6eda	c6965a6b-af0c-43be-9c9a-7fdfd22c822b	2025-10-10 18:23:42.487458-05	\N	\N	\N
1ecf457d-3251-4727-9581-921edd97c031	2f91f6aa-11bd-4acd-8890-f73ab32d6eda	4454448b-6847-4e6b-b5e9-5a0246934341	2025-10-10 18:23:42.595354-05	\N	\N	\N
514a34e7-b73c-47e9-af1a-85b8cb1940a3	2f91f6aa-11bd-4acd-8890-f73ab32d6eda	8bb91ba4-0495-4a94-ba6d-35e3425e5f86	2025-10-10 18:23:42.705884-05	\N	\N	\N
5844838d-1d6b-4f41-9c73-4045a6365e05	2f91f6aa-11bd-4acd-8890-f73ab32d6eda	bb9b51a9-9635-4ed6-a04c-382d00aa9f29	2025-10-10 18:23:42.807798-05	\N	\N	\N
aa5fd022-6543-4e28-a411-b0345f1aa6e2	2f91f6aa-11bd-4acd-8890-f73ab32d6eda	c46e53d0-6fc6-40b0-a49e-7fe0ca286e06	2025-10-10 18:23:42.93524-05	\N	\N	\N
f641cec2-d1be-429d-ad44-92bd519b1b47	0069610c-0488-43c1-b9d7-5781e25c66d2	30647c53-e1da-48dd-a63c-910cd6f06a54	2025-10-10 18:23:43.55841-05	\N	\N	\N
c2537513-64bc-4943-b9c1-ffa44379b386	0069610c-0488-43c1-b9d7-5781e25c66d2	7f11256c-804b-490d-8fd2-1bd61970f2fa	2025-10-10 18:23:43.695862-05	\N	\N	\N
5b5cff40-e0f9-47c0-b810-c856f238ef71	0069610c-0488-43c1-b9d7-5781e25c66d2	a8a5fde0-93ea-4d5b-adce-5921d5febe30	2025-10-10 18:23:43.923855-05	\N	\N	\N
a7e6d28d-beda-4d59-95a1-d999b946335a	0069610c-0488-43c1-b9d7-5781e25c66d2	76c908ed-ade9-4d21-86ea-29ca29d87321	2025-10-10 18:23:44.053228-05	\N	\N	\N
9398abda-f71e-478b-b099-c9c9fde584c3	af64f443-d50c-4a44-b5aa-47e0dca43613	b0258c3d-86f1-4064-b4c9-add2882e90f7	2025-10-10 18:23:44.680207-05	\N	\N	\N
e6c3c5a7-268e-4d54-8557-e8d6f8a1800c	af64f443-d50c-4a44-b5aa-47e0dca43613	3ab5d654-9872-4087-846d-8f2265015336	2025-10-10 18:23:44.795808-05	\N	\N	\N
e4b39e9c-97e0-43e5-9732-86c4f42ca4bd	af64f443-d50c-4a44-b5aa-47e0dca43613	80fe785d-a1dd-49a8-9bfc-2130e9a5c89a	2025-10-10 18:23:44.921862-05	\N	\N	\N
ac1c6d04-4b75-4c1a-833f-4c948fdc26c5	af64f443-d50c-4a44-b5aa-47e0dca43613	47421419-143e-4fb4-b57b-d953d7d1e2fb	2025-10-10 18:23:45.040046-05	\N	\N	\N
8d5373a2-bfab-4717-9307-07dd6d844b17	af64f443-d50c-4a44-b5aa-47e0dca43613	83a91bfc-8341-4d3c-aeea-6c34a0234c44	2025-10-10 18:23:45.156125-05	\N	\N	\N
239fe4d3-3d52-4e7f-97ae-8a8e7d651bbe	af64f443-d50c-4a44-b5aa-47e0dca43613	8a15fb09-dd86-4b58-883d-5207b24b2e9d	2025-10-10 18:23:45.267564-05	\N	\N	\N
b738b1ae-5b4a-4169-a3af-9912faf67ea6	1fc1a78b-c3ef-47a3-92f9-9c0ac089f48a	8bc57d9b-b545-44fa-9dbb-95f904c78f1f	2025-10-10 18:23:45.849082-05	\N	\N	\N
e91b979d-e83b-4361-9fec-23558d6d2fa8	1fc1a78b-c3ef-47a3-92f9-9c0ac089f48a	c464c796-35ba-4189-bb2a-399322fd32e1	2025-10-10 18:23:45.973083-05	\N	\N	\N
c199e1d9-a2d8-4ef2-8a29-94616a6ab414	1fc1a78b-c3ef-47a3-92f9-9c0ac089f48a	a47fd403-d680-44f6-aec4-4f9af7d48f9e	2025-10-10 18:23:46.095528-05	\N	\N	\N
645848a1-9dc4-41e8-8cd0-8ad936718268	1fc1a78b-c3ef-47a3-92f9-9c0ac089f48a	927c27ca-4542-46cd-b0f4-6e3c003ae40e	2025-10-10 18:23:46.215882-05	\N	\N	\N
e03b5a66-b6fb-47ce-91e8-d4ba3379bbe7	1fc1a78b-c3ef-47a3-92f9-9c0ac089f48a	91ffbf79-a22b-4bbc-8d58-8dc032945fa3	2025-10-10 18:23:46.336941-05	\N	\N	\N
b7413fe4-764b-40f2-a7c5-cf45c12b070d	1fc1a78b-c3ef-47a3-92f9-9c0ac089f48a	b52fc616-7ef1-4be2-8a52-d7f2ba26c0a8	2025-10-10 18:23:46.463381-05	\N	\N	\N
17abb711-2172-4bb5-88d6-d66e574383ca	d407ce53-891b-403d-a2e6-8262303c14f8	4d569bc2-7de4-4a06-8c17-a030f0f4dac9	2025-10-10 18:23:48.170456-05	\N	\N	\N
9e795d99-b8d1-451b-8c1d-ff15985ab4c2	d407ce53-891b-403d-a2e6-8262303c14f8	ba223dbe-3134-4245-9d65-3b366950e1b8	2025-10-10 18:23:48.292942-05	\N	\N	\N
16e212d5-59ff-45c6-bec6-27efe560dc0f	d407ce53-891b-403d-a2e6-8262303c14f8	3ed6d6c5-831c-4c6a-a29e-f33d6697bfea	2025-10-10 18:23:48.426467-05	\N	\N	\N
1d6c925f-4b7b-4364-b08b-17ed953cffb8	d407ce53-891b-403d-a2e6-8262303c14f8	bebea98d-1670-4a79-b924-d65e1f367f4b	2025-10-10 18:23:48.556869-05	\N	\N	\N
407d0a87-2852-4eba-bd84-f30dd7a43ca7	d407ce53-891b-403d-a2e6-8262303c14f8	28ba09b2-4302-46d2-a4df-9943b92709a3	2025-10-10 18:23:48.685109-05	\N	\N	\N
3f408f64-65ed-4e84-a1d8-d776a5847df3	d407ce53-891b-403d-a2e6-8262303c14f8	b7a9c0ca-bb9e-4214-89e1-af890f6bcb52	2025-10-10 18:23:48.803868-05	\N	\N	\N
54de4570-17c7-48f2-bd12-43b63094ae41	d407ce53-891b-403d-a2e6-8262303c14f8	64dda0b1-4e14-4603-af91-a18ca6dd7388	2025-10-10 18:23:48.944102-05	\N	\N	\N
f5e24d1e-5dca-4025-87cd-72fbacd349c2	d407ce53-891b-403d-a2e6-8262303c14f8	e44091d3-edc1-4026-9b61-85dc2a946507	2025-10-10 18:23:49.080592-05	\N	\N	\N
62210efa-ec7d-4efa-a299-ba79bc20f1c9	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	3f0547fc-f874-495c-82b0-7fcad1f7558f	2025-10-10 18:23:49.718518-05	\N	\N	\N
a0122dce-0d4b-46d0-9af8-d66b106f3d6e	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	8469bdd2-ff27-4173-b2d6-d978fbfa3a5f	2025-10-10 18:23:49.945097-05	\N	\N	\N
546bd79e-4cb5-4b87-9069-7c89ff6a031f	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	64e1c379-e560-48c9-8391-a3e89c197455	2025-10-10 18:23:50.084068-05	\N	\N	\N
3642e4ca-1c76-485d-839f-fc7e4c54322b	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	d61c6def-0752-4e4d-a63f-7c40de291256	2025-10-10 18:23:50.21488-05	\N	\N	\N
b07aadd6-a563-4b57-b720-50ebbd70a161	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	f2d8871b-1f9b-4e7f-ae5b-befe60234525	2025-10-10 18:23:50.348349-05	\N	\N	\N
70b0ee9c-d0d6-4157-a336-42a91d15df91	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	e5c2081e-ee27-4d46-ba28-01621ae65626	2025-10-10 18:23:50.480245-05	\N	\N	\N
d3634f4b-ec80-4d3b-9a67-e4119aea42e6	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	16ab2be4-1d80-4cb7-8a49-8c1b7d0c217f	2025-10-10 18:23:50.613078-05	\N	\N	\N
bc652882-75ff-4ed5-8fb6-29fcb5ec920e	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	7602cd16-b7ef-456d-b457-72e44c0e43c2	2025-10-10 18:23:50.735605-05	\N	\N	\N
004d5635-c1a8-4f29-a767-cf944fd48c76	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	1162a332-420c-43f9-a014-0ac38fd28dde	2025-10-10 18:23:50.862794-05	\N	\N	\N
298f5521-796d-4701-bd7c-9d05359042d8	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	530059ee-db16-409f-b928-adc6eaab68f5	2025-10-10 18:23:51.00265-05	\N	\N	\N
a70f52ab-7c66-48c4-8b68-9a7822bff087	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	b9ac2246-84be-4551-b32d-c0e70bfea086	2025-10-10 18:23:51.136217-05	\N	\N	\N
96f7a904-aee5-4b23-ad28-23656eaf8e54	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	b1c5703e-fb13-4f8a-8739-1c146637a92d	2025-10-10 18:23:51.258531-05	\N	\N	\N
be61595c-be63-478f-a6b4-64945c94909b	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	e475328e-39b6-4a71-970b-b268270ebb54	2025-10-10 18:23:51.385456-05	\N	\N	\N
bce1714a-530f-48c4-b32c-908694ac03da	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	2495f62b-51ce-4f31-bcc4-65e0b9498a4f	2025-10-10 18:23:51.513164-05	\N	\N	\N
d6a4e6a4-5a08-4e12-9adf-8eb695f055d4	5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	b61b2c6e-7090-4e2c-8939-35501ff51f22	2025-10-10 18:23:51.632405-05	\N	\N	\N
195e5ad3-7abf-4c29-8ea6-87dd6ea6d483	50e46fb5-886b-458c-aecf-5694d6200ce4	c51caad9-c869-4460-a45f-bcc9e497b515	2025-10-10 18:23:52.29358-05	\N	\N	\N
3c261582-1880-450a-95ba-3f12967e16fb	50e46fb5-886b-458c-aecf-5694d6200ce4	ef43e5fe-6e55-44ee-93c2-1bdd46e10653	2025-10-10 18:23:52.44468-05	\N	\N	\N
2abf40c0-507e-4ef2-998c-7cadfc2d90c1	50e46fb5-886b-458c-aecf-5694d6200ce4	c75603d1-f1c4-43a2-aa0e-328e9c082f83	2025-10-10 18:23:52.599063-05	\N	\N	\N
d77750d5-a4ca-4e1b-bee8-1e61e193c095	50e46fb5-886b-458c-aecf-5694d6200ce4	be4e2e42-742a-4c4c-ba1d-9100261f85be	2025-10-10 18:23:52.745465-05	\N	\N	\N
167e1444-f8f3-41ec-b935-4ddbbd1cc8a6	781dc4e0-e9b9-4982-9505-c75db7fa5346	a65dc4a0-44b7-47ab-a179-2c56cca8f2c2	2025-10-10 18:23:53.385976-05	\N	\N	\N
aa922abc-a2e9-4cb3-86b2-d7f69d15bc38	781dc4e0-e9b9-4982-9505-c75db7fa5346	c0d582ea-ac4b-40b4-9089-a823034c887a	2025-10-10 18:23:53.522879-05	\N	\N	\N
fb26051f-cb76-4fc0-98ea-83cba6a23f2a	781dc4e0-e9b9-4982-9505-c75db7fa5346	530166f3-5e8f-4f93-959c-609d9c418d4e	2025-10-10 18:23:53.640584-05	\N	\N	\N
a2c8e609-e788-4912-8d6a-b886b43f1483	781dc4e0-e9b9-4982-9505-c75db7fa5346	33faaea6-5017-4c5b-935a-ac94109881fc	2025-10-10 18:23:53.761634-05	\N	\N	\N
02d9eb20-5873-4076-ae86-d2cace3412f8	781dc4e0-e9b9-4982-9505-c75db7fa5346	8f6c193c-f4c0-4fe5-b95a-f57bb5930edd	2025-10-10 18:23:53.883133-05	\N	\N	\N
0a450c09-c40f-4c5b-8f01-2cbc91dea3e1	781dc4e0-e9b9-4982-9505-c75db7fa5346	48d5537e-9830-4e6a-aff5-a28f5773621d	2025-10-10 18:23:54.014345-05	\N	\N	\N
446c9dc4-adeb-4edd-84de-a3459c576a3a	781dc4e0-e9b9-4982-9505-c75db7fa5346	9d6127a4-7467-4b5e-8c6d-33723d32ea43	2025-10-10 18:23:54.146744-05	\N	\N	\N
23a28dba-b15b-4c50-a7d0-b748c72ec393	781dc4e0-e9b9-4982-9505-c75db7fa5346	468f7991-9100-4362-93ad-89cf3f5ed02b	2025-10-10 18:23:54.27903-05	\N	\N	\N
396aa872-dad8-4fd2-8eca-b98a2d019921	781dc4e0-e9b9-4982-9505-c75db7fa5346	4db44e34-6ba3-4c6d-af78-2a8f71277ddf	2025-10-10 18:23:54.415412-05	\N	\N	\N
521150d8-4483-4ffb-98e8-692244a62cd7	781dc4e0-e9b9-4982-9505-c75db7fa5346	d1cadb35-b275-4a6d-9f57-802835316e59	2025-10-10 18:23:54.540872-05	\N	\N	\N
95c6322c-9d32-48dc-aa1c-d98209b615e4	781dc4e0-e9b9-4982-9505-c75db7fa5346	98b766c7-93fa-41c5-a0b4-93d5b9c172fd	2025-10-10 18:23:54.665099-05	\N	\N	\N
5e082542-5d9c-42ab-b828-b94db2edbc54	781dc4e0-e9b9-4982-9505-c75db7fa5346	37c31675-1edb-4514-aa4f-a28eb202b6cd	2025-10-10 18:23:54.79257-05	\N	\N	\N
661f8fbf-6b3b-48a9-9034-80e5c2aee086	781dc4e0-e9b9-4982-9505-c75db7fa5346	3a3f57db-c50b-45ed-8452-4c365c0ab134	2025-10-10 18:23:54.916518-05	\N	\N	\N
1c27f7c1-4c30-4a33-b065-cc39a8d2e00c	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	46896cec-3b5b-411a-b5c7-c91c0d0916f0	2025-10-10 18:23:55.534058-05	\N	\N	\N
59b973c0-6464-45e5-ad16-ac3bf41117d7	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	7001f455-012d-4170-b393-ed91efe8751c	2025-10-10 18:23:55.664517-05	\N	\N	\N
788f4341-9066-4c5a-a9e4-e692b4855d6f	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	b967e182-bc93-4d9f-8cea-08c279838a5a	2025-10-10 18:23:55.792009-05	\N	\N	\N
6b426f08-387e-48d5-8062-e6e1fd9968a1	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	c8128e7d-31e1-4bd4-b8b5-f84ee62aa43e	2025-10-10 18:23:55.926246-05	\N	\N	\N
f4cf8e8d-7220-4301-8930-41f0252cfbfb	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	62a176b6-ea28-47b6-a5e1-2f4229de0a6f	2025-10-10 18:23:56.061609-05	\N	\N	\N
4e976ad6-a828-4280-ad27-3d39ad464059	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	bd990107-7727-44f0-96f6-190339c8dde8	2025-10-10 18:23:56.195178-05	\N	\N	\N
fe8b9c0a-f805-4d6d-98af-1d2d6c7075b8	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	ee4f94a5-1d2f-403a-9036-34d8d8fcd891	2025-10-10 18:23:56.321281-05	\N	\N	\N
04c566a2-48a1-4c39-aa41-cdfb13536829	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	5936c507-e403-4e83-a2d6-d60264d5b362	2025-10-10 18:23:56.445533-05	\N	\N	\N
beb5f52e-19d5-42d1-a6fd-ff23628b618e	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	c0e3e0ae-1a6f-4d80-afc4-f0ef4008ea75	2025-10-10 18:23:56.565485-05	\N	\N	\N
3ccaf28f-8ab8-427b-9c0a-3756f09be340	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	b98b2dd9-22ad-4618-9b1a-24278e5a71fa	2025-10-10 18:23:56.688156-05	\N	\N	\N
f42d7a61-bb5c-4f3f-b566-c95a4c9af45e	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	08742323-666c-4985-9f30-951e6150da68	2025-10-10 18:23:56.80893-05	\N	\N	\N
ecac9b00-4a86-4408-9027-2e68e1b136ab	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	fa20354b-8395-46c8-a3d2-627f188a7604	2025-10-10 18:23:56.945125-05	\N	\N	\N
2d3cfb06-39d8-439a-91bb-b5dcc6b7cb71	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	b9fb7ffb-e6ac-4f4d-bb6b-0e4bc31a78b4	2025-10-10 18:23:57.072796-05	\N	\N	\N
0eafda67-da2c-4e4d-a522-18dbfead86f1	59558e7c-c026-4ecb-aac4-4e10eeeb3d45	33178778-990d-4620-926b-07522014c9b3	2025-10-10 18:23:57.204519-05	\N	\N	\N
c38748b3-4395-4cbd-aca1-30e8b51cfd91	8a171a72-3abb-4193-8900-20422558c8a2	52358b5c-8e38-4acc-a874-fccc735441e8	2025-10-10 18:23:57.828756-05	\N	\N	\N
d96a6637-ac71-4ab1-81bf-f26e1f9f55a1	8a171a72-3abb-4193-8900-20422558c8a2	0d19c510-b82b-4cab-a7aa-060b41010e6b	2025-10-10 18:23:57.969309-05	\N	\N	\N
ecb0463e-2938-492b-8daa-c5374631d44f	8a171a72-3abb-4193-8900-20422558c8a2	6b19cee9-a17d-47e1-ab64-b47cc6805ede	2025-10-10 18:23:58.102792-05	\N	\N	\N
9c088573-702c-42e7-a0e9-5cbc960c0c63	8a171a72-3abb-4193-8900-20422558c8a2	fc939f18-7e88-47de-b4f0-f9c68e0631eb	2025-10-10 18:23:58.230782-05	\N	\N	\N
06ac0f89-65e3-418d-85b5-bf9a423ec4f8	8a171a72-3abb-4193-8900-20422558c8a2	5f580155-aaa1-4167-9cca-a9ede0fa46c2	2025-10-10 18:23:58.363798-05	\N	\N	\N
ee1ad196-df53-4be7-9ac7-4f150badd143	8a171a72-3abb-4193-8900-20422558c8a2	82ed54a4-f7ef-4ddb-b349-7b945c2b2531	2025-10-10 18:23:58.496219-05	\N	\N	\N
c88425d3-82e8-411e-96a0-534c3a669b5f	8a171a72-3abb-4193-8900-20422558c8a2	905a2ebc-e4cf-4ac9-8498-2355716fe8b6	2025-10-10 18:23:58.613803-05	\N	\N	\N
291d0369-3e1e-4460-b56b-3d339d3d4c52	8a171a72-3abb-4193-8900-20422558c8a2	c4cb78e8-4929-41eb-be79-331256c5fdad	2025-10-10 18:23:58.74878-05	\N	\N	\N
bb6deacc-6509-46c1-ad3b-39b24772f382	8a171a72-3abb-4193-8900-20422558c8a2	9cb9e2b7-ce2f-4702-b8f0-e706c42d86bc	2025-10-10 18:23:58.879507-05	\N	\N	\N
30a58813-7ce8-4636-8c1f-e46281ff601b	8a171a72-3abb-4193-8900-20422558c8a2	8e378d72-05a0-4eef-a7f6-d002f49a2cd2	2025-10-10 18:23:59.003662-05	\N	\N	\N
53e8d848-fd11-4597-8cfb-cd9f98a9e259	8a171a72-3abb-4193-8900-20422558c8a2	6f9a5bc5-2c3c-4684-8171-0362037d328e	2025-10-10 18:23:59.132486-05	\N	\N	\N
30ae496e-3658-4964-9a54-933e30036c20	8a171a72-3abb-4193-8900-20422558c8a2	5d4ea0fe-8e21-4168-bc92-dda3ce3f840b	2025-10-10 18:23:59.271322-05	\N	\N	\N
03fcaadb-c9d5-4c59-971f-04baed1e9b6a	8a171a72-3abb-4193-8900-20422558c8a2	c2d8e980-baac-4edf-b8a3-ba69d7b57ad3	2025-10-10 18:23:59.406322-05	\N	\N	\N
d9134f95-765e-4f18-b947-024a2afca496	8a171a72-3abb-4193-8900-20422558c8a2	35842913-a173-4b02-bdf3-c385f0fe7902	2025-10-10 18:23:59.534801-05	\N	\N	\N
d95ba475-67d6-4d83-9662-774d1bcae082	8a171a72-3abb-4193-8900-20422558c8a2	631d76ee-3931-40c0-82a9-ad9e6ebb545a	2025-10-10 18:23:59.665973-05	\N	\N	\N
766c2c7d-e839-4fa5-9fec-775e08de1a2f	8a171a72-3abb-4193-8900-20422558c8a2	7291d641-db5b-421d-a0ef-cd44b039802f	2025-10-10 18:23:59.798089-05	\N	\N	\N
e3fffbfc-1216-4cf8-8e47-6d8a7fe4842e	b83a6d84-bdd6-4904-898b-94a75613cece	f5e7679f-78f3-445e-8e75-6b32ffa36d1f	2025-10-10 18:24:00.482752-05	\N	\N	\N
619675ab-6bb0-4f97-9e57-11d26ec2bf4e	b83a6d84-bdd6-4904-898b-94a75613cece	c11679a7-148c-4302-b4ca-97dcf46a7d64	2025-10-10 18:24:00.637713-05	\N	\N	\N
789a4a2d-f9c4-4128-99c5-8811b8d47581	b83a6d84-bdd6-4904-898b-94a75613cece	c82b6d05-0bf9-491d-8407-3c9b31258d4f	2025-10-10 18:24:00.874647-05	\N	\N	\N
846189fe-d2e5-466e-a0ba-90c450441e0f	b83a6d84-bdd6-4904-898b-94a75613cece	e582d123-8a04-4f21-93af-f6cf28135511	2025-10-10 18:24:01.091841-05	\N	\N	\N
3b61f68c-3cb0-4da2-8793-bb31078a0a9a	b83a6d84-bdd6-4904-898b-94a75613cece	414c5370-da2f-444b-91c0-d62791698f4a	2025-10-10 18:24:01.228153-05	\N	\N	\N
a9792e8e-e5b5-45f9-a895-c5d50f5a85fa	9fffe600-5caa-42a4-8459-06ddf2ea03a4	41749162-bc96-4698-b405-633f2d469033	2025-10-10 18:24:01.889431-05	\N	\N	\N
e248a11d-a870-4952-853e-7bb6e9611f38	9fffe600-5caa-42a4-8459-06ddf2ea03a4	00bd2b9d-7571-4c15-861e-f29a21636498	2025-10-10 18:24:02.048049-05	\N	\N	\N
4b4b1194-8425-4cf1-b224-4f0425b2b6a4	9fffe600-5caa-42a4-8459-06ddf2ea03a4	262d1784-3f43-4076-8f0e-ffca1d91fa70	2025-10-10 18:24:02.305069-05	\N	\N	\N
bc0a6996-1bf6-4f3c-a7b5-3b19d36097a6	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	6dbf2693-d278-4ffa-bd49-f853f7144bd4	2025-10-10 18:24:02.938755-05	\N	\N	\N
d1f1075b-2169-48a2-8039-d878e0448b84	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	46c91ff7-569b-4966-acb3-77b2f6188dda	2025-10-10 18:24:03.084384-05	\N	\N	\N
2b25a9d5-7652-4c81-812e-85cec35312f7	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	23a066e8-f642-4b5d-857b-ba9866f4b010	2025-10-10 18:24:03.238895-05	\N	\N	\N
26ad1d78-3f78-440a-a41a-92ac19e9bfc5	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	78a657b3-6015-4b8c-ae69-380d0dcf58d6	2025-10-10 18:24:03.374187-05	\N	\N	\N
3e7a796c-33fa-4c3d-90c6-3da584e5aa34	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	e40338b3-eaf4-4095-bdf2-f69158f1c902	2025-10-10 18:24:03.509344-05	\N	\N	\N
495812fa-698e-418a-aed4-f99ec383643a	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	38714e29-1efd-45db-8509-dd97d93e5fee	2025-10-10 18:24:03.653719-05	\N	\N	\N
0edaf7f5-56b2-4d32-8d66-b2aaea3b0837	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	64f6bfd6-e7d1-40ed-bfff-d7167a8b2005	2025-10-10 18:24:03.784568-05	\N	\N	\N
9581ec24-493c-4079-bc82-60c283b5403b	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	4af80c20-dde7-4628-a84e-1a1fc609a5f7	2025-10-10 18:24:03.926843-05	\N	\N	\N
edf69c44-b6ae-4b36-9dc3-2616cb3f20d5	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	70fb8582-4233-4913-bb97-18c40dc5027b	2025-10-10 18:24:04.072615-05	\N	\N	\N
1999af88-b780-4979-8646-d779469aa57e	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	6606a0b5-2f1d-4dab-a845-4f83e438fc38	2025-10-10 18:24:04.215601-05	\N	\N	\N
245ca783-1f59-438e-b5d2-f20bc482ad44	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	8d9cd57a-b15f-4afa-97cc-9e3e0e70009a	2025-10-10 18:24:04.352033-05	\N	\N	\N
4c034a08-9fea-4f20-86fe-b92c4351664a	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	c1737ed6-6a83-4b77-bdf9-4a2895305878	2025-10-10 18:24:04.494606-05	\N	\N	\N
9b349cca-4b03-41ce-8141-0667b9512f78	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	355226ff-d00a-4403-9cf9-f75dfe0eb323	2025-10-10 18:24:04.626716-05	\N	\N	\N
fff7bff7-b97b-4828-96fc-fbe95dc35f53	236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	cbd0a17b-6dda-45cf-8425-e5e09a092106	2025-10-10 18:24:04.759067-05	\N	\N	\N
250b8c16-1055-42f8-b259-701bf99efd12	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	20d53670-3fe8-46de-b3b4-677eb234324d	2025-10-10 18:24:05.422289-05	\N	\N	\N
ed368671-9aab-47e0-89f3-a1f1d27ee1ab	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	be861d32-3f7e-4df1-9ae9-632603e9ec47	2025-10-10 18:24:05.560896-05	\N	\N	\N
1b0a689e-5090-4ce6-bd81-43c7d8718b1f	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	11079f22-d723-4a05-9ed6-82b649ca2a08	2025-10-10 18:24:05.711077-05	\N	\N	\N
016b2442-1346-4be5-b3f6-4b5d35630b08	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	899f0373-cbf3-4de4-bb5e-581c966f7e27	2025-10-10 18:24:05.836966-05	\N	\N	\N
203166b5-8e56-4321-9aec-c669641f86f4	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	53044f24-bb14-4afa-ad1a-ec8b502c2753	2025-10-10 18:24:05.976766-05	\N	\N	\N
15513e06-ad3d-4998-bd68-dfd70f44ad3f	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	5206f896-9207-4151-a2b0-9d388f2803fc	2025-10-10 18:24:06.094356-05	\N	\N	\N
fa092b26-32ee-4706-96b6-82760d95e90e	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	66d35b5d-c471-4557-9077-e8ffdc4ccb55	2025-10-10 18:24:06.218611-05	\N	\N	\N
b12b3baf-652a-498c-ac5b-523615b750c1	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	3ffa07a1-adf7-45dc-aae6-04156dce6682	2025-10-10 18:24:06.360114-05	\N	\N	\N
cea902b1-4e06-47e8-a48b-5b760360a343	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	6405fb64-63dc-43ff-8e0d-cd418b369f5f	2025-10-10 18:24:06.497927-05	\N	\N	\N
6d0a70cb-b484-41ab-b530-273b59f117d2	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	45b0c287-5f1e-4351-9144-fcf1ee804ed3	2025-10-10 18:24:06.639107-05	\N	\N	\N
c0d58684-b1bf-46ef-9c69-abd7a4328305	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	1388f5bb-34f3-40dd-b91b-0ec1c1044d77	2025-10-10 18:24:06.779498-05	\N	\N	\N
7fb3da25-9b6f-44c1-8a33-75aeeb7aa3c1	8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	a9b5f3db-f5ae-4aaf-adbc-8728f9bc7245	2025-10-10 18:24:06.897894-05	\N	\N	\N
21e6cd2b-b105-4f25-984e-2b24e0aadc59	6f899f51-c88f-44cd-ade4-60fe44854786	a0d10bb8-307a-401b-9f4b-8a12bf66e683	2025-10-10 18:24:07.507938-05	\N	\N	\N
09754df2-eb9d-406a-ab1c-8f13a6778522	6f899f51-c88f-44cd-ade4-60fe44854786	ac97a39e-f685-497a-8459-80efc0acf4e2	2025-10-10 18:24:07.641966-05	\N	\N	\N
daaccf6d-7300-4de8-8c33-13eec7ddca38	6f899f51-c88f-44cd-ade4-60fe44854786	3149973b-6ccb-4d9e-a831-6af8436c6761	2025-10-10 18:24:07.777411-05	\N	\N	\N
fcc94548-3081-4040-bb00-15d062c89343	6f899f51-c88f-44cd-ade4-60fe44854786	3cbc7436-9881-417c-a78f-20fbb6d3c249	2025-10-10 18:24:07.90206-05	\N	\N	\N
81fb5431-54f1-408d-ac66-d1563fba65a9	27bc06b3-05b6-4a3f-bc37-5ab40bab96bd	9ec43481-7e27-4579-979e-76ef18d4cbbb	2025-10-10 18:24:08.524192-05	\N	\N	\N
e2a13e79-02fb-4e57-87bf-5bdb39e0cb7f	27bc06b3-05b6-4a3f-bc37-5ab40bab96bd	d457c2c0-7b2c-4c0d-a838-df985fa1c410	2025-10-10 18:24:08.658301-05	\N	\N	\N
5f36897c-b4a2-4c23-bf28-2681f5b3ec00	27bc06b3-05b6-4a3f-bc37-5ab40bab96bd	e39ca054-7c34-4de3-8a03-871cbec8d4b3	2025-10-10 18:24:08.788252-05	\N	\N	\N
dfb85f0f-ddab-4465-95a6-0b4b1685539e	27bc06b3-05b6-4a3f-bc37-5ab40bab96bd	ba2d2e6f-345d-4607-b4f6-751a34928b09	2025-10-10 18:24:08.906392-05	\N	\N	\N
d7a64ceb-976e-4275-972a-3d185e752af1	27bc06b3-05b6-4a3f-bc37-5ab40bab96bd	ef3d0104-0553-4c48-8b54-26ec61ef3889	2025-10-10 18:24:09.035637-05	\N	\N	\N
0606c206-c1d8-4eff-83dd-3f83235c1baa	27bc06b3-05b6-4a3f-bc37-5ab40bab96bd	52bbb895-e756-4752-8e32-f7547d924e57	2025-10-10 18:24:09.154054-05	\N	\N	\N
4afb9086-e617-425e-bc7d-9f73fe8a0bb7	d4c1f60e-4b95-40be-bc68-fb8998f18dc8	42f1d1aa-439a-4548-b36b-6ccf27f284ae	2025-10-10 18:24:09.803106-05	\N	\N	\N
2180aa13-8c54-4aa3-b444-36cc3c55ec4f	d4c1f60e-4b95-40be-bc68-fb8998f18dc8	0c86ae02-9555-4dcb-8d6e-5e8881b1d6e5	2025-10-10 18:24:09.957341-05	\N	\N	\N
e858e20f-d1a5-4652-8c03-4557f5674988	d4c1f60e-4b95-40be-bc68-fb8998f18dc8	e4459358-600a-4a6b-8df6-3007f328c1c2	2025-10-10 18:24:10.09818-05	\N	\N	\N
ab524fdd-e808-447c-861e-6a51594d3021	d4c1f60e-4b95-40be-bc68-fb8998f18dc8	1e47f6e1-87eb-4dda-962f-3ec754142fc1	2025-10-10 18:24:10.245748-05	\N	\N	\N
63e82150-fdbb-43ec-bc52-a661eb3926be	d4c1f60e-4b95-40be-bc68-fb8998f18dc8	741927a9-90ad-4e57-96af-47d377e71813	2025-10-10 18:24:10.37318-05	\N	\N	\N
2803cf0a-12a9-4e8b-957a-72de0b18a248	d4c1f60e-4b95-40be-bc68-fb8998f18dc8	2183145f-d835-4fd2-bf90-e17d4ac79d6d	2025-10-10 18:24:10.514108-05	\N	\N	\N
3e6cf2d4-24a5-4f9d-9b23-5198f94ad3ea	fe1a81a2-306e-4106-8d1e-719ffb067e42	3223a244-b6a4-4025-81d0-15ffa8d94445	2025-10-10 18:24:11.161296-05	\N	\N	\N
2af26506-c907-429c-8efb-8defbd1546e2	fe1a81a2-306e-4106-8d1e-719ffb067e42	caddeb73-4e16-43b8-a46d-922d2de201fe	2025-10-10 18:24:11.293299-05	\N	\N	\N
475e3d44-b830-46fe-8416-de8ae7a59254	fe1a81a2-306e-4106-8d1e-719ffb067e42	bf8c62f2-286c-443a-aa1f-5637e075dc28	2025-10-10 18:24:11.423838-05	\N	\N	\N
297c3ac0-31dc-451a-b549-ec1d4b7f7690	fe1a81a2-306e-4106-8d1e-719ffb067e42	a1dbf3fc-3f0e-4eb8-b94e-89e4bd59213d	2025-10-10 18:24:11.545-05	\N	\N	\N
f12ed0d1-23a4-44e1-b975-8c46c1c4a07e	fe1a81a2-306e-4106-8d1e-719ffb067e42	090fa507-3b5e-4bce-8f5c-ae809a078eca	2025-10-10 18:24:11.667062-05	\N	\N	\N
eb6f423a-59eb-4a16-a58c-52f6b2798b70	fe1a81a2-306e-4106-8d1e-719ffb067e42	c9abee51-8b28-4145-8082-5d30c8c35784	2025-10-10 18:24:11.801084-05	\N	\N	\N
9111a92b-e557-40fb-a73c-9343e3c68477	fe1a81a2-306e-4106-8d1e-719ffb067e42	822add8c-cfc2-4831-a175-2b1b1fccde77	2025-10-10 18:24:11.929554-05	\N	\N	\N
cf54cdc1-f24b-42b2-a4cd-7cb80e03c5b2	fe1a81a2-306e-4106-8d1e-719ffb067e42	067ce140-cfb5-43cf-906e-b0d510f85a24	2025-10-10 18:24:12.062401-05	\N	\N	\N
07f04420-0497-400e-8b9a-8a570d78494f	fe1a81a2-306e-4106-8d1e-719ffb067e42	94558f86-fdf7-4662-946b-4e6b874616d9	2025-10-10 18:24:12.191337-05	\N	\N	\N
9f24dab9-03de-43fc-85c7-4eecc704baf0	fe1a81a2-306e-4106-8d1e-719ffb067e42	2c0e5943-c22c-48f1-aa6a-607e310a47ef	2025-10-10 18:24:12.325396-05	\N	\N	\N
3081593a-be73-479b-bb04-fe10df327494	fe1a81a2-306e-4106-8d1e-719ffb067e42	79d136ae-3c99-41af-86da-97dc7f4cc5b9	2025-10-10 18:24:12.454548-05	\N	\N	\N
0a80a8f2-a95c-4999-a8a6-4b15c9800e02	fe1a81a2-306e-4106-8d1e-719ffb067e42	0d3a6944-dbce-4d07-8ad9-12cce769585d	2025-10-10 18:24:12.573026-05	\N	\N	\N
6ac4b447-85c3-4588-9054-cb5730e3e851	fe1a81a2-306e-4106-8d1e-719ffb067e42	2eba323e-7e93-483d-91af-73679c4dedda	2025-10-10 18:24:12.708273-05	\N	\N	\N
2c00499d-5ad1-462f-8af3-c5d9622c743a	fe1a81a2-306e-4106-8d1e-719ffb067e42	fab143a9-5987-4504-abfc-8a81330b3ffa	2025-10-10 18:24:12.83926-05	\N	\N	\N
8345b246-ba41-4bb3-b5ac-476f16a4b325	3fddc702-8526-4054-9bf3-e84a9cb956c7	6c4018e0-86b0-470d-bcc3-bb23346a7e71	2025-10-10 18:24:13.506737-05	\N	\N	\N
02a8a26b-e92f-4782-b050-637c2c88d05b	3fddc702-8526-4054-9bf3-e84a9cb956c7	92a31a1e-b72d-4455-bb8c-6e935bbcf417	2025-10-10 18:24:13.627783-05	\N	\N	\N
5fdcf76c-06b2-484a-9872-5524813afda0	3fddc702-8526-4054-9bf3-e84a9cb956c7	ce59463e-cd24-45ba-be24-017b0f630edd	2025-10-10 18:24:13.749341-05	\N	\N	\N
0303abcc-7f39-4022-8bf9-f76bf2d694dc	3fddc702-8526-4054-9bf3-e84a9cb956c7	eac76333-a313-4641-8b9d-5ddb1fbc3b0d	2025-10-10 18:24:13.87995-05	\N	\N	\N
e462b08f-88c2-4e54-902a-9090796b1043	3fddc702-8526-4054-9bf3-e84a9cb956c7	a32140d5-34fe-4dec-8b0d-3113b5345d50	2025-10-10 18:24:14.017476-05	\N	\N	\N
b9e418c4-d0f2-45e9-b741-2c430eaadd5d	3fddc702-8526-4054-9bf3-e84a9cb956c7	1fb2fb68-b243-457e-a93c-d5de68b66596	2025-10-10 18:24:14.150158-05	\N	\N	\N
97ae4968-3660-43de-a3c0-9fce6ad57ba6	3fddc702-8526-4054-9bf3-e84a9cb956c7	cadac56f-8f3b-4b5d-8f02-cd2eb1278de3	2025-10-10 18:24:14.283287-05	\N	\N	\N
dfac9172-d6c8-4e20-a951-6ec49994ee11	3fddc702-8526-4054-9bf3-e84a9cb956c7	c4eed450-3a17-40e3-8f4b-cdc97cab6ba8	2025-10-10 18:24:14.428102-05	\N	\N	\N
ae963d94-8116-4797-95b3-0ef4a14dc9b6	3fddc702-8526-4054-9bf3-e84a9cb956c7	0f875e41-18ca-4b45-9e99-a53e7b7ee23c	2025-10-10 18:24:14.585712-05	\N	\N	\N
db6af5ff-0af1-4da0-9e3a-30a5234eae41	3fddc702-8526-4054-9bf3-e84a9cb956c7	6c007685-ac73-4782-8f3f-801844b6292f	2025-10-10 18:24:14.720836-05	\N	\N	\N
7dec6100-0a62-45b2-be72-d7cabf75a05f	3fddc702-8526-4054-9bf3-e84a9cb956c7	01402794-35fb-4295-a579-07bd70d065cc	2025-10-10 18:24:14.856122-05	\N	\N	\N
e2813d42-d7a0-4e55-8a3c-f12bc21e0887	cd913b1a-ed39-4349-8bba-9d38bc07007c	81979a13-d99c-484c-9a6b-4de16907db33	2025-10-10 18:24:15.515034-05	\N	\N	\N
9b199041-e6ef-4ba2-8ce8-c8a6b1596dcf	cd913b1a-ed39-4349-8bba-9d38bc07007c	dacfdccb-1c16-4995-bf1e-4ce47f6ef4e0	2025-10-10 18:24:15.647127-05	\N	\N	\N
34a20e8d-eb2e-4f26-9fa9-568f7877bbf8	cd913b1a-ed39-4349-8bba-9d38bc07007c	888ee102-4973-47be-8046-4b1c1137cd65	2025-10-10 18:24:15.770966-05	\N	\N	\N
4dbd41a1-567d-4745-9adc-17989daafdfc	cd913b1a-ed39-4349-8bba-9d38bc07007c	14ade23d-96a3-4b32-a7ac-5b8bfaffb723	2025-10-10 18:24:15.914198-05	\N	\N	\N
54400fa4-edf7-4a61-9415-d9579cd3e4cd	cd913b1a-ed39-4349-8bba-9d38bc07007c	3ccea26c-4216-40e7-8b61-ac18e60d9bc6	2025-10-10 18:24:16.043245-05	\N	\N	\N
904c3120-2474-403f-b6f8-7fa1b59100ff	cd913b1a-ed39-4349-8bba-9d38bc07007c	65fdcfbc-bf92-4998-a9a4-07b8bcbbbf99	2025-10-10 18:24:16.172128-05	\N	\N	\N
7eadbee5-5efe-4c91-af43-2a9823112ff7	cd913b1a-ed39-4349-8bba-9d38bc07007c	3375cbb4-6ba8-418d-919a-2eb1c6c8b503	2025-10-10 18:24:16.295811-05	\N	\N	\N
dc652718-4143-47d6-a016-017fd79c02de	cd913b1a-ed39-4349-8bba-9d38bc07007c	f42dde7c-c885-4376-940b-3310758fdf9a	2025-10-10 18:24:16.429285-05	\N	\N	\N
7a53621b-e721-4764-8856-5d8cb2058931	cd913b1a-ed39-4349-8bba-9d38bc07007c	7a455ed6-22e5-48f7-8e3f-13a4a274ee43	2025-10-10 18:24:16.567911-05	\N	\N	\N
533484d9-5b2d-4d68-8ce2-f09b873d536f	cd913b1a-ed39-4349-8bba-9d38bc07007c	57be8635-780b-4aeb-8002-75d528a5198a	2025-10-10 18:24:16.707884-05	\N	\N	\N
0efad120-f7e4-4783-9497-0700f415383f	cd913b1a-ed39-4349-8bba-9d38bc07007c	b7122f66-b42b-4ab9-871b-464a965747b4	2025-10-10 18:24:16.838444-05	\N	\N	\N
b38f02b7-30ef-4650-8b4b-448654fdb758	dd344554-ea9f-4201-af51-c420c0dfdf6e	f6b9d26a-bbfc-43a8-be0a-6083d6baa5fc	2025-10-10 18:24:17.499167-05	\N	\N	\N
db29bfa0-cd4a-46c1-a80e-f08c265c5c4f	dd344554-ea9f-4201-af51-c420c0dfdf6e	2af9a75f-5b96-4bbb-809c-f8c5102307bd	2025-10-10 18:24:17.63124-05	\N	\N	\N
ad97656d-54c6-4272-b60e-3e69459cac5a	dd344554-ea9f-4201-af51-c420c0dfdf6e	cc69a533-7916-4d01-ab3c-4f12c797a7af	2025-10-10 18:24:17.767369-05	\N	\N	\N
66137f27-3577-4f70-b09e-68b68fa35d23	dd344554-ea9f-4201-af51-c420c0dfdf6e	71212f20-3431-49e8-9e12-01f4ea41f51d	2025-10-10 18:24:17.888972-05	\N	\N	\N
490201e6-6301-4dfa-a96d-80fd727f2483	dd344554-ea9f-4201-af51-c420c0dfdf6e	7d74da5a-d24d-4c74-80f4-f53b1b9ccda5	2025-10-10 18:24:18.016658-05	\N	\N	\N
372f0837-64cc-4d67-9e12-eddef90f9af8	dd344554-ea9f-4201-af51-c420c0dfdf6e	f83e15b5-835e-4739-a7f6-5322041cbd24	2025-10-10 18:24:18.140276-05	\N	\N	\N
74c47cd1-0901-45d8-b116-a5fb23b30a53	4186bdcb-6366-4462-ae37-fd5fd118bdec	9759ba5a-70c7-4ac2-9baf-324a11771f35	2025-10-10 18:24:18.772936-05	\N	\N	\N
3493b6df-526e-4f00-89d8-684765fa5870	4186bdcb-6366-4462-ae37-fd5fd118bdec	52a3a373-2e33-4a87-8937-4809ac5d4ef5	2025-10-10 18:24:18.917758-05	\N	\N	\N
22787646-7b67-4f23-a62d-35eff6c22b86	4186bdcb-6366-4462-ae37-fd5fd118bdec	66157dfc-2761-46a4-8e90-4350efcc4d00	2025-10-10 18:24:19.049793-05	\N	\N	\N
b2ea19e3-b60d-46dc-b912-a624b5c11e96	4186bdcb-6366-4462-ae37-fd5fd118bdec	17ec7f78-ecdb-40ed-995b-2296f2e00238	2025-10-10 18:24:19.186053-05	\N	\N	\N
0c50581a-6773-46a8-ad09-c2455c8c3e58	4186bdcb-6366-4462-ae37-fd5fd118bdec	b4b7b7ae-faf9-4585-bbed-c67a604f80f6	2025-10-10 18:24:19.324127-05	\N	\N	\N
1610348b-8f83-49a4-b22e-23239f6fd67b	4186bdcb-6366-4462-ae37-fd5fd118bdec	67ac3a21-429d-480c-8456-9088fc65b201	2025-10-10 18:24:19.451926-05	\N	\N	\N
7e3430ed-3363-4a54-88b1-6e9a9996da9b	4186bdcb-6366-4462-ae37-fd5fd118bdec	60ba8be2-fa40-4522-bfd1-5de50c36b364	2025-10-10 18:24:19.576423-05	\N	\N	\N
559efb9c-ba8e-4401-8d04-842157ac2a4e	5cab5f83-5af0-46cf-9969-cbb3d0f8cc05	f896bf25-bdbf-4866-b432-a2d1ea2babf3	2025-10-10 18:24:20.232235-05	\N	\N	\N
16f6a99f-04df-4af4-8ebd-f0f6a9a2c6bd	5cab5f83-5af0-46cf-9969-cbb3d0f8cc05	452205c1-388b-4e94-9b84-f925717539ad	2025-10-10 18:24:20.373584-05	\N	\N	\N
acbc4734-ec6e-4b65-8dbe-cd2d6fd8d4bc	5cab5f83-5af0-46cf-9969-cbb3d0f8cc05	b9a39b35-ab36-4c24-bb0a-d7f006bad113	2025-10-10 18:24:20.508862-05	\N	\N	\N
0f1728f3-0ebc-4f2f-85a3-882e239d1dee	5cab5f83-5af0-46cf-9969-cbb3d0f8cc05	123d5acb-d6cb-4eb3-a8b4-d13297d0f532	2025-10-10 18:24:20.669724-05	\N	\N	\N
fe815e11-0c47-41a2-8456-158e8ea8e10a	5cab5f83-5af0-46cf-9969-cbb3d0f8cc05	9312fe6c-628b-4423-a0e9-0f191006f3fb	2025-10-10 18:24:20.812299-05	\N	\N	\N
b8edc18b-d82b-4d62-9c9c-5460467670d2	5cab5f83-5af0-46cf-9969-cbb3d0f8cc05	8587545f-9df0-4872-ab6e-883850c70036	2025-10-10 18:24:20.961699-05	\N	\N	\N
084eb082-1f62-4c0f-bd49-bdafcde8ff03	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	0d8a5bb8-9d8e-4203-831a-ef9cbc81be23	2025-10-10 18:24:21.596057-05	\N	\N	\N
9970901b-b109-45bc-b7d8-fe412498e8e0	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	55664a6c-2a81-4808-a818-ccfda55ca51c	2025-10-10 18:24:21.734043-05	\N	\N	\N
b089b0b3-0cbb-424a-9c1f-3dec0a86f505	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	2ece3a5f-6050-4eac-93f1-774f5de15855	2025-10-10 18:24:21.853524-05	\N	\N	\N
1c6c6001-6fa1-4179-b527-06b21126841d	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	4ba54c06-f0d5-48ed-ba13-e32bb6f65822	2025-10-10 18:24:21.985898-05	\N	\N	\N
ac4da718-08be-4de0-afc8-9ef27bf08aa6	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	45c0ceef-11a2-4a88-8f89-b907f9fcdc69	2025-10-10 18:24:22.116535-05	\N	\N	\N
3ac0608e-322d-4e0e-9b69-3c16ef58aedb	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	4fbbb6c2-6f23-4ba1-b69b-de598052f62e	2025-10-10 18:24:22.256842-05	\N	\N	\N
42c973ad-fd23-4729-be2a-2dce656b27fb	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	bcc3bd0d-3482-4a90-a242-051e4d24a2bc	2025-10-10 18:24:22.390733-05	\N	\N	\N
be98f757-909a-480a-8bbf-88e24e3eb792	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	3afc04fe-f77d-49d9-bb72-befea04cd0d9	2025-10-10 18:24:22.519623-05	\N	\N	\N
0c7c6631-900a-4e49-8f2a-af227cd1b387	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	408340ae-389b-4449-a6ef-2bdc7e6d9381	2025-10-10 18:24:22.652568-05	\N	\N	\N
fdada98e-057b-469f-a537-713a98eb0167	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	3641aa87-7634-4636-9615-7a4bfcfb2a36	2025-10-10 18:24:22.780508-05	\N	\N	\N
b53a35b7-7ec7-4a3d-9265-08592004d919	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	4d1cf06f-5894-4c45-a3f4-4b2f7b41b5c9	2025-10-10 18:24:22.896519-05	\N	\N	\N
90ed8769-53e7-45f9-bf3c-7c4192ca308e	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	fcb22f32-ccb9-4fe7-8106-b362de679d04	2025-10-10 18:24:23.033306-05	\N	\N	\N
a1713dbd-40a9-4e89-9bf2-a21abf83757e	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	6f880790-2dca-4cb6-8a05-2a878875f651	2025-10-10 18:24:23.150448-05	\N	\N	\N
22f1aeeb-29f1-470c-9351-43ea179d5abf	f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	7339f530-12d8-471b-84df-c68ed74af03c	2025-10-10 18:24:23.280128-05	\N	\N	\N
0cbe50cd-50a3-48d3-911b-83c1a185c9c7	0651744d-e62a-4d7c-969d-925281acaf1f	1f4d6275-08c5-4d81-9b77-94aa6a4ea79d	2025-10-10 18:24:23.938175-05	\N	\N	\N
75bb273d-15b5-4444-ae1c-8fbf43458822	0651744d-e62a-4d7c-969d-925281acaf1f	45c95821-f371-47d6-8b61-f03e2f92372e	2025-10-10 18:24:24.075649-05	\N	\N	\N
629f912d-9dc3-468e-9b5e-10f8e1ce2966	0651744d-e62a-4d7c-969d-925281acaf1f	e1a10ee2-5fc9-4c15-aa69-47f2b1630f22	2025-10-10 18:24:24.197779-05	\N	\N	\N
0cc791be-014a-4071-92e3-b65ac3b11008	0651744d-e62a-4d7c-969d-925281acaf1f	34e53d5c-0c2e-43ff-94f9-4eec7ac65f7a	2025-10-10 18:24:24.332105-05	\N	\N	\N
4780b916-e3bc-4870-a5db-156d4e3b7503	0651744d-e62a-4d7c-969d-925281acaf1f	de34c5ea-e9e1-48ac-b711-62b90faa9564	2025-10-10 18:24:24.469953-05	\N	\N	\N
0b7bde90-51a4-4ea9-8024-92ca42375f37	0651744d-e62a-4d7c-969d-925281acaf1f	31419fca-721e-4a6c-9214-c805cdfd8413	2025-10-10 18:24:24.605331-05	\N	\N	\N
6c47ec02-7922-442e-9347-cb74e297fd94	0651744d-e62a-4d7c-969d-925281acaf1f	6bbace54-97dd-42fb-a5d8-1692d11d0538	2025-10-10 18:24:24.74425-05	\N	\N	\N
bcaba75c-4675-43db-a2d1-6ed8f7c7997e	0651744d-e62a-4d7c-969d-925281acaf1f	93d29de9-21cf-42dd-bf5d-0298f9ba66c8	2025-10-10 18:24:24.871505-05	\N	\N	\N
b49c52d9-7e8c-4954-b448-9988b05309ba	0651744d-e62a-4d7c-969d-925281acaf1f	edacd143-2001-4445-b50c-f0fcddbd65d6	2025-10-10 18:24:25.011615-05	\N	\N	\N
4b968881-c01f-43d0-98a8-c4dbf5ba0022	0651744d-e62a-4d7c-969d-925281acaf1f	bcc2c3c7-86c1-4415-b596-8295f95fca84	2025-10-10 18:24:25.138193-05	\N	\N	\N
36f9c8e0-711e-44e8-80f1-cd204176ee2f	0651744d-e62a-4d7c-969d-925281acaf1f	3cff96a8-e78a-4923-b44f-d8fca9e282dc	2025-10-10 18:24:25.256312-05	\N	\N	\N
f767fce1-bf33-47d1-a9b9-44cc7f4baf4b	0651744d-e62a-4d7c-969d-925281acaf1f	9116ebfd-9100-4d5a-a6f6-ba4e13668ecf	2025-10-10 18:24:25.36695-05	\N	\N	\N
0d57b2c8-ecd1-46ef-b6d3-5b6e864b5ef8	0651744d-e62a-4d7c-969d-925281acaf1f	18435931-1cf6-4751-a50a-70a3b9d42657	2025-10-10 18:24:25.483066-05	\N	\N	\N
ce4dc8a5-5546-4111-89c5-6e0739e5752b	0651744d-e62a-4d7c-969d-925281acaf1f	d3c0d383-b05a-4551-99de-d9611a06d4bb	2025-10-10 18:24:25.613697-05	\N	\N	\N
bb2943b5-d64d-4126-8e48-fdd837bb78c6	0651744d-e62a-4d7c-969d-925281acaf1f	38f5d49a-b22b-4534-8c84-f4c762309c7e	2025-10-10 18:24:25.736678-05	\N	\N	\N
5d61658b-1df0-4b8b-9ed4-96c3a83377f2	0651744d-e62a-4d7c-969d-925281acaf1f	cc99b028-2154-4ef3-ab3c-f5e6e6d44b45	2025-10-10 18:24:25.871153-05	\N	\N	\N
c84fd38b-da6b-4bfa-b118-0847130a9e66	0651744d-e62a-4d7c-969d-925281acaf1f	3f513380-87b8-41c3-99e2-59688b0a8f9c	2025-10-10 18:24:26.011273-05	\N	\N	\N
862125fe-8e70-482e-9685-1a0eddec2cb7	0651744d-e62a-4d7c-969d-925281acaf1f	b4216c79-debc-40ff-a9c6-e0ab26c7ca78	2025-10-10 18:24:26.154746-05	\N	\N	\N
91f04d6d-98bc-43a6-afef-7407f7cf4143	0651744d-e62a-4d7c-969d-925281acaf1f	b7fd211c-61a5-4ab2-9f14-560d130ab0b4	2025-10-10 18:24:26.289698-05	\N	\N	\N
f2f55b77-0ef7-4f41-bfb8-79a194a689dc	0651744d-e62a-4d7c-969d-925281acaf1f	c477dda8-0485-47a3-9369-a172817257d9	2025-10-10 18:24:26.423291-05	\N	\N	\N
36a57c11-0bf5-4c9c-a967-c434fb7d26dd	0651744d-e62a-4d7c-969d-925281acaf1f	67be0dcf-a0b1-4e08-a303-122b846c580c	2025-10-10 18:24:26.55182-05	\N	\N	\N
b3229dd0-f924-436c-8638-73a9a8defdf3	0651744d-e62a-4d7c-969d-925281acaf1f	ef3a4a90-c90a-44b2-8a2c-3196cf4d7834	2025-10-10 18:24:26.681926-05	\N	\N	\N
a71971e8-d1b1-49fe-a074-838a975f4400	0651744d-e62a-4d7c-969d-925281acaf1f	6c758e94-d189-4e6b-ada6-6f2128337c2f	2025-10-10 18:24:26.821978-05	\N	\N	\N
ea71a7c0-a70f-4cd0-82f4-d8f5275d71bd	98880f4b-ee38-43b6-bc6a-926c1a4b10e5	fdbf680d-06e7-4d9a-b663-f07c852dd48d	2025-10-10 18:24:27.440059-05	\N	\N	\N
3179a22f-e36b-4ec4-b487-c81601650edb	98880f4b-ee38-43b6-bc6a-926c1a4b10e5	da46f294-bf21-4642-99bf-f6c97a101c76	2025-10-10 18:24:27.585313-05	\N	\N	\N
afe70066-e30a-4a2a-bdda-e6a27b4cd44b	98880f4b-ee38-43b6-bc6a-926c1a4b10e5	b3d3ac3e-d3ed-417b-a5d1-2d91ff079aec	2025-10-10 18:24:27.724932-05	\N	\N	\N
6a8c5311-f055-478a-bbae-4e55011b998e	98880f4b-ee38-43b6-bc6a-926c1a4b10e5	d6e99d06-9eca-42e8-948d-f3b4c579fee8	2025-10-10 18:24:27.865201-05	\N	\N	\N
0b079742-0c1d-463c-bc1d-09c6a0af9314	98880f4b-ee38-43b6-bc6a-926c1a4b10e5	40cfdcb1-b151-40e6-b74b-96dedd8cbf7c	2025-10-10 18:24:28.009284-05	\N	\N	\N
a6a5fc99-6294-4a75-aad8-43e174cd7550	98880f4b-ee38-43b6-bc6a-926c1a4b10e5	d104273d-000e-4858-b7d6-fd900268bf8b	2025-10-10 18:24:28.149902-05	\N	\N	\N
ef372bed-59f0-4540-a416-d4b53a6eb31c	98880f4b-ee38-43b6-bc6a-926c1a4b10e5	062e7bc6-8691-4a8c-ac4e-fb1375bc4e25	2025-10-10 18:24:28.298771-05	\N	\N	\N
d6cb48dc-3014-461f-ab61-c44dc1a5a65f	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	fdd7c708-6efb-483f-b1d5-a0043b504748	2025-10-10 18:24:28.948714-05	\N	\N	\N
4cd02999-54ed-4e02-a242-0b4cb62d007b	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	dd658b34-3a91-487a-96fa-07344303e3aa	2025-10-10 18:24:29.096488-05	\N	\N	\N
c3ddf657-9d8c-4c58-917a-725dea44092e	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	9a22a5b8-c0ad-4c8f-8225-49d1ab17e302	2025-10-10 18:24:29.251089-05	\N	\N	\N
766e35f4-f856-48a1-8c5f-ee04bea3d30f	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	8797d2fe-1854-41d2-998e-ac90cdb14d54	2025-10-10 18:24:29.405658-05	\N	\N	\N
281da0fd-3165-4b01-8506-bda7a3876681	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	badc9fcf-707c-4414-a25d-473c1e91cb26	2025-10-10 18:24:29.569331-05	\N	\N	\N
47459a76-afe0-4fd6-b223-605be26cbaa4	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	313c728b-f62c-4343-998c-69e7251d41a2	2025-10-10 18:24:29.732548-05	\N	\N	\N
22e6c77d-f3d9-4912-8ca4-801bd2a99903	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	9ec3ebd6-483d-4a1a-9c09-3a7efc9f6227	2025-10-10 18:24:29.878982-05	\N	\N	\N
5ddb339c-a0f2-4fb9-a44d-1d972a061c6a	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	89c72d1d-6d8e-4e32-96f0-5feaee8ec841	2025-10-10 18:24:30.029296-05	\N	\N	\N
f311d7e9-f5f4-40c5-9932-8fe5f106e79e	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	7df6e1fd-86b4-4d71-80d6-b614029c818b	2025-10-10 18:24:30.189281-05	\N	\N	\N
25e8a854-8062-4eae-b954-017b183ec669	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	34bdfe7f-65ac-48c0-8ca0-66f7647c0e36	2025-10-10 18:24:30.348943-05	\N	\N	\N
6fdc950b-408b-4e9d-bb66-3ccf7f46d2ca	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	701c0ef0-82ec-4b8e-ad65-aeb7cbd08ed3	2025-10-10 18:24:30.494363-05	\N	\N	\N
6e6af159-cad0-469e-938d-3db465dce75c	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	f46813fb-cbfd-4ca6-8bbb-da3a34a76da0	2025-10-10 18:24:30.633329-05	\N	\N	\N
077bf763-6a1c-40e4-a9bf-d177c9f23728	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	810a4cb2-e918-4943-afb6-5f882958529f	2025-10-10 18:24:30.790361-05	\N	\N	\N
062a5d6d-68a4-4247-bf75-351157f9d489	4839fbbe-21ed-4bfa-b7da-23d25cda5a37	a94365aa-fe6b-4e1c-a4f3-8203df61189e	2025-10-10 18:24:30.966603-05	\N	\N	\N
a3319ea5-13b8-42ba-b1f4-78528c1f806f	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	de29a11c-0f0f-4ebc-bc93-b0fdb3f90513	2025-10-10 18:24:31.651911-05	\N	\N	\N
95a75088-ad6c-4c02-9685-e827aa0b1ff0	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	f180ea39-b924-4e22-a9a3-d8d9b1eee0ad	2025-10-10 18:24:31.809807-05	\N	\N	\N
5e7802f2-5e45-4837-9941-7efc334f60d0	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	7be4a86d-b619-43f7-8d6f-a8d6f4fa2725	2025-10-10 18:24:31.968841-05	\N	\N	\N
d69ecc1f-de0a-4a8b-947d-1d1433b24516	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	74e61fd6-3be9-4983-ab29-3f542eccae5c	2025-10-10 18:24:32.120361-05	\N	\N	\N
6e43736f-6832-4889-b848-b0103e55ad10	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	92c1841c-1141-43b6-98fb-70a2f340519b	2025-10-10 18:24:32.263661-05	\N	\N	\N
f05b8a21-c8a4-4d57-9e2d-226c66bdd865	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	3b41ad04-9a15-4280-a266-cbb2dd3a1750	2025-10-10 18:24:32.421778-05	\N	\N	\N
7ba7b6c2-9a21-44fc-bd6c-edf290fe0173	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	8ccde2a5-0a71-48cd-b45f-10c8f491a03e	2025-10-10 18:24:32.574514-05	\N	\N	\N
f4a3ffa4-1408-49bf-bae8-49e2a54096df	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	05bf9bc8-c2a2-4745-9c1d-721b6fb6e61a	2025-10-10 18:24:32.749285-05	\N	\N	\N
16df6a2a-534f-4a77-aee2-fd15667c9436	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	1cbb77c7-8a15-47e4-a198-eee622dc0446	2025-10-10 18:24:32.896863-05	\N	\N	\N
698484bd-00bc-4215-8bb5-5b9add8d4ed5	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	32f7b643-e6b3-4bc9-82dd-397076f1e28f	2025-10-10 18:24:33.047795-05	\N	\N	\N
bec74b21-361d-4202-8b41-b5a73cc14d36	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	672e5da6-6844-45ac-bcf2-e74d65983643	2025-10-10 18:24:33.19892-05	\N	\N	\N
eac82f4b-9951-4793-a10b-6b87cf1ba25c	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	a2887698-29da-49b1-bcba-82e88dd9297f	2025-10-10 18:24:33.351753-05	\N	\N	\N
57e95999-d2a4-4b3f-b1d0-af78f4cc7db0	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	93f6cfcf-6df8-4a41-8d17-ed06cffa92aa	2025-10-10 18:24:33.503585-05	\N	\N	\N
3e1aac02-0f9c-479e-9f3f-222c05d6a20d	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	a8e9f30d-1ddd-479a-ad33-aa6c0be4ef1d	2025-10-10 18:24:33.660294-05	\N	\N	\N
d994234d-3151-4547-8a3d-71bd0f5918ba	c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	697d05e6-2422-481f-b241-39fa5eaf3707	2025-10-10 18:24:33.813491-05	\N	\N	\N
08f00aeb-619f-4eb5-915f-d1364030f57b	c7433fe3-bb48-4719-ad15-e6ff3e0cda2d	ba1183d7-3475-4d23-9231-c8196e63585f	2025-10-10 18:24:34.48208-05	\N	\N	\N
638d89c7-cc0a-47ad-a399-5d8fc21ae68a	c7433fe3-bb48-4719-ad15-e6ff3e0cda2d	0f7e7abc-b09a-4bc3-b588-bc10dbb67fe4	2025-10-10 18:24:34.641376-05	\N	\N	\N
36eb5c9c-9ed6-4c6c-b2c5-cfbfd51a0633	c7433fe3-bb48-4719-ad15-e6ff3e0cda2d	87bccbf8-614e-4a5f-9853-d59e9e8b5222	2025-10-10 18:24:34.794795-05	\N	\N	\N
a66b4dd8-7ad2-4e4a-bc89-b5723edf0478	c7433fe3-bb48-4719-ad15-e6ff3e0cda2d	f8b8cfd9-73a6-4fd7-9a2d-807d0663bfab	2025-10-10 18:24:34.943521-05	\N	\N	\N
a7623362-a728-4bde-be56-332dc9539438	6e9073db-145b-4a5a-9bde-990381e4c769	f74ed1c0-e6a2-4508-940f-e8755becc9f0	2025-10-10 18:24:35.610016-05	\N	\N	\N
a4a771ee-d0dd-4190-b8d3-b154460eee9a	6e9073db-145b-4a5a-9bde-990381e4c769	b4db3919-615c-4a38-88c5-98b3d860a670	2025-10-10 18:24:35.765388-05	\N	\N	\N
49da9470-3d56-40e4-b44c-5d13a39b3f79	6e9073db-145b-4a5a-9bde-990381e4c769	a0da0a7d-2dac-427f-9dc3-56919c5413d2	2025-10-10 18:24:35.914686-05	\N	\N	\N
3a7d3f80-95d0-4bf5-9e8c-5d6bbf4d8486	6e9073db-145b-4a5a-9bde-990381e4c769	40672d91-a7a7-4811-8ef4-fdc02f506e9d	2025-10-10 18:24:36.064035-05	\N	\N	\N
e5b69068-6436-4c4b-92b1-ce2712078c42	6e9073db-145b-4a5a-9bde-990381e4c769	e61ddb8e-52ca-43b4-9ced-8df0efdbf9f6	2025-10-10 18:24:36.188548-05	\N	\N	\N
c956dd3a-db9f-4338-bfce-34aecf9923aa	6e9073db-145b-4a5a-9bde-990381e4c769	8d96a108-96d2-4fbc-aed2-cc3c78a7b741	2025-10-10 18:24:36.327562-05	\N	\N	\N
908b584d-a419-4640-a170-7f2b755e4787	6e9073db-145b-4a5a-9bde-990381e4c769	f5b01127-b315-422a-bd3b-ed506ac8d5f2	2025-10-10 18:24:36.452947-05	\N	\N	\N
78273318-b1e1-488d-8ce6-9f1867f718f7	6e9073db-145b-4a5a-9bde-990381e4c769	4e3a63e2-3490-4c1b-8f08-c0705f94ef9a	2025-10-10 18:24:36.599454-05	\N	\N	\N
8c61d18d-14ef-4ffa-8da3-77d8c82c4997	6e9073db-145b-4a5a-9bde-990381e4c769	e8323462-912d-4397-9aa7-e41e6c7d1dac	2025-10-10 18:24:36.731087-05	\N	\N	\N
d4745cf6-ebca-41a3-b3a3-53fb2b6a28c1	6e9073db-145b-4a5a-9bde-990381e4c769	7eeace61-a00b-4e5e-a0f8-2901bae5e0d4	2025-10-10 18:24:36.856768-05	\N	\N	\N
1cfe5287-1c74-4465-9958-f507eed11160	6e9073db-145b-4a5a-9bde-990381e4c769	61ed03f8-9725-40c2-bcaf-371e572e8ac4	2025-10-10 18:24:36.99169-05	\N	\N	\N
97256075-a377-4db4-9a4f-51ef3bd997b0	6e9073db-145b-4a5a-9bde-990381e4c769	7939e9a7-3c9b-4f25-b063-57af6d98cf10	2025-10-10 18:24:37.130191-05	\N	\N	\N
5adbc6c4-6fae-416a-a013-d9faf4df2ec3	6e9073db-145b-4a5a-9bde-990381e4c769	cfe86afb-0b82-43ce-ae6e-7e4bc053dcea	2025-10-10 18:24:37.258026-05	\N	\N	\N
cb2eaa13-6f16-4596-b380-40b47b595b71	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	e06858c1-4d43-436c-acde-ec6907e7ab18	2025-10-10 18:24:37.894597-05	\N	\N	\N
1e2c4161-9054-4feb-8de0-9446d77a4e56	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	9fc8d24d-5cb7-4842-a361-9e39a5705dd6	2025-10-10 18:24:38.033777-05	\N	\N	\N
e5a973f7-60dc-4747-99db-dc409913006e	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	e165a0f9-6bf4-4005-82e9-65c8b23b092d	2025-10-10 18:24:38.178089-05	\N	\N	\N
57b95ed4-678e-4c86-b8f8-594d429ecb1d	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	a800b2ec-5785-4f8b-8ff6-c606a53fad1f	2025-10-10 18:24:38.322546-05	\N	\N	\N
f6d03a22-f0c2-469d-9a67-3f993ca2813c	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	655d64e1-22ed-44b2-9a01-f2728c7b1f84	2025-10-10 18:24:38.461547-05	\N	\N	\N
50d67d2b-5250-4028-8053-2695f78c3b68	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	217b60f6-8c85-4501-9888-e1f854a7f18b	2025-10-10 18:24:38.589687-05	\N	\N	\N
3f9c397f-38b8-4d95-95f1-f04ff986746b	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	12664e80-6f1a-4bb3-b2f4-29b629f4aafa	2025-10-10 18:24:38.727741-05	\N	\N	\N
8d2b61aa-fc20-48c8-a6b0-7c383ca8ccb3	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	c486189d-bf4a-42b5-be31-07d841b9824b	2025-10-10 18:24:38.858282-05	\N	\N	\N
9d371504-5718-4c93-8f13-5d52cedf905f	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	da93a667-93e3-4745-92ee-c303452fcfcd	2025-10-10 18:24:39.006264-05	\N	\N	\N
eec43cc3-05ef-4689-ac3c-b5459c4d325c	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	9777399b-8a6b-4c9b-829c-96a7d687e3cc	2025-10-10 18:24:39.146046-05	\N	\N	\N
da760524-44d8-4841-bea1-e8cf1d4f884b	6352a0ec-484c-41ec-8fb7-2ea63b23ace3	27432094-a85e-4c1f-bc4f-5419f6c9125a	2025-10-10 18:24:39.288114-05	\N	\N	\N
b6781bf4-e218-4548-80d1-85d4a345a604	87c5e8a4-2554-4514-ab0d-025df16b884f	2ef7326a-4ff3-47be-a303-a9c355dcebc7	2025-10-10 18:24:39.935814-05	\N	\N	\N
212d68cb-d163-4969-a3e3-bedd26e5dffb	87c5e8a4-2554-4514-ab0d-025df16b884f	5681b265-db79-43fb-bd13-f1fb6bf419d9	2025-10-10 18:24:40.111746-05	\N	\N	\N
1d550eec-210a-461b-8b69-b15acd7b9dfc	87c5e8a4-2554-4514-ab0d-025df16b884f	98f640b9-c7f7-4a77-a5f2-e0bc1288bfa6	2025-10-10 18:24:40.25377-05	\N	\N	\N
9fae2126-03c5-4641-930d-a30c9d72a2c7	87c5e8a4-2554-4514-ab0d-025df16b884f	3e1fa1d2-b7e8-4a10-bb91-ebe9882a0df6	2025-10-10 18:24:40.402497-05	\N	\N	\N
f30611c3-9745-402d-900d-0460a52aa9c9	87c5e8a4-2554-4514-ab0d-025df16b884f	d4f1980c-574c-48ce-b2c9-989c7bbb1def	2025-10-10 18:24:40.545014-05	\N	\N	\N
23cd1937-00f3-47af-9331-27a8b94c79c6	87c5e8a4-2554-4514-ab0d-025df16b884f	8238c98e-4bf8-4991-8769-403ec061d84a	2025-10-10 18:24:40.687768-05	\N	\N	\N
a4021abd-f434-4fee-b9e6-f6a0408ecd55	87c5e8a4-2554-4514-ab0d-025df16b884f	5f7eb36e-7612-41b9-b143-4700f95450d0	2025-10-10 18:24:40.829467-05	\N	\N	\N
0c405d5e-b812-46b3-a442-5e66b2940c9d	0047c2f0-00ad-44f2-a862-ab94cdf69b51	5ca0e855-371c-4167-b824-3de1a93ef219	2025-10-10 18:24:41.480729-05	\N	\N	\N
9f3541cd-9004-4198-bb1c-048ebc58c4f0	0047c2f0-00ad-44f2-a862-ab94cdf69b51	a24dddb3-0703-48c5-a1a1-d61c3f32ce86	2025-10-10 18:24:41.617549-05	\N	\N	\N
36e8389a-76bf-48d1-a71c-d5b3be514a2d	0047c2f0-00ad-44f2-a862-ab94cdf69b51	fed23641-1ee6-42b4-a453-9d4e78cb8b81	2025-10-10 18:24:41.756417-05	\N	\N	\N
b7ccbfa5-b793-4abf-a594-f0dc8a956a82	0047c2f0-00ad-44f2-a862-ab94cdf69b51	89ceb766-ed91-4f81-8281-a1f5d12272df	2025-10-10 18:24:41.904371-05	\N	\N	\N
efc8bb98-8c42-4723-8429-61d423c6b3bb	0047c2f0-00ad-44f2-a862-ab94cdf69b51	65b9db8c-f38f-4564-ad71-2c43bd119d0a	2025-10-10 18:24:42.04973-05	\N	\N	\N
38fbafbf-2879-493f-9855-b6fd9fde9e21	0047c2f0-00ad-44f2-a862-ab94cdf69b51	d91143ab-8b21-4a31-b4a4-6b1a7beee251	2025-10-10 18:24:42.196313-05	\N	\N	\N
ba3aedd6-16b9-40aa-889b-570062bbdafb	0047c2f0-00ad-44f2-a862-ab94cdf69b51	ffd9214b-c386-4896-94f9-3728d57b9dd7	2025-10-10 18:24:42.335352-05	\N	\N	\N
874b5770-4bc6-484c-aee6-9924c311a9fc	0047c2f0-00ad-44f2-a862-ab94cdf69b51	81ed3b38-4354-4174-84af-7a6bf32354b8	2025-10-10 18:24:42.502782-05	\N	\N	\N
c0a6f547-1f1f-4f41-898f-68d8cf190719	0047c2f0-00ad-44f2-a862-ab94cdf69b51	457c36ef-a9e5-44bc-84ec-b503da05d13a	2025-10-10 18:24:42.635737-05	\N	\N	\N
00a8f50b-29c9-450d-937e-8fe204bb7799	0047c2f0-00ad-44f2-a862-ab94cdf69b51	1860ed49-ffb5-4324-afe2-af8aadbd5e6a	2025-10-10 18:24:42.778719-05	\N	\N	\N
2040b0ea-7cb9-4e50-8050-120945b59cbf	0047c2f0-00ad-44f2-a862-ab94cdf69b51	07689a05-1262-4b5b-8747-45f2832c4133	2025-10-10 18:24:42.911368-05	\N	\N	\N
97c2add5-c874-4824-a7ba-a2a84585b8b7	0047c2f0-00ad-44f2-a862-ab94cdf69b51	b75c76c9-159a-4d16-bc1d-1f9c4b9594a5	2025-10-10 18:24:43.047785-05	\N	\N	\N
dd08dc80-7e3a-416a-9abd-50bb83175862	0047c2f0-00ad-44f2-a862-ab94cdf69b51	54c2a9ba-3077-49c0-8a24-a8284bdb5733	2025-10-10 18:24:43.200745-05	\N	\N	\N
b3c4e6da-fd38-4285-a382-f9d6fe11806e	0047c2f0-00ad-44f2-a862-ab94cdf69b51	0bea3617-6725-4f5d-8deb-e71d52a99b76	2025-10-10 18:24:43.346156-05	\N	\N	\N
d42112d8-72b6-4768-a592-26f3c4d6cead	0047c2f0-00ad-44f2-a862-ab94cdf69b51	0ffb56a4-43c4-4a42-94e5-d70286b4dd7b	2025-10-10 18:24:43.486704-05	\N	\N	\N
3340b7da-a59d-4f8f-965b-806ce96f8c02	14f633ab-ebdb-4e0c-8604-77f3704a1bee	e51967ee-9714-47e5-ad34-c6503a83de6e	2025-10-10 18:24:44.120767-05	\N	\N	\N
6daf7054-1b0a-4264-97e9-ae9ed519e080	14f633ab-ebdb-4e0c-8604-77f3704a1bee	d88560a3-ea0a-48df-bf2a-10a1a397be5f	2025-10-10 18:24:44.262905-05	\N	\N	\N
11fc5934-d620-406b-a5d8-f3842355d22e	14f633ab-ebdb-4e0c-8604-77f3704a1bee	a511385c-0e46-4035-b82b-4f4a722afd7d	2025-10-10 18:24:44.413285-05	\N	\N	\N
6223ad55-58bb-4d57-abc2-affe6be5ed6a	14f633ab-ebdb-4e0c-8604-77f3704a1bee	83ea898b-4733-425a-94d0-58d0517fb82e	2025-10-10 18:24:44.561189-05	\N	\N	\N
c300d497-d4a6-4370-9f13-c4e19cd2b155	475fa05a-949e-4b65-b790-e84f7e61396b	582f5c24-65be-427b-ac2e-4b16c9ee5b48	2025-10-10 18:24:45.210812-05	\N	\N	\N
bf207a89-8b0e-4e2e-abd5-e7eccbbb2147	475fa05a-949e-4b65-b790-e84f7e61396b	65ac0d17-96a5-4160-bf3b-114530b82111	2025-10-10 18:24:45.351349-05	\N	\N	\N
2073c4a3-fb81-4ef0-afc9-e92ce89ea14c	475fa05a-949e-4b65-b790-e84f7e61396b	2fe293bd-aef9-4df5-b9af-c541f10d5ad0	2025-10-10 18:24:45.490477-05	\N	\N	\N
135a1c52-b86e-49dc-9173-cf5206edcb2d	475fa05a-949e-4b65-b790-e84f7e61396b	e5f07d40-6838-49e9-a5a3-a85f338608e7	2025-10-10 18:24:45.633281-05	\N	\N	\N
4ecc972c-ea0b-4aab-a20a-0a5dcff32e17	475fa05a-949e-4b65-b790-e84f7e61396b	3637fb5a-df83-488d-9b3f-1f3574ec89fa	2025-10-10 18:24:45.802739-05	\N	\N	\N
b9417cd3-ce89-45da-9593-ee832960ca2b	475fa05a-949e-4b65-b790-e84f7e61396b	b221ce38-a22d-47dc-8ad3-cf134af1608b	2025-10-10 18:24:45.944329-05	\N	\N	\N
f1363ef4-0557-4223-be53-e6e084f11060	475fa05a-949e-4b65-b790-e84f7e61396b	ed484d78-7c48-4b79-9960-1ac3cb228462	2025-10-10 18:24:46.09931-05	\N	\N	\N
6edc46b3-62ca-4b0a-8d4e-760d8e6819bf	475fa05a-949e-4b65-b790-e84f7e61396b	daba2d79-9991-4d29-a6d8-5ecec5524241	2025-10-10 18:24:46.234895-05	\N	\N	\N
52c31c9e-b326-4b20-8275-058424da037e	475fa05a-949e-4b65-b790-e84f7e61396b	e394a74f-b153-49c1-9c43-e438014a62c0	2025-10-10 18:24:46.37815-05	\N	\N	\N
ad2bbbce-b1a1-464e-98dc-908ef15c5638	475fa05a-949e-4b65-b790-e84f7e61396b	5cb79a1e-0411-4674-aa9f-e7591e591c6e	2025-10-10 18:24:46.514933-05	\N	\N	\N
9ec6d18e-e09c-4cf6-be7d-b910fc5ccb2c	475fa05a-949e-4b65-b790-e84f7e61396b	33ec9930-eee9-4a8c-8c2e-3cd3a2d5ceb9	2025-10-10 18:24:46.643558-05	\N	\N	\N
\.


--
-- TOC entry 5457 (class 0 OID 19960)
-- Dependencies: 243
-- Data for Name: trimester; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trimester (id, school_id, name, description, "order", start_date, end_date, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
14ec8c9e-4d48-4b0d-8d0a-2285a3f863c1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	3T	\N	3	2025-09-22 00:00:00-05	2025-12-19 00:00:00-05	t	2025-10-10 18:45:25.701539-05	\N	\N	\N
433c48d8-46df-4bd2-aa3c-afa6c9f9ce62	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	2T	\N	2	2025-06-23 00:00:00-05	2025-09-12 00:00:00-05	f	2025-10-10 18:45:25.701395-05	2025-10-10 18:45:27.314539-05	\N	\N
a31b876d-be84-4fd8-a074-4c9a208734e5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	1T	\N	1	2025-03-10 00:00:00-05	2025-06-13 00:00:00-05	f	2025-10-10 18:45:25.615828-05	2025-10-10 18:45:27.314539-05	\N	\N
\.


--
-- TOC entry 5458 (class 0 OID 19975)
-- Dependencies: 244
-- Data for Name: user_grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_grades (user_id, grade_id) FROM stdin;
\.


--
-- TOC entry 5459 (class 0 OID 19980)
-- Dependencies: 245
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_groups (user_id, group_id) FROM stdin;
\.


--
-- TOC entry 5460 (class 0 OID 19985)
-- Dependencies: 246
-- Data for Name: user_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_subjects (user_id, subject_id) FROM stdin;
\.


--
-- TOC entry 5461 (class 0 OID 19990)
-- Dependencies: 247
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, school_id, name, email, password_hash, role, status, two_factor_enabled, last_login, created_at, last_name, document_id, date_of_birth, "UpdatedAt", cellphone_primary, cellphone_secondary, created_by, updated_by, updated_at, disciplina, inclusion, orientacion, inclusivo) FROM stdin;
199a1eb3-9a34-44be-bb68-9d3a78028d90	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Aileen	aileen.terrero@meduca.edu.pa	$2a$11$xqVKAG1OC.RpKSyJVHuiuedz.NXBV4hP1Dfr55ODfrZennba.wbr2	teacher	active	f	\N	2025-10-10 18:23:25.384056-05	Terrero	8-763-227	2000-10-10 18:23:24.850939-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9311ba6b-0680-4f56-9e4b-801a4f3c99ca	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Flor	amyvictoria.isabella@gmail.com	$2a$11$ksYmJtl9EJWq7p6MoC.8XOZ9NYWi1pJblM3fj4C/17olmVL9znJA6	teacher	active	f	\N	2025-10-10 18:23:27.916357-05	Simpson	8-739-1737	1979-03-08 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
c5bdb8d0-9109-48b2-837b-96e015293dce	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Antonina	antoninamunoz2913@outlook.com	$2a$11$mj/9GGll1qwpFMhK1fNxOOAyBc8zWf99BvwncqNGnmTxbV.3yWm/q	teacher	active	f	\N	2025-10-10 18:23:31.645754-05	Muñoz Ruiz	8-235-3522	2000-10-10 18:23:31.128259-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
e7d9d79b-d4f1-4dd4-b864-b70afa96fadc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Falconeris	bonillafalconeris@gmail.com	$2a$11$jKrbR0EptNWkReYp5aG6C.JlFErVBjzrIOjf0KzlrDh6Jbb4LOYMa	teacher	active	f	\N	2025-10-10 18:23:34.316385-05	Bonilla Leavy	1 - 20 - 203	2000-10-10 18:23:33.772423-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
ac815aa5-9166-4c35-ab28-1e35a5cdccd6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Heliodora	carmen.moreno3@meduca.edu.pa	$2a$11$uC//Ww8MThFV8Klg6uf6DOIFOZkR.YuciIW7xag5c7hJAOzGKAhoS	teacher	active	f	\N	2025-10-10 18:23:36.557551-05	Moreno Rodríguez	7-84-858	2000-10-10 18:23:36.035366-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4a382bcf-040a-40f4-91bf-0ea9f8f57afc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Dalia	dalia.lasso@meduca.edu.pa	$2a$11$LRCsSAkdCftDoy4Wz7odm.yo4Z1m3.UOCkQrMOsYsaMdnJexFNSA.	teacher	active	f	\N	2025-10-10 18:23:41.195613-05	Lasso Brias	8-282-979	2000-10-10 18:23:40.730648-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2f91f6aa-11bd-4acd-8890-f73ab32d6eda	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Dalva	dalva.espinosa@meduca.edu.pa	$2a$11$acX9/94uFv4TS4/cggh8peU8spQhPpC39p1xAbgvFQhDi6zq24Hc2	teacher	active	f	\N	2025-10-10 18:23:42.253398-05	Espinosa Rodriguez	2-103-2727	1966-05-10 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
0069610c-0488-43c1-b9d7-5781e25c66d2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	DORIS	dcmltrabajo@gmail.com	$2a$11$CC9zqbT42VmcRALLrDfvjOZ4Zz0cBjArlXL2f6XA1WWVZ481VFmZq	teacher	active	f	\N	2025-10-10 18:23:43.512286-05	CABALLERO	4-718-54	2000-10-10 18:23:43.058732-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
af64f443-d50c-4a44-b5aa-47e0dca43613	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Dioselina	decchiriqui@gmail.com	$2a$11$M5kjiagWOWGiLlIWC7v./.iL5Qboyqg9/OsXV2H2DX4rHInCCzL0i	teacher	active	f	\N	2025-10-10 18:23:44.627836-05	Eysseric	4-122-712	1953-09-04 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1fc1a78b-c3ef-47a3-92f9-9c0ac089f48a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Denia	deniacs33@gmail.com	$2a$11$aCc9XoooK1uQZ8vWAlmvW.wd.5Yf6n1xmy2Z/BxICoAAZk1h/i62u	teacher	active	f	\N	2025-10-10 18:23:45.8053-05	Carrasco	8-701-1479	2000-10-10 18:23:45.391681-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
d407ce53-891b-403d-a2e6-8262303c14f8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Eva	eva.271962@gmail.com	$2a$11$VKLMpZ38TAh0HABXWOc8FO3QlyYw4BIUqic.Eb10uc..vBJBS8pUC	teacher	active	f	\N	2025-10-10 18:23:48.12195-05	Vergara	9-124-1457	2000-10-10 18:23:46.609291-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5a6f3dfe-c97a-49c0-9243-7e9b770a7e4a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Fidel	fidelbatista901@gmail.com	$2a$11$0bqoO8pVuLSaxwnc/cQveuY82wN.WGvSHRd0mhTfPqdZ2z93zwUY.	teacher	active	f	\N	2025-10-10 18:23:49.670539-05	Batista	9-207-694	1974-04-04 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
50e46fb5-886b-458c-aecf-5694d6200ce4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Francisco	francisco.cortes@meduca.edu.pa	$2a$11$lqMYYdqE1kCG8Se3Foh4mu8ZqtLje2SDa13HL6Zv4R6UnqaVacERC	teacher	active	f	\N	2025-10-10 18:23:52.241402-05	Cortes	8-237-2449	2000-10-10 18:23:51.777138-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
781dc4e0-e9b9-4982-9505-c75db7fa5346	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Gisela	gisela.gutierrez@meduca.edu.pa	$2a$11$MorA95R5urV6/WSQJJlqZOogvlbOa.v2QVebmHAYM6CXRy6QKrmlC	teacher	active	f	\N	2025-10-10 18:23:53.329372-05	Gutiérrez	8-500-373	1963-12-08 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
59558e7c-c026-4ecb-aac4-4e10eeeb3d45	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Gloria Cecilia	gloria.christie@meduca.edu.pa	$2a$11$hDZ7U57rNpqWYkIn9ulQg.JWADkwXy0urnaL5uBGHMZeJI5ZhI6AS	teacher	active	f	\N	2025-10-10 18:23:55.486598-05	Christie	8-391-1000	2000-10-10 18:23:55.043288-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8a171a72-3abb-4193-8900-20422558c8a2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	guillermo low	guillermo.low@meduca.edu.pa	$2a$11$6UCRbyQbYOAeP/7w8TnLh.t7smWPtYD3jBDPA/Cp7mzSdkNb2Pgtq	teacher	active	f	\N	2025-10-10 18:23:57.774946-05	low	1,24,1289	1960-03-10 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
b83a6d84-bdd6-4904-898b-94a75613cece	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Guillermo	guillermo.morales1@meduca.edu.pa	$2a$11$stWNTKWOa7P3yxhiQzQObesSyAzKZsrmAXdHzwR0uWO3FxCL0egby	teacher	active	f	\N	2025-10-10 18:24:00.413248-05	Morales	8-213-1293	2000-10-10 18:23:59.960371-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9fffe600-5caa-42a4-8459-06ddf2ea03a4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Hector ivan	hectormoltalvo010199@gmail.com	$2a$11$xkeC/5WVXpWh7ryIdRvxI.plpvkeDxQmf9XXM6GA2sabyLAZZCysO	teacher	active	f	\N	2025-10-10 18:24:01.832735-05	Montalvo martinez	9-727-287	2000-10-10 18:24:01.384308-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
236b12a0-4d1d-4fa3-9ab4-c3d4360c33ee	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Irasema	iracema.atencio@meduca.edu.pa	$2a$11$XX2Wt6guBDX4dyrDXkOmWe22NAZXzH3cDr2CYOEOwAlCd9660DhC2	teacher	active	f	\N	2025-10-10 18:24:02.886215-05	Atencio	8-226-783	2000-10-10 18:24:02.444228-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8c7339c5-6d3e-4e86-933d-0a3a25b58b8c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Isrrael	irismenotti26@gmail.com	$2a$11$fZ6v5hWXG8fYlGCEzNbUW.DU0qauHJt9tGHa9VBY87D0fQGJbkrqm	teacher	active	f	\N	2025-10-10 18:24:05.361276-05	Núñez	8-492-780	2000-10-10 18:24:04.904348-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6f899f51-c88f-44cd-ade4-60fe44854786	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio José	julio.magallon@meduca.edu.pa	$2a$11$Bnst62IKOg4JScYfyTRplukbk5IeQA1frU4mv3eNTWHVMW1yMYaSG	teacher	active	f	\N	2025-10-10 18:24:07.457272-05	Magallón Lorenzo	2-720-1465	1987-04-06 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
27bc06b3-05b6-4a3f-bc37-5ab40bab96bd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Laura Rosalía	lauragonzalez17ep@gmail.com	$2a$11$d7tbTmPNzNjYIs8G8z9wEuAQQTCw8HFUbR6eUTHRy/WON9LBKQCA2	teacher	active	f	\N	2025-10-10 18:24:08.474356-05	GonzálezValoys	8-714-710	1977-11-04 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
d4c1f60e-4b95-40be-bc68-fb8998f18dc8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Lázaro	lazaro.pedroza@meduca.edu.pa	$2a$11$ssk4UbGwKG0QlWthmK/4SOdG1jQ6HXCxGHZhE2hLtX0L9PYRKqpFi	teacher	active	f	\N	2025-10-10 18:24:09.754407-05	Pedroza Rojas	8-241-985	1965-05-03 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
fe1a81a2-306e-4106-8d1e-719ffb067e42	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	MARIA ELENA	llorentem348@gmail.com	$2a$11$uv1nHt4hgVMG//vE/mk05ud1Yv0veDgeWNYVS2ak0/hiEgdrAUHky	teacher	active	f	\N	2025-10-10 18:24:11.099753-05	LLORENTE ORTEGA	8-263-889	1962-04-03 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3fddc702-8526-4054-9bf3-e84a9cb956c7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel	lopezstdaniel@yahoo.es	$2a$11$/N.sHOfp.9OaywDKAGq9Ju0bVkpaxI4qu25PQWeD.FJyyA8haFNMW	teacher	active	f	\N	2025-10-10 18:24:13.450193-05	López stocel	10-9-460	1953-03-06 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
cd913b1a-ed39-4349-8bba-9d38bc07007c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luciano	luciano.morales4@meduca.edu.pa	$2a$11$6ViBeb9XtEM5EZCMwTXl6Oo8e/9VNxjIuH70eYCORGkdApz5iOM.m	teacher	active	f	\N	2025-10-10 18:24:15.451884-05	Morales	9-723-2033	2000-10-10 18:24:14.994244-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
dd344554-ea9f-4201-af51-c420c0dfdf6e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luz Eneida	luckonchangluz@gmail.com	$2a$11$5Yue48LYsC/MXedmpYdFVurHguExywgrCfL.pwhnP.x6PFXSbg9l6	teacher	active	f	\N	2025-10-10 18:24:17.440578-05	Luckonchang Abrahams.	3-81-361	1960-04-04 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4186bdcb-6366-4462-ae37-fd5fd118bdec	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis	luis.quintero6@meduca.edu.pa	$2a$11$bANYFwn9l0gyQff3WMdxAuW7GGbSe5WgnAJH1z9fVjUPBdUIR0amy	teacher	active	f	\N	2025-10-10 18:24:18.716564-05	Quintero	9-124-1305	1963-07-04 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
b5cb04ba-8b09-4f7c-bf34-6fed01fa080b	\N	admin@correo.com	admin@correo.com	$2a$11$ijYC6tyYjXnk.l2uWu.0QeINxiYVKAVhEHwTbaTg5CUtEtlTEZ8i6	superadmin	active	f	2025-09-08 23:38:59.273493-05	2025-04-11 22:55:18.363537-05	Corro	DOC000016	2025-04-22 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5cab5f83-5af0-46cf-9969-cbb3d0f8cc05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	marco antonio	marco.guardia@meduca.edu.pa	$2a$11$AR4zmIBsOtf.6didreH8X.zOBPpGdT/lsVwh5A03OW.fOsE1pBtkW	teacher	active	f	\N	2025-10-10 18:24:20.177535-05	guardia quiroz	8 - 424 - 519	1954-04-05 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
f6c64e44-ee6e-4590-b396-8a8ea2fe4bea	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Alex René	maritzacarrasco2525@gmail.com	$2a$11$z/RSs.4j4CS0I7kIg7N5Le5Uvc6vtnBpcG4RXKDk2CgcKkBxNYh2m	teacher	active	f	\N	2025-10-10 18:24:21.538558-05	Arroyo carrasco	8-7191599	1978-12-05 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
0651744d-e62a-4d7c-969d-925281acaf1f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Luisa	maría.caicedo@meduca.edu.pa	$2a$11$jy57N6A7QdriTC8HL3gnfOp/JnGif/yiQFvWsSHfvgZqAlMDXziAO	teacher	active	f	\N	2025-10-10 18:24:23.881453-05	Caicedo	5-707-261	2000-10-10 18:24:23.430175-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1d4a1f65-0c21-4440-af72-0eeaad4bd0c5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Cristóbal	crijogar@gmail.com	$2a$11$YR188lz45yDcqHx2eVfXf.zOckFIRlgKe4j/krTwPyuRkeWSj8lcq	teacher	active	f	2025-10-10 19:57:32.526747-05	2025-10-10 18:23:39.406323-05	Joseph Garzón	8-162-2234	2000-10-10 00:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:48:48.289789-05	f	si	f	f
1ba15f92-dca9-46f0-be12-a1ee95f0befb	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Cecilia Lisette	cecimosqueea03@gmail.com	$2a$11$qfhcLztadbqelF4P8ykRMOsm9faLdNYs8yNFbVx3HI9qTT1d/PHsq	teacher	active	f	2025-10-10 19:54:33.931444-05	2025-10-10 18:23:37.859758-05	Mosquera López	5-18-1148	2000-10-10 00:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:47:22.325654-05	f	no	t	f
98880f4b-ee38-43b6-bc6a-926c1a4b10e5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Miguel	miguel.gonzalez@meduca.edu.pa	$2a$11$ljEHUN3WN5G2dPFJ0jDJ3.Fi1muc1XcrByYVWMbatIb7Tq7bEfsi6	teacher	active	f	\N	2025-10-10 18:24:27.380284-05	González González	8-439-536	2000-10-10 18:24:26.958959-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4839fbbe-21ed-4bfa-b7da-23d25cda5a37	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Noris	quinteronoris23@gmail.com	$2a$11$1otXJL5a6NETHJ4FfbSnlePOGuT/gOyA1dhkho0pI5HtIA3YasLoS	teacher	active	f	\N	2025-10-10 18:24:28.877818-05	Quintero	8-287-222	2000-10-10 18:24:28.435939-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
c105e5f3-d4a7-42ad-b2fb-5b4b666a36de	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Rigoberto	rigoberto.martinez@meduca.edu.pa	$2a$11$T/L84.g1C3iQGpgnv4jbmeOj02xUrfEEhDvvdyfqoMQcjy624yMaS	teacher	active	f	\N	2025-10-10 18:24:31.587679-05	Martinez	2-78-928	1953-04-08 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
c7433fe3-bb48-4719-ad15-e6ff3e0cda2d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Roberto	robertwright68@gmail.com	$2a$11$WA9CE0ST5L1B28gOWuBQJe/Fv8kOwi1JqX6yfIwGKCp39n0h0n70e	teacher	active	f	\N	2025-10-10 18:24:34.418531-05	Wright	4-197-292	2000-10-10 18:24:33.97423-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6e9073db-145b-4a5a-9bde-990381e4c769	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	RODRIGO ARTURO	rodrigo.tejada@meduca.edu.pa	$2a$11$zZ1Ud8TyCABiievhHTn4V.qrLHUy/rvcv.h4WC8qlPmaDdBpKxa8y	teacher	active	f	\N	2025-10-10 18:24:35.546564-05	TEJADA MUÑOZ	9-729-201	2000-10-10 18:24:35.096321-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6352a0ec-484c-41ec-8fb7-2ea63b23ace3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Silvia	silvia.rodriguez@meduca.edu.pa	$2a$11$Ha9LWm8G8YidQh0Mn8dbnemfQVZ6.KpVShlvJMMQ.HcjB8ktaVhcG	teacher	active	f	\N	2025-10-10 18:24:37.836539-05	De Rodríguez	9-99-1491	2000-10-10 18:24:37.393003-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
87c5e8a4-2554-4514-ab0d-025df16b884f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Dalia	teacherdjones2020@gmail.com	$2a$11$ZxBvBMBM436OoAX0MfcAReZxGNCYvNKaI0yM2eko1zwlc9GdAnM92	teacher	active	f	\N	2025-10-10 18:24:39.872549-05	Jones	8-495-556	2000-10-10 18:24:39.433365-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
0047c2f0-00ad-44f2-a862-ab94cdf69b51	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	GERTRUDIS	trudykir@live.com	$2a$11$GcZWPDxS70lNdSyR.QX3T.C.E97yC5KZo00.3cE7ItkznNi9VwVeO	teacher	active	f	\N	2025-10-10 18:24:41.419377-05	KIRTON WINTER	8-237-996	2000-10-10 18:24:40.977804-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
14f633ab-ebdb-4e0c-8604-77f3704a1bee	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Virginia	vml1316@yahoo.com	$2a$11$HHGxqvwam9WGtt0SrxSvhOPctsfPmlW.bv8//I6164fpdB2RcsFMu	teacher	active	f	\N	2025-10-10 18:24:44.05569-05	Muñoz	8-348-227	1970-12-07 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
475fa05a-949e-4b65-b790-e84f7e61396b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Yamileth	yamileth.hernandez@meduca.edu.pa	$2a$11$PLDb1/2YlexHcaWrpehhPuFs15F4vrEmE8pHn7w/BLZ4Y7gB.yIwy	teacher	active	f	\N	2025-10-10 18:24:45.150195-05	Hernandez	8-756-1076	2000-10-10 18:24:44.71232-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
33af2a1b-8a2f-4dda-b6e5-a23c3191af10	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana José	ana.castillo@pruebasipt.com	$2a$11$LqQO9rpmEObfJQM5RjA5Ou/TbohRysPi0w5KLlu9.cofpHc6t4m9K	estudiante	active	f	\N	2025-10-10 18:25:14.480999-05	Martínez Castillo	3-1500-1385	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:14.480999-05	\N	\N	\N	f
fe99e819-a50f-4597-aca7-17bd7296e1ff	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Paola	ana.chavez@pruebasipt.com	$2a$11$epqplcByA2LE2/emrlDMa.EJjUqi5DOsWTbDZ/Mexf0UJYPQi/scm	estudiante	active	f	\N	2025-10-10 18:25:15.17483-05	Fernández Chávez	6-5766-1350	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:15.17483-05	\N	\N	\N	f
258b05f1-56e7-452d-b2ec-30abbb78f1be	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Ana	ana.fernandez@pruebasipt.com	$2a$11$BqxzYVfG.mFioqYej.2ONOpV.a2tV9UZZXHExsWdOL87EokXKqGfm	estudiante	active	f	\N	2025-10-10 18:25:15.707592-05	Pérez Fernández	8-6147-1376	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:15.707593-05	\N	\N	\N	f
deb2e827-0377-403d-aca7-8e78ce7ddd23	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Pedro	ana.lopez@pruebasipt.com	$2a$11$JVeEQmbh/G2LJCWHuS2fNORhWNzRfoRyFf8GNjw035f7Nd6zl2A.K	estudiante	active	f	\N	2025-10-10 18:25:16.251634-05	Martínez López	3-6892-1389	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:16.251635-05	\N	\N	\N	t
c66e050f-b242-4060-94e0-4c91806dab77	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Marta	ana.martinez@pruebasipt.com	$2a$11$nAzBd9gysa7MevxpYj4c0.2IzxNJ3eHanIAUjYOVc7ZUiLDN3CCXG	estudiante	active	f	\N	2025-10-10 18:25:16.801672-05	Díaz Martínez	10-3268-1115	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:16.801673-05	\N	\N	\N	f
8016e639-8ea2-4fd5-a56f-b1ceaf303a53	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana José	ana.perez@pruebasipt.com	$2a$11$RMSJc6DIlf3CSfmf/xUFXOgUslLkJiy2EOcrwftg9.qNX.ZIE20.2	estudiante	active	f	\N	2025-10-10 18:25:17.341967-05	Romero Pérez	6-7039-1360	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:17.341967-05	\N	\N	\N	f
4a1f5a5d-58d0-4f73-9208-7e1b6d73a700	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana María	ana.rios1@pruebasipt.com	$2a$11$liI9veJAFAsYUaRRIuwFYOnhJIRDVSTlCyCJG2slGtlb2it9Qsx2y	estudiante	active	f	\N	2025-10-10 18:25:17.877863-05	Rodríguez Ríos	4-5760-1114	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:17.877863-05	\N	\N	\N	f
f6f982b8-86a2-4c76-b97b-b951f48e4422	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Ricardo	ana.rios@pruebasipt.com	$2a$11$/I9iMkDDPesgGRosvImR8.vp7ZGj5yNdRSK7HK7rClEpkhD7pNuIu	estudiante	active	f	\N	2025-10-10 18:25:18.432763-05	González Ríos	10-4024-1076	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:18.432763-05	\N	\N	\N	f
420bdefc-0164-4076-b17e-d3dfbbef7a8e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Luis	ana.rodriguez@pruebasipt.com	$2a$11$re7ERoFsYOtt60cLmj9q1e8Q.l/BMdrQhIWqtXfseftgA7J1i31ue	estudiante	active	f	\N	2025-10-10 18:25:18.99735-05	López Rodríguez	3-5146-1221	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:18.99735-05	\N	\N	\N	t
2f238165-5660-46bf-a0e9-c072bc7d92cb	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Juan	ana.sanchez1@pruebasipt.com	$2a$11$Q41Uthf8OU7bxDgCnflhUu4iZnlZjGQB0J44p.bL2AGhG44JUE8hq	estudiante	active	f	\N	2025-10-10 18:25:19.535017-05	Chávez Sánchez	3-8626-1109	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:19.535018-05	\N	\N	\N	f
c1bda3f6-cccb-4cfc-b43d-4e2d294f61f6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Daniel	ana.sanchez2@pruebasipt.com	$2a$11$NPm8ZwqrCHVhiS90P9LjjOby6i4a5EweF87g7ipkdxPO5Xe5tARSK	estudiante	active	f	\N	2025-10-10 18:25:20.058243-05	Castillo Sánchez	7-5584-1215	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:20.058244-05	\N	\N	\N	t
21941532-f100-4443-b5de-7c7e3cc0ae29	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Sofía	ana.sanchez@pruebasipt.com	$2a$11$Wrf92BJQbpae/xwufzpa2.Pf0yNZiDnMFWUp6a8TGAvWOGl8HUbGi	estudiante	active	f	\N	2025-10-10 18:25:20.556048-05	Fernández Sánchez	5-3774-1102	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:20.556049-05	\N	\N	\N	f
ccbeddd6-84b3-4fc6-b0c7-196a906844f2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Sofía	ana.torres@pruebasipt.com	$2a$11$Zslh2y9m9WYvFNv8VqV4n.Nrq/xM5uzq35YBvWpa.5hEVs829Cmh2	estudiante	active	f	\N	2025-10-10 18:25:21.025566-05	Vargas Torres	8-2106-1362	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:21.025567-05	\N	\N	\N	f
ada12236-b69b-4c27-b306-144475244e34	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Marta	ana.vargas1@pruebasipt.com	$2a$11$jDYLLzJEa8V/eOmWK2Su2O/CYo9Mro1Q/RZY.VGstU8Qt7e/Mo782	estudiante	active	f	\N	2025-10-10 18:25:21.528925-05	Moreno Vargas	2-4289-1205	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:21.528926-05	\N	\N	\N	f
32ef5836-f964-470f-b223-08e9c1dda3d5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ana Elena	ana.vargas@pruebasipt.com	$2a$11$MkXkkVNY2dSSZmIWetrR2OrWrdFwyYF4JO1jAbEHw6xGYlVd8tpby	estudiante	active	f	\N	2025-10-10 18:25:22.069819-05	Ríos Vargas	1-2073-1072	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:22.069819-05	\N	\N	\N	f
79fd0959-e9d5-49c6-838e-de575dd01046	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Sofía	andres.chavez@pruebasipt.com	$2a$11$ZnvTnZsUIDLElZEds8jeHeL8mcHeNHmWj7L13l7Y0R3jD.MjVX1oG	estudiante	active	f	\N	2025-10-10 18:25:22.614199-05	Fernández Chávez	1-8733-1217	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:22.6142-05	\N	\N	\N	f
52a1d689-c422-4437-bbdc-d8566687a8e4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Esteban	andres.cordoba@pruebasipt.com	$2a$11$Rr4xBSLY9TNSTspVrcfW9OCRHv/dTBmUMQFofi.hiIMzabsDnOPkO	estudiante	active	f	\N	2025-10-10 18:25:23.162464-05	Moreno Córdoba	6-7114-1364	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:23.162464-05	\N	\N	\N	f
eba7a548-2a47-4134-a94f-4154e41c37bf	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Andrés	andres.diaz@pruebasipt.com	$2a$11$Rq57w19P4I0pLqloprwOJu5hE1BIvfKDKP23civBLGU1g9k4C1cWm	estudiante	active	f	\N	2025-10-10 18:25:23.733422-05	Castillo Díaz	5-8978-1172	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:23.733423-05	\N	\N	\N	f
54fba2ed-ca2f-4d6d-b467-a5ec03ac3d74	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés María	andres.fernandez1@pruebasipt.com	$2a$11$IOf.RNbddQtLEacBMUAGTuSsFRpbY36TD9h3iC7PLMu.Uq.Exc39.	estudiante	active	f	\N	2025-10-10 18:25:24.289923-05	López Fernández	10-6247-1276	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:24.289923-05	\N	\N	\N	f
aef65908-4be2-489d-83ea-65a3b0e7f0f6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés María	andres.fernandez@pruebasipt.com	$2a$11$tLqFaMd/FljT0R9V9SBG1O.20emv1lPybFeRRVFOw8tQNB/OJmMTK	estudiante	active	f	\N	2025-10-10 18:25:24.854225-05	Rodríguez Fernández	4-2771-1156	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:24.854225-05	\N	\N	\N	f
43758908-403d-4d68-8295-483e708b7499	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés María	andres.gomez@pruebasipt.com	$2a$11$HsQqmrs2Vd/UIdaI8HjlZOQPVTPVGsHgIxGJfJqaU446MV8nxDEx.	estudiante	active	f	\N	2025-10-10 18:25:25.424009-05	Torres Gómez	8-7940-1269	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:25.424009-05	\N	\N	\N	t
e81baeed-58c7-4d0d-b971-ae136c434b1d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Esteban	camila.sanchez1@pruebasipt.com	$2a$11$g1.2J422zCjSrPXlllM0BeDbCGOfGsi6RV2F37OfsCmazitbU9mF6	estudiante	active	f	\N	2025-10-10 18:25:42.603656-05	Castillo Sánchez	10-2153-1379	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:42.603656-05	\N	\N	\N	f
8c269315-004f-43e3-b897-305633b40d8f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Ricardo	camila.sanchez@pruebasipt.com	$2a$11$RC27Q65KyrR3ON5EtUGfGOcvPsKbgjSFSdw1SiXimZ1GDMsi/3NDi	estudiante	active	f	\N	2025-10-10 18:25:43.167876-05	Jiménez Sánchez	9-8649-1090	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:43.167877-05	\N	\N	\N	f
3f6f2113-41ff-4f66-8300-be100c112aca	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila María	camila.perez@pruebasipt.com	$2a$11$Z/S9WHfeEnsVYGH.MtP.r.APAzMZCG.bpy/ybv3LBu5ZTADTNYncG	estudiante	active	f	\N	2025-10-10 18:25:39.771737-05	Castillo Pérez	6-1644-1254	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:39.771738-05	\N	\N	\N	f
011ad327-b5cd-4cfa-8614-1668b44e4ccb	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Andrés	camila.rios@pruebasipt.com	$2a$11$C3R.NL6kmF/ABAgKi1zKqubRTGz0aJ12ygYrEcWOvQpf.AHbYB38u	estudiante	active	f	\N	2025-10-10 18:25:40.341395-05	Torres Ríos	7-6977-1096	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:40.341395-05	\N	\N	\N	f
3cebf0bf-bb60-4196-9a77-ce79105e3b04	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Ana	camila.rodriguez@pruebasipt.com	$2a$11$dKhyWp3o3zJxRlECsYoptux6IMNDmbWynZQYMZkuOo/X0uXx0SZDS	estudiante	active	f	\N	2025-10-10 18:25:40.915126-05	Fernández Rodríguez	8-2497-1048	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:40.915127-05	\N	\N	\N	f
285150a0-2a1c-44b5-a984-0b8e4a5c2ec1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Diego	andres.gonzalez@pruebasipt.com	$2a$11$9sxyAtoRveQ0nxIU4qYgsu9ybh1PPptDk5SI.oFtMIe3vMo36mINW	estudiante	active	f	\N	2025-10-10 18:25:25.979161-05	Herrera González	5-2245-1085	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:25.979161-05	\N	\N	\N	f
86be87b0-1a03-4a9f-b820-6ea8700d59c4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Sofía	andres.herrera1@pruebasipt.com	$2a$11$5xz9lbPF292MfAlvuyPJ0OApgsMpy/9xLqy1SyXF66e5YFSP5XJ.a	estudiante	active	f	\N	2025-10-10 18:25:26.605786-05	Romero Herrera	8-4589-1039	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:26.605786-05	\N	\N	\N	f
6009c952-c058-4e71-9936-c88c0940386d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Ana	andres.herrera@pruebasipt.com	$2a$11$wQJrr3l8/xudYQ3GD4M4zezZ3IgLFlsLMbpTv0vzoEC1y55tOp5v6	estudiante	active	f	\N	2025-10-10 18:25:27.144623-05	Gómez Herrera	10-2614-1037	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:27.144624-05	\N	\N	\N	f
39165dd5-9245-48e3-901c-3ddafffbee17	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés María	andres.jimenez@pruebasipt.com	$2a$11$pK4S2BuS5X8u./qv15kOfOdy8GxldsFkcQHKfEQGr49m1ASM8IWMu	estudiante	active	f	\N	2025-10-10 18:25:27.694512-05	Mendoza Jiménez	7-4814-1129	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:27.694512-05	\N	\N	\N	f
85857aba-7343-4a97-83f7-b330b280e48b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Carlos	andres.lopez@pruebasipt.com	$2a$11$Q1ZdAzyRlbiC/1rvRgld1O9rLLx0q0gH5HVBODAmqpz72ZlByeX4O	estudiante	active	f	\N	2025-10-10 18:25:28.241906-05	Moreno López	2-3258-1375	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:28.241906-05	\N	\N	\N	f
8c4af287-a170-42d2-a58d-44713fa83db5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Daniel	andres.mendoza@pruebasipt.com	$2a$11$wWCHYk4/atPtbTm4K74sluyWMH.iglDrOsIi2ldPsyHV0TK37jbQm	estudiante	active	f	\N	2025-10-10 18:25:28.70822-05	Moreno Mendoza	10-5484-1280	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:28.70822-05	\N	\N	\N	f
5a4a085b-1a0a-43ad-ae61-9b2a3d10dba6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Ana	andres.moreno1@pruebasipt.com	$2a$11$.vzLQZ7yPIj7dCqWa.sOt.KVhv1GPYd0lICZ79Fct233bGUDfguDa	estudiante	active	f	\N	2025-10-10 18:25:29.239257-05	Torres Moreno	4-6797-1082	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:29.239257-05	\N	\N	\N	f
2c86740b-7e67-4731-ab39-975b03d93920	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés José	andres.moreno2@pruebasipt.com	$2a$11$xpBe7gciVbAIxKt9d8/TbevAh5JrsetQ7tIaBgN6CiGh5q4CIOlge	estudiante	active	f	\N	2025-10-10 18:25:29.781005-05	Córdoba Moreno	1-5407-1263	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:29.781005-05	\N	\N	\N	t
c3381cf1-effb-4dc6-aebc-1f50c5abde9a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Carlos	andres.moreno3@pruebasipt.com	$2a$11$HcoIVYm0sPYPAaI7ZJhr.ejwHYjy4W/NHYyYomkrjIcf1g0g2kfIe	estudiante	active	f	\N	2025-10-10 18:25:30.302935-05	Vargas Moreno	7-9716-1352	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:30.302935-05	\N	\N	\N	f
7639b757-5b70-44c0-8f8d-48f70757fe03	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Julio	andres.moreno@pruebasipt.com	$2a$11$qsZnKFU9ZHRhyQFlHJk0e.30Ncq7TiFQblyGpPy3Wc91m16QNbwfS	estudiante	active	f	\N	2025-10-10 18:25:30.851776-05	Gómez Moreno	6-7256-1032	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:30.851776-05	\N	\N	\N	f
5253ef90-3ee0-41c2-a626-173c2c41f9c9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Luis	andres.perez1@pruebasipt.com	$2a$11$hZPYAAdLe/uXGiCXInBpsOll4DLTdUWK1rA2pKyvrybdd4L0Jtb7q	estudiante	active	f	\N	2025-10-10 18:25:31.399082-05	Rodríguez Pérez	1-6167-1297	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:31.399083-05	\N	\N	\N	f
cc8be287-43e4-42ac-aa27-92efe7d0152b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Paola	andres.perez@pruebasipt.com	$2a$11$kgbdf6QOIP12lH0XlHQZ/./B0iJBsyT/JSCuI1BfR1L6gmi4F.kxG	estudiante	active	f	\N	2025-10-10 18:25:31.94892-05	López Pérez	5-8564-1118	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:31.948921-05	\N	\N	\N	f
137313cd-89df-45ef-ae9e-c32b79a8d068	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Diego	andres.rios@pruebasipt.com	$2a$11$EVbLDAvYMOjr6x8YTy5gnO4OwIEobBXw093G3HRpuJimkUJALrOTu	estudiante	active	f	\N	2025-10-10 18:25:32.479968-05	Pérez Ríos	4-6812-1239	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:32.479968-05	\N	\N	\N	t
d59a3bd1-2853-4849-afba-62eedd22fda5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Andrés Juan	andres.romero@pruebasipt.com	$2a$11$Mk96UVHgpUUq4Gt8AG73Z.1qSdzgv6APQRxSX2tlI9VzZMQlsssW6	estudiante	active	f	\N	2025-10-10 18:25:33.036942-05	Mendoza Romero	1-7198-1193	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:33.036942-05	\N	\N	\N	f
e505f903-d5de-4847-a44b-97de8f414913	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Paola	camila.chavez@pruebasipt.com	$2a$11$1x8.34./5ZBPtC7XWCUeAejAzaAnt6Nc54LJRHWBFSyOhphm/u40G	estudiante	active	f	\N	2025-10-10 18:25:33.594283-05	Gómez Chávez	5-1090-1071	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:33.594284-05	\N	\N	\N	t
5b813d33-6dfb-4337-acbb-df34f138ca56	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Camila	camila.diaz@pruebasipt.com	$2a$11$8qPsHwRlawEltSuBE8JRE.yX8V1st.F3MiEWktQJbFBBTKpZWANg2	estudiante	active	f	\N	2025-10-10 18:25:34.163659-05	Romero Díaz	3-4558-1133	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:34.163659-05	\N	\N	\N	f
df87630f-56c8-4355-80cf-1222f24cdc8a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Carmen	camila.fernandez@pruebasipt.com	$2a$11$dG0LlIf99WTxFRQGBeVrMeYRZDqLYZfBUsD9nDMhP36/9KjkwQlQe	estudiante	active	f	\N	2025-10-10 18:25:34.727131-05	González Fernández	1-4370-1244	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:34.727132-05	\N	\N	\N	f
4ed3e409-37fb-49f4-b5fa-603f1fddab03	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Valeria	camila.gonzalez@pruebasipt.com	$2a$11$Q2OufEnNqaxgeqLXWJYhIulK9MoXRu8AGxPWifCbcxZZ/75bht2je	estudiante	active	f	\N	2025-10-10 18:25:35.290856-05	Ríos González	1-7266-1372	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:35.290856-05	\N	\N	\N	f
087cba2d-608e-4cb4-bbbd-4d472077c63d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Sofía	camila.herrera1@pruebasipt.com	$2a$11$TcQSBdtF0O5E0uMjkjedIeoq6Zb3sYH28OeD7mKyiNiiBXYhp0ohC	estudiante	active	f	\N	2025-10-10 18:25:35.844702-05	Jiménez Herrera	5-8164-1345	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:35.844702-05	\N	\N	\N	f
e0e8ff8e-0f77-4948-ab5e-b7fadd9f00e3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Luis	camila.herrera@pruebasipt.com	$2a$11$/H4rzYfPII4hSX3TKBNsY.MvbE0BgHV53nziw1X3yPB.Tm4ONyvf6	estudiante	active	f	\N	2025-10-10 18:25:36.373127-05	Castillo Herrera	7-4928-1099	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:36.373127-05	\N	\N	\N	f
5499af9b-c7ba-4a8f-b3d3-2a1fcffc31dd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Diego	camila.lopez1@pruebasipt.com	$2a$11$9TxS8zioC8Ub98MV.60RXeysQUbHDin1myVJp8zfQqc6S.weiW7YS	estudiante	active	f	\N	2025-10-10 18:25:36.916558-05	Pérez López	1-2157-1356	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:36.916558-05	\N	\N	\N	f
ab3f3e93-1a93-4a32-a61c-d8a10ebbfe7d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Camila	camila.lopez@pruebasipt.com	$2a$11$QUgVy5rDJWhevPMZP85F3euL8412i/ncC.sAwx3MviReloLqN3eru	estudiante	active	f	\N	2025-10-10 18:25:37.487241-05	Romero López	2-9325-1347	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:37.487241-05	\N	\N	\N	t
3df11abd-74ba-40e3-8d5f-b04c27556c29	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Marta	camila.martinez@pruebasipt.com	$2a$11$/P.4OfHetGfhXQOsTgWHzu1i5lSmwZ6qefC2nSWgA6E0rqluLOfLO	estudiante	active	f	\N	2025-10-10 18:25:38.057552-05	Chávez Martínez	3-8667-1365	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:38.057552-05	\N	\N	\N	t
3a477bec-ae02-4de8-8d14-36886d2f4f2c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Pedro	camila.mendoza1@pruebasipt.com	$2a$11$ISiavA..qJMkrGR1BA1hRuID5XNQaG71bySZNJfvJb1lZb/vx5GXq	estudiante	active	f	\N	2025-10-10 18:25:38.630806-05	Chávez Mendoza	1-1450-1322	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:38.630807-05	\N	\N	\N	f
fcf4db68-1c51-4c60-8c5f-c4023b810906	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Ana	camila.mendoza@pruebasipt.com	$2a$11$8xRDTbGDz8yvco8NUv17E.jX3FuLG2/CaAilMc4nPSNHC8pIVuVxa	estudiante	active	f	\N	2025-10-10 18:25:39.197516-05	Chávez Mendoza	2-4025-1204	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:39.197516-05	\N	\N	\N	f
92d7d4a8-0e7d-4e5b-86de-8a3722800797	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Daniel	camila.romero1@pruebasipt.com	$2a$11$LRGnFy/2RVM3OOvFpNrhAeUJK8dVE9bdUDa6JoiadkdTjOBcqOc8i	estudiante	active	f	\N	2025-10-10 18:25:41.476069-05	Herrera Romero	5-3493-1242	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:41.476069-05	\N	\N	\N	f
6ae07ea2-cf1e-449b-9848-570b7cd7189f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Carlos	camila.romero@pruebasipt.com	$2a$11$m/Z1Xcu6cgeri7SOXDLuPusuYsBdt/VzbVWV94CxdYXMwMnE9cdxO	estudiante	active	f	\N	2025-10-10 18:25:42.031972-05	Jiménez Romero	3-2257-1094	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:42.031972-05	\N	\N	\N	f
e4dc376f-fa40-4133-a21e-e6ae0bf5f20b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Juan	camila.vargas1@pruebasipt.com	$2a$11$JttiACuiPkUFYMMnM20CE.r/cou3CLsdxyqI2tLK2Qw8Rco2VB7Eu	estudiante	active	f	\N	2025-10-10 18:25:43.723074-05	Herrera Vargas	8-7519-1366	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:43.723074-05	\N	\N	\N	f
7e381731-1233-4b80-9ab2-5c8e8a0da04e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Camila Andrés	camila.vargas@pruebasipt.com	$2a$11$2C8LjB29EwcZrlOncoSec.o2atG/hv.rFhypplziZ0KlfbFoDkF26	estudiante	active	f	\N	2025-10-10 18:25:44.274127-05	Rodríguez Vargas	10-4204-1300	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:44.274127-05	\N	\N	\N	f
67cfa05f-d1f4-4d67-adaf-5e95a21020fe	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Marta	carlos.chavez@pruebasipt.com	$2a$11$xXZxv3X.eeQYNKiojukJ5.jU8O..Qja5vS9RV7MsBeUTi/frUc1aq	estudiante	active	f	\N	2025-10-10 18:25:44.836045-05	Díaz Chávez	5-9266-1081	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:44.836046-05	\N	\N	\N	f
f71f9124-9db0-48f2-a758-e39fd98afa6f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Daniel	carlos.cordoba1@pruebasipt.com	$2a$11$Fi9dCy05T5PDOJxe0XCH/OuuEbWVdiMGc8qcYK.cZc.vBKTZkHNta	estudiante	active	f	\N	2025-10-10 18:25:45.4078-05	Chávez Córdoba	5-7748-1333	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:45.4078-05	\N	\N	\N	f
0fc388ca-a6fd-403a-9f62-cf243b60bcf5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Sofía	carlos.cordoba@pruebasipt.com	$2a$11$QLniz0DXrWE1.vNnTNXtS.jEojRafIMXuQhku0fhhTZDlgdWWm/1i	estudiante	active	f	\N	2025-10-10 18:25:45.964686-05	Pérez Córdoba	5-8541-1236	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:45.964687-05	\N	\N	\N	f
7f2c2253-6085-4b8e-9272-a1cdd30b6ebe	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Sofía	carlos.diaz1@pruebasipt.com	$2a$11$HNgXkjSaUHMhML6Q2DfMvuB6h/R5TD5ruH7iZz0p8qz68yGRNHDdK	estudiante	active	f	\N	2025-10-10 18:25:46.524864-05	Herrera Díaz	9-5338-1174	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:46.524865-05	\N	\N	\N	f
87935e6e-7c17-4053-91fb-f1ece7edbecd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Marta	carlos.diaz@pruebasipt.com	$2a$11$rnPbpU/Wy3su.W2RbHk35etS8BNYhMJRzyTeCTcd6bR/0YEgoDS4G	estudiante	active	f	\N	2025-10-10 18:25:47.058316-05	Martínez Díaz	4-9558-1014	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:47.058317-05	\N	\N	\N	f
6e0bfcaf-7c5b-4316-bb95-b46b06a164e7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Luis	carlos.fernandez1@pruebasipt.com	$2a$11$oxdTytWMkS2n/uOEI0pajeUWteBpctzzNhONyqR.IKYGZkxT6qYDK	estudiante	active	f	\N	2025-10-10 18:25:47.631581-05	López Fernández	8-9734-1277	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:47.631582-05	\N	\N	\N	f
4f9c22f5-ca06-4f50-ae88-698aee8113dd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Diego	carlos.fernandez@pruebasipt.com	$2a$11$fWdoBaqju.r2t2eRht5bDewGju6wUqVj5oIxi7iLzDfVqqLi3ghrG	estudiante	active	f	\N	2025-10-10 18:25:48.191348-05	Jiménez Fernández	8-9031-1057	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:48.191348-05	\N	\N	\N	f
2df4385c-e2c8-4f3a-b03b-6b2566ac11bf	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Andrés	carlos.gomez@pruebasipt.com	$2a$11$yfBhHCzZBnJHbfFxNYs9HOAzTg9DL4GaU0Aq420v3sGhwmhfrSjay	estudiante	active	f	\N	2025-10-10 18:25:48.7469-05	Gómez Gómez	5-2738-1369	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:48.7469-05	\N	\N	\N	f
55d6942c-fab1-4687-8dca-d1e336e34bb0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Andrés	carlos.gonzalez@pruebasipt.com	$2a$11$ebKY/DqnRnXiPB8exH0aae3zRtbhvTuJU.5DIPkOlqPxHvalb5pLm	estudiante	active	f	\N	2025-10-10 18:25:49.302124-05	González González	5-3821-1080	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:49.302124-05	\N	\N	\N	f
bfcfa3ed-7180-4d1b-b590-e495a9bc86b7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Andrés	carlos.herrera@pruebasipt.com	$2a$11$0aHWd/QcwgfL/sdI9Na.QOHTeyPX.CDcKrJU.v5ncI52HVoDkZv76	estudiante	active	f	\N	2025-10-10 18:25:49.880575-05	Herrera Herrera	2-2999-1262	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:49.880575-05	\N	\N	\N	f
e91a08cf-b8df-4310-b949-4df3bd7c50b1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Ana	carlos.jimenez@pruebasipt.com	$2a$11$VVLYTMGpG.UjUQR3aT79QOZCAtLG6fPmT52sJaRXIM0rx.rd6EGh.	estudiante	active	f	\N	2025-10-10 18:25:50.450108-05	Torres Jiménez	9-7568-1308	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:50.450109-05	\N	\N	\N	f
de4c1f92-46da-4e97-9786-870808611a84	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Paola	carlos.lopez@pruebasipt.com	$2a$11$snXs1rvWnZ92NR8j.hRMqeSatlQcPw.wp8lfEFxuOASLTCsBHgjYG	estudiante	active	f	\N	2025-10-10 18:25:51.000791-05	Herrera López	2-3145-1159	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:51.000791-05	\N	\N	\N	f
693740ad-88d3-4ebf-a0ba-05d12a229564	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Diego	carlos.martinez@pruebasipt.com	$2a$11$REg.TtJ2zCDUXEqgvHipS.Ve0QYNyJkmooz1pUpYLQ1VL13NE0F9S	estudiante	active	f	\N	2025-10-10 18:25:51.574899-05	Romero Martínez	9-8081-1318	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:51.574899-05	\N	\N	\N	f
7ee49798-9dae-44e0-bbd8-28b793d87615	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Elena	carlos.mendoza@pruebasipt.com	$2a$11$LhYEZEiI25cxrXCuUdUvrOrtnW.g1bk4ZBEVtRIe5K08rapl7Y8MW	estudiante	active	f	\N	2025-10-10 18:25:52.141546-05	Jiménez Mendoza	3-1789-1228	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:52.141546-05	\N	\N	\N	f
ebee7a34-7faf-48fe-8b11-2e74d6113c5a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Elena	carlos.rios1@pruebasipt.com	$2a$11$C.abNVr.LXdpCfWKh4lntuG0Trp3oBG8AFy.HtGaoRvgykpVbHN.m	estudiante	active	f	\N	2025-10-10 18:25:52.710792-05	Ríos Ríos	2-4357-1237	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:52.710793-05	\N	\N	\N	f
8589d09a-e202-498b-8e72-e1b5a8fcb05c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Ricardo	carlos.rios2@pruebasipt.com	$2a$11$YO5Of89oC/7iqLVFLXmnK.ezzE5RuEsaulNFUeGDqHGOOXEsPlZ7a	estudiante	active	f	\N	2025-10-10 18:25:53.266705-05	Sánchez Ríos	2-7093-1268	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:53.266706-05	\N	\N	\N	f
5e48f5dd-3583-41bb-89b5-74f06b78d5d9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Ana	carlos.rios@pruebasipt.com	$2a$11$c/mvCypwufaC51GrVPClXuRESFoXaWjGajLpOoSMtPwcKdc49kqW6	estudiante	active	f	\N	2025-10-10 18:25:53.825833-05	Mendoza Ríos	10-5870-1169	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:53.825834-05	\N	\N	\N	f
9325940e-d4c1-406f-894b-2116508c850e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Luis	carlos.rodriguez@pruebasipt.com	$2a$11$C8SZ9Mkz3SpnwWr6Dd2sl.VAv9qTL06c7MhPCL4B3MwMTiLWWOZH6	estudiante	active	f	\N	2025-10-10 18:25:54.393876-05	Córdoba Rodríguez	4-9769-1200	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:54.393876-05	\N	\N	\N	f
0560a821-469d-46e8-9344-de66c1921bbd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos María	carlos.romero@pruebasipt.com	$2a$11$CK9BIJZL6z5D.rUVaTnOBeBFi7kRzt3r6R.E0S2KHnx1Ny0Hxj/tq	estudiante	active	f	\N	2025-10-10 18:25:54.959149-05	González Romero	10-9598-1203	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:54.959149-05	\N	\N	\N	t
1082138b-b33d-4fdc-a46c-42f85755fcd0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Paola	carlos.sanchez@pruebasipt.com	$2a$11$Ud36vwH1ZaY3qHHYiEf0KusxYJsPG.E96uIGV39ReUqlHT1GKaohy	estudiante	active	f	\N	2025-10-10 18:25:55.524164-05	Martínez Sánchez	7-7035-1253	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:55.524164-05	\N	\N	\N	f
cc36e9d7-44e5-47cc-a3fd-2d44f34a2d4c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Julio	carlos.torres@pruebasipt.com	$2a$11$EEY1PqfrS.SRyWclRHqoKOcvHnfxqcnNKHxYeHO0T3fS8bgcHUgd.	estudiante	active	f	\N	2025-10-10 18:25:56.083008-05	López Torres	3-8197-1056	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:56.083009-05	\N	\N	\N	f
11b11cf3-01af-4e4a-8292-339b8c160768	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carlos Sofía	carlos.vargas@pruebasipt.com	$2a$11$wqcr5YVLlFHcfT65t/8Q8u.nCXmPoVCXLk5SEWln0HotA4yMhEWMG	estudiante	active	f	\N	2025-10-10 18:25:56.661927-05	Martínez Vargas	6-2137-1068	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:56.661928-05	\N	\N	\N	f
41ff85d9-c1e0-4934-b8da-d9ec78fd4789	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Carmen	carmen.cordoba@pruebasipt.com	$2a$11$IconqexPGsZRw6TS7b1cNeJ2Vo0Ee9jDhthWRj2Z3zlmyFZCEkvXK	estudiante	active	f	\N	2025-10-10 18:25:57.221837-05	Martínez Córdoba	2-2874-1176	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:57.221837-05	\N	\N	\N	f
f2bd2aa0-b2b5-4fe9-935d-cd7fc926d8a7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Daniel	carmen.diaz@pruebasipt.com	$2a$11$psGtUN.mnvTCWwkVtZ89wOCqoXRmbbo47dVkDyqXF6s8KJOjl6zQS	estudiante	active	f	\N	2025-10-10 18:25:57.793933-05	Pérez Díaz	2-4291-1139	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:57.793933-05	\N	\N	\N	f
3437673d-e4aa-4cb3-91e8-2a32925896db	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Pedro	carmen.fernandez@pruebasipt.com	$2a$11$fGwebMurrQPeELZIiEZ7k.E2f8KXLGx0IZADFQmVRUJ4qsX5PDCTa	estudiante	active	f	\N	2025-10-10 18:25:58.368434-05	Rodríguez Fernández	1-7977-1332	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:58.368435-05	\N	\N	\N	f
f137f787-1b81-4c31-b9c6-fd09945d6512	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Ricardo	carmen.gonzalez1@pruebasipt.com	$2a$11$4Wiq72CgdjQhn652CF1eyujFqEXECBTNru3CbTvbgdRzVVHzlWLwq	estudiante	active	f	\N	2025-10-10 18:25:58.948809-05	Jiménez González	3-3745-1128	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:58.948809-05	\N	\N	\N	f
3e3e91d4-1c84-420c-9db3-e1086dddc7d0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Esteban	carmen.gonzalez@pruebasipt.com	$2a$11$EivM66JnYNZDPYo4VtY2xuJJgVEuz3MZnlB8lu3nzToOA9o330s3S	estudiante	active	f	\N	2025-10-10 18:25:59.524797-05	Córdoba González	6-7219-1060	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:25:59.524798-05	\N	\N	\N	f
ba1024d6-b0c6-4c44-ac71-fca1eee217f6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen María	carmen.herrera@pruebasipt.com	$2a$11$fyamHZsvMzwiaadf7OBgIOHdBTmcaWnMwPG.rAbmryuQ2r0gT3pO6	estudiante	active	f	\N	2025-10-10 18:26:00.07919-05	Rodríguez Herrera	10-2994-1091	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:00.07919-05	\N	\N	\N	f
7855c257-0b74-4c09-adc5-453043d08f53	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Carmen	carmen.jimenez1@pruebasipt.com	$2a$11$hhJOLSOO82wNScbzFH3/EO3qYgFlquNO/2FDLpOkw2jmOPkV0avE2	estudiante	active	f	\N	2025-10-10 18:26:00.623925-05	Pérez Jiménez	10-3788-1137	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:00.623926-05	\N	\N	\N	t
337a9697-91b1-4cbe-a1a1-f4bbcac2d6e1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Daniel	carmen.jimenez@pruebasipt.com	$2a$11$Nr52aVq.ozkmBuGBd3k1BeFSpJqFuhhd5rsF.gCsMsJZl4.dDR1gW	estudiante	active	f	\N	2025-10-10 18:26:01.186195-05	Martínez Jiménez	6-3780-1045	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:01.186196-05	\N	\N	\N	f
8fa7e9e9-e9cc-4f6a-b048-2233eef8c33d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Esteban	carmen.martinez1@pruebasipt.com	$2a$11$E.q1hwF5h.ccfa1EAsYIU.9V5GYnjbmeY99S3bWRF2UufQ4r6nmUW	estudiante	active	f	\N	2025-10-10 18:26:01.751149-05	Castillo Martínez	8-8200-1207	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:01.75115-05	\N	\N	\N	f
9212b75d-34f6-41d9-a46e-efa683281eb0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Ana	carmen.martinez2@pruebasipt.com	$2a$11$B8NRShd483KUuCLuXqMX2uYnf9nTN6pfzCUrc6676EHUCE6RjRMGi	estudiante	active	f	\N	2025-10-10 18:26:02.319214-05	Martínez Martínez	2-4860-1317	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:02.319215-05	\N	\N	\N	t
9153e3d4-5daf-4b2c-ae15-460cd464a904	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Paola	carmen.martinez@pruebasipt.com	$2a$11$f/7fgmSeP.jTrsWjksEVkeAi7hbeRlatbuBwHL71svNv9ZTGMIkhi	estudiante	active	f	\N	2025-10-10 18:26:02.8963-05	Torres Martínez	7-6097-1191	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:02.8963-05	\N	\N	\N	t
234f0231-9d36-49b8-96fe-a2c947bf4fe8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Paola	carmen.rodriguez1@pruebasipt.com	$2a$11$eFkIWErNQbmPKJ5P9F5UGOESK.eT7miNZeui6ILsFEAeCqeok8Df2	estudiante	active	f	\N	2025-10-10 18:26:03.458435-05	Pérez Rodríguez	4-5074-1017	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:03.458435-05	\N	\N	\N	t
503d6773-e7fb-4f8e-b17d-112f894f8818	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Paola	carmen.rodriguez2@pruebasipt.com	$2a$11$99L6Ewbwsga.SIqoqWuPCe.D54cv1.5JqyTV/C0z2p7seJtaCrWeO	estudiante	active	f	\N	2025-10-10 18:26:04.025079-05	Díaz Rodríguez	9-4039-1055	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:04.02508-05	\N	\N	\N	f
4e0959c6-3cd4-4931-b743-73e377dfd012	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen María	carmen.rodriguez3@pruebasipt.com	$2a$11$bqxWzwDWJLOBBDCgjbcL9eC.S5oUE1GdbCEJasq351huT9x.nycZa	estudiante	active	f	\N	2025-10-10 18:26:04.599149-05	Herrera Rodríguez	1-2516-1383	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:04.599149-05	\N	\N	\N	t
5c0ba75c-b42a-4b5e-b801-28bb70660d1d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Carmen	carmen.rodriguez@pruebasipt.com	$2a$11$7JFVQn6vE.YimWO8yftGne6pZUsXdG3Hy7rj6uxZL5QNBbiYlQ07y	estudiante	active	f	\N	2025-10-10 18:26:05.177243-05	Sánchez Rodríguez	3-8871-1012	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:05.177243-05	\N	\N	\N	f
4d733cb5-7d14-41bd-94ef-d788166b8466	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Marta	carmen.romero@pruebasipt.com	$2a$11$KS48aB/iJXeSCOBQXt6ECu3tFiMk8QKxIMSs8LAAS7x5DTo0Kbv9.	estudiante	active	f	\N	2025-10-10 18:26:05.718441-05	Chávez Romero	4-6849-1173	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:05.718442-05	\N	\N	\N	t
3e408117-002c-4cb5-8d3d-180590dc9f7f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Elena	carmen.sanchez1@pruebasipt.com	$2a$11$ZM7gR5bPr8CL55mjFwyNduirJMqEC7pLPCbgIq5NMij8MnWUBVWYu	estudiante	active	f	\N	2025-10-10 18:26:06.29346-05	Díaz Sánchez	10-2511-1132	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:06.29346-05	\N	\N	\N	f
e0cab3cf-ad31-4cc6-8ba7-3663699d0704	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Pedro	carmen.sanchez@pruebasipt.com	$2a$11$sPlEKekfEE9TxjSpekNCI.nzIhbsjMHuZkT1X2/lxZYlxOr8RZt5K	estudiante	active	f	\N	2025-10-10 18:26:06.85107-05	Rodríguez Sánchez	1-4106-1020	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:06.851071-05	\N	\N	\N	f
f1cfb3d7-7019-4a5d-8204-6de953256bf6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Camila	carmen.torres1@pruebasipt.com	$2a$11$68DzWNbKwy0trrK9HLUrkOkr9SVxqRu3yj.AtJQwwEf.2sPsU6nJ.	estudiante	active	f	\N	2025-10-10 18:26:07.407926-05	Pérez Torres	4-3945-1258	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:07.407926-05	\N	\N	\N	f
3d8dfff4-b487-4191-8a95-91c9753eae76	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carmen Juan	carmen.torres@pruebasipt.com	$2a$11$9WAuSS7DmH11ZrOyDn8LYOA1DLeEZMiV0OmQapARwCUXIG8hOM9QC	estudiante	active	f	\N	2025-10-10 18:26:07.952975-05	Torres Torres	10-1952-1013	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:07.952975-05	\N	\N	\N	f
4de59fb6-9395-4378-82d1-48a60a61cac0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Juan	daniel.chavez@pruebasipt.com	$2a$11$Vc5qs1uB.2O/4FKs.eZP8OOUwa8VvWOZUV1ur.Wumi8Sn.BEGbTg6	estudiante	active	f	\N	2025-10-10 18:26:08.494213-05	López Chávez	6-3342-1305	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:08.494213-05	\N	\N	\N	t
88563ca3-f643-4514-a10d-153406e412c6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Esteban	daniel.cordoba1@pruebasipt.com	$2a$11$Rs3PicwRpNL9JuDYSVwk/uctyTVzhpW2DlF0Zecul4v/4YbQvBvjW	estudiante	active	f	\N	2025-10-10 18:26:09.046108-05	Jiménez Córdoba	6-5076-1238	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:09.046108-05	\N	\N	\N	f
94af83b3-8ee4-425a-885b-b3e4e7996ed7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Daniel	daniel.cordoba@pruebasipt.com	$2a$11$R7U/LlBARFAboMoD/W5wsuCxN1WX25GbDcq1vy02MgV9aCKBjEid.	estudiante	active	f	\N	2025-10-10 18:26:09.59838-05	Rodríguez Córdoba	10-6576-1134	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:09.59838-05	\N	\N	\N	f
8ec49143-7765-47f7-bba8-68f12b1ebf6b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Marta	daniel.fernandez@pruebasipt.com	$2a$11$rFEHN3M4JSyJ8HXeP3maSOjLo1FUSbIunaOm0pJ.EZ/9ChJLD9vUi	estudiante	active	f	\N	2025-10-10 18:26:10.147737-05	Díaz Fernández	7-1953-1101	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:10.147738-05	\N	\N	\N	t
e70acca8-93cb-4897-80bd-848da12f4d38	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Carmen	daniel.gomez@pruebasipt.com	$2a$11$wgXHhoVKifaLznOzMWkbT.foTEcbdwB4G8/BTdbqQIpgnHhPk2woi	estudiante	active	f	\N	2025-10-10 18:26:10.707818-05	Sánchez Gómez	3-6803-1192	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:10.707818-05	\N	\N	\N	f
5fc375a8-6587-4bfd-8cad-b89eae0072b2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Paola	daniel.herrera1@pruebasipt.com	$2a$11$mcCLqfMjnxJ5bKK4xo9fvOEqCZL7i5Q71h4vuomgqucMNfHhIOp0G	estudiante	active	f	\N	2025-10-10 18:26:11.265343-05	González Herrera	5-5622-1270	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:11.265343-05	\N	\N	\N	f
a970dd46-082a-4f45-8bd1-f887150de9d0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Pedro	daniel.herrera@pruebasipt.com	$2a$11$Qtt28f4toz0umm53D4UrFeLiZ.svVEK53QwwcqZGSxFW4erVvE3TS	estudiante	active	f	\N	2025-10-10 18:26:11.805319-05	Gómez Herrera	4-2010-1003	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:11.805319-05	\N	\N	\N	f
57a87153-287b-400e-adc0-fe360f53f799	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Luis	daniel.lopez@pruebasipt.com	$2a$11$d9/wYMX0lGaIM9zMGwMVs.I0meQ3vOoD6ws2j27Te8sDNUOaq4RG2	estudiante	active	f	\N	2025-10-10 18:26:12.341803-05	Jiménez López	1-5363-1208	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:12.341804-05	\N	\N	\N	f
197681ed-5ed9-4f2c-97d4-e92f3a13f1b6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Valeria	daniel.mendoza1@pruebasipt.com	$2a$11$1AAstDMEIghI7KXRa.YP9OTqJSmXgnf0Rs/hVHhW9jjIv9aECDdne	estudiante	active	f	\N	2025-10-10 18:26:12.910465-05	Martínez Mendoza	6-5926-1371	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:12.910466-05	\N	\N	\N	t
351f16fb-b5a8-44ba-ad24-5a01abf8f170	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Marta	daniel.mendoza@pruebasipt.com	$2a$11$UmQlO3CnN5nZlwUL8YRoc.JoZCA8X7eSlhpi/OKV6zLhqcqTKQrr2	estudiante	active	f	\N	2025-10-10 18:26:13.454762-05	Vargas Mendoza	5-2748-1252	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:13.454763-05	\N	\N	\N	f
d5ff762f-e8ec-41aa-9ff5-d222c3d2505a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Sofía	daniel.moreno@pruebasipt.com	$2a$11$kkIDj98w7qlOvpfl4sxKOuRCw2AUE3RecOBrfxme5/bEHUTLi/siG	estudiante	active	f	\N	2025-10-10 18:26:14.01484-05	Sánchez Moreno	10-6959-1210	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:14.014841-05	\N	\N	\N	f
fcee0e38-99c2-442f-9116-f23b092bcad6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Elena	daniel.rodriguez1@pruebasipt.com	$2a$11$iWQsFnL9p/nZ6hLlgQ9Lj.WH77c5DCir4JhKqs07QznyHeF1oldLC	estudiante	active	f	\N	2025-10-10 18:26:14.699966-05	López Rodríguez	6-9421-1206	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:14.699966-05	\N	\N	\N	f
3151da6f-45b3-44ec-9f8a-150603af2686	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Ricardo	daniel.rodriguez2@pruebasipt.com	$2a$11$fQNQ8983UM2WPYZ1IvBt/.e0CkshaShlTY1TzB/rnhyFiaTG8k3IS	estudiante	active	f	\N	2025-10-10 18:26:15.261337-05	Fernández Rodríguez	9-1458-1222	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:15.261338-05	\N	\N	\N	f
fefc0b80-697e-411b-84be-b00c77809d2f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Pedro	daniel.rodriguez@pruebasipt.com	$2a$11$7YMzYziAHEpKVdQdXLpgF.wkR5ZYdJGo3FaPgeEk4WFaBTOreE6kC	estudiante	active	f	\N	2025-10-10 18:26:15.80129-05	Fernández Rodríguez	6-4703-1024	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:15.801291-05	\N	\N	\N	f
6c294215-0f4e-426d-97fe-af1ed11e1409	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Juan	daniel.romero@pruebasipt.com	$2a$11$RWJ7yC5BpDS2sBGYefwnje1ojjMnts1n0yL33RxVAStz3ezgK8vJm	estudiante	active	f	\N	2025-10-10 18:26:16.373625-05	Vargas Romero	8-2077-1325	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:16.373625-05	\N	\N	\N	f
05e60ed1-414d-4f5b-b16a-65f92e561a13	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel Andrés	daniel.sanchez1@pruebasipt.com	$2a$11$DIGz.mJmDwU3t9su1rgTquaxztA6xeOamsomWmwgaKq2uz4efgbn.	estudiante	active	f	\N	2025-10-10 18:26:16.943593-05	Gómez Sánchez	7-7406-1163	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:16.943593-05	\N	\N	\N	f
93adcde6-ffd0-4d8e-be1c-1bf08389afcd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniel María	daniel.sanchez@pruebasipt.com	$2a$11$qm.BdRV.2M5oRb5/w5ThpeD/F5t82sl18jqp7wwtjbtVh6eoCed6u	estudiante	active	f	\N	2025-10-10 18:26:17.508305-05	Vargas Sánchez	9-2981-1036	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:17.508305-05	\N	\N	\N	f
91d30dc8-11c0-41ef-927c-5c7b3614945d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Sofía	diego.cordoba@pruebasipt.com	$2a$11$qVChgl4xYNd1nWU.Qnbn3ORIfcoQxRpTvPj1Uk4k1DQVdxn5TTLqa	estudiante	active	f	\N	2025-10-10 18:26:18.056412-05	Torres Córdoba	10-9861-1342	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:18.056412-05	\N	\N	\N	f
a2229450-0965-4193-ba63-1b085600d8c4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Valeria	diego.diaz@pruebasipt.com	$2a$11$kZL6MoqVH/KRH2ArtAMECOo8ibXq1uUOLbY89TPaa2R1gGz6K8.zm	estudiante	active	f	\N	2025-10-10 18:26:18.566872-05	Sánchez Díaz	8-3408-1388	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:18.566873-05	\N	\N	\N	f
cfbb36f5-e38c-446b-8624-a07fae229114	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Esteban	diego.fernandez@pruebasipt.com	$2a$11$.0nyKdrqg9Q6dwi7fre6E.Ko.3BKPzSGakir/AqRE6rRXe10ApEKS	estudiante	active	f	\N	2025-10-10 18:26:19.099781-05	Sánchez Fernández	3-2921-1153	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:19.099782-05	\N	\N	\N	f
60469364-649b-4749-a4cd-4f8ce2a63284	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Ana	diego.gomez@pruebasipt.com	$2a$11$wmwK/nNiVBZNpPU7v6mGu.HwYDpuwzbs/d02btxYdT4rAXcAavb5m	estudiante	active	f	\N	2025-10-10 18:26:19.638627-05	González Gómez	9-8261-1070	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:19.638627-05	\N	\N	\N	f
b12c121b-3b04-41a1-a7f7-e4a1dd45b5db	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego María	diego.mendoza1@pruebasipt.com	$2a$11$bowPKQ0G1QbV87.Xr7VI8u2n5d4n2Bg8z/mk2B0efniZkYfdAxs7O	estudiante	active	f	\N	2025-10-10 18:26:20.195871-05	Chávez Mendoza	6-8605-1251	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:20.195872-05	\N	\N	\N	t
00f178e5-5eee-4c8a-a547-2ca86a31cad7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Carmen	diego.mendoza@pruebasipt.com	$2a$11$gPEAx6DPq1rAJoxOj38e3OJrs/5UjHWY5FVG3Vb0hGgPgT6P4hfXS	estudiante	active	f	\N	2025-10-10 18:26:20.753641-05	Castillo Mendoza	4-2105-1062	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:20.753641-05	\N	\N	\N	f
9566a27a-6d11-490a-9e4f-b4268bd9afbf	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Daniel	diego.moreno@pruebasipt.com	$2a$11$.2lcXtjtikqy3CUL.9UDNudRZ8AaqYSJYN/jCUwIgLLy3xzRKIHhq	estudiante	active	f	\N	2025-10-10 18:26:21.303795-05	Torres Moreno	1-1673-1161	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:21.303795-05	\N	\N	\N	t
f909fcd5-647b-4dbf-a3d8-4caa8647f7bc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Valeria	diego.rodriguez1@pruebasipt.com	$2a$11$vk2ZjF...BHYlfasvRLmyO.ApjtIfUhA.HXloNf5GZtfdebXhvG06	estudiante	active	f	\N	2025-10-10 18:26:21.864615-05	Romero Rodríguez	3-3674-1327	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:21.864615-05	\N	\N	\N	f
a0f2f12c-ae92-4e9e-a839-b5bdfd9dbe04	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Esteban	diego.rodriguez@pruebasipt.com	$2a$11$pLBSocPxtN6VDey3E9ODFeOPIYXFKZeX5TKRjS1V2gxmjHf2j1o1.	estudiante	active	f	\N	2025-10-10 18:26:22.43307-05	Martínez Rodríguez	9-1464-1224	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:22.43307-05	\N	\N	\N	f
0c5b9185-29fd-4a27-bd52-12a44649170f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Ricardo	diego.romero@pruebasipt.com	$2a$11$ylTpzEOvnMUz3ATnclfqFu/PROAHgFIZ7Ub9SlXyBS8PxbfcRB7kW	estudiante	active	f	\N	2025-10-10 18:26:22.989809-05	Ríos Romero	1-6716-1175	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:22.989809-05	\N	\N	\N	f
394d14d2-8848-4ae8-8575-44b4ed88f594	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Diego Ana	diego.torres@pruebasipt.com	$2a$11$6M1MBDZXkMk5jVCtVGippO7HYsTNL9bDrc3ly1.JhzkU7a/AWlV5m	estudiante	active	f	\N	2025-10-10 18:26:23.564819-05	Moreno Torres	6-8313-1249	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:23.56482-05	\N	\N	\N	f
97049860-09e7-4986-8364-4e53bb9f28dc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Carmen	elena.cordoba1@pruebasipt.com	$2a$11$tPtLI1z276MQSMzzUoU0V.3bvaQ5hrJWqWadEll5LcQvJoB7AXqvK	estudiante	active	f	\N	2025-10-10 18:26:24.110946-05	Rodríguez Córdoba	3-3953-1197	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:24.110946-05	\N	\N	\N	t
2575362f-5c68-408c-951b-4b38e2e9dc2a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Valeria	elena.cordoba@pruebasipt.com	$2a$11$/hmvL28lZoxnC7Y10VbxZOvigLEQVRLXEes8ymSmuUWeajC3HxBoW	estudiante	active	f	\N	2025-10-10 18:26:24.673545-05	Pérez Córdoba	2-6480-1083	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:24.673545-05	\N	\N	\N	t
a499748e-3a63-477d-9042-2c9a1a9756b5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Pedro	elena.diaz@pruebasipt.com	$2a$11$0cbLIwJD4GxUrnLApVKGw.y9NnwCTX2JYCcLbTtdA7n.CCPSNGDBi	estudiante	active	f	\N	2025-10-10 18:26:25.23636-05	Herrera Díaz	10-6126-1095	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:25.23636-05	\N	\N	\N	t
0dfc31b6-95e2-49fd-b0c1-6234ed2538ca	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Camila	elena.gomez1@pruebasipt.com	$2a$11$8nbH4YxlvK4WS5.nACvteOHlI/mk2f5giuxBTGPWr949lB.PzAy.q	estudiante	active	f	\N	2025-10-10 18:26:25.792107-05	Córdoba Gómez	10-1355-1218	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:25.792107-05	\N	\N	\N	f
49491300-4816-49a7-b5da-a01fa46b2adf	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Sofía	elena.gomez2@pruebasipt.com	$2a$11$1AecB6lMIJPA18hAcz9zk.vNmMOidaYRS.K.Bx.RiUiiGhrIx/Ohu	estudiante	active	f	\N	2025-10-10 18:26:26.387153-05	Chávez Gómez	10-4023-1271	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:26.387153-05	\N	\N	\N	f
5577810e-8764-469f-9934-a37212a7774d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena María	elena.gomez3@pruebasipt.com	$2a$11$DDkBJjVkVu82i2gff4mmnO5UTALcIdlF3p244x4S54SjwgVZsFrau	estudiante	active	f	\N	2025-10-10 18:26:27.007035-05	Pérez Gómez	10-3238-1373	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:27.007036-05	\N	\N	\N	f
23c9a17c-dfb2-407c-a4a5-c7ebc56fa2da	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Luis	elena.gomez@pruebasipt.com	$2a$11$HGy/Kc5XAStT6M.yaVc9yug0VblLG1B5FOpSncJYBFObAUUl6kS3K	estudiante	active	f	\N	2025-10-10 18:26:27.576485-05	Gómez Gómez	9-3402-1018	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:27.576486-05	\N	\N	\N	f
2b584260-f73d-4979-b3e4-5f42089d6e8d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Camila	elena.gonzalez@pruebasipt.com	$2a$11$B8g8DtdFFeX6sTIZX9jW7OscFGe4V.C1RKhsXX6Lw2HkqI/23FV8O	estudiante	active	f	\N	2025-10-10 18:26:28.109931-05	Chávez González	8-4111-1247	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:28.109932-05	\N	\N	\N	f
18ebd144-7fcc-4d00-9c59-252f48acec5c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Ana	elena.herrera@pruebasipt.com	$2a$11$IYAMKz3a.fodQK9O8qdcguzdhCPoIcB1W30sGGLEMhysDlfDrthlW	estudiante	active	f	\N	2025-10-10 18:26:28.633373-05	Torres Herrera	2-2531-1141	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:28.633373-05	\N	\N	\N	f
d04e098c-f799-4e4a-bb84-28d3dad41071	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Esteban	elena.martinez@pruebasipt.com	$2a$11$ZSgH4fU/9DK.7pnFow1caeNg6cy84Zqe74bfMIFRle9Pl0g49JFtq	estudiante	active	f	\N	2025-10-10 18:26:29.17248-05	Chávez Martínez	2-9496-1092	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:29.172481-05	\N	\N	\N	f
6c269aed-96fa-4dcf-aab9-fc7fd870f387	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Juan	elena.mendoza@pruebasipt.com	$2a$11$HHXs03uFZVPJNotj.9AfmODFtEHRLEgSMYLFXlDFGMe2yECTBujBy	estudiante	active	f	\N	2025-10-10 18:26:29.764932-05	Pérez Mendoza	8-6498-1107	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:29.764932-05	\N	\N	\N	t
b940d46a-4f70-4a21-8b7c-932db040fd0c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Marta	elena.rodriguez@pruebasipt.com	$2a$11$BcSORibFrNY0wHYKR/NXHu7F86Oy6tDRCN2Qyz9YIUq/NT7Y1VtJm	estudiante	active	f	\N	2025-10-10 18:26:30.340584-05	Jiménez Rodríguez	3-6141-1122	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:30.340585-05	\N	\N	\N	f
abd7e8c9-31b9-444f-aca3-d40c562a79e7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Paola	elena.romero@pruebasipt.com	$2a$11$Ukg8GyKd1FxHnwy8FFX/Re0kMIFBKZxX6eJ539kYTsbccTmCUoefa	estudiante	active	f	\N	2025-10-10 18:26:30.902173-05	Díaz Romero	7-9255-1006	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:30.902173-05	\N	\N	\N	f
84ce7867-57c6-48d4-a908-c8cfd2688242	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Camila	elena.sanchez1@pruebasipt.com	$2a$11$vUfXrSH3TlIrF5YwY2Ig9.5t1LhuwBXawB3.0O6TyQsx.Z1aLUkdq	estudiante	active	f	\N	2025-10-10 18:26:31.499706-05	Pérez Sánchez	2-1576-1323	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:31.499706-05	\N	\N	\N	t
ef769bdd-9095-4765-9326-c2e1ae5eb54a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Luis	elena.sanchez@pruebasipt.com	$2a$11$K6r7m28jAcJr6IDwzrpglOSh3kGXUUCRgL0RxRPbSOmGglLOAGPXm	estudiante	active	f	\N	2025-10-10 18:26:32.083505-05	Rodríguez Sánchez	7-8697-1124	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:32.083505-05	\N	\N	\N	f
15f57479-ce5f-4740-9e42-3ff478f9eba8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Elena Luis	elena.vargas@pruebasipt.com	$2a$11$musDkI1qQN6iV/DNrTURJOMOX2W/N8oEQnx.6aj4tj1hXs3tth5qm	estudiante	active	f	\N	2025-10-10 18:26:32.671073-05	Rodríguez Vargas	7-6948-1177	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:32.671074-05	\N	\N	\N	f
c89eb03e-6c6d-43b9-9fa7-5f8d3cae968f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Juan	esteban.castillo1@pruebasipt.com	$2a$11$jN84eGubHuMWTmPe5vp5luUFWwYC6jKlfbL8ZUlYD94JlYqoP2Y.q	estudiante	active	f	\N	2025-10-10 18:26:33.257399-05	Martínez Castillo	7-5222-1354	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:33.257399-05	\N	\N	\N	f
a3345544-6389-4352-8ee4-23d21d871755	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Valeria	esteban.castillo@pruebasipt.com	$2a$11$UCZPaHjpRtDw70swH9.MwO0Ak0Yy4MWW/imEwZHNzb7Pq./5e2Gpm	estudiante	active	f	\N	2025-10-10 18:26:33.840954-05	Castillo Castillo	8-7914-1031	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:33.840954-05	\N	\N	\N	f
a65a6166-7814-4aba-8133-009b2a2bf870	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Diego	esteban.cordoba@pruebasipt.com	$2a$11$NBhJm1cahqUDmNgZoS9Oe.51rWv88nCsRSU4WVm7/5SqVGjIuckMq	estudiante	active	f	\N	2025-10-10 18:26:34.427166-05	Gómez Córdoba	8-5711-1054	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:34.427166-05	\N	\N	\N	f
dec57b2d-8488-4d9d-9922-bbf28cc43f56	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Luis	esteban.diaz1@pruebasipt.com	$2a$11$NUcVOmdfzFkte27LDtNzc.s3Zoo1MaJ0f8IimdXZkLzBuQBG7x.EO	estudiante	active	f	\N	2025-10-10 18:26:35.00698-05	Rodríguez Díaz	6-2761-1143	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:35.00698-05	\N	\N	\N	t
76f605c6-f730-4d16-939f-bd82c7fdd8c6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Carlos	esteban.diaz@pruebasipt.com	$2a$11$/fQcfr3XrPr6BVzCN1BM1uuHlD3jxZCqPpAi4r8S/8E8kAXXAxHuu	estudiante	active	f	\N	2025-10-10 18:26:35.600529-05	Rodríguez Díaz	9-7278-1127	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:35.600529-05	\N	\N	\N	f
6d056566-7b9b-4f53-bb1b-9136d27f59a5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban José	esteban.gonzalez@pruebasipt.com	$2a$11$eKiMhs.ooxWizgTAlnaA0.Zv3J4x/0a8w48BozZbJd9fBLVw.bMfW	estudiante	active	f	\N	2025-10-10 18:26:36.17736-05	Sánchez González	3-1946-1355	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:36.17736-05	\N	\N	\N	f
b64e21f6-a598-4b0d-9508-73af614f7331	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban José	esteban.herrera@pruebasipt.com	$2a$11$QAaRH3J6agqc/BgVUWK8juOGnuJz/LlcjVl2D2OItNXqtDkkx4C2K	estudiante	active	f	\N	2025-10-10 18:26:36.776963-05	González Herrera	7-2883-1078	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:36.776964-05	\N	\N	\N	f
953804ef-ab28-414a-adbd-7f1d92a13fae	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Ricardo	esteban.jimenez1@pruebasipt.com	$2a$11$nIKDLCOKqxR3Z/0fqCcNGeHwLPAUQvaNDdOoWKPNyPXnFEGiYibtG	estudiante	active	f	\N	2025-10-10 18:26:37.382238-05	López Jiménez	5-8962-1077	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:37.382238-05	\N	\N	\N	t
7914a9e8-8e52-46fe-9297-879733772af1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Diego	esteban.jimenez@pruebasipt.com	$2a$11$3kdlVELvBo.y5ggtvIGz...AbD.gzrKt6gcre2V0G0fFSBXMNyLDm	estudiante	active	f	\N	2025-10-10 18:26:37.981061-05	Romero Jiménez	4-2917-1073	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:37.981062-05	\N	\N	\N	f
4f332e1f-9ad6-440f-a28c-f7f93d71ad5b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Andrés	esteban.lopez@pruebasipt.com	$2a$11$B85aLs54IJBfL0wysaRx6unyoqfSM.4e54hEvduMlWTJIMQEm8F5.	estudiante	active	f	\N	2025-10-10 18:26:38.515831-05	Mendoza López	2-8868-1240	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:38.515831-05	\N	\N	\N	f
73cbef6e-6faf-48f6-94cb-61c8f2632322	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Pedro	esteban.martinez@pruebasipt.com	$2a$11$IBATLmjZgrhX0LiYczK9eOVz5In5sXP//R6PKwnAzE0.X5a8VL9iq	estudiante	active	f	\N	2025-10-10 18:26:39.071191-05	Córdoba Martínez	10-8471-1152	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:39.071192-05	\N	\N	\N	f
41d60db3-c8cf-4f81-88ca-140a7b80d8ae	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Carmen	esteban.mendoza1@pruebasipt.com	$2a$11$NwREmfROvQHeY89mSZaDQe3Xn8knUkpobOqIf6yRRachQHJr0Fmwi	estudiante	active	f	\N	2025-10-10 18:26:39.640691-05	Ríos Mendoza	9-6807-1275	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:39.640692-05	\N	\N	\N	t
97b86396-e4d0-4468-a9b0-024e7c7c3b44	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Marta	esteban.mendoza2@pruebasipt.com	$2a$11$k.NyTQGqfMKPBO2ugGCcxuW3WDloWfdjWVV4VPS9gtHgxmxRNUgHm	estudiante	active	f	\N	2025-10-10 18:26:40.175882-05	Herrera Mendoza	9-4851-1289	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:40.175882-05	\N	\N	\N	f
352a4e5c-c260-4161-9e77-fb00ad1b26d5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Julio	esteban.mendoza3@pruebasipt.com	$2a$11$W1sANGXGwIdcqEZOv5K18.PNiPAFkxTBcnYGEHK1gAd7iWOerOEm.	estudiante	active	f	\N	2025-10-10 18:26:40.721455-05	Martínez Mendoza	2-2006-1294	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:40.721456-05	\N	\N	\N	f
8face643-2dc4-40b1-8573-4f7035156be7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Andrés	esteban.mendoza@pruebasipt.com	$2a$11$NLgfZmWVYH/5jUBqb2MxMOfsJPS1OeDkrcLDeNwiH16M2lxbqe3FO	estudiante	active	f	\N	2025-10-10 18:26:41.261907-05	Pérez Mendoza	7-7267-1182	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:41.261907-05	\N	\N	\N	f
cf61c3b1-5ab9-4758-9e7c-a6880cf4f765	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Sofía	esteban.moreno1@pruebasipt.com	$2a$11$oK76sBua8pextR7vbmeuVOUTvy760jybTXA2Jh14IL3zgrHgwfG3a	estudiante	active	f	\N	2025-10-10 18:26:41.823637-05	Herrera Moreno	2-2758-1046	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:41.823637-05	\N	\N	\N	f
62f3fb90-72db-498e-8d49-377b1c144dda	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban José	esteban.moreno@pruebasipt.com	$2a$11$cXHORKnOdtfL8Rx2f0du8evAI8WHRaHB9hcd3jxB3y6xhE/VjeLlS	estudiante	active	f	\N	2025-10-10 18:26:42.393288-05	Vargas Moreno	4-3104-1007	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:42.393289-05	\N	\N	\N	f
fc2ad202-eccc-473e-8e25-cecbb4896793	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Carlos	esteban.perez1@pruebasipt.com	$2a$11$FBUZYCup4Z4f19blBXBhaOieL9winCtCmHNFfIhmD9s2itm/Zzr/y	estudiante	active	f	\N	2025-10-10 18:26:42.951697-05	Jiménez Pérez	3-7499-1202	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:42.951697-05	\N	\N	\N	f
c205da2e-65e7-497a-8060-6b2816314d5b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Luis	esteban.perez@pruebasipt.com	$2a$11$1C8Nts8Twl9emgQImWa8Ze2e5iNw8u6uQtG1Y7xGJxo3lQVO9SXUi	estudiante	active	f	\N	2025-10-10 18:26:43.502715-05	Castillo Pérez	9-2921-1093	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:43.502715-05	\N	\N	\N	f
2724570a-d845-487d-8ab9-54be2b9ed547	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Paola	esteban.rios1@pruebasipt.com	$2a$11$4eNNYG8htRSgRnEMC0KhtO2I7GLZFVVCiqMdGWvVCYNrl0ZVGexNe	estudiante	active	f	\N	2025-10-10 18:26:44.059577-05	Díaz Ríos	7-6288-1326	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:44.059577-05	\N	\N	\N	f
9f5a0be8-97f6-4827-8672-0949cdc59c36	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Valeria	esteban.rios@pruebasipt.com	$2a$11$kRW.qg7kb4p7TbShRNKOeuLmpD1Y3OarGJQedlC8FagyRz1Gb.5Le	estudiante	active	f	\N	2025-10-10 18:26:44.619147-05	González Ríos	6-5513-1050	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:44.619148-05	\N	\N	\N	f
36cf8945-2a34-4d32-98fa-03e5a76e0e59	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Andrés	esteban.rodriguez@pruebasipt.com	$2a$11$m1c.qQx3MkM8/5Y7jccwvOt.3VKyTva41xoL8AU3MzPZzmc343KuW	estudiante	active	f	\N	2025-10-10 18:26:45.177419-05	Romero Rodríguez	2-3157-1235	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:45.17742-05	\N	\N	\N	f
ab1986bc-dbae-4e72-ad75-f41ee51ba734	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Pedro	esteban.romero1@pruebasipt.com	$2a$11$Z6MmTGRO1MtYB9hNgj.mweHvHLkItNiMOOMNjoVfFn455ByGoBXTC	estudiante	active	f	\N	2025-10-10 18:26:45.73753-05	Rodríguez Romero	4-8875-1106	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:45.73753-05	\N	\N	\N	f
e2f5ff94-5ff2-4413-932e-6876af4ad872	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban José	esteban.romero2@pruebasipt.com	$2a$11$XqhsWJxmiFnS3n1kC0zRY.ouJCzI5e/uUcdSZ5cUErftin3pWGfwi	estudiante	active	f	\N	2025-10-10 18:26:46.305792-05	Pérez Romero	7-7666-1246	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:46.305793-05	\N	\N	\N	f
e7744c87-b37d-4010-ab99-472d19a79ce4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Carmen	esteban.romero3@pruebasipt.com	$2a$11$h0vTJ/Je.BSYJgy5ASfZEumivjIWquJ1do4U.HkoieouirokVo6Qe	estudiante	active	f	\N	2025-10-10 18:26:46.878769-05	Chávez Romero	1-2453-1264	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:46.878769-05	\N	\N	\N	f
b9e2f09c-9bf4-4022-bcf7-1f0af1a0e738	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Ricardo	esteban.romero@pruebasipt.com	$2a$11$CjIcCPUzKlJaIh/BJYsasOK2Ksnn/BjoUo.t6aYXo0msq53Gz8Mgm	estudiante	active	f	\N	2025-10-10 18:26:47.439339-05	Jiménez Romero	8-3659-1001	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:47.439339-05	\N	\N	\N	f
61690be7-fa15-47eb-81c6-4b2b4a8142ec	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Luis	esteban.torres1@pruebasipt.com	$2a$11$cyWjcs/9iWHU8Cbr/N7Jf.RV9si9BUAwXGNT/U4ZERcVcw06MVFwy	estudiante	active	f	\N	2025-10-10 18:26:48.002843-05	Martínez Torres	8-1800-1381	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:48.002843-05	\N	\N	\N	f
f876b81a-dacf-4c5d-92d7-4aaaa424065a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Pedro	esteban.torres@pruebasipt.com	$2a$11$bvz0Xna.2dNWJeqStqBXWeYvBtJlISqGq6Y1XibqJiPpzYLjOxe76	estudiante	active	f	\N	2025-10-10 18:26:48.56782-05	Vargas Torres	1-1662-1259	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:48.56782-05	\N	\N	\N	f
f941d8c8-4517-43b4-a714-00446c443df7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Luis	esteban.vargas1@pruebasipt.com	$2a$11$Ag09haO8Cm3gnNENOt0eKOzsWLuJOmVpuIzNDd2ExP9jh1k7r8T96	estudiante	active	f	\N	2025-10-10 18:26:49.126457-05	Romero Vargas	2-9477-1348	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:49.126458-05	\N	\N	\N	f
e7bae2ad-5ce8-4189-871f-c547f1d16b3f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esteban Pedro	esteban.vargas@pruebasipt.com	$2a$11$NTH2JJ5uPhjGy2Ya4zJHD.xuxC7w9xz5ji361O1EAiDL9yhGS7yPS	estudiante	active	f	\N	2025-10-10 18:26:49.701622-05	Moreno Vargas	3-1899-1027	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:49.701622-05	\N	\N	\N	f
e8fef0b3-641c-47bb-840d-0035fcfd58a4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Camila	jose.diaz@pruebasipt.com	$2a$11$NqEQ6m9OH5.mgqbDYrTHiO2ihUhD7/1kh8ZcL6gh55wmZ/iqmcMVS	estudiante	active	f	\N	2025-10-10 18:26:50.270681-05	Pérez Díaz	5-7788-1130	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:50.270681-05	\N	\N	\N	f
578a5431-eefe-456f-9e45-f971fe1e3078	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Elena	jose.gomez@pruebasipt.com	$2a$11$8oDf1O8SLZn.H7rMk0G06uquorNvwUcP996RZQbVOG5yiSDDBBNba	estudiante	active	f	\N	2025-10-10 18:26:50.835672-05	Herrera Gómez	6-7210-1135	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:50.835672-05	\N	\N	\N	f
08d1d83d-0ac1-4feb-bb42-a1cb737ddc56	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Julio	jose.herrera1@pruebasipt.com	$2a$11$H0kmEj7OJkQ/axKPKdhznOszIe4MtHaGyv2xV7I5UekMilP0795Xe	estudiante	active	f	\N	2025-10-10 18:26:51.401696-05	Díaz Herrera	3-6394-1232	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:51.401696-05	\N	\N	\N	f
905d98cf-8218-4bdc-a220-68c699c2a99f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Camila	jose.herrera@pruebasipt.com	$2a$11$Iucl8X/lU9RvTaTHBzkmgO24ZnLFTtK8bcwT8a38tb8AXmJ6UvcG.	estudiante	active	f	\N	2025-10-10 18:26:51.985127-05	Fernández Herrera	8-4916-1199	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:51.985127-05	\N	\N	\N	f
d3f85a84-c943-4c3f-ab83-990d5a5acb38	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Marta	jose.jimenez@pruebasipt.com	$2a$11$qLd8uqmBr6czxuzZmUVHs.Bp5lbUYCJi0gQnmvGtG5LctU8eDrka.	estudiante	active	f	\N	2025-10-10 18:26:52.569117-05	Chávez Jiménez	5-8904-1311	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:52.569117-05	\N	\N	\N	t
90fbd08f-4583-4cf7-adbf-146fd54f1381	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José María	jose.mendoza1@pruebasipt.com	$2a$11$Cf/OlX.9k0A9wVZn7uOkROeKt/hBEsKmcT/x/GWVpnI662/oWwxTS	estudiante	active	f	\N	2025-10-10 18:26:53.152306-05	Fernández Mendoza	8-9342-1198	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:53.152307-05	\N	\N	\N	f
933ca263-fc10-44dc-8469-5ef14210dfd3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Valeria	jose.mendoza2@pruebasipt.com	$2a$11$ccRIAmgtioB8gPQaeatQl.mYNcFAovOvWuxToSElnpafl0p/t/aTq	estudiante	active	f	\N	2025-10-10 18:26:53.721042-05	Jiménez Mendoza	8-2199-1265	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:53.721042-05	\N	\N	\N	f
96433773-0735-495f-8aa8-769141604f54	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Carmen	jose.mendoza@pruebasipt.com	$2a$11$QBUAH3KZk16zkd216gDAKeQVQoSc6W7UhojnqaWv4EgDU7ZnkQ8dK	estudiante	active	f	\N	2025-10-10 18:26:54.284053-05	Ríos Mendoza	3-5819-1126	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:54.284053-05	\N	\N	\N	f
807d4de6-0dad-439a-ba4a-a91c4abf7ed3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José María	jose.perez@pruebasipt.com	$2a$11$feYAgKZLug5J9pKO7bmP8uRpg2ULGtbfisDxk/W78BbISMizb2J2e	estudiante	active	f	\N	2025-10-10 18:26:54.827571-05	Moreno Pérez	5-3681-1287	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:54.827571-05	\N	\N	\N	t
95d58772-8f08-437e-b9a1-e6322c9076ad	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Sofía	jose.rios1@pruebasipt.com	$2a$11$8oFgFS9fBm7smoCEFZSajeTltx0tFQ5Uhy0akKPCRZ/LvGD2bNK.a	estudiante	active	f	\N	2025-10-10 18:26:55.375702-05	González Ríos	7-6733-1194	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:55.375702-05	\N	\N	\N	f
855fded0-9310-497b-873d-c666d895c43a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Esteban	jose.rios2@pruebasipt.com	$2a$11$UjW1IaUjQI7OtU58NMjb3Oq5UQANbRqOp.tvKUDI9IN68HaaBr3x2	estudiante	active	f	\N	2025-10-10 18:26:55.952848-05	Castillo Ríos	2-8968-1285	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:55.952848-05	\N	\N	\N	f
dc16dde0-552d-4be6-91ba-11a3952b34c9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Juan	jose.rios@pruebasipt.com	$2a$11$mqmwhG7io8T/RO/y2hdZiu9MZhl5c3L0eJCx2DjC7koL0w1ONIGJe	estudiante	active	f	\N	2025-10-10 18:26:56.51656-05	Pérez Ríos	9-5786-1184	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:56.51656-05	\N	\N	\N	f
0dfb7afa-9cd5-4b63-838b-f3823a561392	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Camila	jose.rodriguez@pruebasipt.com	$2a$11$Kc2iXQ.VCNempKpOVoXPDe/S8VvwfA1.qLrwC1bbrqmHM7SQES.mC	estudiante	active	f	\N	2025-10-10 18:26:57.087358-05	Fernández Rodríguez	1-4956-1181	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:57.087358-05	\N	\N	\N	f
78557a2b-8341-4bcd-b193-00dc015f7f05	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Elena	jose.romero1@pruebasipt.com	$2a$11$v12LE92Z2Buswee5urBMyu1SWiSC8597BE7mm7jrGzJ2qaEC3q6fG	estudiante	active	f	\N	2025-10-10 18:26:57.622621-05	González Romero	6-3257-1195	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:57.622622-05	\N	\N	\N	f
14b1b07d-8d18-4222-b704-671e61ec2436	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Diego	jose.romero2@pruebasipt.com	$2a$11$Vz2IOEamhOLvnP2uyqR6a.I.Fi69cZ9Xj/wzanQnGtIHFk.WIwp82	estudiante	active	f	\N	2025-10-10 18:26:58.180452-05	González Romero	1-8005-1319	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:58.180452-05	\N	\N	\N	f
f46ffd37-466b-477a-b68c-3f792ae0c524	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Ana	jose.romero@pruebasipt.com	$2a$11$Dx6Agi6Vw4MSgAY5CrRu.OgYCz5.6ajJMWbjSzIx6gHiBOL/svF42	estudiante	active	f	\N	2025-10-10 18:26:58.745349-05	Torres Romero	4-4198-1087	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:58.74535-05	\N	\N	\N	f
993bcfb4-fb9d-4fa9-9591-33a9e3f4c2bb	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Esteban	jose.sanchez@pruebasipt.com	$2a$11$uY5/7EOi32TdCENEsZe/COIgui0ZgFJcXjaaKa3s2YE1fQJ7mTfX2	estudiante	active	f	\N	2025-10-10 18:26:59.304599-05	Díaz Sánchez	1-3269-1040	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:59.304599-05	\N	\N	\N	f
b7cd69e1-5aa3-4692-9b9e-790cb1baee98	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Camila	jose.torres@pruebasipt.com	$2a$11$glU5Jq2BP32E/o6WCfS1t.d551gJLZ59AmRJtazxFvzwrA6q.Dtgq	estudiante	active	f	\N	2025-10-10 18:26:59.880067-05	Córdoba Torres	3-4867-1307	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:26:59.880068-05	\N	\N	\N	f
e0c2c8a5-7d98-4987-9bd5-9f4c5d45a154	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	José Valeria	jose.vargas@pruebasipt.com	$2a$11$AKbfqBe3TZ1MtuWQWPSr5OonNcZJYmPE7pWsjSeQzfG5aIL./.xJ6	estudiante	active	f	\N	2025-10-10 18:27:00.433756-05	Fernández Vargas	6-3080-1145	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:00.433757-05	\N	\N	\N	f
7f64631b-29df-479e-a968-dc266723d37e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Sofía	juan.cordoba1@pruebasipt.com	$2a$11$XD/aXlpUsA9.L5dEHbdjKeOaK80W8Wg9LTkdDyxeMZvhhuedyU.3y	estudiante	active	f	\N	2025-10-10 18:27:01.005598-05	Torres Córdoba	4-3369-1361	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:01.005599-05	\N	\N	\N	f
bb212762-bd19-4ca1-ab3f-110e7d7f8856	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Juan	juan.cordoba@pruebasipt.com	$2a$11$731gHDd7PS2SsF0ONp0TDesIHepxYnkSYk5KcJCqZtn31Odn2lGde	estudiante	active	f	\N	2025-10-10 18:27:01.582506-05	Herrera Córdoba	4-2318-1353	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:01.582506-05	\N	\N	\N	t
bb162f50-7f00-4c42-9208-523cd007f3d2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Marta	juan.diaz1@pruebasipt.com	$2a$11$YbUGlJZK9i.SQQSneBJz8.S3nBm5wTe7bCzKJC/w/OqQTKceVEfMS	estudiante	active	f	\N	2025-10-10 18:27:02.146403-05	Castillo Díaz	9-3054-1377	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:02.146403-05	\N	\N	\N	t
21f49c80-1916-418d-b9cc-b736e88201b9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Carmen	juan.diaz@pruebasipt.com	$2a$11$T5E2Pcy8uK01PIgk1kkVNupkK.jAjrx.30YQq9tIiK1iQjXuusKXm	estudiante	active	f	\N	2025-10-10 18:27:02.712387-05	González Díaz	1-4200-1149	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:02.712387-05	\N	\N	\N	t
f1cee740-c8e2-46ac-957d-03b8b0fde7a8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Andrés	juan.fernandez@pruebasipt.com	$2a$11$Rc7Rix2wCn3/vNDP6tPo9O79ypYHZ76DXbJ4J8Ad8MXXTGqwP2eGO	estudiante	active	f	\N	2025-10-10 18:27:03.233717-05	Martínez Fernández	1-8318-1103	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:03.233717-05	\N	\N	\N	f
21021cf3-216e-4196-a283-77dac9c46511	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Daniel	juan.gomez@pruebasipt.com	$2a$11$nSxL0brbvxHoyKZ4bFawX.waP6P5VUnpH7yRenT9c5bLM1boJfYZ.	estudiante	active	f	\N	2025-10-10 18:27:03.792334-05	López Gómez	1-9246-1136	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:03.792334-05	\N	\N	\N	f
6672c810-ead7-4f84-8808-005dd893f9b5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Andrés	juan.gonzalez@pruebasipt.com	$2a$11$d6A4AWrG7LX91JcYqEw1auD9lMHVinIBbvq7fo4oqaHuciIOuwdoq	estudiante	active	f	\N	2025-10-10 18:27:04.381132-05	Romero González	6-2371-1321	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:04.381133-05	\N	\N	\N	f
cdbac3d0-038f-4ed1-9e75-6bac24201eb9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Daniel	juan.herrera@pruebasipt.com	$2a$11$JC30Z0Qm.eKRxMYBd/UZ9.QX2wvMmCutXW0XSvm1EHUaUlrKeLQAi	estudiante	active	f	\N	2025-10-10 18:27:04.946417-05	Mendoza Herrera	7-2734-1075	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:04.946417-05	\N	\N	\N	f
2056531c-a2b8-4130-94bd-fa36da64b516	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Sofía	juan.jimenez@pruebasipt.com	$2a$11$F7D1JjJBVg0xp4CQOOmwOOSWgWUH4QMmTknOOF09EcjJUaI//kBAO	estudiante	active	f	\N	2025-10-10 18:27:05.518063-05	Herrera Jiménez	1-6916-1180	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:05.518064-05	\N	\N	\N	f
f55d7df6-8cbe-4610-8adc-f1fededc8dad	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan José	juan.lopez1@pruebasipt.com	$2a$11$w/Yp4HJaKGWunbV7FNXv7.Cbpf7QpTzuiZS6Rcs9D.l7xfY//0rCW	estudiante	active	f	\N	2025-10-10 18:27:06.091127-05	Chávez López	7-6346-1147	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:06.091128-05	\N	\N	\N	f
84073095-07a1-4dd8-aea4-611fe5121760	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Marta	juan.lopez2@pruebasipt.com	$2a$11$a4V1hase2dxwo08wewNBqu/mL.dODzFZCb5sgGzef.tYHniWScctK	estudiante	active	f	\N	2025-10-10 18:27:06.668252-05	Romero López	2-8108-1223	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:06.668252-05	\N	\N	\N	f
a6cb93b7-7b92-4e06-b0cd-47529861b744	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Elena	juan.lopez@pruebasipt.com	$2a$11$ABRNz/4/pRxuzELMO2by7elAi3dXOAh6kVWNScSySUb.Jj0OR9fTq	estudiante	active	f	\N	2025-10-10 18:27:07.243651-05	Gómez López	10-2225-1119	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:07.243651-05	\N	\N	\N	t
b97a3f36-c18e-42f9-8f2a-57becd595f6b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Ana	juan.moreno@pruebasipt.com	$2a$11$ZAcyfKEc10ScVdaQcMLpue0bJ6sIX18KTSwGUj.uw4yCs/FeVTsRq	estudiante	active	f	\N	2025-10-10 18:27:07.809168-05	Córdoba Moreno	9-8489-1196	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:07.809169-05	\N	\N	\N	f
d87e2d83-ab84-4ad3-9015-fceb7bdff402	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Daniel	juan.perez@pruebasipt.com	$2a$11$tDv7uqDKKDWJRuKV8ZOy6e/85P/gFI57YD4oni/UUQ8Z72C.FhYzG	estudiante	active	f	\N	2025-10-10 18:27:08.34058-05	López Pérez	9-9128-1281	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:08.34058-05	\N	\N	\N	t
c431bbc7-cc3f-495e-9034-e54456f3c145	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Diego	juan.rios@pruebasipt.com	$2a$11$ACu3A3.V/uZEqDmXvDrc5.gQpH1f2uPBmamc1L1Zklds2CU5/s6yG	estudiante	active	f	\N	2025-10-10 18:27:08.912661-05	Pérez Ríos	8-8721-1079	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:08.912661-05	\N	\N	\N	f
e9664e46-5c4b-4d6c-8193-dd928137df3e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan José	juan.rodriguez@pruebasipt.com	$2a$11$AcxlZ3/l.6oJVjqNiBjJseEP7lWzZpNWuGlgpgi78H2Vg5szlvOQi	estudiante	active	f	\N	2025-10-10 18:27:09.47686-05	Moreno Rodríguez	3-5390-1059	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:09.47686-05	\N	\N	\N	t
60f7dc9f-6244-4f23-80b1-4372b0cea625	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Carmen	juan.sanchez1@pruebasipt.com	$2a$11$76zYJ6.YA.TSKMEgxopbC.p59yTAETk6joj2egD2hUTFFfMA.eBcS	estudiante	active	f	\N	2025-10-10 18:27:10.050695-05	Pérez Sánchez	8-7789-1171	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:10.050696-05	\N	\N	\N	f
f5166fa2-2d58-44b0-b430-8a8122110d62	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Diego	juan.sanchez@pruebasipt.com	$2a$11$scN9z6Bj7JpFxseVnGagw.RirrSWIg3BkftOZWvw2Ka0ToB9MYkpW	estudiante	active	f	\N	2025-10-10 18:27:10.588515-05	Herrera Sánchez	5-4171-1066	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:10.588515-05	\N	\N	\N	f
339ca863-b90c-46bb-9c97-810db9bd8080	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Camila	juan.torres@pruebasipt.com	$2a$11$kl.1NXxzwScX3ZMIdwJ8PedkqJ2HA4BOQmdZ3aewny4CkhdQHB2a2	estudiante	active	f	\N	2025-10-10 18:27:11.154292-05	Chávez Torres	5-3074-1261	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:11.154293-05	\N	\N	\N	f
250585a8-00a3-42e0-a2d2-8df03dd9b6c3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio María	julio.castillo@pruebasipt.com	$2a$11$KAcTr2QMteKvkkOfSLDKNuDKzs0RuiBxB6z9f2ybQl42HKXhgeVZu	estudiante	active	f	\N	2025-10-10 18:27:11.718644-05	Sánchez Castillo	9-1948-1151	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:11.718644-05	\N	\N	\N	f
5fe2bf3f-41f3-44c1-bd2f-da73b0492563	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Juan	julio.chavez@pruebasipt.com	$2a$11$f1MfrvJJlDbJg81y0e9QRuC/jFwJW1lW3Z5eNEwyFXpAj2lpZHZNe	estudiante	active	f	\N	2025-10-10 18:27:12.253894-05	López Chávez	2-7514-1160	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:12.253895-05	\N	\N	\N	f
1390a165-d4da-4fd9-93d6-6a1c06024c92	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Elena	julio.diaz1@pruebasipt.com	$2a$11$sALyYetMwbWWVk1vn4ictuDxOvZRY/ssGGzEWCcSmZfFfcUWf3lEW	estudiante	active	f	\N	2025-10-10 18:27:12.826597-05	Castillo Díaz	5-4496-1349	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:12.826597-05	\N	\N	\N	f
1c787e73-1851-4239-85e1-4866388364fe	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Camila	julio.diaz@pruebasipt.com	$2a$11$Mjd6FnG4ytgrqwaNW5UKrOdza7uPO8scpAvI1KCN4.l16UHss8D0.	estudiante	active	f	\N	2025-10-10 18:27:13.388364-05	Mendoza Díaz	5-8464-1029	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:13.388364-05	\N	\N	\N	t
91df104f-373b-42bf-9846-45bec2a4433c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Paola	julio.fernandez@pruebasipt.com	$2a$11$JocTXARICZiOVIACWjJXIuj2WnQM8GSxwsrs2rvglrwq3KMU9ki0e	estudiante	active	f	\N	2025-10-10 18:27:13.953954-05	Jiménez Fernández	5-2868-1384	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:13.953954-05	\N	\N	\N	f
153d5614-e732-41aa-ae26-e62ac5f40799	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Esteban	julio.gomez@pruebasipt.com	$2a$11$/B7wR4ZUJzdmaK0BPYcureDUmlbpfKMYbrMIDM67SyygTS.oMpu7.	estudiante	active	f	\N	2025-10-10 18:27:14.535293-05	Ríos Gómez	5-7725-1296	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:14.535294-05	\N	\N	\N	f
0c44f3f8-7e2e-471e-b3db-106d7f356ae8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Carmen	julio.gonzalez@pruebasipt.com	$2a$11$HOEGw7xNhH46JQcpDy90EOkKQEi0hPwLljpidxBsRc6zjn.5.WIuS	estudiante	active	f	\N	2025-10-10 18:27:15.077266-05	López González	10-9027-1233	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:15.077266-05	\N	\N	\N	t
93dc72b7-0603-405e-b244-a6b2d8cb9308	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Paola	julio.herrera@pruebasipt.com	$2a$11$pk4K.odSJcBNEFPMY1fpnewbxnJ9UlYUwlRuBrRFRR7YHwbMwxIlu	estudiante	active	f	\N	2025-10-10 18:27:15.637665-05	Ríos Herrera	5-3352-1016	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:15.637665-05	\N	\N	\N	f
b646c8bc-7062-4136-836a-2276b039ce84	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Julio	julio.lopez@pruebasipt.com	$2a$11$uP46L3qEAlbOe3USnSYHqei1TGVNVxQprZn9XQebEtdCDxxDDlfGK	estudiante	active	f	\N	2025-10-10 18:27:16.195868-05	Rodríguez López	1-2940-1047	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:16.195869-05	\N	\N	\N	t
605fe520-84db-4397-bb3d-f16b603516be	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Andrés	julio.perez@pruebasipt.com	$2a$11$RXQBc2n1uIeOfuJaxjL/h.RUnCIz2Bl32kQSXgKHBnu9E7G.EaEuq	estudiante	active	f	\N	2025-10-10 18:27:16.773708-05	Fernández Pérez	5-7496-1309	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:16.773708-05	\N	\N	\N	f
4300ba30-d315-4cdc-b4e6-b0c68f9d76cd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Luis	julio.romero1@pruebasipt.com	$2a$11$1AvU6Yeia8wJm0HDsEWXUeQkVx4I3yxm9m2UjPJPL7k89Qm4jE3f.	estudiante	active	f	\N	2025-10-10 18:27:17.365365-05	Torres Romero	5-6937-1267	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:17.365366-05	\N	\N	\N	f
4f4bd828-7895-438b-9827-53d1e12d116d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Marta	julio.romero@pruebasipt.com	$2a$11$pN2UYW8qUea8Ot8vFGG7xOfSHHhYIYWUkjtTEJ0NnOUwGuQjopRP.	estudiante	active	f	\N	2025-10-10 18:27:17.944617-05	Pérez Romero	5-8863-1154	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:17.944618-05	\N	\N	\N	f
91b8453c-1216-457a-9917-f6f40acb0880	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julio Elena	julio.vargas@pruebasipt.com	$2a$11$HnMt./Av91FLdE7SCAkIEekLdT8dUMnybuTe62lXuW.gGQxh8Arze	estudiante	active	f	\N	2025-10-10 18:27:18.514482-05	Rodríguez Vargas	10-1987-1214	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:18.514482-05	\N	\N	\N	f
3a7a291f-099f-4ece-9075-22d1d633a4fd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Paola	luis.castillo@pruebasipt.com	$2a$11$0AmcXAgQTZUVQeHc2H3RMOMi8LFqUMMqotupMuLsmdNogLshYdy0O	estudiante	active	f	\N	2025-10-10 18:27:19.101224-05	López Castillo	8-6580-1064	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:19.101224-05	\N	\N	\N	f
66db6165-4b24-4cb5-a22c-7d7f2a4660b0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Ricardo	luis.fernandez1@pruebasipt.com	$2a$11$5AUKnkCzIZdp4iBsBC6SauGMEA4wbkVsyqFZ8M8lalYEVsUBuhroO	estudiante	active	f	\N	2025-10-10 18:27:19.658928-05	Jiménez Fernández	4-3732-1273	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:19.658928-05	\N	\N	\N	f
fb4c9ec3-7004-40a1-b2bf-3f71b443b47d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Valeria	luis.fernandez@pruebasipt.com	$2a$11$ZDp4i3ZLoP1kxjM5DeMQz.hQY3NwKPn22Se2MTYnW0R/H.h8KVjJu	estudiante	active	f	\N	2025-10-10 18:27:20.220648-05	Díaz Fernández	7-4972-1030	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:20.220649-05	\N	\N	\N	f
fff02275-ab05-4195-a963-1a1209d00bd8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Marta	luis.gonzalez@pruebasipt.com	$2a$11$qf3JCXetgCXN97SRB5mOw.ARMZf0AhGDHgdRjXmcddNEWs9NOzldC	estudiante	active	f	\N	2025-10-10 18:27:20.798798-05	Martínez González	3-7049-1084	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:20.798798-05	\N	\N	\N	f
d982e836-08b4-41fa-8ca9-67012b3e8d19	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Elena	luis.herrera@pruebasipt.com	$2a$11$9oI9VKk59l2dPUbJ1KWdSuAWi7ZHwbg1Nq2J7Le/IsWQyTXmRIOxG	estudiante	active	f	\N	2025-10-10 18:27:21.357578-05	Romero Herrera	4-4167-1330	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:21.357579-05	\N	\N	\N	f
2a513be4-f454-4d50-aece-4d348287d498	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Daniel	luis.jimenez1@pruebasipt.com	$2a$11$TuOzGkb.Qbks7vjjDUduTOX5zWmccGfrT451wgqzTrRzNDqtFXb5a	estudiante	active	f	\N	2025-10-10 18:27:21.945457-05	Jiménez Jiménez	5-8889-1367	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:21.945458-05	\N	\N	\N	f
f224ef0f-bb03-4327-83e5-85d1d9567fed	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Sofía	luis.jimenez@pruebasipt.com	$2a$11$Y9wbdf1DiLiGFkbP73BW9.WGwX9WNvArcgm7jeDl4T08QF.ss4mlC	estudiante	active	f	\N	2025-10-10 18:27:22.529394-05	Romero Jiménez	1-9260-1266	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:22.529394-05	\N	\N	\N	f
cdb95b87-c33b-4dba-8666-6ff94cca379c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Valeria	luis.lopez@pruebasipt.com	$2a$11$pfCfJ0Tj3IUZPRku/TpP2ehur3HPpK6aGOWGWXS2hhleKTtR4rbi.	estudiante	active	f	\N	2025-10-10 18:27:23.107048-05	Herrera López	2-6972-1155	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:23.107049-05	\N	\N	\N	t
e6468d00-b9aa-48d7-bc1c-33e2e440e5b6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Luis	luis.mendoza@pruebasipt.com	$2a$11$ffzqBWR3DguT37Ze2FEwgubFZdhL7Fr2zvocP2IT9TwYcA0A/qGvG	estudiante	active	f	\N	2025-10-10 18:27:23.692995-05	Mendoza Mendoza	10-8849-1051	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:23.692995-05	\N	\N	\N	f
a920e183-2112-4217-929c-51b4602e43d9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Ana	luis.moreno@pruebasipt.com	$2a$11$82/ZZiAXt5MefPiGaxTNheNy4.tCCKn8RTZ965M48e79jyudyOU2m	estudiante	active	f	\N	2025-10-10 18:27:24.258247-05	Rodríguez Moreno	3-5418-1209	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:24.258247-05	\N	\N	\N	t
8d7ab715-30c2-4f81-9028-929f72e19123	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Valeria	luis.perez1@pruebasipt.com	$2a$11$5wGCWW8Mq/orPbsiCZpQwur2P3LfFCtoVtCOdNPe58TQ2jJdNrU4C	estudiante	active	f	\N	2025-10-10 18:27:24.849827-05	Gómez Pérez	4-5279-1340	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:24.849828-05	\N	\N	\N	f
fa7261e5-ea54-4d86-b04b-64771d538ac0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Ana	luis.perez@pruebasipt.com	$2a$11$A4/PGzDKiprY3rzBccFGXeN9QoTPY.tRO6Ac7WQwZuqHYOOFfIS7W	estudiante	active	f	\N	2025-10-10 18:27:25.428267-05	Gómez Pérez	6-3957-1185	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:25.428268-05	\N	\N	\N	t
e4ea14b8-b0c8-43ed-81a3-acc303d89312	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Juan	luis.rios1@pruebasipt.com	$2a$11$7Ue8jmhZ1Q/6cRBQmqag/.wBaf7v3LjxK2daKaTaWHVvFdoAhRp2i	estudiante	active	f	\N	2025-10-10 18:27:26.013621-05	González Ríos	10-1103-1183	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:26.013622-05	\N	\N	\N	f
314394e7-14fa-4d2c-a5a1-20f2aa1004ec	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Luis	luis.rios2@pruebasipt.com	$2a$11$cwo2pCn7EMLwxAyDh2CJ1u8XQb1K6ImNPiT0N/InZfgnJB77hvtd2	estudiante	active	f	\N	2025-10-10 18:27:26.578318-05	Mendoza Ríos	5-9918-1226	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:26.578318-05	\N	\N	\N	f
57e9f58f-1115-4a43-9de2-df9717cf6b0b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Esteban	luis.rios@pruebasipt.com	$2a$11$AFR4rMdLAA2LYhOTv6r9nuTiE/klL8OG3Z93ogPUJ43tCoEQhdRgG	estudiante	active	f	\N	2025-10-10 18:27:27.160009-05	Vargas Ríos	8-9764-1002	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:27.160009-05	\N	\N	\N	f
2514e0c9-cefd-4781-ad18-2c74c282c90e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Carlos	luis.romero@pruebasipt.com	$2a$11$E.EoADAz7P4ZD4HQWRl9meXHU8mJ5WFhzA7O3i5jZvZYL12BkXlDq	estudiante	active	f	\N	2025-10-10 18:27:27.737972-05	Torres Romero	10-6949-1359	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:27.737972-05	\N	\N	\N	t
ccb2b663-81cd-453f-93a7-ff7921dd0752	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Sofía	luis.vargas@pruebasipt.com	$2a$11$2BkCu/s7r5X/IcSIHtnnv.svArz.BcvdfPtNPbMGwMmWfVjaVIIui	estudiante	active	f	\N	2025-10-10 18:27:28.307593-05	Díaz Vargas	3-9275-1035	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:28.307594-05	\N	\N	\N	t
e2100893-cc25-40e8-8bde-8d22be80084b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María María	maria.chavez1@pruebasipt.com	$2a$11$xdAlMFGtO8IGCQWv5.mCke3SYhWhrpfgZCDGMwsLiEDDuMHHexe9a	estudiante	active	f	\N	2025-10-10 18:27:28.817977-05	Chávez Chávez	5-1231-1387	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:28.817977-05	\N	\N	\N	f
ec0f45df-c01e-4ecc-abd8-888b06d85184	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Camila	maria.chavez@pruebasipt.com	$2a$11$xCeCh/Zz1pKOZ1MwqcbICunDoD18NDKrsY2k6En58HJ26byC8CPJK	estudiante	active	f	\N	2025-10-10 18:27:29.381794-05	Torres Chávez	10-2225-1248	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:29.381794-05	\N	\N	\N	f
6a4f95a9-d46d-420b-bb78-e395bf686f6d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Juan	maria.cordoba@pruebasipt.com	$2a$11$F1vwK5krf19Sy5yZxJve/.j4YM57H3FfEtM1yAy2It5j7XFws2zqa	estudiante	active	f	\N	2025-10-10 18:27:29.966345-05	Pérez Córdoba	6-8117-1243	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:29.966345-05	\N	\N	\N	f
9dc819d8-344b-4990-a31f-420dbf2cc8cf	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María María	maria.diaz@pruebasipt.com	$2a$11$nAYAdwSImFKHtPVCQZuBuuP9cZlR//wFwJG7hjpxql2zJNhEorOVK	estudiante	active	f	\N	2025-10-10 18:27:30.5865-05	Ríos Díaz	5-6012-1157	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:30.5865-05	\N	\N	\N	f
1b549b20-c6d4-4399-a510-7380abd3d243	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Daniel	maria.fernandez@pruebasipt.com	$2a$11$TjJZD4BZBeKjNpgXlIo0keZQouvV1JScKNHZ5H420UXB7A/46rq8q	estudiante	active	f	\N	2025-10-10 18:27:31.139316-05	Vargas Fernández	2-5669-1061	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:31.139317-05	\N	\N	\N	f
4fd860fa-397c-4579-aa93-f1eaf214f84e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Ricardo	maria.gomez1@pruebasipt.com	$2a$11$1SgOjHUNnhS3Hxs2zFD8LuNqWr/CyCRr3fqUxps2IP2TM.kS8/Kv.	estudiante	active	f	\N	2025-10-10 18:27:31.701865-05	Fernández Gómez	5-1429-1108	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:31.701865-05	\N	\N	\N	f
7b219bc3-cbe1-4e25-a3f0-409b9ad4ce34	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Elena	maria.gomez@pruebasipt.com	$2a$11$XZLG1.nBF02O.JYZ1GywWeKCkAOSKy4OYVw3nrcsjFWHxPrwMDIXK	estudiante	active	f	\N	2025-10-10 18:27:32.267014-05	Castillo Gómez	8-3369-1026	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:32.267014-05	\N	\N	\N	f
a1fca2fb-d651-4c8e-8c3f-0c2076308f6b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Ana	maria.gonzalez@pruebasipt.com	$2a$11$lnb9SAldBiMIt1NAKu4lpurGW.1vJ2z0Sm.U4aIjUQZkReOqq3yI2	estudiante	active	f	\N	2025-10-10 18:27:32.828579-05	Romero González	7-3634-1301	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:32.828579-05	\N	\N	\N	f
48dcff2a-16e6-4fd5-bb3b-7b0257c5be32	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Juan	maria.herrera1@pruebasipt.com	$2a$11$5Qw7PoepJw1D2GMkqfzSGef7XI0c0rB5p1qonsrO23OUt1jSIW8f.	estudiante	active	f	\N	2025-10-10 18:27:33.47324-05	Córdoba Herrera	8-7172-1304	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:33.473241-05	\N	\N	\N	f
d1c9968c-8fa5-4468-b602-d12d66be29cf	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Valeria	maria.herrera@pruebasipt.com	$2a$11$IY4UIiX31uRBNmttddBY.OQk9H7zuT9LPttEhA4DU8Nv5kpmd0MPi	estudiante	active	f	\N	2025-10-10 18:27:34.0582-05	Córdoba Herrera	3-4264-1033	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:34.0582-05	\N	\N	\N	f
6f7e9820-b708-46e8-94f3-b8a104451fcc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María María	maria.jimenez@pruebasipt.com	$2a$11$tFapK6/NTHcRmWJLdX39I.9dIJVakk0Ab9fUS67UEuAXKCdl4JOPq	estudiante	active	f	\N	2025-10-10 18:27:34.639454-05	Díaz Jiménez	5-3561-1380	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:34.639454-05	\N	\N	\N	f
5811e4ba-7ae1-44c8-a85b-5bacef999b00	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Julio	maria.martinez@pruebasipt.com	$2a$11$rN4S2amHq505AhvrRyMmEe2/1ssu1jAX6oZKbCMM4C516ZKYdPLS2	estudiante	active	f	\N	2025-10-10 18:27:35.220307-05	Vargas Martínez	6-8629-1357	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:35.220308-05	\N	\N	\N	f
a831fb42-46d1-4aaf-a8c8-b3ccacd7350d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Marta	maria.mendoza1@pruebasipt.com	$2a$11$hFOL41sTloKBEKo5wqzYUOyWOnsjQI2T6jEcFRT3UjSjSsnETujx.	estudiante	active	f	\N	2025-10-10 18:27:35.790192-05	López Mendoza	9-9472-1234	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:35.790192-05	\N	\N	\N	f
4702a195-e173-483e-aecb-2b433494f6d3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Daniel	maria.mendoza2@pruebasipt.com	$2a$11$g3JpzWhyrPNbNb3pJLEl7unWf1p9oktSTa116XyBoH73KyT18oOmu	estudiante	active	f	\N	2025-10-10 18:27:36.36471-05	Díaz Mendoza	6-5560-1288	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:36.36471-05	\N	\N	\N	f
217cca08-d2b8-42a9-8d20-f137910efc5f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María José	maria.mendoza@pruebasipt.com	$2a$11$5FywAoHNreij7wkicHFD0.wQCsc0LZteS9g0w/OaFSO.sFdYTQJ8K	estudiante	active	f	\N	2025-10-10 18:27:36.950107-05	Córdoba Mendoza	2-4744-1086	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:36.950107-05	\N	\N	\N	f
74f0f5fb-adb5-4cdf-ba29-6a131966e36d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Paola	maria.moreno1@pruebasipt.com	$2a$11$NR6oZcjrPFsF94RAYphVfuL5DMoVVvhT7CHRnAu0nI29wSh4UHsWy	estudiante	active	f	\N	2025-10-10 18:27:37.550996-05	Romero Moreno	10-9140-1112	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:37.550996-05	\N	\N	\N	f
ec60c83d-40bc-4477-bed1-e5c9881c4fc8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Ricardo	maria.moreno@pruebasipt.com	$2a$11$5CpC0FykQvz62J6zb.u8Qe3akybG8fY/8TtyPf3Np1rIU7BqYHZtG	estudiante	active	f	\N	2025-10-10 18:27:38.131971-05	Torres Moreno	8-9797-1104	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:38.131972-05	\N	\N	\N	f
0812d4bf-75a0-4c30-861d-0da8d936d2e6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Daniel	maria.perez@pruebasipt.com	$2a$11$ahS1U3qZjNyC6JJ4ABOqdOSdtLDWz2Ej7pp0wosqz1GojUBO6c5D6	estudiante	active	f	\N	2025-10-10 18:27:38.727577-05	Chávez Pérez	8-2252-1042	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:38.727578-05	\N	\N	\N	f
2e135b3c-9145-4810-b745-baca1b65c70a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Andrés	maria.rios@pruebasipt.com	$2a$11$utkV4KXvgBARnG0eSdZ4cedcKyF3WGZ63HG1EBmXfrj./8wOe3leu	estudiante	active	f	\N	2025-10-10 18:27:39.295105-05	Romero Ríos	10-9688-1351	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:39.295105-05	\N	\N	\N	f
19118f32-5cf3-4cb3-8a5a-72fca55f0173	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Paola	maria.rodriguez@pruebasipt.com	$2a$11$3TVHqMOTm30tRaW9hEPTq.2ssCn42rZz0Va70jH97gIq95TQDqf2O	estudiante	active	f	\N	2025-10-10 18:27:39.883108-05	Herrera Rodríguez	10-5740-1098	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:39.883108-05	\N	\N	\N	f
52698c70-bd3d-4945-9f9b-5028ba7027cb	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Carmen	maria.romero1@pruebasipt.com	$2a$11$EtxhU87FfJVxaXzpGggSK.wLDmKrut8sSRvoDNlQLU8L/dRmVk1AK	estudiante	active	f	\N	2025-10-10 18:27:40.462255-05	Rodríguez Romero	5-8150-1302	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:40.462256-05	\N	\N	\N	f
03933950-2bb7-434f-b29b-96147a19c5c4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Pedro	maria.romero2@pruebasipt.com	$2a$11$N44DYv1ReCWUnM7SG22We.mzwz8nUAkvwooiD.w64SvmRE8d7G3yS	estudiante	active	f	\N	2025-10-10 18:27:41.04935-05	Fernández Romero	7-6996-1337	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:41.04935-05	\N	\N	\N	f
51b3a2cd-2492-4964-887d-5caa361d1cdd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María Juan	maria.romero@pruebasipt.com	$2a$11$.vudpmpnDnjH6bIpiVWYa.teRfFAu9ZZ6FBiqH1oH./7VKZSPqwAu	estudiante	active	f	\N	2025-10-10 18:27:41.614565-05	Moreno Romero	6-9666-1229	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:41.614565-05	\N	\N	\N	f
203c8bfd-fc25-4ccf-84d1-2f34448e3776	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Camila	marta.chavez1@pruebasipt.com	$2a$11$KTMRLxG2KhOJ6wUhqwuGFellZLA2kH1XuNk2nGLz9GQhEmxUhH0qG	estudiante	active	f	\N	2025-10-10 18:27:42.203249-05	Chávez Chávez	6-6853-1299	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:42.203249-05	\N	\N	\N	t
9a68d015-77fd-455d-92c8-d41a59230282	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Ricardo	marta.chavez@pruebasipt.com	$2a$11$cA/cTymDGjz17cMioZFM6u7Zc8iE7mnNbpuU6OjBn16zspUbu/d4W	estudiante	active	f	\N	2025-10-10 18:27:42.802645-05	Moreno Chávez	4-2428-1227	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:42.802646-05	\N	\N	\N	t
b872ff1c-d143-4f34-88bc-6aee099ee5a1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Carlos	marta.cordoba1@pruebasipt.com	$2a$11$Q9IQBYY4YCEArx54Wy4vVOahJTZIF6fcOUWMw02fy6Z6p744.KN5q	estudiante	active	f	\N	2025-10-10 18:27:43.385293-05	Gómez Córdoba	6-2717-1034	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:43.385294-05	\N	\N	\N	f
3b3d74d6-d8e1-4f37-bc01-d908d864c0b0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Ricardo	marta.cordoba2@pruebasipt.com	$2a$11$IjF.dD188TIoNOFe8OJgyuyrLVSQ//HtUrOTZ552PV19PqsqVaMjy	estudiante	active	f	\N	2025-10-10 18:27:43.989753-05	Chávez Córdoba	3-6431-1320	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:43.989754-05	\N	\N	\N	f
604cf805-2379-4b94-99d5-523740c3a58c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Ricardo	marta.cordoba@pruebasipt.com	$2a$11$Q6z1i3OhB8nLmRaBQ2WyTe1dz4npY6soGqNAtkjhailfaiNn5hXMO	estudiante	active	f	\N	2025-10-10 18:27:44.578212-05	Mendoza Córdoba	8-4213-1025	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:44.578212-05	\N	\N	\N	f
10d3e650-cd1c-4994-85e2-d0ce61720877	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Juan	marta.diaz1@pruebasipt.com	$2a$11$9YPOB7KUuPuUiukYyzEu1etIRvo5Gg378pKCQUgpZivJZ8uroHp3a	estudiante	active	f	\N	2025-10-10 18:27:45.176457-05	Mendoza Díaz	3-3546-1166	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:45.176457-05	\N	\N	\N	f
205b7b98-2a57-4973-b1ed-2f5aec96123e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Luis	marta.diaz@pruebasipt.com	$2a$11$sc.k8LNFaTbT1MGn9fxtVutM/MS2Vo5yOsInwttQ5pBDdeMJM323S	estudiante	active	f	\N	2025-10-10 18:27:45.763714-05	González Díaz	3-1821-1074	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:45.763715-05	\N	\N	\N	f
2ef83911-71fe-4bc7-b13a-7cc16030fad8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Sofía	marta.fernandez@pruebasipt.com	$2a$11$VyKyD4nN.Z8GU93f63yDbOtIl90H54RzpZ5DauYGkMsrF5XRIJuR2	estudiante	active	f	\N	2025-10-10 18:27:46.342708-05	Ríos Fernández	5-6718-1334	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:46.342709-05	\N	\N	\N	f
48fa3c1d-2280-45ff-9038-61d3f4f2cf20	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta José	marta.gomez1@pruebasipt.com	$2a$11$xJhVWSOQqqmM7bVYVcJcVOhJFs.g55re.9CavuApqXvopVTqlIc7.	estudiante	active	f	\N	2025-10-10 18:27:46.935933-05	Moreno Gómez	6-1103-1324	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:46.935933-05	\N	\N	\N	f
cc378c43-cbd8-4fc6-9c83-7e45abb3e6e1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Camila	marta.gomez@pruebasipt.com	$2a$11$L387OQSp7PUiwdWB0W6nkOazJgrLF5AiJSKvUDDynlwgX8ei09Pe.	estudiante	active	f	\N	2025-10-10 18:27:47.53347-05	Moreno Gómez	8-3082-1306	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:47.53347-05	\N	\N	\N	f
499eda58-03cc-40c3-9633-11812c8a03a3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Daniel	marta.gonzalez@pruebasipt.com	$2a$11$1rAVnLuJ25U61pzrzdc0he46bQOESUudhFY75OwSU/0jjdo7gZ/s6	estudiante	active	f	\N	2025-10-10 18:27:48.111555-05	González González	10-5962-1216	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:48.111555-05	\N	\N	\N	f
f7cb07b2-2f94-4e81-8799-8b60128ff583	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Daniel	marta.jimenez@pruebasipt.com	$2a$11$ApnUIhag6Ni98h7VLux/quwFVa.afXd9wdQS3uGDRcy54aigeiC8e	estudiante	active	f	\N	2025-10-10 18:27:48.680657-05	Díaz Jiménez	2-9545-1009	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:48.680657-05	\N	\N	\N	f
5a140fb2-abed-42f7-b52d-f7197c3c312c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta José	marta.lopez1@pruebasipt.com	$2a$11$LYfZw3VSvoY9D6VdQg4FsuCzae7l8UrRoxTwLdWiEY7/rEb6ikSCe	estudiante	active	f	\N	2025-10-10 18:27:49.279212-05	Mendoza López	10-3081-1315	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:49.279212-05	\N	\N	\N	f
21349f4f-5082-48c2-99ab-54c9acff9ac1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Paola	marta.lopez@pruebasipt.com	$2a$11$l8lKfsJxjrVTj42PIw7jbOF9BnebfgsjIWnpegmvEDfSeRki9RFYS	estudiante	active	f	\N	2025-10-10 18:27:49.858461-05	Herrera López	4-1938-1189	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:49.858462-05	\N	\N	\N	f
bd7bc8f8-b7b5-407f-aa82-47ae5e9ff59e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Camila	marta.martinez@pruebasipt.com	$2a$11$p.NYz6t8QAtg53Xw0xk9ou.yYpIW0ThBB26ZxL6Ca/oSQJQ9VxMfC	estudiante	active	f	\N	2025-10-10 18:27:50.452042-05	Jiménez Martínez	1-8807-1310	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:50.452043-05	\N	\N	\N	f
8f6e378b-a980-4d31-986a-5343ca8b04fe	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Esteban	marta.mendoza1@pruebasipt.com	$2a$11$yeZ1w9IOFoujFeLJoh2iyu5pkUW/PKjA6ceJz4ryBcKTzacpl6BeO	estudiante	active	f	\N	2025-10-10 18:27:51.039781-05	Martínez Mendoza	9-6361-1290	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:51.039781-05	\N	\N	\N	f
d43de11b-ba9a-44f1-aace-d294a85f9c81	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Carmen	marta.mendoza2@pruebasipt.com	$2a$11$IAP.XBW1GAw6Cv.3DxC/1OGHoQLtNT5/84Z313Ni85HHjUni94lFu	estudiante	active	f	\N	2025-10-10 18:27:51.610394-05	Rodríguez Mendoza	7-5882-1303	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:51.610394-05	\N	\N	\N	f
967ac167-7d4d-4ff7-acb1-b635ea406419	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Paola	marta.mendoza@pruebasipt.com	$2a$11$6/ciEBzQTLl54bajJwJGiuvZzqZM7MFN9ey.UiS4FpmRcxYXQXzda	estudiante	active	f	\N	2025-10-10 18:27:52.183492-05	Gómez Mendoza	2-8984-1069	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:52.183492-05	\N	\N	\N	f
22ba018d-5dc1-47eb-8137-2a8344f06f20	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Elena	marta.moreno1@pruebasipt.com	$2a$11$XhgfRAGDACCWJ8FaGlg6Nu7Aj401aNPInUGIFo1jXFdbH/K6JeoHC	estudiante	active	f	\N	2025-10-10 18:27:52.772621-05	Córdoba Moreno	6-1055-1188	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:52.772621-05	\N	\N	\N	f
972472ce-7790-42a3-a969-6cc8b78564ff	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Carmen	marta.moreno2@pruebasipt.com	$2a$11$UCacw6Ep7U8yuV9zD4T01OGKTXP64UWU7ap2xBl8HxyiMo.7tgo4u	estudiante	active	f	\N	2025-10-10 18:27:53.360117-05	Fernández Moreno	8-1961-1274	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:53.360118-05	\N	\N	\N	f
a545956a-1117-49ec-8b53-4561a595ba24	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Andrés	marta.moreno@pruebasipt.com	$2a$11$vELJUnIIBfcoPLXlB4sf.OxRSSltFx9JVzQ8lhPbsSLuZCyVNor0C	estudiante	active	f	\N	2025-10-10 18:27:53.946156-05	Vargas Moreno	1-6385-1019	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:53.946156-05	\N	\N	\N	f
55176420-23db-4d89-8fa4-22b17e66203b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Sofía	marta.rios@pruebasipt.com	$2a$11$QrZhxaXgW4V2fiK5XBVYZebvon1rZvkNKPBimbKapb8/CEaykJXkm	estudiante	active	f	\N	2025-10-10 18:27:54.525064-05	González Ríos	2-4111-1113	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:54.525064-05	\N	\N	\N	t
d90acba5-5656-45b9-a2d8-2dd1468a9ce8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Paola	marta.sanchez1@pruebasipt.com	$2a$11$.oTlJR7AXEiCEfH6RFQbXO34QcDovGH127zDBp1V6DqrXHEgEHT5C	estudiante	active	f	\N	2025-10-10 18:27:55.103956-05	Fernández Sánchez	1-5282-1088	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:55.103956-05	\N	\N	\N	f
888beba2-b251-4dad-a8dc-a413221c7cb5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Marta	marta.sanchez@pruebasipt.com	$2a$11$Cpq6m/X4VaeVkW4HoEGYde.PsusGtWzxUIMz4GwUgxQHZ7q/Rdmx.	estudiante	active	f	\N	2025-10-10 18:27:55.695532-05	Díaz Sánchez	4-8080-1067	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:55.695533-05	\N	\N	\N	f
b7b99f47-592e-428d-aa0d-e318b6f4f82d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marta Paola	marta.torres@pruebasipt.com	$2a$11$s7Glz9WHn6aKyeFiDosFnOAQjWoa9fm2CXv6HQbQ67F4MCDcSYfPi	estudiante	active	f	\N	2025-10-10 18:27:56.288081-05	Córdoba Torres	9-1463-1374	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:56.288081-05	\N	\N	\N	f
3e2b2a06-72f2-4ab6-b698-79cac1003b29	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Elena	paola.castillo@pruebasipt.com	$2a$11$ZqXoCQnEHLM.Hw7CfhQ2KuYFh6PYuw2hkxsfqzax/RAbGQlAoL/cG	estudiante	active	f	\N	2025-10-10 18:27:56.879891-05	Castillo Castillo	7-7221-1117	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:56.879891-05	\N	\N	\N	f
0e094829-0526-4a10-b712-c3ce8ad70ef2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Elena	paola.chavez@pruebasipt.com	$2a$11$zrW/UXJCJjGTIrEHOOlja.TWr6VBJZrU2OeIMUvtZ.0Qu1WjJvdyW	estudiante	active	f	\N	2025-10-10 18:27:57.472794-05	Chávez Chávez	5-1407-1120	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:57.472794-05	\N	\N	\N	f
1a509d63-0d87-465d-b713-6b5c0e347212	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Carmen	paola.fernandez@pruebasipt.com	$2a$11$2BhP2n39XMuZvvbQNzk30O/oyLXfv028X7QPlOKdMyLaj/pGltL6K	estudiante	active	f	\N	2025-10-10 18:27:58.078354-05	Romero Fernández	9-2445-1378	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:58.078355-05	\N	\N	\N	f
eee03708-1677-4e52-9f95-bf3135b42153	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Julio	paola.herrera@pruebasipt.com	$2a$11$uqXrQd14SeT.GnaCNRlEoe210/smWLvfPt0SxVYBawgb/4UZGcTZK	estudiante	active	f	\N	2025-10-10 18:27:58.68758-05	Martínez Herrera	5-6138-1386	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:58.68758-05	\N	\N	\N	f
9e0096a6-e21f-4fd2-8775-2045072e9d41	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Ana	paola.jimenez@pruebasipt.com	$2a$11$L8hazrr74ijUb9qBQjEIhOQea5CPIvDdQ9c5fud6dGXWgJKKf.ySm	estudiante	active	f	\N	2025-10-10 18:27:59.284869-05	Fernández Jiménez	6-6304-1272	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:59.284869-05	\N	\N	\N	f
d6a1de81-fc2f-4455-8c0d-b77bcd89a20f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Diego	paola.martinez1@pruebasipt.com	$2a$11$ywwEdPBMvx6bvbH1sRwRbuoxNyUtXCB5/i0g1HbQwpSif/p8FufM6	estudiante	active	f	\N	2025-10-10 18:27:59.864305-05	Vargas Martínez	8-6585-1295	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:27:59.864305-05	\N	\N	\N	f
bcef825f-3068-445e-aba9-d3d1022ec351	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Juan	paola.martinez2@pruebasipt.com	$2a$11$UcwUJsNjXolhU7P2kVzKw.oCMfskKy9id8KmCVzc2.oOECdSDndcG	estudiante	active	f	\N	2025-10-10 18:28:00.45444-05	González Martínez	2-5098-1298	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:00.454441-05	\N	\N	\N	f
c0e5dd95-9c70-4da2-b17e-1f93224f094a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Carmen	paola.martinez@pruebasipt.com	$2a$11$7UQ5uvZ9R0ub4BZL2PA/Wu.EdnYnLCl.25j3fPPH9z6YC9/v9EkTy	estudiante	active	f	\N	2025-10-10 18:28:01.043148-05	Díaz Martínez	10-3107-1097	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:01.043148-05	\N	\N	\N	f
522ad9e8-e820-435a-b48a-05a2190c88dd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Esteban	paola.mendoza1@pruebasipt.com	$2a$11$2mpaapt6BtTJBFpoE/10W.AKhPHrDMiRFkY7gvQYQm6P4azVytwP.	estudiante	active	f	\N	2025-10-10 18:28:01.606909-05	Martínez Mendoza	5-8240-1063	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:01.606909-05	\N	\N	\N	f
b9065d1a-6e83-4b1f-88e5-7c6f25f030f3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Daniel	paola.mendoza2@pruebasipt.com	$2a$11$lulzifk91TVkPy3MOkEOjOrddZBmTSZoflzBO1wk2/VOLPQFa/Ola	estudiante	active	f	\N	2025-10-10 18:28:02.208209-05	Pérez Mendoza	1-4675-1121	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:02.208209-05	\N	\N	\N	f
cfb51bfe-77c6-4346-b425-e8aa89de0927	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Luis	paola.mendoza@pruebasipt.com	$2a$11$1iPDPbXce0URhWo9r1WCEO7MnAIdZn3jO8olMKfFJ8FogUvuaAW3W	estudiante	active	f	\N	2025-10-10 18:28:02.787576-05	Rodríguez Mendoza	7-3152-1044	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:02.787577-05	\N	\N	\N	f
9b3255d2-a64f-41c2-add9-c739cf25b882	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Esteban	paola.rodriguez@pruebasipt.com	$2a$11$qpFZ7oaJ4xgD3ZAVgJTPBurgTCFCKm4TmrAOceHdqVoKV7uR/Hx6S	estudiante	active	f	\N	2025-10-10 18:28:03.359769-05	Torres Rodríguez	9-8921-1335	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:03.359769-05	\N	\N	\N	t
5b017e78-7b51-4bc2-9718-5b7e36b0b589	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Paola	paola.romero1@pruebasipt.com	$2a$11$19cS7ZPJldcRVJ1TRhQfeeRJRjQdPy8c/kBGat2aNcXF.BBQ05p5y	estudiante	active	f	\N	2025-10-10 18:28:03.953581-05	Castillo Romero	6-3262-1314	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:03.953582-05	\N	\N	\N	f
d06d026c-e4d1-4418-b0e2-5a82ce94c9ea	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Diego	paola.romero@pruebasipt.com	$2a$11$OyVeeHaz2gAHQ/wdUWv9COUWez1cK/FVHeTL.vvgcYaiVWoykWo.q	estudiante	active	f	\N	2025-10-10 18:28:04.547167-05	Romero Romero	8-7036-1105	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:04.547168-05	\N	\N	\N	f
f97b6146-5d44-47e6-840c-a76bd793dfba	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Daniel	paola.torres1@pruebasipt.com	$2a$11$8HoV6UA0034/ZmKGfEqeGuHNycRgOBQ/Kk6TiVimKm2bSDA6fqCIG	estudiante	active	f	\N	2025-10-10 18:28:05.129612-05	Pérez Torres	6-7938-1279	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:05.129612-05	\N	\N	\N	f
e9bb6f6c-ca29-4700-8106-ea3d746a4de3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Julio	paola.torres@pruebasipt.com	$2a$11$yywBP2AnPnw0uG/Vq9b/juD5bAfMnkJPFPOZiraiHCQoaG.QttQfW	estudiante	active	f	\N	2025-10-10 18:28:05.733557-05	Jiménez Torres	4-7353-1168	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:05.733557-05	\N	\N	\N	f
42ad3c6c-6304-426d-baca-d9646e924d65	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Paola Andrés	paola.vargas@pruebasipt.com	$2a$11$XxhcGJ/bKFGlYLe7occKaO0rR9jNCvs1SmhhRGojNXxpLNqSrZ3ge	estudiante	active	f	\N	2025-10-10 18:28:06.329434-05	Mendoza Vargas	8-8304-1100	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:06.329434-05	\N	\N	\N	f
b5db6150-e122-46d7-ab5c-39c8b77c92c0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Julio	pedro.castillo@pruebasipt.com	$2a$11$jz2Z/ku6Ss.IkycoQRcrU.kzkn657Ek9yMggrDXbEbKRHkQViQ90O	estudiante	active	f	\N	2025-10-10 18:28:06.952453-05	Vargas Castillo	6-6960-1282	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:06.952453-05	\N	\N	\N	f
a067cc63-6f6a-4047-828a-44d01a46f6f2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro José	pedro.cordoba@pruebasipt.com	$2a$11$LZgQPk4hMxOqYFbOFtuYbeCivcdTV/oowtAuQqy0vvXQe0uUITRoO	estudiante	active	f	\N	2025-10-10 18:28:07.553658-05	González Córdoba	6-1149-1000	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:07.553658-05	\N	\N	\N	f
09076bb4-77e6-46db-b3ce-9011558af5de	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Valeria	pedro.gomez@pruebasipt.com	$2a$11$qsSepy7uFNbi8EVxTQruh.Unth640pC4LZFTqQWYJ10p9KS4yw8dm	estudiante	active	f	\N	2025-10-10 18:28:08.150194-05	Romero Gómez	7-3695-1015	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:08.150195-05	\N	\N	\N	f
b308aca5-bb8c-4a68-b47b-0f5fd42c7865	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro María	pedro.gonzalez@pruebasipt.com	$2a$11$CtueUe.ZV8AFRVWhWQoCI.HUD2vIoJ9xSDKi4SrkyL3DD6PwuaJyW	estudiante	active	f	\N	2025-10-10 18:28:08.769502-05	Martínez González	10-7343-1245	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:08.769503-05	\N	\N	\N	t
685aa1d5-b7b8-4a1f-b011-8395527b9df1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Daniel	pedro.herrera@pruebasipt.com	$2a$11$KQE.7FuxQTClW8NLxVjhJ.qlO46Z0/1XlivpDucmkq92I/NAlUfe6	estudiante	active	f	\N	2025-10-10 18:28:09.357973-05	Jiménez Herrera	1-9912-1146	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:09.357974-05	\N	\N	\N	f
9d0e4ddc-c032-489c-8a48-7e3ab846811f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Andrés	pedro.jimenez@pruebasipt.com	$2a$11$dzoclwW2EdJdVkvq7Q.wte3guWk/koQv5j2RsAfemDSbJOxi035T6	estudiante	active	f	\N	2025-10-10 18:28:09.975757-05	Sánchez Jiménez	5-7569-1123	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:09.975758-05	\N	\N	\N	f
29023be9-0ce9-45e4-9825-10e1e50bd711	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro José	pedro.lopez@pruebasipt.com	$2a$11$0J.ays.biCmkpWf54ndtuOTTibR.6mxO0XyG7oEhQ5ARvthKBsCoO	estudiante	active	f	\N	2025-10-10 18:28:10.57069-05	Chávez López	8-5962-1049	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:10.57069-05	\N	\N	\N	f
0ee32c2d-4a6b-4c12-b32c-b5da19a364aa	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Ana	pedro.martinez@pruebasipt.com	$2a$11$K0iXjGQLLcuc9pmUkT1MRuLWpN/3IepfaVeGB2gQUxX46nJMdRKzS	estudiante	active	f	\N	2025-10-10 18:28:11.15879-05	Jiménez Martínez	6-5363-1190	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:11.15879-05	\N	\N	\N	f
915f956d-4245-4752-819f-f33f62ef54b9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Carmen	pedro.mendoza@pruebasipt.com	$2a$11$zWdaoVq5xwo/UPE/etCJzeaFpDtZ6o27otIOwDGhg/RQePa67WcIa	estudiante	active	f	\N	2025-10-10 18:28:11.752537-05	Díaz Mendoza	2-2073-1256	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:11.752537-05	\N	\N	\N	f
f3100163-c493-49a0-a64f-17acd13560e1	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Juan	pedro.moreno1@pruebasipt.com	$2a$11$CLlFI6NZVlPC4gXKBjGigOl/FMuWSgGdxNwdh8LUzAuXAGMOF5S9.	estudiante	active	f	\N	2025-10-10 18:28:12.364708-05	Mendoza Moreno	1-3968-1343	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:12.364709-05	\N	\N	\N	f
df761407-3f75-4060-90f3-6e57bcbdbda3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Sofía	pedro.moreno@pruebasipt.com	$2a$11$Y9pnIEmL2W54Bza5EpyBTOiMlb2ALafpV/GiN.YhveWcZfxRU4ESG	estudiante	active	f	\N	2025-10-10 18:28:12.978809-05	Vargas Moreno	7-1063-1125	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:12.978809-05	\N	\N	\N	t
fb226c58-54ae-481d-a979-f4ce97c1cfd3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Pedro	pedro.rios1@pruebasipt.com	$2a$11$L8vaF4BX65Ij5VUX8DFQsumim5tRZYGEvNzJEzSr1bSzw88DsRWu2	estudiante	active	f	\N	2025-10-10 18:28:13.584022-05	Romero Ríos	7-8107-1179	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:13.584023-05	\N	\N	\N	t
178ea05d-cd89-48cb-add1-618e03cda92e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Diego	pedro.rios@pruebasipt.com	$2a$11$4Je2z3zQPvibhOEPsJJVx.jePfDhm8nt1u3EQ2J5QOZTIWy8V5Jk2	estudiante	active	f	\N	2025-10-10 18:28:14.19412-05	Moreno Ríos	5-4800-1021	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:14.19412-05	\N	\N	\N	f
faa222e7-b797-432b-866f-ab90dc2a7de5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Julio	pedro.sanchez1@pruebasipt.com	$2a$11$Qr3Bh8ti38UIw1FY2eXzeuz1thvQ0uhR2LcuExHbW8tRbExi6vw2C	estudiante	active	f	\N	2025-10-10 18:28:14.896273-05	Chávez Sánchez	4-2228-1286	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:14.896273-05	\N	\N	\N	f
6f1b7dfa-4c0b-43d5-89ab-cb58adf40eae	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Pedro	pedro.sanchez2@pruebasipt.com	$2a$11$Dp98h5yMWwcBxrmeftAWheDCgppRqZtBHKPC.Lr9pRp54AEI0bTcq	estudiante	active	f	\N	2025-10-10 18:28:15.479378-05	Moreno Sánchez	8-6086-1341	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:15.479378-05	\N	\N	\N	t
ad10675d-a0bd-4aa3-8111-d5d2232583f5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Diego	pedro.sanchez@pruebasipt.com	$2a$11$/DWZ.aSOfZf4.4PHR7Qlg.H5jKO2OZYz0xzfpHaw5L6oIxqIqKUi6	estudiante	active	f	\N	2025-10-10 18:28:16.025068-05	Gómez Sánchez	6-4330-1065	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:16.025069-05	\N	\N	\N	t
d5a44021-692b-4d81-aafb-c1868da9521b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pedro Camila	pedro.vargas@pruebasipt.com	$2a$11$a6aHIblvx0b5hR2eXguu2uFIG5xOcrahKONUIXrqFQJ5gcZYj9WAK	estudiante	active	f	\N	2025-10-10 18:28:16.60053-05	Herrera Vargas	6-8673-1363	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:16.600531-05	\N	\N	\N	f
5ad73058-f6fd-46ec-a4ab-9abfae1766ad	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Juan	ricardo.castillo1@pruebasipt.com	$2a$11$6NLSYApY3WsMBdKwEcEfee1OJB7kuMcf/9bGd1kOP.csZ22SLWxQa	estudiante	active	f	\N	2025-10-10 18:28:17.156934-05	Moreno Castillo	7-9309-1023	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:17.156934-05	\N	\N	\N	t
c1c171f4-3e60-4b07-81de-8b036e499310	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Diego	ricardo.castillo2@pruebasipt.com	$2a$11$xSuHiqLluLlwwKkg3TmhHOn3U5/VF2V0T4roL.7TTAgIES1Jn8Prq	estudiante	active	f	\N	2025-10-10 18:28:17.743644-05	Jiménez Castillo	9-6919-1162	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:17.743645-05	\N	\N	\N	f
712b3798-af76-4b1a-8ec5-1c1405f79b68	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Camila	ricardo.castillo@pruebasipt.com	$2a$11$FkujG8oWVNNrX8011DF2TezsfJu/CV1bsN.7XrkZ0W8w5fUHilHQO	estudiante	active	f	\N	2025-10-10 18:28:18.328516-05	Sánchez Castillo	3-2935-1011	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:18.328517-05	\N	\N	\N	t
0306bd74-4817-459a-b38a-151fc2d95122	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Camila	ricardo.chavez1@pruebasipt.com	$2a$11$Ebb13mgIN1jUQutCl/Gd0.h.hKNS7c2tgU3Qn/ll5ZnxHsUviMFMC	estudiante	active	f	\N	2025-10-10 18:28:18.908067-05	Torres Chávez	9-5421-1344	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:18.908067-05	\N	\N	\N	f
6cd0f4e3-f920-4997-9b61-b5a68dea5b19	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo José	ricardo.chavez@pruebasipt.com	$2a$11$hkXqi1ja1Zct3unzhyaC5uYWKkR92NpLswL/xTcByVqxcd6QZJRpy	estudiante	active	f	\N	2025-10-10 18:28:19.484993-05	González Chávez	4-7240-1165	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:19.484993-05	\N	\N	\N	f
9bec12be-dc03-4eb2-ac7f-6d68efd08363	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Daniel	ricardo.fernandez@pruebasipt.com	$2a$11$QPQ8VI/Ndt8wASe0fPftIuvpVu2JqUk8F8Jhp9oraXI5CESMFxhpK	estudiante	active	f	\N	2025-10-10 18:28:20.066079-05	Díaz Fernández	9-5773-1148	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:20.06608-05	\N	\N	\N	f
dc041efc-a199-49a7-9dc9-b3cada840c78	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Carmen	ricardo.gomez1@pruebasipt.com	$2a$11$iZBIymL8/ai0IY8auJeOCuD63FW3FE7FOEnG.lbqRXwuB49oKqHG2	estudiante	active	f	\N	2025-10-10 18:28:20.637488-05	Castillo Gómez	7-5262-1089	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:20.637489-05	\N	\N	\N	t
ef68c0e8-ab58-49d6-93f3-d65cb44b9bf0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Sofía	ricardo.gomez2@pruebasipt.com	$2a$11$VtA9sguVZzA4NJDeGXMlU.oZzUvvmeuhxjSgVKqwql42U.wVFcCVK	estudiante	active	f	\N	2025-10-10 18:28:21.211751-05	Castillo Gómez	7-4306-1142	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:21.211751-05	\N	\N	\N	f
110e3708-dde4-4ae5-a418-2139e468035c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo María	ricardo.gomez3@pruebasipt.com	$2a$11$DIZqYGdqTVXjdEnkxsDrJuDBng8WM9Cl9c.Nbz68j1WMXViIAyR16	estudiante	active	f	\N	2025-10-10 18:28:21.794681-05	Jiménez Gómez	1-3418-1230	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:21.794682-05	\N	\N	\N	f
ca292815-f26e-45a8-8259-d711b8caaab2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Ricardo	ricardo.gomez4@pruebasipt.com	$2a$11$mvskZAjccmRo8ozlLO.UC.TEHAdJJ02CkRDHC2B4eVa9h6WtJ4dyK	estudiante	active	f	\N	2025-10-10 18:28:22.381-05	González Gómez	5-8660-1283	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:22.381-05	\N	\N	\N	f
42d1cb7e-2bb9-413d-af9b-18357a2917ef	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo José	ricardo.gomez@pruebasipt.com	$2a$11$STak6N5SB6v/PlrfcNZUC.oIeBrrgn2jAl48xd7ZP5lNuzZVc3zmS	estudiante	active	f	\N	2025-10-10 18:28:22.951582-05	López Gómez	3-5258-1053	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:22.951583-05	\N	\N	\N	t
d759553c-6ab0-4b26-b7c6-b3f86e8cacba	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Paola	ricardo.gonzalez@pruebasipt.com	$2a$11$5VWAXWwSNpNwHttsRA/TSem9Fjvt48JhO28/RNQXL31qnVZkLVzEa	estudiante	active	f	\N	2025-10-10 18:28:23.445119-05	Romero González	2-9812-1313	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:23.445119-05	\N	\N	\N	f
876462f9-386b-4cf2-841e-a297b2324ee0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Andrés	ricardo.herrera@pruebasipt.com	$2a$11$WHF.MuPataedcFjasWeSZu6adQ7jxHBwPs28a190fs9StlSZO7SbW	estudiante	active	f	\N	2025-10-10 18:28:24.007858-05	Córdoba Herrera	6-5336-1022	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:24.007859-05	\N	\N	\N	f
d2d1892e-a89f-4123-bdb0-9fad28c317bc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo María	ricardo.lopez@pruebasipt.com	$2a$11$Gyvi2FCsIuZGRmblwxr9cOUh3sVI8HL/AHn2/3jtCwUPLaTFibfXa	estudiante	active	f	\N	2025-10-10 18:28:24.622488-05	Rodríguez López	8-1740-1328	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:24.622488-05	\N	\N	\N	f
838a7c9f-86ca-4d48-a084-e4986071df7b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Daniel	ricardo.martinez1@pruebasipt.com	$2a$11$9siJ8Wwcy4/QvYDiW7cCceyj8t0F6U.EcXbbgsW3BAfSjM3gjqQv2	estudiante	active	f	\N	2025-10-10 18:28:25.207442-05	Romero Martínez	4-5963-1213	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:25.207442-05	\N	\N	\N	f
cb77f441-dbb3-4134-84d0-3b8399a77cf3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Marta	ricardo.martinez2@pruebasipt.com	$2a$11$gE.NzeB5P0NFO3sRKI4SI.lejICzPtz4RWOuHJ9zU3xN/bw8mni5K	estudiante	active	f	\N	2025-10-10 18:28:25.783755-05	Mendoza Martínez	5-1763-1331	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:25.783755-05	\N	\N	\N	f
d5bb34a3-a7a0-4835-ab3e-3ac7299eaf0a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Juan	ricardo.martinez@pruebasipt.com	$2a$11$Q85R18of5GLMTj8SrLV2YOTJkTbhxeh7AyyCOmram8UXjbV1Hhncm	estudiante	active	f	\N	2025-10-10 18:28:26.371345-05	González Martínez	7-2946-1170	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:26.371345-05	\N	\N	\N	f
f9760330-71e6-4f8d-bdc2-7a23992c217e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Sofía	ricardo.mendoza@pruebasipt.com	$2a$11$Up.WG7zE1n9B/mBgPyy4Ie9AnCv9CWiswpLAYmOjnz26ZG9NG4dN2	estudiante	active	f	\N	2025-10-10 18:28:26.924307-05	Romero Mendoza	2-7393-1292	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:26.924307-05	\N	\N	\N	f
a572d935-8b25-4e52-b5c6-1ebcfd364575	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Carlos	ricardo.moreno1@pruebasipt.com	$2a$11$v8cP/VoSYgAhu6/hxGlFueRJROOG/7cJuw7aZEqsUbRA.l8WG59FS	estudiante	active	f	\N	2025-10-10 18:28:27.480082-05	López Moreno	3-9910-1116	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:27.480082-05	\N	\N	\N	f
3aee7ee1-2de8-4d53-9650-dbdd643781f5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Andrés	ricardo.moreno@pruebasipt.com	$2a$11$.tV2Bt9I2BOJdYb29Tua.eoc/D4aGklCi0UjzijNQI.iaUiQ1BaSe	estudiante	active	f	\N	2025-10-10 18:28:28.071063-05	López Moreno	4-2436-1038	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:28.071064-05	\N	\N	\N	f
33f62692-2c55-4d15-be14-7cfe4e6ecaf6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Luis	ricardo.rios@pruebasipt.com	$2a$11$8G80YP5cLHfMIWgIeHl16u/o7qI6zvTsdZ65rjabtOdC1jljgpsaK	estudiante	active	f	\N	2025-10-10 18:28:28.61501-05	Vargas Ríos	9-4223-1225	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:28.61501-05	\N	\N	\N	f
14c36a0c-4c0f-4193-92c4-905610d87d89	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Sofía	ricardo.vargas1@pruebasipt.com	$2a$11$G6ndQdIZV9uFwr3//zOnZe7Y/9JaP.xLrVz4/7sIzCRp/I.TF6aGO	estudiante	active	f	\N	2025-10-10 18:28:29.183039-05	Pérez Vargas	8-1802-1178	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:29.183039-05	\N	\N	\N	f
c8947a8f-4e2d-4f7b-9363-e9e7b6a35531	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ricardo Luis	ricardo.vargas@pruebasipt.com	$2a$11$Qa31RGTxIjQcQ9hOSAlq7eJ4ZzesLwuhd4gAUgDF4ZiCOuJnRrRAK	estudiante	active	f	\N	2025-10-10 18:28:29.763285-05	Ríos Vargas	5-8999-1158	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:29.763285-05	\N	\N	\N	f
e559912b-40ce-41af-b08f-cac0c2f6c98d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía José	sofia.castillo@pruebasipt.com	$2a$11$Wb/TLog3XbfOhSAB4fQHtuThGRCEws/Qqs1nAd2wl3t16G23L6E2y	estudiante	active	f	\N	2025-10-10 18:28:30.330375-05	Vargas Castillo	7-1843-1257	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:30.330376-05	\N	\N	\N	t
7099fd8a-e49d-4668-92d3-b34bb97e3d6e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Ricardo	sofia.chavez@pruebasipt.com	$2a$11$6ProV27g6VzbTwZKFnvZtekLT2xboqr.RplhikRkev2UAZtT49xuO	estudiante	active	f	\N	2025-10-10 18:28:30.910693-05	Vargas Chávez	5-3996-1346	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:30.910693-05	\N	\N	\N	f
1c61ebec-4ec3-4f5d-82b1-a6e7d4f53f6a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Luis	sofia.diaz@pruebasipt.com	$2a$11$YbU86twah.y/SFo0g9VqV.wadtvpud1v4v/nqgUOEimEasHPjZtda	estudiante	active	f	\N	2025-10-10 18:28:31.492337-05	Mendoza Díaz	8-2965-1138	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:31.492338-05	\N	\N	\N	f
25b93aeb-cb68-4a55-8ba0-4a8d08687e29	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Sofía	sofia.fernandez@pruebasipt.com	$2a$11$bXCV3mDmRiGJS39X38Wwvex2Q/xum3dI68cl3xH6Z6jd2r418rHXO	estudiante	active	f	\N	2025-10-10 18:28:32.078469-05	Romero Fernández	4-1139-1005	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:32.07847-05	\N	\N	\N	t
9d3dd5e4-bad3-4dea-8e4b-f535bd36fe6b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Ricardo	sofia.gomez1@pruebasipt.com	$2a$11$WgQts5.5h27Xd.mLaBlH9OhM1jrPhJwfbXxERK1P.CdwNMPIl/ELm	estudiante	active	f	\N	2025-10-10 18:28:32.663899-05	Ríos Gómez	7-8681-1187	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:32.663899-05	\N	\N	\N	f
44c2b6d1-1206-48f8-9fcb-d1e76af89034	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Diego	sofia.gomez@pruebasipt.com	$2a$11$asviQ9VnqMxEpdVUIhFN9.CGAcgJI6ODg/pArWCYdfWi109U9ob0u	estudiante	active	f	\N	2025-10-10 18:28:33.238926-05	Gómez Gómez	1-9814-1131	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:33.238926-05	\N	\N	\N	t
68be66ae-a6db-4b18-9445-152167b99dae	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Sofía	sofia.gonzalez1@pruebasipt.com	$2a$11$PlYJdKRyU2.mb6E0PW5.Xe6t0xaAR6v3sgbggpV..X.G7e.MoJK3a	estudiante	active	f	\N	2025-10-10 18:28:33.811702-05	Ríos González	3-2013-1043	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:33.811703-05	\N	\N	\N	f
92a68a3c-9712-41a7-b6eb-4b48e568ead8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía José	sofia.gonzalez@pruebasipt.com	$2a$11$bodzQQNP8PYkCQwYOhOxdOvr3gM4NQqVlhUWO.ZOVGfsIGsTYJ3bm	estudiante	active	f	\N	2025-10-10 18:28:34.395422-05	Díaz González	10-4652-1041	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:34.395423-05	\N	\N	\N	t
c8f7f33f-63d3-427f-85d8-aa64fd3c89d2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Carlos	sofia.jimenez1@pruebasipt.com	$2a$11$RPhqAwwlgf.VSMJlxirdlO9rpr/.ebkpQI/vYWO6pclVAyWNsSa9O	estudiante	active	f	\N	2025-10-10 18:28:34.972888-05	Gómez Jiménez	9-1520-1291	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:34.972889-05	\N	\N	\N	f
7836670e-23ac-4781-8fcd-2e742dac468d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Carlos	sofia.jimenez@pruebasipt.com	$2a$11$Fy2O0GtiXB2vbJhaNBoo7e9/s6si4V2kBvaKrm3zM5vI8lrMS0dxm	estudiante	active	f	\N	2025-10-10 18:28:35.559542-05	Fernández Jiménez	7-4329-1241	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:35.559543-05	\N	\N	\N	f
fa32c00c-3fe1-48a3-8ca0-c196e1fa1e58	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Esteban	sofia.lopez1@pruebasipt.com	$2a$11$Vsn5fUIRmQ.8hRw2sPuJzOjyEHZZx4HDwqjVn8x9xQj0nHrykQOMa	estudiante	active	f	\N	2025-10-10 18:28:36.15087-05	López López	5-8359-1329	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:36.15087-05	\N	\N	\N	t
74956414-21ff-4b7c-8cc3-7b49d460325f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Juan	sofia.lopez2@pruebasipt.com	$2a$11$O58tdtAItW6Jf7n3gsqXpuih//oH5yFBnHNfVDsgDqdaXzHHccjzy	estudiante	active	f	\N	2025-10-10 18:28:36.732083-05	Ríos López	7-1545-1338	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:36.732084-05	\N	\N	\N	f
a0e57c49-9afc-4e6c-8a16-137f18b41814	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Pedro	sofia.lopez@pruebasipt.com	$2a$11$ng2fT.iyyTLj27.p4eRm5eAsXIjS7wtk5XlpbJrr1FMiv0NFs0DNW	estudiante	active	f	\N	2025-10-10 18:28:37.347022-05	Torres López	1-1631-1150	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:37.347022-05	\N	\N	\N	f
35f0d242-a2cb-4060-b26f-c59195146b79	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía María	sofia.martinez1@pruebasipt.com	$2a$11$cE04dtAy5drKPSQBJkETnORuDZgjmD1ill3xH9jhWOACVI1Ghxq7O	estudiante	active	f	\N	2025-10-10 18:28:37.921616-05	Romero Martínez	3-6892-1219	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:37.921617-05	\N	\N	\N	f
758fcabb-0006-4fdf-bb0e-c2d8f5e8f779	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Esteban	sofia.martinez2@pruebasipt.com	$2a$11$AUGl3oCMH0vIcDCkfJeCqe1QjnfpE2ioZzEbyoqr6Bjwhu1dApLNa	estudiante	active	f	\N	2025-10-10 18:28:38.496878-05	Torres Martínez	2-6755-1336	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:38.496878-05	\N	\N	\N	f
4d2d8382-6d8d-41b9-943d-461d04b75526	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Daniel	sofia.martinez3@pruebasipt.com	$2a$11$e4W0vO/mxCb9sg7dFejZwuD/M9RQdd1f8vSLbmsiy90hdyk90J1U2	estudiante	active	f	\N	2025-10-10 18:28:39.081102-05	Romero Martínez	2-9291-1370	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:39.081102-05	\N	\N	\N	f
d430b226-0c8c-41c5-9941-640d99da2d8f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Esteban	sofia.martinez@pruebasipt.com	$2a$11$Cj1DSDXyLHu7mB6ItsY8p.omm30bkwqcxkHJWTQ/O1S8smZkgYpf2	estudiante	active	f	\N	2025-10-10 18:28:39.679213-05	Fernández Martínez	10-6600-1167	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:39.679213-05	\N	\N	\N	t
066717ce-64e8-42cb-82e5-26ad45c9302e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Sofía	sofia.moreno@pruebasipt.com	$2a$11$pG/n1K/YeavsSr3fICK45.Pu0oYPFGcXXgN6wpcHYK5DZZ1eYcz..	estudiante	active	f	\N	2025-10-10 18:28:40.253543-05	Gómez Moreno	7-4246-1312	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:40.253544-05	\N	\N	\N	f
6b614b15-09ca-42fb-a58d-375845d26412	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía María	sofia.rios@pruebasipt.com	$2a$11$BRONpTtrqW9Dgjq5X10HkOMuToIQlZzlnTlKEa3Em7mTLZ56PT/wa	estudiante	active	f	\N	2025-10-10 18:28:40.846637-05	Herrera Ríos	3-7093-1284	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:40.846637-05	\N	\N	\N	f
f5a389b7-3804-4711-aa26-24c4165d42b0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía José	sofia.rodriguez@pruebasipt.com	$2a$11$vq3R0HeGEtglxJ4NOVj/muk.eSyta9TNCTx1AhkieoiPR6EusZ6Me	estudiante	active	f	\N	2025-10-10 18:28:41.43063-05	Rodríguez Rodríguez	7-9764-1211	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:41.43063-05	\N	\N	\N	f
50b3d7ae-4142-45d4-b3e3-b2f11827daad	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Paola	sofia.romero@pruebasipt.com	$2a$11$vXtf1sr2hY7Neci4CTT2WesIbb3xV1ZvoZdy5iV52DfQEXXnSeVIm	estudiante	active	f	\N	2025-10-10 18:28:42.014824-05	Romero Romero	5-5778-1144	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:42.014824-05	\N	\N	\N	f
8a8c9472-7d18-4b54-af77-139504543d4d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Marta	sofia.sanchez@pruebasipt.com	$2a$11$o3RSPoIVz3QyaJZUpyQQXe7Sj5IZniHTPy3EPSJjhaLN0WwG.DD.q	estudiante	active	f	\N	2025-10-10 18:28:42.601613-05	Torres Sánchez	1-6448-1111	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:42.601613-05	\N	\N	\N	f
869bb49c-25ff-4830-89c7-231eaa6461bc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sofía Carlos	sofia.torres@pruebasipt.com	$2a$11$Kh.zJbGOkAl2VbcrUC.PF.TeFO66IDbLw8Zev5S3ReOBL/5uVVN5G	estudiante	active	f	\N	2025-10-10 18:28:43.197812-05	Vargas Torres	8-2512-1201	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:43.197812-05	\N	\N	\N	f
da25eddc-c94c-4a3d-b0af-ad35c5a8d076	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Andrés	valeria.chavez@pruebasipt.com	$2a$11$hpHsPw9s10v1m/QbxWsE/O1rjhUsWs1LtHjsflx1FXKyiR55MNfsK	estudiante	active	f	\N	2025-10-10 18:28:43.772777-05	Romero Chávez	3-9572-1260	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:43.772777-05	\N	\N	\N	f
e77b28ca-bc20-4ec8-bfc0-6eb7165d9bb7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Ricardo	valeria.cordoba1@pruebasipt.com	$2a$11$P.v0OEv5.0WgaC0aFoXRsuzZ9ifTrWwnJ1bDm4O8NBO2JyDPqIOIK	estudiante	active	f	\N	2025-10-10 18:28:44.368037-05	Gómez Córdoba	8-1672-1028	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:44.368037-05	\N	\N	\N	f
fe7695e4-42c1-43f5-9e58-1376d191b1e2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Ana	valeria.cordoba2@pruebasipt.com	$2a$11$7GopK9iEN/2tIDTQoQCF9OxUtGBRhjiK26biHDwAVoyxFkYmyugGW	estudiante	active	f	\N	2025-10-10 18:28:44.951927-05	Herrera Córdoba	7-3933-1212	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:44.951927-05	\N	\N	\N	f
0895be20-cb13-4e22-a1bb-c347081d7aef	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Ana	valeria.cordoba@pruebasipt.com	$2a$11$F8bWUvjtm3ZgY9XpLlc60elCrqA3asplE6LolsM3y1Zhvaig4vvpG	estudiante	active	f	\N	2025-10-10 18:28:45.53766-05	Ríos Córdoba	1-7562-1008	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:45.53766-05	\N	\N	\N	f
b3c2d678-70bf-4c07-abc4-b19ae8437bd5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Sofía	valeria.fernandez1@pruebasipt.com	$2a$11$uYZrms9K/.GN3pz3c5/9iOAV8TFrJgFFXZvwud1oylvZ5THF0./wG	estudiante	active	f	\N	2025-10-10 18:28:46.128928-05	Martínez Fernández	7-6663-1186	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:46.128929-05	\N	\N	\N	f
e994cb6c-df9b-40a6-a28a-0265389da25e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Valeria	valeria.fernandez2@pruebasipt.com	$2a$11$f4SisPAtKN7Mbfe5PN/WmuLlHMAmyEbeRwrRUW4HqKhIk68k1ivHi	estudiante	active	f	\N	2025-10-10 18:28:46.724672-05	Moreno Fernández	6-7245-1220	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:46.724672-05	\N	\N	\N	f
e7ebe45d-58eb-40c5-89dd-0604b654d25a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Paola	valeria.fernandez3@pruebasipt.com	$2a$11$v94Q8i5I3PZqvMa6uunSeeukuSb6Blt1G7tzsZAuNPfA17wTMOWYy	estudiante	active	f	\N	2025-10-10 18:28:47.218869-05	Fernández Fernández	8-8570-1316	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:47.21887-05	\N	\N	\N	f
637287c0-ae08-437c-86e4-639f5b4be9be	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Julio	valeria.fernandez4@pruebasipt.com	$2a$11$kJbxklS1q2XrhhYnMS1Qee95lXLnYhNhiAksUuZcx7bplbQS43zFW	estudiante	active	f	\N	2025-10-10 18:28:47.803374-05	Torres Fernández	8-9450-1339	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:47.803374-05	\N	\N	\N	f
d5b0f8fe-2ae1-4a6e-a812-f2545b22baa2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Carlos	valeria.fernandez@pruebasipt.com	$2a$11$iuUe2/RG4oj6BgUw9yKEGuhQ/xAy6teVkOt0MJvdbivRoUHomZgRG	estudiante	active	f	\N	2025-10-10 18:28:48.37762-05	González Fernández	6-8199-1164	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:48.377621-05	\N	\N	\N	f
0337e5cf-a51d-404d-9cd0-aa65b3bd9a00	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Camila	valeria.gomez1@pruebasipt.com	$2a$11$OHmfW5p28pihsLSO6FFm0OqniY9n.lDYAQx.TI6u.KrF9hFgM0p8S	estudiante	active	f	\N	2025-10-10 18:28:48.968569-05	Pérez Gómez	7-9192-1140	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:48.968569-05	\N	\N	\N	f
655d2e73-a379-4165-8b4a-4c53ed855409	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Camila	valeria.gomez2@pruebasipt.com	$2a$11$w0pO70HKAMwu5BsofAwS5uvNoL4jS/dGZ/MyRX3TtyFjMQeWP4d4C	estudiante	active	f	\N	2025-10-10 18:28:49.56837-05	Gómez Gómez	1-7003-1293	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:49.56837-05	\N	\N	\N	t
52197395-aa1a-4906-b5cb-bbabe98ecf62	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Camila	valeria.gomez@pruebasipt.com	$2a$11$sGN1P6/o3B8a2OgnZEFNf.RRXDl4MTBbNPkJ3AJqCpoYoGoEdOH..	estudiante	active	f	\N	2025-10-10 18:28:50.153556-05	Pérez Gómez	6-6143-1052	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:50.153557-05	\N	\N	\N	f
47f52a98-3c46-49be-bc22-c85a38ff284f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Elena	valeria.gonzalez1@pruebasipt.com	$2a$11$Jg5CZP9BBFT7g1zmzyVEVun1FPKpkjHO/SXnXbIOrzVXyI0NobgXa	estudiante	active	f	\N	2025-10-10 18:28:50.751766-05	Pérez González	5-5198-1250	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:50.751766-05	\N	\N	\N	f
0b1ebe2e-c112-499f-a898-0ce02ec3f68c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Diego	valeria.gonzalez2@pruebasipt.com	$2a$11$gH9zDh.FuRyW5GEIEEfICOYIkukCtBOv0fjq353oCJ5EbWOhh2p4q	estudiante	active	f	\N	2025-10-10 18:28:51.329989-05	Mendoza González	9-7741-1255	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:51.32999-05	\N	\N	\N	f
717c1acd-b2bf-4bb0-a9e5-06f6e9342954	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Ana	valeria.gonzalez3@pruebasipt.com	$2a$11$7RWAmBEJQqlch8rnvIpxs.S2EHMKXXqBnV5kxw/GcXXrGepPzHDoC	estudiante	active	f	\N	2025-10-10 18:28:51.898571-05	González González	3-8679-1382	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:51.898572-05	\N	\N	\N	f
2ed9d651-6bee-499b-aa29-8398b6f4984a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Elena	valeria.gonzalez@pruebasipt.com	$2a$11$DW15VEYfb1gxG5qEDTiPTeF50ayEBzqRiLqy8YW7Cj9.zr2RO42Ri	estudiante	active	f	\N	2025-10-10 18:28:52.504643-05	Castillo González	8-5270-1110	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:52.504644-05	\N	\N	\N	f
eb94a9b3-78ce-4c9d-a135-8423af016ae8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Valeria	valeria.herrera1@pruebasipt.com	$2a$11$gQEWHVj2DFv3JYnO2v0EeePUByCrB5BpvymtSZ9FwbzNwHdosfj52	estudiante	active	f	\N	2025-10-10 18:28:53.105018-05	González Herrera	1-7655-1358	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:53.105019-05	\N	\N	\N	f
fe65612f-8a69-4cbb-ace5-bc4c5129416b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Marta	valeria.herrera@pruebasipt.com	$2a$11$VPz6CbbHqIgi6ZDh0.vQ1uBAhMoeeJGisfTQYWTnRYbcRt3Rn8Cna	estudiante	active	f	\N	2025-10-10 18:28:53.691891-05	Moreno Herrera	4-7099-1058	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:53.691891-05	\N	\N	\N	f
8c46517a-7560-43aa-9ecd-ea76e180a1dc	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Ana	valeria.lopez@pruebasipt.com	$2a$11$Sgb6gzbt8dEJBckNlGTdIu0gQZTRHLWyfOLZ25VWGLNE0.A3Wem1a	estudiante	active	f	\N	2025-10-10 18:28:54.278222-05	Jiménez López	3-4203-1278	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:54.278222-05	\N	\N	\N	f
66be866f-0099-4832-894b-62afd1314776	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria María	valeria.mendoza@pruebasipt.com	$2a$11$vzd1jC/gZGTCHKzwjMBl0Ob7vRyFqmXcn9Yc1ovjvDMcX0s6QHk3K	estudiante	active	f	\N	2025-10-10 18:28:54.845877-05	González Mendoza	10-4854-1010	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:54.845878-05	\N	\N	\N	f
2c13241c-12a6-4d86-b020-91f55c7a41eb	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Carlos	valeria.rios@pruebasipt.com	$2a$11$KgEgESecUQBQ4vURBITU1uYRMX54o445wg41yRtT48Wm7vEi6PDLy	estudiante	active	f	\N	2025-10-10 18:28:55.389929-05	Mendoza Ríos	5-5659-1004	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:55.38993-05	\N	\N	\N	f
9f678622-dbde-4ef6-b325-c8c613bd2dad	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Esteban	valeria.sanchez@pruebasipt.com	$2a$11$cGctx4eHBKj4kxE0yJsSFeNKyuCqdseuM1SEFefgdhlTesNtvRhTW	estudiante	active	f	\N	2025-10-10 18:28:55.979267-05	Herrera Sánchez	9-8799-1231	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:55.979267-05	\N	\N	\N	f
9392aedc-121e-4b6b-93f5-23cfaf6d772b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Valeria Esteban	valeria.torres@pruebasipt.com	$2a$11$i7K2ZLcf1xYLJLHYVrvjNuRqBYDC07ukNKIoMTEy1pO7FxpK0vBAq	estudiante	active	f	\N	2025-10-10 18:28:56.553151-05	Romero Torres	6-6924-1368	1999-01-01 19:00:00-05	\N	\N	\N	\N	\N	2025-10-10 18:28:56.553151-05	\N	\N	\N	f
21e66209-995a-4182-98e9-33d2ab635b48	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Quenna	quenna.lopez@qlservice.net	$2a$11$ijYC6tyYjXnk.l2uWu.0QeINxiYVKAVhEHwTbaTg5CUtEtlTEZ8i6	admin	active	f	2025-10-10 18:45:58.135871-05	2025-09-06 11:58:51.905454-05	Lopez	\N	2025-09-05 19:00:00-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
37ff9dbc-e400-4e6f-a6da-63bfe88ff602	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Adrinis Elena	adrinis.alvarado@meduca.edu.pa	$2a$11$hqCUElgIP29sBQczT0MF2.d9uxRAsrpM1wUfUz0Gx9JHWJCy2P13G	teacher	active	f	2025-10-10 19:11:56.048111-05	2025-10-10 18:23:23.226598-05	Alvarado Rodríguez	9-734-2020	2000-10-10 18:23:22.772035-05	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5096 (class 2606 OID 20011)
-- Name: EmailConfigurations PK_EmailConfigurations; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmailConfigurations"
    ADD CONSTRAINT "PK_EmailConfigurations" PRIMARY KEY ("Id");


--
-- TOC entry 5098 (class 2606 OID 20013)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 5104 (class 2606 OID 20015)
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- TOC entry 5110 (class 2606 OID 20017)
-- Name: activity_attachments activity_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 5115 (class 2606 OID 20019)
-- Name: activity_types activity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5119 (class 2606 OID 20021)
-- Name: area area_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--
-- TOC entry 5125 (class 2606 OID 20023)
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- TOC entry 5129 (class 2606 OID 20025)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 5131 (class 2606 OID 20027)
-- Name: counselor_assignments counselor_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5144 (class 2606 OID 20029)
-- Name: discipline_reports discipline_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 5146 (class 2606 OID 20031)
-- Name: email_configurations email_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_configurations
    ADD CONSTRAINT email_configurations_pkey PRIMARY KEY (id);


--
-- TOC entry 5150 (class 2606 OID 20033)
-- Name: grade_levels grade_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_levels
    ADD CONSTRAINT grade_levels_pkey PRIMARY KEY (id);


--
-- TOC entry 5153 (class 2606 OID 20035)
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- TOC entry 5221 (class 2606 OID 20787)
-- Name: orientation_reports orientation_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT orientation_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 5156 (class 2606 OID 20037)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 5159 (class 2606 OID 20039)
-- Name: security_settings security_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 5162 (class 2606 OID 20041)
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- TOC entry 5166 (class 2606 OID 20043)
-- Name: student_activity_scores student_activity_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 5172 (class 2606 OID 20045)
-- Name: student_assignments student_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT student_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5176 (class 2606 OID 20047)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 5183 (class 2606 OID 20049)
-- Name: subject_assignments subject_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5187 (class 2606 OID 20051)
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 5190 (class 2606 OID 20053)
-- Name: teacher_assignments teacher_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5195 (class 2606 OID 20055)
-- Name: trimester trimester_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_pkey PRIMARY KEY (id);


--
-- TOC entry 5198 (class 2606 OID 20057)
-- Name: user_grades user_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT user_grades_pkey PRIMARY KEY (user_id, grade_id);


--
-- TOC entry 5201 (class 2606 OID 20059)
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (user_id, group_id);


--
-- TOC entry 5204 (class 2606 OID 20061)
-- Name: user_subjects user_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT user_subjects_pkey PRIMARY KEY (user_id, subject_id);


--
-- TOC entry 5211 (class 2606 OID 20063)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5094 (class 1259 OID 20064)
-- Name: IX_EmailConfigurations_SchoolId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_EmailConfigurations_SchoolId" ON public."EmailConfigurations" USING btree ("SchoolId");


--
-- TOC entry 5099 (class 1259 OID 20065)
-- Name: IX_activities_ActivityTypeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_ActivityTypeId" ON public.activities USING btree ("ActivityTypeId");


--
-- TOC entry 5100 (class 1259 OID 20066)
-- Name: IX_activities_TrimesterId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_TrimesterId" ON public.activities USING btree ("TrimesterId");


--
-- TOC entry 5101 (class 1259 OID 20067)
-- Name: IX_activities_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_school_id" ON public.activities USING btree (school_id);


--
-- TOC entry 5102 (class 1259 OID 20068)
-- Name: IX_activities_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_subject_id" ON public.activities USING btree (subject_id);


--
-- TOC entry 5112 (class 1259 OID 20069)
-- Name: IX_activity_types_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activity_types_school_id" ON public.activity_types USING btree (school_id);


--
-- TOC entry 5116 (class 1259 OID 20070)
-- Name: IX_area_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_area_school_id" ON public.area USING btree (school_id);


--
-- TOC entry 5120 (class 1259 OID 20071)
-- Name: IX_attendance_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_grade_id" ON public.attendance USING btree (grade_id);


--
-- TOC entry 5121 (class 1259 OID 20072)
-- Name: IX_attendance_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_group_id" ON public.attendance USING btree (group_id);


--
-- TOC entry 5122 (class 1259 OID 20073)
-- Name: IX_attendance_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_student_id" ON public.attendance USING btree (student_id);


--
-- TOC entry 5123 (class 1259 OID 20074)
-- Name: IX_attendance_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_teacher_id" ON public.attendance USING btree (teacher_id);


--
-- TOC entry 5126 (class 1259 OID 20075)
-- Name: IX_audit_logs_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_audit_logs_school_id" ON public.audit_logs USING btree (school_id);


--
-- TOC entry 5127 (class 1259 OID 20076)
-- Name: IX_audit_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_audit_logs_user_id" ON public.audit_logs USING btree (user_id);


--
-- TOC entry 5138 (class 1259 OID 20077)
-- Name: IX_discipline_reports_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_grade_level_id" ON public.discipline_reports USING btree (grade_level_id);


--
-- TOC entry 5139 (class 1259 OID 20078)
-- Name: IX_discipline_reports_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_group_id" ON public.discipline_reports USING btree (group_id);


--
-- TOC entry 5140 (class 1259 OID 20079)
-- Name: IX_discipline_reports_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_student_id" ON public.discipline_reports USING btree (student_id);


--
-- TOC entry 5141 (class 1259 OID 20080)
-- Name: IX_discipline_reports_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_subject_id" ON public.discipline_reports USING btree (subject_id);


--
-- TOC entry 5142 (class 1259 OID 20081)
-- Name: IX_discipline_reports_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_teacher_id" ON public.discipline_reports USING btree (teacher_id);


--
-- TOC entry 5151 (class 1259 OID 20082)
-- Name: IX_groups_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_groups_school_id" ON public.groups USING btree (school_id);


--
-- TOC entry 5212 (class 1259 OID 20788)
-- Name: IX_orientation_reports_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orientation_reports_created_by" ON public.orientation_reports USING btree (created_by);


--
-- TOC entry 5213 (class 1259 OID 20789)
-- Name: IX_orientation_reports_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orientation_reports_grade_level_id" ON public.orientation_reports USING btree (grade_level_id);


--
-- TOC entry 5214 (class 1259 OID 20790)
-- Name: IX_orientation_reports_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orientation_reports_group_id" ON public.orientation_reports USING btree (group_id);


--
-- TOC entry 5215 (class 1259 OID 20791)
-- Name: IX_orientation_reports_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orientation_reports_school_id" ON public.orientation_reports USING btree (school_id);


--
-- TOC entry 5216 (class 1259 OID 20792)
-- Name: IX_orientation_reports_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orientation_reports_student_id" ON public.orientation_reports USING btree (student_id);


--
-- TOC entry 5217 (class 1259 OID 20793)
-- Name: IX_orientation_reports_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orientation_reports_subject_id" ON public.orientation_reports USING btree (subject_id);


--
-- TOC entry 5218 (class 1259 OID 20794)
-- Name: IX_orientation_reports_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orientation_reports_teacher_id" ON public.orientation_reports USING btree (teacher_id);


--
-- TOC entry 5219 (class 1259 OID 20795)
-- Name: IX_orientation_reports_updated_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_orientation_reports_updated_by" ON public.orientation_reports USING btree (updated_by);


--
-- TOC entry 5154 (class 1259 OID 20083)
-- Name: IX_schools_admin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_schools_admin_id" ON public.schools USING btree (admin_id);


--
-- TOC entry 5157 (class 1259 OID 20084)
-- Name: IX_security_settings_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_security_settings_school_id" ON public.security_settings USING btree (school_id);


--
-- TOC entry 5168 (class 1259 OID 20085)
-- Name: IX_student_assignments_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_grade_id" ON public.student_assignments USING btree (grade_id);


--
-- TOC entry 5169 (class 1259 OID 20086)
-- Name: IX_student_assignments_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_group_id" ON public.student_assignments USING btree (group_id);


--
-- TOC entry 5170 (class 1259 OID 20087)
-- Name: IX_student_assignments_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_student_id" ON public.student_assignments USING btree (student_id);


--
-- TOC entry 5173 (class 1259 OID 20088)
-- Name: IX_students_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_students_parent_id" ON public.students USING btree (parent_id);


--
-- TOC entry 5174 (class 1259 OID 20089)
-- Name: IX_students_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_students_school_id" ON public.students USING btree (school_id);


--
-- TOC entry 5177 (class 1259 OID 20090)
-- Name: IX_subject_assignments_SchoolId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_SchoolId" ON public.subject_assignments USING btree ("SchoolId");


--
-- TOC entry 5178 (class 1259 OID 20091)
-- Name: IX_subject_assignments_area_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_area_id" ON public.subject_assignments USING btree (area_id);


--
-- TOC entry 5179 (class 1259 OID 20092)
-- Name: IX_subject_assignments_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_grade_level_id" ON public.subject_assignments USING btree (grade_level_id);


--
-- TOC entry 5180 (class 1259 OID 20093)
-- Name: IX_subject_assignments_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_group_id" ON public.subject_assignments USING btree (group_id);


--
-- TOC entry 5181 (class 1259 OID 20094)
-- Name: IX_subject_assignments_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_subject_id" ON public.subject_assignments USING btree (subject_id);


--
-- TOC entry 5184 (class 1259 OID 20095)
-- Name: IX_subjects_AreaId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subjects_AreaId" ON public.subjects USING btree ("AreaId");


--
-- TOC entry 5185 (class 1259 OID 20096)
-- Name: IX_subjects_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subjects_school_id" ON public.subjects USING btree (school_id);


--
-- TOC entry 5188 (class 1259 OID 20097)
-- Name: IX_teacher_assignments_subject_assignment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_teacher_assignments_subject_assignment_id" ON public.teacher_assignments USING btree (subject_assignment_id);


--
-- TOC entry 5192 (class 1259 OID 20098)
-- Name: IX_trimester_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_trimester_school_id" ON public.trimester USING btree (school_id);


--
-- TOC entry 5196 (class 1259 OID 20099)
-- Name: IX_user_grades_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_grades_grade_id" ON public.user_grades USING btree (grade_id);


--
-- TOC entry 5199 (class 1259 OID 20100)
-- Name: IX_user_groups_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_groups_group_id" ON public.user_groups USING btree (group_id);


--
-- TOC entry 5202 (class 1259 OID 20101)
-- Name: IX_user_subjects_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_subjects_subject_id" ON public.user_subjects USING btree (subject_id);


--
-- TOC entry 5205 (class 1259 OID 20102)
-- Name: IX_users_cellphone_primary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_cellphone_primary" ON public.users USING btree (cellphone_primary);


--
-- TOC entry 5206 (class 1259 OID 20103)
-- Name: IX_users_cellphone_secondary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_cellphone_secondary" ON public.users USING btree (cellphone_secondary);


--
-- TOC entry 5207 (class 1259 OID 20104)
-- Name: IX_users_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_school_id" ON public.users USING btree (school_id);


--
-- TOC entry 5113 (class 1259 OID 20105)
-- Name: activity_types_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX activity_types_name_school_key ON public.activity_types USING btree (name, school_id);


--
-- TOC entry 5117 (class 1259 OID 20106)
-- Name: area_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX area_name_school_key ON public.area USING btree (name, school_id);


--
-- TOC entry 5132 (class 1259 OID 20107)
-- Name: counselor_assignments_school_grade_group_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX counselor_assignments_school_grade_group_key ON public.counselor_assignments USING btree (school_id, grade_id, group_id) WHERE ((grade_id IS NOT NULL) AND (group_id IS NOT NULL));


--
-- TOC entry 5133 (class 1259 OID 20108)
-- Name: counselor_assignments_school_user_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX counselor_assignments_school_user_key ON public.counselor_assignments USING btree (school_id, user_id);


--
-- TOC entry 5148 (class 1259 OID 20109)
-- Name: grade_levels_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_levels_name_key ON public.grade_levels USING btree (name);


--
-- TOC entry 5105 (class 1259 OID 20110)
-- Name: idx_activities_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_group ON public.activities USING btree (group_id);


--
-- TOC entry 5106 (class 1259 OID 20111)
-- Name: idx_activities_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_teacher ON public.activities USING btree (teacher_id);


--
-- TOC entry 5107 (class 1259 OID 20112)
-- Name: idx_activities_trimester; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_trimester ON public.activities USING btree (trimester);


--
-- TOC entry 5108 (class 1259 OID 20113)
-- Name: idx_activities_unique_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_unique_lookup ON public.activities USING btree (name, type, subject_id, group_id, teacher_id, trimester);


--
-- TOC entry 5111 (class 1259 OID 20114)
-- Name: idx_attach_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attach_activity ON public.activity_attachments USING btree (activity_id);


--
-- TOC entry 5134 (class 1259 OID 20115)
-- Name: idx_counselor_assignments_grade; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_grade ON public.counselor_assignments USING btree (grade_id);


--
-- TOC entry 5135 (class 1259 OID 20116)
-- Name: idx_counselor_assignments_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_group ON public.counselor_assignments USING btree (group_id);


--
-- TOC entry 5136 (class 1259 OID 20117)
-- Name: idx_counselor_assignments_school; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_school ON public.counselor_assignments USING btree (school_id);


--
-- TOC entry 5137 (class 1259 OID 20118)
-- Name: idx_counselor_assignments_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_user ON public.counselor_assignments USING btree (user_id);


--
-- TOC entry 5147 (class 1259 OID 20119)
-- Name: idx_email_configurations_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_email_configurations_school_id ON public.email_configurations USING btree (school_id);


--
-- TOC entry 5163 (class 1259 OID 20120)
-- Name: idx_scores_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scores_activity ON public.student_activity_scores USING btree (activity_id);


--
-- TOC entry 5164 (class 1259 OID 20121)
-- Name: idx_scores_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scores_student ON public.student_activity_scores USING btree (student_id);


--
-- TOC entry 5160 (class 1259 OID 20122)
-- Name: specialties_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX specialties_name_key ON public.specialties USING btree (name);


--
-- TOC entry 5191 (class 1259 OID 20123)
-- Name: teacher_assignments_teacher_id_subject_assignment_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX teacher_assignments_teacher_id_subject_assignment_id_key ON public.teacher_assignments USING btree (teacher_id, subject_assignment_id);


--
-- TOC entry 5193 (class 1259 OID 20124)
-- Name: trimester_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX trimester_name_school_key ON public.trimester USING btree (name, school_id);


--
-- TOC entry 5167 (class 1259 OID 20125)
-- Name: uq_scores; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_scores ON public.student_activity_scores USING btree (student_id, activity_id);


--
-- TOC entry 5208 (class 1259 OID 20126)
-- Name: users_document_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_document_id_key ON public.users USING btree (document_id);


--
-- TOC entry 5209 (class 1259 OID 20127)
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- TOC entry 5222 (class 2606 OID 20128)
-- Name: EmailConfigurations FK_EmailConfigurations_schools_SchoolId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmailConfigurations"
    ADD CONSTRAINT "FK_EmailConfigurations_schools_SchoolId" FOREIGN KEY ("SchoolId") REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5223 (class 2606 OID 20133)
-- Name: activities FK_activities_activity_types_ActivityTypeId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_activity_types_ActivityTypeId" FOREIGN KEY ("ActivityTypeId") REFERENCES public.activity_types(id);


--
-- TOC entry 5224 (class 2606 OID 20138)
-- Name: activities FK_activities_trimester_TrimesterId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_trimester_TrimesterId" FOREIGN KEY ("TrimesterId") REFERENCES public.trimester(id);


--
-- TOC entry 5280 (class 2606 OID 20796)
-- Name: orientation_reports FK_orientation_reports_schools_school_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT "FK_orientation_reports_schools_school_id" FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- TOC entry 5281 (class 2606 OID 20801)
-- Name: orientation_reports FK_orientation_reports_users_created_by; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT "FK_orientation_reports_users_created_by" FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- TOC entry 5282 (class 2606 OID 20806)
-- Name: orientation_reports FK_orientation_reports_users_updated_by; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT "FK_orientation_reports_users_updated_by" FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- TOC entry 5252 (class 2606 OID 20143)
-- Name: schools FK_schools_users_admin_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT "FK_schools_users_admin_id" FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- TOC entry 5262 (class 2606 OID 20148)
-- Name: subject_assignments FK_subject_assignments_schools_SchoolId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT "FK_subject_assignments_schools_SchoolId" FOREIGN KEY ("SchoolId") REFERENCES public.schools(id);


--
-- TOC entry 5268 (class 2606 OID 20153)
-- Name: subjects FK_subjects_area_AreaId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT "FK_subjects_area_AreaId" FOREIGN KEY ("AreaId") REFERENCES public.area(id);


--
-- TOC entry 5225 (class 2606 OID 20158)
-- Name: activities activities_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5226 (class 2606 OID 20163)
-- Name: activities activities_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5227 (class 2606 OID 20168)
-- Name: activities activities_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5228 (class 2606 OID 20173)
-- Name: activities activities_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5229 (class 2606 OID 20178)
-- Name: activity_attachments activity_attachments_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5230 (class 2606 OID 20183)
-- Name: activity_types activity_types_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5231 (class 2606 OID 20188)
-- Name: area area_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5232 (class 2606 OID 20193)
-- Name: attendance attendance_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5233 (class 2606 OID 20198)
-- Name: attendance attendance_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5234 (class 2606 OID 20203)
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5235 (class 2606 OID 20208)
-- Name: attendance attendance_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5239 (class 2606 OID 20213)
-- Name: audit_logs audit_logs_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- TOC entry 5240 (class 2606 OID 20218)
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5241 (class 2606 OID 20223)
-- Name: counselor_assignments counselor_assignments_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id) ON DELETE SET NULL;


--
-- TOC entry 5242 (class 2606 OID 20228)
-- Name: counselor_assignments counselor_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- TOC entry 5243 (class 2606 OID 20233)
-- Name: counselor_assignments counselor_assignments_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5244 (class 2606 OID 20238)
-- Name: counselor_assignments counselor_assignments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5245 (class 2606 OID 20243)
-- Name: discipline_reports discipline_reports_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5246 (class 2606 OID 20248)
-- Name: discipline_reports discipline_reports_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5247 (class 2606 OID 20253)
-- Name: discipline_reports discipline_reports_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5248 (class 2606 OID 20258)
-- Name: discipline_reports discipline_reports_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5249 (class 2606 OID 20263)
-- Name: discipline_reports discipline_reports_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5250 (class 2606 OID 20268)
-- Name: email_configurations email_configurations_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_configurations
    ADD CONSTRAINT email_configurations_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5236 (class 2606 OID 20405)
-- Name: attendance fk_attendance_created_by; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_created_by FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5237 (class 2606 OID 20415)
-- Name: attendance fk_attendance_school; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_school FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5238 (class 2606 OID 20410)
-- Name: attendance fk_attendance_updated_by; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT fk_attendance_updated_by FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5257 (class 2606 OID 20273)
-- Name: student_assignments fk_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5258 (class 2606 OID 20278)
-- Name: student_assignments fk_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5259 (class 2606 OID 20283)
-- Name: student_assignments fk_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5254 (class 2606 OID 20400)
-- Name: student_activity_scores fk_student_activity_scores_school; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT fk_student_activity_scores_school FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5273 (class 2606 OID 20288)
-- Name: user_grades fk_user_grades_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5274 (class 2606 OID 20293)
-- Name: user_grades fk_user_grades_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5275 (class 2606 OID 20298)
-- Name: user_groups fk_user_groups_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5276 (class 2606 OID 20303)
-- Name: user_groups fk_user_groups_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5277 (class 2606 OID 20308)
-- Name: user_subjects fk_user_subjects_subject; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_subject FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5278 (class 2606 OID 20313)
-- Name: user_subjects fk_user_subjects_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5251 (class 2606 OID 20318)
-- Name: groups groups_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5283 (class 2606 OID 20811)
-- Name: orientation_reports orientation_reports_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT orientation_reports_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5284 (class 2606 OID 20816)
-- Name: orientation_reports orientation_reports_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT orientation_reports_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5285 (class 2606 OID 20821)
-- Name: orientation_reports orientation_reports_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT orientation_reports_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5286 (class 2606 OID 20826)
-- Name: orientation_reports orientation_reports_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT orientation_reports_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5287 (class 2606 OID 20831)
-- Name: orientation_reports orientation_reports_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orientation_reports
    ADD CONSTRAINT orientation_reports_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5253 (class 2606 OID 20323)
-- Name: security_settings security_settings_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5255 (class 2606 OID 20328)
-- Name: student_activity_scores student_activity_scores_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5256 (class 2606 OID 20333)
-- Name: student_activity_scores student_activity_scores_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5260 (class 2606 OID 20338)
-- Name: students students_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- TOC entry 5261 (class 2606 OID 20343)
-- Name: students students_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5263 (class 2606 OID 20348)
-- Name: subject_assignments subject_assignments_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.area(id);


--
-- TOC entry 5264 (class 2606 OID 20353)
-- Name: subject_assignments subject_assignments_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5265 (class 2606 OID 20358)
-- Name: subject_assignments subject_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5266 (class 2606 OID 20363)
-- Name: subject_assignments subject_assignments_specialty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES public.specialties(id);


--
-- TOC entry 5267 (class 2606 OID 20368)
-- Name: subject_assignments subject_assignments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5269 (class 2606 OID 20373)
-- Name: subjects subjects_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5270 (class 2606 OID 20378)
-- Name: teacher_assignments teacher_assignments_subject_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_subject_assignment_id_fkey FOREIGN KEY (subject_assignment_id) REFERENCES public.subject_assignments(id);


--
-- TOC entry 5271 (class 2606 OID 20383)
-- Name: teacher_assignments teacher_assignments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5272 (class 2606 OID 20388)
-- Name: trimester trimester_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5279 (class 2606 OID 20393)
-- Name: users users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


-- Completed on 2025-10-10 19:59:42

--
-- PostgreSQL database dump complete
--

\unrestrict YByRdQ9wcetVAl5UcyolaTCwAAC76prP5Por0LW09DfXKHaBPHxiuwMHrhLfatY

