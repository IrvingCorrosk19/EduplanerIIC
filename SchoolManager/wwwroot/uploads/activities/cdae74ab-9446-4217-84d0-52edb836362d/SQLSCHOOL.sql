--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2025-07-07 20:59:44

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
-- TOC entry 2 (class 3079 OID 16862)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5223 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 3 (class 3079 OID 16899)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5224 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 16910)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16913)
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
    due_date timestamp with time zone
);


ALTER TABLE public.activities OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16920)
-- Name: activity_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    activity_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    storage_path character varying(500) NOT NULL,
    mime_type character varying(50) NOT NULL,
    uploaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.activity_attachments OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16927)
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
    updated_at timestamp with time zone
);


ALTER TABLE public.activity_types OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16937)
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
    updated_at timestamp with time zone
);


ALTER TABLE public.area OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16947)
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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16952)
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
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16959)
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
    grade_level_id uuid
);


ALTER TABLE public.discipline_reports OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16966)
-- Name: grade_levels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grade_levels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.grade_levels OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16973)
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid,
    name character varying(20) NOT NULL,
    grade character varying(20),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    description text
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16980)
-- Name: schools; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.schools OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16989)
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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.security_settings OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 17003)
-- Name: specialties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specialties (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.specialties OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 17010)
-- Name: student_activity_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_activity_scores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    activity_id uuid NOT NULL,
    score numeric(2,1),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.student_activity_scores OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17015)
-- Name: student_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    grade_id uuid NOT NULL,
    group_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.student_assignments OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17020)
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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 17025)
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
    "SchoolId" uuid
);


ALTER TABLE public.subject_assignments OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17030)
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
    "AreaId" uuid
);


ALTER TABLE public.subjects OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 17038)
-- Name: teacher_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teacher_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    teacher_id uuid NOT NULL,
    subject_assignment_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.teacher_assignments OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 17043)
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
    updated_at timestamp with time zone
);


ALTER TABLE public.trimester OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 17051)
-- Name: user_grades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_grades (
    user_id uuid NOT NULL,
    grade_id uuid NOT NULL
);


ALTER TABLE public.user_grades OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 17054)
-- Name: user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_groups (
    user_id uuid NOT NULL,
    group_id uuid NOT NULL
);


ALTER TABLE public.user_groups OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 17057)
-- Name: user_subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_subjects (
    user_id uuid NOT NULL,
    subject_id uuid NOT NULL
);


ALTER TABLE public.user_subjects OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 17060)
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
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('superadmin'::character varying)::text, ('admin'::character varying)::text, ('director'::character varying)::text, ('teacher'::character varying)::text, ('parent'::character varying)::text, ('student'::character varying)::text, ('estudiante'::character varying)::text]))),
    CONSTRAINT users_status_check CHECK (((status)::text = ANY (ARRAY[('active'::character varying)::text, ('inactive'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 5194 (class 0 OID 16910)
-- Dependencies: 219
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
\.


--
-- TOC entry 5195 (class 0 OID 16913)
-- Dependencies: 220
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (id, school_id, subject_id, teacher_id, group_id, name, type, trimester, pdf_url, created_at, grade_level_id, "ActivityTypeId", "TrimesterId", due_date) FROM stdin;
7da33029-0760-445a-96d6-c98f8b77f815	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	d401c0d5-ffab-420d-998d-9a2481987504	849bc167-84a0-4feb-89fa-d38a621221e0	01995b64-a990-443f-a210-0ee930fd8331	panama	Tarea	2T	\N	2025-07-07 18:44:23.761385-05	a3283c67-ae8b-46f7-99f0-ee3a59885978	\N	99f02818-f409-49f0-ae06-3da03884dd35	2025-07-30 00:00:00-05
\.


--
-- TOC entry 5196 (class 0 OID 16920)
-- Dependencies: 221
-- Data for Name: activity_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_attachments (id, activity_id, file_name, storage_path, mime_type, uploaded_at) FROM stdin;
\.


--
-- TOC entry 5197 (class 0 OID 16927)
-- Dependencies: 222
-- Data for Name: activity_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_types (id, school_id, name, description, icon, color, is_global, display_order, is_active, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5198 (class 0 OID 16937)
-- Dependencies: 223
-- Data for Name: area; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.area (id, school_id, name, description, code, is_global, display_order, is_active, created_at, updated_at) FROM stdin;
9114e054-5c47-4369-ad9a-6dea25ec5dcd	\N	TECNOLÓGICA	\N	\N	f	0	t	2025-06-14 23:41:57.255163-05	\N
b7bb6287-fea2-4ad8-b962-a36f7531676a	\N	CIENTÍFICA	\N	\N	f	0	t	2025-06-14 23:41:57.612698-05	\N
af7361ff-09bb-4c3e-9570-03ef61efb0aa	\N	HUMANISTICA	\N	\N	f	0	t	2025-06-14 23:41:57.747786-05	\N
7873164c-f5ce-4eff-bc6f-db7b188d33c0	\N	ddd	dddd	\N	f	0	f	2025-07-05 23:00:13.367397-05	\N
\.


--
-- TOC entry 5199 (class 0 OID 16947)
-- Dependencies: 224
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, student_id, teacher_id, group_id, grade_id, date, status, created_at) FROM stdin;
\.


--
-- TOC entry 5200 (class 0 OID 16952)
-- Dependencies: 225
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, school_id, user_id, user_name, user_role, action, resource, details, ip_address, "timestamp") FROM stdin;
\.


--
-- TOC entry 5201 (class 0 OID 16959)
-- Dependencies: 226
-- Data for Name: discipline_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discipline_reports (id, student_id, teacher_id, date, report_type, description, status, created_at, updated_at, subject_id, group_id, grade_level_id) FROM stdin;
\.


--
-- TOC entry 5202 (class 0 OID 16966)
-- Dependencies: 227
-- Data for Name: grade_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grade_levels (id, name, description, created_at) FROM stdin;
a3283c67-ae8b-46f7-99f0-ee3a59885978	10	\N	2025-06-14 23:41:57.374673-05
e3208170-5974-47fd-af5b-ed389790dc6f	12	\N	2025-06-14 23:41:57.67114-05
74a61edd-271e-426a-9652-aa93960431b3	11	\N	2025-06-14 23:41:57.714896-05
5d8ca774-6339-42af-90dc-e3a9bec0fbe2	1	\N	2025-06-14 23:41:58.755316-05
ced697ac-255f-4a98-aad5-5d90bed79ec5	2	\N	2025-06-14 23:41:58.790873-05
0933b030-498d-440a-8315-0d492981755e	3	\N	2025-06-14 23:41:58.828134-05
6d919423-659f-4d5d-82ae-60ffe980ec31	4	\N	2025-06-14 23:41:58.864965-05
cf0ee27e-e396-4d6f-9b01-274a0b956edb	5	\N	2025-06-14 23:41:58.901371-05
a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	6	\N	2025-06-14 23:41:58.939689-05
0f60cac0-4564-4e5f-860c-0fad0a817b40	7	\N	2025-06-14 23:41:58.981142-05
9676fd9a-916d-4f9c-8f33-4f3727a23d57	8	\N	2025-06-14 23:41:59.016134-05
3c36afca-f68d-4523-bb81-b12644aae620	9	\N	2025-06-14 23:41:59.051748-05
802bf302-fc4b-4d46-a3e0-ac202c8ba414	13	3333	2025-07-05 23:00:53.189069-05
\.


--
-- TOC entry 5203 (class 0 OID 16973)
-- Dependencies: 228
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, school_id, name, grade, created_at, description) FROM stdin;
01995b64-a990-443f-a210-0ee930fd8331	\N	C	\N	2025-06-14 23:41:57.427126-05	\N
5fd6e94f-528e-42f9-9254-937d15b8059b	\N	D	\N	2025-06-14 23:41:57.582109-05	\N
0530747f-cbde-469f-9f75-b27bcf7ed324	\N	E	\N	2025-06-14 23:41:57.629047-05	\N
67227029-b40c-49cb-a533-b145795385f0	\N	N	\N	2025-06-14 23:41:57.678-05	\N
904c0067-4026-4732-82ac-840ccde9bfb0	\N	B	\N	2025-06-14 23:41:57.765711-05	\N
4e53507a-2a88-4d6b-9d02-17083f4036b8	\N	F	\N	2025-06-14 23:41:57.869747-05	\N
fee6b9fe-5ef6-4373-8193-54d9c71b7119	\N	G	\N	2025-06-14 23:41:57.947904-05	\N
88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	\N	H	\N	2025-06-14 23:41:57.986101-05	\N
465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	\N	I	\N	2025-06-14 23:41:58.024536-05	\N
4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	\N	J	\N	2025-06-14 23:41:58.065466-05	\N
baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	\N	K	\N	2025-06-14 23:41:58.105106-05	\N
45556e56-b550-424e-bb47-08ff7ca7dd05	\N	L	\N	2025-06-14 23:41:58.143598-05	\N
30c35313-f6c8-4da1-94c9-0ea8a1f94435	\N	M	\N	2025-06-14 23:41:58.181754-05	\N
5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	\N	O	\N	2025-06-14 23:41:58.250626-05	\N
4f5e7435-3e6a-483a-bfbe-983faa96ea2b	\N	A	\N	2025-06-14 23:41:58.291829-05	\N
4b02049a-6d6d-4872-8683-ddbf59278d06	\N	dd	\N	2025-07-05 23:00:30.789134-05	ddd
\.


--
-- TOC entry 5204 (class 0 OID 16980)
-- Dependencies: 229
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schools (id, name, address, phone, logo_url, created_at, admin_id) FROM stdin;
57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	El Porvenir	admin@correo.com	65140986	93f02b43-6687-4cd3-9006-f05ea1b2dc19_ElPorvenir.png	2025-07-05 18:35:58.467312-05	0d8014f2-3870-4e3e-ad7a-21138c70f1e3
\.


--
-- TOC entry 5205 (class 0 OID 16989)
-- Dependencies: 230
-- Data for Name: security_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.security_settings (id, school_id, password_min_length, require_uppercase, require_lowercase, require_numbers, require_special, expiry_days, prevent_reuse, max_login_attempts, session_timeout_minutes, created_at) FROM stdin;
\.


--
-- TOC entry 5206 (class 0 OID 17003)
-- Dependencies: 231
-- Data for Name: specialties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specialties (id, name, description, created_at) FROM stdin;
d12c8727-d989-4a7f-a4ae-252f19944456	BACHILLER EN COMERCIO	\N	2025-06-14 23:41:57.210292-05
fdcbe1e4-81db-4211-90c0-66607403a000	BACHILLER EN  COMERCIO BILINGÜE	\N	2025-06-14 23:41:57.558533-05
5fc4896c-8aef-46ce-9cd7-3caec468a11e	BACHILLER EN CONTABILIDAD	\N	2025-06-14 23:41:57.604202-05
a5bdd381-00ac-4081-a433-ed868d43cf25	BACHILLER EN  TECNOLOGÍA INFORMÁTICA	\N	2025-06-14 23:41:57.653393-05
837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	BACHILLER EN HUMANIDADES	\N	2025-06-14 23:41:57.74003-05
1cb7fa4b-146f-4c57-ac39-eff30afb4cea	BACHILLER EN TURISMO	\N	2025-06-14 23:41:57.852186-05
ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	BACHILLER INDUSTRIAL EN  TECNOLOGÍA MECÁNICA	\N	2025-06-14 23:41:57.899593-05
f177b290-61b1-4114-96e4-9e5f3ae82c7d	BACHILLER INDUSTRIAL EN  AUTOTRÓNICA	\N	2025-06-14 23:41:57.969532-05
b97f483e-719a-44a7-97ea-6f29de181b8f	BACHILLER INDUSTRIAL EN  REFRIGERACIÓN Y CLIMATIZACIÓN	\N	2025-06-14 23:41:58.00763-05
a2496458-dc74-4db4-9919-197feb32425b	BACHILLER INDUSTRIAL EN  ELECTRICIDAD	\N	2025-06-14 23:41:58.04782-05
4aec1612-86de-425d-8f6c-d0b128f6cbc0	BACHILLER INDUSTRIAL EN  ELECTRÓNICA	\N	2025-06-14 23:41:58.08769-05
225e70e4-d813-484c-b138-dee8886ab18b	BACHILLER INDUSTRIAL EN  CONSTRUCCIÓN	\N	2025-06-14 23:41:58.126417-05
94208fb4-d881-4e88-8088-e46cfbddb1c8	BACHILLER  MARÍTIMO	\N	2025-06-14 23:41:58.164704-05
8b3a2887-c4a3-4809-b53e-6920a38094fd	BACHILLER EN  SERVICIO Y GESTIÓN INSTITUCIONAL	\N	2025-06-14 23:41:58.233774-05
ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	BACHILLER EN CIENCIAS	\N	2025-06-14 23:41:58.273635-05
eae08d36-af8d-4e33-aa85-b6f7fdd84cef	PRIMARIA	\N	2025-06-14 23:41:58.736865-05
75a11471-aca9-474d-b1b1-c7ada29d90f5	PRE-MEDIA	\N	2025-06-14 23:41:58.966786-05
65c7db26-e64f-408d-af19-407206b304b2	dddd	ddddd	2025-07-05 23:00:07.090819-05
\.


--
-- TOC entry 5207 (class 0 OID 17010)
-- Dependencies: 232
-- Data for Name: student_activity_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_activity_scores (id, student_id, activity_id, score, created_at) FROM stdin;
\.


--
-- TOC entry 5208 (class 0 OID 17015)
-- Dependencies: 233
-- Data for Name: student_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_assignments (id, student_id, grade_id, group_id, created_at) FROM stdin;
59677803-530c-417a-b305-2de0816ab405	12e6088f-b1d1-418e-a326-bf17e4777eca	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:43:59.958224-05
287cc0bb-4989-4f44-ae12-64f349a1a61e	d5952aa6-7b21-46d7-92d9-92c5da7654d0	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:44:00.118873-05
2415b891-e9f0-46ea-b389-adf9a1541c62	b130bc87-a0a1-4999-9860-5ccf2b134f6e	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:44:00.279804-05
fc072de4-e809-47ff-8078-243c429cc95a	255d4744-a3a7-449d-a897-e55993ced01b	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:44:00.442603-05
fa2ad782-9ea2-46e9-905d-10d2ffd6ae9b	040b1332-32c6-400c-a66f-3ac1806e057c	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:44:00.602499-05
3d74a56d-7aec-4503-8699-3117ce1e5d0b	a65e4b5e-96b2-4f6c-bbea-a8e4e2a95d55	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:44:00.758405-05
eed1992f-60e5-47be-8747-d8608c968046	8e390c08-e8a7-41d7-a1d6-a103d8cbd265	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:44:00.916505-05
4c36750a-29e0-457d-9012-bc3bf23236c4	fecd8a0f-c74d-462b-a604-eb1d22dad933	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:44:01.073651-05
3e712476-080e-4a29-8170-74eacbb54dc2	4429dd31-9292-49c6-94ca-989ea24f0f37	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:49:56.503562-05
ed84841d-0d82-42d4-aeef-94db53d770f8	f38cda1e-ff1d-4114-9114-329c50722c71	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-06 13:41:46.447704-05
\.


--
-- TOC entry 5209 (class 0 OID 17020)
-- Dependencies: 234
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, school_id, name, birth_date, grade, group_name, parent_id, created_at) FROM stdin;
\.


--
-- TOC entry 5210 (class 0 OID 17025)
-- Dependencies: 235
-- Data for Name: subject_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subject_assignments (id, specialty_id, area_id, subject_id, grade_level_id, group_id, created_at, status, "SchoolId") FROM stdin;
75355193-112c-4260-89c4-6223d79a16f9	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	9f38b236-1fdb-448b-9a48-f6c23db4c7c6	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 21:34:56.609973-05	Inactive	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d56c33e3-653d-4f03-a832-1e4abde98dfe	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f1b521e1-df02-4ec5-b28d-e103f81cacb9	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:39.782261-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b286c0fc-1099-4f45-a6ad-ff8cf734f803	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f1b521e1-df02-4ec5-b28d-e103f81cacb9	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:40.02825-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f743d2ca-50cc-43e1-b132-cb04749e9f3c	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	f1b521e1-df02-4ec5-b28d-e103f81cacb9	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:40.084903-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
33f9b421-3ab1-4ad0-b590-cac594bcd4d3	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5284e53e-8811-4b2f-b304-24d6492870b1	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:40.15741-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
69707666-f79a-4e50-b708-3e05e633f689	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	42770ffd-bf79-4cac-98e1-052dee724cbd	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:40.231318-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5589ce6c-815c-4872-8273-13661f0e3fbd	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:40.297132-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f8a81864-e13d-456d-b8b3-74f03856c6c1	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:40.345809-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3dad2fd9-b063-4256-81d0-93ad0b93f35f	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:40.396826-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
556a90d3-dd3d-43d3-aa15-b2bb8f56d9b5	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:40.457465-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4b8bf30d-bbbb-47b1-bb3c-c970ec73c4c1	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:40.511754-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
aee730d8-cfb1-4ee2-914e-5700eeb8f98d	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:40.563209-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
29a4d83a-97fa-4510-a750-f40f0c522863	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:40.612449-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
36bce862-189d-472d-9c94-020419a8cd1d	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:40.66654-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d2e7be80-7e72-4282-b2d3-07376e49c2e5	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:40.7136-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9dd751fc-3814-44f6-9612-afffad35943e	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:40.75932-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
964b19ce-9929-4534-b0a2-72318ea560b1	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:40.80937-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
333452c4-4938-4086-a344-ed09cc2bb1d8	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:40.859976-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b4c243de-8e2c-4341-aa3a-db5ab7a30331	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:40.911213-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ce543cc3-5acb-4e04-9879-0f27ee4fff21	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:40.960375-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a5b8a7f2-34d2-4c28-9fe6-6fe17ddf3743	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:41.010573-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5b8829c6-fa76-44c5-956d-12fc6691a5a3	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:41.059333-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
82e75e3d-aa8d-4f56-a648-679628c0e467	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.113158-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ce5ff143-05f2-420f-8fc3-9ddc302a5140	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:41.162091-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
cd533492-1a33-40b4-9937-d76bfceb983f	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.213248-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c68de0d1-5b45-4e8a-bc3e-c3ed361d51af	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:41.261516-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a600b325-a219-4286-904a-530bf10ecf89	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:41.313416-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4a4a5603-534d-48b7-862b-b3bcf0fe9092	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.361098-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
66f6c79f-bd12-4acd-8f11-4ec450bd6525	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:41.40888-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2cc878a7-6857-491e-93e3-9f6164824222	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	57d84811-b6cb-4d0c-a15f-cc383fd50ad9	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:41.459971-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
77947721-5f3e-4b6c-8265-6e6a141af01a	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	67f8d492-c674-4c93-8c52-0d798dbb6c8a	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:41.509368-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e89fd922-a996-4d65-987b-0cdf87d7d554	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e6f9ab75-8d52-40b2-b203-396309375106	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:41.56108-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
25c26915-0345-4309-add4-5f9a963b3d32	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e6f9ab75-8d52-40b2-b203-396309375106	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:41.608798-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f2167c75-bc93-4946-b135-c2fdcb66a8a2	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.662073-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
73f8f1b9-609a-45dd-9d0a-c2c48ce1a454	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.710765-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
93ddd157-e2af-4ff4-b21a-476403ddba62	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.765443-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b51debaf-ad6f-44e9-bdc5-0e99baaeb37e	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.816421-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
58443ad2-6170-4ef7-ba26-e40c1de24a86	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.87132-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d5cb2bae-b861-4c8e-ba03-2c04d6efca35	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.923208-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
986ae2af-a23d-463f-b8fc-6923762e9bfc	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:41.980813-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
1fa48644-0b35-45e4-8d87-4d9d8ca1becf	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:42.034892-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
938b9954-5ee8-4f3a-876c-f50f6cf55ac7	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:42.088202-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
82444487-a8f5-4225-ae07-cadb8f52f4c2	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:42.144067-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f024ed8a-826f-4278-8d46-35997f50e5f7	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:42.201509-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2f7142a3-981c-4b89-88e8-7742520c647e	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:42.254157-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5fbfdeda-e8d7-4a4a-a063-0d074e55a018	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:42.300836-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
538a114f-fc11-460a-a96e-15f445599dfe	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:42.347533-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
94f399cf-9ef2-4dbc-b6ef-e83b815e901c	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:42.396565-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b94aaacc-dda9-4024-b059-752c67a1c4bb	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:42.446007-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bc0fe627-caf0-4b44-94c0-a62f76f3c45e	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:42.492334-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
19b05811-a539-4334-acf5-e35c73f95abb	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:42.540991-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b8e6d5c0-0e8f-4c2b-b899-d4c323dfcf42	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:42.591036-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c615891c-7696-4223-adfa-c8bb758309ad	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:42.649219-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
29625ae6-caf0-4318-b13f-4e6256c4df27	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:42.705268-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e44cd4af-dadb-49a0-ab66-87d64300bca1	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:42.762789-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
feae5749-b225-4ff6-938d-7655e518c5dd	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:42.822645-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f6a058d5-c85f-4e19-b0be-dc8ca30205e2	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:42.875562-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4a9749a5-9921-4db3-bf5c-c13a9193647a	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:42.930072-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a948ca15-22bb-4f71-a89f-b8d483e2989a	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:42.981379-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ac0c5201-cd41-44f5-ab60-664bc1be052b	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:43.038051-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5184e26b-6e22-4f24-8a15-0a735a75b09f	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:43.092976-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
186cb3b8-c4b1-4fab-9eca-79ab689e1731	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:43.148787-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7a5f3afe-3dee-4778-be06-260b2446b3c9	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:43.208103-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
aab997b3-8363-47d1-81c6-dca140931b74	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:43.267021-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9bd00cbf-808d-4e9a-bb70-15fe6b4d89f5	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:43.32045-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8aea1bd9-5efd-45b8-bbb6-fafd59521623	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:43.376124-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0329bf58-1d55-4c63-85d0-d888ae498448	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:43.428089-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bd304d6a-0731-4eec-80be-b0fba1354ff8	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:43.483514-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ae34e790-de0e-411b-a3f0-20d0c9f6ada1	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:43.54191-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
65af736a-2a5e-46e8-8ba2-0418c6bad544	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:43.596847-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b704c4e6-a473-4d6d-b52a-098bc8c4a870	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:43.654925-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
68256ecb-30c0-438b-aa3d-b8e8a6a30bc3	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:43.71374-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a0759838-c75a-4f07-8098-9fb441630874	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:43.768934-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b035d6be-8a12-46b7-aa91-a3214c40eedd	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:43.827831-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
192fad51-e414-43fb-8ec2-f08e5c944257	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:43.885779-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ff3aa009-fc70-40ff-be28-f34e550f2b62	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:43.940449-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2f2bdcd9-eb86-4677-b8c2-d6457ca0dcb9	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:43.994782-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0a781f8a-6038-4d90-b3b5-e4576c808520	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:44.044613-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6c2014e0-b02e-43c6-b7c5-dc6067292098	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:44.092874-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f18ffd8f-c859-4d51-99a8-6abaeeb5a1cf	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d138c98d-3b6c-4895-ade4-ef681d169259	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:44.143603-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3535795b-7ef6-47da-9f5d-1f70cf92bcaa	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d138c98d-3b6c-4895-ade4-ef681d169259	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:44.197108-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e5954519-8adb-4740-8a1f-b628dc371109	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2f4c2bf7-f466-4a57-b869-6b2238c5fc39	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:44.247944-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
853fefd7-ba2f-454d-a26a-6fcdd1eaf705	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2f4c2bf7-f466-4a57-b869-6b2238c5fc39	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:44.297978-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d9b68d15-7883-47e0-a726-c1faa88d4d04	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c90ca72b-1bbd-4b76-a717-eab0d06c0e37	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:44.351481-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
35ebf74d-dc24-4044-8db4-733c60001a7b	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:44.410926-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a047bb23-789f-40f2-816b-2a0a15d0adfc	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:44.461058-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bd820548-9fc9-4d76-8236-ddf7ba69bf21	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:44.511015-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
72e58da0-7702-43d9-b1c7-377354ea979f	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:44.562871-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f9d468be-858d-49f6-a6aa-69eb5fc66d4e	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:44.614948-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d5a7cbce-c727-46aa-b931-9ec49b58f90c	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:44.669214-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4eaf20a0-65ce-483c-9268-a283d9e1dafa	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:44.719446-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
89036b69-1c4a-468c-beae-eca2813380d8	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:44.770017-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b0d11a7b-a8f3-4a96-8eb6-cf78959743f1	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:44.822964-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d4cb4565-2884-44c4-95ab-75da36425067	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	23200364-de2b-4792-bbfa-f54ef3267cbe	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:44.880853-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
85f1b6ac-a55d-4fef-b133-62461c516509	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	85472c7c-8d9c-479c-b24b-79f30ea4feee	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:44.932456-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bae7fb85-bbad-4f70-9123-66e40d28ca63	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	85472c7c-8d9c-479c-b24b-79f30ea4feee	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:44.98686-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bb84e713-b368-4d15-9c8e-d0f69899746a	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	85472c7c-8d9c-479c-b24b-79f30ea4feee	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:45.040592-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7b7348cf-331a-4273-8a4d-0c7d82422b80	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	20cca1c9-20d5-4c33-9a69-bc959f4ec2e5	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:45.088653-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
cd2c0255-b0f7-4f47-96c0-5fd7353559e6	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5b8120a1-af76-44d4-85bf-e6e40bf1e7be	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:45.138071-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6eb264c7-9291-4ff0-a749-00c34af38c67	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5b8120a1-af76-44d4-85bf-e6e40bf1e7be	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:45.184713-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a6f4bad9-2cca-4ed8-886f-88d66b017285	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:45.228415-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
54dc2097-f5fe-4497-a644-65aada0256d5	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:45.27242-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6c772a1c-212d-49d2-b6e5-640a00e2bc28	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:45.317097-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
eb94ec45-2c11-47da-8698-e47da627f5d4	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:45.360789-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c0c10d7a-dc11-4111-9a14-23d7bf6df740	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:45.404525-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f7bcb898-ca3b-4c6b-9d73-c31746f5d621	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	aa920dbb-9a34-488c-a450-319c3be369e6	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:45.454702-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4e799e3b-0ff9-44b5-89f1-13bf02c86b02	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c2e2f56f-09f3-47f1-99f3-041f017bf8ed	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:45.504422-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3149b580-b8a0-4fce-998d-92d3d35dd616	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c2e2f56f-09f3-47f1-99f3-041f017bf8ed	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:45.557955-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2544c229-5692-4e9e-8c90-a949d2d3539a	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3018ef5a-b1f2-415f-ba71-1de0f1218d1f	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:45.611058-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a8c2114a-5657-4ff3-865c-98fbb72493d9	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	75e38d3b-93c3-4a42-abd8-4d07df71f808	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:45.670112-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b2768cb9-aa0e-4eff-a5b2-ccd334fa40c1	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:45.725172-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
1699c104-ddf2-4064-b0a5-fc0562734910	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:45.781028-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c1495756-42ce-4cc1-afff-79d75a5721e3	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:45.836499-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e535b597-c3a5-4dad-9385-373165b7ca7f	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:45.892146-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c619547d-8c15-4493-b0d4-f076bf725c8a	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:45.942326-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
61f68447-fca6-4e19-ae3c-b0502ff6f28d	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:45.996597-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
13ae467d-6596-4eee-847d-f2cd042ff9da	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:46.049696-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9dbb65b4-e41a-4700-af50-3a38f25c17b1	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:46.106263-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9a61df98-796d-462c-98d5-e5721e6ada1c	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:46.154893-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
702c9e1e-21ec-43ee-a934-5cd5658c2c31	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:46.205236-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
acfd475f-04a8-4bb1-bb32-6feffc509977	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:46.254406-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
de013418-4904-41bd-ae3b-4a7299e8e7e1	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:46.304006-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0b945488-d33d-4b7c-a98f-8447573b8f3e	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:46.354945-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2e9ec4a9-c698-47c9-ba3f-d5076d770027	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:46.407753-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
80b761fd-3b4a-4d42-9d4e-c891e54b7ca5	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:46.461426-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6a75d616-b51f-45f6-b3e8-116c6b66921a	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:46.515569-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b079e849-f38e-40e8-acd6-1945904cf13f	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:46.574688-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f4a5c126-5948-48eb-84d1-c16f3e0fe5c0	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:46.62735-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c31e0d97-0b05-4a92-b112-0802e0700adf	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:46.682218-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a5d223f4-09ee-4e75-b887-e4b12d789c8a	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:46.735419-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
14f78270-cce6-4e15-bfef-6f0c8a355509	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:46.792952-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
21e3edc3-9419-47db-b071-5e5bccc0644c	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:46.840831-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7f54984a-9615-4a57-956e-25abd497da1a	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:46.893413-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d82f4785-fdf1-4ed5-8eaa-ab42401582ee	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:46.944259-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
714c2a97-2229-4001-ac0e-2a5e47b8f515	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:46.999548-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
894e3329-b54e-4192-8ffd-c5b532c4564a	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:47.05134-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
64b00427-3d16-44be-a8d3-dd819afc4e53	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:47.108459-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8625d76a-f952-49a7-a62e-3223de1753b8	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:47.164141-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e94b0b80-034b-47de-9358-9653de0607e2	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:47.215434-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7cef8feb-bfa4-467f-8b25-7968bbe21653	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:47.266581-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fcc5da62-d657-46ac-984d-a3de7d94254e	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:47.313803-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fd78f76a-9aca-4510-9b37-bd393b990f28	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:47.362498-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
db02917d-f40f-458f-a8e6-8fbf304d0360	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:47.410717-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c0b9c186-3af4-4a95-935b-8f454bb84cdb	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:47.457748-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
508f12cf-6c7b-42ed-9bb5-cb420a8d354b	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:47.508107-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
89b822a7-409b-4315-9a33-8d5c047f2a63	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:47.558307-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f9e1b1f8-9669-4fa9-8d84-e34e55112910	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:47.611887-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
312559ff-4e49-45cb-aaed-31cad2343078	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:47.664387-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bca578f2-9c87-43ef-bad3-c72d880eadf5	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:47.715984-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4ae58984-049d-4fa2-807b-d914fb251d0b	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:47.762994-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8ce165e1-588b-473a-9a4a-0e05df048338	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	a11fff06-3bcc-4665-b622-9cf8df2f0630	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:47.815896-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
498c644a-9d48-40cf-93b7-925ccb8979b7	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f6327a69-73bb-4f20-8c90-85126c1759ed	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:47.86787-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
30790960-db63-4dce-a6f6-0de73090358e	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f6327a69-73bb-4f20-8c90-85126c1759ed	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:47.92037-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ec2854cd-6472-4b8d-8460-a3a59be4c819	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:47.96999-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6f8847e4-6a9c-4ceb-99c6-4cd2014d7d64	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.021013-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3a82bd83-322b-4f6f-8db6-03c5a6050a8d	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.074642-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
423b3110-15e2-4594-96d7-cc3f99ac2cba	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.125471-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c6d29e70-76dd-437c-a0d3-8ae631c525be	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.177351-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
37ecf4c7-0b26-428c-a28f-0dc5404a4e83	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.251841-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2738e25b-8751-4e9b-9412-183812796f74	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.313597-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
25abe8f2-0e86-427d-ae0d-73784d017f86	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.368569-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
30939313-178c-4131-9658-c936ef7c2213	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.419067-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
27752d5d-7568-44c3-a3c5-90060c54ff96	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:48.469809-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ffdf002b-d1cc-42ed-a156-25ea9a32074d	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:48.519302-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
280d1d8d-26a2-4ddd-8f3a-6a542dee8986	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:48.568269-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a3e6507b-ca1c-4155-91cc-be4c779b45a8	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:48.609454-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
80587540-877b-461f-b491-dbc77b4ce764	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:48.650593-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f6704b06-a5bb-4777-b127-faa5eb3f8f6b	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:48.691971-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e93c44a2-69d0-4197-bf81-3a76b8a3039f	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:48.736076-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b73c2ec3-a02b-426a-acd1-296aa9b0f37d	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:48.780883-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2f234afb-cd15-4c52-9b8d-bc50e13a0f48	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:48.822291-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
66e4a2dd-5c05-407b-b2ea-baefecef8e39	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:48.86388-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
82379428-ee30-4e63-808a-563f86cb8b96	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:48.924221-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6cf4cbb9-3f1b-48e9-898b-512da58aaa65	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:48.969742-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0e1edddf-4242-471f-815a-757dfc9a6af8	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:49.016344-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b3f6466f-7207-4277-a85c-10d44763777e	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:49.059999-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
1ab8c012-ea5b-4422-b450-545bc3cc5b98	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:49.104662-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a548cdc7-ed88-4778-bbe6-fc0c00a17f9e	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:49.17359-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7aa44a5f-9a66-4dd6-b771-ccce785cdbed	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:49.224415-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8244d0f3-41da-4ddf-9aa9-4dd858a2ded0	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:49.268892-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
45a43519-c773-4191-9c8d-b29041f10be7	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:49.319376-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
15e1fd3b-dbce-4424-9cb7-9c4caad091f9	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:49.367952-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ec20aa79-c192-4b22-b9d2-1300a93bb4de	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:49.416973-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
803bf9ff-3c63-4b1f-b2c8-dc5be392c7ec	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:49.464688-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
df84802c-743b-4fa8-a2be-59ce180c1136	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:49.509422-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3387b173-78b1-4173-9b5d-58bcba3eb5b4	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:49.553643-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d551fedf-5b23-4e8a-9f32-65f0dcb3c655	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:49.599027-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fa56fbf0-78fd-4363-b5f8-6c9012fdda4c	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:49.647734-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a93e3ef0-ab98-4b4d-8f4b-c2ec14d40a81	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:49.692526-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f77a6d6e-549c-4ca4-93b7-be11223d7114	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:49.737985-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c25cd3b3-424a-4418-8778-0cd3a756fc35	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:49.783974-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8f21413f-75ef-4601-84da-9fb472c639e7	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:49.828512-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ed3f1d1b-c395-42d9-a00b-e94b68adaccb	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:49.877441-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
55390628-1de0-4d6f-8cda-d1973cc90510	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:49.921671-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5a56efe9-9227-45d0-983c-e00132873fd3	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:49.969008-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
137cd490-ff8b-458f-bf20-f3d132d81a00	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:50.015222-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8e4af3c3-d77d-4d47-acf3-f2278edc5393	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:50.062128-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6f5967ca-a2b5-4496-baab-2211bbd404a7	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:50.109441-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3233f3bc-1702-4df5-972c-e6fd963f8ea5	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:50.156029-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d61e3c8b-67bd-41af-ad29-040d180ee27f	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:50.201741-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9f293583-2d48-4b6d-9b2d-4624df1f74c2	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:50.250038-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a25346da-a0bd-453e-aca7-12085767bd6f	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:50.296489-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
21c16701-c43d-440d-bd1e-4c7eae0fe74e	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:50.340986-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5ea8b788-1488-4626-a559-a9c3e3c111cd	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:50.389378-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
552edb61-95b1-42e2-aefe-960aa1edb63e	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:50.4343-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7dad32c6-a922-480a-b80c-6468592320b2	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:50.480139-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
30792264-ca6d-40e5-9426-4bf20dca5591	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:50.531385-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
067f2e23-1f94-465b-a488-c22b4070172d	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:50.57662-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3f77e6c3-aff7-4189-82d3-822bb2da4cba	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:50.623297-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4eccd593-cb88-49eb-a5e7-a711bc3f3eb8	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:50.669078-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ad028445-1125-4a5e-ad90-1d4285fbcbd9	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:50.713609-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
cba66a1d-a0e8-47d5-824c-968aeca3ae07	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:50.764673-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
53cdd286-75e3-4fef-9899-0ebd7cb07ceb	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:50.810889-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f96a2255-2360-41bd-a61a-ebc3b5816717	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:50.857091-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
26d842ad-5803-4499-9fa5-fd4e4d31a38b	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:50.90236-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
de9d7c68-4c11-4b82-8d02-cd351faa729e	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:50.950172-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c5e15336-8b23-49f8-8199-71ff9682b871	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:50.995858-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d7fde291-b9ae-46a3-914a-07a9465ccdb6	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:51.036144-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0015b2d3-6490-4a1c-be2c-18fd4ecda5ba	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:51.078256-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ae324a11-ecaf-4946-b0b5-b1e5cb1dc5e5	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:51.119855-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8a2d3996-362e-44ca-967f-30e9f121e169	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:51.163488-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fd4f3a54-2551-424a-93f3-e27818deb538	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:51.207054-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
18137335-9368-4912-9cf7-aab8fee3d208	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:51.249411-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
783bd97f-2239-4c21-a918-69e34c0da547	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:51.294982-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
473a06cb-9c9d-44dc-9675-5c8e757752a1	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:51.336515-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2b144c18-5c3c-4f33-aeb6-1f75bbcbc1d2	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:51.378064-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
92dc6dbf-9cc4-4412-aa0e-06aa6b64dbb6	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:51.421171-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
cd533ea5-9c7e-4903-ab76-9dd774bafd3a	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:51.462207-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d4023028-6895-4a74-8438-8e4131d3fd7c	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:51.504492-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
21b2c73b-93b1-4272-89f7-08788dbba34e	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:51.54967-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
adc6d0c4-a15a-4e0f-a27d-7f9c5d783b00	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:51.595766-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
930490e2-f5e5-4094-bf3d-57181530273a	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:51.642276-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b4e2ad45-c1a1-407c-9dd5-a1353e78fd88	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:51.685879-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0bb61716-9291-431c-ac4a-633a04bc43ec	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:51.72653-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a331921f-77ea-41a6-9659-8fa6042bbe6e	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:51.768548-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
deee9fc3-af17-40ff-8a3b-8d306e26be2e	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:51.812696-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2ca89bc2-066d-43b2-b8c8-dcf85800777f	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:51.855064-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
66298770-6797-42a3-a5f6-a8a0140d8d61	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2d37981d-051e-44e2-86d8-6600982d9d36	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:51.895239-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a242b131-f562-48a8-8baf-ce35942d3a82	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afa75117-2804-4650-b310-2c31a8f37732	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:51.935841-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d8ec09b4-ccde-4e72-9f26-f5991dad0972	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afa75117-2804-4650-b310-2c31a8f37732	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:51.975806-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
1ab897dc-e348-4e05-8276-f9747f571c4f	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afa75117-2804-4650-b310-2c31a8f37732	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:52.018481-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
17f95dcc-efd6-4f14-a2d6-fecd9233e4da	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	a71addca-33d4-4b8c-8eab-f510e2b08557	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:52.06232-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d2e07034-d2ed-4e5b-91b3-46a55ecd7b32	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	45358765-1e9d-40d6-9f3f-4b13211ec7e0	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:52.10348-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a37a7d20-7a91-47c0-afc9-9ff66c93d204	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	45358765-1e9d-40d6-9f3f-4b13211ec7e0	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:52.14382-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9e045993-a8d7-441a-bd5b-19dcdd35a8ed	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	9b10d056-636b-4780-9aaf-3180bfffcf8f	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:52.189198-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
1fe3cb7a-3eb2-408a-92fe-80b9861c6dba	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6450833e-a92a-4cc8-9eb0-188a4e9e41a9	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:52.234077-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e465214b-5877-4d5d-a1c6-5373bdde0af0	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6450833e-a92a-4cc8-9eb0-188a4e9e41a9	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:52.281682-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c1920e12-76e6-4aa5-9f96-e5d733705c99	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6c87424b-b8a6-44ff-94cd-c198380ff0fb	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:52.326314-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d3cac67d-535f-4253-a968-c5257130d182	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6c87424b-b8a6-44ff-94cd-c198380ff0fb	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:52.368645-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4b0f5641-67ba-4f5a-9277-c08ed87072c3	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6c87424b-b8a6-44ff-94cd-c198380ff0fb	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:52.409048-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ae962f97-6f2d-48c4-8f51-62f105026313	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	0130d83b-82d4-4a42-95dc-997d2e364570	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:52.450685-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
74e26014-5a55-4056-b08c-665e2b7ac57d	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d13aa640-bc74-4187-a51f-fb8a0c779152	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:52.496963-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
05841fd2-3973-46d5-b44c-347cf6440d71	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	345001d7-26f8-48fa-93e5-9ee9522a14ab	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:52.53978-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
1b8f5893-bc7a-48b7-aecf-3b4d0207a170	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:52.5814-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6cd8a885-54fd-4668-bc0a-dedbc044675a	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:52.622622-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
402e6a22-abc5-4a1b-a0ac-241e8b1dfe9b	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:52.6647-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
84ea111c-de73-4da5-b604-a325799da8d2	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:52.710349-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
78666040-dcdf-433d-88ca-6776ad4967c9	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:52.753301-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
454b3ef2-003d-4b42-9a9c-247ca4741519	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:52.797724-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ffeed9aa-618b-4a19-8e41-613f0171e189	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:52.841532-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c119edfe-8bac-41b9-bdbb-98b3ed6be34c	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:52.883155-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ec08e985-83e7-4dc2-a3f6-441cef06ea51	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:52.928084-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
06ff43ba-2f84-4bb8-b057-92581395f321	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:52.970448-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
24e2de0e-1aed-4088-ba3f-e30e66e9d0fc	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:53.017841-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3f7d0af3-a93c-4aac-8654-27076ae18088	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:53.058696-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6bf2fb23-7016-4928-b7d0-a47c28328ea5	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.099977-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
613cf6bd-20a3-4a60-b229-75568caacf80	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:53.144698-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
410be8a6-4aeb-408b-9b5e-8139d9462e19	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:53.188154-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d4ef5f0b-b7b3-4a1f-b830-06f844c4b42c	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:53.229633-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d651c631-8277-46be-ae01-8b7fe2fa94a3	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:53.272228-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8aa32749-12e7-4179-9cec-5889ee28e6ad	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:53.314147-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6b1ff3b8-2c90-4e47-b360-e7de43b773c5	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:53.360188-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7c207c21-9ada-4502-9d1d-49526990c8a3	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:53.402167-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
584131a2-72e9-420c-b5a5-52529ea5d7e1	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:53.444827-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
87de0440-1422-43f8-97ab-6b0c5c52fece	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:53.487206-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
97d5c7a6-35b3-4500-b667-51c12203a6f9	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	4d4fc0ca-a74d-438a-bf93-eb06fe3df5c0	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:53.530828-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
aacfb3e1-d15b-4788-8cb6-0920e1879110	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d910b7bc-b855-4d56-8d0d-85731c3ca991	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:53.574103-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b1b455c9-7def-4154-bc28-cc1c9095fe77	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d910b7bc-b855-4d56-8d0d-85731c3ca991	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:53.617315-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2d3084de-f431-4091-b2c3-166344d8492c	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.663261-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c1756483-69d5-4066-a070-1bb4dcc45da2	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.706015-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
811aa862-64fd-484f-a51e-ec7dbe345692	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.747319-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b1f0c5a0-cc70-45d4-b668-b31abd373cfd	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.795321-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8019f895-469e-4eb9-a13a-f1b4c25ab31e	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.845209-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
864527ed-a256-4563-99b9-367aee4a1b53	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.889771-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
34ad1673-b2f8-48a4-a110-50736a2effaa	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.933221-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
876973aa-0ba3-43b8-abe7-07be18bfa380	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:53.976523-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8fdc85e7-f963-48e4-a713-21416b9effec	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:54.021679-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4637ab23-0982-4beb-8d6b-7200594ba07c	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	da56e8b4-8376-4664-8e64-5860d60507cb	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:54.064908-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f0737964-cd39-4b40-ab47-8a8a6eb6ee37	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c1e6d0ab-d7cf-4051-b388-b10c0b16f3c4	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:54.109308-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9db0ebbb-41e3-4168-81e9-912b42bd35b3	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c1e6d0ab-d7cf-4051-b388-b10c0b16f3c4	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:54.151289-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
54c91705-bd4c-4bc8-9f01-70dca368727a	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d9becc23-9506-41b6-bc0a-5e9e32b4030d	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:54.194035-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d5525982-f313-4151-8eb5-f4ce73ab6e79	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d9becc23-9506-41b6-bc0a-5e9e32b4030d	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:54.240731-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0632c879-9a7d-4049-8728-c819b956fcd4	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c076b644-4f74-4322-8e66-3f3305572bba	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:54.28521-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
18bf7999-1396-4193-affa-5cb1eadbc359	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e4ed7dd7-7823-430a-8641-12c19622aa93	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:54.327556-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
97f8ba33-a596-47ba-905a-58d923937166	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e4ed7dd7-7823-430a-8641-12c19622aa93	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:54.371699-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ccbc9200-77f7-4f64-9160-b7193e77b62a	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	95182a1b-c357-47d8-983e-930667540381	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:54.417438-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d26dd51c-459b-45c7-a461-49e3b89ffe4e	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afb6a689-260d-45f9-ba33-a8b013dc4081	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:54.462639-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0c7b8404-52d9-45fb-b33b-d520d655c0b7	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2aa9fd0b-d60d-49f3-93e7-ad5e90a1bb12	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:54.506339-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
13796d1f-eeba-49c8-923c-ffa12b173dd0	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c4955a5b-7cc7-4fa9-81ff-cc81c7534495	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:54.550846-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
619910a6-e6b1-4d6b-b4ef-154ec9882894	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c4955a5b-7cc7-4fa9-81ff-cc81c7534495	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:54.593418-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
af9b9c05-8893-4882-aa17-258975372c74	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	457cb5a5-fd01-4220-85ba-a6b67074a6a2	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:54.636095-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0993550b-d4f0-476f-90a8-9cfb707dc409	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:54.68144-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b4e555e4-fa09-4862-bd9a-eb73aa0b0213	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:54.725909-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
03c66801-1aa4-4b88-9a0a-4454d21812d7	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:54.76837-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b4d9c016-9909-44da-a1c8-9e12a6dd7c77	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:54.811557-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b32a4f39-f012-48ac-8e5d-1c3917b311d4	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:54.855073-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8fb5b9ff-c59c-4922-81d2-9f52c0ae369e	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:54.9006-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
117ff911-450f-4478-a98b-9e43af21866f	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ff2ae947-169b-4191-8240-6f63a2aa26f4	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:54.943615-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4051717f-9e25-4865-817e-6bd5ec457f31	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ff2ae947-169b-4191-8240-6f63a2aa26f4	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:54.98858-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
957856d8-ed26-4789-aac1-e32d76c27ba1	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8b57cd3a-01bd-4997-9e3c-b5927bd67e6f	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:55.032672-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4e3fbe75-c9e1-4922-bd57-065e22902667	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e919ef33-cb9c-4eb7-997f-c8271be8f2e7	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:55.074814-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
40863b4c-f351-43a8-875f-5017ee01ac97	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f695ea4f-307c-4a67-a94e-7aad9c1daea0	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:55.119617-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c7887f84-2893-46ab-b989-8010193b5da4	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c5d57eca-2406-49e5-943b-60a1c6777409	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:55.163128-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8f1bcae4-0114-4b6f-9010-1d0350b763d8	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c5d57eca-2406-49e5-943b-60a1c6777409	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:55.205479-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
722cbc5f-048e-4a0a-8a5b-0ea425221d82	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	cc84047b-214f-4726-9afb-b65e8578e8fc	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:55.25055-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
59e74ded-c0c3-4acd-aad3-af068db9b8f6	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	41810c3e-1088-4103-8c64-5464d4c087e8	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:55.293263-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b23a457a-da35-4e1e-9e75-89945d507943	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8c32b128-5a24-4318-9875-eeff9f63a232	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:55.339594-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f7950edd-2a01-4e06-9489-e32edd7fcb57	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8c32b128-5a24-4318-9875-eeff9f63a232	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:55.38236-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
846eff85-5dd8-4e76-af4f-14c97140536e	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5b17b887-f077-4815-aec9-76ade7fc48e3	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:55.425553-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ba1159a9-c869-48bd-b400-76744eba09e2	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5b17b887-f077-4815-aec9-76ade7fc48e3	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:55.471651-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
602fce5e-47b8-4cf4-a255-bad691c170c1	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	4e79c543-fe6e-4cb3-a9e9-f8de2ab5edce	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:55.515929-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
44450b7c-ac9c-457b-98f7-1b18501db88d	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	4e79c543-fe6e-4cb3-a9e9-f8de2ab5edce	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:55.561881-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0ecdb273-9441-47ad-9bd9-d559c117cba6	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	18cf4bd8-0c41-4853-b7f0-ab8045fa84d7	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:55.606338-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
eb2fad76-f9f1-42a1-9e53-0edda8979abb	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d9026535-e315-4e7d-b865-590ad2ef02c4	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:55.649977-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
12f4b3be-435c-4141-b472-74eea8353839	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e30e3c89-f75a-4c26-bb8c-726a2d22026c	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:55.693531-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d31201c0-9a8b-4502-b6c3-a7f6bc487036	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	1d0005f9-241e-4c79-b8fe-b1b22d5a69e4	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:55.737093-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9bb3565c-5e36-46cd-9876-38c0f0adab66	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3be08eb2-2963-40df-81a8-272bb1b87182	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:55.783758-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
10c20562-86f0-4ff5-b392-40699eb35d38	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3be08eb2-2963-40df-81a8-272bb1b87182	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:55.827409-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
968b7f7d-7f29-4484-8047-82fc86eb8530	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	696df0e1-dcf8-4a88-b02c-cb2259b876ec	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:55.869875-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6f5967e3-77db-4cd3-b0e7-6783d64be709	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	696df0e1-dcf8-4a88-b02c-cb2259b876ec	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:55.91307-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bd30138f-87c5-4cfe-9745-049b1fe253cd	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e14efa35-1987-4cc3-b70e-06250f27f0d1	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:55.957017-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
50d736dd-f5fc-4554-a834-2f5c4cd405fb	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e14efa35-1987-4cc3-b70e-06250f27f0d1	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:56.004416-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ddbacb91-3ad6-4d56-b0e4-98f07d583b94	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2f5958fd-620f-4556-b050-94371ce79dce	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:56.055919-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ee8fa5d2-b417-4361-baf1-1c54bb2f42b7	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ef183f7c-c3d1-45ee-a548-e505385aa062	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:56.102075-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b418339e-7b40-45e1-9d83-cc875caedc6a	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	7334bc00-bb6d-4c22-ad74-ca1a06230cac	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:56.146144-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8a399097-5492-4aa2-aa11-9a919a28bd12	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f3aa23d4-ad96-4e5b-bbea-a93cb8acd679	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:56.193779-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5150e81e-0f73-41d0-9f74-ab47b125f8e1	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8cd35820-0d17-429f-8510-fcf411f8e6a2	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:56.237688-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5d9f574c-8aa1-48a4-8974-56108d7ed493	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8cd35820-0d17-429f-8510-fcf411f8e6a2	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:56.28067-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
479d9ce7-f280-4a4e-a345-019587ede515	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	81faeb59-87bb-4204-9158-6d18b7f32895	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:56.32705-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f84b2d2c-4cdf-449f-860a-21bb500e5a37	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:56.370552-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ca0ed141-5cf2-4d58-b32d-541eca3925c5	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:56.4167-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bb137c79-e291-4d94-9872-0658a3a9fbb3	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:56.46107-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2a96b0d3-fbea-43c1-8751-d013062eb15b	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:56.50456-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
aa41bc81-7813-4fdb-adeb-f05112178c76	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:56.548249-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a1fa7380-92d8-458d-abff-80e85add9a16	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:56.59097-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
13ab7cef-91e7-4a6a-ab51-f5215d2ac77e	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:56.640555-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2b6bac49-24cc-4d3f-be38-5944192a7fa2	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:56.684756-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
88422c71-373b-4096-8679-385bbcfcb377	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:56.730066-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a096b9a2-f21a-4e3c-852e-705dcf1288d0	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:56.777511-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0cd64964-6c03-44e3-8f3e-bc6b965ae7ee	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:56.8209-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0cfb1e74-7e3f-4ca4-aa89-b32aebcbde2b	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:56.867259-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c3fb0d2d-0127-4a14-b974-6bead114a021	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:56.912183-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
24cc25ac-3f9e-41dc-b696-229d9162c05f	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:56.95604-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d73356f2-eb30-419b-9db7-05b9a8c86854	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:56.998884-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4ec0e53c-6cf0-4f31-8df2-1e32436f9573	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:57.0463-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3012339f-dd82-446f-ad08-349628abf23a	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:57.091797-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
77c7350f-d1fe-4b7e-b95a-47ec587fdfd1	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:57.137351-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
74da410b-6840-4a83-8943-24d7aa436122	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:57.184243-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
05a27fb3-0f36-4e67-8e8f-ffa867dc850a	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:57.22874-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a6719997-24fe-45d3-9b31-b540855f1867	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:57.275847-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
63c39e42-fded-4049-b8f4-fa9f95baea2d	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:57.325557-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
eb087267-0c22-4006-868b-a8421a11e19b	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:57.372447-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f2928c5b-3d4d-43c0-8b47-0421b33d8512	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.42077-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3067dcc9-7695-4f7b-bc7c-88c2b9a7a1ed	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.469387-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6d6f9d20-730c-421b-a58c-8b8c58cac938	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.520696-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
916184f5-3ad3-4ace-8f7b-f2e6feca3744	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.567435-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e267fb19-8c7b-4c36-add7-04ebb899ee6b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.612767-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b36f4cda-cc50-4f4c-b267-5c510660d0fc	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.66639-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
220cb228-e5d4-4627-8130-264413151708	75a11471-aca9-474d-b1b1-c7ada29d90f5	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.714471-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a41bb175-318f-44a6-b8f1-82d4043771cf	75a11471-aca9-474d-b1b1-c7ada29d90f5	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.765015-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0b2b0109-4774-486b-8ccc-2042d3ed2cbe	75a11471-aca9-474d-b1b1-c7ada29d90f5	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:57.812629-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7c7052c1-3090-4832-8148-6d91cae4fde0	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2774c5ba-437c-4461-9e93-3ad251707aa5	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:57.861493-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
05d5ee2f-a50c-4e1f-9416-1fc85a56f57a	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c8bebd64-d512-4ecb-b71e-d2fd6b2eb99a	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:57.908163-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
246c99dd-98ff-476c-ab31-b77e0cac4945	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	160ab978-9698-42c2-a4bc-a9c768926b6f	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:57.957455-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4346fbc4-13b7-4f4f-86b8-c6b75038a829	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	160ab978-9698-42c2-a4bc-a9c768926b6f	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:58.005559-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5e522332-d8e1-4f33-aaea-2b85dc3a2e26	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	7dfc5e9f-c1f5-4cf3-b9a7-05a3297569da	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:58.050898-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
195acb52-ad6d-47d2-9bfe-1948162a5f1d	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	7dfc5e9f-c1f5-4cf3-b9a7-05a3297569da	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:58.098416-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f6fcbb56-6c95-4f35-b630-5cbf7a2a5471	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	7dfc5e9f-c1f5-4cf3-b9a7-05a3297569da	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:58.144397-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8690d2f2-7e6d-4bff-8d6f-da6a7ea73ff5	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ab30f171-8aac-479a-b648-da81bfc1be6a	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:58.192474-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8fc11183-d1a9-4466-bb53-009e8d87cb8f	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ab30f171-8aac-479a-b648-da81bfc1be6a	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:58.245512-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c017b578-9676-4a23-bad4-dc1ee0371ffd	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:58.301967-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
dbb7651b-8a4e-4739-af45-19174fa413d0	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:58.340522-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
1644e61c-4c2a-47e8-82a1-783d756a1684	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:58.379484-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
16a5b929-ff55-4556-9702-7e19a89841eb	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:58.417337-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b829010b-ae7b-42a5-a5f3-081911103c01	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:58.455476-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2328cbfc-7ba9-4374-a882-30edd717635d	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:58.493669-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3477f0d1-451b-4c66-be12-a254d464346d	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.530381-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
844d49f1-bcf8-490c-a467-e6d35f1b5868	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.566965-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5d298e67-85e7-47b9-b2f2-0ce17d090660	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.60783-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
805c89d1-1fc9-49f0-886e-ab3334eabd92	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.646957-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
799200fd-53a1-4000-a16e-90ef02f4824c	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.68299-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e487a440-06fc-4001-81c7-eaaecdc6c94f	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.718909-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4faf6bc1-eb1a-4e1f-b4c7-a2df433ac2a4	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.754287-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
44d47405-214d-4b19-beb4-0fea364ba521	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.791786-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8cbf688a-cfbb-4481-af55-68fa74463239	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.834004-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e49f85e8-61b6-46b0-ba53-4cb964646ebc	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.87357-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7f70c811-7a92-4f76-a365-01315a6e77b9	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:58.909499-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
697a98e7-832f-428a-bbf3-d96bdafca60c	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:58.944125-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
72150362-e40c-46e8-a4a7-d7c13b5c4525	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:58.980178-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
75713985-1035-4524-b7b1-523e42d8060f	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:59.017595-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f27eca87-d767-411b-a0ac-f66fe0640feb	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:59.058668-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e21bfbe2-a4c8-42c3-9695-f723cc7a59d4	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:59.095299-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
95dace94-2326-45a0-8af3-c98c00e32d28	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:59.13321-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a789f4bc-6900-42e8-843f-c901c2e848b1	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:59.172913-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
77e0ddb0-2c13-427f-93ba-f92f3d33517a	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:59.210306-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ca4e66dd-fa58-4efb-98cb-8c4fba6b3c95	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:59.247484-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
dabdb043-5aca-433d-896c-d3ad029b774e	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:06:59.285382-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f1153e1f-d1d1-4d2f-aba9-ac983f398c7c	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:06:59.322065-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
04b7d55c-d437-417e-9135-a560e85ef4a9	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:06:59.359806-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
16f0ce22-8251-4e8b-9575-8dc2aab3e1a7	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:06:59.397822-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e8cd7e4e-570a-40a2-a6e7-f4bb8d26d3fc	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:06:59.437991-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7d01a785-e2c0-4178-b670-912a0a6ce207	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:06:59.475915-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
bf6c9b56-6347-415e-9937-c67cb87ee1d5	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:06:59.515215-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e473b790-af58-4b06-8484-27ad0bf28fd0	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:06:59.550827-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0d6db1fc-3d1f-40d6-a261-7ccc409b84b4	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:06:59.586097-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
406d341f-6ba8-4362-8109-98cc632cb6e0	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:06:59.621604-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a0e731cd-1703-4562-aa06-244b11ff7362	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d85332cd-f71c-4980-aa40-e6d27d6ce2b1	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:06:59.656738-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e32897d8-991a-4f34-9f53-b0ea54ca3d74	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d85332cd-f71c-4980-aa40-e6d27d6ce2b1	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:59.693036-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
aaba6fac-b40e-4e14-bb1a-19d19bf46a1d	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d85332cd-f71c-4980-aa40-e6d27d6ce2b1	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:06:59.728757-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
78d8cafc-adf9-44cf-b473-ca6894d0857f	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2419537c-563b-44a8-81c4-5f3d6287f310	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:59.762152-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6e6ddc4b-3bf2-422e-a1d9-4e3b21f05af5	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2419537c-563b-44a8-81c4-5f3d6287f310	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:59.797324-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5ef28cf7-50f2-4f4e-9f4c-a6d7323a2c8d	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2419537c-563b-44a8-81c4-5f3d6287f310	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:06:59.831386-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
435c0791-5fbc-4dcf-889b-00d64a3d01b0	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	b4e96247-797e-4d07-9d13-cbc686da0399	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:59.864695-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4d795b00-4180-4dd5-a008-5287ede7b287	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	b4e96247-797e-4d07-9d13-cbc686da0399	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:59.898318-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a12a6eb2-2b68-42ee-93b5-f99edf627aaa	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	b4e96247-797e-4d07-9d13-cbc686da0399	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:06:59.935379-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
99155a60-5630-4859-9e6f-818a24f58bcb	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afbb13d8-b0c9-4f17-8f24-4ea2e01fd617	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:06:59.973911-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f681c6d9-0d9d-4a90-93ba-75cc4b33b197	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afbb13d8-b0c9-4f17-8f24-4ea2e01fd617	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:00.011512-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
63c2c793-0b78-47b0-bd12-3e8c28536f46	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afbb13d8-b0c9-4f17-8f24-4ea2e01fd617	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:00.048314-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ccaf72da-bb06-4395-a7ab-9fec335a9bfd	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	94a2f151-893c-426c-b8af-7d6b39e8245d	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:00.085059-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
668564d7-0b1d-43c6-908d-ec4f1242614a	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	94a2f151-893c-426c-b8af-7d6b39e8245d	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:00.121536-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e7b64a68-5c7d-4be5-b0c7-e275869432fd	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	94a2f151-893c-426c-b8af-7d6b39e8245d	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:00.15774-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
1d3df19e-4a00-4daf-af12-dcc07d0e17e3	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:00.192184-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7402936a-7e35-4263-a83c-b1a9909201f6	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:00.226197-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
337fdfc5-6d00-482c-963f-57e798242d92	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:00.261111-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2d66ff15-0908-46ab-9838-60161dd443d4	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:00.294318-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
62c26ddb-dbd4-40e6-8ad0-5749f3402942	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:00.327356-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0b4c3bbf-2594-4615-bf72-f53ec31370f4	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:00.363862-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5b272c73-470d-40b0-881a-cfc674535118	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:00.398043-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b81182cc-3e09-42c5-b097-0a980b844938	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:00.432749-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
654d1986-4611-4bd5-8a80-527d273b3534	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:00.470617-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fab8854b-0a3a-425f-9bae-a2f237d7f8f5	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:00.512576-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0967e549-78fe-4b06-b030-56ab15768026	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:00.557008-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
06b0108f-8f06-4dea-9510-3528f80ac240	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:00.595172-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4d4c3a3a-c588-470b-9952-f70d35e72035	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:00.63196-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5a4d8e9a-0dff-4ba6-ac2d-1d7fb6952e26	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:00.668023-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
edb18857-baaf-41ec-90be-58db980addf6	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:00.702917-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
595cb490-680c-4166-b58b-841a2b2e7cfc	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2f43da8f-d9f7-4133-94d1-84f8b2b8401f	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:00.736652-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
937621b9-f2e3-4274-82c2-a314c183cdb4	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2f43da8f-d9f7-4133-94d1-84f8b2b8401f	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:00.771105-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a96b05ba-4ca7-4a7d-8833-e57ab855a23f	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2f43da8f-d9f7-4133-94d1-84f8b2b8401f	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:00.80713-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c0d9eeb9-163a-4f2b-8cc3-52d979d04b08	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	99296f68-1117-491f-a8e2-337fce77f135	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:00.842427-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
aa6af4b9-dfe7-473e-90c3-d4554c55a3d8	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	99296f68-1117-491f-a8e2-337fce77f135	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:00.87639-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
602d8f71-a6b5-4c22-94f0-a1d0b4fc7f35	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1726da2-d766-46a1-8356-2a23b9912854	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:00.911672-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4b08b47c-86be-435e-8a5e-72705bde933e	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1726da2-d766-46a1-8356-2a23b9912854	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:00.945029-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
faf57a9d-92dc-4c75-a1a7-0e90b95f1cb6	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	7f56eb86-b298-4a97-a496-d31ff9d3269c	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:00.979304-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b7901b5e-a6cd-4380-8ed1-7a8e08e2f755	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	69f75876-5a83-4578-866a-a356457556aa	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:01.017692-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a7cb75a0-d58e-4bdb-93b5-bfec69333450	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:01.053131-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5a957158-9822-4298-a93d-9f78d4d1dfce	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:01.089449-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6dac8c0c-2cfe-4df4-a621-e36fa2841b81	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:01.127435-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9829823b-d1c2-4756-936a-d2d0507e0baa	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:01.161887-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
858a80cf-2b64-44f9-be60-2fb93c130932	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:01.196378-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
88ca79c5-fb2d-46c9-a934-8ebc43d089b4	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:01.239824-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
81941de0-c2b4-49ed-923b-d5d1965f299e	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:01.296382-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
cf80cfaf-5c5b-40b4-99ba-22a74655a300	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:01.338164-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
47228da9-5920-427c-9537-1f9b306050e5	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:01.373693-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
06ecd934-1505-47f1-9513-385655e65772	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:01.407721-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
54c28a0f-ef4f-42b7-85a0-b629e82b5cb9	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:01.444387-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
79a4fff8-156d-4e0a-b4a0-80d188762eed	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:01.480073-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3d9e70b4-3d6a-4dd2-b947-5774d9c0a1cf	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2be8c622-bd40-4399-800d-db79f576a8f3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:01.515569-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2ba9e3ab-a1aa-47c4-a327-d4be2e09ce59	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bf84cc88-30aa-420d-aa9c-8bd1366fe5a3	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:01.550123-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fcaf5aed-fe5a-466c-94bd-c6a9d48f0cb7	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bf84cc88-30aa-420d-aa9c-8bd1366fe5a3	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:01.584043-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9d04610b-3916-43a2-b4c5-6f6f2ebbcedb	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	c95eba06-5073-4749-bc20-25515f703da4	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:01.621948-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c46a8f4e-36d2-46ca-8ee6-660c28a7b21d	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	c95eba06-5073-4749-bc20-25515f703da4	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:01.659498-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c23df24c-0875-43bf-bbe7-181b5111d2f5	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	c95eba06-5073-4749-bc20-25515f703da4	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:01.695812-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d21b7e4f-624e-405a-9dee-54b958db7523	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	57d5aeba-fd9c-4e26-bc93-ca11f112ac50	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:01.72966-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
85e32a76-e94a-4454-86bd-c6673bac6eb8	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:01.764564-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3500dd9c-ebc8-46a4-9792-7239227a5e63	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:01.800977-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9963e06f-33b2-4dad-84f6-d2b059b9905a	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:01.835625-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c6c47713-bbc6-4114-a706-d3ebe3c2cde3	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:01.871363-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ef6eb5c0-434a-4592-a1b7-688072fa5c84	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:01.907606-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4e16cc9d-1fed-47d8-8f0f-ee658cbfdb90	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:01.94196-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
dc5cb548-f651-4750-b63f-53f703f6d109	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:01.976419-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8dae0345-d3cb-4516-86a1-656a9a3fbf31	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:02.010581-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a66d2e2b-baa6-487e-b34d-78de4c4e78ad	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:02.061899-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
200883c5-8a90-4de9-a0e8-84427bb3c607	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:02.098916-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c6f27b24-5050-478a-a629-7b4a2ddfaaf2	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:02.133525-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
687ec9a1-d3d3-4254-a989-253c24cd7bb7	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:02.167269-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7367d224-0adc-4b5c-8357-37b92caf1235	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:02.20455-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f8ba5111-2392-47cd-b14d-f9cbd5f38ce2	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:02.239215-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c78ca2b6-9a59-414a-96bd-1c1bd063d47f	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:02.273573-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
589d9378-b877-4ab2-bb8a-ba346e8627f1	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:02.309321-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5ce47f0e-e94d-4b50-8fab-ba4267d081b7	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:02.344509-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3010f417-fd19-45f7-9b28-c2ed39ef7622	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:02.378272-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8bc57082-a081-4f99-b233-d9b23698e392	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:02.413126-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
83f39481-2c50-4a06-bc48-a1f482e8bf54	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:02.448315-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7dbb062e-81c4-4c87-b1e5-eea83ea7f190	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:02.483414-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5dc3b330-ec8d-400c-81fc-8ab62626b9a1	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8d2e9a35-e707-49e5-8ff9-8582e571311d	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:02.521251-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2c58d278-fdbd-41e5-ae87-a69ca9c3a876	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:02.56055-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3bddfc7b-095d-4e09-937d-fb2742d1c5f7	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:02.596051-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
41cf2721-0bf1-4896-8820-98851c1494ef	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:02.630709-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4a475181-11b6-44ae-916c-8f137a06763d	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8b109e75-4cec-4c39-8814-d0c613c566b7	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:02.798405-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
af7786ec-00fd-4e1e-8e2d-fe5e4902ce93	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8b109e75-4cec-4c39-8814-d0c613c566b7	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:02.834821-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7c251f5a-1ec8-4303-8de5-c18f59c637f6	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:03.459348-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
952671d4-9f36-4aed-91a6-7a6aad1686d2	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:03.508377-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
03740514-4054-49be-afdf-a01c77fad433	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:03.542954-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8904b588-12f6-4d3e-8e15-34ec41b17864	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:03.578036-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ec714681-d1c7-4ac2-b328-19fe1c52cbba	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:03.611663-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
50f87ccf-6445-47d1-afda-42f5c43ac013	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:03.649274-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
304932fd-bcb6-4bd0-80a1-33db130dcce9	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:03.683443-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
04081d2e-c96a-431f-95ff-fdbed3889bad	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:03.718912-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3c302d00-2acd-4e90-bd12-db38ce1c529d	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:03.752549-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e4af2fd1-e8fd-4a32-8ee5-ecd2d8a616b3	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:03.786356-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8c3617f6-c5ad-447f-bf16-2a6a40105446	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:03.823097-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8c3d012d-4298-4828-bfb3-1033f26f022e	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:03.863289-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ba25a3c5-4192-4b23-a74e-a0a8238e9132	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:03.900407-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
17c86917-d50c-42f2-8911-ce1c89948a66	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:03.934717-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8d2f6f66-b46b-4da8-b6f6-7d737e0dcd66	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:03.968458-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
0efd4069-0a5a-4fe0-a59e-4c0bca4fe477	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:04.003541-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8d0413cf-3e1e-4956-964e-42a19641e9df	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:04.038683-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ab50cc0e-6769-4ed0-a3b0-632124b26692	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:04.075488-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e26256e1-f6c7-497d-a059-0fa11ccb0bdb	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:04.111323-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
61bc8114-6dd9-4265-a2ff-d8b379e4df1d	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:04.14625-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fdd4c5a4-77a3-47c4-ae09-138cf9007ac3	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:04.183119-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
acc55e58-988f-4a2d-8203-334db6c54744	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:04.217662-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7c9223d2-083e-444c-84a9-dced5109797b	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:04.252541-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6524e4b9-ecbd-4696-9a84-f621d4c4b836	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:04.288027-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
52802a4a-a4f1-4ce5-92aa-ab8e75cbfc53	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:04.323239-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ddabecb2-c8e1-4fed-810b-800fd0a560b6	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:04.358057-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
88d498b1-85b1-468b-bb4c-218110c88438	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:04.392873-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
69ca5c9c-45fc-4838-985a-e12b3d91e536	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:04.428478-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e205c0bf-03af-4128-9270-560a0f969109	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:04.464264-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
88717db7-4b5d-4f6c-ac08-1f2496c77443	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:04.499307-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6d37f010-b289-4812-a1ba-e05af13cfc62	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:04.536609-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a97f0859-8356-44c3-b8e9-1961ce708fcd	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:04.571889-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d5d8cb83-5bac-4208-a0b7-fc74109576ab	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:04.607261-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
864253df-4a05-4415-b307-588b9630b760	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:04.64515-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
842de725-91e7-469d-afeb-50449695f840	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:04.68036-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
945e6ca8-1ef9-48d5-85db-678d87f54ebb	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:04.71544-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3687bb5d-0bbb-4016-8b5d-f1c6ad8d969d	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:04.751616-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
83ef4381-119b-460f-a81b-6905e15fa4aa	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:04.786758-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
24c2dfb7-f1e9-4e21-82f4-3851e5970c30	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:04.822516-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d5bc9844-2c52-48c2-aead-80f07ead2147	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:04.857905-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9ba5d314-6892-469f-8f82-052bd25b14d1	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:04.892567-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
04174d75-1a2b-4287-a305-8b174a57108c	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:04.930164-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c4dfe536-1b15-479c-a76a-837591fb979c	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:04.971314-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
749645db-fb2f-43b3-85f8-6911486b8351	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:05.010983-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
85ae1356-b5a6-4047-8d07-d0144eed1ce9	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:05.045608-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6809e6be-babb-4ef1-b18e-81a0da7dc036	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:05.079996-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ba0fb9a8-2b70-479e-870b-15737afda474	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:05.117803-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
810978c9-7e93-453a-840f-68c123f98ebd	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:05.155697-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c338d67a-52b6-4e4c-87eb-68fe2860da05	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	56cd2914-b523-4883-a407-6f0f4b95d119	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:05.190088-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e59c2077-af4d-4d9a-814d-beb95c01d6cd	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	56cd2914-b523-4883-a407-6f0f4b95d119	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:05.225019-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
73c29869-0024-499c-ab39-173998ac09e0	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	663fcd4a-1b6f-40da-a1eb-8de8722b4f8f	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:05.259446-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
34598745-dbfd-40a5-b57b-09b8a803112d	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	663fcd4a-1b6f-40da-a1eb-8de8722b4f8f	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:05.292033-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fd5ee91f-aef3-4372-9746-38c9067be6fd	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2b38bf28-5925-434b-a48d-99808624d119	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:05.32814-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
7a872b26-547c-409e-b99a-008b20937e37	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:05.363591-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
15aed7a6-3f5d-4039-ade2-5c121d43565a	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:05.400077-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d1db2072-3394-462a-b52c-fcc90a5de6e3	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:05.434766-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c39bb93e-e194-44ef-845c-8515fcc3e783	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:05.469434-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e433c33b-4305-4ab7-8f09-c85d4028637d	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:05.505283-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
88780483-0621-47fb-8ae2-10e89801a196	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:05.541949-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c86e0908-a2cd-4a8a-86d0-30a4dd32e55b	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:05.580065-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
62c72d17-2ff8-4d99-9aa2-67e1565668d8	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:05.618178-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9061f42f-d459-48ae-a725-ef17b272aa47	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	862fafad-bfb7-45de-880a-4ab022993152	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:05.653451-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b16c1d76-3a7c-4eae-b28b-0d104b3dcde1	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	862fafad-bfb7-45de-880a-4ab022993152	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:05.68891-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ae449803-6ccd-40e2-b65a-1b05790fe129	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	862fafad-bfb7-45de-880a-4ab022993152	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:05.72398-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
222a6570-333a-415a-9ec8-abcbf354af38	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:05.758692-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d9ea1f74-1adc-4e70-8497-caea5de78224	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:05.793999-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
950c5d85-8828-4f04-a3ca-6886e3349a0b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:05.832583-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
cc185d07-b953-4b98-96c6-4e61259233d1	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:05.867423-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
55b30722-9583-450b-86cb-a58ccacdc11e	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:05.905564-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6a2e55ec-9a58-42fe-a45b-1a3442b6c821	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:05.94425-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
488fd112-1559-4a11-9907-93d411c119aa	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:05.982588-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
65b6b862-4003-4a86-9eb9-27c7258d668e	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:06.02034-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c03f794f-fba3-4a72-9ed1-629042aa28f8	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:06.060588-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
5925ba4c-857a-4412-8ecf-d518f6c1255e	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:06.100235-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
8a9c806c-64b4-4261-a8eb-68bded9d88fd	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:06.140457-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f8005ee3-d899-4523-bc85-8b3c4db483b8	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:06.181363-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
469e419b-0bec-4fb9-855e-7a47d880872f	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:06.218349-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
44669a05-d6f8-43e5-a9a8-84bcead61ed5	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:06.258415-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
cb5e29fc-6022-4057-8cec-270d0681e859	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:06.300887-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
cb12b5de-341b-46f1-97c0-2e355f6af21c	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:06.338308-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
9d55eda2-f7ef-48e5-b32f-e11e078b1001	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:06.374854-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
54e8286f-2f87-431c-9d23-a51eaeb84664	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:06.411216-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e7f30c86-2baf-4fd7-a682-1b0524584ec8	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:06.446541-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d934b4eb-26ec-4581-81d4-5b7201673ae7	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:06.486229-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
847fa5cc-556a-4b4e-90ac-976abd756346	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:06.52298-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fabbe7c4-7dc6-4436-b431-c38cc3a61b17	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:06.559546-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
199aec87-4464-496a-927b-3aa6ad329094	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:06.595877-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d2e86314-ac3e-433a-923a-8aa26d6f75e0	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:06.632097-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
a766fb79-9b97-443c-b00f-f65b4b76695c	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:06.667505-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f911c8be-8359-4b6c-a5ca-7577b877a8b3	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:06.706046-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
948cb3ef-e843-4dd8-b75e-a338c41dff3b	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:06.744017-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4314d798-34ac-4705-999c-0d5423524124	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:06.779241-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
08c053d3-f1b3-4dcd-aea0-50c564245b88	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:06.813981-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
3a03ca0c-47e1-48bd-83f4-721cab21c2b5	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-05 22:07:06.849212-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ef08cb57-07e7-4afc-9ed9-f5c95a0ace29	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-05 22:07:06.884532-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
ca855271-862a-4275-a672-5e0ed57db901	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-05 22:07:06.923324-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
aeeb2f16-3818-4ba9-82e3-670e1994c652	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:06.96137-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f02f641c-cc9d-4f93-ace0-87a037322ba2	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:07.000141-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
f8522076-c0e8-4ef0-9d97-cd415380b769	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:07.035308-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
16ee8e4c-4651-491f-b076-0fd2d75c983d	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:07.070987-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2e783b8c-f178-4012-b804-ac700bfbc56e	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:07.107285-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
4dd82429-e1c4-4984-8064-9179819e47bf	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-05 22:07:21.535004-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2db30c50-eea9-4639-b4b2-9fc0f49da92b	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-05 22:07:21.573995-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
54efd639-52e8-44ef-be59-b7800dd12081	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-05 22:07:21.610877-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c82855bb-83a5-4473-a1da-ee3da987ddd1	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-05 22:07:21.650504-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b8ad815c-ee4b-4b36-9cf2-2c0636197785	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-05 22:07:21.688369-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
87149f08-62a0-40b6-9a10-f180098c49b8	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-05 22:07:21.727501-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6bd7fd08-d0ed-49aa-9617-ebad9420db53	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-05 22:07:21.764993-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
e005d737-f7f4-4879-997e-9e444b8578bb	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	26b00153-ec1d-4b83-80b6-74d24c580cd9	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:21.802131-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
2778bff5-e82c-43d4-8cdf-01aaa070da27	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	26b00153-ec1d-4b83-80b6-74d24c580cd9	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:21.841663-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
6b708b5f-fe3a-4d8e-970a-1cfcd81a636f	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:21.877527-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
78a49e43-a973-4a23-b3e3-5145dba85c4f	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-05 22:07:21.916309-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
eca00ffd-af6e-4bed-9cbe-ffbccf5bdc51	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-05 22:07:21.955102-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
c3e68077-9807-49e8-8194-1f5910f94d78	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-05 22:07:21.995456-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
86eb6739-0a1f-4459-90b1-58905b9d6fa6	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-05 22:07:22.034895-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
d7f34f2c-3175-4326-86f0-6693768a4c52	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:22.128564-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
b97e1826-c465-4747-a5bf-d11bbd042803	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:22.198426-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
15b7377e-2016-488f-a270-caf9523e0c5e	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-05 22:07:22.266313-05	\N	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
fa9b2734-c35a-440c-8e4f-a834c2e43f2b	65c7db26-e64f-408d-af19-407206b304b2	7873164c-f5ce-4eff-bc6f-db7b188d33c0	9f38b236-1fdb-448b-9a48-f6c23db4c7c6	802bf302-fc4b-4d46-a3e0-ac202c8ba414	4b02049a-6d6d-4872-8683-ddbf59278d06	2025-07-05 23:03:33.488809-05	Active	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e
\.


--
-- TOC entry 5211 (class 0 OID 17030)
-- Dependencies: 236
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, school_id, name, code, description, status, created_at, "AreaId") FROM stdin;
9f38b236-1fdb-448b-9a48-f6c23db4c7c6	\N	dddddd	\N	2222	t	2025-06-14 14:47:37.184181-05	\N
f1b521e1-df02-4ec5-b28d-e103f81cacb9	\N	ADMINISTRACIÓN	\N	\N	t	2025-06-14 18:41:57.34654-05	\N
5284e53e-8811-4b2f-b304-24d6492870b1	\N	APLICACIONES CON BASE DE DATOS	\N	\N	t	2025-06-14 18:41:57.665096-05	\N
42770ffd-bf79-4cac-98e1-052dee724cbd	\N	ARQUITECTURA DE COMPUTADORAS	\N	\N	t	2025-06-14 18:41:57.707635-05	\N
d401c0d5-ffab-420d-998d-9a2481987504	\N	BELLAS ARTES	\N	\N	t	2025-06-14 18:41:57.756291-05	\N
1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	\N	BIOLOGÍA	\N	\N	t	2025-06-14 18:41:58.387959-05	\N
57d84811-b6cb-4d0c-a15f-cc383fd50ad9	\N	BISINESS ACOUNTING II	\N	\N	t	2025-06-14 18:41:58.606389-05	\N
67f8d492-c674-4c93-8c52-0d798dbb6c8a	\N	BUSINESS ACOUNTING III	\N	\N	t	2025-06-14 18:41:58.641193-05	\N
e6f9ab75-8d52-40b2-b203-396309375106	\N	BUSINESS MANAGEMENT AND HUMAN RESOURCES	\N	\N	t	2025-06-14 18:41:58.676097-05	\N
aed4e961-0736-4ae2-a814-4f1191055dc4	\N	CIENCIAS NATURALES	\N	\N	t	2025-06-14 18:41:58.749194-05	\N
49534204-c5e6-4fca-b0d4-5713f849c8b0	\N	CIENCIAS NATURALES INTEGRADAS	\N	\N	t	2025-06-14 18:41:59.084475-05	\N
76fca87e-f52c-4560-9012-82d5a529290b	\N	CIENCIAS SOCIALES	\N	\N	t	2025-06-14 18:41:59.439592-05	\N
9534c386-747b-46c6-8b12-044a4270e51f	\N	CÍVICA	\N	\N	t	2025-06-14 18:41:59.63432-05	\N
d138c98d-3b6c-4895-ade4-ef681d169259	\N	COMPUTER BUSINESS APLICATION	\N	\N	t	2025-06-14 18:42:00.284983-05	\N
2f4c2bf7-f466-4a57-b869-6b2238c5fc39	\N	COMUNICACIÓN NAUTICA	\N	\N	t	2025-06-14 18:42:00.362079-05	\N
c90ca72b-1bbd-4b76-a717-eab0d06c0e37	\N	CONFIGURACIÓN Y ADMINISTRACIÓN DE SISTEMAS OPERATIVOS	\N	\N	t	2025-06-14 18:42:00.441196-05	\N
3b701f10-0870-4e7e-a74d-ce0f9bf08e35	\N	CONTABILIDAD	\N	\N	t	2025-06-14 18:42:00.485359-05	\N
23200364-de2b-4792-bbfa-f54ef3267cbe	\N	CONTABILIDAD I	\N	\N	t	2025-06-14 18:42:00.841448-05	\N
85472c7c-8d9c-479c-b24b-79f30ea4feee	\N	DESARROLLO HUMANO Y LA VIDA INDEPENDIENTE	\N	\N	t	2025-06-14 18:42:00.884262-05	\N
20cca1c9-20d5-4c33-9a69-bc959f4ec2e5	\N	DESARROLLO LÓGICO Y ALGORITMO	\N	\N	t	2025-06-14 18:42:01.000509-05	\N
5b8120a1-af76-44d4-85bf-e6e40bf1e7be	\N	DIBUJO I	\N	\N	t	2025-06-14 18:42:01.043092-05	\N
66f2da44-2f53-4e2b-8c1e-e267aeca040e	\N	DIBUJO I (LINEAL)	\N	\N	t	2025-06-14 18:42:01.120069-05	\N
aa920dbb-9a34-488c-a450-319c3be369e6	\N	DIBUJO II ( MECÁNICO Y COMPUTARIZADO)	\N	\N	t	2025-06-14 18:42:01.307417-05	\N
c2e2f56f-09f3-47f1-99f3-041f017bf8ed	\N	DIBUJO II (APLICADO Y ASISTIDO POR COMPUTADORA)	\N	\N	t	2025-06-14 18:42:01.352567-05	\N
3018ef5a-b1f2-415f-ba71-1de0f1218d1f	\N	DIBUJO II (CONSTRUCCIÓN)	\N	\N	t	2025-06-14 18:42:01.430614-05	\N
75e38d3b-93c3-4a42-abd8-4d07df71f808	\N	DIBUJO III (ASISTIDO POR COMPUTADORA)	\N	\N	t	2025-06-14 18:42:01.473221-05	\N
84d19712-cb74-4115-ae56-9b62f129cf12	\N	EDUCACIÓN FÍSICA	\N	\N	t	2025-06-14 18:42:01.5144-05	\N
e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	\N	EDUCACIÓN FÍSICA Y SALUD INTEGRAL	\N	\N	t	2025-06-14 18:42:01.829398-05	\N
a11fff06-3bcc-4665-b622-9cf8df2f0630	\N	ELABORACIÓN DE PROYECTOS TURÍSTICOS	\N	\N	t	2025-06-14 18:42:02.894709-05	\N
f6327a69-73bb-4f20-8c90-85126c1759ed	\N	ENSAYO DE MATERIALES (ESTÁTICA Y RESISTENCIA)	\N	\N	t	2025-06-14 18:42:02.931618-05	\N
09e8097e-64b0-4aa0-9375-1dc512350751	\N	ESPAÑOL	\N	\N	t	2025-06-14 18:42:03.003492-05	\N
f1c2b742-2e0b-412f-a026-ea090c7fa15e	\N	ESPAÑOL (LENGUAJE Y COMUNICACIÓN)	\N	\N	t	2025-06-14 18:42:03.301774-05	\N
767b8d77-7f5b-4970-b458-225d8c8ff28f	\N	ÉTICA, MORAL, VALORES Y RELACIONES HUMANAS	\N	\N	t	2025-06-14 18:42:04.622835-05	\N
b60fe917-c6d3-4331-8878-feca2c7cc9e3	\N	MATEMÁTICA	\N	\N	t	2025-06-14 18:42:05.010827-05	\N
2d37981d-051e-44e2-86d8-6600982d9d36	\N	MERCADEO Y PUBLICIDAD	\N	\N	t	2025-06-14 18:42:05.577443-05	\N
afa75117-2804-4650-b310-2c31a8f37732	\N	MERCADOTECNIA Y PUBLICIDAD	\N	\N	t	2025-06-14 18:42:05.610169-05	\N
a71addca-33d4-4b8c-8eab-f510e2b08557	\N	MULTIMEDIA Y DESARROLLO WEB	\N	\N	t	2025-06-14 18:42:05.702428-05	\N
45358765-1e9d-40d6-9f3f-4b13211ec7e0	\N	NÁUTICA BÁSICA	\N	\N	t	2025-06-14 18:42:05.735413-05	\N
9b10d056-636b-4780-9aaf-3180bfffcf8f	\N	OFFICE MANAGEMENT	\N	\N	t	2025-06-14 18:42:05.798022-05	\N
6450833e-a92a-4cc8-9eb0-188a4e9e41a9	\N	OFIMÁTICA	\N	\N	t	2025-06-14 18:42:05.831432-05	\N
6c87424b-b8a6-44ff-94cd-c198380ff0fb	\N	PRÁCTICA PROFESIONAL	\N	\N	t	2025-06-14 18:42:05.893984-05	\N
0130d83b-82d4-4a42-95dc-997d2e364570	\N	PROFESSIONAL PRACTICE	\N	\N	t	2025-06-14 18:42:05.985347-05	\N
d13aa640-bc74-4187-a51f-fb8a0c779152	\N	PROGRAMACIÓN	\N	\N	t	2025-06-14 18:42:06.019818-05	\N
345001d7-26f8-48fa-93e5-9ee9522a14ab	\N	PROYECTO Y PRESUPUESTO	\N	\N	t	2025-06-14 18:42:06.054022-05	\N
03d5d3cf-1634-4e02-becb-8adc869d1974	\N	QUÍMICA	\N	\N	t	2025-06-14 18:42:06.089301-05	\N
4d4fc0ca-a74d-438a-bf93-eb06fe3df5c0	\N	RECURSOS MARINOS Y COSTEROS	\N	\N	t	2025-06-14 18:42:06.724587-05	\N
d910b7bc-b855-4d56-8d0d-85731c3ca991	\N	REDES DE COMPUTADORAS	\N	\N	t	2025-06-14 18:42:06.757121-05	\N
90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	\N	RELIGIÓN, MORAL Y VALORES	\N	\N	t	2025-06-14 18:42:06.817882-05	\N
da56e8b4-8376-4664-8e64-5860d60507cb	\N	SEGURIDAD MARÍTIMA	\N	\N	t	2025-06-14 18:42:07.100049-05	\N
c1e6d0ab-d7cf-4051-b388-b10c0b16f3c4	\N	SERVICIO Y GESTIÓN INSTITUCIONAL	\N	\N	t	2025-06-14 18:42:07.13979-05	\N
d9becc23-9506-41b6-bc0a-5e9e32b4030d	\N	SERVICIOS TURÍSTICOS I Y II	\N	\N	t	2025-06-14 18:42:07.210737-05	\N
c076b644-4f74-4322-8e66-3f3305572bba	\N	SISTEMAS MECÁNICOS, HIDRÁULICOS Y NEUMÁTICOS	\N	\N	t	2025-06-14 18:42:07.288797-05	\N
e4ed7dd7-7823-430a-8641-12c19622aa93	\N	TALLER DE MICRO INDUSTRIAS	\N	\N	t	2025-06-14 18:42:07.325031-05	\N
95182a1b-c357-47d8-983e-930667540381	\N	TALLER DE PRODUCCIÓN Y DISTRIBUCIÓN	\N	\N	t	2025-06-14 18:42:07.398171-05	\N
afb6a689-260d-45f9-ba33-a8b013dc4081	\N	TALLER DE PROYECTO Y PRESUPUESTO	\N	\N	t	2025-06-14 18:42:07.436684-05	\N
2aa9fd0b-d60d-49f3-93e7-ad5e90a1bb12	\N	TALLER DE SISTEMAS ROBÓTICOS	\N	\N	t	2025-06-14 18:42:07.472905-05	\N
c4955a5b-7cc7-4fa9-81ff-cc81c7534495	\N	TALLER ECOLOGÍA FAMILIAR	\N	\N	t	2025-06-14 18:42:07.509657-05	\N
457cb5a5-fd01-4220-85ba-a6b67074a6a2	\N	TALLER I (FUNDAMENTOS DE MEDICIONES Y SEGURIDAD INDUSTRIAL)	\N	\N	t	2025-06-14 18:42:07.582174-05	\N
d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	\N	TALLER I (FUNDAMENTOS DE MEDICIONES Y SEGURIDAD INDUSTRIAL).	\N	\N	t	2025-06-14 18:42:07.622577-05	\N
ff2ae947-169b-4191-8240-6f63a2aa26f4	\N	TALLER I Y II (PRÁCTICA PROFESIONAL)	\N	\N	t	2025-06-14 18:42:07.835154-05	\N
8b57cd3a-01bd-4997-9e3c-b5927bd67e6f	\N	TALLER II (DIAGNÓSTICO AUTOMOTRIZ AUTOMATIZADO)	\N	\N	t	2025-06-14 18:42:07.910087-05	\N
e919ef33-cb9c-4eb7-997f-c8271be8f2e7	\N	TALLER II (ELECTRÓNICA INDUSTRIAL)	\N	\N	t	2025-06-14 18:42:07.950109-05	\N
f695ea4f-307c-4a67-a94e-7aad9c1daea0	\N	TALLER II (INSTALACIONES RESIDENCIALES Y COMERCIALES)	\N	\N	t	2025-06-14 18:42:07.991017-05	\N
c5d57eca-2406-49e5-943b-60a1c6777409	\N	TALLER II (SOLDADURA Y HOJALATERÍA)	\N	\N	t	2025-06-14 18:42:08.032602-05	\N
cc84047b-214f-4726-9afb-b65e8578e8fc	\N	TALLER II-A (CIRCUITOS ELÉCTRICOS)	\N	\N	t	2025-06-14 18:42:08.108747-05	\N
41810c3e-1088-4103-8c64-5464d4c087e8	\N	TALLER II-B (CIRCUITOS ELECTRÓNICOS)	\N	\N	t	2025-06-14 18:42:08.150729-05	\N
8c32b128-5a24-4318-9875-eeff9f63a232	\N	TALLER III (COMUNICACIONES)	\N	\N	t	2025-06-14 18:42:08.195256-05	\N
5b17b887-f077-4815-aec9-76ade7fc48e3	\N	TALLER III (ELECTRICIDAD Y ELECTRÓNICA)	\N	\N	t	2025-06-14 18:42:08.26434-05	\N
4e79c543-fe6e-4cb3-a9e9-f8de2ab5edce	\N	TALLER III (TECNOLOGÍA Y TALLER AUTOMOTRIZ)	\N	\N	t	2025-06-14 18:42:08.33607-05	\N
18cf4bd8-0c41-4853-b7f0-ab8045fa84d7	\N	TALLER III ELECTRÓNICA)	\N	\N	t	2025-06-14 18:42:08.407479-05	\N
d9026535-e315-4e7d-b865-590ad2ef02c4	\N	TALLER III-A (SOLDADURA I)	\N	\N	t	2025-06-14 18:42:08.447084-05	\N
e30e3c89-f75a-4c26-bb8c-726a2d22026c	\N	TALLER III-B (SOLDADURA II Y HOJALATERÍA)	\N	\N	t	2025-06-14 18:42:08.488586-05	\N
1d0005f9-241e-4c79-b8fe-b1b22d5a69e4	\N	TALLER IV (ANÁLISIS DE CIRCUITOS ELÉCTRICOS)	\N	\N	t	2025-06-14 18:42:08.53072-05	\N
3be08eb2-2963-40df-81a8-272bb1b87182	\N	TALLER IV (CIRCUITOS ELECTRÓNICOS)	\N	\N	t	2025-06-14 18:42:08.569537-05	\N
696df0e1-dcf8-4a88-b02c-cb2259b876ec	\N	TALLER IV (ELECTRICIDAD Y ELECTRÓNICA AUTOMOTRIZ)	\N	\N	t	2025-06-14 18:42:08.646723-05	\N
e14efa35-1987-4cc3-b70e-06250f27f0d1	\N	TALLER IV (MECÁNICA DE PRECISIÓN Y PRÁCTICA PROFESIONAL)	\N	\N	t	2025-06-14 18:42:08.722032-05	\N
2f5958fd-620f-4556-b050-94371ce79dce	\N	TALLER IV (TECNOLOGÍA Y PRÁCTICA DE LA REFRIGERACIÓN Y CLIMATIZACIÓN)	\N	\N	t	2025-06-14 18:42:08.795906-05	\N
ef183f7c-c3d1-45ee-a548-e505385aa062	\N	TALLER SERVICIOS MÚLTIPLES	\N	\N	t	2025-06-14 18:42:08.836947-05	\N
7334bc00-bb6d-4c22-ad74-ca1a06230cac	\N	TALLER V (MANTENIMIENTO AUTOMOTRIZ)	\N	\N	t	2025-06-14 18:42:08.87376-05	\N
f3aa23d4-ad96-4e5b-bbea-a93cb8acd679	\N	TALLER V (MÁQUINA ELÉCTRICA)	\N	\N	t	2025-06-14 18:42:08.914635-05	\N
8cd35820-0d17-429f-8510-fcf411f8e6a2	\N	TALLER V (TECNOLOGÍA DIGITAL)	\N	\N	t	2025-06-14 18:42:08.953611-05	\N
81faeb59-87bb-4204-9158-6d18b7f32895	\N	TALLER V (TECNOLOGÍA Y PRÁCTICA DE LA REFRIGERACIÓN Y CLIMATIZACIÓN)	\N	\N	t	2025-06-14 18:42:09.032641-05	\N
c7d83767-bedc-4f26-ad8e-f4dd96a8b179	\N	TECNOLOGÍA COMERCIAL	\N	\N	t	2025-06-14 18:42:09.075629-05	\N
2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	\N	TECNOLOGÍA DE LA INFORMACIÓN	\N	\N	t	2025-06-14 18:42:09.295037-05	\N
12069145-518c-4103-90e0-7d36ceebb544	\N	TECNOLOGÍAS	\N	\N	t	2025-06-14 18:42:09.890738-05	\N
2774c5ba-437c-4461-9e93-3ad251707aa5	\N	TEORÍA Y PRÁCTICA PROFESIONAL	\N	\N	t	2025-06-14 18:42:10.224878-05	\N
c8bebd64-d512-4ecb-b71e-d2fd6b2eb99a	\N	TOPOGRAFÍA	\N	\N	t	2025-06-14 18:42:10.265818-05	\N
160ab978-9698-42c2-a4bc-a9c768926b6f	\N	TRANSPORTE Y LOGÍSTICA	\N	\N	t	2025-06-14 18:42:10.306907-05	\N
7dfc5e9f-c1f5-4cf3-b9a7-05a3297569da	\N	TURISMO (INTRODUCCIÓN AL TURISMO Y CULTURA TURÍSTICA)	\N	\N	t	2025-06-14 18:42:10.379755-05	\N
ab30f171-8aac-479a-b648-da81bfc1be6a	\N	TURISMO SOSTENIBLE	\N	\N	t	2025-06-14 18:42:10.49387-05	\N
666452b2-e093-457b-b465-e36c3094ba70	\N	EXPRESIONES ARTÍSTICAS	\N	\N	t	2025-06-14 18:42:10.790019-05	\N
071c67f5-8cd9-49f8-8375-e646c71d7937	\N	FÍSICA	\N	\N	t	2025-06-14 18:42:11.09745-05	\N
d85332cd-f71c-4980-aa40-e6d27d6ce2b1	\N	FORMULACIÓN Y EVALUACIÓN DE PROYECTOS	\N	\N	t	2025-06-14 18:42:11.813946-05	\N
2419537c-563b-44a8-81c4-5f3d6287f310	\N	FRANCES	\N	\N	t	2025-06-14 18:42:11.919821-05	\N
b4e96247-797e-4d07-9d13-cbc686da0399	\N	FRANCÉS/MANDARÍN/OTROS	\N	\N	t	2025-06-14 18:42:12.025535-05	\N
afbb13d8-b0c9-4f17-8f24-4ea2e01fd617	\N	FUNDAMENTO LABORAL Y COMERCIAL	\N	\N	t	2025-06-14 18:42:12.138252-05	\N
94a2f151-893c-426c-b8af-7d6b39e8245d	\N	GEOGRAFÍA	\N	\N	t	2025-06-14 18:42:12.248293-05	\N
6f48a4ba-3043-44ae-9a72-af73a2b30608	\N	GEOGRAFÍA DE PANAMÁ	\N	\N	t	2025-06-14 18:42:12.355752-05	\N
2f43da8f-d9f7-4133-94d1-84f8b2b8401f	\N	GEOGRAFÍA ECONÓMICA	\N	\N	t	2025-06-14 18:42:12.865866-05	\N
99296f68-1117-491f-a8e2-337fce77f135	\N	GEOGRAFÍA FÍSICA	\N	\N	t	2025-06-14 18:42:12.981053-05	\N
f1726da2-d766-46a1-8356-2a23b9912854	\N	GEOGRAFÍA HUMANA ECONÓMICA Y POLÍTICA	\N	\N	t	2025-06-14 18:42:13.070481-05	\N
7f56eb86-b298-4a97-a496-d31ff9d3269c	\N	GEOGRAFÍA TURÍSTICA DE PANAMÁ	\N	\N	t	2025-06-14 18:42:13.13842-05	\N
69f75876-5a83-4578-866a-a356457556aa	\N	GEOGRAFRÍA TURÍSTICA DEL MUNDO	\N	\N	t	2025-06-14 18:42:13.173986-05	\N
bfc63b64-11de-40bc-a950-e77d38531afb	\N	GESTIÓN EMPRESARIAL	\N	\N	t	2025-06-14 18:42:13.20749-05	\N
2be8c622-bd40-4399-800d-db79f576a8f3	\N	GESTIÓN EMPRESARIAL TURÍSTICA	\N	\N	t	2025-06-14 18:42:13.594921-05	\N
bf84cc88-30aa-420d-aa9c-8bd1366fe5a3	\N	GESTIÓN EMPRESARIAL Y FORMULACIÓN DE PROYECTOS	\N	\N	t	2025-06-14 18:42:13.634349-05	\N
c95eba06-5073-4749-bc20-25515f703da4	\N	HISTORIA	\N	\N	t	2025-06-14 18:42:13.710876-05	\N
57d5aeba-fd9c-4e26-bc93-ca11f112ac50	\N	HISTORIA DE LA CULTURA DE AMÉRICA LATINA	\N	\N	t	2025-06-14 18:42:13.809943-05	\N
009e1039-8705-4bef-872e-c03bcc4a05b0	\N	HISTORIA DE LAS RELACIONES ENTRE PANAMÁ Y LOS ESTADOS UNIDOS DE AMÉRICA	\N	\N	t	2025-06-14 18:42:13.845199-05	\N
77399a04-c033-416a-a8d5-1ebde27bbba7	\N	HISTORIA DE PANAMÁ	\N	\N	t	2025-06-14 18:42:14.277226-05	\N
8d2e9a35-e707-49e5-8ff9-8582e571311d	\N	INDUSTRIA MARÍTIMA BÁSICA	\N	\N	t	2025-06-14 18:42:14.542116-05	\N
8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	\N	INGLÉS	\N	\N	t	2025-06-14 18:42:14.58063-05	\N
8b109e75-4cec-4c39-8814-d0c613c566b7	\N	PUERTOS E INDUSTRIAS MARÍTIMAS AUXILIARES	\N	\N	t	2025-06-14 18:42:14.791358-05	\N
47e670ac-0ac3-46c9-942e-ca34b24ccdeb	\N	INGLÉS (LENGUAJE Y COMUNICACIÓN)	\N	\N	t	2025-06-14 18:42:15.583278-05	\N
56cd2914-b523-4883-a407-6f0f4b95d119	\N	INTRODUCCIÓN A LAS ARTES CULINARIAS	\N	\N	t	2025-06-14 18:42:17.072994-05	\N
663fcd4a-1b6f-40da-a1eb-8de8722b4f8f	\N	LABORATORIO (SOFTWARE CONTABLE)	\N	\N	t	2025-06-14 18:42:17.143629-05	\N
2b38bf28-5925-434b-a48d-99808624d119	\N	LEGISLACIÓN DE LA CONSTRUCCIÓN	\N	\N	t	2025-06-14 18:42:17.213281-05	\N
74a199ca-5d40-4adc-b206-e381ba531af6	\N	LÓGICA / FILOSOFÍA	\N	\N	t	2025-06-14 18:42:17.250559-05	\N
862fafad-bfb7-45de-880a-4ab022993152	\N	LÓGICA Y FILOSOFÍA	\N	\N	t	2025-06-14 18:42:17.51527-05	\N
26b00153-ec1d-4b83-80b6-74d24c580cd9	\N	HISTORIA DE RELACIONES ENTRE PANAMÁ Y LOS ESTADOS UNIDOS DE AMÉRICA	\N	\N	t	2025-06-14 18:42:31.512838-05	\N
e1a6c773-2833-40b7-ada9-9d59a05043e1	\N	HISTORIA MODERNA Y POST-MODERNA	\N	\N	t	2025-06-14 18:42:31.574779-05	\N
209e9bde-3a06-4d20-9482-c64f16911d18	\N	ddd	\N	ddddd	t	2025-07-05 23:00:22.521049-05	\N
\.


--
-- TOC entry 5212 (class 0 OID 17038)
-- Dependencies: 237
-- Data for Name: teacher_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_assignments (id, teacher_id, subject_assignment_id, created_at) FROM stdin;
2ad73620-4fdb-4599-93b4-8e464c7976ca	849bc167-84a0-4feb-89fa-d38a621221e0	f8a81864-e13d-456d-b8b3-74f03856c6c1	2025-07-06 13:41:35.086586-05
\.


--
-- TOC entry 5213 (class 0 OID 17043)
-- Dependencies: 238
-- Data for Name: trimester; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trimester (id, school_id, name, description, "order", start_date, end_date, is_active, created_at, updated_at) FROM stdin;
30d604f4-2e31-4577-aa6d-dfc763ae2fed	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	3T	\N	3	2025-09-22 00:00:00-05	2025-12-24 00:00:00-05	t	2025-07-06 13:40:54.426459-05	\N
99f02818-f409-49f0-ae06-3da03884dd35	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	2T	\N	2	2025-05-06 00:00:00-05	2025-08-07 00:00:00-05	t	2025-07-06 13:40:54.424562-05	\N
2f0e3afa-4a65-4c4b-a6b5-80a1f56b55cd	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	1T	\N	1	2025-01-06 00:00:00-05	2025-04-03 00:00:00-05	f	2025-07-06 13:40:54.382958-05	2025-07-06 13:40:56.097696-05
\.


--
-- TOC entry 5214 (class 0 OID 17051)
-- Dependencies: 239
-- Data for Name: user_grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_grades (user_id, grade_id) FROM stdin;
\.


--
-- TOC entry 5215 (class 0 OID 17054)
-- Dependencies: 240
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_groups (user_id, group_id) FROM stdin;
\.


--
-- TOC entry 5216 (class 0 OID 17057)
-- Dependencies: 241
-- Data for Name: user_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_subjects (user_id, subject_id) FROM stdin;
\.


--
-- TOC entry 5217 (class 0 OID 17060)
-- Dependencies: 242
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, school_id, name, email, password_hash, role, status, two_factor_enabled, last_login, created_at, last_name, document_id, date_of_birth, "UpdatedAt") FROM stdin;
f38cda1e-ff1d-4114-9114-329c50722c71	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1000	estudiante1000@demo.com	$2a$11$uMpIfWh2GE/bDxzXNeEpjOmPN7MMyKsLFDhVsznNmmJj4xO7ff8tS	estudiante	active	f	\N	2025-07-05 22:43:59.27255-05		\N	2025-07-05 22:43:59.524446-05	\N
4429dd31-9292-49c6-94ca-989ea24f0f37	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1001	estudiante1001@demo.com	$2a$11$kXnImA5RPchM64F2kZ2pWep7Rc1FVcq/hqGUB05F.ATdEaYRv2bu6	estudiante	active	f	\N	2025-07-05 22:43:59.651869-05		\N	2025-07-05 22:43:59.788471-05	\N
12e6088f-b1d1-418e-a326-bf17e4777eca	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1002	estudiante1002@demo.com	$2a$11$gY0lvqlt29ebWaiVSJHjWutOEj0/2SgbZA3WgvMFPQFZdUZ075002	estudiante	active	f	\N	2025-07-05 22:43:59.809322-05		\N	2025-07-05 22:43:59.945417-05	\N
d5952aa6-7b21-46d7-92d9-92c5da7654d0	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1003	estudiante1003@demo.com	$2a$11$IqFwd/Zinw1GcDGfi91Y6.D/cB2vj8aIaT9879B8rXb5k09dc0j.W	estudiante	active	f	\N	2025-07-05 22:43:59.965463-05		\N	2025-07-05 22:44:00.104971-05	\N
b130bc87-a0a1-4999-9860-5ccf2b134f6e	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1004	estudiante1004@demo.com	$2a$11$vJJiMZZTXRA0PXMOWgnaN.Q367JWCty1HH80sWND/06iE9WxtrsQ.	estudiante	active	f	\N	2025-07-05 22:44:00.126951-05		\N	2025-07-05 22:44:00.262289-05	\N
255d4744-a3a7-449d-a897-e55993ced01b	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1005	estudiante1005@demo.com	$2a$11$lGn76vwiuwRZ/aO965S20u4nKeZDcGnuae3E/ydyY2KkWnzJ96I5K	estudiante	active	f	\N	2025-07-05 22:44:00.292023-05		\N	2025-07-05 22:44:00.428826-05	\N
040b1332-32c6-400c-a66f-3ac1806e057c	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1006	estudiante1006@demo.com	$2a$11$AyJhA7h.NOKEaY3yjnSkn.6O8qX6eDcXYADhcs.T7g.05N.gM26WS	estudiante	active	f	\N	2025-07-05 22:44:00.450944-05		\N	2025-07-05 22:44:00.589433-05	\N
a65e4b5e-96b2-4f6c-bbea-a8e4e2a95d55	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1007	estudiante1007@demo.com	$2a$11$QIScLFw51XVgH3j2vZJt3O6yBV2hIY3O55dUgxXB1c3d87YXdojHS	estudiante	active	f	\N	2025-07-05 22:44:00.610294-05		\N	2025-07-05 22:44:00.7456-05	\N
8e390c08-e8a7-41d7-a1d6-a103d8cbd265	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1008	estudiante1008@demo.com	$2a$11$PSA3/OtNDDP3aRXzSoPqPuoOyPY3E4pQ4g9eZVXp55GiZoQBq/BP2	estudiante	active	f	\N	2025-07-05 22:44:00.766092-05		\N	2025-07-05 22:44:00.903294-05	\N
fecd8a0f-c74d-462b-a604-eb1d22dad933	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	estudiante1009	estudiante1009@demo.com	$2a$11$dbkxUlr/LJNoJJqSY/iruu6t8pfD6WVoZNObvC77qeLG1fh9LG5lK	estudiante	active	f	\N	2025-07-05 22:44:00.924182-05		\N	2025-07-05 22:44:01.06015-05	\N
3e3eea5d-db0b-433e-8040-5ad908aaaceb	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	Irvingssss	icorrossssss@people-inmotion.com	$2a$11$qtnhEkE47nfg.K4btCbo6OEGLfrig3qarTYFdnAObLPHNILwFY/.2	director	active	f	\N	2025-07-05 22:01:55.314102-05	Corro Mendoza		2222-12-12 00:00:00-05	\N
b5cb04ba-8b09-4f7c-bf34-6fed01fa080b	\N	admin@correo.com	admin@correo.com	$2a$11$ghA2pp1kQxj87N/q7Eq0QexRa2T0C8vf6TSmbCywSK6/phMMFY1TS	superadmin	active	f	2025-07-05 23:52:15.125272-05	2025-04-11 22:55:18.363537-05	Corro	DOC000016	2025-04-23 11:12:36.889583-05	\N
0d8014f2-3870-4e3e-ad7a-21138c70f1e3	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	Irving	icorro@people-inmotion.com	$2a$11$elzij.6YeURA4ZGWpo.7XOxHCaJ79nSnEFTac6Itx.kXApm68Vjpy	admin	active	f	2025-07-06 13:39:56.7569-05	2025-07-05 13:35:58.611545-05	Corro Mendoza	\N	2025-07-05 13:35:58.482289-05	\N
849bc167-84a0-4feb-89fa-d38a621221e0	57bc1b05-0436-4a6f-ae6d-52fbe1982b5e	Irving	icorro2222@people-inmotion.com	$2a$11$Ryz.Ldr8XcBvTJ4w4AakduRnpUDnuu4BpM79vcw.OdzIL6o07hQ1O	teacher	active	f	2025-07-07 18:44:08.631815-05	2025-07-05 15:14:45.028959-05	Corro Mendoza	2222222	2025-07-05 00:00:00-05	\N
\.


--
-- TOC entry 4900 (class 2606 OID 17074)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 4906 (class 2606 OID 17076)
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- TOC entry 4912 (class 2606 OID 17078)
-- Name: activity_attachments activity_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 4917 (class 2606 OID 17080)
-- Name: activity_types activity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4921 (class 2606 OID 17082)
-- Name: area area_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--
-- TOC entry 4927 (class 2606 OID 17084)
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- TOC entry 4931 (class 2606 OID 17086)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4938 (class 2606 OID 17088)
-- Name: discipline_reports discipline_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 4941 (class 2606 OID 17090)
-- Name: grade_levels grade_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_levels
    ADD CONSTRAINT grade_levels_pkey PRIMARY KEY (id);


--
-- TOC entry 4944 (class 2606 OID 17092)
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- TOC entry 4947 (class 2606 OID 17094)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 4950 (class 2606 OID 17096)
-- Name: security_settings security_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 4953 (class 2606 OID 17098)
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- TOC entry 4957 (class 2606 OID 17100)
-- Name: student_activity_scores student_activity_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 4963 (class 2606 OID 17102)
-- Name: student_assignments student_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT student_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4967 (class 2606 OID 17104)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 4974 (class 2606 OID 17106)
-- Name: subject_assignments subject_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4978 (class 2606 OID 17108)
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 4981 (class 2606 OID 17110)
-- Name: teacher_assignments teacher_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4986 (class 2606 OID 17112)
-- Name: trimester trimester_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_pkey PRIMARY KEY (id);


--
-- TOC entry 4989 (class 2606 OID 17114)
-- Name: user_grades user_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT user_grades_pkey PRIMARY KEY (user_id, grade_id);


--
-- TOC entry 4992 (class 2606 OID 17116)
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (user_id, group_id);


--
-- TOC entry 4995 (class 2606 OID 17118)
-- Name: user_subjects user_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT user_subjects_pkey PRIMARY KEY (user_id, subject_id);


--
-- TOC entry 5000 (class 2606 OID 17120)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4901 (class 1259 OID 17121)
-- Name: IX_activities_ActivityTypeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_ActivityTypeId" ON public.activities USING btree ("ActivityTypeId");


--
-- TOC entry 4902 (class 1259 OID 17122)
-- Name: IX_activities_TrimesterId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_TrimesterId" ON public.activities USING btree ("TrimesterId");


--
-- TOC entry 4903 (class 1259 OID 17123)
-- Name: IX_activities_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_school_id" ON public.activities USING btree (school_id);


--
-- TOC entry 4904 (class 1259 OID 17124)
-- Name: IX_activities_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_subject_id" ON public.activities USING btree (subject_id);


--
-- TOC entry 4914 (class 1259 OID 17125)
-- Name: IX_activity_types_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activity_types_school_id" ON public.activity_types USING btree (school_id);


--
-- TOC entry 4918 (class 1259 OID 17126)
-- Name: IX_area_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_area_school_id" ON public.area USING btree (school_id);


--
-- TOC entry 4922 (class 1259 OID 17127)
-- Name: IX_attendance_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_grade_id" ON public.attendance USING btree (grade_id);


--
-- TOC entry 4923 (class 1259 OID 17128)
-- Name: IX_attendance_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_group_id" ON public.attendance USING btree (group_id);


--
-- TOC entry 4924 (class 1259 OID 17129)
-- Name: IX_attendance_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_student_id" ON public.attendance USING btree (student_id);


--
-- TOC entry 4925 (class 1259 OID 17130)
-- Name: IX_attendance_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_teacher_id" ON public.attendance USING btree (teacher_id);


--
-- TOC entry 4928 (class 1259 OID 17131)
-- Name: IX_audit_logs_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_audit_logs_school_id" ON public.audit_logs USING btree (school_id);


--
-- TOC entry 4929 (class 1259 OID 17132)
-- Name: IX_audit_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_audit_logs_user_id" ON public.audit_logs USING btree (user_id);


--
-- TOC entry 4932 (class 1259 OID 17133)
-- Name: IX_discipline_reports_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_grade_level_id" ON public.discipline_reports USING btree (grade_level_id);


--
-- TOC entry 4933 (class 1259 OID 17134)
-- Name: IX_discipline_reports_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_group_id" ON public.discipline_reports USING btree (group_id);


--
-- TOC entry 4934 (class 1259 OID 17135)
-- Name: IX_discipline_reports_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_student_id" ON public.discipline_reports USING btree (student_id);


--
-- TOC entry 4935 (class 1259 OID 17136)
-- Name: IX_discipline_reports_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_subject_id" ON public.discipline_reports USING btree (subject_id);


--
-- TOC entry 4936 (class 1259 OID 17137)
-- Name: IX_discipline_reports_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_teacher_id" ON public.discipline_reports USING btree (teacher_id);


--
-- TOC entry 4942 (class 1259 OID 17138)
-- Name: IX_groups_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_groups_school_id" ON public.groups USING btree (school_id);


--
-- TOC entry 4945 (class 1259 OID 17139)
-- Name: IX_schools_admin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_schools_admin_id" ON public.schools USING btree (admin_id);


--
-- TOC entry 4948 (class 1259 OID 17140)
-- Name: IX_security_settings_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_security_settings_school_id" ON public.security_settings USING btree (school_id);


--
-- TOC entry 4959 (class 1259 OID 17141)
-- Name: IX_student_assignments_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_grade_id" ON public.student_assignments USING btree (grade_id);


--
-- TOC entry 4960 (class 1259 OID 17142)
-- Name: IX_student_assignments_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_group_id" ON public.student_assignments USING btree (group_id);


--
-- TOC entry 4961 (class 1259 OID 17143)
-- Name: IX_student_assignments_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_student_id" ON public.student_assignments USING btree (student_id);


--
-- TOC entry 4964 (class 1259 OID 17144)
-- Name: IX_students_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_students_parent_id" ON public.students USING btree (parent_id);


--
-- TOC entry 4965 (class 1259 OID 17145)
-- Name: IX_students_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_students_school_id" ON public.students USING btree (school_id);


--
-- TOC entry 4968 (class 1259 OID 17146)
-- Name: IX_subject_assignments_SchoolId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_SchoolId" ON public.subject_assignments USING btree ("SchoolId");


--
-- TOC entry 4969 (class 1259 OID 17147)
-- Name: IX_subject_assignments_area_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_area_id" ON public.subject_assignments USING btree (area_id);


--
-- TOC entry 4970 (class 1259 OID 17148)
-- Name: IX_subject_assignments_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_grade_level_id" ON public.subject_assignments USING btree (grade_level_id);


--
-- TOC entry 4971 (class 1259 OID 17149)
-- Name: IX_subject_assignments_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_group_id" ON public.subject_assignments USING btree (group_id);


--
-- TOC entry 4972 (class 1259 OID 17150)
-- Name: IX_subject_assignments_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_subject_id" ON public.subject_assignments USING btree (subject_id);


--
-- TOC entry 4975 (class 1259 OID 17151)
-- Name: IX_subjects_AreaId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subjects_AreaId" ON public.subjects USING btree ("AreaId");


--
-- TOC entry 4976 (class 1259 OID 17152)
-- Name: IX_subjects_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subjects_school_id" ON public.subjects USING btree (school_id);


--
-- TOC entry 4979 (class 1259 OID 17153)
-- Name: IX_teacher_assignments_subject_assignment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_teacher_assignments_subject_assignment_id" ON public.teacher_assignments USING btree (subject_assignment_id);


--
-- TOC entry 4983 (class 1259 OID 17154)
-- Name: IX_trimester_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_trimester_school_id" ON public.trimester USING btree (school_id);


--
-- TOC entry 4987 (class 1259 OID 17155)
-- Name: IX_user_grades_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_grades_grade_id" ON public.user_grades USING btree (grade_id);


--
-- TOC entry 4990 (class 1259 OID 17156)
-- Name: IX_user_groups_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_groups_group_id" ON public.user_groups USING btree (group_id);


--
-- TOC entry 4993 (class 1259 OID 17157)
-- Name: IX_user_subjects_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_subjects_subject_id" ON public.user_subjects USING btree (subject_id);


--
-- TOC entry 4996 (class 1259 OID 17158)
-- Name: IX_users_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_school_id" ON public.users USING btree (school_id);


--
-- TOC entry 4915 (class 1259 OID 17159)
-- Name: activity_types_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX activity_types_name_school_key ON public.activity_types USING btree (name, school_id);


--
-- TOC entry 4919 (class 1259 OID 17160)
-- Name: area_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX area_name_school_key ON public.area USING btree (name, school_id);


--
-- TOC entry 4939 (class 1259 OID 17161)
-- Name: grade_levels_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_levels_name_key ON public.grade_levels USING btree (name);


--
-- TOC entry 4907 (class 1259 OID 17162)
-- Name: idx_activities_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_group ON public.activities USING btree (group_id);


--
-- TOC entry 4908 (class 1259 OID 17163)
-- Name: idx_activities_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_teacher ON public.activities USING btree (teacher_id);


--
-- TOC entry 4909 (class 1259 OID 17164)
-- Name: idx_activities_trimester; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_trimester ON public.activities USING btree (trimester);


--
-- TOC entry 4910 (class 1259 OID 17165)
-- Name: idx_activities_unique_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_unique_lookup ON public.activities USING btree (name, type, subject_id, group_id, teacher_id, trimester);


--
-- TOC entry 4913 (class 1259 OID 17166)
-- Name: idx_attach_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attach_activity ON public.activity_attachments USING btree (activity_id);


--
-- TOC entry 4954 (class 1259 OID 17167)
-- Name: idx_scores_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scores_activity ON public.student_activity_scores USING btree (activity_id);


--
-- TOC entry 4955 (class 1259 OID 17168)
-- Name: idx_scores_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scores_student ON public.student_activity_scores USING btree (student_id);


--
-- TOC entry 4951 (class 1259 OID 17169)
-- Name: specialties_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX specialties_name_key ON public.specialties USING btree (name);


--
-- TOC entry 4982 (class 1259 OID 17170)
-- Name: teacher_assignments_teacher_id_subject_assignment_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX teacher_assignments_teacher_id_subject_assignment_id_key ON public.teacher_assignments USING btree (teacher_id, subject_assignment_id);


--
-- TOC entry 4984 (class 1259 OID 17171)
-- Name: trimester_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX trimester_name_school_key ON public.trimester USING btree (name, school_id);


--
-- TOC entry 4958 (class 1259 OID 17172)
-- Name: uq_scores; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_scores ON public.student_activity_scores USING btree (student_id, activity_id);


--
-- TOC entry 4997 (class 1259 OID 17173)
-- Name: users_document_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_document_id_key ON public.users USING btree (document_id);


--
-- TOC entry 4998 (class 1259 OID 17174)
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- TOC entry 5001 (class 2606 OID 17175)
-- Name: activities FK_activities_activity_types_ActivityTypeId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_activity_types_ActivityTypeId" FOREIGN KEY ("ActivityTypeId") REFERENCES public.activity_types(id);


--
-- TOC entry 5002 (class 2606 OID 17180)
-- Name: activities FK_activities_trimester_TrimesterId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_trimester_TrimesterId" FOREIGN KEY ("TrimesterId") REFERENCES public.trimester(id);


--
-- TOC entry 5022 (class 2606 OID 17185)
-- Name: schools FK_schools_users_admin_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT "FK_schools_users_admin_id" FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- TOC entry 5031 (class 2606 OID 17190)
-- Name: subject_assignments FK_subject_assignments_schools_SchoolId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT "FK_subject_assignments_schools_SchoolId" FOREIGN KEY ("SchoolId") REFERENCES public.schools(id);


--
-- TOC entry 5037 (class 2606 OID 17195)
-- Name: subjects FK_subjects_area_AreaId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT "FK_subjects_area_AreaId" FOREIGN KEY ("AreaId") REFERENCES public.area(id);


--
-- TOC entry 5003 (class 2606 OID 17200)
-- Name: activities activities_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5004 (class 2606 OID 17205)
-- Name: activities activities_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5005 (class 2606 OID 17210)
-- Name: activities activities_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5006 (class 2606 OID 17215)
-- Name: activities activities_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5007 (class 2606 OID 17220)
-- Name: activity_attachments activity_attachments_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5008 (class 2606 OID 17225)
-- Name: activity_types activity_types_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5009 (class 2606 OID 17230)
-- Name: area area_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5010 (class 2606 OID 17235)
-- Name: attendance attendance_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5011 (class 2606 OID 17240)
-- Name: attendance attendance_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5012 (class 2606 OID 17245)
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5013 (class 2606 OID 17250)
-- Name: attendance attendance_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5014 (class 2606 OID 17255)
-- Name: audit_logs audit_logs_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- TOC entry 5015 (class 2606 OID 17260)
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5016 (class 2606 OID 17265)
-- Name: discipline_reports discipline_reports_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5017 (class 2606 OID 17270)
-- Name: discipline_reports discipline_reports_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5018 (class 2606 OID 17275)
-- Name: discipline_reports discipline_reports_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5019 (class 2606 OID 17280)
-- Name: discipline_reports discipline_reports_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5020 (class 2606 OID 17285)
-- Name: discipline_reports discipline_reports_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5026 (class 2606 OID 17290)
-- Name: student_assignments fk_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5027 (class 2606 OID 17295)
-- Name: student_assignments fk_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5028 (class 2606 OID 17300)
-- Name: student_assignments fk_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5042 (class 2606 OID 17305)
-- Name: user_grades fk_user_grades_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5043 (class 2606 OID 17310)
-- Name: user_grades fk_user_grades_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5044 (class 2606 OID 17315)
-- Name: user_groups fk_user_groups_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5045 (class 2606 OID 17320)
-- Name: user_groups fk_user_groups_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5046 (class 2606 OID 17325)
-- Name: user_subjects fk_user_subjects_subject; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_subject FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5047 (class 2606 OID 17330)
-- Name: user_subjects fk_user_subjects_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5021 (class 2606 OID 17335)
-- Name: groups groups_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5023 (class 2606 OID 17340)
-- Name: security_settings security_settings_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5024 (class 2606 OID 17345)
-- Name: student_activity_scores student_activity_scores_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5025 (class 2606 OID 17350)
-- Name: student_activity_scores student_activity_scores_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5029 (class 2606 OID 17355)
-- Name: students students_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- TOC entry 5030 (class 2606 OID 17360)
-- Name: students students_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5032 (class 2606 OID 17365)
-- Name: subject_assignments subject_assignments_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.area(id);


--
-- TOC entry 5033 (class 2606 OID 17370)
-- Name: subject_assignments subject_assignments_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5034 (class 2606 OID 17375)
-- Name: subject_assignments subject_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5035 (class 2606 OID 17380)
-- Name: subject_assignments subject_assignments_specialty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES public.specialties(id);


--
-- TOC entry 5036 (class 2606 OID 17385)
-- Name: subject_assignments subject_assignments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5038 (class 2606 OID 17390)
-- Name: subjects subjects_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5039 (class 2606 OID 17395)
-- Name: teacher_assignments teacher_assignments_subject_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_subject_assignment_id_fkey FOREIGN KEY (subject_assignment_id) REFERENCES public.subject_assignments(id);


--
-- TOC entry 5040 (class 2606 OID 17400)
-- Name: teacher_assignments teacher_assignments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5041 (class 2606 OID 17405)
-- Name: trimester trimester_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5048 (class 2606 OID 17410)
-- Name: users users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE RESTRICT;


-- Completed on 2025-07-07 20:59:44

--
-- PostgreSQL database dump complete
--

