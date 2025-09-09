--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-09-07 19:02:51

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
-- TOC entry 7 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: admin
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO admin;

--
-- TOC entry 2 (class 3079 OID 201462)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 3 (class 3079 OID 201499)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 245 (class 1259 OID 202596)
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
-- TOC entry 219 (class 1259 OID 201510)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO admin;

--
-- TOC entry 220 (class 1259 OID 201513)
-- Name: activities; Type: TABLE; Schema: public; Owner: admin
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
    due_date timestamp with time zone
);


ALTER TABLE public.activities OWNER TO admin;

--
-- TOC entry 221 (class 1259 OID 201520)
-- Name: activity_attachments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.activity_attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    activity_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    storage_path character varying(500) NOT NULL,
    mime_type character varying(50) NOT NULL,
    uploaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.activity_attachments OWNER TO admin;

--
-- TOC entry 222 (class 1259 OID 201527)
-- Name: activity_types; Type: TABLE; Schema: public; Owner: admin
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
    updated_at timestamp with time zone
);


ALTER TABLE public.activity_types OWNER TO admin;

--
-- TOC entry 223 (class 1259 OID 201537)
-- Name: area; Type: TABLE; Schema: public; Owner: admin
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
    updated_at timestamp with time zone
);


ALTER TABLE public.area OWNER TO admin;

--
-- TOC entry 224 (class 1259 OID 201547)
-- Name: attendance; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid,
    teacher_id uuid,
    group_id uuid,
    grade_id uuid,
    date date NOT NULL,
    status character varying(10) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.attendance OWNER TO admin;

--
-- TOC entry 225 (class 1259 OID 201552)
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: admin
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
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO admin;

--
-- TOC entry 244 (class 1259 OID 202042)
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
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.counselor_assignments OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 201559)
-- Name: discipline_reports; Type: TABLE; Schema: public; Owner: admin
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
    grade_level_id uuid
);


ALTER TABLE public.discipline_reports OWNER TO admin;

--
-- TOC entry 227 (class 1259 OID 201566)
-- Name: email_configurations; Type: TABLE; Schema: public; Owner: admin
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


ALTER TABLE public.email_configurations OWNER TO admin;

--
-- TOC entry 5328 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE email_configurations; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON TABLE public.email_configurations IS 'Configuración de servidores SMTP para cada escuela';


--
-- TOC entry 5329 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN email_configurations.smtp_use_ssl; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.email_configurations.smtp_use_ssl IS 'Usar SSL para conexión SMTP';


--
-- TOC entry 5330 (class 0 OID 0)
-- Dependencies: 227
-- Name: COLUMN email_configurations.smtp_use_tls; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.email_configurations.smtp_use_tls IS 'Usar TLS para conexión SMTP';


--
-- TOC entry 228 (class 1259 OID 201578)
-- Name: grade_levels; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.grade_levels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.grade_levels OWNER TO admin;

--
-- TOC entry 229 (class 1259 OID 201585)
-- Name: groups; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.groups (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(20) NOT NULL,
    grade character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    description text
);


ALTER TABLE public.groups OWNER TO admin;

--
-- TOC entry 230 (class 1259 OID 201592)
-- Name: schools; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.schools (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(200) DEFAULT ''::character varying NOT NULL,
    phone character varying(20) DEFAULT ''::character varying NOT NULL,
    logo_url character varying(500),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    admin_id uuid
);


ALTER TABLE public.schools OWNER TO admin;

--
-- TOC entry 231 (class 1259 OID 201601)
-- Name: security_settings; Type: TABLE; Schema: public; Owner: admin
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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.security_settings OWNER TO admin;

--
-- TOC entry 232 (class 1259 OID 201615)
-- Name: specialties; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.specialties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.specialties OWNER TO admin;

--
-- TOC entry 233 (class 1259 OID 201622)
-- Name: student_activity_scores; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.student_activity_scores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    activity_id uuid NOT NULL,
    score numeric(2,1),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.student_activity_scores OWNER TO admin;

--
-- TOC entry 234 (class 1259 OID 201627)
-- Name: student_assignments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.student_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    grade_id uuid NOT NULL,
    group_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.student_assignments OWNER TO admin;

--
-- TOC entry 235 (class 1259 OID 201632)
-- Name: students; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.students (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(100) NOT NULL,
    birth_date date,
    grade character varying(20),
    group_name character varying(20),
    parent_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.students OWNER TO admin;

--
-- TOC entry 236 (class 1259 OID 201637)
-- Name: subject_assignments; Type: TABLE; Schema: public; Owner: admin
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
    "SchoolId" uuid
);


ALTER TABLE public.subject_assignments OWNER TO admin;

--
-- TOC entry 237 (class 1259 OID 201642)
-- Name: subjects; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.subjects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(100) NOT NULL,
    code character varying(10),
    description text,
    status boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "AreaId" uuid
);


ALTER TABLE public.subjects OWNER TO admin;

--
-- TOC entry 238 (class 1259 OID 201650)
-- Name: teacher_assignments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.teacher_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    teacher_id uuid NOT NULL,
    subject_assignment_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.teacher_assignments OWNER TO admin;

--
-- TOC entry 239 (class 1259 OID 201655)
-- Name: trimester; Type: TABLE; Schema: public; Owner: admin
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
    updated_at timestamp with time zone
);


ALTER TABLE public.trimester OWNER TO admin;

--
-- TOC entry 240 (class 1259 OID 201663)
-- Name: user_grades; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.user_grades (
    user_id uuid NOT NULL,
    grade_id uuid NOT NULL
);


ALTER TABLE public.user_grades OWNER TO admin;

--
-- TOC entry 241 (class 1259 OID 201666)
-- Name: user_groups; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.user_groups (
    user_id uuid NOT NULL,
    group_id uuid NOT NULL
);


ALTER TABLE public.user_groups OWNER TO admin;

--
-- TOC entry 242 (class 1259 OID 201669)
-- Name: user_subjects; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.user_subjects (
    user_id uuid NOT NULL,
    subject_id uuid NOT NULL
);


ALTER TABLE public.user_subjects OWNER TO admin;

--
-- TOC entry 243 (class 1259 OID 201672)
-- Name: users; Type: TABLE; Schema: public; Owner: admin
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
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('superadmin'::character varying)::text, ('admin'::character varying)::text, ('director'::character varying)::text, ('teacher'::character varying)::text, ('parent'::character varying)::text, ('student'::character varying)::text, ('estudiante'::character varying)::text]))),
    CONSTRAINT users_status_check CHECK (((status)::text = ANY (ARRAY[('active'::character varying)::text, ('inactive'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO admin;

--
-- TOC entry 5331 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN users.cellphone_primary; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.users.cellphone_primary IS 'Número de celular principal del usuario';


--
-- TOC entry 5332 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN users.cellphone_secondary; Type: COMMENT; Schema: public; Owner: admin
--

COMMENT ON COLUMN public.users.cellphone_secondary IS 'Número de celular secundario del usuario';


--
-- TOC entry 5272 (class 0 OID 202596)
-- Dependencies: 245
-- Data for Name: EmailConfigurations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."EmailConfigurations" ("Id", "SchoolId", "SmtpServer", "SmtpPort", "SmtpUsername", "SmtpPassword", "SmtpUseSsl", "SmtpUseTls", "FromEmail", "FromName", "IsActive", "CreatedAt", "UpdatedAt") FROM stdin;
\.


--
-- TOC entry 5246 (class 0 OID 201510)
-- Dependencies: 219
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: admin
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
-- TOC entry 5247 (class 0 OID 201513)
-- Dependencies: 220
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.activities (id, school_id, subject_id, teacher_id, group_id, name, type, trimester, pdf_url, created_at, grade_level_id, "ActivityTypeId", "TrimesterId", due_date) FROM stdin;
298a4309-4f1c-496d-a89a-f7b65e1d12d6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	fc01350f-66dc-4c68-9962-e16427bf233e	c7c18b5a-3677-4157-9e39-cebd25d38385	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2	Parcial	2T	\N	2025-09-07 07:19:37.227203-05	77082a01-90bb-4a50-bf7c-562092ba81ec	\N	b76727b4-3f16-4e91-ade0-99a3f5798746	2025-09-07 00:00:00-05
fbaa94b9-5abd-4a72-a996-19b24f976171	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	fc01350f-66dc-4c68-9962-e16427bf233e	c7c18b5a-3677-4157-9e39-cebd25d38385	0e3c3c91-a160-485f-8c40-7329ae00dbfb	1	Tarea	2T	/uploads/activities/fbaa94b9-5abd-4a72-a996-19b24f976171/estudiantesPRUEBA.xlsx	2025-09-07 07:19:23.857305-05	77082a01-90bb-4a50-bf7c-562092ba81ec	\N	b76727b4-3f16-4e91-ade0-99a3f5798746	2025-09-11 00:00:00-05
\.


--
-- TOC entry 5248 (class 0 OID 201520)
-- Dependencies: 221
-- Data for Name: activity_attachments; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.activity_attachments (id, activity_id, file_name, storage_path, mime_type, uploaded_at) FROM stdin;
\.


--
-- TOC entry 5249 (class 0 OID 201527)
-- Dependencies: 222
-- Data for Name: activity_types; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.activity_types (id, school_id, name, description, icon, color, is_global, display_order, is_active, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5250 (class 0 OID 201537)
-- Dependencies: 223
-- Data for Name: area; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.area (id, school_id, name, description, code, is_global, display_order, is_active, created_at, updated_at) FROM stdin;
2fd6215e-dfa5-4643-bc91-8dea1420b2b4	\N	HUMANISTICA	\N	\N	f	0	f	2025-09-06 12:30:34.445229-05	\N
0401b0e4-6026-44e3-b13c-5662a90a4dc6	\N	TECNOLÓGICA	\N	\N	f	0	f	2025-09-06 12:30:38.259151-05	\N
3f24f2d5-9a4a-4ef6-9d7e-631f741fef32	\N	CIENTÍFICA	\N	\N	f	0	f	2025-09-06 13:00:39.6498-05	\N
\.


--
-- TOC entry 5251 (class 0 OID 201547)
-- Dependencies: 224
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.attendance (id, student_id, teacher_id, group_id, grade_id, date, status, created_at) FROM stdin;
\.


--
-- TOC entry 5252 (class 0 OID 201552)
-- Dependencies: 225
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.audit_logs (id, school_id, user_id, user_name, user_role, action, resource, details, ip_address, "timestamp") FROM stdin;
\.


--
-- TOC entry 5271 (class 0 OID 202042)
-- Dependencies: 244
-- Data for Name: counselor_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.counselor_assignments (id, school_id, user_id, grade_id, group_id, is_counselor, is_active, created_at, updated_at) FROM stdin;
c91f5d6e-85d6-4a74-8f2e-1e8c5d30f750	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	c7c18b5a-3677-4157-9e39-cebd25d38385	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	t	t	2025-09-07 17:43:06.321007-05	2025-09-07 17:43:06.321078-05
6000755f-e619-4396-b995-9eaf991b3261	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	f0829e04-80dc-4b37-b8bc-8aa337cb4919	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	t	t	2025-09-07 17:47:22.739986-05	2025-09-07 17:47:22.739986-05
\.


--
-- TOC entry 5253 (class 0 OID 201559)
-- Dependencies: 226
-- Data for Name: discipline_reports; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.discipline_reports (id, student_id, teacher_id, date, report_type, description, status, created_at, updated_at, subject_id, group_id, grade_level_id) FROM stdin;
\.


--
-- TOC entry 5254 (class 0 OID 201566)
-- Dependencies: 227
-- Data for Name: email_configurations; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.email_configurations (id, school_id, smtp_server, smtp_port, smtp_username, smtp_password, smtp_use_ssl, smtp_use_tls, from_email, from_name, is_active, created_at, updated_at) FROM stdin;
5138fe6e-e0ae-4b5d-a2f6-9473a78e27ec	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	smtp.gmail.com	587	irvingcorrosk19@gmail.com	mqxahytcidbjobad	f	t	irvingcorrosk19@gmail.com	IPT San Miguelito	t	2025-09-06 21:36:52.236737-05	2025-09-06 22:15:30.323577-05
\.


--
-- TOC entry 5255 (class 0 OID 201578)
-- Dependencies: 228
-- Data for Name: grade_levels; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.grade_levels (id, name, description, created_at) FROM stdin;
77082a01-90bb-4a50-bf7c-562092ba81ec	7	\N	2025-09-06 12:30:35.141464-05
\.


--
-- TOC entry 5256 (class 0 OID 201585)
-- Dependencies: 229
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.groups (id, school_id, name, grade, created_at, description) FROM stdin;
0e3c3c91-a160-485f-8c40-7329ae00dbfb	\N	A	\N	2025-09-06 12:30:35.345718-05	\N
c5842f46-cda9-45a1-b700-9504cb52f780	\N	B	\N	2025-09-06 12:30:38.153355-05	\N
\.


--
-- TOC entry 5257 (class 0 OID 201592)
-- Dependencies: 230
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.schools (id, name, address, phone, logo_url, created_at, admin_id) FROM stdin;
ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	IPT San Miguelito	Panamá, San Miguelito, Belisario Frias, Torrijos Carter, Calle Principal	260-9999	cdea3cd3-e8b7-44f3-9a4e-e92e4d85f151_Imagen de WhatsApp 2025-09-06 a las 11.56.46_1473f923.jpg	2025-09-06 16:58:50.703258-05	21e66209-995a-4182-98e9-33d2ab635b48
\.


--
-- TOC entry 5258 (class 0 OID 201601)
-- Dependencies: 231
-- Data for Name: security_settings; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.security_settings (id, school_id, password_min_length, require_uppercase, require_lowercase, require_numbers, require_special, expiry_days, prevent_reuse, max_login_attempts, session_timeout_minutes, created_at) FROM stdin;
\.


--
-- TOC entry 5259 (class 0 OID 201615)
-- Dependencies: 232
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.specialties (id, name, description, created_at) FROM stdin;
5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	PRE-MEDIA	\N	2025-09-06 12:30:34.141028-05
\.


--
-- TOC entry 5260 (class 0 OID 201622)
-- Dependencies: 233
-- Data for Name: student_activity_scores; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.student_activity_scores (id, student_id, activity_id, score, created_at) FROM stdin;
\.


--
-- TOC entry 5261 (class 0 OID 201627)
-- Dependencies: 234
-- Data for Name: student_assignments; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.student_assignments (id, student_id, grade_id, group_id, created_at) FROM stdin;
4ccd2d83-e8f4-4a63-9488-906840dfe985	898929fa-c937-4df1-b548-832158f8bee9	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:15.812514-05
c8b87b48-e6d0-4315-aaaf-4b0b4c5d056b	d9978e62-44a5-4c22-9a5c-6f59f9f92952	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:16.919011-05
0b3ebd2c-d2cf-4748-9b42-f0428cfdb8c5	868fe773-9b11-4392-b271-1981b1e2b80a	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:17.926722-05
435f8f29-3841-4d97-ade4-a2f77149a867	2a426da8-a30b-467d-84b4-ebda117f0d19	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:19.415068-05
5701076a-1297-471f-a961-c669781b8fd5	f939f912-2c57-49ba-bfdf-b0de58227a24	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:21.419972-05
9d2ea86c-03b8-41f8-a2d5-c7d8eb06b579	11a2ce43-2286-4425-9afb-63b87700bad4	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:23.021509-05
26b0f1bb-593d-4a40-acd3-929c21640c86	75a37405-7fa8-4ecc-ae74-9fc4976f970a	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:24.213314-05
4cb7ee20-6523-435d-8428-8cc1dcd5beac	ec2f109e-80a1-4232-9191-a5d573686d76	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:25.411484-05
28778216-5dbe-4ce0-92db-0bc33467d959	3489214d-8a34-4bd0-ad3d-ed53541e278d	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:26.424952-05
f22fd2e1-bcaf-4614-a4f1-1af14f20da66	84cbac66-3e0d-470e-99f1-06228b8602a0	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:27.517688-05
d6899a2d-9124-4223-8c9f-bd46434ec3cb	66e0fae9-0bcb-422d-aade-d969eb45d1d7	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:28.526803-05
b8907ac4-2674-4d7a-97db-d58e11caf92e	66ee1cf2-a616-402b-a447-c0b405f554e7	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:29.624112-05
a73f9783-c177-4e4e-bbb8-9cd911588223	727adc01-190a-444b-bbd7-41ff473c6547	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:30.815106-05
fb741ba4-66e4-446c-82b0-f8d38bdb3234	8c6e08ef-b7c0-452a-8080-ad1fd4d58f8e	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:32.213043-05
8a8a7d81-aeda-420a-8a99-4f39c5707697	e3f1ec62-eee2-425a-a8d0-df99b903df02	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:34.126705-05
36bd479e-0f0f-4ebf-badd-71bde5cd8efa	d773ac46-71cd-49f2-97da-e2e9722f9446	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:35.619437-05
3fe545fd-2fa8-471b-91be-8c86d41654ac	17e20ea8-681a-4bde-b1cb-138ceeeb2fbe	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:36.629742-05
bc7a1a79-64ef-4f41-bc78-070e4cda6ba6	b64893ef-b575-44f1-9aa2-6c6629cab28c	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:37.81729-05
070d99b0-fa6b-4b9b-99f5-5c86ce07047b	44a57e70-b8ab-4d34-9fa5-145939b820fe	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:38.823025-05
ca729c8d-92e6-4de1-b595-f9f068b21bc7	2b6ddd6c-b16a-4540-bd90-426da40cfe26	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:40.020008-05
d330e8f9-3ee2-40f5-afce-fd6e6be27d72	0a0684d7-6f10-438b-97c2-0798715fb273	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:41.129239-05
c27d6050-3b5b-4c2c-adbd-23ca20e2e593	000ec5be-a394-4eb2-8f06-67ee2374d519	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:42.313358-05
0d466921-35cb-41d3-86e8-fb282f0d811a	a5041ef7-d355-4dc1-aec3-bdbc57d19a3c	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:43.621426-05
9b7aa85b-7b8c-4aff-ae98-0ebe2bbc7acb	818a5efb-0eb4-46cc-83d8-86d3308546b2	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:44.725499-05
bb52701a-9a36-468a-854a-3892940a2529	c48a6c8f-3ac5-4195-afee-2ed178bbc98d	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:45.813588-05
796f0015-cf8e-49ee-ab43-b9de443f962f	67a537ae-b2f1-4dc6-809d-7164c5550720	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:46.83571-05
5c7802ab-4a6d-4049-9767-e7fb52868475	d06f6166-b3b1-441c-b7b7-d1577dbade8f	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:47.921975-05
0e616a34-d496-4319-a014-3640a66bb8de	acf14b7d-e8d3-4180-95c9-007a12234391	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:49.012941-05
7542e468-961e-4e57-b0b0-6b423c8c1f94	b8e8c368-3936-40c0-9bd8-794bd0f88b0a	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:50.028713-05
a3086115-c0c3-47e7-9eb9-3903777ef5b8	6254c4a6-c3a7-453c-8691-aac784e428f6	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:51.217137-05
82002148-4f66-480e-aad1-d7587d22cfa1	977fdd9d-00a9-4733-a532-4c7bd9a8fbf0	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:52.315401-05
27d86cf8-7038-4353-8456-fbf6d3982eaf	1db0cf8c-f114-406e-9579-0144e2e710c2	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:53.42557-05
13a28755-5063-4eda-aad7-e514b2b2bdb1	06c24cd3-07c6-4dc3-adcb-df2098a5d454	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:54.520702-05
ee5a9297-7573-4623-a757-4c32be42b985	c90b279c-6ad1-4e36-bbeb-7b5cbba48dc8	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:55.829994-05
f599320b-4fe5-4874-b066-6fa02967ef56	f1a42d22-5bec-4f39-94f7-f8d8b64f5174	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:04:56.919784-05
627af7db-dd60-4a74-b393-5d5443132681	603f1edb-a49b-4bcd-a8b2-cbc10caf3832	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:04:58.035228-05
e49f6604-377e-4810-b63e-22e1769cbc4f	ad670d72-f0eb-48d1-9ec0-371a4b4cca7b	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:04:59.030304-05
5665d677-20f6-4ce6-8dec-a23f2d4a5909	9367c566-da28-4e80-9cc6-12dced0241cd	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:00.218878-05
81815329-89ac-4034-a796-77db38628d95	9a250708-d5bd-4e2b-8a4e-0007d9fd48ba	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:01.330847-05
8b5c6de4-994b-4f4e-bed6-79afaf262f6c	2444d902-b4c7-4dde-875b-9b529604b305	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:02.327125-05
f6327d68-d430-48bd-a63f-d05b3d830376	4a68d235-d4a5-4aaa-9aed-ee2c5d07bdb0	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:03.329336-05
b9cce219-f7bc-4b19-be1c-da0ec8f97b80	fbc04d6a-88e6-4538-a942-9f97220a5896	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:04.329884-05
56dd4b22-faa7-40a7-b71f-212fc3b73030	a155bc11-1d88-4687-9e8d-9c47fd1e4d3f	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:05.419272-05
4ccd5731-018b-4cf2-aebd-5e5705f99433	83b68e29-92fa-4716-a6b5-d9c1b3881c06	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:06.511412-05
b37b4887-7d5f-4293-8faa-32979b44c935	ea031f5b-ad83-47a5-b6da-cc0a98714cac	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:07.625422-05
2bdd3d55-ca96-478b-a9d3-d5337f33c6f4	97bdebe9-28ba-4420-8dd3-cbde41755801	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:08.721083-05
e2917eb4-f0c8-45ac-a606-f3f59e037b8f	e70f7e61-4d8b-4ba0-9c18-b23230e16af3	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:09.731034-05
83949f1a-f11c-42e1-b2cc-05bc231fe6ea	83591c94-ac2f-4bb3-868d-cd0ef3ab4fa2	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:10.928043-05
e1037301-516b-4744-8299-9b97eab1b339	4a44e91f-3021-4689-8596-61970517991b	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:11.924216-05
c1d117e5-dc31-4abb-892d-3b03ac634c73	ba892e28-cfc4-4afd-885e-949ef2ccfea3	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:13.025494-05
af7d96af-d451-4969-a97a-76a46549e143	ea16c16a-adf7-4846-8004-826ba68773d4	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:14.122182-05
b9b083d9-22a7-489d-a507-a53e45fcba24	68ea8b03-9272-45f5-a95b-cab8525a11fe	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:15.220007-05
65adc713-6bcc-4292-8fa1-6a7062483e1a	dfb5d4aa-bd71-4d25-8dd2-9d5691592777	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:16.424262-05
4bc8d8dc-fa32-4564-97ef-f287eb29a69a	668d1c4f-fa93-44f1-a73c-57d965ee03ba	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:17.429855-05
c7776a8f-8afa-4ec3-831f-ec9ca5a9d1fa	0bda8e73-9486-4eeb-a9bb-77885e40b59f	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:18.516508-05
8ab451bc-f878-49f7-84ad-678188b9660c	695b7110-31f6-4652-b77b-cb2aad386519	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:19.525305-05
62e6f888-f857-47a2-9f19-a882db57a27e	813cfcf8-d6f1-4364-a76f-8497b0bb220d	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:20.53037-05
59600fbb-c2cc-4a9d-875b-40c4088890ab	16ee1e96-bae4-48bc-83a1-5a9f65b67e46	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:21.618041-05
49a8a60e-ee4a-4f12-9f54-9c228ad76fbc	4eac2670-6939-442b-99af-e32af259ed20	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:22.626963-05
4a0907c3-3b8e-49d4-84a7-ebe61c3acd3a	418d1a1f-f2c6-4222-aca9-29da04a3eb6a	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:23.723131-05
1551564d-9c29-48cd-8223-53d011660eb1	4792645b-7c5b-4c51-9a72-58aa57976074	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:24.826958-05
ff7b11dc-c18b-4b52-8bd6-f5fd9c57871e	08d35a17-cb25-40af-8c01-881e5c43df48	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:25.846951-05
0b58ebeb-1b73-41a6-b970-aecee40ae3e7	022ce88e-5b5d-4dd6-a0d5-ef799f3c766a	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:26.916168-05
eb9d5080-5970-4857-9d5e-bd69b7c9a3ee	73067c81-3edf-4d99-b56f-953f2f3a03f0	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:28.021808-05
76174b31-cff7-4d93-8f78-a773f59b30de	4712c60c-a7c3-4c9f-867c-6ed44aecfbae	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:29.11139-05
034cb948-3e66-42b6-9bbf-88c69fe26c50	22b44601-234e-435a-a690-a799e1191c6c	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:30.129313-05
63ac67a6-3ebf-483d-8d94-74fa3bf86b78	3cda6203-3f04-49c7-85da-2027423c08b5	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:31.129449-05
8031c6da-6a9e-4567-8455-8a9355706f6e	6b3bc4a4-c92f-4b3a-863f-343d3cd6ce5b	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:32.216442-05
df1452be-80d4-4787-82ec-5563e2da72d5	fe5ee1f7-3ddf-4d81-826f-f1d129495169	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:33.229853-05
9b543750-a3eb-40af-8434-bc45f67b393a	659c7325-61b1-4e10-bbdf-01644c1ca65b	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:05:34.317133-05
\.


--
-- TOC entry 5262 (class 0 OID 201632)
-- Dependencies: 235
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.students (id, school_id, name, birth_date, grade, group_name, parent_id, created_at) FROM stdin;
\.


--
-- TOC entry 5263 (class 0 OID 201637)
-- Dependencies: 236
-- Data for Name: subject_assignments; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.subject_assignments (id, specialty_id, area_id, subject_id, grade_level_id, group_id, created_at, status, "SchoolId") FROM stdin;
f444bd02-a7da-4f8f-8862-5f5424b9f72a	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	4130eb55-bd87-4acd-a37b-e09d948ff3ea	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 12:30:35.739228-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
e421c671-7d77-4962-ad46-c8cc93865301	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	4130eb55-bd87-4acd-a37b-e09d948ff3ea	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 12:30:38.238295-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
8488a6d8-1326-4525-ab3e-990dde72d97f	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	0401b0e4-6026-44e3-b13c-5662a90a4dc6	fc01350f-66dc-4c68-9962-e16427bf233e	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 12:30:38.443008-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
2571149b-2eff-4022-adfb-7d62a6f91f3e	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	0401b0e4-6026-44e3-b13c-5662a90a4dc6	fc01350f-66dc-4c68-9962-e16427bf233e	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:39.330258-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
400ab637-a0eb-43d0-b7e5-c15a2e1e90b7	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	3f24f2d5-9a4a-4ef6-9d7e-631f741fef32	f52c3c9b-a104-41cf-b622-1fca7a0b38a7	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:39.92188-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
f26a8862-0d04-46fa-b099-c60f8abeb365	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	3f24f2d5-9a4a-4ef6-9d7e-631f741fef32	f52c3c9b-a104-41cf-b622-1fca7a0b38a7	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:40.945685-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
8693d84b-1b13-4409-9d6e-f9e8561c968f	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	86704d32-0788-4078-93e3-b20fc70c74a9	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:41.117466-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
84253d11-2ca8-4d7e-acdd-8a311cf54a49	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	86704d32-0788-4078-93e3-b20fc70c74a9	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:42.611645-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
116a2eca-6dc2-412b-852d-689c41c0ea6b	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	3f24f2d5-9a4a-4ef6-9d7e-631f741fef32	8aab1547-f3cb-4baa-869f-df7b477477cd	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:43.013399-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
dbaa1e6e-afa5-4056-b55c-3649978a7e7d	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	3f24f2d5-9a4a-4ef6-9d7e-631f741fef32	8aab1547-f3cb-4baa-869f-df7b477477cd	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:45.317592-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
ad0b8ef8-98de-44f0-b96e-45c919612f1a	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	94c65602-3764-4cfb-a0ac-602c289d6d86	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:45.426956-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
5f10bc5c-3859-4a3c-973d-7c4699335860	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	94c65602-3764-4cfb-a0ac-602c289d6d86	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:46.916891-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
a5f28bb3-d927-4b41-9db5-eeb2854e23a9	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	b18480f6-1dcf-46f0-8472-da3c727b51d3	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:47.521029-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
8bb6e70f-3d42-48fa-9214-742ec0e605f6	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	b18480f6-1dcf-46f0-8472-da3c727b51d3	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:50.219615-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
dcb34c02-f74f-4a21-8b4d-2c098c37dd72	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	8882686e-89af-4d0f-819e-90f210a5ad41	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:50.911539-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
9d08d388-07af-4317-8a33-c5cd6877d7d9	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	8882686e-89af-4d0f-819e-90f210a5ad41	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:53.130351-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
4bae07d0-c982-4a9d-87b6-b243355bebf5	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	b6d6eacc-96bc-45a3-8ae1-7cb65bbd7ba8	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:53.31526-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
06bcd0f7-05d6-4352-8cad-e54e0c44096e	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	b6d6eacc-96bc-45a3-8ae1-7cb65bbd7ba8	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:54.426208-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
ae8879af-f5af-40f5-8dc6-926c1764c395	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	a6365d29-84ce-4b69-9c78-7dd80b0c163d	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:54.624266-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
0d6b4fae-5dbe-46d2-8cd2-73f08a6c3270	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	2fd6215e-dfa5-4643-bc91-8dea1420b2b4	a6365d29-84ce-4b69-9c78-7dd80b0c163d	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:56.411327-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
fb80aff4-a3f3-4ba5-b56c-dde21f6091e9	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	3f24f2d5-9a4a-4ef6-9d7e-631f741fef32	7749982c-feda-442c-be05-770c6651f3d0	77082a01-90bb-4a50-bf7c-562092ba81ec	0e3c3c91-a160-485f-8c40-7329ae00dbfb	2025-09-06 13:00:56.81452-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
d8f00b69-da40-4a5f-a6fb-42298cf56765	5d7bc76d-ba1c-409d-9107-f6b21d6c14ef	3f24f2d5-9a4a-4ef6-9d7e-631f741fef32	7749982c-feda-442c-be05-770c6651f3d0	77082a01-90bb-4a50-bf7c-562092ba81ec	c5842f46-cda9-45a1-b700-9504cb52f780	2025-09-06 13:00:59.311504-05	\N	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5
\.


--
-- TOC entry 5264 (class 0 OID 201642)
-- Dependencies: 237
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.subjects (id, school_id, name, code, description, status, created_at, "AreaId") FROM stdin;
4130eb55-bd87-4acd-a37b-e09d948ff3ea	\N	RELIGIÓN, MORAL Y VALORES	\N	\N	t	2025-09-06 12:30:35.037725-05	\N
fc01350f-66dc-4c68-9962-e16427bf233e	\N	TECNOLOGÍAS	\N	\N	t	2025-09-06 12:30:38.431784-05	\N
f52c3c9b-a104-41cf-b622-1fca7a0b38a7	\N	CIENCIAS NATURALES	\N	\N	t	2025-09-06 13:00:39.815961-05	\N
86704d32-0788-4078-93e3-b20fc70c74a9	\N	CÍVICA	\N	\N	t	2025-09-06 13:00:41.030643-05	\N
8aab1547-f3cb-4baa-869f-df7b477477cd	\N	EDUCACIÓN FÍSICA	\N	\N	t	2025-09-06 13:00:42.909772-05	\N
94c65602-3764-4cfb-a0ac-602c289d6d86	\N	ESPAÑOL	\N	\N	t	2025-09-06 13:00:45.415612-05	\N
b18480f6-1dcf-46f0-8472-da3c727b51d3	\N	EXPRESIONES ARTÍSTICAS	\N	\N	t	2025-09-06 13:00:47.412765-05	\N
8882686e-89af-4d0f-819e-90f210a5ad41	\N	GEOGRAFÍA	\N	\N	t	2025-09-06 13:00:50.722502-05	\N
b6d6eacc-96bc-45a3-8ae1-7cb65bbd7ba8	\N	HISTORIA	\N	\N	t	2025-09-06 13:00:53.230713-05	\N
a6365d29-84ce-4b69-9c78-7dd80b0c163d	\N	INGLÉS	\N	\N	t	2025-09-06 13:00:54.61404-05	\N
7749982c-feda-442c-be05-770c6651f3d0	\N	MATEMÁTICA	\N	\N	t	2025-09-06 13:00:56.710555-05	\N
\.


--
-- TOC entry 5265 (class 0 OID 201650)
-- Dependencies: 238
-- Data for Name: teacher_assignments; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.teacher_assignments (id, teacher_id, subject_assignment_id, created_at) FROM stdin;
18c961e6-66d4-4dda-93a7-1472f5ff4135	f0829e04-80dc-4b37-b8bc-8aa337cb4919	f444bd02-a7da-4f8f-8862-5f5424b9f72a	2025-09-06 12:30:37.938631-05
dd7ddea6-4522-4e82-8c3e-4bb645722c35	f0829e04-80dc-4b37-b8bc-8aa337cb4919	e421c671-7d77-4962-ad46-c8cc93865301	2025-09-06 12:30:38.249251-05
307a8fc9-a000-4f9a-99b5-3685e8ea06b7	c7c18b5a-3677-4157-9e39-cebd25d38385	8488a6d8-1326-4525-ab3e-990dde72d97f	2025-09-06 13:00:39.212055-05
cfea2e44-7a35-4de2-8d69-77ad535f74f2	c7c18b5a-3677-4157-9e39-cebd25d38385	2571149b-2eff-4022-adfb-7d62a6f91f3e	2025-09-06 13:00:39.634834-05
f16ef3b2-dc42-477e-8b90-9a0c00570938	b0830b4a-e562-4fc0-ae5c-1e9cb0ccc531	400ab637-a0eb-43d0-b7e5-c15a2e1e90b7	2025-09-06 13:00:40.932805-05
493f58cc-6fa1-45a1-bc8e-4335ffd1488a	b0830b4a-e562-4fc0-ae5c-1e9cb0ccc531	f26a8862-0d04-46fa-b099-c60f8abeb365	2025-09-06 13:00:41.020756-05
541b70f3-fbb5-48ca-9a57-0fe9e4fbaec7	10e01ed6-ebac-4103-84ec-19815822556f	8693d84b-1b13-4409-9d6e-f9e8561c968f	2025-09-06 13:00:42.317585-05
b5349fbf-d4e4-4e57-9d01-c540df3daaf6	10e01ed6-ebac-4103-84ec-19815822556f	84253d11-2ca8-4d7e-acdd-8a311cf54a49	2025-09-06 13:00:42.715451-05
c59edef6-1501-45ba-b60b-3d8da4040d8e	d332fda9-9736-4c8c-84cb-aaa2eb0ccbf8	116a2eca-6dc2-412b-852d-689c41c0ea6b	2025-09-06 13:00:45.11676-05
52758dec-1d0a-4a90-8561-cf92c9eb6428	d332fda9-9736-4c8c-84cb-aaa2eb0ccbf8	dbaa1e6e-afa5-4056-b55c-3649978a7e7d	2025-09-06 13:00:45.328926-05
e96021f6-bc82-4a82-b189-c73c32dbc31b	8d6e4b17-3107-44be-938f-13374a2a268e	ad0b8ef8-98de-44f0-b96e-45c919612f1a	2025-09-06 13:00:46.617923-05
3ee2e5d9-f5c5-4d78-9db5-73bb88165e02	8d6e4b17-3107-44be-938f-13374a2a268e	5f10bc5c-3859-4a3c-973d-7c4699335860	2025-09-06 13:00:47.211617-05
dba1e6b5-49f3-4098-983c-0772e3828eff	71106b68-5bd5-4cdc-bffd-82ff6fe9e110	a5f28bb3-d927-4b41-9db5-eeb2854e23a9	2025-09-06 13:00:49.922758-05
81ca2f39-3a3c-4598-b575-fb343785ff24	71106b68-5bd5-4cdc-bffd-82ff6fe9e110	8bb6e70f-3d42-48fa-9214-742ec0e605f6	2025-09-06 13:00:50.430911-05
c4a3aa41-e2ec-459b-86f4-399bafbef669	cc1def40-ed6f-4755-84a1-45032743e293	dcb34c02-f74f-4a21-8b4d-2c098c37dd72	2025-09-06 13:00:53.116085-05
186b8fed-0dc3-4290-aff6-b4a079b740f6	cc1def40-ed6f-4755-84a1-45032743e293	9d08d388-07af-4317-8a33-c5cd6877d7d9	2025-09-06 13:00:53.217673-05
0bf9a64f-1a5e-49ad-99c1-707ee37cf9a3	28155aef-3576-4174-af80-eb75b620ba9f	4bae07d0-c982-4a9d-87b6-b243355bebf5	2025-09-06 13:00:54.328226-05
83b63131-70fb-4691-9206-c24fe77bc03d	28155aef-3576-4174-af80-eb75b620ba9f	06bcd0f7-05d6-4352-8cad-e54e0c44096e	2025-09-06 13:00:54.514012-05
678a401d-9dad-4c36-aaa3-9cb4193f6edb	7bd475f2-0efa-4c38-8032-2a45bba6c313	ae8879af-f5af-40f5-8dc6-926c1764c395	2025-09-06 13:00:56.211649-05
28fecb6c-438c-44ac-9299-4f4253641936	7bd475f2-0efa-4c38-8032-2a45bba6c313	0d6b4fae-5dbe-46d2-8cd2-73f08a6c3270	2025-09-06 13:00:56.516582-05
71eb361d-2fba-4c36-9664-151805eb7915	a7c08bc7-d1a4-46e5-b46e-9194ce45c94b	fb80aff4-a3f3-4ba5-b56c-dde21f6091e9	2025-09-06 13:00:59.11155-05
42704f2d-413b-4512-bc49-de2a5b6b62d1	a7c08bc7-d1a4-46e5-b46e-9194ce45c94b	d8f00b69-da40-4a5f-a6fb-42298cf56765	2025-09-06 13:00:59.418858-05
\.


--
-- TOC entry 5266 (class 0 OID 201655)
-- Dependencies: 239
-- Data for Name: trimester; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.trimester (id, school_id, name, description, "order", start_date, end_date, is_active, created_at, updated_at) FROM stdin;
b76727b4-3f16-4e91-ade0-99a3f5798746	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	2T	\N	2	2025-06-30 19:00:00-05	2025-09-29 19:00:00-05	t	2025-09-06 13:31:42.502265-05	\N
4b85540d-697b-4db1-942a-1d91f74c719b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	1T	\N	1	2025-02-28 19:00:00-05	2025-06-29 19:00:00-05	f	2025-09-06 13:31:42.298049-05	2025-09-06 13:31:44.700076-05
dcfc00dd-d487-4a4d-81a7-b1c93b0d367e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	3T	\N	3	2025-09-30 19:00:00-05	2025-12-30 19:00:00-05	f	2025-09-06 13:31:42.502814-05	2025-09-06 13:32:07.108637-05
\.


--
-- TOC entry 5267 (class 0 OID 201663)
-- Dependencies: 240
-- Data for Name: user_grades; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.user_grades (user_id, grade_id) FROM stdin;
\.


--
-- TOC entry 5268 (class 0 OID 201666)
-- Dependencies: 241
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.user_groups (user_id, group_id) FROM stdin;
\.


--
-- TOC entry 5269 (class 0 OID 201669)
-- Dependencies: 242
-- Data for Name: user_subjects; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.user_subjects (user_id, subject_id) FROM stdin;
\.


--
-- TOC entry 5270 (class 0 OID 201672)
-- Dependencies: 243
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.users (id, school_id, name, email, password_hash, role, status, two_factor_enabled, last_login, created_at, last_name, document_id, date_of_birth, "UpdatedAt", cellphone_primary, cellphone_secondary) FROM stdin;
2b6ddd6c-b16a-4540-bd90-426da40cfe26	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Custodia	prueba020@prueba.com	$2a$11$Fo7cQldTUmI0E6oLiJDb8exGaQXskI4KNnks9VkvwIWSwnYviok5y	estudiante	active	f	\N	2025-09-06 13:04:38.827997-05	Bonet	74167622	2000-09-06 13:04:38.827995-05	2025-09-06 13:04:38.827997-05	\N	\N
898929fa-c937-4df1-b548-832158f8bee9	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Regina	prueba001@prueba.com	$2a$11$uZui2KOAQndpZ7iYpFJiuudhR9zhWEtqrtLZ33rFTKYoYRSN6lAPC	estudiante	active	f	\N	2025-09-06 13:04:14.522585-05	Navas	75876751	2000-09-06 13:04:14.522583-05	2025-09-06 13:04:14.522585-05	\N	\N
d9978e62-44a5-4c22-9a5c-6f59f9f92952	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Prudencio	prueba002@prueba.com	$2a$11$2FUdHgb4Pr8GvMArFMYSneXjwC2jylApgRE09GrBhLT2zCXSHoUEC	estudiante	active	f	\N	2025-09-06 13:04:15.921045-05	Valenciano	66910793	2000-09-06 13:04:15.921043-05	2025-09-06 13:04:15.921045-05	\N	\N
f939f912-2c57-49ba-bfdf-b0de58227a24	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ámbar	prueba005@prueba.com	$2a$11$u0A9Hf9Y2vod1Mj1eGlQY.RlwnHT2MSVZlbzj.N.17pQfegyTzvri	estudiante	active	f	\N	2025-09-06 13:04:19.420059-05	Meléndez	48660146	2000-09-06 13:04:19.420057-05	2025-09-06 13:04:19.420059-05	\N	\N
11a2ce43-2286-4425-9afb-63b87700bad4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Kike	prueba006@prueba.com	$2a$11$Xy2UT5bVjZovyegzI.wODuWluqK19vUjaoaCe9ov5/5XM/HR7y99K	estudiante	active	f	\N	2025-09-06 13:04:21.514853-05	Mayoral	94560817	2000-09-06 13:04:21.51485-05	2025-09-06 13:04:21.514853-05	\N	\N
75a37405-7fa8-4ecc-ae74-9fc4976f970a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Caridad	prueba007@prueba.com	$2a$11$ZeT1zZ6u2KuGWBpmTW7ATu9o.u7zYNWGrF4R.n1jdM92G0ESyaIPO	estudiante	active	f	\N	2025-09-06 13:04:23.111271-05	Ibarra	82623191	2015-08-07 19:00:00-05	2025-09-06 13:04:23.111271-05	\N	\N
ec2f109e-80a1-4232-9191-a5d573686d76	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Nazario	prueba008@prueba.com	$2a$11$vn/diSrBdVwdFhAR98ghA.B2RaJ5Pl.5IosffmUYIlneT5xBukU4a	estudiante	active	f	\N	2025-09-06 13:04:24.219769-05	Caparrós	95283774	2000-09-06 13:04:24.219766-05	2025-09-06 13:04:24.219769-05	\N	\N
3489214d-8a34-4bd0-ad3d-ed53541e278d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Reyna	prueba009@prueba.com	$2a$11$dikcUc86gQTbhXKZMSiMruEXnp5Q7veTMFOLKu14Ju4yYdBSCVlZi	estudiante	active	f	\N	2025-09-06 13:04:25.417617-05	Agustí	95641522	2000-09-06 13:04:25.417615-05	2025-09-06 13:04:25.417617-05	\N	\N
84cbac66-3e0d-470e-99f1-06228b8602a0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Bárbara	prueba010@prueba.com	$2a$11$uTCSykDVuoi6qTOoBrReRO/Bu0YY2GHBuP8CuvSfTPIyK8ktQgA6a	estudiante	active	f	\N	2025-09-06 13:04:26.433173-05	Fuente	80911704	2000-09-06 13:04:26.433171-05	2025-09-06 13:04:26.433174-05	\N	\N
66e0fae9-0bcb-422d-aade-d969eb45d1d7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marina	prueba011@prueba.com	$2a$11$kbtHcSXQ2OzKCWUiU2D3HOwM/uX9xZu6JHf9KS4oHZMMNwKKUxHq2	estudiante	active	f	\N	2025-09-06 13:04:27.52448-05	Verdejo	37938011	2013-08-05 19:00:00-05	2025-09-06 13:04:27.52448-05	\N	\N
66ee1cf2-a616-402b-a447-c0b405f554e7	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Rita	prueba012@prueba.com	$2a$11$Lx.QnCbqZKn5JYqiCM8xLu1tu2Zdi4raaCplUWgjWFA8cB.zK4.GS	estudiante	active	f	\N	2025-09-06 13:04:28.533897-05	Cortés	99666095	2000-09-06 13:04:28.533895-05	2025-09-06 13:04:28.533897-05	\N	\N
727adc01-190a-444b-bbd7-41ff473c6547	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Eustaquio	prueba013@prueba.com	$2a$11$dVg6K4vs78qlbxRy49lx1.imb7UDtiyo/whGs7YqhfjK9gW6Fcrn.	estudiante	active	f	\N	2025-09-06 13:04:29.630086-05	Méndez	12935310	2013-02-02 19:00:00-05	2025-09-06 13:04:29.630086-05	\N	\N
8c6e08ef-b7c0-452a-8080-ad1fd4d58f8e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan Carlos	prueba014@prueba.com	$2a$11$DyGA4TMlOb8jsZNlxA2j4OB01WmCQfciuZ4xFUCv7UZPpXntt0xPO	estudiante	active	f	\N	2025-09-06 13:04:30.926025-05	Marquez	89794848	2000-09-06 13:04:30.926023-05	2025-09-06 13:04:30.926025-05	\N	\N
e3f1ec62-eee2-425a-a8d0-df99b903df02	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Fernando	prueba015@prueba.com	$2a$11$9z3YbSzVir8k65IQNzb7BOaNBFKiuPT/hvjeahS8JxY8NZaIcJy52	estudiante	active	f	\N	2025-09-06 13:04:32.226502-05	Marin	56018465	2014-01-31 19:00:00-05	2025-09-06 13:04:32.226502-05	\N	\N
d773ac46-71cd-49f2-97da-e2e9722f9446	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Victoria	prueba016@prueba.com	$2a$11$/N9Zn6h5i49NKUgB2CnYMO6jl2VycKEwl6jd2H7YD3NL9zKhCLvQG	estudiante	active	f	\N	2025-09-06 13:04:34.213801-05	Vara	64215809	2000-09-06 13:04:34.2138-05	2025-09-06 13:04:34.213801-05	\N	\N
17e20ea8-681a-4bde-b1cb-138ceeeb2fbe	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Leyre	prueba017@prueba.com	$2a$11$xphX/vsXx2gPHKWa/caq1.Si4gImZ5dMA7cXIw4ZkysoWhOuYmTA.	estudiante	active	f	\N	2025-09-06 13:04:35.627518-05	Landa	32821210	2000-09-06 13:04:35.627516-05	2025-09-06 13:04:35.627518-05	\N	\N
b64893ef-b575-44f1-9aa2-6c6629cab28c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Micaela	prueba018@prueba.com	$2a$11$A2hphfbq4I1c2Hx68m.w8e3IFNXLb.aVJVF6aQW/ax2QSq39907QC	estudiante	active	f	\N	2025-09-06 13:04:36.713539-05	Pino	12558625	2012-02-09 19:00:00-05	2025-09-06 13:04:36.713539-05	\N	\N
44a57e70-b8ab-4d34-9fa5-145939b820fe	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Gala	prueba019@prueba.com	$2a$11$oeTxFbJTkVXaaE/JOJhAH.tIieUn57tBJjolcsm0i8lCCUEemZm26	estudiante	active	f	\N	2025-09-06 13:04:37.823065-05	Benítez	77911021	2000-09-06 13:04:37.823064-05	2025-09-06 13:04:37.823066-05	\N	\N
0a0684d7-6f10-438b-97c2-0798715fb273	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Azahar	prueba021@prueba.com	$2a$11$Iqto3lhvXhxdQOyf8e/IUuW8Jd/V0gPmnZavg76limyLYxdePrBzG	estudiante	active	f	\N	2025-09-06 13:04:40.027192-05	Checa	34826722	2000-09-06 13:04:40.027191-05	2025-09-06 13:04:40.027192-05	\N	\N
000ec5be-a394-4eb2-8f06-67ee2374d519	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Mario	prueba022@prueba.com	$2a$11$o3hqXX8uCpti46abIbId2.IXODZhpMoz2I2PfFFbBf7othp18XR8q	estudiante	active	f	\N	2025-09-06 13:04:41.218184-05	Palmer	25869127	2014-06-08 19:00:00-05	2025-09-06 13:04:41.218184-05	\N	\N
a5041ef7-d355-4dc1-aec3-bdbc57d19a3c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Vito	prueba023@prueba.com	$2a$11$JcCoUroo97eR3ff/i5cpnev1tFjymYFicOYnA6zgMOmcbFhaa5XZK	estudiante	active	f	\N	2025-09-06 13:04:42.318921-05	Padilla	14145901	2000-09-06 13:04:42.318919-05	2025-09-06 13:04:42.318921-05	\N	\N
818a5efb-0eb4-46cc-83d8-86d3308546b2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Seve	prueba024@prueba.com	$2a$11$fFIZAh7yJep8Rm95199kH.k5YSrt1sUfcEO/YuM2uoqNJVxOrwVV6	estudiante	active	f	\N	2025-09-06 13:04:43.626699-05	Ramis	89275852	2000-09-06 13:04:43.626697-05	2025-09-06 13:04:43.626699-05	\N	\N
c48a6c8f-3ac5-4195-afee-2ed178bbc98d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Esther	prueba025@prueba.com	$2a$11$CDlO7iXtSuDalRWvd3ZI2u4fPnMPibuXJ2EbKslNo2R.vJ/vOnchK	estudiante	active	f	\N	2025-09-06 13:04:44.732896-05	Fuentes	98463532	2000-09-06 13:04:44.732894-05	2025-09-06 13:04:44.732896-05	\N	\N
67a537ae-b2f1-4dc6-809d-7164c5550720	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Rico	prueba026@prueba.com	$2a$11$UB5kWnEpzjKKF0HKQDWSj.mv03h.9LzKYq58jIRd26ExuXcMlehsO	estudiante	active	f	\N	2025-09-06 13:04:45.859568-05	Salcedo	20332969	2006-12-09 19:00:00-05	2025-09-06 13:04:45.859568-05	\N	\N
d06f6166-b3b1-441c-b7b7-d1577dbade8f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Primitivo	prueba027@prueba.com	$2a$11$2j2ZTfCaoRsVNRm1swtx/efmdAHyV8k6DVqgsMQ8Yyf03f5eE8Qcq	estudiante	active	f	\N	2025-09-06 13:04:46.913778-05	Aliaga	17016641	2000-09-06 13:04:46.913776-05	2025-09-06 13:04:46.913778-05	\N	\N
b8e8c368-3936-40c0-9bd8-794bd0f88b0a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Morena	prueba029@prueba.com	$2a$11$V2TFlx8.CW1Ph6KByL.aoestkd48Bi62adS9Y2D8Qc5o3eqKZaaWO	estudiante	active	f	\N	2025-09-06 13:04:49.019829-05	Abad	64602715	2000-09-06 13:04:49.019828-05	2025-09-06 13:04:49.019829-05	\N	\N
6254c4a6-c3a7-453c-8691-aac784e428f6	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Demetrio	prueba030@prueba.com	$2a$11$BlnpFvTjqsrU/Rt1Jxbsr.5eDyzqOogRz7tMeAiC1w.s8KbbNN5f2	estudiante	active	f	\N	2025-09-06 13:04:50.117081-05	Riquelme	96308770	2000-09-06 13:04:50.117079-05	2025-09-06 13:04:50.117081-05	\N	\N
977fdd9d-00a9-4733-a532-4c7bd9a8fbf0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Celso	prueba031@prueba.com	$2a$11$NPmZIIzhegAvMTkJDf1xLuQjyH99jy3euKaSPBHSKRRN/K5Dp3tn2	estudiante	active	f	\N	2025-09-06 13:04:51.223591-05	Aguilar	85090280	2012-05-09 19:00:00-05	2025-09-06 13:04:51.223591-05	\N	\N
1db0cf8c-f114-406e-9579-0144e2e710c2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ruy	prueba032@prueba.com	$2a$11$PRu9rUSLy4u1vJ/nArVQv.5rbYD5a4smZ3p0jeigRCB8486cHci5O	estudiante	active	f	\N	2025-09-06 13:04:52.321223-05	Morillo	26730947	2000-09-06 13:04:52.321221-05	2025-09-06 13:04:52.321223-05	\N	\N
06c24cd3-07c6-4dc3-adcb-df2098a5d454	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Mauricio	prueba033@prueba.com	$2a$11$gYEDHBAPRFBgZmdFrWfNIeC0mw.REEMzaasCcIivwELk86AWrmGB.	estudiante	active	f	\N	2025-09-06 13:04:53.43102-05	Ferrero	18226734	2010-04-04 19:00:00-05	2025-09-06 13:04:53.43102-05	\N	\N
b5cb04ba-8b09-4f7c-bf34-6fed01fa080b	\N	admin@correo.com	admin@correo.com	$2a$11$ijYC6tyYjXnk.l2uWu.0QeINxiYVKAVhEHwTbaTg5CUtEtlTEZ8i6	superadmin	active	f	2025-09-07 08:04:44.730847-05	2025-04-11 22:55:18.363537-05	Corro	DOC000016	2025-04-22 19:00:00-05	\N	\N	\N
f0829e04-80dc-4b37-b8bc-8aa337cb4919	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 10	juan10@email.com	$2a$11$F3LXjOqSrEr4aXSUd9TadewpdncILno5osUQ7qzqxiBFxAatsrOci	teacher	active	f	2025-09-07 17:47:45.1717-05	2025-09-06 12:30:37.142433-05	Perez	9-789-667	2000-09-05 19:00:00-05	\N	\N	\N
acf14b7d-e8d3-4180-95c9-007a12234391	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Amílcar	prueba028@prueba.com	$2a$11$YrImb0ReoQWtP5atWHVfnuKUk8dBosUS25/5hE2VYE0zxHJg7s6qy	estudiante	active	f	2025-09-07 05:46:33.670568-05	2025-09-06 13:04:47.92686-05	Roman	42935565	2011-02-10 19:00:00-05	2025-09-06 13:04:47.92686-05	\N	\N
2a426da8-a30b-467d-84b4-ebda117f0d19	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Cipriano	prueba004@prueba.com	$2a$11$9AgJNbO1F9u/5xEuA8zrWe6jjfgnaXBBTz4RbSSAp/opMwwU89hoS	estudiante	active	f	2025-09-07 07:30:44.298024-05	2025-09-06 13:04:17.931351-05	Buendía	99087130	2008-03-05 19:00:00-05	2025-09-06 13:04:17.931352-05	\N	\N
868fe773-9b11-4392-b271-1981b1e2b80a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Adora	qlservices0@gmail.com	$2a$11$NBGZW2nFmfO7/POH/uaI5.HCx6h2ELRnYScgIvvxTWAqVut07k0Ye	estudiante	active	f	2025-09-07 10:36:23.753332-05	2025-09-06 13:04:16.923878-05	Valverde	72125338	2009-04-03 00:00:00-05	2025-09-06 13:04:16.923879-05	+507 2222 222	+507 2222 222
c90b279c-6ad1-4e36-bbeb-7b5cbba48dc8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Daniela	prueba034@prueba.com	$2a$11$LkQqobKPbJ8hsu4UluNEeuDuQ1FgJ9AgR4RaxZDc5jTu2G3K6SjRC	estudiante	active	f	\N	2025-09-06 13:04:54.526682-05	Garrido	41660027	2015-10-03 19:00:00-05	2025-09-06 13:04:54.526682-05	\N	\N
f1a42d22-5bec-4f39-94f7-f8d8b64f5174	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Rafael	prueba035@prueba.com	$2a$11$5KKy.greV33..FuiFKZbmeWFsWMRw3TpRWjoRETetCfKbL1/clyE.	estudiante	active	f	\N	2025-09-06 13:04:55.838669-05	Prat	90107282	2000-09-06 13:04:55.838667-05	2025-09-06 13:04:55.83867-05	\N	\N
603f1edb-a49b-4bcd-a8b2-cbc10caf3832	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Vicente	prueba036@prueba.com	$2a$11$Ju6/x1GIIL0cNrrigyhPa.SlCiEASi9gAwQcZYPD8ZYtW1lLou09y	estudiante	active	f	\N	2025-09-06 13:04:57.023976-05	Oliveras	75009193	2009-12-06 19:00:00-05	2025-09-06 13:04:57.023976-05	\N	\N
ad670d72-f0eb-48d1-9ec0-371a4b4cca7b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Nieves	prueba037@prueba.com	$2a$11$yCZphboxn2Z58L/jFMpegOse97TE0uyjl2Q8fMRLzAW5ZUE.oJO3e	estudiante	active	f	\N	2025-09-06 13:04:58.113462-05	Farré	28693945	2000-09-06 13:04:58.113461-05	2025-09-06 13:04:58.113462-05	\N	\N
9367c566-da28-4e80-9cc6-12dced0241cd	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Prudencia	prueba038@prueba.com	$2a$11$cEdXzuNOojZ9jly8j7s8xevkV5IAbAJh3QBb4wD4DR3mBHgnJ9nAW	estudiante	active	f	\N	2025-09-06 13:04:59.118672-05	Lobato	79053475	2000-09-06 13:04:59.11867-05	2025-09-06 13:04:59.118672-05	\N	\N
9a250708-d5bd-4e2b-8a4e-0007d9fd48ba	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Nereida	prueba039@prueba.com	$2a$11$egdvOJAwsGpxYNaB/eCDfeeVDs3e6D6BJbj31iQIK5eH0A4M5pMtm	estudiante	active	f	\N	2025-09-06 13:05:00.230725-05	Cuervo	33860628	2000-09-06 13:05:00.230723-05	2025-09-06 13:05:00.230725-05	\N	\N
4a68d235-d4a5-4aaa-9aed-ee2c5d07bdb0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pascuala	prueba041@prueba.com	$2a$11$9QQ9HuMO3JKbRY8aJiYGoOLDi112hcCEgURHF6YSIeDrQZE5aQLWa	estudiante	active	f	\N	2025-09-06 13:05:02.332606-05	Mur	91036943	2007-11-30 19:00:00-05	2025-09-06 13:05:02.332606-05	\N	\N
fbc04d6a-88e6-4538-a942-9f97220a5896	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Soledad	prueba042@prueba.com	$2a$11$f3zD1FUNzoj0VO9T/LXOiOobAks5lWO.yrRkQ/YxvVemUqykzkaoW	estudiante	active	f	\N	2025-09-06 13:05:03.334371-05	Huertas	18641538	2000-09-06 13:05:03.334356-05	2025-09-06 13:05:03.334371-05	\N	\N
a155bc11-1d88-4687-9e8d-9c47fd1e4d3f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Marisa	prueba043@prueba.com	$2a$11$MWJ5EesYAs/6FV.vmKNYOucbQq79CVe7FVsDWv4EqfRR2TWwWVhy.	estudiante	active	f	\N	2025-09-06 13:05:04.411313-05	Montero	60766831	2007-08-03 19:00:00-05	2025-09-06 13:05:04.411313-05	\N	\N
83b68e29-92fa-4716-a6b5-d9c1b3881c06	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Mariano	prueba044@prueba.com	$2a$11$9liA049MAPzTsINlucJoK.xma33Dbcd0M1K4SVP90xd4ZXzNPAbsi	estudiante	active	f	\N	2025-09-06 13:05:05.425458-05	Barriga	15486018	2000-09-06 13:05:05.425457-05	2025-09-06 13:05:05.425458-05	\N	\N
ea031f5b-ad83-47a5-b6da-cc0a98714cac	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Cayetano	prueba045@prueba.com	$2a$11$95kAL0xSJRGLqYEOaKU6M.q69fCmcvW60u0rPKYwVCYTR53uBODFS	estudiante	active	f	\N	2025-09-06 13:05:06.517456-05	Ruiz	37940960	2000-09-06 13:05:06.517455-05	2025-09-06 13:05:06.517456-05	\N	\N
97bdebe9-28ba-4420-8dd3-cbde41755801	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Ruben	prueba046@prueba.com	$2a$11$HAxqKg2dMOWF7wBlPSqH..Amu8.nj2P7tl8h9wZH6Bags7v1ElxXi	estudiante	active	f	\N	2025-09-06 13:05:07.632032-05	Ramírez	10558717	2015-11-05 19:00:00-05	2025-09-06 13:05:07.632032-05	\N	\N
e70f7e61-4d8b-4ba0-9c18-b23230e16af3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Estrella	prueba047@prueba.com	$2a$11$5n.4byfEYAH4ih.QDDkH/OAA0wSanm.n4pVKDlVSjBkuRmckgb/y2	estudiante	active	f	\N	2025-09-06 13:05:08.726861-05	Jordá	71976706	2000-09-06 13:05:08.72686-05	2025-09-06 13:05:08.726861-05	\N	\N
83591c94-ac2f-4bb3-868d-cd0ef3ab4fa2	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Miguel Ángel	prueba048@prueba.com	$2a$11$GCLesla9lG/vmTQ2uZzf.uwgjvbr3.5jlt47tzB.AEP9IH/LfmCwe	estudiante	active	f	\N	2025-09-06 13:05:09.817419-05	Martinez	47724914	2009-03-06 19:00:00-05	2025-09-06 13:05:09.817419-05	\N	\N
4a44e91f-3021-4689-8596-61970517991b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Rosenda	prueba049@prueba.com	$2a$11$HPHa2COLAjp3E4isRpPPo.KOWEOBO4oTdyBKLctwYgWcQJwj/5v7a	estudiante	active	f	\N	2025-09-06 13:05:10.935922-05	Girona	59442451	2008-05-07 19:00:00-05	2025-09-06 13:05:10.935922-05	\N	\N
ba892e28-cfc4-4afd-885e-949ef2ccfea3	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Mariana	prueba050@prueba.com	$2a$11$k9/D5HpfkQiD4x26Z4QQX.hDrNBAJ9a1oEXHNi0z1pikZMkOwz3rO	estudiante	active	f	\N	2025-09-06 13:05:11.930872-05	Andrés	63243160	2006-04-09 19:00:00-05	2025-09-06 13:05:11.930872-05	\N	\N
ea16c16a-adf7-4846-8004-826ba68773d4	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María	prueba051@prueba.com	$2a$11$SttWdCnwGB6FRbYFiCUHc.V5X7P7cyWHlUQRxPNVHdfSpEBGo/cFa	estudiante	active	f	\N	2025-09-06 13:05:13.031887-05	Portero	41741049	2008-03-09 19:00:00-05	2025-09-06 13:05:13.031887-05	\N	\N
68ea8b03-9272-45f5-a95b-cab8525a11fe	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Concha	prueba052@prueba.com	$2a$11$mCPGgL1M1Poj22IwL7Td7un30JUYi2Otoa4mEQs.heFJslnL/qfNq	estudiante	active	f	\N	2025-09-06 13:05:14.127677-05	Gutiérrez	78282305	2012-04-03 19:00:00-05	2025-09-06 13:05:14.127677-05	\N	\N
dfb5d4aa-bd71-4d25-8dd2-9d5691592777	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Herberto	prueba053@prueba.com	$2a$11$eMS5CNoyhOVDLocZCFR7v.VkY0Amaxcqua4lnQowt4etP7UVcfMBC	estudiante	active	f	\N	2025-09-06 13:05:15.22525-05	Mena	24697380	2000-09-06 13:05:15.225249-05	2025-09-06 13:05:15.22525-05	\N	\N
668d1c4f-fa93-44f1-a73c-57d965ee03ba	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Pío	prueba054@prueba.com	$2a$11$p2E9KRrsIYZpBTOsy0.R6eiw9jLmTL6vMgy4DHjwlyeaZ6L4o/rkW	estudiante	active	f	\N	2025-09-06 13:05:16.430242-05	Martín	79713446	2000-09-06 13:05:16.430242-05	2025-09-06 13:05:16.430242-05	\N	\N
0bda8e73-9486-4eeb-a9bb-77885e40b59f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Loida	prueba055@prueba.com	$2a$11$cYbLz0Jo6NOr11YChp1Bf.yj1Y8tCkMIJyOO.V8jIiXXRUCc9AD7u	estudiante	active	f	\N	2025-09-06 13:05:17.436791-05	Arrieta	81585492	2000-09-06 13:05:17.436791-05	2025-09-06 13:05:17.436791-05	\N	\N
695b7110-31f6-4652-b77b-cb2aad386519	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Maricruz	prueba056@prueba.com	$2a$11$rwfMiCuEIjcU24V4DzyLTOHMHVOQxcBPwV7PSbTTrgfreD8gG7hbq	estudiante	active	f	\N	2025-09-06 13:05:18.522487-05	Morillo	28269029	2000-09-06 13:05:18.522487-05	2025-09-06 13:05:18.522487-05	\N	\N
813cfcf8-d6f1-4364-a76f-8497b0bb220d	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sancho	prueba057@prueba.com	$2a$11$EJSbVAP9KLzvEWSaNT.47Oqdp18aW8VGPyNecrApAFkJ.m3Uta8ti	estudiante	active	f	\N	2025-09-06 13:05:19.532747-05	Melero	30759585	2000-09-06 13:05:19.532746-05	2025-09-06 13:05:19.532747-05	\N	\N
16ee1e96-bae4-48bc-83a1-5a9f65b67e46	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Mariano	prueba058@prueba.com	$2a$11$.Ao6AgfyryIJ8fbWC10AOeJfYVSZHVhU7rQJg76FZF6vrmkaSgWOO	estudiante	active	f	\N	2025-09-06 13:05:20.617979-05	Izaguirre	31639994	2013-03-09 19:00:00-05	2025-09-06 13:05:20.617979-05	\N	\N
4eac2670-6939-442b-99af-e32af259ed20	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Luis Ángel	prueba059@prueba.com	$2a$11$0gmIZrHOTGhxaSpnH3Mrv.z0vIzD65wbEvl5a40B.2E9ytkceUjGK	estudiante	active	f	\N	2025-09-06 13:05:21.624011-05	Suárez	32660732	2000-09-06 13:05:21.624011-05	2025-09-06 13:05:21.624011-05	\N	\N
418d1a1f-f2c6-4222-aca9-29da04a3eb6a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Florinda	prueba060@prueba.com	$2a$11$XwOVHb4arcNosLQzAZfb6eTwmjA/RC0GBhUavdHn1QdPK4jfVAAIa	estudiante	active	f	\N	2025-09-06 13:05:22.715445-05	Pera	42310933	2000-09-06 13:05:22.715444-05	2025-09-06 13:05:22.715445-05	\N	\N
4792645b-7c5b-4c51-9a72-58aa57976074	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Carina	prueba061@prueba.com	$2a$11$YIMjoTucmYuFs.wl7KBmIerq/P36.r//ICcTG44CXfAWOnpSUklLK	estudiante	active	f	\N	2025-09-06 13:05:23.731007-05	Ayala	11585745	2000-09-06 13:05:23.731006-05	2025-09-06 13:05:23.731007-05	\N	\N
08d35a17-cb25-40af-8c01-881e5c43df48	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Gema	prueba062@prueba.com	$2a$11$rwe/stP/ESzjSajJ8Tzi0e2kRa5ErqKjocos7sWfzNil.IBFOcxUe	estudiante	active	f	\N	2025-09-06 13:05:24.834009-05	Terrón	13044064	2009-06-04 19:00:00-05	2025-09-06 13:05:24.83401-05	\N	\N
022ce88e-5b5d-4dd6-a0d5-ef799f3c766a	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	María	prueba063@prueba.com	$2a$11$BMHbc50VtVxedVAj0tvvr.XgoDq6m0kQrhI5E9x5OgasWAUbmpyOm	estudiante	active	f	\N	2025-09-06 13:05:25.867617-05	Peñas	17599659	2000-09-06 13:05:25.867617-05	2025-09-06 13:05:25.867617-05	\N	\N
73067c81-3edf-4d99-b56f-953f2f3a03f0	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Julia	prueba064@prueba.com	$2a$11$7CjwclpZ1nMfCwMDNKOpXOSHjacGSBZ0jZJTyU5oScjb3JsfxCvp2	estudiante	active	f	\N	2025-09-06 13:05:26.924785-05	Aller	83320784	2000-09-06 13:05:26.924785-05	2025-09-06 13:05:26.924785-05	\N	\N
4712c60c-a7c3-4c9f-867c-6ed44aecfbae	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Odalys	prueba065@prueba.com	$2a$11$ybfhtUH4Bpix2/1fuO8VYe2qE3AYD7Vzwtk1D9QIlx/1FpDJy16wG	estudiante	active	f	\N	2025-09-06 13:05:28.027565-05	Gárate	81369169	2010-11-02 19:00:00-05	2025-09-06 13:05:28.027565-05	\N	\N
22b44601-234e-435a-a690-a799e1191c6c	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Eligia	prueba066@prueba.com	$2a$11$9mQs5FNLCMxpHRJ1iNTDXOOtcro4kFus17Wf8jkX94bQZojK5/aUu	estudiante	active	f	\N	2025-09-06 13:05:29.120965-05	Exposito	77625918	2013-03-11 19:00:00-05	2025-09-06 13:05:29.120965-05	\N	\N
3cda6203-3f04-49c7-85da-2027423c08b5	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Lino	prueba067@prueba.com	$2a$11$CIfobcZgkzKLV/EouDQ9ied9JnTSU1MPmK/OiYMd8.VnNFDzyRo9y	estudiante	active	f	\N	2025-09-06 13:05:30.135435-05	Salvador	40610272	2000-09-06 13:05:30.135434-05	2025-09-06 13:05:30.135435-05	\N	\N
6b3bc4a4-c92f-4b3a-863f-343d3cd6ce5b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Lupita	prueba068@prueba.com	$2a$11$qlPvceehLLEhPFFEqkg1Quu.mJ9pVYeB6SOh9OZwELt/9CqXJd.ua	estudiante	active	f	\N	2025-09-06 13:05:31.213153-05	Agudo	38053622	2000-09-06 13:05:31.213153-05	2025-09-06 13:05:31.213153-05	\N	\N
fe5ee1f7-3ddf-4d81-826f-f1d129495169	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Primitivo	prueba069@prueba.com	$2a$11$bIDRMFAYb7x.cczZSp8aXunclgfdOueE/M3Ese4OXm5eYuoHkqEIK	estudiante	active	f	\N	2025-09-06 13:05:32.22367-05	Torrens	38166788	2000-09-06 13:05:32.22367-05	2025-09-06 13:05:32.22367-05	\N	\N
659c7325-61b1-4e10-bbdf-01644c1ca65b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Sandra	prueba070@prueba.com	$2a$11$zu3ZW4WecF4G.p./dXJOqutweE2kcRkyrB/UMkF/d7vfMS9gsJP0u	estudiante	active	f	\N	2025-09-06 13:05:33.235734-05	Badía	56407718	2014-02-07 19:00:00-05	2025-09-06 13:05:33.235734-05	\N	\N
b0830b4a-e562-4fc0-ae5c-1e9cb0ccc531	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 1	juan1@email.com	$2a$11$5yi8F47TCDmECqDuuAVOxO6yss/FlRKLj9lwemSUJTyc1mgOpuzoa	teacher	active	f	\N	2025-09-06 13:00:40.913342-05	Perez	9-789-183	2000-09-06 13:00:39.943614-05	\N	\N	\N
10e01ed6-ebac-4103-84ec-19815822556f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 2	juan2@email.com	$2a$11$AU8tr4nVem8XSp7HnxF/sO.iNAlCNebk2L6vbttvAXyW3kgstsfbG	teacher	active	f	\N	2025-09-06 13:00:42.212282-05	Perez	9-789-203	2000-09-06 13:00:41.128074-05	\N	\N	\N
d332fda9-9736-4c8c-84cb-aaa2eb0ccbf8	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 3	juan3@email.com	$2a$11$vNlKPSfTnAVwjKZt3UFuP.KL0lBUrUytskWb6brYKkZ/GQBfZmzUe	teacher	active	f	\N	2025-09-06 13:00:45.014235-05	Perez	9-789-260	1990-09-04 19:00:00-05	\N	\N	\N
8d6e4b17-3107-44be-938f-13374a2a268e	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 4	juan4@email.com	$2a$11$YYaBM3bz3A.iCALlEjlKkuG.CzqOwtFv9HbDFswI7JWXI6d5h9drm	teacher	active	f	\N	2025-09-06 13:00:46.514395-05	Perez	9-789-303	2000-09-06 13:00:45.438788-05	\N	\N	\N
71106b68-5bd5-4cdc-bffd-82ff6fe9e110	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 5	juan5@email.com	$2a$11$CuLlV4SVddzjv6vzmwEah.CLEqRILNDEQdCVids6BgWAreSp0YHUq	teacher	active	f	\N	2025-09-06 13:00:49.713186-05	Perez	9-789-376	1990-02-08 19:00:00-05	\N	\N	\N
cc1def40-ed6f-4755-84a1-45032743e293	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 6	juan6@email.com	$2a$11$wGc1Q7ZUUfXMishsc6Qx1eLKBsrMel0jPFLgse6jc.RbXHYwv0swW	teacher	active	f	\N	2025-09-06 13:00:53.013207-05	Perez	9-789-412	1990-08-09 19:00:00-05	\N	\N	\N
28155aef-3576-4174-af80-eb75b620ba9f	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 7	juan7@email.com	$2a$11$1pZdslVNjMgeYU885XI40OfqhsqAZCtil1YjwbxJzVcPemj40baha	teacher	active	f	\N	2025-09-06 13:00:54.317046-05	Perez	9-789-454	2000-09-06 13:00:53.326289-05	\N	\N	\N
7bd475f2-0efa-4c38-8032-2a45bba6c313	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 8	juan8@email.com	$2a$11$0z.yMdURIvbEtESc8rEeMOdUEmwEdIyqf2yaE6I1nLuMw2WzQgGS2	teacher	active	f	\N	2025-09-06 13:00:56.112766-05	Perez	9-789-500	1991-03-31 19:00:00-05	\N	\N	\N
a7c08bc7-d1a4-46e5-b46e-9194ce45c94b	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 9	juan9@email.com	$2a$11$VzBF3Z2.l7MgcjlowOxqVO4eHovc8vMrgVLZpA76yg/lmNwMfJqSq	teacher	active	f	\N	2025-09-06 13:00:58.914124-05	Perez	9-789-570	2000-09-06 13:00:56.915576-05	\N	\N	\N
c7c18b5a-3677-4157-9e39-cebd25d38385	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Juan 11	juan11@email.com	$2a$11$9AgJNbO1F9u/5xEuA8zrWe6jjfgnaXBBTz4RbSSAp/opMwwU89hoS	teacher	active	f	2025-09-07 17:44:27.971498-05	2025-09-06 13:00:38.225816-05	Perez	9-789-751	1991-12-08 19:00:00-05	\N	\N	\N
2444d902-b4c7-4dde-875b-9b529604b305	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Amaro	irvingcorrosk19@gmail.com	$2a$11$.AIWCbTcGWW.T6/Agan.6.5QiKml5cbD5nSbo4fUxxd2OMxWvv/5O	estudiante	active	f	2025-09-06 14:59:14.414319-05	2025-09-06 13:05:01.336463-05	Vendrell	33875322	2000-09-06 00:00:00-05	2025-09-06 13:05:01.336463-05	\N	\N
21e66209-995a-4182-98e9-33d2ab635b48	ecaa3808-5b26-4f02-8365-cf12e2e5cbe5	Quenna	quenna.lopez@qlservice.net	$2a$11$ijYC6tyYjXnk.l2uWu.0QeINxiYVKAVhEHwTbaTg5CUtEtlTEZ8i6	admin	active	f	2025-09-07 18:58:45.333346-05	2025-09-06 11:58:51.905454-05	Lopez	\N	2025-09-05 19:00:00-05	\N	\N	\N
\.


--
-- TOC entry 5046 (class 2606 OID 202604)
-- Name: EmailConfigurations PK_EmailConfigurations; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmailConfigurations"
    ADD CONSTRAINT "PK_EmailConfigurations" PRIMARY KEY ("Id");


--
-- TOC entry 4930 (class 2606 OID 201686)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 4936 (class 2606 OID 201688)
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- TOC entry 4942 (class 2606 OID 201690)
-- Name: activity_attachments activity_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 4947 (class 2606 OID 201692)
-- Name: activity_types activity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4951 (class 2606 OID 201694)
-- Name: area area_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--
-- TOC entry 4957 (class 2606 OID 201696)
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- TOC entry 4961 (class 2606 OID 201698)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 5037 (class 2606 OID 202051)
-- Name: counselor_assignments counselor_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4968 (class 2606 OID 201700)
-- Name: discipline_reports discipline_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 4970 (class 2606 OID 201702)
-- Name: email_configurations email_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.email_configurations
    ADD CONSTRAINT email_configurations_pkey PRIMARY KEY (id);


--
-- TOC entry 4974 (class 2606 OID 201704)
-- Name: grade_levels grade_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.grade_levels
    ADD CONSTRAINT grade_levels_pkey PRIMARY KEY (id);


--
-- TOC entry 4977 (class 2606 OID 201706)
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- TOC entry 4980 (class 2606 OID 201708)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 4983 (class 2606 OID 201710)
-- Name: security_settings security_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 4986 (class 2606 OID 201712)
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- TOC entry 4990 (class 2606 OID 201714)
-- Name: student_activity_scores student_activity_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 4996 (class 2606 OID 201716)
-- Name: student_assignments student_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT student_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5000 (class 2606 OID 201718)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 5007 (class 2606 OID 201720)
-- Name: subject_assignments subject_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5011 (class 2606 OID 201722)
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 5014 (class 2606 OID 201724)
-- Name: teacher_assignments teacher_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 5019 (class 2606 OID 201726)
-- Name: trimester trimester_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_pkey PRIMARY KEY (id);


--
-- TOC entry 5022 (class 2606 OID 201728)
-- Name: user_grades user_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT user_grades_pkey PRIMARY KEY (user_id, grade_id);


--
-- TOC entry 5025 (class 2606 OID 201730)
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (user_id, group_id);


--
-- TOC entry 5028 (class 2606 OID 201732)
-- Name: user_subjects user_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT user_subjects_pkey PRIMARY KEY (user_id, subject_id);


--
-- TOC entry 5035 (class 2606 OID 201734)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5044 (class 1259 OID 202610)
-- Name: IX_EmailConfigurations_SchoolId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_EmailConfigurations_SchoolId" ON public."EmailConfigurations" USING btree ("SchoolId");


--
-- TOC entry 4931 (class 1259 OID 201735)
-- Name: IX_activities_ActivityTypeId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_activities_ActivityTypeId" ON public.activities USING btree ("ActivityTypeId");


--
-- TOC entry 4932 (class 1259 OID 201736)
-- Name: IX_activities_TrimesterId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_activities_TrimesterId" ON public.activities USING btree ("TrimesterId");


--
-- TOC entry 4933 (class 1259 OID 201737)
-- Name: IX_activities_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_activities_school_id" ON public.activities USING btree (school_id);


--
-- TOC entry 4934 (class 1259 OID 201738)
-- Name: IX_activities_subject_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_activities_subject_id" ON public.activities USING btree (subject_id);


--
-- TOC entry 4944 (class 1259 OID 201739)
-- Name: IX_activity_types_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_activity_types_school_id" ON public.activity_types USING btree (school_id);


--
-- TOC entry 4948 (class 1259 OID 201740)
-- Name: IX_area_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_area_school_id" ON public.area USING btree (school_id);


--
-- TOC entry 4952 (class 1259 OID 201741)
-- Name: IX_attendance_grade_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_attendance_grade_id" ON public.attendance USING btree (grade_id);


--
-- TOC entry 4953 (class 1259 OID 201742)
-- Name: IX_attendance_group_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_attendance_group_id" ON public.attendance USING btree (group_id);


--
-- TOC entry 4954 (class 1259 OID 201743)
-- Name: IX_attendance_student_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_attendance_student_id" ON public.attendance USING btree (student_id);


--
-- TOC entry 4955 (class 1259 OID 201744)
-- Name: IX_attendance_teacher_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_attendance_teacher_id" ON public.attendance USING btree (teacher_id);


--
-- TOC entry 4958 (class 1259 OID 201745)
-- Name: IX_audit_logs_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_audit_logs_school_id" ON public.audit_logs USING btree (school_id);


--
-- TOC entry 4959 (class 1259 OID 201746)
-- Name: IX_audit_logs_user_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_audit_logs_user_id" ON public.audit_logs USING btree (user_id);


--
-- TOC entry 4962 (class 1259 OID 201747)
-- Name: IX_discipline_reports_grade_level_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_discipline_reports_grade_level_id" ON public.discipline_reports USING btree (grade_level_id);


--
-- TOC entry 4963 (class 1259 OID 201748)
-- Name: IX_discipline_reports_group_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_discipline_reports_group_id" ON public.discipline_reports USING btree (group_id);


--
-- TOC entry 4964 (class 1259 OID 201749)
-- Name: IX_discipline_reports_student_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_discipline_reports_student_id" ON public.discipline_reports USING btree (student_id);


--
-- TOC entry 4965 (class 1259 OID 201750)
-- Name: IX_discipline_reports_subject_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_discipline_reports_subject_id" ON public.discipline_reports USING btree (subject_id);


--
-- TOC entry 4966 (class 1259 OID 201751)
-- Name: IX_discipline_reports_teacher_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_discipline_reports_teacher_id" ON public.discipline_reports USING btree (teacher_id);


--
-- TOC entry 4975 (class 1259 OID 201752)
-- Name: IX_groups_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_groups_school_id" ON public.groups USING btree (school_id);


--
-- TOC entry 4978 (class 1259 OID 201753)
-- Name: IX_schools_admin_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX "IX_schools_admin_id" ON public.schools USING btree (admin_id);


--
-- TOC entry 4981 (class 1259 OID 201754)
-- Name: IX_security_settings_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_security_settings_school_id" ON public.security_settings USING btree (school_id);


--
-- TOC entry 4992 (class 1259 OID 201755)
-- Name: IX_student_assignments_grade_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_student_assignments_grade_id" ON public.student_assignments USING btree (grade_id);


--
-- TOC entry 4993 (class 1259 OID 201756)
-- Name: IX_student_assignments_group_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_student_assignments_group_id" ON public.student_assignments USING btree (group_id);


--
-- TOC entry 4994 (class 1259 OID 201757)
-- Name: IX_student_assignments_student_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_student_assignments_student_id" ON public.student_assignments USING btree (student_id);


--
-- TOC entry 4997 (class 1259 OID 201758)
-- Name: IX_students_parent_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_students_parent_id" ON public.students USING btree (parent_id);


--
-- TOC entry 4998 (class 1259 OID 201759)
-- Name: IX_students_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_students_school_id" ON public.students USING btree (school_id);


--
-- TOC entry 5001 (class 1259 OID 201760)
-- Name: IX_subject_assignments_SchoolId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_subject_assignments_SchoolId" ON public.subject_assignments USING btree ("SchoolId");


--
-- TOC entry 5002 (class 1259 OID 201761)
-- Name: IX_subject_assignments_area_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_subject_assignments_area_id" ON public.subject_assignments USING btree (area_id);


--
-- TOC entry 5003 (class 1259 OID 201762)
-- Name: IX_subject_assignments_grade_level_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_subject_assignments_grade_level_id" ON public.subject_assignments USING btree (grade_level_id);


--
-- TOC entry 5004 (class 1259 OID 201763)
-- Name: IX_subject_assignments_group_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_subject_assignments_group_id" ON public.subject_assignments USING btree (group_id);


--
-- TOC entry 5005 (class 1259 OID 201764)
-- Name: IX_subject_assignments_subject_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_subject_assignments_subject_id" ON public.subject_assignments USING btree (subject_id);


--
-- TOC entry 5008 (class 1259 OID 201765)
-- Name: IX_subjects_AreaId; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_subjects_AreaId" ON public.subjects USING btree ("AreaId");


--
-- TOC entry 5009 (class 1259 OID 201766)
-- Name: IX_subjects_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_subjects_school_id" ON public.subjects USING btree (school_id);


--
-- TOC entry 5012 (class 1259 OID 201767)
-- Name: IX_teacher_assignments_subject_assignment_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_teacher_assignments_subject_assignment_id" ON public.teacher_assignments USING btree (subject_assignment_id);


--
-- TOC entry 5016 (class 1259 OID 201768)
-- Name: IX_trimester_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_trimester_school_id" ON public.trimester USING btree (school_id);


--
-- TOC entry 5020 (class 1259 OID 201769)
-- Name: IX_user_grades_grade_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_user_grades_grade_id" ON public.user_grades USING btree (grade_id);


--
-- TOC entry 5023 (class 1259 OID 201770)
-- Name: IX_user_groups_group_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_user_groups_group_id" ON public.user_groups USING btree (group_id);


--
-- TOC entry 5026 (class 1259 OID 201771)
-- Name: IX_user_subjects_subject_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_user_subjects_subject_id" ON public.user_subjects USING btree (subject_id);


--
-- TOC entry 5029 (class 1259 OID 202613)
-- Name: IX_users_cellphone_primary; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_users_cellphone_primary" ON public.users USING btree (cellphone_primary);


--
-- TOC entry 5030 (class 1259 OID 202614)
-- Name: IX_users_cellphone_secondary; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_users_cellphone_secondary" ON public.users USING btree (cellphone_secondary);


--
-- TOC entry 5031 (class 1259 OID 201772)
-- Name: IX_users_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IX_users_school_id" ON public.users USING btree (school_id);


--
-- TOC entry 4945 (class 1259 OID 201773)
-- Name: activity_types_name_school_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX activity_types_name_school_key ON public.activity_types USING btree (name, school_id);


--
-- TOC entry 4949 (class 1259 OID 201774)
-- Name: area_name_school_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX area_name_school_key ON public.area USING btree (name, school_id);


--
-- TOC entry 5038 (class 1259 OID 202612)
-- Name: counselor_assignments_school_grade_group_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX counselor_assignments_school_grade_group_key ON public.counselor_assignments USING btree (school_id, grade_id, group_id) WHERE ((grade_id IS NOT NULL) AND (group_id IS NOT NULL));


--
-- TOC entry 5039 (class 1259 OID 202072)
-- Name: counselor_assignments_school_user_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX counselor_assignments_school_user_key ON public.counselor_assignments USING btree (school_id, user_id);


--
-- TOC entry 4972 (class 1259 OID 201775)
-- Name: grade_levels_name_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX grade_levels_name_key ON public.grade_levels USING btree (name);


--
-- TOC entry 4937 (class 1259 OID 201776)
-- Name: idx_activities_group; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_activities_group ON public.activities USING btree (group_id);


--
-- TOC entry 4938 (class 1259 OID 201777)
-- Name: idx_activities_teacher; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_activities_teacher ON public.activities USING btree (teacher_id);


--
-- TOC entry 4939 (class 1259 OID 201778)
-- Name: idx_activities_trimester; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_activities_trimester ON public.activities USING btree (trimester);


--
-- TOC entry 4940 (class 1259 OID 201779)
-- Name: idx_activities_unique_lookup; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_activities_unique_lookup ON public.activities USING btree (name, type, subject_id, group_id, teacher_id, trimester);


--
-- TOC entry 4943 (class 1259 OID 201780)
-- Name: idx_attach_activity; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_attach_activity ON public.activity_attachments USING btree (activity_id);


--
-- TOC entry 5040 (class 1259 OID 202077)
-- Name: idx_counselor_assignments_grade; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_grade ON public.counselor_assignments USING btree (grade_id);


--
-- TOC entry 5041 (class 1259 OID 202078)
-- Name: idx_counselor_assignments_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_group ON public.counselor_assignments USING btree (group_id);


--
-- TOC entry 5042 (class 1259 OID 202075)
-- Name: idx_counselor_assignments_school; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_school ON public.counselor_assignments USING btree (school_id);


--
-- TOC entry 5043 (class 1259 OID 202076)
-- Name: idx_counselor_assignments_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_counselor_assignments_user ON public.counselor_assignments USING btree (user_id);


--
-- TOC entry 4971 (class 1259 OID 201781)
-- Name: idx_email_configurations_school_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_email_configurations_school_id ON public.email_configurations USING btree (school_id);


--
-- TOC entry 4987 (class 1259 OID 201782)
-- Name: idx_scores_activity; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_scores_activity ON public.student_activity_scores USING btree (activity_id);


--
-- TOC entry 4988 (class 1259 OID 201783)
-- Name: idx_scores_student; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_scores_student ON public.student_activity_scores USING btree (student_id);


--
-- TOC entry 4984 (class 1259 OID 201784)
-- Name: specialties_name_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX specialties_name_key ON public.specialties USING btree (name);


--
-- TOC entry 5015 (class 1259 OID 201785)
-- Name: teacher_assignments_teacher_id_subject_assignment_id_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX teacher_assignments_teacher_id_subject_assignment_id_key ON public.teacher_assignments USING btree (teacher_id, subject_assignment_id);


--
-- TOC entry 5017 (class 1259 OID 201786)
-- Name: trimester_name_school_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX trimester_name_school_key ON public.trimester USING btree (name, school_id);


--
-- TOC entry 4991 (class 1259 OID 201787)
-- Name: uq_scores; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX uq_scores ON public.student_activity_scores USING btree (student_id, activity_id);


--
-- TOC entry 5032 (class 1259 OID 201788)
-- Name: users_document_id_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX users_document_id_key ON public.users USING btree (document_id);


--
-- TOC entry 5033 (class 1259 OID 201789)
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- TOC entry 5100 (class 2606 OID 202605)
-- Name: EmailConfigurations FK_EmailConfigurations_schools_SchoolId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EmailConfigurations"
    ADD CONSTRAINT "FK_EmailConfigurations_schools_SchoolId" FOREIGN KEY ("SchoolId") REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5047 (class 2606 OID 201790)
-- Name: activities FK_activities_activity_types_ActivityTypeId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_activity_types_ActivityTypeId" FOREIGN KEY ("ActivityTypeId") REFERENCES public.activity_types(id);


--
-- TOC entry 5048 (class 2606 OID 201795)
-- Name: activities FK_activities_trimester_TrimesterId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_trimester_TrimesterId" FOREIGN KEY ("TrimesterId") REFERENCES public.trimester(id);


--
-- TOC entry 5069 (class 2606 OID 201800)
-- Name: schools FK_schools_users_admin_id; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT "FK_schools_users_admin_id" FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- TOC entry 5078 (class 2606 OID 201805)
-- Name: subject_assignments FK_subject_assignments_schools_SchoolId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT "FK_subject_assignments_schools_SchoolId" FOREIGN KEY ("SchoolId") REFERENCES public.schools(id);


--
-- TOC entry 5084 (class 2606 OID 201810)
-- Name: subjects FK_subjects_area_AreaId; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT "FK_subjects_area_AreaId" FOREIGN KEY ("AreaId") REFERENCES public.area(id);


--
-- TOC entry 5049 (class 2606 OID 201815)
-- Name: activities activities_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5050 (class 2606 OID 201820)
-- Name: activities activities_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5051 (class 2606 OID 201825)
-- Name: activities activities_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5052 (class 2606 OID 201830)
-- Name: activities activities_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5053 (class 2606 OID 201835)
-- Name: activity_attachments activity_attachments_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5054 (class 2606 OID 201840)
-- Name: activity_types activity_types_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5055 (class 2606 OID 201845)
-- Name: area area_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5056 (class 2606 OID 201850)
-- Name: attendance attendance_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5057 (class 2606 OID 201855)
-- Name: attendance attendance_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5058 (class 2606 OID 201860)
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5059 (class 2606 OID 201865)
-- Name: attendance attendance_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5060 (class 2606 OID 201870)
-- Name: audit_logs audit_logs_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- TOC entry 5061 (class 2606 OID 201875)
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5096 (class 2606 OID 202062)
-- Name: counselor_assignments counselor_assignments_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id) ON DELETE SET NULL;


--
-- TOC entry 5097 (class 2606 OID 202067)
-- Name: counselor_assignments counselor_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- TOC entry 5098 (class 2606 OID 202052)
-- Name: counselor_assignments counselor_assignments_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5099 (class 2606 OID 202057)
-- Name: counselor_assignments counselor_assignments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5062 (class 2606 OID 201880)
-- Name: discipline_reports discipline_reports_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5063 (class 2606 OID 201885)
-- Name: discipline_reports discipline_reports_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5064 (class 2606 OID 201890)
-- Name: discipline_reports discipline_reports_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5065 (class 2606 OID 201895)
-- Name: discipline_reports discipline_reports_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5066 (class 2606 OID 201900)
-- Name: discipline_reports discipline_reports_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5067 (class 2606 OID 201905)
-- Name: email_configurations email_configurations_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.email_configurations
    ADD CONSTRAINT email_configurations_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5073 (class 2606 OID 201910)
-- Name: student_assignments fk_grade; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5074 (class 2606 OID 201915)
-- Name: student_assignments fk_group; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5075 (class 2606 OID 201920)
-- Name: student_assignments fk_student; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5089 (class 2606 OID 201925)
-- Name: user_grades fk_user_grades_grade; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5090 (class 2606 OID 201930)
-- Name: user_grades fk_user_grades_user; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5091 (class 2606 OID 201935)
-- Name: user_groups fk_user_groups_group; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5092 (class 2606 OID 201940)
-- Name: user_groups fk_user_groups_user; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5093 (class 2606 OID 201945)
-- Name: user_subjects fk_user_subjects_subject; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_subject FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5094 (class 2606 OID 201950)
-- Name: user_subjects fk_user_subjects_user; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5068 (class 2606 OID 201955)
-- Name: groups groups_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5070 (class 2606 OID 201960)
-- Name: security_settings security_settings_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5071 (class 2606 OID 201965)
-- Name: student_activity_scores student_activity_scores_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5072 (class 2606 OID 201970)
-- Name: student_activity_scores student_activity_scores_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5076 (class 2606 OID 201975)
-- Name: students students_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- TOC entry 5077 (class 2606 OID 201980)
-- Name: students students_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5079 (class 2606 OID 201985)
-- Name: subject_assignments subject_assignments_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.area(id);


--
-- TOC entry 5080 (class 2606 OID 201990)
-- Name: subject_assignments subject_assignments_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5081 (class 2606 OID 201995)
-- Name: subject_assignments subject_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5082 (class 2606 OID 202000)
-- Name: subject_assignments subject_assignments_specialty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES public.specialties(id);


--
-- TOC entry 5083 (class 2606 OID 202005)
-- Name: subject_assignments subject_assignments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5085 (class 2606 OID 202010)
-- Name: subjects subjects_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5086 (class 2606 OID 202015)
-- Name: teacher_assignments teacher_assignments_subject_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_subject_assignment_id_fkey FOREIGN KEY (subject_assignment_id) REFERENCES public.subject_assignments(id);


--
-- TOC entry 5087 (class 2606 OID 202020)
-- Name: teacher_assignments teacher_assignments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5088 (class 2606 OID 202025)
-- Name: trimester trimester_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5095 (class 2606 OID 202030)
-- Name: users users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 260
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea) TO admin;


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 263
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO admin;


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 264
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.crypt(text, text) TO admin;


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 257
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dearmor(text) TO admin;


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 265
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO admin;


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 266
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO admin;


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 246
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(bytea, text) TO admin;


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 267
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(text, text) TO admin;


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 248
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO admin;


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 249
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO admin;


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 250
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO admin;


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 268
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_uuid() TO admin;


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 251
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text) TO admin;


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 252
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO admin;


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 269
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO admin;


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 247
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(text, text, text) TO admin;


--
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 270
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO admin;


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 256
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO admin;


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 271
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO admin;


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 272
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO admin;


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 273
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO admin;


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 274
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO admin;


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 255
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO admin;


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 275
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO admin;


--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 276
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO admin;


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 277
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO admin;


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 254
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO admin;


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 278
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO admin;


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 279
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO admin;


--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 280
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO admin;


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 281
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO admin;


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 282
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO admin;


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 287
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO admin;


--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 294
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO admin;


--
-- TOC entry 5314 (class 0 OID 0)
-- Dependencies: 253
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO admin;


--
-- TOC entry 5315 (class 0 OID 0)
-- Dependencies: 295
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO admin;


--
-- TOC entry 5316 (class 0 OID 0)
-- Dependencies: 297
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v1() TO admin;


--
-- TOC entry 5317 (class 0 OID 0)
-- Dependencies: 258
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v1mc() TO admin;


--
-- TOC entry 5318 (class 0 OID 0)
-- Dependencies: 298
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v3(namespace uuid, name text) TO admin;


--
-- TOC entry 5319 (class 0 OID 0)
-- Dependencies: 261
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v4() TO admin;


--
-- TOC entry 5320 (class 0 OID 0)
-- Dependencies: 262
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v5(namespace uuid, name text) TO admin;


--
-- TOC entry 5321 (class 0 OID 0)
-- Dependencies: 299
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_nil() TO admin;


--
-- TOC entry 5322 (class 0 OID 0)
-- Dependencies: 300
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_dns() TO admin;


--
-- TOC entry 5323 (class 0 OID 0)
-- Dependencies: 259
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_oid() TO admin;


--
-- TOC entry 5324 (class 0 OID 0)
-- Dependencies: 301
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_url() TO admin;


--
-- TOC entry 5325 (class 0 OID 0)
-- Dependencies: 302
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_x500() TO admin;


--
-- TOC entry 5326 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE "EmailConfigurations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."EmailConfigurations" TO admin;


--
-- TOC entry 5327 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE counselor_assignments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.counselor_assignments TO admin;


--
-- TOC entry 2195 (class 826 OID 202035)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON SEQUENCES TO admin;


--
-- TOC entry 2196 (class 826 OID 202036)
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TYPES TO admin;


--
-- TOC entry 2197 (class 826 OID 202037)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON FUNCTIONS TO admin;


--
-- TOC entry 2198 (class 826 OID 202038)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES TO admin;


-- Completed on 2025-09-07 19:02:51

--
-- PostgreSQL database dump complete
--

