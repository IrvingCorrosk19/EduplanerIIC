--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-09-05 08:03:00

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
-- TOC entry 2 (class 3079 OID 161758)
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
-- TOC entry 3 (class 3079 OID 161795)
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
-- TOC entry 219 (class 1259 OID 161753)
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 161824)
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
-- TOC entry 223 (class 1259 OID 161833)
-- Name: activity_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    activity_id uuid NOT NULL,
    file_name character varying(255) NOT NULL,
    storage_path character varying(500) NOT NULL,
    mime_type character varying(50) NOT NULL,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.activity_attachments OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 161847)
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
-- TOC entry 225 (class 1259 OID 161859)
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
-- TOC entry 226 (class 1259 OID 161871)
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 161883)
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
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 161892)
-- Name: discipline_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discipline_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid,
    teacher_id uuid,
    date timestamp without time zone NOT NULL,
    report_type character varying(50),
    description text,
    status character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    subject_id uuid,
    group_id uuid,
    grade_level_id uuid
);


ALTER TABLE public.discipline_reports OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 161806)
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
-- TOC entry 229 (class 1259 OID 161906)
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
-- TOC entry 230 (class 1259 OID 161915)
-- Name: schools; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schools (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    address character varying(200) DEFAULT ''::character varying NOT NULL,
    phone character varying(20) DEFAULT ''::character varying NOT NULL,
    logo_url character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    admin_id uuid
);


ALTER TABLE public.schools OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 161924)
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.security_settings OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 161815)
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
-- TOC entry 236 (class 1259 OID 162029)
-- Name: student_activity_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_activity_scores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    activity_id uuid NOT NULL,
    score numeric(2,1),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.student_activity_scores OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 162046)
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
-- TOC entry 238 (class 1259 OID 162068)
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 161997)
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
-- TOC entry 232 (class 1259 OID 161945)
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
-- TOC entry 242 (class 1259 OID 162130)
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
-- TOC entry 233 (class 1259 OID 161965)
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
-- TOC entry 239 (class 1259 OID 162085)
-- Name: user_grades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_grades (
    user_id uuid NOT NULL,
    grade_id uuid NOT NULL
);


ALTER TABLE public.user_grades OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 162100)
-- Name: user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_groups (
    user_id uuid NOT NULL,
    group_id uuid NOT NULL
);


ALTER TABLE public.user_groups OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 162115)
-- Name: user_subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_subjects (
    user_id uuid NOT NULL,
    subject_id uuid NOT NULL
);


ALTER TABLE public.user_subjects OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 161980)
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
-- TOC entry 5194 (class 0 OID 161753)
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
\.


--
-- TOC entry 5197 (class 0 OID 161824)
-- Dependencies: 222
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (id, school_id, subject_id, teacher_id, group_id, name, type, trimester, pdf_url, created_at, grade_level_id, "ActivityTypeId", "TrimesterId", due_date) FROM stdin;
\.


--
-- TOC entry 5198 (class 0 OID 161833)
-- Dependencies: 223
-- Data for Name: activity_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_attachments (id, activity_id, file_name, storage_path, mime_type, uploaded_at) FROM stdin;
\.


--
-- TOC entry 5199 (class 0 OID 161847)
-- Dependencies: 224
-- Data for Name: activity_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity_types (id, school_id, name, description, icon, color, is_global, display_order, is_active, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5200 (class 0 OID 161859)
-- Dependencies: 225
-- Data for Name: area; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.area (id, school_id, name, description, code, is_global, display_order, is_active, created_at, updated_at) FROM stdin;
9114e054-5c47-4369-ad9a-6dea25ec5dcd	\N	TECNOLÓGICA	\N	\N	f	0	t	2025-06-14 23:41:57.255163-05	\N
b7bb6287-fea2-4ad8-b962-a36f7531676a	\N	CIENTÍFICA	\N	\N	f	0	t	2025-06-14 23:41:57.612698-05	\N
af7361ff-09bb-4c3e-9570-03ef61efb0aa	\N	HUMANISTICA	\N	\N	f	0	t	2025-06-14 23:41:57.747786-05	\N
7873164c-f5ce-4eff-bc6f-db7b188d33c0	\N	ddd	dddd	\N	f	0	f	2025-07-05 23:00:13.367397-05	\N
\.


--
-- TOC entry 5201 (class 0 OID 161871)
-- Dependencies: 226
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (id, student_id, teacher_id, group_id, grade_id, date, status, created_at) FROM stdin;
\.


--
-- TOC entry 5202 (class 0 OID 161883)
-- Dependencies: 227
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, school_id, user_id, user_name, user_role, action, resource, details, ip_address, "timestamp") FROM stdin;
\.


--
-- TOC entry 5203 (class 0 OID 161892)
-- Dependencies: 228
-- Data for Name: discipline_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discipline_reports (id, student_id, teacher_id, date, report_type, description, status, created_at, updated_at, subject_id, group_id, grade_level_id) FROM stdin;
\.


--
-- TOC entry 5195 (class 0 OID 161806)
-- Dependencies: 220
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
-- TOC entry 5204 (class 0 OID 161906)
-- Dependencies: 229
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
-- TOC entry 5205 (class 0 OID 161915)
-- Dependencies: 230
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schools (id, name, address, phone, logo_url, created_at, admin_id) FROM stdin;
181abc51-1e01-4c32-8684-a636a18b3f47	El Porvenir	admin@correo.com	65140986	633ecb7a-8e0d-40a7-89f9-320396eb9467_ElPorvenir.png	2025-07-29 13:21:32.497176	2b1b31a3-2afd-4357-8889-f709867a4358
\.


--
-- TOC entry 5206 (class 0 OID 161924)
-- Dependencies: 231
-- Data for Name: security_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.security_settings (id, school_id, password_min_length, require_uppercase, require_lowercase, require_numbers, require_special, expiry_days, prevent_reuse, max_login_attempts, session_timeout_minutes, created_at) FROM stdin;
\.


--
-- TOC entry 5196 (class 0 OID 161815)
-- Dependencies: 221
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
-- TOC entry 5211 (class 0 OID 162029)
-- Dependencies: 236
-- Data for Name: student_activity_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_activity_scores (id, student_id, activity_id, score, created_at) FROM stdin;
\.


--
-- TOC entry 5212 (class 0 OID 162046)
-- Dependencies: 237
-- Data for Name: student_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_assignments (id, student_id, grade_id, group_id, created_at) FROM stdin;
d52ad3ad-a832-4542-bd55-976398450c4e	c7ee74ea-4b88-4be2-b06a-12e50d119ef7	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:24:56.52736-05
d91b8e6e-ea41-4dda-9c26-36150e086fff	84561573-701e-4e79-8752-52b7a37cb3d6	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:24:56.684832-05
7734ab4b-630f-4553-ac0c-005431193fba	21d78497-1ddf-4b7d-b098-bcc2db658179	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:24:56.844497-05
a57010c6-b169-403b-9b83-3e4a52d33a6e	ea343094-9329-42a8-881d-e08bc900c3b8	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:24:57.003186-05
b91ce240-302f-46c3-8e3b-a63a42d24547	bacfdfa6-a34f-4d1d-a9d9-9e100ac3a7c5	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:24:57.161481-05
bf1a2c97-63f3-4112-99e6-e6b71d5447c1	32e48db9-798f-4890-af2d-ad6bab718cf4	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:24:57.317045-05
200ee9c7-3b81-42df-a6f6-f716b24d47f1	0360922b-922c-45b4-89bc-15216afedd52	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:24:57.479729-05
f2555963-a6b4-4df7-8891-e6812b1cbd06	88c7241b-9fda-43a8-ae30-d0931c89e55c	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:24:57.637911-05
e0c4ffb7-a72f-4a2b-be95-1572e85ae6b6	03ffc6e8-549d-4ed4-8f08-f4755afc5fb4	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:12.046049-05
e1a525b4-14cf-4105-b194-d65e31a51bb9	042bc0d1-8e8d-4077-bfad-4792cc8c2e51	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:12.20127-05
9e6c9a24-b23f-488e-9732-53a65650717e	87550719-e7d0-4729-9620-664869998e06	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:12.354748-05
9895ca7c-49d7-4b01-9598-5d78c24f2fb3	23529838-129e-46ab-9db9-c813e36defaa	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:12.509401-05
a188e8f1-5e5e-4aa5-924e-53253079eee3	4d0c22b3-0423-4158-bf3c-7b40daf247dc	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:12.663611-05
386499f3-6e7c-4803-9468-a00f314a7d13	b350edff-2be7-4e66-ae87-d7c0814c8340	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:12.81952-05
20c242f6-fd01-4369-82eb-462f93358aef	1ae09f3d-8063-4945-9bcc-0f3ce1d73d51	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:12.976704-05
86dc397b-5647-4b8b-ab57-3955873fb3e4	1bd1dacc-7df5-4dc4-b351-970d9195ce06	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:13.13131-05
aba65fe6-0d43-4336-b14d-ce4feb595080	e883da8d-108a-4ce9-8f65-3fb33413c811	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:25:13.285787-05
3d63b809-2168-4732-a22d-b5770c367526	47f953c4-ed73-4d36-bd57-90d55fefedf3	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:25:13.440265-05
0a101139-d3a3-4922-814d-5f5e81fe2fba	7b5d0782-84d4-4d6c-935a-9a4284d20bdf	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:25:30.716993-05
c07d73a7-c31b-4576-817a-37a422f6f0e8	e5970de1-853b-49cc-bf9b-042fd71c5d5a	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:25:30.906852-05
ca06672a-9a25-443e-8f90-c26d8f6c86b8	31482094-5d58-4a56-9ed6-1b8d67b97572	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:25:31.065336-05
9cbf5cc9-0aad-4122-b265-c4b13eea45b0	7aed13df-6c3c-4276-b08b-a67a4c697a06	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:25:31.223451-05
8abdf7c3-9929-4ac6-bd04-7811282a893c	119b9a2c-1f15-4f4e-a706-a8b7497b29b0	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:25:31.383209-05
98d4c4a1-91c3-4303-bee7-61e3427a1537	39babdd3-6f99-4637-a046-527f15ec8320	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:25:31.540061-05
aa6e53a7-35ff-44aa-b9c2-34b94c27eac1	636717e4-7872-4580-9f96-8a4006fca398	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:25:31.697386-05
ae05337d-1fd5-4f89-954b-b476b4cfdbc9	2a7b768c-c97d-4501-91af-524838d13061	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:25:31.856111-05
d4ac7021-4011-4f34-a4cb-d726cead8f3b	832d745f-9bb7-46ef-936c-81ffd2b48250	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:25:32.015921-05
5ae6dc96-ffc5-4ce5-8ea1-7a7fd545c4c7	557a833d-c73a-4798-af27-f331aece55e6	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:25:32.176181-05
7a7e41ec-5365-4098-9ad3-c08e446bd596	3bcb5be2-fd90-4212-aad9-6cda90b40098	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:25:32.336621-05
7a0d08a4-ad73-47a0-bb07-1dea668b1548	7db8beb8-2a3e-4122-b3cf-fc68ea15308e	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:32.496646-05
c6ec58b6-4b7a-4024-9c41-f660eac5919e	181e37bd-80b0-4be7-bfa5-9b8bc537420d	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:25:32.654229-05
7f7179c2-d946-4a73-b526-cb10d27716f4	28579412-e23a-4867-9539-36bcab716dd5	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:25:32.812275-05
b2e69304-cca3-4476-8ea9-3469ff1f71b0	6e2b2594-a443-4997-bf1c-ef07282aebb7	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:25:32.974172-05
81ea910f-c567-463b-a965-ce83c34ab116	596cf3e0-d548-4a72-be9e-676d0c7b9d98	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:25:33.134399-05
c8205192-999b-48a5-b5cc-ffd96a455df5	d6fdd196-1c89-44b3-9092-b6b76306608f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:25:33.295195-05
f784ebb4-bdb1-41f2-b522-33c8883c0777	324f64ca-ce21-4645-8b56-d9faefd9caee	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:25:33.454121-05
f12e4858-aee6-49a0-aec3-bc300b9bf371	15a4dcd7-79c1-4279-9401-bed2720baa88	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:25:33.615416-05
e9c31f7e-3c7f-4b21-9939-3e474ad23407	01022d97-d9e6-40a7-a1a1-a4e5a120d3b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:25:33.779127-05
67b56a59-9a86-4aaf-a9f8-171e41c34add	dadb7b6b-6d40-47b2-9343-da5b720dd1ec	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:25:33.940569-05
e1007504-529c-47ae-af97-4dc88a2bcdcc	82eadbee-e2b1-4b23-91fc-89addfcf56c3	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:34.10055-05
3ae2290b-ca8d-43a5-9b0d-b8bb21182244	d2774085-36c8-4617-a83f-99b011641413	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:25:34.260042-05
16d14fa4-44e1-4a2d-9ef7-a367749129d7	203d2933-3fbe-46b9-b62a-fea72716894b	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:25:34.419115-05
65ce66bb-32a3-437b-bea4-adbc9dd18436	14e18b2d-89d4-48c8-8a87-5a4432ac3faa	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:34.576067-05
92b4f65a-58f7-4a65-a377-c2ce94c4b6b1	4d9a1b11-5c0c-4e41-be91-6ef10b3b0a1b	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:25:34.734918-05
f4541bcf-5b30-4289-9254-e531d9b3d0d0	92be377c-e0d8-4e39-a904-ac88e8db9063	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:34.891193-05
a14dfbfd-124f-423c-9810-d021258af4bf	6e01948b-bd86-40eb-a094-e07a6d64618a	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:35.05375-05
6bfc5d1b-6380-415f-8429-897a97b29538	7f302c6d-4c52-48b7-8acd-04bd688057b0	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:25:35.219452-05
56552411-fb69-470b-a657-ba60d76f163e	45b9ca2f-02d3-4c02-abdf-192063aaeba0	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:35.380062-05
f2fe4b5b-6867-452d-80f8-900b03b89d38	703a214a-a9be-435f-8d73-1d2734150c96	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:35.554973-05
51b288bb-7765-4901-82b8-5434e75f81f8	d3af105a-60a9-4a10-a3ca-a64cd978c9ad	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:35.728423-05
fe6840cb-8846-494b-aa2c-29d99e8a754e	980b48b7-2cf1-4824-ab5a-2c980fcbceb1	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:25:35.891841-05
823d669e-f06b-4005-a095-346c24fc3dc9	87539ec5-ce68-427b-bbc1-6af8b87a399f	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:36.051918-05
463d1a7f-841f-4433-a3a5-a9bd6c99b279	cf0bf5bd-9deb-4a5a-aad3-1ecbc16ab00a	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:36.22933-05
450ef961-91f2-41e8-8bcf-432c6b2c0f87	1de585e9-c7e5-4e5d-9a51-2aefe4818c1f	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:36.40764-05
f28a2ce0-2410-45fd-b263-acc1df2bb7c3	2866192f-64de-4527-9783-3c86fa220b76	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:36.567855-05
9625025b-e557-42c9-9606-a1760086ead5	e3dbe70c-67a0-422f-be55-bbdbb1e252bb	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:36.730139-05
104e9ce1-3d91-45da-8b23-c63571e4a0c9	d8aa857b-1800-44b0-9582-193852093cb2	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:37.235791-05
619f8024-0ec2-4057-95db-cc78b99a97c5	a3baa386-33f3-45a5-9563-f3bfac3d2a14	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:37.541059-05
bc19e781-39b1-44e6-91fc-f4bc9ad0c687	e8a96bbd-62f4-4b8f-86b9-dbacadf559a0	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:37.73889-05
3762ab5c-b539-4276-8670-d6300f816e7f	80e10fed-7c1f-4fdc-8b84-d19ff4ba6edc	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:38.086219-05
9b18d9f6-3cb5-44cf-af25-b943496388e9	cc6922a0-215a-40b1-9616-56659590f4c8	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:38.330745-05
94d3f9c4-1825-46c0-97a6-218e4ca9092f	d05ac063-d2b3-4994-be8e-b78ed7b74cce	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:25:38.597146-05
2a44b9a1-b1fe-4abd-8df1-6c61fbd94373	80ff7b9a-dfca-4bd6-a805-da724a7a9fe2	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:38.860366-05
38864098-773a-4d59-aa32-4a10d68fa989	92b9d828-469d-4d7b-b5e6-e502c758d76c	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:39.108533-05
bcb35362-606a-4a9c-a227-693bc595652f	20e36638-6ae8-45df-8f8c-7b47dc69c22b	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:39.35415-05
8307fdc2-7058-45e5-aa8c-a4b9b2c98ddf	b61edb01-2801-487c-a114-e3a60cbfa7a5	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:25:39.601616-05
a4eedc62-ff4a-4695-a26c-c69f82e0348e	dd171585-d6eb-4b36-8001-7ace8f1a383e	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:25:39.851289-05
87419727-acb2-4aa6-bbca-db1eb2ec047f	aea92802-26d7-4a17-b0a8-876f80cb6047	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:25:40.097513-05
9980187d-5942-4a31-a52b-6701452a31eb	6243c671-821a-406f-b178-85d5b4904f5f	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:40.338941-05
e31099b8-db55-48d5-8d6d-7191242c316c	4c02fca9-3a3b-453c-8579-ffeafbeca729	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:25:40.58414-05
24f3f2b5-8e3e-4f49-a21f-8d34ed890da1	d6f7775a-4d3a-4535-9eb2-ba8507ba3aa4	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:25:40.844609-05
79de24b5-f022-438d-85a9-5e3a7da80ef1	b3c17170-3a6e-49eb-909a-2d897079fb15	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:25:41.100435-05
edc43d95-9922-454a-b59e-fc11bbd7c081	009396de-df0e-4250-bea2-a0157d8bda21	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:25:41.342822-05
87800aa5-7099-4022-8221-7dc61813839a	521f212b-dec9-4518-9d80-dee509f9d390	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:25:41.588408-05
ea55f655-8cfa-4600-89d9-e767e761d3ec	d72dc39e-d869-4cb4-bdaf-0f8e719dfdcf	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:25:41.824985-05
1e463949-b004-4d06-b979-5cf10f416e34	669bd825-f227-43df-a636-d90a57318f4f	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:25:42.063915-05
848b3764-f30c-4917-8db9-ea12c1226b22	923612ce-506e-461f-ad3a-99c8785e455e	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:25:42.235504-05
489475ed-bd94-4d67-865f-00b820ad716c	7e80c71b-1a6a-498f-9a34-afd75b41a3b0	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:25:42.476204-05
f4ddc2cc-1808-40a8-9c4b-949ad5b686ed	243428f8-f68f-4d0a-9985-5b7758707c11	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:25:42.75262-05
bb782af0-a4f0-4323-bd57-c5dc95a17585	785c3d1d-8758-4c6e-b44d-294770ac8394	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:25:42.986285-05
f0ee3041-2aa2-4905-bc13-489864b925fa	9fc82ad6-6218-4190-bdb2-f28d35a0016a	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:25:55.112597-05
1e750e98-c6cf-4654-bd35-983e93f144ab	e307bb1b-9f1b-4bf0-8aa0-c98cf3f60908	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:25:55.429983-05
ca0e85a5-30ff-4acf-8d6b-e694c7ccba72	1a7f007a-564e-47bf-92f2-0d773cb9fd20	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:25:55.756535-05
0d795d8a-4e1e-4740-89cb-8cb3138353fc	00b69150-2fe4-4261-bb28-da77f117bd75	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:56.077233-05
e6eb3fc8-85a9-4c70-9050-6cd97d303893	c1703147-21e4-43d0-8100-85e6f5e570fc	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:56.398673-05
befd9a95-1621-42f0-b941-9f4560a0af53	7f14b8e1-d96e-4a6e-842d-cb652eee5fcd	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:57.03251-05
6707073c-2703-4ee1-9965-272fbecd8ad0	539654a0-e1a2-4101-bb29-43b9a95859ae	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:57.348011-05
2bfeea3c-bd48-474c-96d5-39e6c435a7b0	deadb577-ae88-4f72-9928-966839d00111	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:57.66675-05
19dcbc27-6e7e-453f-a17a-e3786032979f	63454c05-7422-4447-b7c0-4b6ac6c18452	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:57.982212-05
04a2a344-8f7b-43a1-9f14-132f1d443fb5	fa862365-de9e-4ef5-94c2-4bef2429d33c	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:58.301139-05
a7630bee-ccf4-40ac-971e-0852e73f2f21	b0372dd4-f1a4-4620-9bf5-2378193800db	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:58.616025-05
2801d0aa-4334-494a-866e-699bc339fede	9385ff96-2fd8-4779-903b-ba37c34d3f88	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:58.932247-05
2cb2080e-eec8-4601-ba8b-a80cc683bc13	5ab823e6-4afe-4a31-91a1-b9ddaf628a36	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:59.253775-05
e3125c99-b19a-4ac8-b9c0-bc9c2667b8b3	1f15d415-a8ea-401a-acff-a18d13a01c06	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:25:59.572882-05
02ac02d0-d95c-40ca-a919-3e322d87815b	ef030d2e-b187-4066-9fef-518eefcef491	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:59.891064-05
d5be0fbb-320f-4d92-8174-380f039ce907	e78b5e0c-1b40-4cf8-8bb4-42db593ee5fd	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:26:00.220074-05
9b842e73-c4fa-4ed5-a2b7-60daaf8986eb	62c4e725-dda5-4baf-bbd3-38fe739273ba	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:26:00.54481-05
d5f190e7-5adb-4d2a-8d17-7647ba1acc2e	75789a77-2814-447b-970b-bcae658a2fe3	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:26:00.873926-05
6d446c2d-3ac9-468b-8f27-af9704576166	76e76038-5bf7-4d32-9926-7ac053709ab5	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:26:01.198061-05
52ed532b-0347-470c-ad02-a5914cc64301	d81f7eae-31ad-4eb0-bfbc-7e08b3633f95	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:26:01.522022-05
6517d2d2-865a-4294-a958-6e4f3210fbb0	862d9ff6-438d-48ae-a9e6-79148fd7a704	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:26:01.867643-05
14e8f7e8-71c1-4867-9cea-bd19b18ea3ac	71d75f83-0ea9-4f34-826e-57e845f8cc91	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:26:02.202212-05
6eda36a7-53cf-4cd0-adde-81f123925cd1	0cc19101-3529-4fc2-bab5-251d2c925aba	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:26:02.53127-05
e5714bdf-81dc-44e3-a4de-b327aeb39d07	7b45dad3-4fb2-460f-880d-4a88fab9b714	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:26:02.857176-05
635668ee-f1bc-465d-a91c-dc021f9ba923	2a264be7-0a8b-40d2-afe5-5bcf194951bb	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:26:03.183812-05
2a2dbfce-4743-409d-903d-1da4f0cb093a	8030dad1-39cb-413f-baba-ead4fced51f4	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:26:03.51128-05
8fb53371-96d2-41b1-b501-b8f65af47707	fc6ec1a9-1d00-49a6-b840-d01d7cb9b12b	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:26:03.842936-05
187bbbee-1578-4303-8c1a-714e375e4c0d	c40cef99-a004-4eaf-bd60-f54094813afe	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:26:04.16559-05
644dd34d-78ec-4e93-b162-aaa9dcc8953a	dd8cb26c-3ffd-4bb0-839b-1b04be7f8931	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:26:04.492655-05
b813a91e-8b51-49ef-b169-431d23250bbd	fb189475-61a9-428a-9fae-95dc7404619c	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:26:04.817275-05
cecddbf3-b51f-4b26-becd-ee77de1c41b4	86ea9cdd-998e-431e-9213-8262d6a4bb0d	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:26:05.144961-05
5ebe188e-49e8-4038-9d27-b5444a7adea4	37a47cc8-8cbd-4499-8de7-a0d652dac541	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:26:05.47076-05
cf733182-e671-4ccc-9a20-cc25eeb56cd2	8c07c3a6-feb0-45ee-bd6c-4861e8a5cfe5	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:26:05.804681-05
6c567c3a-8c80-496c-b739-9549edf1598c	a4da0dba-3155-4a91-90e2-1071684b9fc0	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:26:06.147138-05
191900f8-2c19-41cd-8a66-5d3d25ed490c	75441912-32da-4100-bbb0-ad3f105c2a64	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:06.474988-05
a4fc4c9d-bd3a-4d22-ae82-b895edab2654	29f0ff7e-40c5-44d5-8ddf-57340604f094	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:26:06.804469-05
a0edd325-bf44-4ae1-b6fe-baffedbc7d9a	b8fbd0ad-2489-475a-af96-d5d7d77ab510	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:26:07.134164-05
47ae59ce-15ac-460c-8acf-b519225699bf	2b58c422-40e9-46c9-88b5-7806cd1367aa	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:26:07.469051-05
6d1bfc49-6d31-4f8d-a2b9-d4b764883ded	12082507-f379-40fb-8bd5-3bd73333c097	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:07.800944-05
42d824d9-b03c-4f6a-a2f1-1cf7745ce1f6	294f16c0-7ec5-442e-800a-93fbd75a5af6	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:08.130244-05
e828a565-ebde-4705-90fc-677354563865	e53acc81-302b-4763-8aa3-670b1b8f93eb	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:08.462014-05
d3a8bf1f-8625-417d-a666-fe31a5aad339	721d37f4-4f3b-4e85-91c7-a9edb10d4275	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:08.792842-05
84634991-c045-491a-b78f-a0baaf85930d	72f326a3-4130-4a93-a0a3-d5857c13adb8	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:26:09.116291-05
6c1d2b07-d27b-431b-b14e-170711ecae19	6923b570-cf40-406c-8f67-fe549fc9b479	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:26:09.4397-05
d4c79095-cc8b-4e3b-bd32-a4167d16a855	2b81b5b5-42d7-4fc0-87e2-57eb8ec983df	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:26:09.759705-05
0ee8bb16-494c-4edb-803f-4424491a19fe	fc3e0c12-4156-4305-aa36-16cda070d052	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:26:10.080455-05
84161a3f-8104-4011-998c-a77469c7f9ef	05784877-22cd-409e-b71b-ecdd1b978c22	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:26:10.407033-05
5a52f7d8-1948-4a91-8a37-be55a0938ae4	e2f5489e-bf15-43d4-89c2-8310d1f4c089	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:26:10.737494-05
3574f973-6564-4d64-9078-c1cb9e930c2e	ca41fc7d-689b-4e7c-b2c9-fffaa5f996d1	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:26:11.072463-05
d8cce738-7f36-4155-ae46-4c18e5c39267	dcd56ff4-1604-4740-8f4f-3345e4037509	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:25:43.226996-05
30180177-a5a8-4701-8b92-3e4be27eb14e	6d50d2f6-484f-47e8-bb28-03142b60cafc	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:25:43.486051-05
061081bc-4ee4-4fee-9214-a60fea44f214	3bf10694-5efe-4364-97bd-d4429ddf74a0	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:25:43.737738-05
3aef04f3-4d58-472b-84fa-7f21d706206c	c6d7ef9f-c5e1-4303-87c7-767fa28128f7	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:25:43.988225-05
0ae56857-b826-4cd2-b52c-984685e3062d	f80b87a6-928d-4e41-b808-754786346820	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:25:44.235143-05
8eb76be6-6a76-41e5-b312-1e3bce21863c	df173dcf-0d71-40c4-91f7-6529fbf75f69	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:25:44.485367-05
ba4a0f14-bc3a-4205-9bbb-620720ddc361	ef66dc1a-3955-4057-b0dc-9b47557e54d5	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:25:44.740584-05
c5160099-cc30-4400-b2ab-ad3da07fc904	8d4ca5be-6183-4c88-8b95-883c65abcd4f	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:25:45.00247-05
6334e236-0cd6-49e8-8d48-c6fd91dc1768	dabb0617-2fa1-4138-b4e2-60098b1ffe98	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:45.25615-05
c952582b-c280-4974-ac35-d684d8ae9d82	bf8f94b5-cd92-42a1-a07c-27a3a45ff29f	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:25:45.51647-05
c5b9059c-e126-42e0-8f3e-2467a37f5d63	f2413e92-f0b2-4ba9-87c0-23375b71f866	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:25:45.790825-05
6985a523-0383-4bcf-b080-61cea7cf21d5	1abcc8f4-444e-4bbd-b9d5-d2dade9c145d	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:25:46.050167-05
f2fe34d9-4537-4655-9960-540d0bc0c143	f0118d4d-9c22-4a51-be6b-50179d2a6ba5	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:25:46.305792-05
3faf8464-1f80-426f-9a91-66cae04ca421	34baa176-7004-42cd-80c1-42020dd9ea4c	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:25:46.571175-05
c20ac364-2bb2-4249-a104-f8081af216e9	6c71f76c-5c27-44de-be5e-934eefa30efb	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:25:46.829988-05
6bc65884-6bd6-4341-83ea-f41c1d27e6e4	78eae549-4812-4cae-9873-e40f0bc72e7e	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:25:47.084863-05
39df7c02-a259-4e2d-961b-418c570b9210	fa2acac4-b976-47a3-a865-3a433f1dc1d2	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:25:47.35076-05
b04552c9-d6be-4f34-9417-85c7694d72d3	e152bc18-a24a-4e54-9b9b-b2921b9e45b4	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:25:47.609323-05
1675396f-d6ee-4cb0-a19b-264f279321c3	4a352c60-b58c-456e-9daa-6ae541a23553	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:25:47.86892-05
24ac50c5-59f1-449c-b742-a1b145e24bcc	36dde3d1-163f-4933-bf72-0e8e796d3447	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:25:48.131704-05
26daaa0e-ec18-4e76-bd96-c8cf1c3aa584	94e50d42-b39c-4b45-81bd-6165803d393e	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:25:48.390003-05
16ba1637-43db-4ffc-939e-33060f592fba	ef712527-1413-4bf9-80e0-4bb1c7cd0fbc	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:48.637809-05
0b3c4027-2ac1-4b4b-be28-5aae37aa2b0b	5a27e976-dc41-428e-93c5-cb4e9590dc34	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:25:48.886857-05
8b7b0d2e-2ede-4601-92ab-a1446080de32	733d727c-87e8-4247-9f6d-afabb8c2f6e0	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:49.137527-05
89059e09-24ab-43ae-9b25-91b6f15fa296	24bc7f08-db39-4af7-81df-d0dfe1f39953	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:49.389083-05
bcb22b0e-5efe-42f9-b3ae-313510ae41a0	2c173167-eda2-4895-95db-4c1e1b110fdc	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:25:49.639373-05
5a6cef7d-b338-42c7-aa45-09dd4da5bc9e	ae30dd4c-f27a-472f-b5da-f54b1a1190d3	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:25:49.885809-05
2ae905ab-ca3c-4aad-8235-a74f45029268	026788d6-76db-43b2-b825-31a4f9925834	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:50.136606-05
2f5518bb-69f3-44b5-b781-6c4a426c235a	f06a97bc-76e8-4887-b7a6-be8c8920a7d1	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:25:55.27114-05
810ff82e-c71d-4b5f-97c6-92b0be091726	9a94dde5-b764-42e2-aaab-70d3d48f9083	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:25:55.594655-05
7ce1478b-2762-48ba-9d81-69f0e34afeaf	8a647610-a7fd-41f4-83d9-ebfcbfc44fbb	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:55.91669-05
56cc5b2a-0a29-42af-8961-69554094f3f2	77afc866-7404-4048-be29-50e776203a6c	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:25:56.238957-05
6d22096b-3415-42c3-976a-9f4ac041b45d	c5664e3c-37dc-46e1-97b4-a3b06797cf62	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:25:56.558125-05
2fb6d3a9-e9d0-457b-9f0f-bacea9d028cc	540dc10d-4b08-49d4-af4a-b23daaa8f7ab	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:56.874454-05
63c2bae7-34b3-46f7-820f-301034c38c61	bc58b33d-3a60-48e2-89e4-53e286d38683	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:57.190508-05
92e1ee52-28ec-4db7-85a3-db7b91abceb2	3435d383-e1e6-49aa-b40c-772e0fa06a7f	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:25:57.507385-05
e4e25e7d-d6d3-4283-bb95-76525c9b4ca6	df857904-9e73-4ffa-beb1-ad3e17b25825	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:57.824061-05
109741fb-63db-48de-9aaa-443d7f1eec51	1907047b-9319-4d99-bdd5-e1cff6b4b072	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:58.139595-05
81460c27-0f2a-4e08-bad2-ecea3de19467	b0321c73-1559-4cab-b93d-ef590373e65f	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:25:58.458798-05
a9b8bfc2-b154-4b21-9eb6-594d86a9a030	9bea6f88-26cc-47a6-ab78-cb38894822ef	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:58.774442-05
5cf9c087-5162-4225-bd0e-1f8acc32376e	f9e36a9f-b372-4d42-b420-8f9f6a6d53cd	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:25:59.093465-05
0cdc0da5-8957-42ab-8f20-bf2608847b32	02d925a0-2ae8-41dc-91d9-c91b046b302a	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:25:59.412129-05
a5b12c2d-17e4-448b-b325-53e1460d56cf	1ee97635-ecf5-430b-8a1d-19b5764e9df2	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:25:59.731658-05
e9eff4a6-cb47-4b5e-bdc0-bb8c2267d373	fa1e439d-f7de-4d96-ae59-ec3f4e86a7c4	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:26:00.057088-05
6ce68818-9fc3-4133-9218-4d30ef2cd121	a8b3683a-a6f9-4a47-a3e8-29fd24fa65e3	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:26:00.381276-05
78a2b969-af8a-48e7-a260-2d1145404253	c17f5622-d2df-4367-8dbd-d44aaa06273d	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:26:00.710263-05
2d140b61-fe1b-4813-8184-dd5a185551a1	f5ab3892-3d9a-4e2b-8cbd-458c83fdff4b	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:26:01.036441-05
7007342f-7a7c-4140-9c86-50232d91d8c2	2b0fcfca-4a06-4e03-a3df-381169012e73	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:26:01.359656-05
b0f33d1a-0b4a-4652-8f17-1261b5d247af	726577ba-bda6-4896-8d44-7c8193ca9ccf	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:26:01.688581-05
5611cc08-08b9-4f01-b386-0a28f4944242	f1dada37-a4e5-4f50-b6b5-cbcdf0846047	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:26:02.037111-05
508fc925-3ad9-4439-9f2e-fa0710e3852a	bee14904-38af-4255-8bcb-b5b8e5bf2516	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:26:02.367246-05
59198189-c25d-4d67-a2f8-db051536ba00	c19cec3c-f5f5-41b9-a2af-632a772af984	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:26:02.695438-05
a4edce64-5c27-4950-ba40-b041326f7a0a	a43bbd16-71ee-4d52-ac9b-e6a052d85936	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:26:03.020102-05
433403a0-c8da-46f0-af65-47d8275b8996	734795aa-fc41-4882-b1e7-0379b0ba6883	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:26:03.348459-05
3d2f40ee-a30a-44c0-8d38-1eabbe8fd27a	e9174f1f-6cac-4090-b0d7-2656d4819a60	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:26:03.678894-05
8cf0ef75-d812-40ea-a5c9-e5c38da677af	9a1593d8-41cd-421c-93a1-d31348741041	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:26:04.005081-05
19331947-a494-4efe-bf88-6ba781e4dbc2	f04c7270-c1fa-4487-a0e6-0ff980835451	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:26:04.329346-05
68207c26-59bd-4149-aaa2-8e238e50af95	c9bd5d5d-2113-44cb-8402-4ca63810d346	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:26:04.654456-05
1891470e-2599-4281-865a-86d0858fee10	c3305604-5593-4b5e-84e7-f4455d5083f3	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:26:04.981402-05
b0196774-61d1-4e69-9604-befcfd5e38b3	a3888f38-1c07-4374-98fd-69274762addb	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:26:05.306783-05
ca46af41-ccdd-4cd5-84c6-73a4fa39c0b0	d0bdf218-8cf3-4930-98af-266649091444	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:26:05.640104-05
3d819323-bec6-4173-abd1-ebbf620c23dc	49aaffaa-d125-4429-b9a6-7c5025324618	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:05.980024-05
0fb7252d-f0f9-4a43-8e82-4dcf4b388f92	7e7592e9-c21e-452e-8859-71afa7ba8ce0	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:26:06.312153-05
d26024ac-0a26-4973-8539-dff627a1f8fc	05114f2f-e189-49ef-a251-e740f4a6ff07	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:26:06.640877-05
88f7c8f1-8b8d-411f-83f4-f2c2bd69e8b1	bb8883ae-bb00-47eb-96a8-82b9537db6b0	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:06.9712-05
74e07cd4-7bbe-448d-8fbb-1e5eb1eb39ff	531884ce-5d5b-47fe-86f3-9a320a04203c	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:26:07.296603-05
0f6453f7-c793-4de3-9b36-0bd7c2325a6b	d052de6a-be0f-4815-9f56-8d5bd69e5f2e	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:07.635951-05
d96bc75d-0677-43f9-9bed-ed2af92842f6	0bb46acb-4a6f-4f56-a071-850cc1612e56	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:07.965074-05
e4051ff9-c8bf-4f64-8eff-f36d97e200dd	e20b9ea4-0a97-42dd-9caa-62dffc758344	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:08.294462-05
b03fb0c0-567d-4e83-ab0d-e94ca799ff35	2c758dcc-0969-4171-8fc0-bb55d7252f76	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:08.629714-05
06cf8f00-f7e0-4908-b56b-2defa7220e45	c494d668-0da3-4c33-a17f-1b5b5e2301bc	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:26:08.954545-05
a166d684-281a-429e-baa6-3114cd6e3e1d	873cbfd2-d247-47f0-a8fc-19a139a7f158	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:26:09.278079-05
b249b27c-d193-4c63-b9a6-d903cac2929d	289e3869-f9b9-4d56-8ac3-ae7acfee3a44	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:26:09.599607-05
24ea948c-2cb6-4ed0-83c7-a37f4c16b7ed	c939a7e9-00a6-431b-a85b-d439a436a316	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:26:09.919543-05
296a7ece-6260-4e19-926c-9eefbabdc4ac	4488bd8c-309d-460a-b91f-352bba181eda	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:26:10.243394-05
d69f1a90-08a5-4639-8aa9-d7597b67b55a	1e48b713-25c6-4638-ae7f-021e46a69753	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:26:10.571593-05
e667a784-b58c-4426-af8b-5a2bbcbdb3d6	16636ccf-8a68-400b-9275-b64a496aa03d	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:26:10.904385-05
2f4802b7-7c94-4ee2-82bb-5d957e09a6a7	95822fb7-a49c-4247-b8bf-eb921817e8d9	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:26:11.241283-05
\.


--
-- TOC entry 5213 (class 0 OID 162068)
-- Dependencies: 238
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, school_id, name, birth_date, grade, group_name, parent_id, created_at) FROM stdin;
\.


--
-- TOC entry 5210 (class 0 OID 161997)
-- Dependencies: 235
-- Data for Name: subject_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subject_assignments (id, specialty_id, area_id, subject_id, grade_level_id, group_id, created_at, status, "SchoolId") FROM stdin;
2b1f91be-7564-434e-99f6-aa0f8830c00e	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f1b521e1-df02-4ec5-b28d-e103f81cacb9	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:13.550173-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e9ba726c-dab2-4e52-be7f-e76537f42cb3	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f1b521e1-df02-4ec5-b28d-e103f81cacb9	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:13.691296-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
080dda56-722c-4c9a-9cc3-453c323853d5	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	f1b521e1-df02-4ec5-b28d-e103f81cacb9	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:13.72513-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
58f6dc84-83ec-471d-b09d-653415e72845	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5284e53e-8811-4b2f-b304-24d6492870b1	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:13.756783-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f4b4c8d5-056c-42b3-a5e5-f0b39a770a56	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	42770ffd-bf79-4cac-98e1-052dee724cbd	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:13.78758-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ef632922-23d7-4d84-9e40-81d811b5bc42	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:13.817842-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a60fe78f-0d96-4c51-a1a1-41b42a63f06d	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:13.847928-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0d89fa1e-0eb1-4082-a599-04048942e9cf	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:13.878843-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fdef0134-19a7-4e9a-89c8-41887b502768	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:13.910812-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
297909d1-d7c8-4bd3-9a35-ae4230752450	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:13.942097-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c9e1296e-6fca-43a8-87c5-a410587f1570	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:13.97423-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a1bafaa3-70c5-421a-919b-5c58ce108dce	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:14.00483-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8e0a1015-4952-48e9-8964-4ec12b30f3e6	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:14.033745-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a131e824-5051-417d-a37b-82efead8be8c	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:14.064243-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
cb08a7c1-53b9-4a1c-a35b-58e21b88472a	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:14.094406-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
97a36df5-7d37-475f-af6c-b474dd7e3cda	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:14.153623-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bb4b8bb4-4647-490d-b67c-432348f0d958	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:14.181523-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b9f02c01-f8b5-4edc-a251-8d7a34fd38e5	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:14.210254-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3f360570-5458-47ce-a8d4-0b8bcd1cde7b	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.239703-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
065fe022-9a63-47e8-b7b4-bd97abeee4d4	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:14.26992-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
350fa1e5-bcf4-41f7-9007-45ab209b3a69	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	d401c0d5-ffab-420d-998d-9a2481987504	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:14.298969-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bbe404e8-a748-4a03-92d9-56368a88b26f	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.330409-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3a1b93ed-1e06-4719-960e-29d0874971e2	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:14.360167-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b7b8058b-be6b-4e0b-8c4b-2bc26f611907	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.389669-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
82d0810a-2913-4ba8-b095-8a0d9aeab380	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:14.419022-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
664f7a58-8ed3-4efb-af71-ecf9d9d62f55	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:14.448556-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
68566982-11de-41ec-897d-5aea4fbaffe1	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.479664-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6cb3698e-f0cd-45b8-a643-1c6dfce93a58	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	1f1f3eb3-e4f2-4a0b-acfe-09a2c3cd738f	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:14.510965-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2103658c-e60d-4eaf-9e0a-f94df24171d2	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	57d84811-b6cb-4d0c-a15f-cc383fd50ad9	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:14.543265-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c90a89eb-f9db-454e-83d5-9caeafb13378	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	67f8d492-c674-4c93-8c52-0d798dbb6c8a	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:14.575505-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
07a167bb-67c0-46e0-a231-b6bf6804136e	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e6f9ab75-8d52-40b2-b203-396309375106	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:14.60829-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2d591682-c1f5-451b-9b85-14c5e7cd5131	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e6f9ab75-8d52-40b2-b203-396309375106	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:14.639101-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2b262289-883d-4662-a53a-1676ba8f56c7	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.669127-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
758b0c4e-f33f-497c-b277-56df8f3d7e08	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.700132-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
116aa1f2-0523-4864-b0a6-46f0a07e95ae	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.730575-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ac6e3163-3a80-4436-87e7-57dd0016ab95	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.762416-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
aacb35dd-94ac-4d89-903d-46f64d93d92b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.795808-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3383f4ed-ede9-4d9b-9964-8fe2ebd63491	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.827808-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1c821caf-3f7d-4ec7-981d-b14ce1a6b8e2	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.858893-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fda96941-b18a-4e90-a552-05e305d75ccf	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.8906-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9ef203ea-eba2-4c60-bab0-963535d3f605	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	aed4e961-0736-4ae2-a814-4f1191055dc4	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:14.922198-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e91ee09b-c329-4773-b2c3-81085dc4d945	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:14.953067-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
996fbe8e-dad2-4b6d-a123-34b4ff9f50bc	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:14.984107-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4133b27d-6112-4d23-8549-09512a294a4d	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:15.015245-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a58d7b1f-bb8b-404f-a3bf-b42e1d030ea4	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:15.047123-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6932028a-31bc-4bdc-b88a-e93fdd885505	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:15.07816-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0e59d647-0bb2-4dc8-a8b3-dbfbc9112704	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:15.110379-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
77eaa46f-c6ff-4050-b3ad-60207971c8d4	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:15.148516-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bc496d37-1d82-478a-8b41-87f185677bcc	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:15.180702-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
169e1ab7-4002-4dea-afc2-75adebb9a219	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:15.212845-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f23b4c59-d9de-40a1-9be8-bf6cf2d2ab88	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:15.246315-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
50b1cc5c-dcfe-401d-b0d6-900355fd35da	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	49534204-c5e6-4fca-b0d4-5713f849c8b0	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:15.277899-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8c8dca62-8238-45b0-8f41-3c69364bb706	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.312206-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2ab00563-89ae-4695-93dd-dc0ed11f2a7c	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.347233-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bbab2a3a-5ee2-4e7f-8ae6-11d4e06a56ab	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.38954-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
24b863b7-bea2-49d9-8db4-fb20c48ecacb	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.432293-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
98bf64d2-e993-4504-9064-ad605b8d1b5e	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.476644-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
724115ab-bcc3-4c88-ab67-346ce9e54475	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	76fca87e-f52c-4560-9012-82d5a529290b	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.508871-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
75114420-6cc6-4497-9226-92dc27090876	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.540639-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a334f116-f559-4e48-a78b-4f0c5922406a	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.571471-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7fe16772-72d9-4da3-ae6a-518bc0c89604	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:15.602862-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c782966e-5943-45a8-9d2c-8830216aa9b0	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:15.63425-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
86e76a44-4195-4316-b88b-65976c9568a9	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:15.668196-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
52b3cf90-64f5-426f-aeaa-b312e29abc94	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:15.702729-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
31977d0d-b653-4222-a40d-e536df5a3fd9	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:15.736158-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
427a3b78-94c5-42fd-9b2f-7a18f7d0d2b2	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:15.767015-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0656ecdf-fac9-42d0-b3fa-2aac1abd3fba	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:15.797071-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c4649c8f-ae36-44d5-a171-47b99afdf30d	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:15.828738-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
30ed73d0-25b4-4467-b872-ba942d00978f	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:15.860148-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
81ffa9ba-c5d8-4a58-8b1f-57e025a6e498	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:15.893258-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
30605b6a-0ad3-4c78-899b-7f1d5f1a51a5	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:15.924909-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ab024015-c720-4ca3-9c3b-a5bae376f52f	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:15.95624-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2757a7b4-3543-4ac9-be50-88a27be7f556	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:15.986924-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2f446485-4d52-4f5f-8228-b7c1aa8193d3	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:16.018125-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
95040940-173c-45d6-8ae2-0670a138a631	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:16.04911-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6d2f66e5-dfda-4b19-8707-176f70c40d88	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:16.079878-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c60c5c6d-0e58-4be3-b7a2-dcb868388dda	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:16.114065-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5f2789a2-b699-485d-be69-2b148221c162	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	9534c386-747b-46c6-8b12-044a4270e51f	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:16.144841-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a2c16526-b0af-4aca-b6f9-2a391ba59903	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d138c98d-3b6c-4895-ade4-ef681d169259	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:16.175955-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1e54e08a-52f6-4569-be43-b2916c8dbe8e	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d138c98d-3b6c-4895-ade4-ef681d169259	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:16.207473-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
858943b4-9135-4d40-90f0-0c117d28f234	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2f4c2bf7-f466-4a57-b869-6b2238c5fc39	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:16.240665-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f6250a1f-8ef2-4418-b7c9-e69ce8dcb31b	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2f4c2bf7-f466-4a57-b869-6b2238c5fc39	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:16.273467-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d674a5fd-58ce-407a-9194-dc70e52d834a	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c90ca72b-1bbd-4b76-a717-eab0d06c0e37	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:16.306908-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e8f2bea7-63b3-4ee0-8982-d1071d5e8502	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:16.341406-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5df0dd0c-ed4d-4f6e-bd50-379474c6437b	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:16.372688-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a0ccbe07-b7e1-46b3-a78d-220c592f7785	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:16.404307-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
329b2b9a-5099-496e-8965-0df6b151af6f	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:16.435578-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2542a1f0-4f29-42d6-b172-c5e26748b36c	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:16.467386-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fb1092e4-d05b-43dd-8335-c91bb86e74c0	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:16.500995-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1b980f4c-b7e3-4c18-8664-60d92b2a8e76	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:16.532135-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
22c3e84d-51f7-40f6-80a0-bd18b6b566ee	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:16.565953-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
77503836-7230-4f86-aab1-cb0a4cfc8a03	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3b701f10-0870-4e7e-a74d-ce0f9bf08e35	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:16.59721-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
484e7fc0-665d-40c0-a47d-1c9e5b7cfc4a	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	23200364-de2b-4792-bbfa-f54ef3267cbe	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:16.628643-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1189407f-0acc-4f3b-aa90-c69774043aa6	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	85472c7c-8d9c-479c-b24b-79f30ea4feee	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:16.659816-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d846a268-7a5d-42d6-a093-7e66c3d8b827	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	85472c7c-8d9c-479c-b24b-79f30ea4feee	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:16.691988-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1a29e2e9-e7cb-4bdb-a447-e3916f9851f4	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	85472c7c-8d9c-479c-b24b-79f30ea4feee	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:16.72378-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5f8aec4a-f037-482e-8327-4591aa195b24	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	20cca1c9-20d5-4c33-9a69-bc959f4ec2e5	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:16.755992-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d3e7fb02-93ad-44f5-a75e-06a398646e08	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5b8120a1-af76-44d4-85bf-e6e40bf1e7be	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:16.78988-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9501ae32-d25b-4ff7-82d7-df8b7aef50ba	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5b8120a1-af76-44d4-85bf-e6e40bf1e7be	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:16.823273-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b4df002b-49ce-44d1-9b72-4548d7f8a86b	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:16.855674-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
17fee35c-b226-473d-9ea2-ac446b499bbe	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:16.888297-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d5d6931f-42b6-407b-86a6-e7b2d9636ad3	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:16.921993-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2234cef8-a9e5-48de-a7cd-8252df090dbc	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:16.956735-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
97f73d90-4641-427c-892e-870dea183caa	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	66f2da44-2f53-4e2b-8c1e-e267aeca040e	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:16.990353-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a2690f74-9e5f-40b3-8080-23bfe1b65f5e	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	aa920dbb-9a34-488c-a450-319c3be369e6	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:17.026953-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2b386d86-2ebc-4337-a05a-8021c1447ae0	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c2e2f56f-09f3-47f1-99f3-041f017bf8ed	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:17.05942-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
04df3267-4b48-4230-b3a0-b4df3d682996	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c2e2f56f-09f3-47f1-99f3-041f017bf8ed	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:17.091245-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a023cda6-02ed-432e-ad88-cf4da3087f39	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3018ef5a-b1f2-415f-ba71-1de0f1218d1f	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:17.121856-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
20157008-d821-4e91-b30d-e0add5963185	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	75e38d3b-93c3-4a42-abd8-4d07df71f808	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:17.152598-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c15f2327-49d1-4fe5-bddc-abc7f17e4e55	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.186391-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d370bd5e-bd3b-4c1d-8cd0-0c61eb5dc05b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.218711-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
71e72f7a-7bdd-4c7e-a386-862e64ba2459	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.252774-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e58c1af1-b33c-4177-897c-197c9db1499a	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.284363-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f185410e-1a22-4b9a-a999-55df6b398779	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.315677-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d9bdba8d-d4b6-4e09-ba4e-07c8a861940e	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.347894-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
eb63f599-2f0f-4afc-91d5-3f2255a3b0a3	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.377464-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f91477d5-f52b-40aa-858c-1d4e96cec00b	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.410787-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bc8dc232-83d8-471f-96a2-cb68ccef85cd	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	84d19712-cb74-4115-ae56-9b62f129cf12	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.443098-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d3cc680e-c00a-473e-bf65-49fdf7f07f33	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.475376-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b69fe77a-c10d-40e1-ab87-ea867608b4f2	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:17.506001-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f3ee82b8-83b2-413f-b0a9-88ac9186272c	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:17.536615-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
750e7760-51ef-4e73-ac9e-610a322a2423	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:17.567679-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4e961bf1-2e7e-4339-a2ac-6b6e9db763ed	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:17.598389-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7d1f24bd-e27c-43f6-b65d-7c9c78577f9b	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:17.627581-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
83ea3dc1-40d7-4d9b-b3ec-f836c1329901	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:17.658152-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8575d63f-f9b8-494f-b127-6b0cb8ca61ae	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:17.691468-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
99ef66f2-6cce-4cff-ad6e-9684409c003b	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:17.723857-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2a3f1525-a0d5-459e-a84a-dde27bc9c9d1	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:17.756396-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7c729acc-d848-4ec0-a04f-ff407bf4a102	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:17.787337-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
be8fbdb4-f10b-4d91-a544-4fb821c23f7f	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:17.819676-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ff3fbc8b-c3cf-402e-b70d-8c18a1539eb6	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:17.851493-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
52826b53-d762-422b-a07e-960119744f39	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:17.883662-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
37035d04-621f-4865-b867-9c2e14609728	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:17.917433-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
78be2970-daa5-496e-b47c-60251fae5832	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:17.95183-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c63596ba-9391-40f6-88fd-26a66866a7d6	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:17.98589-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
18637f82-275c-4cc4-9b57-ca4066bbfd30	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:18.0202-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
453a3207-f5f0-4b3b-8c0d-33e19eca3219	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:18.054016-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f7210485-e225-4330-89a3-523c52568741	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:18.08769-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
aef05242-2832-486e-a8d9-e2b019a1a90b	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:18.12232-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5b4245b0-4dcb-4607-920c-3498a9d0f42d	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:18.158318-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
df3a1ea5-f50f-44f0-95fa-acfdf35c9978	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:18.191607-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
17022f21-a8f7-43b4-a212-2593f37d2f2f	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:18.225593-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7a4c292a-430f-402d-aec5-082a720c0c4b	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:18.260342-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6d047e03-65b8-4b85-96c8-d5aa16a87a5b	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:18.293888-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6992254c-00de-4c1e-a650-a453fe4e7a65	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:18.328095-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c099416b-4216-4672-8613-74ee2388ea05	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:18.364304-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f716d565-8c19-47b8-b8d6-c5bb4cf9ee53	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:18.398231-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6a0bc977-c885-425a-b885-e6b200bf6ab7	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:18.432503-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8abfee00-3c90-4c40-8847-34498396ad4d	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	e0cc7f4e-6b02-4596-b26b-ed11cfa047b3	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:18.467298-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ca0b2c28-10a6-443b-bdf4-c27d2345effb	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	a11fff06-3bcc-4665-b622-9cf8df2f0630	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:18.502571-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
48ab0975-4589-4fa9-bbb8-c1e19fb5513f	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f6327a69-73bb-4f20-8c90-85126c1759ed	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:18.53816-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
192eb128-c74a-4e86-b3b5-57919f211fc0	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f6327a69-73bb-4f20-8c90-85126c1759ed	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:18.574396-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
572de111-c412-4f96-b451-4dc3c5c5972e	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.612343-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3f5578fd-5dd0-407b-a779-b8ab520e8267	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.650684-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ad4a30fb-a418-4868-91e7-b67765c27ee5	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.688847-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
955b3d08-a226-405e-9860-2fd4ca3d3e0d	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.726921-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f263d85b-f09d-4101-96c7-79742c58a0b9	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.765205-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a0d85577-7024-4fe7-af74-ea2dc5300818	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.804222-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
74d56928-43ee-4706-ad34-29d99e3fa308	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.84048-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c82bb153-aae8-4e03-a5be-a46a05de6f63	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.878122-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dc255d01-c6b8-43a8-8214-260c839067a3	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	09e8097e-64b0-4aa0-9375-1dc512350751	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.916434-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7a63653c-774c-4e0d-b4ad-e118194ea964	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:18.954702-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0311aef1-c006-499c-8332-829e10d18a93	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:18.993643-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f83f78fc-78c3-4d49-a7e3-2993ca16bef0	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:19.035002-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2f073123-49a5-444c-a4f5-10cf0dd1a447	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:19.07493-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d87975de-8dbd-4c9b-aa10-ffb145b218a1	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:19.110097-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1c2d03b9-c107-4125-9f30-171387d1ea68	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:19.145695-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0af80ae7-90a8-491a-aaff-3b4cd6200254	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:19.182622-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
575b748e-dfd9-4c54-a211-e54dc68b6af6	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:19.221005-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2e187ab4-cce0-48f3-9a8c-bd01e76535da	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:19.260433-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5b77cc89-db4d-4380-8943-52c2210daac6	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:19.300553-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c0fe9535-f9f7-438a-b0b4-0abc71fd1387	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:19.337623-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
939fa081-8916-47b9-85f9-78fcd6332162	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:19.376037-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
166e65ca-254b-4aa1-a754-879075718f35	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:19.41479-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2dccd4e5-bffd-43c4-8d25-9cff7d4be661	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:19.456605-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
46d9722e-9c11-4990-b304-f77e255c23ff	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:19.495611-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5ea7e561-151c-4dc9-ae0a-b6fada2edb57	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:19.535784-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8941af7b-9193-449a-80ab-2ae762684104	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:19.575527-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
255e9541-b2dc-4de6-bd18-2c99758ac67c	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:19.613952-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e54c343d-ddc1-4b56-b61e-a4437d62a62b	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:19.653808-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2376468b-4c7a-4f12-8d8c-3b76b1975f94	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:19.69367-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8e6603d4-0a00-4cbe-80cf-244ba2e91af6	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:19.73293-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f1d660ae-5059-4d75-81fd-ea69f9ea8271	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:19.772198-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
814ebc8d-6323-4aea-9351-c960e5945c10	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:19.811948-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
04af2478-6667-4bdb-b86a-5a15daf730e6	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:19.851189-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4216bda9-45e2-4ed4-9f0e-e5d6b0a02aa3	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:19.891325-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
668df943-a262-4475-bc20-03af59944753	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:19.9309-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
414e591c-b641-498a-afef-487de6b752f8	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:19.969168-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8d379166-86d7-4ed1-87c7-cd0df0716e04	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:20.00819-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dd527ce7-e856-4c88-b7a7-86dae0d07987	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:20.04812-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2324d6b9-7fa9-4dc6-bfdb-581e6e12bdc0	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:20.090178-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e831df20-864d-435b-ba73-033167293e5b	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:20.131579-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4ec0bf50-d932-4a1e-aa95-5fce4d2920fe	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:20.170458-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5da57955-7255-48b4-8d72-82f8673c5710	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:20.206705-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f0584361-4642-4340-99df-9a9c17200d3a	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:20.240269-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9b6c9669-3d61-413c-9be4-ce96759a16a8	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:20.273127-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1a9e4a60-fdac-43d1-b4ef-a250ee6f56fd	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:20.307242-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ece04a6f-9175-4e25-9b06-c1bab6f6e1f4	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:20.343672-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
81a3d460-2c0f-4ddd-b7a3-f0554d265a2e	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:20.380107-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a5fc20f6-5544-4702-a1a2-ef5ba0844a76	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:20.41532-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9959fac1-e157-47c6-a0b2-719c3f4256fd	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:20.452351-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
09f8c10d-93d5-4bd9-bb0f-0d72f0663373	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:20.489277-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e2a90198-0ce2-4be1-aa81-e59b4a770c24	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:20.527843-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e51da69e-cc9a-42bd-b10e-e8eb7f27bf6b	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:20.577262-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
13c3d512-832c-4dd7-a4b3-2aaf93103e82	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:20.610238-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1bb85d56-d7e0-476b-b40d-6b121be2add8	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1c2b742-2e0b-412f-a026-ea090c7fa15e	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:20.642648-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e38f1916-b301-4c0f-ba65-a0483f6c7e13	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:20.674853-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
54a9d6b9-416e-468a-958a-02aaad55be83	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:20.707553-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
348f75e9-0f86-4cb4-8b3d-e16d6f0c9541	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:20.74037-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c73f6323-76dd-462e-ae9a-08639cccfa95	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:20.776693-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a5d96562-b843-4b89-88a9-6548214a95b8	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:20.812327-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5e1e0937-d023-4fcd-ba18-d660e84595f8	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:20.848497-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
97340b89-4e95-4f92-a462-906f437dca04	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:20.887518-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
58524007-f56f-4c70-aba1-2468a4e4d2af	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:20.924334-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
04e711b4-5ad6-4f47-b1cd-54ed0e221ffa	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:20.960363-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
16c3c190-3bda-4538-a19b-cac318f95918	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:20.999606-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0460628b-baa9-437f-9668-12a5db1da8f3	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:21.038191-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9970b99e-c3fb-4f49-bed4-96536312aa22	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:21.076755-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bf00008a-1d4a-4ec7-961f-39af960c69fa	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:21.115267-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c36bb1e2-95f8-4ec2-a28a-be63e08421c4	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:21.15515-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
76ae5d82-9eac-4d55-b628-7f95854ef671	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:21.194256-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dc64e052-1694-46b7-b2bd-0621fdbd771e	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:21.230895-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
64e6ab24-ff4a-49ab-848b-25324f198dc9	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:21.264749-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1b5ce06d-ec86-4db5-8e76-a80ba7c34d05	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:21.298012-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
54995089-7acf-43d1-a881-677f90fbe2e0	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:21.331393-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
01a8a3b2-a221-4156-aa8b-9820d82d376d	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:21.36492-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5e5df9a5-215e-43cf-bcca-055ec1fb3d16	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:21.397318-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
615d1f90-1405-4722-9ab4-bee261628471	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:21.433454-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bc22deb1-9169-41b3-8a3d-7a60a233f452	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:21.468556-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c72b7941-fddb-4470-81a8-8597deca8b00	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:21.502313-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b50a8078-804a-4814-ad0f-2be2eee3d809	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:21.535631-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ca041123-be78-42af-afea-e80e0c0eeb64	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:21.56935-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d35f4a2d-a441-4030-8db1-d2afa5eff3d3	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:21.602751-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2b976957-3995-4c79-bf40-efe5f93e725a	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:21.635339-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
914186a7-c01b-4b68-833d-873f360e1384	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:21.6724-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b631f171-8321-4e31-9d7d-03e823f4a797	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:21.70582-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8b492657-b6dd-4b2a-8340-19b446f70503	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2d37981d-051e-44e2-86d8-6600982d9d36	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:21.739701-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3f15eb49-739d-4ec7-8ba3-c28684e67652	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afa75117-2804-4650-b310-2c31a8f37732	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:21.774417-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
42f9ea6e-ed39-4181-aedb-75999858aeb5	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afa75117-2804-4650-b310-2c31a8f37732	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:21.808687-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
61beeb4b-6ec5-4b3a-acaa-a94024b94db2	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afa75117-2804-4650-b310-2c31a8f37732	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:21.843178-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
87d19377-4481-4540-9f87-f055ce4be80e	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	a71addca-33d4-4b8c-8eab-f510e2b08557	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:21.881854-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fdd93161-a4e5-40af-9900-7ee5b3bac2f6	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	45358765-1e9d-40d6-9f3f-4b13211ec7e0	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:21.917162-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
80a476d7-ec24-45d7-bcdc-e7f94878c57f	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	45358765-1e9d-40d6-9f3f-4b13211ec7e0	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:21.95115-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
80d2f969-28da-41f7-aa73-24b6a19970cc	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	9b10d056-636b-4780-9aaf-3180bfffcf8f	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:21.985299-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7b5f793e-41a4-4ab0-ae25-f466d923e1ec	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6450833e-a92a-4cc8-9eb0-188a4e9e41a9	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:22.019715-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
09513ff7-db96-46e0-b057-fb474e7e2e86	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6450833e-a92a-4cc8-9eb0-188a4e9e41a9	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:22.053531-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
358cc31b-8b5c-4b73-9021-d423af991696	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6c87424b-b8a6-44ff-94cd-c198380ff0fb	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:22.088439-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bd5ca865-a694-47c9-9267-770d0dd4b1a3	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6c87424b-b8a6-44ff-94cd-c198380ff0fb	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:22.122797-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d088eacd-3b9d-4047-a691-7a693c1a031f	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	6c87424b-b8a6-44ff-94cd-c198380ff0fb	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:22.156248-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2c0dc741-02ef-42b8-ade8-3235546ed78f	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	0130d83b-82d4-4a42-95dc-997d2e364570	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:22.188651-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
33203df8-1d03-42cb-8348-104e6853079c	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d13aa640-bc74-4187-a51f-fb8a0c779152	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:22.222477-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bdba6d4d-04af-407e-a1e8-0e1f7deacd32	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	345001d7-26f8-48fa-93e5-9ee9522a14ab	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:22.256494-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0b3a96db-0517-44bd-8f9f-c31c53fcdf1d	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:22.290932-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4a4f6d34-bac7-483b-9090-04fab639a8f9	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:22.327114-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
48f31ecd-5701-4cd4-bb01-96413e57615a	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:22.360741-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
94465cb8-54df-4f36-b044-fc1b2cf01694	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:22.395529-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5bbd6dfb-5be1-4a17-85d1-3b7002caa2e9	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:22.4299-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dce64c25-ae3e-46ca-a7ee-bb437c3c14f7	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:22.463507-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d0c4ba99-5a59-4ea5-960f-9920be9ac9e2	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:22.4974-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5f1b7c32-0a55-464e-8748-b53ad381f217	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:22.534237-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
af0ea423-7fef-4279-8177-69e219c2d5a1	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:22.569663-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
84fc3147-fe5b-4882-8fb8-3c12f3d92996	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:22.604614-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e970b304-a054-4575-9a94-2a68407668c4	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:22.640327-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a8e1ac64-b60c-4a14-baba-d4326ad947d1	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:22.67535-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
beb4804c-da3b-4dca-a3bb-771aae41a397	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:22.710395-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
46b0a9db-a4bf-4ee5-8e8c-2ca364e3cac6	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:22.747686-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
230aab12-88ab-4f27-84b7-8223c55869ae	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:22.784251-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c8eaf39f-ce4a-48ee-b8db-5468dd284ac0	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:22.820922-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e456db9b-281e-4765-95cb-c8f56f1a6586	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:22.857064-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d18e9118-86a6-499b-aa16-17482ed2333e	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:22.893662-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
cd0fe298-9999-4f31-809d-077dd8deee6f	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:22.931386-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c33d59fe-56e2-45e8-95ef-8655072de151	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:22.96949-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
df66db78-176c-4cf1-9d1c-659e246dd063	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:23.006275-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b6f4752a-aab4-4ece-8c73-590861569341	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	03d5d3cf-1634-4e02-becb-8adc869d1974	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:23.04196-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
52813795-fb4d-44e8-9c6c-ec4c7a2163ba	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	4d4fc0ca-a74d-438a-bf93-eb06fe3df5c0	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:23.077568-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9694c001-6978-4aaf-80c3-70c70dcaa846	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d910b7bc-b855-4d56-8d0d-85731c3ca991	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:23.113433-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1be5ff36-2a8d-4fda-a332-f9b575fa781f	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d910b7bc-b855-4d56-8d0d-85731c3ca991	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:23.151295-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e7c9a097-d315-486b-8ca6-33e2c7f50bbd	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.188016-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
84fe6d0f-86e0-488f-ac24-2d2977b7ee7d	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.225512-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
361ec132-6d95-44d5-ac15-12060fa10809	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.262612-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
78072deb-47e0-4b3f-afd8-33267ada511f	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.298802-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9169a99b-dd24-47d5-8292-04b2c3442b14	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.334135-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9b41fccb-0f50-4d65-b74e-08541b87a6d4	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.369904-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e9c11830-e03f-44e8-9a08-5e52552819b3	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.407897-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
86b72850-dc62-4503-9aba-97a42ece650c	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.447153-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e1bcb528-89d3-442b-9433-e473e162e5e4	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	90fc6128-49ee-4b8b-bab6-c34bb4bcd7cf	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:23.48412-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
161766c9-9d74-4dc1-bc04-c3001ce4957c	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	da56e8b4-8376-4664-8e64-5860d60507cb	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:23.522093-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bb1138bf-a13e-46c2-b490-dbb6a4939984	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c1e6d0ab-d7cf-4051-b388-b10c0b16f3c4	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:23.562802-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f0ad1b74-a73f-4a50-b583-a26eb7567bd9	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c1e6d0ab-d7cf-4051-b388-b10c0b16f3c4	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:23.602726-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2d94fe5a-ee8b-4690-a3c0-68350315f2df	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d9becc23-9506-41b6-bc0a-5e9e32b4030d	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:23.644379-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7ca7c72a-fd29-4cb4-b034-8ef3aa2a3f8c	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d9becc23-9506-41b6-bc0a-5e9e32b4030d	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:23.684644-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4659ac59-fb3a-48b2-ae0d-1a807ed38fa3	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c076b644-4f74-4322-8e66-3f3305572bba	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:23.72353-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5b4d537c-ad69-4013-bab2-6658c8dfec80	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e4ed7dd7-7823-430a-8641-12c19622aa93	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:23.762659-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8fcad82d-37d5-4056-9071-43a3ee908504	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e4ed7dd7-7823-430a-8641-12c19622aa93	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:23.800755-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1ca5c769-628d-4184-89d5-07a256e0bed5	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	95182a1b-c357-47d8-983e-930667540381	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:23.842597-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
93f8c5cf-f7af-445b-a411-adbc2eda0e46	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afb6a689-260d-45f9-ba33-a8b013dc4081	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:23.882237-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5ec5d4bc-527e-41d7-87f6-1012d6222858	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2aa9fd0b-d60d-49f3-93e7-ad5e90a1bb12	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:23.923539-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1c7dcd55-3b52-463a-8f4a-37d7a913f3a6	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c4955a5b-7cc7-4fa9-81ff-cc81c7534495	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:23.963334-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9eda16d5-f67e-4386-9766-67e65ce460b8	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c4955a5b-7cc7-4fa9-81ff-cc81c7534495	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:24.003148-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3d7cf6da-609a-421d-ad9b-e3f99c702a1c	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	457cb5a5-fd01-4220-85ba-a6b67074a6a2	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:24.044536-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1532da80-2b9d-4eaf-b2bd-f000f57b177a	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:24.080019-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a78af75b-ae5d-4d8d-b64f-5a4178e4127c	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:24.116799-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
066f5a63-5f69-4ed1-b772-be858a137af0	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:24.153798-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
66232d77-5f98-47e3-9fc7-436b1f9440ee	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:24.187838-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8a9dc6c5-03ad-4d3c-825c-0fbf3f308864	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:24.225975-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d9798c8b-7129-4885-82c6-2346f420f52a	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d760af45-ed1c-4ea1-bdd2-e96d2e1c254a	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:24.264759-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
cbc52195-5180-4157-937d-518e5d7d94da	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ff2ae947-169b-4191-8240-6f63a2aa26f4	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:24.303738-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
94bfd750-6623-46b5-97f5-17c3f3f5eb62	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ff2ae947-169b-4191-8240-6f63a2aa26f4	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:24.343126-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
af0f9f74-df1f-4ba7-a447-fba5255e66ab	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8b57cd3a-01bd-4997-9e3c-b5927bd67e6f	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:24.381762-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6f044be7-bf75-4381-a7fb-300aebe31a1a	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e919ef33-cb9c-4eb7-997f-c8271be8f2e7	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:24.419774-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
edd3cc7a-ae98-484d-b54a-8e742a70ea88	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f695ea4f-307c-4a67-a94e-7aad9c1daea0	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:24.458167-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
cd457442-a8e0-4acf-9848-1530260a331f	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c5d57eca-2406-49e5-943b-60a1c6777409	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:24.49849-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
412960c1-4614-4075-ad01-d03f63bf4b9e	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c5d57eca-2406-49e5-943b-60a1c6777409	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:24.538295-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a2fac925-7e55-43f4-b66e-d7429ed8ceab	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	cc84047b-214f-4726-9afb-b65e8578e8fc	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:24.578291-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
48f49051-3015-4a4f-a82a-0e610b7cddb5	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	41810c3e-1088-4103-8c64-5464d4c087e8	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:24.618416-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
aad5f793-223e-44c9-9939-6dda64672161	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8c32b128-5a24-4318-9875-eeff9f63a232	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:24.658764-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
36e1ac8c-f461-4b04-ab0c-72efac9ed905	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8c32b128-5a24-4318-9875-eeff9f63a232	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:24.700815-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e184c0b6-8700-41b3-a592-e6f2cdb45f38	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5b17b887-f077-4815-aec9-76ade7fc48e3	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:24.741051-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2fc4d38c-a8e4-4296-a4cf-0d55960f5ac5	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	5b17b887-f077-4815-aec9-76ade7fc48e3	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:24.782017-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f16fb17a-1300-4e61-bc67-f719f1bd0c81	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	4e79c543-fe6e-4cb3-a9e9-f8de2ab5edce	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:24.822074-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a15fac9d-0049-4642-a041-31d5e337f1fb	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	4e79c543-fe6e-4cb3-a9e9-f8de2ab5edce	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:24.865336-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ff2629cd-08c6-423a-9e25-cf7ee480258f	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	18cf4bd8-0c41-4853-b7f0-ab8045fa84d7	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:24.907787-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5022c904-1d64-421a-afb8-bff358eee18f	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d9026535-e315-4e7d-b865-590ad2ef02c4	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:24.949312-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
baf2471d-5775-4e51-bfea-c2900a78a612	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e30e3c89-f75a-4c26-bb8c-726a2d22026c	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:24.989265-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2b76e710-dd64-482b-a87f-7d60bf74e918	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	1d0005f9-241e-4c79-b8fe-b1b22d5a69e4	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:25.031639-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d9979d5d-830c-4baf-a7a1-ed8195734835	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3be08eb2-2963-40df-81a8-272bb1b87182	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:25.067135-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1be9b985-462b-4a1d-826f-fd4ca09924da	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	3be08eb2-2963-40df-81a8-272bb1b87182	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:25.101204-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
84fcac30-9eb2-455c-a8f0-6a5ed0af3b69	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	696df0e1-dcf8-4a88-b02c-cb2259b876ec	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:25.137067-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
eaf944ad-7e4f-49a4-ba2a-aea619701a30	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	696df0e1-dcf8-4a88-b02c-cb2259b876ec	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:25.171205-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3edac3fc-c094-4bae-8510-42c551dabb46	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e14efa35-1987-4cc3-b70e-06250f27f0d1	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:25.205145-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5ce45f11-b234-4a73-bcfa-5448604bf429	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	e14efa35-1987-4cc3-b70e-06250f27f0d1	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:25.239844-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fa3ab7be-1731-45ee-b83b-7b34a9476325	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2f5958fd-620f-4556-b050-94371ce79dce	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:25.274233-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4552313f-4f5b-4d43-9bff-bbf93968f6cc	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ef183f7c-c3d1-45ee-a548-e505385aa062	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:25.31093-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
212dfebe-bd57-4462-aad5-d0ce607ca293	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	7334bc00-bb6d-4c22-ad74-ca1a06230cac	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:25.350312-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6f63ed7c-4cd7-450a-9151-95eb1dde68a7	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	f3aa23d4-ad96-4e5b-bbea-a93cb8acd679	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:25.398875-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4af3a2df-01ae-4fc2-8225-2de194766921	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8cd35820-0d17-429f-8510-fcf411f8e6a2	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:25.452996-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f937b988-4957-4bb0-995d-af7014972ea2	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8cd35820-0d17-429f-8510-fcf411f8e6a2	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:25.503036-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ab754a0f-699c-4ef1-91e4-45fafe20c759	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	81faeb59-87bb-4204-9158-6d18b7f32895	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:25.544143-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0cad62a4-cbc5-4503-8db9-64e0dbf778da	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:25.585885-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c89a8e89-4dc9-42a0-ad0e-73c80ea02225	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:25.628823-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4b6b75ca-1200-4741-90a6-0f3a8c7e3151	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:25.671837-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6533429d-5621-4640-bd0a-ef00a7a7fd03	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:25.713539-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3dbf1d4a-75a3-44da-9e62-f2f224843761	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:25.751349-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
75df9426-0afb-474d-a769-a40fe511be8b	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c7d83767-bedc-4f26-ad8e-f4dd96a8b179	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:25.791312-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
938d22fc-a2d7-4ec7-a2b1-e3f3385ee016	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:25.831801-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5d595dbe-fbc2-4e76-a445-f1b710cb9d45	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:25.867408-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2c629544-d2f6-4ff7-b267-1c482f45e0de	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:25.903383-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8294515d-d5c3-4227-b8b7-581702fcdcdd	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:25.939347-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
99dce867-2529-4edc-a869-f292bc3443ed	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:25.972774-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d382c04a-9380-415f-90c2-451467808481	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:26.0089-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
35bfb143-bd6b-4228-8a5d-ef0f7723a758	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:26.045484-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
93db5a63-bde1-4ac1-b328-383e07ffb923	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:26.082636-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
633d805f-f64d-4493-9385-a0fe2126390f	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:26.11762-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
05fe7187-916d-4fb7-8875-4e2ace9aa405	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:26.153034-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d92fb77b-8764-4c5c-8442-f5f465b4942c	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:26.186497-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9eed2c97-d5cb-416a-8492-be32bf5b183b	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:26.221901-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
051bd0d1-97f2-43c7-8493-4a0f969ecbe7	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:26.257788-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4b37caf4-600e-494e-83d0-ed962c196373	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:26.294178-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2156a205-5c9d-494c-95fc-fa1bc817dc8d	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:26.329257-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
14b1a354-3a67-49cb-bdfb-cf040e873c47	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:26.365-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
aed35d49-d4d1-4011-8853-8412c1c4a3c6	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2cd41277-5bf7-4b0d-85c6-ff06912a8fe6	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:26.4004-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3c3be690-4237-44ea-a868-0765d5ce6257	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.436484-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fbbf3af5-3d31-4af0-8963-6115ea61668a	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.471849-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
435ec793-f6d4-4405-9f53-9ee89835ca1b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.511322-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
68d0761a-5a47-4649-be98-e79e3f589c5c	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.548687-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
23584e1f-29e6-47ac-bd93-50ea7977f066	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.586934-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3d590a39-b0fa-43ff-a795-b202a6cd34cf	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.624636-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
691d00c3-0b12-4770-8031-912413d00e83	75a11471-aca9-474d-b1b1-c7ada29d90f5	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.66113-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8729035c-4327-4047-8268-ca0fc3d56ec7	75a11471-aca9-474d-b1b1-c7ada29d90f5	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.697774-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dfbe75ca-915c-4aff-80f6-f41c6fb95e07	75a11471-aca9-474d-b1b1-c7ada29d90f5	9114e054-5c47-4369-ad9a-6dea25ec5dcd	12069145-518c-4103-90e0-7d36ceebb544	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:26.737834-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e37f1982-d9c7-4f16-a4be-e14e2368e7ce	a5bdd381-00ac-4081-a433-ed868d43cf25	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2774c5ba-437c-4461-9e93-3ad251707aa5	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:26.776142-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
889e1f31-f55f-4e83-8f04-e9d8f37b6b5a	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	c8bebd64-d512-4ecb-b71e-d2fd6b2eb99a	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:26.814573-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5a1c75a4-0367-4881-9a19-1d439064cf84	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	160ab978-9698-42c2-a4bc-a9c768926b6f	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:26.852852-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ee9bcae3-9d74-41e3-8529-3e00110a4981	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	160ab978-9698-42c2-a4bc-a9c768926b6f	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:26.891787-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d79f286b-a2c6-4b29-9bd9-ddb9cad2b31d	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	7dfc5e9f-c1f5-4cf3-b9a7-05a3297569da	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:26.932678-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
443fdaed-81d0-4caf-9c34-d7cdc5a9194e	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	7dfc5e9f-c1f5-4cf3-b9a7-05a3297569da	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:26.971739-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
655652ea-c137-4a26-88db-e99a8314c9e2	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	7dfc5e9f-c1f5-4cf3-b9a7-05a3297569da	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:27.012293-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
69811daa-4ae8-4b76-ad70-5a5500106ee4	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ab30f171-8aac-479a-b648-da81bfc1be6a	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:27.047505-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
65a67500-0555-435d-90c1-9605786ef6c4	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	ab30f171-8aac-479a-b648-da81bfc1be6a	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:27.081804-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e3043095-0cb2-401f-92cc-bdd1d8a499c7	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:27.117133-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b989549a-fb8a-475a-8fe8-ba83645e7754	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:27.155088-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dac8445e-a90d-44dd-8442-e8a520a20fc7	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:27.192102-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2244efc4-1347-4b4a-ad71-1e180ee254c5	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:27.226506-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
28c1ab89-763d-44aa-bff5-f857b384e13d	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:27.261653-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6b160675-221e-4cda-9d58-bb96bf9b65fa	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	767b8d77-7f5b-4970-b458-225d8c8ff28f	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:27.296872-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4199d926-599f-481b-a198-00ce911e4e3b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.332219-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
35263157-41f6-46fd-99b1-1cf8c506767b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.36803-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
24080209-e345-47f0-bb16-5b7490b4624b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.40457-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
df879463-96b5-4d93-9601-53f602047cd7	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.43917-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f996cedd-343d-4185-a14c-5e03cfb6b2d0	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.47389-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1fe7d6bb-597c-4fe1-88d4-72470c671767	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.51025-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2d26f7e0-e04c-4dab-8e35-93f33299ba2d	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.546298-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a7e1372a-bf54-4387-9fc5-2429fb13ed6b	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.584046-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7b8aed22-260e-4c1a-9009-8489827cc627	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	666452b2-e093-457b-b465-e36c3094ba70	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.620684-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c10301eb-bc57-40ad-b79d-c660c6612a97	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.658554-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bc854212-4a2a-4557-b8d8-0543d611ba88	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:27.698051-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8767ae86-2f4d-463c-be9f-79997dfcc118	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:27.73417-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
67c9ed84-4904-4bea-a722-9edfb50da7e1	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:27.77073-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8594f457-c977-4db1-bba0-a03f04a15e92	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:27.810602-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2c50ae0a-5f9d-4d1a-8cef-4f1924fd5b5b	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:27.849032-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
60d535f6-253c-4b89-8578-794f4a5d019e	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:27.887273-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d6bc1058-948f-4ad9-8dc8-e842318ad3c1	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:27.924421-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
26a5fd75-248e-4d8a-b501-7aadea5317cc	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:27.961851-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
60fdd8f3-44db-4934-bd93-0ec4dc5a3104	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:27.999821-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
243d408d-ac24-4067-b852-451709a92e3d	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:28.039862-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d4f447b9-3b73-4137-9ab3-1044baf7673c	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:28.076257-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
561597b5-6363-4fdf-9b9c-683d7bf1b93b	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:28.112962-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dd93a205-f5bd-4965-9336-cafac9f597e5	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:28.150877-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
be52f4b8-e488-4164-92ba-7d98bc461bff	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:28.187539-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d0334e14-c998-4378-954b-c9952b3d6177	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:28.226974-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
75e0be25-2ab9-41f7-98cd-4f203cb9a26e	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:28.265157-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
db0504be-b21d-4555-8d49-5809a1ee5401	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:28.304627-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
88b48c11-88a8-48f5-b921-73d8a246c7b9	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:28.344121-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e6f1c9d2-4a2e-4212-ba28-73bcb489daf1	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:28.381365-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6bc14c96-dd9b-4b17-a2f5-65677f933cfd	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	071c67f5-8cd9-49f8-8375-e646c71d7937	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:28.417948-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8cd7042e-c7b7-4c78-8877-cf9f4f4f82bc	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d85332cd-f71c-4980-aa40-e6d27d6ce2b1	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:28.457746-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
639129c4-0d63-4d60-9a09-5b6fc831c3e1	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d85332cd-f71c-4980-aa40-e6d27d6ce2b1	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:28.495899-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
530ec964-21c9-4418-8596-2ed515be7a44	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	d85332cd-f71c-4980-aa40-e6d27d6ce2b1	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:28.530945-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b5aa80f9-e4e6-4a73-bcaf-683283de4106	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2419537c-563b-44a8-81c4-5f3d6287f310	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:28.566684-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a12eeaf8-198d-423b-9a56-6d0268bef821	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2419537c-563b-44a8-81c4-5f3d6287f310	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:28.602565-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ff33f4ee-eade-4186-985a-4c779e7a8ac9	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2419537c-563b-44a8-81c4-5f3d6287f310	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:28.638171-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4734a600-4688-4a3e-8b10-00425376eeaa	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	b4e96247-797e-4d07-9d13-cbc686da0399	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:28.675738-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
62c17066-6d75-4445-b12a-a0407ff6ebd1	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	b4e96247-797e-4d07-9d13-cbc686da0399	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:28.712055-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ebec177a-7f38-445b-b88d-18666c68e45c	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	b4e96247-797e-4d07-9d13-cbc686da0399	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:28.748146-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
be392d39-03cb-437c-94cb-432c3a47fcbf	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afbb13d8-b0c9-4f17-8f24-4ea2e01fd617	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:28.783552-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dc5fbf80-5c9d-491f-bcd5-23768dad977e	fdcbe1e4-81db-4211-90c0-66607403a000	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afbb13d8-b0c9-4f17-8f24-4ea2e01fd617	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:28.819997-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8b5060c9-fe4b-4ffa-abc2-b9a5519e8059	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	afbb13d8-b0c9-4f17-8f24-4ea2e01fd617	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:28.858458-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
500e2269-971e-402d-b5b4-0769009ee895	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	94a2f151-893c-426c-b8af-7d6b39e8245d	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:28.896275-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2ce72062-17a0-404d-b5c2-c76fef3f8bf7	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	94a2f151-893c-426c-b8af-7d6b39e8245d	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:28.933501-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
56490a0f-49af-4a5d-b549-4ce880d0bd8c	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	94a2f151-893c-426c-b8af-7d6b39e8245d	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:28.96909-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0a3cb7ec-4633-4139-93dc-f1894fa89eae	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:29.005644-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
80ab3353-8740-465c-b124-523691240c59	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:29.042562-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
76c98d8a-23ad-4f12-a855-346abb61ec3a	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:29.078057-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
758de2b1-7b60-412d-acf3-a991ed86a5b9	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:29.115601-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
01530a91-cb74-48f7-8210-b7b93ce255be	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:29.152145-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ab0bb808-c547-4f7f-bbc5-b661e82a5093	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:29.186792-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3c109071-9753-4a52-aac5-3213207e950e	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:29.221431-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4ced552b-bd5b-4b61-93a0-a2096a8f7ab6	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:29.257197-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1376fcf1-59c9-41e3-922e-03357053d6df	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:29.293223-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
62365a70-f271-40f7-b387-f7ff62114658	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:29.329871-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
cb32fbb2-41d3-44a5-b569-366f131c4a4c	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:29.367307-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4f479dd2-97fd-4482-b15f-bd2a42a96138	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:29.406113-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dfafa817-d77a-4cd5-96b0-d728ee72d0b7	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:29.443493-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b3522996-88bc-4fb7-b540-550f63680198	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:29.479963-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4fdec329-bc01-4131-a1d6-c6f6b6a26cd5	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	6f48a4ba-3043-44ae-9a72-af73a2b30608	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:29.516346-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dd928528-554a-4a97-9ffb-1d2285cc586c	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2f43da8f-d9f7-4133-94d1-84f8b2b8401f	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:29.553205-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1036b3a4-be62-4b89-9d42-b2a11c9f25b6	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2f43da8f-d9f7-4133-94d1-84f8b2b8401f	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:29.590355-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e37f2420-ff96-41a7-a242-9e1040ef5fc2	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	2f43da8f-d9f7-4133-94d1-84f8b2b8401f	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:29.625862-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
30e515e0-e1b2-43b1-892d-97f53417f20f	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	99296f68-1117-491f-a8e2-337fce77f135	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:29.662076-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b91ec563-cc66-4e00-ae42-4fac9e9470f3	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	99296f68-1117-491f-a8e2-337fce77f135	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:29.698471-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
eab264a8-de8e-414e-a3c3-d249be97df48	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1726da2-d766-46a1-8356-2a23b9912854	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:29.733859-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ad31ef94-f321-4cf1-9bb1-bc9b25cdda63	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	f1726da2-d766-46a1-8356-2a23b9912854	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:29.770258-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
94c523b0-e9ce-4a7d-8771-34f6ec1f4da4	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	7f56eb86-b298-4a97-a496-d31ff9d3269c	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:29.808305-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9fb09cb1-d67c-4210-ae6b-8f3243825c47	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	69f75876-5a83-4578-866a-a356457556aa	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:29.844851-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
65981134-22fe-4f1e-b8dc-45700b332bed	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:29.880167-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1bad4529-2323-4878-a825-d0fa7dbd972e	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:29.916426-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
63701e94-ac40-413e-a79d-4aac29ad261c	d12c8727-d989-4a7f-a4ae-252f19944456	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:29.953685-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fc9cee57-16f1-4734-b3a7-28b1b08b32ea	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:29.992439-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d5da59e2-7679-484b-9414-50f3c119dce4	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:30.032212-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0c371dee-eaa7-402d-bb8d-6a558d0612ea	f177b290-61b1-4114-96e4-9e5f3ae82c7d	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:30.070614-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
87fe69f7-b39a-4f66-82ec-3c8533aa41f7	b97f483e-719a-44a7-97ea-6f29de181b8f	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:30.107645-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4fa388d4-4aae-4a25-8ba6-c0998fe8b978	a2496458-dc74-4db4-9919-197feb32425b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:30.143683-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d15b6297-b188-4be3-9dd7-a615800f2696	4aec1612-86de-425d-8f6c-d0b128f6cbc0	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:30.179492-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
847f2094-1756-4a4a-8c23-9f035c77516e	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:30.216612-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fefbe858-0f5d-4f59-b14d-ed84a2372aaf	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:30.251671-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
76341c18-7634-4f64-82f6-38d55756c74b	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	bfc63b64-11de-40bc-a950-e77d38531afb	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:30.286776-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6c3899ce-c6d8-46fb-b5a7-0c0e72b77638	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2be8c622-bd40-4399-800d-db79f576a8f3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:30.322372-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e445b7df-3232-4248-99eb-5ba54f64a12c	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bf84cc88-30aa-420d-aa9c-8bd1366fe5a3	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:30.357607-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1eb79ee4-bd33-4932-a9c5-6339884a4597	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	9114e054-5c47-4369-ad9a-6dea25ec5dcd	bf84cc88-30aa-420d-aa9c-8bd1366fe5a3	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:30.393707-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4c978cad-a26e-405a-84ee-0c59ce1fb7ab	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	c95eba06-5073-4749-bc20-25515f703da4	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:30.429922-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ee21d801-1df3-41f2-a224-b7b0bd95d79e	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	c95eba06-5073-4749-bc20-25515f703da4	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:30.465402-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
076c36fe-e0fd-43f5-88b5-0071222269a4	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	c95eba06-5073-4749-bc20-25515f703da4	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:30.49956-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
990c3de7-82a9-4886-8a29-1a1db15fd912	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	57d5aeba-fd9c-4e26-bc93-ca11f112ac50	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:30.534446-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
00d0196e-888b-4a4b-bbba-49f6b1fcf509	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:30.5693-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
565a6aff-5fad-426d-8b9a-b4f7db255d9d	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:30.605986-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
047bf245-231a-42f1-a783-8bbbf26604ee	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:30.642054-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8b24faf5-351b-47da-a4f6-fb28470ed0c7	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:30.679146-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
64b3e278-1b28-4c83-97df-3e6021766750	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:30.714814-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
283f7448-0b9d-4b0d-ac9f-b34091895848	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:30.749674-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fb2eb0ed-4540-472f-98be-415130f228b6	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:30.784898-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3bcf33a6-93c4-4571-8bda-709bdfd240ba	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:30.819922-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
646e7431-9a8f-4a9e-b222-46cbeb7b6ddd	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:30.856495-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
efbe5383-55ec-46fe-8415-e0edb4e6f184	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:30.894514-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b47630c6-50a8-4d48-a849-6ccd2ecae60c	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:30.929221-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
471caa7e-c814-457c-ab5c-a99bc81bce48	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:30.964674-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d9f06015-7afa-4f16-be80-4d293b569187	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	009e1039-8705-4bef-872e-c03bcc4a05b0	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:31.000935-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2de6536e-46b7-4743-8235-b6f72e9f7d1f	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:31.036298-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
82a5d940-27b4-49ab-99f7-177d2262fc42	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:31.072776-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2378d1d6-4fa4-4b19-80df-d8b18c0a3caa	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:31.10919-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7c611a11-2a80-4e91-9842-65deb300c720	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:31.146108-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fb340e9c-161b-4006-b600-79bd96d2be81	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:31.181577-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3267ff2d-f15d-4666-acf0-b9747a2ad7df	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:31.216444-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f97dc68f-5d41-4493-b87c-b066e97448b9	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:31.252126-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
76e04759-fbf6-42e0-8d60-6b41d20949e6	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:31.287912-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
97031bf4-fc30-4e14-a822-2e11e149b339	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8d2e9a35-e707-49e5-8ff9-8582e571311d	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:31.326091-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1ce15330-7e72-4c60-a4b0-a8e869a10066	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:31.362089-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
13e733f4-d943-496d-a07d-251cd1b7d5fb	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:31.397537-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7d53aacb-3865-40c4-b05e-2d9b71c8cb6b	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:31.433249-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c8bf1551-32bd-4257-9e2e-6d286ee4f587	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8b109e75-4cec-4c39-8814-d0c613c566b7	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:31.581268-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c39e343d-4e85-4ff9-a079-2c4e5ffbe632	94208fb4-d881-4e88-8088-e46cfbddb1c8	9114e054-5c47-4369-ad9a-6dea25ec5dcd	8b109e75-4cec-4c39-8814-d0c613c566b7	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:31.61713-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
524287bd-b9ea-40d0-88ae-8f8815f7c3cf	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:32.266593-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6d8e1894-d020-4051-9ef7-f3dabb20ae43	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:32.303141-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
141148a2-89ba-4658-9206-215e6c8fbeb4	75a11471-aca9-474d-b1b1-c7ada29d90f5	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:32.339983-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6bf5f40e-561a-43ca-92df-5df8a9b63050	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:32.375471-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
86e7e91c-4160-467b-b5b7-2a87feb3483e	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:32.415574-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3db64a89-a589-46ac-956c-288dfb43a335	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:32.450671-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
aa2b4521-22c4-4b17-ad8b-26d41aad3086	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:32.48604-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e65bf084-35db-41b2-984e-7235f7466d54	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:32.521005-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d23dc427-8588-4e15-8151-03b05ea31bc8	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:32.556155-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7d2ddb72-f4a0-45c4-a7ed-8e16c426cc30	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:32.59265-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8c1e3765-a380-4466-87be-66f53a503358	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:32.630218-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2df93762-686d-499a-b4af-c1aad87fbfdb	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:32.664934-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e09d4b28-cdbf-48e9-8700-8fc6f8d57c03	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:32.700545-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
97a9bbfb-8eac-41dd-b1f9-ba8ccb5da7f6	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:32.73584-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d5ab15cf-09ed-48f4-bdf0-31f412f5ad87	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:32.771244-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7dc01c83-5d62-4867-bbc0-4546af6b4dd9	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:32.806441-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fc1bde28-1c82-4c6a-9d6b-60a8c162fca2	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:32.843763-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
eecdecdf-cf98-46cb-8a29-ed89304c6ae3	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:32.879277-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6fc81c16-80fb-4d12-87df-697b52a3df7f	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:32.915124-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9d95fe98-cb1d-4171-bcea-6bcaa43b8ac6	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:32.948995-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1dbd14a4-f841-4fcc-bb66-19e354acc206	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:32.98345-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
00d0bd37-f7f5-4812-9227-6fe2c62b873f	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:33.019568-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
090a9215-a68c-40a9-8c3c-487730e5445d	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:33.0559-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
38263126-d246-4989-a08f-4ca61195ae69	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:33.091312-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
dd10480e-4eff-4ad4-be14-25a792a2e9ff	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:33.12548-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8418a147-cbc3-4996-8805-9e7006b337b8	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:33.157985-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
840be693-0f26-48f5-80ba-38b18740d1d7	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:33.189955-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a6d4fdd1-f5c4-466a-bf93-c37582828851	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:33.221542-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b2eade37-4305-4f27-8e14-2c78d824276d	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:33.254472-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ec6076a2-fdeb-4e16-b203-4c3a19c25b6f	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:33.288727-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
eff98f15-2114-4cbd-a4ec-18c90c5fc2a5	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:33.321074-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
98808ca1-18ab-4c0d-88a2-c106b4e3b146	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:33.352484-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2e7be5d3-e076-4ef9-a223-d07e050e711e	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:33.38391-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c219d9b2-0833-46ac-9452-f537d501d122	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:33.417211-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
70406d2b-7153-49ed-ae01-ea685c7471f5	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:33.449493-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
08e7cd00-26fc-4028-963d-3f6adc94c198	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:33.481432-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
507173ef-1fae-4e9c-81f9-1ff37e5d8c10	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:33.514242-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ce32945d-faf8-4761-8566-d77ca5ae878c	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:33.545474-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8eb076bb-e5bd-49e0-8c52-6a11aa4c427e	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:33.57757-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
13b39565-f8cc-4df4-b9b6-762661448b5b	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:33.608946-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b24c9334-328a-4a34-b8ea-3fbc3f68015f	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:33.641489-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
d8307ece-60b3-4064-8858-e156030beee4	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:33.673013-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
62cb9c81-ee42-47c6-914b-340c362a9978	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:33.705073-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ae2e322c-1226-4f65-8681-8f421c525f21	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:33.738066-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7a8839b4-bffc-43ac-a711-86ae670efdb4	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:33.769815-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
902524bd-ca9d-4aef-b43c-433946c700ba	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:33.801856-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1cb17836-73d1-4a1d-ac6d-83ac7ee98a85	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:33.832762-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
17de9373-2450-43cf-835a-068d64d010bc	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	47e670ac-0ac3-46c9-942e-ca34b24ccdeb	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:33.865031-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
7ddb07d7-1951-4d24-a170-566f97693512	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	56cd2914-b523-4883-a407-6f0f4b95d119	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:33.896381-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6014fb10-cb4f-4118-b9e2-8c56ab6c46f2	8b3a2887-c4a3-4809-b53e-6920a38094fd	9114e054-5c47-4369-ad9a-6dea25ec5dcd	56cd2914-b523-4883-a407-6f0f4b95d119	e3208170-5974-47fd-af5b-ed389790dc6f	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:33.928354-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f5b259f9-cf7e-4d2e-ad9c-900ef3888b26	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	663fcd4a-1b6f-40da-a1eb-8de8722b4f8f	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:33.961099-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0364a3b5-7605-4bf4-8177-b51c1b09a94b	5fc4896c-8aef-46ce-9cd7-3caec468a11e	9114e054-5c47-4369-ad9a-6dea25ec5dcd	663fcd4a-1b6f-40da-a1eb-8de8722b4f8f	e3208170-5974-47fd-af5b-ed389790dc6f	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:33.993938-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6adef28e-ad60-4cec-88aa-8a929886bcc8	225e70e4-d813-484c-b138-dee8886ab18b	9114e054-5c47-4369-ad9a-6dea25ec5dcd	2b38bf28-5925-434b-a48d-99808624d119	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:34.025308-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ba84f298-2977-47cc-a1fe-6131cec6f879	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:34.059401-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5b25250a-cace-48fd-8916-6416f1cc7d08	f177b290-61b1-4114-96e4-9e5f3ae82c7d	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:34.091922-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
15b6af5d-bd87-4168-97bd-5631e4a39401	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:34.124776-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
936551d3-bdf3-4278-b81b-99d0ba682c7c	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:34.159708-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5b0c3fd2-959e-4b3c-adb0-083d2e9d29b2	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:34.192335-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1e5c32f5-0d2e-4616-abbd-ca707233f0a9	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:34.224075-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
16f1d10a-4a83-45d1-8837-667b20ac2b19	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:34.256291-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
cef7dcad-efb2-433f-b22f-3140463f91d8	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	74a199ca-5d40-4adc-b206-e381ba531af6	e3208170-5974-47fd-af5b-ed389790dc6f	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:34.288284-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
57764b82-c447-4b97-b579-9f17f3910dfd	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	862fafad-bfb7-45de-880a-4ab022993152	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:34.320573-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
df8dd22f-9650-4242-bb01-2fdb80a212f8	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	862fafad-bfb7-45de-880a-4ab022993152	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.353016-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fe37614e-a3cb-447b-8be3-ac01a92579cd	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	862fafad-bfb7-45de-880a-4ab022993152	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:34.386115-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8c1c34f2-966c-4037-9830-178e06bec3b3	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	5d8ca774-6339-42af-90dc-e3a9bec0fbe2	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.417634-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
76ba81ee-1f7d-463a-94f5-4761a169a7e5	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.449464-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
1a938c98-7390-45e1-8303-fbc69ea33cbc	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	0933b030-498d-440a-8315-0d492981755e	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.480731-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3b626459-1105-4239-b436-f9d88b7e5813	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.511554-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3fdc0ef9-9e08-416f-9b22-62a6c21ac334	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	cf0ee27e-e396-4d6f-9b01-274a0b956edb	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.543515-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
3ed27da1-07cc-434c-9e2f-0e59eef91374	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.576392-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b27c3651-2b5b-405b-8d6a-4c25a21ed76b	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	0f60cac0-4564-4e5f-860c-0fad0a817b40	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.609899-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
516d06c9-5c98-406e-a329-3aabf0bb090b	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	9676fd9a-916d-4f9c-8f33-4f3727a23d57	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.645032-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ba90c585-5021-4863-bd14-1a1838ece0c5	75a11471-aca9-474d-b1b1-c7ada29d90f5	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	3c36afca-f68d-4523-bb81-b12644aae620	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.676729-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9b49af35-a844-47ae-b1ef-ce55be05363a	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:34.710425-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e86b763c-41f2-49e5-9903-5d4af05d14c0	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:34.742368-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4130bdc5-1d51-4618-8cec-34f88806a9f3	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:34.773933-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
aa84441e-f9b5-4ab9-954b-3d6e6797067f	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:34.807253-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
470c2210-bd10-4062-b645-9ecd36600e2c	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:34.840335-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
95084b0f-0c4a-4d04-a7a5-c08f59bf8204	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:34.873195-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
37cb571f-b720-41dc-828b-7e062eb01c26	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:34.904817-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
72d38c58-7e83-4e34-8fd6-b164fde9c195	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:34.935788-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6c516e1a-0b9c-42ff-82f6-9c6b54b8e2f5	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:34.96776-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
9e83d29d-2081-4ad2-a7b6-af44841d53fd	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:35.000099-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
37276235-9a4d-4481-9f84-8df3fe1d0e2c	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:35.034004-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
0840515a-2f85-422a-81e6-bb6040872d33	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:35.06743-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
845d0680-2f77-4b31-b502-ba4a5559408d	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:35.101096-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
fe8be6b8-9558-44cb-9937-93ba249e04a7	a5bdd381-00ac-4081-a433-ed868d43cf25	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:35.132813-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ff23000f-f48a-45ef-899d-7d6fd1907f10	8b3a2887-c4a3-4809-b53e-6920a38094fd	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	a3283c67-ae8b-46f7-99f0-ee3a59885978	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:35.16665-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
2c829a1b-60e3-4c39-8e5f-9973ad3dd3a9	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:35.199999-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
53d4b9c8-7057-4418-a6ff-92c00b97f5e7	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:35.232801-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
97c1b439-71d5-4384-b049-5efd464c4d00	d12c8727-d989-4a7f-a4ae-252f19944456	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:35.265372-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
5d91fd50-9922-4a6a-a060-363cf475e81f	fdcbe1e4-81db-4211-90c0-66607403a000	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:35.298637-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
403e3699-4c42-4bba-8f1f-a7eb3e431713	5fc4896c-8aef-46ce-9cd7-3caec468a11e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:35.331677-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8af96b3c-393e-4ee0-8a69-d47db524421c	1cb7fa4b-146f-4c57-ac39-eff30afb4cea	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	4e53507a-2a88-4d6b-9d02-17083f4036b8	2025-07-29 13:23:35.364866-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
341a91df-43d9-4611-9bdc-9acb65eb9c4d	ea9ee31a-1ed6-4b2f-a471-a631ba983f8e	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	fee6b9fe-5ef6-4373-8193-54d9c71b7119	2025-07-29 13:23:35.405369-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a2ff6feb-0a37-46fd-b51d-ea646716baaf	f177b290-61b1-4114-96e4-9e5f3ae82c7d	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	88c8f421-d47b-4f1f-acf8-2a7b5206ef3b	2025-07-29 13:23:35.44914-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
6b5a1f54-4e7c-4afd-adcd-afe38ce2d1cb	b97f483e-719a-44a7-97ea-6f29de181b8f	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:35.493923-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
cd15b0e7-575f-4644-b212-7d4a9d5fc4c0	a2496458-dc74-4db4-9919-197feb32425b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:35.528671-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
000a2f9e-52ba-4488-bf53-ceb08e94d581	4aec1612-86de-425d-8f6c-d0b128f6cbc0	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:35.559922-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
4e45ac39-6b42-445d-bf98-4d4d5c6fa741	225e70e4-d813-484c-b138-dee8886ab18b	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:35.591671-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
8290ecb4-ccdc-4168-a118-61e2d11fbf38	94208fb4-d881-4e88-8088-e46cfbddb1c8	b7bb6287-fea2-4ad8-b962-a36f7531676a	b60fe917-c6d3-4331-8878-feca2c7cc9e3	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:35.623519-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
26caae66-69a9-4253-a7b1-9a5724c80902	b97f483e-719a-44a7-97ea-6f29de181b8f	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	465e3c5a-b3ff-4d90-9267-d5e7cb48aba3	2025-07-29 13:23:48.045916-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
e34fc888-e3c5-417e-82a1-dcfc4a2acbfa	a2496458-dc74-4db4-9919-197feb32425b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	4bc8c4f0-6567-4d6a-a84d-85dc50e748bd	2025-07-29 13:23:48.093913-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a4707977-f224-433e-a6d2-697c8d057248	4aec1612-86de-425d-8f6c-d0b128f6cbc0	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	baf76b55-bf8f-4ba9-9f19-8e89faf18aa3	2025-07-29 13:23:48.127389-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
648cb205-fc7d-428f-a796-26f11d793ba2	225e70e4-d813-484c-b138-dee8886ab18b	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	45556e56-b550-424e-bb47-08ff7ca7dd05	2025-07-29 13:23:48.159473-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
50dbe35b-f2c9-4f40-936a-85bea216f1a9	94208fb4-d881-4e88-8088-e46cfbddb1c8	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	30c35313-f6c8-4da1-94c9-0ea8a1f94435	2025-07-29 13:23:48.190752-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
79a83e1c-a288-4fc0-948f-858f3a894bff	a5bdd381-00ac-4081-a433-ed868d43cf25	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	67227029-b40c-49cb-a533-b145795385f0	2025-07-29 13:23:48.223155-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
50ae7bba-95b3-427b-b3fa-1b3fa1d5fec2	8b3a2887-c4a3-4809-b53e-6920a38094fd	af7361ff-09bb-4c3e-9570-03ef61efb0aa	77399a04-c033-416a-a8d5-1ebde27bbba7	74a61edd-271e-426a-9652-aa93960431b3	5e6a05e5-1d96-43d3-9d96-9d8bd87efb9b	2025-07-29 13:23:48.257019-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
f2cf3b4c-18c3-4bae-9c83-fb1677b533be	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	26b00153-ec1d-4b83-80b6-74d24c580cd9	e3208170-5974-47fd-af5b-ed389790dc6f	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:48.289734-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
68d4f90e-f325-4789-958c-ec759086af31	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	26b00153-ec1d-4b83-80b6-74d24c580cd9	e3208170-5974-47fd-af5b-ed389790dc6f	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:48.32166-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
a0b39bb1-97ba-4624-b0a7-ceecbdc5f666	ad970ef0-dba6-4813-9c9c-9e1a8e0bd2ff	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:48.354983-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
42db122d-5811-4538-a61f-c35d6b45f904	837d7dfe-74d1-4d03-94c1-bd6bdc9273c9	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	904c0067-4026-4732-82ac-840ccde9bfb0	2025-07-29 13:23:48.387376-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
ff7efd0a-4f3e-4c70-a78c-f1dcb4c5744c	d12c8727-d989-4a7f-a4ae-252f19944456	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	01995b64-a990-443f-a210-0ee930fd8331	2025-07-29 13:23:48.419353-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
b3f27a48-1d7d-4490-8af3-37b98cc91ca8	fdcbe1e4-81db-4211-90c0-66607403a000	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	5fd6e94f-528e-42f9-9254-937d15b8059b	2025-07-29 13:23:48.450532-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c2d5f018-9643-4eb7-8bb6-8109dc302756	5fc4896c-8aef-46ce-9cd7-3caec468a11e	af7361ff-09bb-4c3e-9570-03ef61efb0aa	e1a6c773-2833-40b7-ada9-9d59a05043e1	a3283c67-ae8b-46f7-99f0-ee3a59885978	0530747f-cbde-469f-9f75-b27bcf7ed324	2025-07-29 13:23:48.484417-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
bf5d7a58-96b5-417a-af17-99799c642a7f	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	ced697ac-255f-4a98-aad5-5d90bed79ec5	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:48.568908-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
c6577cef-7fa3-4b37-810c-f748b1ce5585	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	6d919423-659f-4d5d-82ae-60ffe980ec31	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:48.628006-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
466ffc51-0ee2-496d-91a2-6bdd536d9ec2	eae08d36-af8d-4e33-aa85-b6f7fdd84cef	af7361ff-09bb-4c3e-9570-03ef61efb0aa	8a0187c1-cfc0-462d-b7ce-a80b2c9fa925	a3fd09ab-92b8-4b8a-92c2-c665fd6d5f71	4f5e7435-3e6a-483a-bfbe-983faa96ea2b	2025-07-29 13:23:48.685253-05	\N	181abc51-1e01-4c32-8684-a636a18b3f47
\.


--
-- TOC entry 5207 (class 0 OID 161945)
-- Dependencies: 232
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
-- TOC entry 5217 (class 0 OID 162130)
-- Dependencies: 242
-- Data for Name: teacher_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teacher_assignments (id, teacher_id, subject_assignment_id, created_at) FROM stdin;
\.


--
-- TOC entry 5208 (class 0 OID 161965)
-- Dependencies: 233
-- Data for Name: trimester; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trimester (id, school_id, name, description, "order", start_date, end_date, is_active, created_at, updated_at) FROM stdin;
4704b7f5-c3b8-4488-94d2-c46b3028f03c	\N	2T	\N	2	2025-05-05 00:00:00-05	2025-08-05 00:00:00-05	f	2025-07-05 21:58:38.158191-05	2025-07-05 23:04:01.500303-05
d93a3422-be77-4aa2-b7da-4af4ea52d494	\N	3T	\N	3	2025-09-05 00:00:00-05	2025-12-05 00:00:00-05	f	2025-07-05 21:58:38.158945-05	2025-07-05 23:04:10.167357-05
e6f39527-09ee-4bda-9a40-d461cbc5185c	\N	1T	\N	1	2025-01-05 00:00:00-05	2025-04-05 00:00:00-05	f	2025-07-05 21:58:38.127083-05	2025-07-05 21:58:39.604003-05
\.


--
-- TOC entry 5214 (class 0 OID 162085)
-- Dependencies: 239
-- Data for Name: user_grades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_grades (user_id, grade_id) FROM stdin;
\.


--
-- TOC entry 5215 (class 0 OID 162100)
-- Dependencies: 240
-- Data for Name: user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_groups (user_id, group_id) FROM stdin;
\.


--
-- TOC entry 5216 (class 0 OID 162115)
-- Dependencies: 241
-- Data for Name: user_subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_subjects (user_id, subject_id) FROM stdin;
\.


--
-- TOC entry 5209 (class 0 OID 161980)
-- Dependencies: 234
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, school_id, name, email, password_hash, role, status, two_factor_enabled, last_login, created_at, last_name, document_id, date_of_birth, "UpdatedAt") FROM stdin;
bacfdfa6-a34f-4d1d-a9d9-9e100ac3a7c5	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1006	estudiante1006@demo.com	$2a$11$csxqdXqFQaUye0iiRYBEP.GYTxVY155Bzgeev0n7mk.zVwi40ZaqK	estudiante	active	f	\N	2025-07-29 13:24:57.011298-05		\N	2025-07-29 13:24:57.147361-05	\N
32e48db9-798f-4890-af2d-ad6bab718cf4	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1007	estudiante1007@demo.com	$2a$11$DnFguKNk/WCeU753k0OmnOqo08hMBbGG6HxwDWpJU2gWVYWSQKU/6	estudiante	active	f	\N	2025-07-29 13:24:57.168785-05		\N	2025-07-29 13:24:57.303561-05	\N
0360922b-922c-45b4-89bc-15216afedd52	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1008	estudiante1008@demo.com	$2a$11$TqBnTC87ss1XFYFgRklnMOr9C7wXZy4ScTINpKRSybGzVW8yCqfem	estudiante	active	f	\N	2025-07-29 13:24:57.32538-05		\N	2025-07-29 13:24:57.464969-05	\N
88c7241b-9fda-43a8-ae30-d0931c89e55c	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1009	estudiante1009@demo.com	$2a$11$d1ftZB6QA8vDcC78yUsxbeSn1BPbTIYDW4Ki0FkMMlR6VAu.U7M62	estudiante	active	f	\N	2025-07-29 13:24:57.487833-05		\N	2025-07-29 13:24:57.623992-05	\N
03ffc6e8-549d-4ed4-8f08-f4755afc5fb4	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante992	estudiante992@demo.com	$2a$11$eKBu1lxQmNkN5U4JQXeQV.YTA/Ruz0njtLiClKVYHy3faLtCiyxTi	estudiante	active	f	\N	2025-07-29 13:25:11.873014-05		\N	2025-07-29 13:25:12.013622-05	\N
042bc0d1-8e8d-4077-bfad-4792cc8c2e51	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante993	estudiante993@demo.com	$2a$11$7kPnfMWbCEx6qVzj3gpym.2h3pUoiHH8t/LMQ1fxNTwAktz3QfwVS	estudiante	active	f	\N	2025-07-29 13:25:12.053708-05		\N	2025-07-29 13:25:12.188461-05	\N
87550719-e7d0-4729-9620-664869998e06	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante994	estudiante994@demo.com	$2a$11$AftN5eF4EGeaqe.ggBF5/uHnu.CR0CgBlmxxVYD/GkzSBvRIZNUMC	estudiante	active	f	\N	2025-07-29 13:25:12.208135-05		\N	2025-07-29 13:25:12.34217-05	\N
23529838-129e-46ab-9db9-c813e36defaa	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante995	estudiante995@demo.com	$2a$11$xNUXWPjZtCAjN8hLhHVro.wKVRSCA5.LzY/z339q4zKrogKbsUl0K	estudiante	active	f	\N	2025-07-29 13:25:12.361975-05		\N	2025-07-29 13:25:12.496264-05	\N
4d0c22b3-0423-4158-bf3c-7b40daf247dc	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante996	estudiante996@demo.com	$2a$11$pyyzvWihfk7uFhSSriRlLevSwdFHNiQUSVeubfwk/BjYdYhbVhJ.6	estudiante	active	f	\N	2025-07-29 13:25:12.517056-05		\N	2025-07-29 13:25:12.651193-05	\N
b5cb04ba-8b09-4f7c-bf34-6fed01fa080b	\N	admin@correo.com	admin@correo.com	$2a$11$ghA2pp1kQxj87N/q7Eq0QexRa2T0C8vf6TSmbCywSK6/phMMFY1TS	superadmin	active	f	2025-07-29 13:20:43.940488-05	2025-04-11 22:55:18.363537-05	Corro	DOC000016	2025-04-23 11:12:36.889583-05	\N
b350edff-2be7-4e66-ae87-d7c0814c8340	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante997	estudiante997@demo.com	$2a$11$MkTy0xd/NpxEVSZ/t.uaCeyUBP0cUaX2SB.wRseQupSJPD7ISFFY2	estudiante	active	f	\N	2025-07-29 13:25:12.670475-05		\N	2025-07-29 13:25:12.806963-05	\N
1ae09f3d-8063-4945-9bcc-0f3ce1d73d51	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante998	estudiante998@demo.com	$2a$11$s9VWNdolnucLOn5PJpAKTurnGz7p3EeRMB.7MDmlpBv7JTsCy1JYC	estudiante	active	f	\N	2025-07-29 13:25:12.826623-05		\N	2025-07-29 13:25:12.96245-05	\N
c7ee74ea-4b88-4be2-b06a-12e50d119ef7	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1002	estudiante1002@demo.com	$2a$11$7meWoE06WDGrLH8NMXDXN.xFXsAhAIhRmTkoiZH1gwCPS8nkj3Slu	estudiante	active	f	\N	2025-07-29 13:24:56.377507-05		\N	2025-07-29 13:24:56.513545-05	\N
84561573-701e-4e79-8752-52b7a37cb3d6	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1003	estudiante1003@demo.com	$2a$11$PbJnlYmO.gONTK6AX6xEiOdTx.cKxY.zFqiRlkpE9BbQdjax3kQN2	estudiante	active	f	\N	2025-07-29 13:24:56.534672-05		\N	2025-07-29 13:24:56.670089-05	\N
21d78497-1ddf-4b7d-b098-bcc2db658179	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1004	estudiante1004@demo.com	$2a$11$jZic6KYw2Z9rIso4PMcY8em0gLXQvm2f.54wxCDNxCv/g2Et2hFj.	estudiante	active	f	\N	2025-07-29 13:24:56.692429-05		\N	2025-07-29 13:24:56.829847-05	\N
1bd1dacc-7df5-4dc4-b351-970d9195ce06	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante999	estudiante999@demo.com	$2a$11$MdGqSIeR6w6cFOSMYr/DLeQZ9k./RE9ZFHu8IfY1nKJfz375erLIW	estudiante	active	f	\N	2025-07-29 13:25:12.983647-05		\N	2025-07-29 13:25:13.119064-05	\N
ea343094-9329-42a8-881d-e08bc900c3b8	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1005	estudiante1005@demo.com	$2a$11$lb5aDWWVp6kimYcOtBjcPOQuPNYKtLGUUMP1N8jkMEqfq1K7oENOS	estudiante	active	f	\N	2025-07-29 13:24:56.853224-05		\N	2025-07-29 13:24:56.989529-05	\N
e883da8d-108a-4ce9-8f65-3fb33413c811	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante99	estudiante99@demo.com	$2a$11$vnCUhKBGDTqeSC.tLqrLYOm5qtw4sjYOY.hKft5W1fknei2Al3NIC	estudiante	active	f	\N	2025-07-29 13:25:13.138417-05		\N	2025-07-29 13:25:13.272332-05	\N
47f953c4-ed73-4d36-bd57-90d55fefedf3	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante9	estudiante9@demo.com	$2a$11$9gVrbYQRAKsGZo6d5mrL1e2lND6lGoMLaEJIaTNDeuyvrmT2143N2	estudiante	active	f	\N	2025-07-29 13:25:13.293094-05		\N	2025-07-29 13:25:13.428022-05	\N
7b5d0782-84d4-4d6c-935a-9a4284d20bdf	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante910	estudiante910@demo.com	$2a$11$FxfxtoW5HfFFz9ppFeD4renInWWiibLahMB3H4RRq8Y/UAodh.gM.	estudiante	active	f	\N	2025-07-29 13:25:30.561963-05		\N	2025-07-29 13:25:30.702767-05	\N
e5970de1-853b-49cc-bf9b-042fd71c5d5a	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante911	estudiante911@demo.com	$2a$11$Xs0DbsJgT5f6DnsKb737auMM6UkjjX/kY/aacpli9fFOKlJHXosHy	estudiante	active	f	\N	2025-07-29 13:25:30.72552-05		\N	2025-07-29 13:25:30.891639-05	\N
31482094-5d58-4a56-9ed6-1b8d67b97572	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante912	estudiante912@demo.com	$2a$11$pH9WIPWzSc31K9HVCVdnjurwK1jGfEDkMsUv/teoTsNLJIbkUjGBe	estudiante	active	f	\N	2025-07-29 13:25:30.915209-05		\N	2025-07-29 13:25:31.050731-05	\N
7aed13df-6c3c-4276-b08b-a67a4c697a06	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante913	estudiante913@demo.com	$2a$11$mXXnNointI3P0JG4nyr4UeoAmSSEIXUfdYKBE.MH0bi6dPBEska9e	estudiante	active	f	\N	2025-07-29 13:25:31.073571-05		\N	2025-07-29 13:25:31.209106-05	\N
119b9a2c-1f15-4f4e-a706-a8b7497b29b0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante914	estudiante914@demo.com	$2a$11$lZkpl1QLuU07jQFdick7WuCNIt5ZLuTKvcWW4Lx0IWjBukVHnoLay	estudiante	active	f	\N	2025-07-29 13:25:31.231198-05		\N	2025-07-29 13:25:31.368234-05	\N
39babdd3-6f99-4637-a046-527f15ec8320	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante915	estudiante915@demo.com	$2a$11$xSZUOPGYyl49sImjZphBFuWBvVcY1rrzhcnG.2AuB1qmoI.CxKZKC	estudiante	active	f	\N	2025-07-29 13:25:31.391518-05		\N	2025-07-29 13:25:31.525793-05	\N
636717e4-7872-4580-9f96-8a4006fca398	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante916	estudiante916@demo.com	$2a$11$9dSQJsaFskbsSejV8J3efO8RybjKM33d.9esZpRVoo2ne5lz40dZu	estudiante	active	f	\N	2025-07-29 13:25:31.548368-05		\N	2025-07-29 13:25:31.682568-05	\N
2a7b768c-c97d-4501-91af-524838d13061	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante917	estudiante917@demo.com	$2a$11$4534xvn54B6.1wDyH9ef3.CSkCOd35MjWzKH2qMS2Gev0YaM/HJHS	estudiante	active	f	\N	2025-07-29 13:25:31.705478-05		\N	2025-07-29 13:25:31.841476-05	\N
832d745f-9bb7-46ef-936c-81ffd2b48250	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante918	estudiante918@demo.com	$2a$11$Yvn7VGySGoqfkM6TzFuPEOHwMUqoB1fNmazHZFstNz/5D8iC2OuHm	estudiante	active	f	\N	2025-07-29 13:25:31.86501-05		\N	2025-07-29 13:25:32.000239-05	\N
557a833d-c73a-4798-af27-f331aece55e6	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante919	estudiante919@demo.com	$2a$11$FdFJ0PTXoAztqBuujNjjeueykAFNeoWNvHpj0oiPmY4NOivx6eiTK	estudiante	active	f	\N	2025-07-29 13:25:32.024304-05		\N	2025-07-29 13:25:32.160787-05	\N
3bcb5be2-fd90-4212-aad9-6cda90b40098	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante91	estudiante91@demo.com	$2a$11$qZULe6CdlzOxnmD5VAJ4LOL4.o.fg.b3c7NoOoMWtRaHXQhzdNbK.	estudiante	active	f	\N	2025-07-29 13:25:32.184722-05		\N	2025-07-29 13:25:32.320648-05	\N
7db8beb8-2a3e-4122-b3cf-fc68ea15308e	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante920	estudiante920@demo.com	$2a$11$Laoe9bu14Xa/wgHlDsrH/eiC3l6vKxDCYpWgkpg004EgwjjwzRf3S	estudiante	active	f	\N	2025-07-29 13:25:32.346097-05		\N	2025-07-29 13:25:32.481388-05	\N
181e37bd-80b0-4be7-bfa5-9b8bc537420d	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante921	estudiante921@demo.com	$2a$11$3SFzz0amMSefH56mgSAZ5u8rBmYISzf1tDwpuRMDgDig.n0wmBkzm	estudiante	active	f	\N	2025-07-29 13:25:32.504994-05		\N	2025-07-29 13:25:32.639978-05	\N
28579412-e23a-4867-9539-36bcab716dd5	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante922	estudiante922@demo.com	$2a$11$S6aU18E7YZZPX0m9pO8OBeTyVvqxqkgXyysJWjDlF7FovUQckodCW	estudiante	active	f	\N	2025-07-29 13:25:32.662716-05		\N	2025-07-29 13:25:32.797532-05	\N
6e2b2594-a443-4997-bf1c-ef07282aebb7	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante923	estudiante923@demo.com	$2a$11$CguPBxSNlXAiKjg9EM1q7O4m2myJ690CEMCs.hNRfCWeiJsXguKzy	estudiante	active	f	\N	2025-07-29 13:25:32.820568-05		\N	2025-07-29 13:25:32.957883-05	\N
596cf3e0-d548-4a72-be9e-676d0c7b9d98	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante924	estudiante924@demo.com	$2a$11$rQuJF87cSotNv9ZuoBQCVON00Lx04HizINrv6MQkeCTfppFXsQxm.	estudiante	active	f	\N	2025-07-29 13:25:32.982586-05		\N	2025-07-29 13:25:33.117632-05	\N
d6fdd196-1c89-44b3-9092-b6b76306608f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante925	estudiante925@demo.com	$2a$11$.JWw30WxJ6.OV5jNrCRele/ul2h1ojj3w4b4j/XQfTsITUwFmmYCS	estudiante	active	f	\N	2025-07-29 13:25:33.143898-05		\N	2025-07-29 13:25:33.279481-05	\N
324f64ca-ce21-4645-8b56-d9faefd9caee	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante926	estudiante926@demo.com	$2a$11$fY98iTFBaJgS/07K/q60meP5PZPhzWEBJ3V6RrQNucq7FKH6N7SwO	estudiante	active	f	\N	2025-07-29 13:25:33.303605-05		\N	2025-07-29 13:25:33.439128-05	\N
15a4dcd7-79c1-4279-9401-bed2720baa88	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante927	estudiante927@demo.com	$2a$11$095tdwAawS5kIZ/TItpBcO7JmHy3b3dMZX1aHaiDa4WyWXX2QFphC	estudiante	active	f	\N	2025-07-29 13:25:33.463793-05		\N	2025-07-29 13:25:33.59896-05	\N
01022d97-d9e6-40a7-a1a1-a4e5a120d3b0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante928	estudiante928@demo.com	$2a$11$72KxqpfD1AP8QOtb44v8h.5ZZrsRfUJQHRtZejQX3ptqV2ndGyQ0K	estudiante	active	f	\N	2025-07-29 13:25:33.62537-05		\N	2025-07-29 13:25:33.762354-05	\N
dadb7b6b-6d40-47b2-9343-da5b720dd1ec	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante929	estudiante929@demo.com	$2a$11$Sdvp29mbp2o3QoWxchNKruPySEF6XhckJNP083wgcSvVisFLo3fAq	estudiante	active	f	\N	2025-07-29 13:25:33.787963-05		\N	2025-07-29 13:25:33.925842-05	\N
82eadbee-e2b1-4b23-91fc-89addfcf56c3	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante92	estudiante92@demo.com	$2a$11$Xe.yPuHBi9qu0goo9tiaDO9.6X02PA.pfr6gDG2199b7NKSdvyRFS	estudiante	active	f	\N	2025-07-29 13:25:33.948802-05		\N	2025-07-29 13:25:34.085021-05	\N
d2774085-36c8-4617-a83f-99b011641413	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante930	estudiante930@demo.com	$2a$11$pylEDKbg2RKLD.k5dJK1s.bXtxkbZNisZvNnIJ9M2y1fEKQb9g0Ay	estudiante	active	f	\N	2025-07-29 13:25:34.109514-05		\N	2025-07-29 13:25:34.245085-05	\N
203d2933-3fbe-46b9-b62a-fea72716894b	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante931	estudiante931@demo.com	$2a$11$V6ZCTHXKHt7I0.DqibjkTORy0G453SJGkn9T8OSsgjSKVl/WFLeT.	estudiante	active	f	\N	2025-07-29 13:25:34.26818-05		\N	2025-07-29 13:25:34.404439-05	\N
14e18b2d-89d4-48c8-8a87-5a4432ac3faa	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante932	estudiante932@demo.com	$2a$11$yskRrWUmptE4XKAC9jbHW.dGP9EC0sRWx9CfVq5KSLS943VJKZJKG	estudiante	active	f	\N	2025-07-29 13:25:34.428442-05		\N	2025-07-29 13:25:34.563465-05	\N
4d9a1b11-5c0c-4e41-be91-6ef10b3b0a1b	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante933	estudiante933@demo.com	$2a$11$TYkAZiPWBfkZKhqwvGKyeeA.wkz.e3b8I7LmXpip0e916d6dLOwlq	estudiante	active	f	\N	2025-07-29 13:25:34.583687-05		\N	2025-07-29 13:25:34.719605-05	\N
92be377c-e0d8-4e39-a904-ac88e8db9063	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante934	estudiante934@demo.com	$2a$11$/6K/mVBDPy1PEd9x3k5q2erwLJcOAa3/Fb4q9WgsW3VxOTDN84TCe	estudiante	active	f	\N	2025-07-29 13:25:34.743154-05		\N	2025-07-29 13:25:34.878263-05	\N
6e01948b-bd86-40eb-a094-e07a6d64618a	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante935	estudiante935@demo.com	$2a$11$4lpB4Wq8V.b0QYdNi20G2upfcauGgE4074rRxHuF1uDIka95Muplq	estudiante	active	f	\N	2025-07-29 13:25:34.899039-05		\N	2025-07-29 13:25:35.036881-05	\N
7f302c6d-4c52-48b7-8acd-04bd688057b0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante936	estudiante936@demo.com	$2a$11$GQaUlMYiHqEJmO6gn4x3w.6rc2NffxqD18zoQW8qy8qd3LpJvMi9m	estudiante	active	f	\N	2025-07-29 13:25:35.065483-05		\N	2025-07-29 13:25:35.203766-05	\N
45b9ca2f-02d3-4c02-abdf-192063aaeba0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante937	estudiante937@demo.com	$2a$11$6qCv00ZS5XfjLeRh0NRR.OsT0FMGWYsLOEtVNRmzNyUaBWHXu2PlW	estudiante	active	f	\N	2025-07-29 13:25:35.228633-05		\N	2025-07-29 13:25:35.364761-05	\N
703a214a-a9be-435f-8d73-1d2734150c96	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante938	estudiante938@demo.com	$2a$11$3imOUAODZrIyYnNeOs98uOdWwng2IyBosDLvQznQvbtf4E8lgKPo6	estudiante	active	f	\N	2025-07-29 13:25:35.389727-05		\N	2025-07-29 13:25:35.532696-05	\N
d3af105a-60a9-4a10-a3ca-a64cd978c9ad	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante939	estudiante939@demo.com	$2a$11$WXlOCuTu4t8WKaEnBsG8BetR4eR.cvCnKmPKemgQlQ.29V/b/Diaq	estudiante	active	f	\N	2025-07-29 13:25:35.568029-05		\N	2025-07-29 13:25:35.712081-05	\N
980b48b7-2cf1-4824-ab5a-2c980fcbceb1	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante93	estudiante93@demo.com	$2a$11$/5/luLU2dAGzE.NHrVydO.EQSdftuH29MOMAVGoIjRABJHOagcA6m	estudiante	active	f	\N	2025-07-29 13:25:35.737882-05		\N	2025-07-29 13:25:35.875095-05	\N
87539ec5-ce68-427b-bbc1-6af8b87a399f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante940	estudiante940@demo.com	$2a$11$QiDAjkhfe54D455XOei2KujdSnge0bka..OYe/0U5FdLMH2gxtjWe	estudiante	active	f	\N	2025-07-29 13:25:35.900741-05		\N	2025-07-29 13:25:36.037404-05	\N
cf0bf5bd-9deb-4a5a-aad3-1ecbc16ab00a	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante941	estudiante941@demo.com	$2a$11$7UZmAj29Ukw6n2jmn0m39OIMrIyf1BIiFtlWKEoKiFvhbm.WTOdFm	estudiante	active	f	\N	2025-07-29 13:25:36.061095-05		\N	2025-07-29 13:25:36.205226-05	\N
1de585e9-c7e5-4e5d-9a51-2aefe4818c1f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante942	estudiante942@demo.com	$2a$11$KBvSCyYAL4HnzaoGdW410eoVuAgBflxlMyrPCMxW/X.Z6Csv2CDHq	estudiante	active	f	\N	2025-07-29 13:25:36.248652-05		\N	2025-07-29 13:25:36.392151-05	\N
2866192f-64de-4527-9783-3c86fa220b76	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante943	estudiante943@demo.com	$2a$11$gasRYfDKy11yur6XiLHZK.I9IM4t3WnbRcFLuoIc2TUACxJn6Sf0K	estudiante	active	f	\N	2025-07-29 13:25:36.416581-05		\N	2025-07-29 13:25:36.552695-05	\N
e3dbe70c-67a0-422f-be55-bbdbb1e252bb	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante944	estudiante944@demo.com	$2a$11$zZwM2DgB.nL4iP22vk6SSONDFI9MFvGza/JasJSHpTgSFymTtWvbO	estudiante	active	f	\N	2025-07-29 13:25:36.576585-05		\N	2025-07-29 13:25:36.713806-05	\N
d8aa857b-1800-44b0-9582-193852093cb2	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante945	estudiante945@demo.com	$2a$11$NrGM7QAbLdQF8vgXWSzutOQzY3UiFoByd1Gmu4oqHJj44nEs9hBIW	estudiante	active	f	\N	2025-07-29 13:25:36.739637-05		\N	2025-07-29 13:25:37.211899-05	\N
a3baa386-33f3-45a5-9563-f3bfac3d2a14	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante946	estudiante946@demo.com	$2a$11$3HVOhoaCHf5EqttfFr2.4eyOJKEO/VssgAj0nMulLlHulFHzdBVuC	estudiante	active	f	\N	2025-07-29 13:25:37.251007-05		\N	2025-07-29 13:25:37.524886-05	\N
2b1b31a3-2afd-4357-8889-f709867a4358	181abc51-1e01-4c32-8684-a636a18b3f47	Irving	icorro@people-inmotion.com	$2a$11$ijYC6tyYjXnk.l2uWu.0QeINxiYVKAVhEHwTbaTg5CUtEtlTEZ8i6	admin	active	f	2025-09-04 07:34:13.401026-05	2025-07-29 13:21:32.682329-05	Corro Mendoza	\N	2025-07-29 13:21:32.541532-05	\N
e8a96bbd-62f4-4b8f-86b9-dbacadf559a0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante947	estudiante947@demo.com	$2a$11$5l4AME6K8j5iEwdc2oKRRO55rWkx9Ivh7u0CCSQhQu.RdVaalsQu6	estudiante	active	f	\N	2025-07-29 13:25:37.550971-05		\N	2025-07-29 13:25:37.722298-05	\N
80e10fed-7c1f-4fdc-8b84-d19ff4ba6edc	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante948	estudiante948@demo.com	$2a$11$7nsZ9Z6LkhEuH3zv7187uOu5pMijeDKxlPkmDL3XHdPha8MflC9Wa	estudiante	active	f	\N	2025-07-29 13:25:37.749406-05		\N	2025-07-29 13:25:38.045659-05	\N
cc6922a0-215a-40b1-9616-56659590f4c8	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante949	estudiante949@demo.com	$2a$11$/OtVdS8dhuU4v8esOqnkzeXdV.R9SEVCYyfK0hCeEIaFk0yBILLwS	estudiante	active	f	\N	2025-07-29 13:25:38.095315-05		\N	2025-07-29 13:25:38.315605-05	\N
d05ac063-d2b3-4994-be8e-b78ed7b74cce	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante94	estudiante94@demo.com	$2a$11$rPpQYXnvPRpxMm9rljgDRuA60lY2G0f.YiPU6BbUkaeTnocaE2P1m	estudiante	active	f	\N	2025-07-29 13:25:38.339616-05		\N	2025-07-29 13:25:38.582156-05	\N
80ff7b9a-dfca-4bd6-a805-da724a7a9fe2	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante950	estudiante950@demo.com	$2a$11$4zSvy/zsC9kXJXK9hj96JeZMf0kZQFkja61JzsOW0HGtwZaWLWXm.	estudiante	active	f	\N	2025-07-29 13:25:38.606669-05		\N	2025-07-29 13:25:38.844186-05	\N
92b9d828-469d-4d7b-b5e6-e502c758d76c	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante951	estudiante951@demo.com	$2a$11$sve0WzyERDl0VAlN6B//bO/bSN26nk.wENvL0tHiztU4tWTIz4X1y	estudiante	active	f	\N	2025-07-29 13:25:38.869561-05		\N	2025-07-29 13:25:39.094771-05	\N
20e36638-6ae8-45df-8f8c-7b47dc69c22b	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante952	estudiante952@demo.com	$2a$11$G8uAsNECYO06bkEt/JUxDe17cPusdr3DdKrTrtrepR2/SXXrRf31i	estudiante	active	f	\N	2025-07-29 13:25:39.116836-05		\N	2025-07-29 13:25:39.339828-05	\N
b61edb01-2801-487c-a114-e3a60cbfa7a5	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante953	estudiante953@demo.com	$2a$11$al3DLwQmR/BjiwIoETpx0OlqEo18zlO2LXC8d4BrjmM1olrtKtk3m	estudiante	active	f	\N	2025-07-29 13:25:39.363539-05		\N	2025-07-29 13:25:39.587079-05	\N
dd171585-d6eb-4b36-8001-7ace8f1a383e	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante954	estudiante954@demo.com	$2a$11$khLdmrNko2bYldvffxtu3Oc7mfxjAXgJd8Nj1qHFhNJ/U5uNQndAm	estudiante	active	f	\N	2025-07-29 13:25:39.609986-05		\N	2025-07-29 13:25:39.836196-05	\N
aea92802-26d7-4a17-b0a8-876f80cb6047	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante955	estudiante955@demo.com	$2a$11$S1aBYGdlgw3//mmvNicJnOd3.ueWXskLp5TkczjYcmTaD8hMxITgG	estudiante	active	f	\N	2025-07-29 13:25:39.859766-05		\N	2025-07-29 13:25:40.082435-05	\N
6243c671-821a-406f-b178-85d5b4904f5f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante956	estudiante956@demo.com	$2a$11$w9DkSb0OkW8oylGL6Do4BeBNzXRnVER/1O4Ktef9C0jM86PO.eNVa	estudiante	active	f	\N	2025-07-29 13:25:40.106366-05		\N	2025-07-29 13:25:40.323702-05	\N
4c02fca9-3a3b-453c-8579-ffeafbeca729	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante957	estudiante957@demo.com	$2a$11$rDCEX3xFGNdAlAjcm2achOXJp2kGFsHJUQL3xTFl//w00yycYOI/K	estudiante	active	f	\N	2025-07-29 13:25:40.348559-05		\N	2025-07-29 13:25:40.569555-05	\N
d6f7775a-4d3a-4535-9eb2-ba8507ba3aa4	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante958	estudiante958@demo.com	$2a$11$1HVTnyBOfz4/vDB/0Z/.wOiAw6R93FxA9LllryyvQohYEolVeHG.K	estudiante	active	f	\N	2025-07-29 13:25:40.59434-05		\N	2025-07-29 13:25:40.814856-05	\N
b3c17170-3a6e-49eb-909a-2d897079fb15	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante959	estudiante959@demo.com	$2a$11$YTCc3BDqgaWamD.wcaHFKepie.a8LjEGsO/iZav7rdnKq6HxP0rhW	estudiante	active	f	\N	2025-07-29 13:25:40.854868-05		\N	2025-07-29 13:25:41.069313-05	\N
009396de-df0e-4250-bea2-a0157d8bda21	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante95	estudiante95@demo.com	$2a$11$8G3dpCXFuQSVKRz5sUZYcuVV0CcuiSN37D2LdjL9gyWdEIbKcZMSC	estudiante	active	f	\N	2025-07-29 13:25:41.11014-05		\N	2025-07-29 13:25:41.328506-05	\N
521f212b-dec9-4518-9d80-dee509f9d390	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante960	estudiante960@demo.com	$2a$11$RDd4Kgelrh7zAGOSFO4rB.B5WyFQ8GS55oXUfEoG1zumZB3dnQhl6	estudiante	active	f	\N	2025-07-29 13:25:41.351426-05		\N	2025-07-29 13:25:41.573929-05	\N
d72dc39e-d869-4cb4-bdaf-0f8e719dfdcf	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante961	estudiante961@demo.com	$2a$11$/Yx3xul1GZgzqJ1xHW7u6OUP/Lbufkz/0Dp.9kpir3w9Z3IAVKk1S	estudiante	active	f	\N	2025-07-29 13:25:41.597116-05		\N	2025-07-29 13:25:41.811455-05	\N
669bd825-f227-43df-a636-d90a57318f4f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante962	estudiante962@demo.com	$2a$11$OxjLUB.JSixbuxDJUvaUD.Kecgz7plM4dslal/VF6nHgZMCDUOboC	estudiante	active	f	\N	2025-07-29 13:25:41.833448-05		\N	2025-07-29 13:25:42.05029-05	\N
923612ce-506e-461f-ad3a-99c8785e455e	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante963	estudiante963@demo.com	$2a$11$qZSIel6TPI8ruF7n2VizueSfQ0Z2bZOzhfqjFxtwc189VfnFnj7TS	estudiante	active	f	\N	2025-07-29 13:25:42.072577-05		\N	2025-07-29 13:25:42.221693-05	\N
243428f8-f68f-4d0a-9985-5b7758707c11	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante965	estudiante965@demo.com	$2a$11$c..3l3esYtA.o6r0/R93Ze635gqWVln7tLx4czYQkTGmgDH.WXZcq	estudiante	active	f	\N	2025-07-29 13:25:42.485207-05		\N	2025-07-29 13:25:42.719474-05	\N
785c3d1d-8758-4c6e-b44d-294770ac8394	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante966	estudiante966@demo.com	$2a$11$MlH/r5pHhZeUsSV38hLRq.3sN.OYfqwEMjyuCgWzb1j2X/aV/w3ay	estudiante	active	f	\N	2025-07-29 13:25:42.762188-05		\N	2025-07-29 13:25:42.972545-05	\N
7e80c71b-1a6a-498f-9a34-afd75b41a3b0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante964	estudiante964@demo.com	$2a$11$W0jNosXjGvVzrydDQTerJuP1zbaC1emvnTwrA02oMr6MFJ2ILdbKG	estudiante	active	f	\N	2025-07-29 13:25:42.311067-05		\N	2025-07-29 13:25:42.455955-05	\N
dcd56ff4-1604-4740-8f4f-3345e4037509	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante967	estudiante967@demo.com	$2a$11$TMNCmBNruCohkHvT1BruYuZmjBJQv.ShF2nHMCsRb4Wzw740/XGs2	estudiante	active	f	\N	2025-07-29 13:25:42.994876-05		\N	2025-07-29 13:25:43.212967-05	\N
6d50d2f6-484f-47e8-bb28-03142b60cafc	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante968	estudiante968@demo.com	$2a$11$1tnhV/ly8qvzsSVf//3YQ..CyNi6a.6j9Bf83QwM.GePe4TCWZb/O	estudiante	active	f	\N	2025-07-29 13:25:43.236919-05		\N	2025-07-29 13:25:43.47112-05	\N
3bf10694-5efe-4364-97bd-d4429ddf74a0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante969	estudiante969@demo.com	$2a$11$DR24dZ7O8UNYyiIqf7TKEOu6g5K9FMQuRLey.M6qKq.t3RGh.T72S	estudiante	active	f	\N	2025-07-29 13:25:43.495404-05		\N	2025-07-29 13:25:43.722526-05	\N
c6d7ef9f-c5e1-4303-87c7-767fa28128f7	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante96	estudiante96@demo.com	$2a$11$NXHW9ATPaRg68pmvh0pepuCs7KMN/3.VWtz4yg2sFIPwojE5BQtsq	estudiante	active	f	\N	2025-07-29 13:25:43.746684-05		\N	2025-07-29 13:25:43.97323-05	\N
f80b87a6-928d-4e41-b808-754786346820	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante970	estudiante970@demo.com	$2a$11$L9T144xPnF.SSInkmbR4suU5CUBYhRm8C1IvhbBvvwTLIKCeLFQhS	estudiante	active	f	\N	2025-07-29 13:25:43.996948-05		\N	2025-07-29 13:25:44.219849-05	\N
df173dcf-0d71-40c4-91f7-6529fbf75f69	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante971	estudiante971@demo.com	$2a$11$p3aFQeuAIklRyqI6WH4Zaeka8CjKsLSSZB/aO9Y9v8cbaN1Z8WT4i	estudiante	active	f	\N	2025-07-29 13:25:44.244626-05		\N	2025-07-29 13:25:44.469372-05	\N
ef66dc1a-3955-4057-b0dc-9b47557e54d5	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante972	estudiante972@demo.com	$2a$11$uACHVDtgNcOq.SDCLcCVLOALAGCxJPldbl5dRTB/.UJ0EIAAYS3Ni	estudiante	active	f	\N	2025-07-29 13:25:44.494866-05		\N	2025-07-29 13:25:44.724006-05	\N
8d4ca5be-6183-4c88-8b95-883c65abcd4f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante973	estudiante973@demo.com	$2a$11$SM82w9OV0TTNNInPHOwmKuWHjxIudBTXLHyc/lTzwrqgIvJzL5cje	estudiante	active	f	\N	2025-07-29 13:25:44.750498-05		\N	2025-07-29 13:25:44.984854-05	\N
dabb0617-2fa1-4138-b4e2-60098b1ffe98	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante974	estudiante974@demo.com	$2a$11$IQFD1kcVvZMl8qQinslt/uEcWPQ5py9NjPsXA7Duiij32WSh3rEWO	estudiante	active	f	\N	2025-07-29 13:25:45.012817-05		\N	2025-07-29 13:25:45.241457-05	\N
bf8f94b5-cd92-42a1-a07c-27a3a45ff29f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante975	estudiante975@demo.com	$2a$11$Q8Uo5zN1zkJQWdV3TusbIuWex6I8n8cWav3f/B8ISuYsB37VDyijK	estudiante	active	f	\N	2025-07-29 13:25:45.265981-05		\N	2025-07-29 13:25:45.495409-05	\N
f2413e92-f0b2-4ba9-87c0-23375b71f866	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante976	estudiante976@demo.com	$2a$11$sAt4DpTEqEDoKNd5txDPiu/xDJhERQBDGtPSHgTbE01Ljq.0sAp9C	estudiante	active	f	\N	2025-07-29 13:25:45.529838-05		\N	2025-07-29 13:25:45.774005-05	\N
1abcc8f4-444e-4bbd-b9d5-d2dade9c145d	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante977	estudiante977@demo.com	$2a$11$vOSbiKSKUVkuoUpKITiG5eDRrQbpgaQsQGvqJgFQjtkKIlu.GG3Gy	estudiante	active	f	\N	2025-07-29 13:25:45.800308-05		\N	2025-07-29 13:25:46.033717-05	\N
f0118d4d-9c22-4a51-be6b-50179d2a6ba5	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante978	estudiante978@demo.com	$2a$11$4qNO2jpL2QSlRkRLU/aWOO9SmNylTx.wRXJTCylyfpdjfDVDrjwK.	estudiante	active	f	\N	2025-07-29 13:25:46.059673-05		\N	2025-07-29 13:25:46.28926-05	\N
34baa176-7004-42cd-80c1-42020dd9ea4c	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante979	estudiante979@demo.com	$2a$11$7i4nxmW.lZnpvSQLZm9v5uMSYREA2WRIb2oyUp72i4j7O59PoFe5G	estudiante	active	f	\N	2025-07-29 13:25:46.317034-05		\N	2025-07-29 13:25:46.555591-05	\N
6c71f76c-5c27-44de-be5e-934eefa30efb	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante97	estudiante97@demo.com	$2a$11$BF4i.R4vl8/7a5JJsqroWe5Irf27Bsr/oz/EOeMKwVjre5tgLIS0G	estudiante	active	f	\N	2025-07-29 13:25:46.581201-05		\N	2025-07-29 13:25:46.814253-05	\N
78eae549-4812-4cae-9873-e40f0bc72e7e	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante980	estudiante980@demo.com	$2a$11$rEEfWMXyImJycUCWe07OsuAyAkxmIg6Aq.3AnWCIAM7Lvp6B9lBbu	estudiante	active	f	\N	2025-07-29 13:25:46.840048-05		\N	2025-07-29 13:25:47.069145-05	\N
fa2acac4-b976-47a3-a865-3a433f1dc1d2	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante981	estudiante981@demo.com	$2a$11$f14IhflxSbncQzg3XJS1MewWLA2wO9b9AQYM/266y07wTJY4otyEq	estudiante	active	f	\N	2025-07-29 13:25:47.094773-05		\N	2025-07-29 13:25:47.255417-05	\N
e152bc18-a24a-4e54-9b9b-b2921b9e45b4	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante982	estudiante982@demo.com	$2a$11$Y8u.YGdva0U7lSwFHLmUEuZYpVcY4wW5gBTMuUoce.crDqPHtXKzO	estudiante	active	f	\N	2025-07-29 13:25:47.361944-05		\N	2025-07-29 13:25:47.591866-05	\N
4a352c60-b58c-456e-9daa-6ae541a23553	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante983	estudiante983@demo.com	$2a$11$1BJD2JKGxn327qxEMC.YUONBavD/XL8pC.GSZCuS7hq.wryzl9vfS	estudiante	active	f	\N	2025-07-29 13:25:47.621081-05		\N	2025-07-29 13:25:47.851954-05	\N
36dde3d1-163f-4933-bf72-0e8e796d3447	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante984	estudiante984@demo.com	$2a$11$ybDe4XwycL4sKZM7Fh9KUODZYXwMMxc7fEA3Do8GhXGgtUGtLYXLe	estudiante	active	f	\N	2025-07-29 13:25:47.87914-05		\N	2025-07-29 13:25:48.115688-05	\N
94e50d42-b39c-4b45-81bd-6165803d393e	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante985	estudiante985@demo.com	$2a$11$TYZ0eGKJuGo86ruX9U2ziec2Wid.BtAgQNKY2jv4Fo05Ecnh4Jp3q	estudiante	active	f	\N	2025-07-29 13:25:48.142118-05		\N	2025-07-29 13:25:48.374675-05	\N
ef712527-1413-4bf9-80e0-4bb1c7cd0fbc	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante986	estudiante986@demo.com	$2a$11$BuvELf0BCbJCvDBG6LOr5.kQ3DASZe40pnhCbVv4fQzUuJY53.8J.	estudiante	active	f	\N	2025-07-29 13:25:48.399374-05		\N	2025-07-29 13:25:48.623185-05	\N
5a27e976-dc41-428e-93c5-cb4e9590dc34	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante987	estudiante987@demo.com	$2a$11$tknezdpSa0I2HWHDnE7Kfux9WWKVNnBLpIWBIIbZlHh5IZd3QC5xW	estudiante	active	f	\N	2025-07-29 13:25:48.646856-05		\N	2025-07-29 13:25:48.872233-05	\N
733d727c-87e8-4247-9f6d-afabb8c2f6e0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante988	estudiante988@demo.com	$2a$11$KLPibKskbTSy.nUVBtsMruQNUOdF8M/UeNKKfOec7JUu3yk.u.89K	estudiante	active	f	\N	2025-07-29 13:25:48.896252-05		\N	2025-07-29 13:25:49.121323-05	\N
24bc7f08-db39-4af7-81df-d0dfe1f39953	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante989	estudiante989@demo.com	$2a$11$AKEaiwfY48Gmv/zFCIK8MuBc7vbl4v5cobOmBxpPh5y5vEYrp3EbC	estudiante	active	f	\N	2025-07-29 13:25:49.147311-05		\N	2025-07-29 13:25:49.372558-05	\N
9fc82ad6-6218-4190-bdb2-f28d35a0016a	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1091	estudiante1091@demo.com	$2a$11$ai4o3RycVciuAhB4QiVrhebQgNw/INx5/b0cSqTfsDeFMn7IyKVvG	estudiante	active	f	\N	2025-07-29 13:25:54.959781-05		\N	2025-07-29 13:25:55.099336-05	\N
e307bb1b-9f1b-4bf0-8aa0-c98cf3f60908	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1093	estudiante1093@demo.com	$2a$11$/oKVYwGQyQM5933bAAcLn.fI/6KyOsXpC8gHBJQQhEDp4Je0suV72	estudiante	active	f	\N	2025-07-29 13:25:55.280051-05		\N	2025-07-29 13:25:55.41603-05	\N
1a7f007a-564e-47bf-92f2-0d773cb9fd20	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1095	estudiante1095@demo.com	$2a$11$rtMf/Jdi75FasGVn8PK4i./JTCURNscQYYlAd6oNmu1.klK/D1fm2	estudiante	active	f	\N	2025-07-29 13:25:55.602914-05		\N	2025-07-29 13:25:55.741686-05	\N
00b69150-2fe4-4261-bb28-da77f117bd75	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1097	estudiante1097@demo.com	$2a$11$8ZL1CpZ7/7cjM./woOEMye4OHohmVTapXvVnrI45McJw8r6W.Vsxm	estudiante	active	f	\N	2025-07-29 13:25:55.925339-05		\N	2025-07-29 13:25:56.061566-05	\N
c1703147-21e4-43d0-8100-85e6f5e570fc	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1099	estudiante1099@demo.com	$2a$11$RecmmQ49B/MN/ODDDJbQNOVLvXqP0SMV5E.Gh2qtzBsj7pLOb9IT2	estudiante	active	f	\N	2025-07-29 13:25:56.24703-05		\N	2025-07-29 13:25:56.383348-05	\N
7f14b8e1-d96e-4a6e-842d-cb652eee5fcd	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1101	estudiante1101@demo.com	$2a$11$h9k4uJL77mVhS.daVw7aduWvIN/DbeZVBX4i42BS48XMZMi6q76pO	estudiante	active	f	\N	2025-07-29 13:25:56.882419-05		\N	2025-07-29 13:25:57.018708-05	\N
539654a0-e1a2-4101-bb29-43b9a95859ae	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1103	estudiante1103@demo.com	$2a$11$c5b5XfZTYpoNKksQ5MQpiuJNgyVqB6GLk3yD/Ctq/sbzyCMDMaXZu	estudiante	active	f	\N	2025-07-29 13:25:57.198588-05		\N	2025-07-29 13:25:57.334347-05	\N
deadb577-ae88-4f72-9928-966839d00111	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1105	estudiante1105@demo.com	$2a$11$5sopTr9z59Sdk8QP/FIG5OmcED4zCIT1lcdR9aM2akKOhJtbIFPm2	estudiante	active	f	\N	2025-07-29 13:25:57.515285-05		\N	2025-07-29 13:25:57.652092-05	\N
63454c05-7422-4447-b7c0-4b6ac6c18452	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1107	estudiante1107@demo.com	$2a$11$1ArKwM1UBKMOh96xXrsBU.qbu8XoDUT1DwSWkmGXye2V17oWXhYZa	estudiante	active	f	\N	2025-07-29 13:25:57.832673-05		\N	2025-07-29 13:25:57.968363-05	\N
fa862365-de9e-4ef5-94c2-4bef2429d33c	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1109	estudiante1109@demo.com	$2a$11$snFwAvbmdhe/BMqbSEu.N.leVAw/9WZOVY/09AjYH5eJTMWq6OClm	estudiante	active	f	\N	2025-07-29 13:25:58.148767-05		\N	2025-07-29 13:25:58.286094-05	\N
b0372dd4-f1a4-4620-9bf5-2378193800db	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1110	estudiante1110@demo.com	$2a$11$OnZ.hGjppS60OgJcEWVkQenbeYBNONxUPyflr0YawfuiNTsKqIhte	estudiante	active	f	\N	2025-07-29 13:25:58.466981-05		\N	2025-07-29 13:25:58.602287-05	\N
9385ff96-2fd8-4779-903b-ba37c34d3f88	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1112	estudiante1112@demo.com	$2a$11$p1dJpjTLBJubbFC5NcANQe2HDapFjdPdefla4WsIgq2221IVepp6m	estudiante	active	f	\N	2025-07-29 13:25:58.782323-05		\N	2025-07-29 13:25:58.918463-05	\N
5ab823e6-4afe-4a31-91a1-b9ddaf628a36	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1114	estudiante1114@demo.com	$2a$11$DxC.L/vUebSQ5odK3A/VD.WsGx0ZGO3IoK.Oj45foFKQzSiF5bhPS	estudiante	active	f	\N	2025-07-29 13:25:59.101916-05		\N	2025-07-29 13:25:59.238402-05	\N
1f15d415-a8ea-401a-acff-a18d13a01c06	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1116	estudiante1116@demo.com	$2a$11$7WKHnPFIv8CDQkoM5imbvOFRlKsuJ3Iy/7erRMnAxg.mf4JkXsAcO	estudiante	active	f	\N	2025-07-29 13:25:59.420993-05		\N	2025-07-29 13:25:59.558383-05	\N
ef030d2e-b187-4066-9fef-518eefcef491	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1118	estudiante1118@demo.com	$2a$11$FF0d7BdFjdVgASdN0niyR.Fj03WfJZryr2j8hf.tI0zmSk2R5lyl.	estudiante	active	f	\N	2025-07-29 13:25:59.740323-05		\N	2025-07-29 13:25:59.87599-05	\N
e78b5e0c-1b40-4cf8-8bb4-42db593ee5fd	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante111	estudiante111@demo.com	$2a$11$y/RTZqxgZhioJ3Tg/eU1z.yMGtCGUpZiQI2e55yVBpeSCW7YD21sK	estudiante	active	f	\N	2025-07-29 13:26:00.06712-05		\N	2025-07-29 13:26:00.204834-05	\N
62c4e725-dda5-4baf-bbd3-38fe739273ba	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1121	estudiante1121@demo.com	$2a$11$iDWk9fQrViS5217YXOO3/OYZa52f1voUhS9AWadMyEYOlsSMdg3cm	estudiante	active	f	\N	2025-07-29 13:26:00.391479-05		\N	2025-07-29 13:26:00.528631-05	\N
75789a77-2814-447b-970b-bcae658a2fe3	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1123	estudiante1123@demo.com	$2a$11$RjX9XwoYysbjsfHXNUOusuXEJgarHAWvFKdyKyqQcXJcwNkdinlqC	estudiante	active	f	\N	2025-07-29 13:26:00.720111-05		\N	2025-07-29 13:26:00.857701-05	\N
76e76038-5bf7-4d32-9926-7ac053709ab5	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1125	estudiante1125@demo.com	$2a$11$5aIk7kC1Dd5RtlBQ53Nk.eC/8KXEBhALckq0W8vbqwliyPFqF3LtG	estudiante	active	f	\N	2025-07-29 13:26:01.045695-05		\N	2025-07-29 13:26:01.183036-05	\N
d81f7eae-31ad-4eb0-bfbc-7e08b3633f95	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1127	estudiante1127@demo.com	$2a$11$1dwBgmdgzVlrs9CAExvu/eCpliMNmZ4A9cp93i7us3gnP.TKHZdY2	estudiante	active	f	\N	2025-07-29 13:26:01.368835-05		\N	2025-07-29 13:26:01.506295-05	\N
862d9ff6-438d-48ae-a9e6-79148fd7a704	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1129	estudiante1129@demo.com	$2a$11$EdnbLDna4D8jeL2zvCrEzeXFzaS4CG3h278hcPukT3oVP7Xy7jz4G	estudiante	active	f	\N	2025-07-29 13:26:01.699791-05		\N	2025-07-29 13:26:01.845555-05	\N
71d75f83-0ea9-4f34-826e-57e845f8cc91	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1130	estudiante1130@demo.com	$2a$11$tZKUKX6b5aYnPqj7QBXiZ./khyveMDVDJPRJlCtFXaYLSqow8oR0a	estudiante	active	f	\N	2025-07-29 13:26:02.046848-05		\N	2025-07-29 13:26:02.186396-05	\N
0cc19101-3529-4fc2-bab5-251d2c925aba	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1132	estudiante1132@demo.com	$2a$11$bjhRCMzPwwoBT4XRsbTLtu0pXN/suubY51KWGf1se5WvMyGmb.j0u	estudiante	active	f	\N	2025-07-29 13:26:02.376575-05		\N	2025-07-29 13:26:02.514548-05	\N
7b45dad3-4fb2-460f-880d-4a88fab9b714	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1134	estudiante1134@demo.com	$2a$11$VYmm//2IYfdaXO3OidNKf.G2VKJM0wzzWYHSfDe1za939I2yZ7WOK	estudiante	active	f	\N	2025-07-29 13:26:02.704582-05		\N	2025-07-29 13:26:02.841223-05	\N
2a264be7-0a8b-40d2-afe5-5bcf194951bb	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1136	estudiante1136@demo.com	$2a$11$cWq9qTrgGkpDT8eHhvkOcOMvE0mMueXAJdZgnrJ8.ta7kX83bWz1q	estudiante	active	f	\N	2025-07-29 13:26:03.029349-05		\N	2025-07-29 13:26:03.166164-05	\N
8030dad1-39cb-413f-baba-ead4fced51f4	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1138	estudiante1138@demo.com	$2a$11$p5luvRQCVGVKpa6HYokQpe2Iuo92AvvbRKhUVvnK01u1W9oAsuC22	estudiante	active	f	\N	2025-07-29 13:26:03.358199-05		\N	2025-07-29 13:26:03.4954-05	\N
fc6ec1a9-1d00-49a6-b840-d01d7cb9b12b	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante113	estudiante113@demo.com	$2a$11$oMFcAYTLpZ.ncJ5aXswgXeZNbp/SgWPSvM.Dv8HkglXHfXb8YZ52W	estudiante	active	f	\N	2025-07-29 13:26:03.688321-05		\N	2025-07-29 13:26:03.82685-05	\N
c40cef99-a004-4eaf-bd60-f54094813afe	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1141	estudiante1141@demo.com	$2a$11$M0u5rsrhmuGTGxN3WYWIR.I7f9ivaPYaUhlg/MX/emEXkCZTFK96a	estudiante	active	f	\N	2025-07-29 13:26:04.014297-05		\N	2025-07-29 13:26:04.150649-05	\N
dd8cb26c-3ffd-4bb0-839b-1b04be7f8931	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1143	estudiante1143@demo.com	$2a$11$qiyug8pfv1g0Ac8ODDoXn.Kyk3yM.GZJGHHrkCR0wrbet7ZxTh7l.	estudiante	active	f	\N	2025-07-29 13:26:04.338952-05		\N	2025-07-29 13:26:04.477123-05	\N
fb189475-61a9-428a-9fae-95dc7404619c	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1145	estudiante1145@demo.com	$2a$11$KE8J7V4XEXXRFEBgT4yPV.LU4H3ykrcRyVsMC2451IL92eQlEDKcO	estudiante	active	f	\N	2025-07-29 13:26:04.664126-05		\N	2025-07-29 13:26:04.801465-05	\N
86ea9cdd-998e-431e-9213-8262d6a4bb0d	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1147	estudiante1147@demo.com	$2a$11$JVxu8dKReD8PGFg23pjUvOfkoI/XiiUO.BaNl3HxMZ3hURSKr9JFq	estudiante	active	f	\N	2025-07-29 13:26:04.991157-05		\N	2025-07-29 13:26:05.1291-05	\N
2c173167-eda2-4895-95db-4c1e1b110fdc	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante98	estudiante98@demo.com	$2a$11$dK6gkLV6fKK4/f8mr4hYU..7C9Ax9FpC2JSiBR1hmrs2CYoHNBQoO	estudiante	active	f	\N	2025-07-29 13:25:49.398424-05		\N	2025-07-29 13:25:49.623952-05	\N
ae30dd4c-f27a-472f-b5da-f54b1a1190d3	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante990	estudiante990@demo.com	$2a$11$lQADNVXaoKthoYv.LcUJE.hs1t.tKfkegGBGzgtzJNvfDmQynw8ge	estudiante	active	f	\N	2025-07-29 13:25:49.64831-05		\N	2025-07-29 13:25:49.87113-05	\N
026788d6-76db-43b2-b825-31a4f9925834	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante991	estudiante991@demo.com	$2a$11$tgf.SeJcOsaqN.RJJa2Yl.sEgbcSW4LKp2kwz.pObsNn6XYRwyuaa	estudiante	active	f	\N	2025-07-29 13:25:49.895602-05		\N	2025-07-29 13:25:50.12261-05	\N
f06a97bc-76e8-4887-b7a6-be8c8920a7d1	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1092	estudiante1092@demo.com	$2a$11$gFcXm.7zUKQfqEXhQHA4auB9sQNZXu053JrKoAuzQO0/Xesmgj/iq	estudiante	active	f	\N	2025-07-29 13:25:55.120199-05		\N	2025-07-29 13:25:55.25611-05	\N
9a94dde5-b764-42e2-aaab-70d3d48f9083	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1094	estudiante1094@demo.com	$2a$11$1TYk3dRROJXB5Ior3Jlg0u0tpvWLyCO1okWKmHvKnkhXs8YZNb9lC	estudiante	active	f	\N	2025-07-29 13:25:55.437721-05		\N	2025-07-29 13:25:55.575937-05	\N
8a647610-a7fd-41f4-83d9-ebfcbfc44fbb	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1096	estudiante1096@demo.com	$2a$11$HqbRnvqcwmTcmTLf4ju3geiWVEf5MaUGhsuLr9wWBIo1KTunc.V5W	estudiante	active	f	\N	2025-07-29 13:25:55.764744-05		\N	2025-07-29 13:25:55.901764-05	\N
77afc866-7404-4048-be29-50e776203a6c	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1098	estudiante1098@demo.com	$2a$11$vI4MP85xtnQsy08QNfZQ8OZfWDeVWnz9akO.n2cj9qhecQvvFXM/O	estudiante	active	f	\N	2025-07-29 13:25:56.085755-05		\N	2025-07-29 13:25:56.223805-05	\N
c5664e3c-37dc-46e1-97b4-a3b06797cf62	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante109	estudiante109@demo.com	$2a$11$sNr.d2g/7VUBgOGX65daYuY1WDTAUAY0.RtEoV3j7vXEPCi751wEa	estudiante	active	f	\N	2025-07-29 13:25:56.406478-05		\N	2025-07-29 13:25:56.543375-05	\N
540dc10d-4b08-49d4-af4a-b23daaa8f7ab	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1100	estudiante1100@demo.com	$2a$11$zDXPQ.h6ml7G8i4zx2oVCO7ypbLtcEE1AVADIYjoBgtanqnnBCunu	estudiante	active	f	\N	2025-07-29 13:25:56.725526-05		\N	2025-07-29 13:25:56.86035-05	\N
bc58b33d-3a60-48e2-89e4-53e286d38683	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1102	estudiante1102@demo.com	$2a$11$8ByH.Ts35sUt2O6TYSoezu3EIZ0/eSBgkniAuOEUT/QOj/Na9qLiO	estudiante	active	f	\N	2025-07-29 13:25:57.040812-05		\N	2025-07-29 13:25:57.176466-05	\N
3435d383-e1e6-49aa-b40c-772e0fa06a7f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1104	estudiante1104@demo.com	$2a$11$qgkrRNsSCNbiCOYVu.BJ5eDlnExS0Ne8uUrCBT1vsCgr142gFXQX2	estudiante	active	f	\N	2025-07-29 13:25:57.355772-05		\N	2025-07-29 13:25:57.492012-05	\N
df857904-9e73-4ffa-beb1-ad3e17b25825	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1106	estudiante1106@demo.com	$2a$11$f20MtfWHLix83I14NrP8temWXT.AMV0CzED8MAwD9Qf4a4MYFEdFa	estudiante	active	f	\N	2025-07-29 13:25:57.674826-05		\N	2025-07-29 13:25:57.81036-05	\N
1907047b-9319-4d99-bdd5-e1cff6b4b072	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1108	estudiante1108@demo.com	$2a$11$qqrop1.1nIdKJDiBUrWsuONppk1lbAXxTw.goWPau.XrYGIjMJQ/S	estudiante	active	f	\N	2025-07-29 13:25:57.990297-05		\N	2025-07-29 13:25:58.125417-05	\N
b0321c73-1559-4cab-b93d-ef590373e65f	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante110	estudiante110@demo.com	$2a$11$LdbXKV8PUWFm.8zBCLFPzONT/1mudXaiU75QyNpIcukCBnjivOjwi	estudiante	active	f	\N	2025-07-29 13:25:58.309267-05		\N	2025-07-29 13:25:58.444771-05	\N
9bea6f88-26cc-47a6-ab78-cb38894822ef	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1111	estudiante1111@demo.com	$2a$11$uhPhyk8UGShEap0/yz4bKOSTaDSefN5WQUL3MaEBRrb.wao/FOBNW	estudiante	active	f	\N	2025-07-29 13:25:58.624237-05		\N	2025-07-29 13:25:58.759783-05	\N
f9e36a9f-b372-4d42-b420-8f9f6a6d53cd	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1113	estudiante1113@demo.com	$2a$11$eluJ00hzKb2/agCSk5WI1uoCiabO.coS7/DrF13g0WylPbRqdZGCO	estudiante	active	f	\N	2025-07-29 13:25:58.940306-05		\N	2025-07-29 13:25:59.079723-05	\N
02d925a0-2ae8-41dc-91d9-c91b046b302a	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1115	estudiante1115@demo.com	$2a$11$HvC3bOPINHvtmoQidw80v.aprUkTEbbgBQgMOpnZGSzzhPyx5coKi	estudiante	active	f	\N	2025-07-29 13:25:59.261938-05		\N	2025-07-29 13:25:59.397366-05	\N
1ee97635-ecf5-430b-8a1d-19b5764e9df2	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1117	estudiante1117@demo.com	$2a$11$szCGh7BC.yS7lLvNkLs59OkJ9jhxR21nTjTutuy/r9x6kk5e0hayO	estudiante	active	f	\N	2025-07-29 13:25:59.580589-05		\N	2025-07-29 13:25:59.71702-05	\N
fa1e439d-f7de-4d96-ae59-ec3f4e86a7c4	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1119	estudiante1119@demo.com	$2a$11$gcRkAbI5hD1ANvz/SLGTKuLhs92P.J0ajM3aPSLpo0uhzmNzGI7A6	estudiante	active	f	\N	2025-07-29 13:25:59.900471-05		\N	2025-07-29 13:26:00.037956-05	\N
a8b3683a-a6f9-4a47-a3e8-29fd24fa65e3	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1120	estudiante1120@demo.com	$2a$11$Ifretou2SWmuj1znVbKqBenOy8VxCB2ZG.ZbYpfh8M10KnXyb94sa	estudiante	active	f	\N	2025-07-29 13:26:00.228619-05		\N	2025-07-29 13:26:00.365179-05	\N
c17f5622-d2df-4367-8dbd-d44aaa06273d	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1122	estudiante1122@demo.com	$2a$11$R7cu8EsXg7YdzmJot7jDq.qUKv30heYTi7Gxqpru9WphP.KUSz.DK	estudiante	active	f	\N	2025-07-29 13:26:00.555321-05		\N	2025-07-29 13:26:00.694193-05	\N
f5ab3892-3d9a-4e2b-8cbd-458c83fdff4b	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1124	estudiante1124@demo.com	$2a$11$y0.hmCiNcjQhXcE3pytum.nW3kFCowEeFRpMzV9EnBZtWTSZkCvh2	estudiante	active	f	\N	2025-07-29 13:26:00.883789-05		\N	2025-07-29 13:26:01.020676-05	\N
2b0fcfca-4a06-4e03-a3df-381169012e73	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1126	estudiante1126@demo.com	$2a$11$xGqtbq2qIsJsEqV7U0hnK.wx6jv4.c1tOdSeZdfiivpg5um2QiCp.	estudiante	active	f	\N	2025-07-29 13:26:01.207076-05		\N	2025-07-29 13:26:01.343714-05	\N
726577ba-bda6-4896-8d44-7c8193ca9ccf	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1128	estudiante1128@demo.com	$2a$11$mNBs9qZJ1LS0WvvBmcsNQOJhnjj3KNd20zqGvm./WtW./4A.0D4SO	estudiante	active	f	\N	2025-07-29 13:26:01.5309-05		\N	2025-07-29 13:26:01.669025-05	\N
f1dada37-a4e5-4f50-b6b5-cbcdf0846047	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante112	estudiante112@demo.com	$2a$11$wfYsfFjgCeweiq06.VTwD./KatEsg7.NB7VsUJHUMqfM8xjNLeALC	estudiante	active	f	\N	2025-07-29 13:26:01.881063-05		\N	2025-07-29 13:26:02.021204-05	\N
bee14904-38af-4255-8bcb-b5b8e5bf2516	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1131	estudiante1131@demo.com	$2a$11$fzZeL4446ZFwlq4Za12R9enRWqGcw3tEVyKhEXNwOafCGK0bwzmBy	estudiante	active	f	\N	2025-07-29 13:26:02.212019-05		\N	2025-07-29 13:26:02.350386-05	\N
c19cec3c-f5f5-41b9-a2af-632a772af984	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1133	estudiante1133@demo.com	$2a$11$zlKkItXfobBYo0/tm13EHucuCUnuPKofWfbUCCxKANl1V456zY.fO	estudiante	active	f	\N	2025-07-29 13:26:02.541699-05		\N	2025-07-29 13:26:02.679746-05	\N
a43bbd16-71ee-4d52-ac9b-e6a052d85936	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1135	estudiante1135@demo.com	$2a$11$tf/18Qw4GnAmxhUQvQU7hu/S4xL2x1Or.fufJq4UMFqFkKpz/pba2	estudiante	active	f	\N	2025-07-29 13:26:02.866832-05		\N	2025-07-29 13:26:03.003841-05	\N
734795aa-fc41-4882-b1e7-0379b0ba6883	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1137	estudiante1137@demo.com	$2a$11$QO2xBHqH.SGWfgcYHmgBZOYisAFHc0gwwChUR2eDr..bcwN9vBKaW	estudiante	active	f	\N	2025-07-29 13:26:03.194751-05		\N	2025-07-29 13:26:03.332911-05	\N
e9174f1f-6cac-4090-b0d7-2656d4819a60	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1139	estudiante1139@demo.com	$2a$11$EUnaw.aHZVCwqf64wmpnRuwZ9V79blVKFqrjKirfcDX018USnfGQy	estudiante	active	f	\N	2025-07-29 13:26:03.521199-05		\N	2025-07-29 13:26:03.661389-05	\N
9a1593d8-41cd-421c-93a1-d31348741041	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1140	estudiante1140@demo.com	$2a$11$4Kr8iCxY6kmmJ4sKDY20M.ByapydiojmkYxgTasaG.rnGX7C48cTO	estudiante	active	f	\N	2025-07-29 13:26:03.852534-05		\N	2025-07-29 13:26:03.989459-05	\N
f04c7270-c1fa-4487-a0e6-0ff980835451	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1142	estudiante1142@demo.com	$2a$11$IL5Atkv6bp3ZHMq8buqCy.emo9E.kzJeJNEzLFP72apzO69HdfQFG	estudiante	active	f	\N	2025-07-29 13:26:04.175215-05		\N	2025-07-29 13:26:04.312984-05	\N
c9bd5d5d-2113-44cb-8402-4ca63810d346	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1144	estudiante1144@demo.com	$2a$11$BWz1QpXzGiD4H1P9KkSzw.Ica1LBfqK/uNMfYIVRRMVOmKjgnOG9O	estudiante	active	f	\N	2025-07-29 13:26:04.502246-05		\N	2025-07-29 13:26:04.639288-05	\N
c3305604-5593-4b5e-84e7-f4455d5083f3	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1146	estudiante1146@demo.com	$2a$11$TySLEIDkiQ02CN8LFxYd.OdU8Nrc6e5Rqjgicogk4GUcJ1SpXY3pK	estudiante	active	f	\N	2025-07-29 13:26:04.826501-05		\N	2025-07-29 13:26:04.964288-05	\N
a3888f38-1c07-4374-98fd-69274762addb	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1148	estudiante1148@demo.com	$2a$11$Ku18f8iOUEvnKadfe0CoZ.q7CfE1XNybN7O54jIOESbVDaLzoIyT2	estudiante	active	f	\N	2025-07-29 13:26:05.154348-05		\N	2025-07-29 13:26:05.291959-05	\N
d0bdf218-8cf3-4930-98af-266649091444	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante114	estudiante114@demo.com	$2a$11$9QwoYqSmUmyBLsmsIt1EpuGqftT6W15oQVhAYO4mvb.4nUyhx91Nq	estudiante	active	f	\N	2025-07-29 13:26:05.481037-05		\N	2025-07-29 13:26:05.622503-05	\N
49aaffaa-d125-4429-b9a6-7c5025324618	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1151	estudiante1151@demo.com	$2a$11$ymTF9tKRoaOaBdZIZKraqee//R/nREo9avN1OIEFoLayWAzd.zX4m	estudiante	active	f	\N	2025-07-29 13:26:05.817039-05		\N	2025-07-29 13:26:05.961793-05	\N
7e7592e9-c21e-452e-8859-71afa7ba8ce0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1153	estudiante1153@demo.com	$2a$11$sI/S0Fpg5S2JH5wAlujXC.nKSjyC.A7ncxGFI1iDxd4gveo6h8RYO	estudiante	active	f	\N	2025-07-29 13:26:06.157007-05		\N	2025-07-29 13:26:06.295675-05	\N
37a47cc8-8cbd-4499-8de7-a0d652dac541	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1149	estudiante1149@demo.com	$2a$11$f76CzDiPNZ5oonYNUu0pGuvjl9LqZFGq.3dv5g/xZJmH9UMjV4112	estudiante	active	f	\N	2025-07-29 13:26:05.315958-05		\N	2025-07-29 13:26:05.453953-05	\N
8c07c3a6-feb0-45ee-bd6c-4861e8a5cfe5	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1150	estudiante1150@demo.com	$2a$11$HZuKROCV15AqbkYlbey00.wEjqoSn5W8w0nRuJVRD1LXApN5f3K52	estudiante	active	f	\N	2025-07-29 13:26:05.649629-05		\N	2025-07-29 13:26:05.787362-05	\N
a4da0dba-3155-4a91-90e2-1071684b9fc0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1152	estudiante1152@demo.com	$2a$11$TDejlzOhRh5QAtr.0xM2YOQ16GvrYAvune543qy4gjgZj9G3G7XpK	estudiante	active	f	\N	2025-07-29 13:26:05.991047-05		\N	2025-07-29 13:26:06.130151-05	\N
75441912-32da-4100-bbb0-ad3f105c2a64	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1154	estudiante1154@demo.com	$2a$11$PubR557D97gfokq6tLcyyuQDfO6VdBZvuOW9lVNrPNoKjpznwQDo.	estudiante	active	f	\N	2025-07-29 13:26:06.321451-05		\N	2025-07-29 13:26:06.459455-05	\N
29f0ff7e-40c5-44d5-8ddf-57340604f094	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1156	estudiante1156@demo.com	$2a$11$mC1/QE5kozmaWcbET4vvLe2wHsVmfnYx69QN5NC5rDzfDLQ/jejBq	estudiante	active	f	\N	2025-07-29 13:26:06.650036-05		\N	2025-07-29 13:26:06.787658-05	\N
b8fbd0ad-2489-475a-af96-d5d7d77ab510	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1158	estudiante1158@demo.com	$2a$11$SWw8eZcCsypVvtBC8PyVKukZbwyVoGJBsxLgj81vsLVRubT2TFYCS	estudiante	active	f	\N	2025-07-29 13:26:06.982332-05		\N	2025-07-29 13:26:07.118822-05	\N
2b58c422-40e9-46c9-88b5-7806cd1367aa	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante115	estudiante115@demo.com	$2a$11$MAUD8M5rU5LnCrT2iHIfbOPT4zcU2KF7kAEdfjhI2OMNkEGDyYAVC	estudiante	active	f	\N	2025-07-29 13:26:07.306676-05		\N	2025-07-29 13:26:07.452768-05	\N
12082507-f379-40fb-8bd5-3bd73333c097	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1161	estudiante1161@demo.com	$2a$11$fX3TFCsRdtjhaWAtuP.3n.dOmvbPry5zhBlQkv8JqXwyVN/KiO75q	estudiante	active	f	\N	2025-07-29 13:26:07.646095-05		\N	2025-07-29 13:26:07.784932-05	\N
294f16c0-7ec5-442e-800a-93fbd75a5af6	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1163	estudiante1163@demo.com	$2a$11$5XhJlqNRaBRF6ScYujdtce2DlIe2OqYU5x1RHyYnYBVTrmI90YwqW	estudiante	active	f	\N	2025-07-29 13:26:07.975951-05		\N	2025-07-29 13:26:08.113133-05	\N
e53acc81-302b-4763-8aa3-670b1b8f93eb	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1165	estudiante1165@demo.com	$2a$11$E.w2u.m41DZKUauILruefOilBZY0Ocfj65cZvkj/Eu/L1nOgLozzu	estudiante	active	f	\N	2025-07-29 13:26:08.30588-05		\N	2025-07-29 13:26:08.444036-05	\N
721d37f4-4f3b-4e85-91c7-a9edb10d4275	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1167	estudiante1167@demo.com	$2a$11$UkXavYTAkEcBq/bPfCE68evMgkwb40XetKSsQZhNB3snnrlKujD5W	estudiante	active	f	\N	2025-07-29 13:26:08.639284-05		\N	2025-07-29 13:26:08.777421-05	\N
72f326a3-4130-4a93-a0a3-d5857c13adb8	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1169	estudiante1169@demo.com	$2a$11$G7Vt6rkFP88jp9KLWXJTKOgbVtU1zMbMq.tAnWy//aIVc2p/INyqe	estudiante	active	f	\N	2025-07-29 13:26:08.963998-05		\N	2025-07-29 13:26:09.100692-05	\N
6923b570-cf40-406c-8f67-fe549fc9b479	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1170	estudiante1170@demo.com	$2a$11$owpYFMaZmRrvnTzYHlEjkOp9FrCdM8axdK9wZOztVyy1Dqk39JpRW	estudiante	active	f	\N	2025-07-29 13:26:09.287079-05		\N	2025-07-29 13:26:09.424868-05	\N
2b81b5b5-42d7-4fc0-87e2-57eb8ec983df	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1172	estudiante1172@demo.com	$2a$11$DideLq6CBZ82mVnUmKjBYOL8ZxAL7a6NjwGHYlz28LCNu.byIanye	estudiante	active	f	\N	2025-07-29 13:26:09.608968-05		\N	2025-07-29 13:26:09.744853-05	\N
fc3e0c12-4156-4305-aa36-16cda070d052	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1174	estudiante1174@demo.com	$2a$11$13IorBMYuRVSlxBvgkElIOluMvw03k09/RPmI9R3zQDXkzBIzZiAS	estudiante	active	f	\N	2025-07-29 13:26:09.928675-05		\N	2025-07-29 13:26:10.066071-05	\N
05784877-22cd-409e-b71b-ecdd1b978c22	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1176	estudiante1176@demo.com	$2a$11$gi15tqbmiTh4goQSeyECw.2jbGjSA0nNVtWAhgiX4Lhmg0IOPD0ra	estudiante	active	f	\N	2025-07-29 13:26:10.253155-05		\N	2025-07-29 13:26:10.39106-05	\N
e2f5489e-bf15-43d4-89c2-8310d1f4c089	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1178	estudiante1178@demo.com	$2a$11$GI8h4IRa8qhB9YKUM0E3fekKUD8yLrJLTEMqi646hQdAuf9PfxYEa	estudiante	active	f	\N	2025-07-29 13:26:10.581868-05		\N	2025-07-29 13:26:10.722069-05	\N
ca41fc7d-689b-4e7c-b2c9-fffaa5f996d1	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante117	estudiante117@demo.com	$2a$11$azVePMMVsaJwcc3p2RPMe.DQcbwsluaozM3kX1P1ps03AjMhrlDf2	estudiante	active	f	\N	2025-07-29 13:26:10.916296-05		\N	2025-07-29 13:26:11.054451-05	\N
05114f2f-e189-49ef-a251-e740f4a6ff07	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1155	estudiante1155@demo.com	$2a$11$2OZKwRDXSrGpQ9gHWLg1N.7n4DrNeNXDRRZRcKoP8lstido2C8r3m	estudiante	active	f	\N	2025-07-29 13:26:06.48445-05		\N	2025-07-29 13:26:06.624344-05	\N
bb8883ae-bb00-47eb-96a8-82b9537db6b0	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1157	estudiante1157@demo.com	$2a$11$B7bNZrDWNxTOj07fTJSHc.Di2WjIhwGvIHh4fi9gw/Xakt0SJ7glK	estudiante	active	f	\N	2025-07-29 13:26:06.81584-05		\N	2025-07-29 13:26:06.953865-05	\N
531884ce-5d5b-47fe-86f3-9a320a04203c	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1159	estudiante1159@demo.com	$2a$11$0rOUJGWk.qs6QKCcffDZAuPRQ5.BwWo.qBvf0oeelCUDnm/23Rvue	estudiante	active	f	\N	2025-07-29 13:26:07.14379-05		\N	2025-07-29 13:26:07.280356-05	\N
d052de6a-be0f-4815-9f56-8d5bd69e5f2e	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1160	estudiante1160@demo.com	$2a$11$mkmZBVJHP19KthgphlBH8Ox4QZ7KB41Ik7NqptQ3Emt6AJF1qW6Wa	estudiante	active	f	\N	2025-07-29 13:26:07.479685-05		\N	2025-07-29 13:26:07.61943-05	\N
0bb46acb-4a6f-4f56-a071-850cc1612e56	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1162	estudiante1162@demo.com	$2a$11$u5WsG2nZSxS2TYd7e/tXYeCDBcZ43AGaRZEREPzCLYe20knf5s8Ge	estudiante	active	f	\N	2025-07-29 13:26:07.810989-05		\N	2025-07-29 13:26:07.949209-05	\N
e20b9ea4-0a97-42dd-9caa-62dffc758344	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1164	estudiante1164@demo.com	$2a$11$zSLJraqbsp4rVaUEcS0yfuU8YzeBxfQZ/6yw.kPkt3iLGqbrw/zaG	estudiante	active	f	\N	2025-07-29 13:26:08.141046-05		\N	2025-07-29 13:26:08.277982-05	\N
2c758dcc-0969-4171-8fc0-bb55d7252f76	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1166	estudiante1166@demo.com	$2a$11$DJASLN3Wculvc0j/RJSvbe6oDR7w.C4/w9nW.3jS0677azM2ozGBW	estudiante	active	f	\N	2025-07-29 13:26:08.472572-05		\N	2025-07-29 13:26:08.611025-05	\N
c494d668-0da3-4c33-a17f-1b5b5e2301bc	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1168	estudiante1168@demo.com	$2a$11$o9LM5K8Renn6KVg.d4bbpODDc/.ZLZBTcRMY7UKYtb4vmhfaRIV6e	estudiante	active	f	\N	2025-07-29 13:26:08.802235-05		\N	2025-07-29 13:26:08.938634-05	\N
873cbfd2-d247-47f0-a8fc-19a139a7f158	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante116	estudiante116@demo.com	$2a$11$wM8voEqct59NxS0NrNNIhe32mkmnYsuirhClkmWQWGPkJlifBAIqq	estudiante	active	f	\N	2025-07-29 13:26:09.126232-05		\N	2025-07-29 13:26:09.263269-05	\N
289e3869-f9b9-4d56-8ac3-ae7acfee3a44	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1171	estudiante1171@demo.com	$2a$11$.uF3q5CylM6UkmO.InNPm.7OQ80s25AOXsSEXkmcNqpwhhFS0PDIa	estudiante	active	f	\N	2025-07-29 13:26:09.449293-05		\N	2025-07-29 13:26:09.585699-05	\N
c939a7e9-00a6-431b-a85b-d439a436a316	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1173	estudiante1173@demo.com	$2a$11$1fxO3bqnwlOdgemCW7YjG.Y9xv/2W6jSIoQEK8eTH2YxsGBJE4VEO	estudiante	active	f	\N	2025-07-29 13:26:09.76898-05		\N	2025-07-29 13:26:09.905615-05	\N
4488bd8c-309d-460a-b91f-352bba181eda	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1175	estudiante1175@demo.com	$2a$11$/e0g6ldmeErFpNMEEJYvWOwv7v6nJznavuOvAKw2.bC//VRyIQgZ.	estudiante	active	f	\N	2025-07-29 13:26:10.089024-05		\N	2025-07-29 13:26:10.227563-05	\N
1e48b713-25c6-4638-ae7f-021e46a69753	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1177	estudiante1177@demo.com	$2a$11$sY4RbE9pxsKu5wiaU8WQw.PcjEWv/9mz0ZYRMfnPMwDvdEyWuUNTK	estudiante	active	f	\N	2025-07-29 13:26:10.417555-05		\N	2025-07-29 13:26:10.556164-05	\N
16636ccf-8a68-400b-9275-b64a496aa03d	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1179	estudiante1179@demo.com	$2a$11$ddh01hyMZYAGks13qCdKcetSJvKDu5xqHWTJ1kr27.M2WA0fe9cdW	estudiante	active	f	\N	2025-07-29 13:26:10.747302-05		\N	2025-07-29 13:26:10.884293-05	\N
95822fb7-a49c-4247-b8bf-eb921817e8d9	181abc51-1e01-4c32-8684-a636a18b3f47	estudiante1180	estudiante1180@demo.com	$2a$11$0jAybXcBpOVwpNJGKso3Zu2.t5/evHSQ.oJ37XpnFroniMRXtr9tK	estudiante	active	f	\N	2025-07-29 13:26:11.084413-05		\N	2025-07-29 13:26:11.225521-05	\N
\.


--
-- TOC entry 4900 (class 2606 OID 161757)
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- TOC entry 4912 (class 2606 OID 161832)
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- TOC entry 4918 (class 2606 OID 161841)
-- Name: activity_attachments activity_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 4923 (class 2606 OID 161858)
-- Name: activity_types activity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_pkey PRIMARY KEY (id);


--
-- TOC entry 4927 (class 2606 OID 161870)
-- Name: area area_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--
-- TOC entry 4933 (class 2606 OID 161877)
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- TOC entry 4937 (class 2606 OID 161891)
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4944 (class 2606 OID 161900)
-- Name: discipline_reports discipline_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 4903 (class 2606 OID 161814)
-- Name: grade_levels grade_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grade_levels
    ADD CONSTRAINT grade_levels_pkey PRIMARY KEY (id);


--
-- TOC entry 4947 (class 2606 OID 161914)
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- TOC entry 4950 (class 2606 OID 161923)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 4953 (class 2606 OID 161939)
-- Name: security_settings security_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 4906 (class 2606 OID 161823)
-- Name: specialties specialties_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specialties
    ADD CONSTRAINT specialties_pkey PRIMARY KEY (id);


--
-- TOC entry 4977 (class 2606 OID 162035)
-- Name: student_activity_scores student_activity_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 4983 (class 2606 OID 162052)
-- Name: student_assignments student_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT student_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4987 (class 2606 OID 162074)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 4973 (class 2606 OID 162003)
-- Name: subject_assignments subject_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4957 (class 2606 OID 161954)
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 4999 (class 2606 OID 162136)
-- Name: teacher_assignments teacher_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_pkey PRIMARY KEY (id);


--
-- TOC entry 4961 (class 2606 OID 161974)
-- Name: trimester trimester_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_pkey PRIMARY KEY (id);


--
-- TOC entry 4990 (class 2606 OID 162089)
-- Name: user_grades user_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT user_grades_pkey PRIMARY KEY (user_id, grade_id);


--
-- TOC entry 4993 (class 2606 OID 162104)
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (user_id, group_id);


--
-- TOC entry 4996 (class 2606 OID 162119)
-- Name: user_subjects user_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT user_subjects_pkey PRIMARY KEY (user_id, subject_id);


--
-- TOC entry 4966 (class 2606 OID 161991)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4907 (class 1259 OID 162151)
-- Name: IX_activities_ActivityTypeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_ActivityTypeId" ON public.activities USING btree ("ActivityTypeId");


--
-- TOC entry 4908 (class 1259 OID 162154)
-- Name: IX_activities_TrimesterId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_TrimesterId" ON public.activities USING btree ("TrimesterId");


--
-- TOC entry 4909 (class 1259 OID 162152)
-- Name: IX_activities_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_school_id" ON public.activities USING btree (school_id);


--
-- TOC entry 4910 (class 1259 OID 162153)
-- Name: IX_activities_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activities_subject_id" ON public.activities USING btree (subject_id);


--
-- TOC entry 4920 (class 1259 OID 162157)
-- Name: IX_activity_types_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_activity_types_school_id" ON public.activity_types USING btree (school_id);


--
-- TOC entry 4924 (class 1259 OID 162159)
-- Name: IX_area_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_area_school_id" ON public.area USING btree (school_id);


--
-- TOC entry 4928 (class 1259 OID 162160)
-- Name: IX_attendance_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_grade_id" ON public.attendance USING btree (grade_id);


--
-- TOC entry 4929 (class 1259 OID 162161)
-- Name: IX_attendance_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_group_id" ON public.attendance USING btree (group_id);


--
-- TOC entry 4930 (class 1259 OID 162162)
-- Name: IX_attendance_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_student_id" ON public.attendance USING btree (student_id);


--
-- TOC entry 4931 (class 1259 OID 162163)
-- Name: IX_attendance_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_attendance_teacher_id" ON public.attendance USING btree (teacher_id);


--
-- TOC entry 4934 (class 1259 OID 162164)
-- Name: IX_audit_logs_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_audit_logs_school_id" ON public.audit_logs USING btree (school_id);


--
-- TOC entry 4935 (class 1259 OID 162165)
-- Name: IX_audit_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_audit_logs_user_id" ON public.audit_logs USING btree (user_id);


--
-- TOC entry 4938 (class 1259 OID 162166)
-- Name: IX_discipline_reports_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_grade_level_id" ON public.discipline_reports USING btree (grade_level_id);


--
-- TOC entry 4939 (class 1259 OID 162167)
-- Name: IX_discipline_reports_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_group_id" ON public.discipline_reports USING btree (group_id);


--
-- TOC entry 4940 (class 1259 OID 162168)
-- Name: IX_discipline_reports_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_student_id" ON public.discipline_reports USING btree (student_id);


--
-- TOC entry 4941 (class 1259 OID 162169)
-- Name: IX_discipline_reports_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_subject_id" ON public.discipline_reports USING btree (subject_id);


--
-- TOC entry 4942 (class 1259 OID 162170)
-- Name: IX_discipline_reports_teacher_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_discipline_reports_teacher_id" ON public.discipline_reports USING btree (teacher_id);


--
-- TOC entry 4945 (class 1259 OID 162172)
-- Name: IX_groups_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_groups_school_id" ON public.groups USING btree (school_id);


--
-- TOC entry 4948 (class 1259 OID 162356)
-- Name: IX_schools_admin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_schools_admin_id" ON public.schools USING btree (admin_id);


--
-- TOC entry 4951 (class 1259 OID 162174)
-- Name: IX_security_settings_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_security_settings_school_id" ON public.security_settings USING btree (school_id);


--
-- TOC entry 4979 (class 1259 OID 162179)
-- Name: IX_student_assignments_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_grade_id" ON public.student_assignments USING btree (grade_id);


--
-- TOC entry 4980 (class 1259 OID 162180)
-- Name: IX_student_assignments_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_group_id" ON public.student_assignments USING btree (group_id);


--
-- TOC entry 4981 (class 1259 OID 162181)
-- Name: IX_student_assignments_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_student_assignments_student_id" ON public.student_assignments USING btree (student_id);


--
-- TOC entry 4984 (class 1259 OID 162182)
-- Name: IX_students_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_students_parent_id" ON public.students USING btree (parent_id);


--
-- TOC entry 4985 (class 1259 OID 162183)
-- Name: IX_students_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_students_school_id" ON public.students USING btree (school_id);


--
-- TOC entry 4967 (class 1259 OID 162368)
-- Name: IX_subject_assignments_SchoolId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_SchoolId" ON public.subject_assignments USING btree ("SchoolId");


--
-- TOC entry 4968 (class 1259 OID 162184)
-- Name: IX_subject_assignments_area_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_area_id" ON public.subject_assignments USING btree (area_id);


--
-- TOC entry 4969 (class 1259 OID 162185)
-- Name: IX_subject_assignments_grade_level_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_grade_level_id" ON public.subject_assignments USING btree (grade_level_id);


--
-- TOC entry 4970 (class 1259 OID 162186)
-- Name: IX_subject_assignments_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_group_id" ON public.subject_assignments USING btree (group_id);


--
-- TOC entry 4971 (class 1259 OID 162187)
-- Name: IX_subject_assignments_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subject_assignments_subject_id" ON public.subject_assignments USING btree (subject_id);


--
-- TOC entry 4954 (class 1259 OID 162189)
-- Name: IX_subjects_AreaId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subjects_AreaId" ON public.subjects USING btree ("AreaId");


--
-- TOC entry 4955 (class 1259 OID 162190)
-- Name: IX_subjects_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_subjects_school_id" ON public.subjects USING btree (school_id);


--
-- TOC entry 4997 (class 1259 OID 162191)
-- Name: IX_teacher_assignments_subject_assignment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_teacher_assignments_subject_assignment_id" ON public.teacher_assignments USING btree (subject_assignment_id);


--
-- TOC entry 4958 (class 1259 OID 162193)
-- Name: IX_trimester_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_trimester_school_id" ON public.trimester USING btree (school_id);


--
-- TOC entry 4988 (class 1259 OID 162195)
-- Name: IX_user_grades_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_grades_grade_id" ON public.user_grades USING btree (grade_id);


--
-- TOC entry 4991 (class 1259 OID 162196)
-- Name: IX_user_groups_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_groups_group_id" ON public.user_groups USING btree (group_id);


--
-- TOC entry 4994 (class 1259 OID 162197)
-- Name: IX_user_subjects_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_user_subjects_subject_id" ON public.user_subjects USING btree (subject_id);


--
-- TOC entry 4962 (class 1259 OID 162198)
-- Name: IX_users_school_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_users_school_id" ON public.users USING btree (school_id);


--
-- TOC entry 4921 (class 1259 OID 162156)
-- Name: activity_types_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX activity_types_name_school_key ON public.activity_types USING btree (name, school_id);


--
-- TOC entry 4925 (class 1259 OID 162158)
-- Name: area_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX area_name_school_key ON public.area USING btree (name, school_id);


--
-- TOC entry 4901 (class 1259 OID 162171)
-- Name: grade_levels_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX grade_levels_name_key ON public.grade_levels USING btree (name);


--
-- TOC entry 4913 (class 1259 OID 162147)
-- Name: idx_activities_group; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_group ON public.activities USING btree (group_id);


--
-- TOC entry 4914 (class 1259 OID 162148)
-- Name: idx_activities_teacher; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_teacher ON public.activities USING btree (teacher_id);


--
-- TOC entry 4915 (class 1259 OID 162149)
-- Name: idx_activities_trimester; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_trimester ON public.activities USING btree (trimester);


--
-- TOC entry 4916 (class 1259 OID 162150)
-- Name: idx_activities_unique_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_activities_unique_lookup ON public.activities USING btree (name, type, subject_id, group_id, teacher_id, trimester);


--
-- TOC entry 4919 (class 1259 OID 162155)
-- Name: idx_attach_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attach_activity ON public.activity_attachments USING btree (activity_id);


--
-- TOC entry 4974 (class 1259 OID 162176)
-- Name: idx_scores_activity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scores_activity ON public.student_activity_scores USING btree (activity_id);


--
-- TOC entry 4975 (class 1259 OID 162177)
-- Name: idx_scores_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scores_student ON public.student_activity_scores USING btree (student_id);


--
-- TOC entry 4904 (class 1259 OID 162175)
-- Name: specialties_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX specialties_name_key ON public.specialties USING btree (name);


--
-- TOC entry 5000 (class 1259 OID 162192)
-- Name: teacher_assignments_teacher_id_subject_assignment_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX teacher_assignments_teacher_id_subject_assignment_id_key ON public.teacher_assignments USING btree (teacher_id, subject_assignment_id);


--
-- TOC entry 4959 (class 1259 OID 162194)
-- Name: trimester_name_school_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX trimester_name_school_key ON public.trimester USING btree (name, school_id);


--
-- TOC entry 4978 (class 1259 OID 162178)
-- Name: uq_scores; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_scores ON public.student_activity_scores USING btree (student_id, activity_id);


--
-- TOC entry 4963 (class 1259 OID 162199)
-- Name: users_document_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_document_id_key ON public.users USING btree (document_id);


--
-- TOC entry 4964 (class 1259 OID 162200)
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- TOC entry 5001 (class 2606 OID 162201)
-- Name: activities FK_activities_activity_types_ActivityTypeId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_activity_types_ActivityTypeId" FOREIGN KEY ("ActivityTypeId") REFERENCES public.activity_types(id);


--
-- TOC entry 5002 (class 2606 OID 162206)
-- Name: activities FK_activities_trimester_TrimesterId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT "FK_activities_trimester_TrimesterId" FOREIGN KEY ("TrimesterId") REFERENCES public.trimester(id);


--
-- TOC entry 5022 (class 2606 OID 162357)
-- Name: schools FK_schools_users_admin_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT "FK_schools_users_admin_id" FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- TOC entry 5028 (class 2606 OID 162369)
-- Name: subject_assignments FK_subject_assignments_schools_SchoolId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT "FK_subject_assignments_schools_SchoolId" FOREIGN KEY ("SchoolId") REFERENCES public.schools(id);


--
-- TOC entry 5024 (class 2606 OID 161955)
-- Name: subjects FK_subjects_area_AreaId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT "FK_subjects_area_AreaId" FOREIGN KEY ("AreaId") REFERENCES public.area(id);


--
-- TOC entry 5003 (class 2606 OID 162211)
-- Name: activities activities_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5004 (class 2606 OID 162216)
-- Name: activities activities_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5005 (class 2606 OID 162221)
-- Name: activities activities_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5006 (class 2606 OID 162226)
-- Name: activities activities_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5007 (class 2606 OID 161842)
-- Name: activity_attachments activity_attachments_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_attachments
    ADD CONSTRAINT activity_attachments_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5008 (class 2606 OID 162231)
-- Name: activity_types activity_types_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_types
    ADD CONSTRAINT activity_types_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5009 (class 2606 OID 162236)
-- Name: area area_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.area
    ADD CONSTRAINT area_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5010 (class 2606 OID 161878)
-- Name: attendance attendance_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5011 (class 2606 OID 162241)
-- Name: attendance attendance_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5012 (class 2606 OID 162246)
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5013 (class 2606 OID 162251)
-- Name: attendance attendance_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5014 (class 2606 OID 162256)
-- Name: audit_logs audit_logs_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- TOC entry 5015 (class 2606 OID 162261)
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5016 (class 2606 OID 161901)
-- Name: discipline_reports discipline_reports_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5017 (class 2606 OID 162266)
-- Name: discipline_reports discipline_reports_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5018 (class 2606 OID 162271)
-- Name: discipline_reports discipline_reports_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5019 (class 2606 OID 162281)
-- Name: discipline_reports discipline_reports_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5020 (class 2606 OID 162276)
-- Name: discipline_reports discipline_reports_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discipline_reports
    ADD CONSTRAINT discipline_reports_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5036 (class 2606 OID 162053)
-- Name: student_assignments fk_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5037 (class 2606 OID 162058)
-- Name: student_assignments fk_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5038 (class 2606 OID 162063)
-- Name: student_assignments fk_student; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_assignments
    ADD CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5041 (class 2606 OID 162090)
-- Name: user_grades fk_user_grades_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_grade FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5042 (class 2606 OID 162095)
-- Name: user_grades fk_user_grades_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_grades
    ADD CONSTRAINT fk_user_grades_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5043 (class 2606 OID 162105)
-- Name: user_groups fk_user_groups_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_group FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5044 (class 2606 OID 162110)
-- Name: user_groups fk_user_groups_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_user_groups_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5045 (class 2606 OID 162120)
-- Name: user_subjects fk_user_subjects_subject; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_subject FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5046 (class 2606 OID 162125)
-- Name: user_subjects fk_user_subjects_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_subjects
    ADD CONSTRAINT fk_user_subjects_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5021 (class 2606 OID 162286)
-- Name: groups groups_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5023 (class 2606 OID 161940)
-- Name: security_settings security_settings_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.security_settings
    ADD CONSTRAINT security_settings_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5034 (class 2606 OID 162036)
-- Name: student_activity_scores student_activity_scores_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id) ON DELETE CASCADE;


--
-- TOC entry 5035 (class 2606 OID 162041)
-- Name: student_activity_scores student_activity_scores_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_activity_scores
    ADD CONSTRAINT student_activity_scores_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- TOC entry 5039 (class 2606 OID 162075)
-- Name: students students_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.users(id);


--
-- TOC entry 5040 (class 2606 OID 162080)
-- Name: students students_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5029 (class 2606 OID 162004)
-- Name: subject_assignments subject_assignments_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.area(id);


--
-- TOC entry 5030 (class 2606 OID 162009)
-- Name: subject_assignments subject_assignments_grade_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_grade_level_id_fkey FOREIGN KEY (grade_level_id) REFERENCES public.grade_levels(id);


--
-- TOC entry 5031 (class 2606 OID 162014)
-- Name: subject_assignments subject_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id);


--
-- TOC entry 5032 (class 2606 OID 162019)
-- Name: subject_assignments subject_assignments_specialty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_specialty_id_fkey FOREIGN KEY (specialty_id) REFERENCES public.specialties(id);


--
-- TOC entry 5033 (class 2606 OID 162024)
-- Name: subject_assignments subject_assignments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- TOC entry 5025 (class 2606 OID 161960)
-- Name: subjects subjects_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 5047 (class 2606 OID 162137)
-- Name: teacher_assignments teacher_assignments_subject_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_subject_assignment_id_fkey FOREIGN KEY (subject_assignment_id) REFERENCES public.subject_assignments(id);


--
-- TOC entry 5048 (class 2606 OID 162142)
-- Name: teacher_assignments teacher_assignments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teacher_assignments
    ADD CONSTRAINT teacher_assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id);


--
-- TOC entry 5026 (class 2606 OID 161975)
-- Name: trimester trimester_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trimester
    ADD CONSTRAINT trimester_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 5027 (class 2606 OID 175968)
-- Name: users users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


-- Completed on 2025-09-05 08:03:01

--
-- PostgreSQL database dump complete
--

