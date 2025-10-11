# 📐 DIAGRAMAS DEL SISTEMA EDUPLANNER

## 🏗️ DIAGRAMA DE ARQUITECTURA GENERAL

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USUARIOS                                   │
│  SuperAdmin │ Admin │ Director │ Teacher │ Student │ Parent         │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Controllers (MVC) - 26 controladores                        │   │
│  │  - AuthController, UserController, StudentController...     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Views (Razor) - 52+ vistas                                 │   │
│  │  - Login, Dashboard, Gradebook, Attendance...               │   │
│  └─────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  ViewModels - 27 modelos de vista                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         │ Dependency Injection
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                                 │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Services (Business Logic) - 33 servicios                   │   │
│  │  - IUserService, IActivityService, IAttendanceService...    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  DTOs (Data Transfer Objects) - 36 DTOs                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Mappings (AutoMapper)                                       │   │
│  └─────────────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         │ Entity Framework Core 9.0
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    DATA ACCESS LAYER                                 │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  DbContext (SchoolDbContext)                                │   │
│  │  - OnModelCreating (configuración de entidades)             │   │
│  │  - DateTimeInterceptor (conversión UTC)                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Models (Entities) - 31 modelos                             │   │
│  │  - User, School, Activity, Attendance, Grade...             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  Migrations - 23 migraciones                                │   │
│  └─────────────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                         │ Npgsql 9.0.4 (PostgreSQL Driver)
                         │ SSL/TLS Connection
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    DATABASE LAYER                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  PostgreSQL 18.0 (Render Cloud - Oregon)                    │   │
│  │  - 27 tablas principales                                     │   │
│  │  - 64 índices                                                │   │
│  │  - Extensions: uuid-ossp, pgcrypto                          │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    CROSS-CUTTING CONCERNS                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │ Authentication│  │ Authorization│  │   Auditing   │             │
│  │  (Cookies)   │  │    (Roles)   │  │ (AuditLogs)  │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Logging    │  │   DateTime   │  │    Email     │             │
│  │  (Console)   │  │  (Middleware)│  │   (SMTP)     │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🗄️ DIAGRAMA DE BASE DE DATOS (SIMPLIFICADO)

```
┌─────────────────────────────────────────────────────────────────────┐
│                      MULTI-TENANT SCHEMA                             │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│    schools       │ ◄──┐
├──────────────────┤    │
│ id (PK)          │    │
│ name             │    │
│ address          │    │ 1:1
│ phone            │    │
│ logo_url         │    │
│ admin_id (FK) ───┼────┤
└──────────────────┘    │
         │              │
         │ 1:N          │
         ▼              │
┌──────────────────┐    │
│   users          │ ───┘
├──────────────────┤
│ id (PK)          │
│ school_id (FK)   │◄───────────────┐
│ name             │                 │
│ last_name        │                 │
│ email (UNIQUE)   │                 │
│ password_hash    │                 │
│ role (ENUM)      │                 │
│ status           │                 │
│ document_id      │                 │
│ cellphone_*      │                 │
│ disciplina       │                 │
│ orientacion      │                 │
│ inclusivo        │                 │
│ created_by (FK) ─┼─────┐           │
│ updated_by (FK) ─┼──┐  │           │
└──────────────────┘  │  │           │
         │            │  │           │
         │ 1:N        │  │           │
         ▼            │  │           │
┌──────────────────┐  │  │           │
│ audit_logs       │  │  │           │
├──────────────────┤  │  │           │
│ id (PK)          │  │  │           │
│ school_id (FK)   │  │  │           │
│ user_id (FK) ────┼──┘  │           │
│ action           │     │           │
│ resource         │     │           │
│ details (JSON)   │     │           │
│ ip_address       │     │           │
│ timestamp        │     │           │
└──────────────────┘     │           │
                         │           │

┌─────────────────────────────────────────────────────────────────────┐
│                      ACADEMIC CATALOG                                │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│  grade_levels    │       │     groups       │       │     subjects     │
├──────────────────┤       ├──────────────────┤       ├──────────────────┤
│ id (PK)          │       │ id (PK)          │       │ id (PK)          │
│ name             │       │ name             │       │ name             │
│ description      │       │ grade            │       │ code             │
│ school_id (FK) ──┼──┐    │ description      │       │ description      │
└──────────────────┘  │    │ school_id (FK) ──┼──┐    │ area_id (FK) ────┼──┐
         │            │    └──────────────────┘  │    │ school_id (FK)   │  │
         │ 1:N        │             │            │    └──────────────────┘  │
         ▼            │             │ 1:N        │             │            │
┌──────────────────┐  │             ▼            │             │ 1:N        │
│  specialties     │  │    ┌──────────────────┐  │             ▼            │
├──────────────────┤  │    │      area        │  │    ┌──────────────────┐  │
│ id (PK)          │  │    ├──────────────────┤  │    │  activity_types  │  │
│ name             │  │    │ id (PK)          │◄─┘    ├──────────────────┤  │
│ description      │  │    │ name             │       │ id (PK)          │  │
│ school_id (FK)   │  │    │ code             │       │ name             │  │
└──────────────────┘  │    │ description      │       │ icon             │  │
         │            │    │ school_id (FK)   │       │ color            │  │
         │            │    └──────────────────┘       │ is_global        │  │
         │            │                               │ school_id (FK)   │  │
         │            │                               └──────────────────┘  │
         │            │                                        │            │
         │            │                                        │            │
         ▼            ▼                                        ▼            ▼
┌─────────────────────────────────────────────────────────────────────┐
│              subject_assignments (Materia → Grado-Grupo)            │
├─────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                              │
│ specialty_id (FK) ─────► specialties                                │
│ area_id (FK) ──────────► area                                       │
│ subject_id (FK) ───────► subjects                                   │
│ grade_level_id (FK) ───► grade_levels                               │
│ group_id (FK) ─────────► groups                                     │
│ school_id (FK) ────────► schools                                    │
│ status                                                               │
└─────────────────────────────────────────────────────────────────────┘
         │
         │ 1:N
         ▼
┌─────────────────────────────────────────────────────────────────────┐
│          teacher_assignments (Docente → SubjectAssignment)          │
├─────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                              │
│ teacher_id (FK) ────────────────────► users                         │
│ subject_assignment_id (FK) ─────────► subject_assignments           │
│ UNIQUE (teacher_id, subject_assignment_id)                          │
└─────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────┐
│          student_assignments (Estudiante → Grado-Grupo)             │
├─────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                              │
│ student_id (FK) ────────► users                                     │
│ grade_id (FK) ──────────► grade_levels                              │
│ group_id (FK) ──────────► groups                                    │
└─────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────┐
│      counselor_assignments (Orientador → Grado-Grupo)               │
├─────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                              │
│ school_id (FK) ──────────► schools                                  │
│ user_id (FK) ────────────► users                                    │
│ grade_id (FK) ───────────► grade_levels                             │
│ group_id (FK) ───────────► groups                                   │
│ is_counselor                                                         │
│ is_active                                                            │
│ UNIQUE (school_id, user_id)                                         │
│ UNIQUE (school_id, grade_id, group_id) WHERE grade_id IS NOT NULL  │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    ACADEMIC PERIODS                                  │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│   trimester      │
├──────────────────┤
│ id (PK)          │
│ school_id (FK) ──┼────────► schools
│ name             │
│ order            │
│ start_date       │
│ end_date         │
│ is_active        │
└──────────────────┘
         │
         │ 1:N
         ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         activities                                    │
├──────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                               │
│ school_id (FK) ────────────────► schools                             │
│ teacher_id (FK) ───────────────► users                               │
│ subject_id (FK) ───────────────► subjects                            │
│ group_id (FK) ─────────────────► groups                              │
│ grade_level_id (FK) ───────────► grade_levels                        │
│ activity_type_id (FK) ─────────► activity_types                      │
│ trimester_id (FK) ─────────────► trimester                           │
│ name                                                                  │
│ type                                                                  │
│ due_date                                                              │
│ pdf_url                                                               │
│ created_by, updated_by (FK) ───► users                               │
└──────────────────────────────────────────────────────────────────────┘
         │                              │
         │ 1:N                          │ 1:N
         ▼                              ▼
┌─────────────────────┐       ┌────────────────────────────┐
│ activity_attachments│       │ student_activity_scores    │
├─────────────────────┤       ├────────────────────────────┤
│ id (PK)             │       │ id (PK)                    │
│ activity_id (FK) ───┼──┐    │ student_id (FK) ──────────┼──► users
│ file_name           │  │    │ activity_id (FK) ─────────┼──┐
│ storage_path        │  │    │ score (NUMERIC 2,1)       │  │
│ mime_type           │  └───►│ school_id (FK)            │  │
│ uploaded_at         │       │ created_by, updated_by    │  │
└─────────────────────┘       │ UNIQUE (student_id,       │  │
                              │         activity_id)       │  │
                              └────────────────────────────┘  │
                                                              │
                                                              └── activities

┌─────────────────────────────────────────────────────────────────────┐
│                  ATTENDANCE & REPORTS                                │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                         attendance                                    │
├──────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                               │
│ student_id (FK) ───────────────► users                               │
│ teacher_id (FK) ───────────────► users (quien registra)              │
│ group_id (FK) ─────────────────► groups                              │
│ grade_id (FK) ─────────────────► grade_levels                        │
│ date (DATE)                                                           │
│ status (P/A/T/J)                                                      │
│ school_id (FK) ────────────────► schools                             │
│ created_by, updated_by (FK) ───► users                               │
└──────────────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────────┐
│                    discipline_reports                                 │
├──────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                               │
│ student_id (FK) ───────────────► users                               │
│ teacher_id (FK) ───────────────► users (quien reporta)               │
│ subject_id (FK) ───────────────► subjects                            │
│ group_id (FK) ─────────────────► groups                              │
│ grade_level_id (FK) ───────────► grade_levels                        │
│ date (timestamp)                                                      │
│ report_type (varchar 50)                                             │
│ category (TEXT)                                                       │
│ description (TEXT)                                                    │
│ documents (TEXT - JSON paths)                                        │
│ status (pendiente/revisado/resuelto)                                 │
│ school_id (FK) ────────────────► schools                             │
│ created_by, updated_by (FK) ───► users                               │
└──────────────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────────┐
│                    orientation_reports                                │
├──────────────────────────────────────────────────────────────────────┤
│ (Estructura idéntica a discipline_reports)                           │
│ Enfoque: Seguimiento académico/emocional                             │
└──────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     MANY-TO-MANY TABLES                              │
└─────────────────────────────────────────────────────────────────────┘

┌───────────────┐        ┌───────────────┐        ┌─────────────────┐
│ user_grades   │        │ user_groups   │        │ user_subjects   │
├───────────────┤        ├───────────────┤        ├─────────────────┤
│ user_id  (FK) │        │ user_id  (FK) │        │ user_id  (FK)   │
│ grade_id (FK) │        │ group_id (FK) │        │ subject_id (FK) │
│ PK (user_id,  │        │ PK (user_id,  │        │ PK (user_id,    │
│     grade_id) │        │     group_id) │        │     subject_id) │
└───────────────┘        └───────────────┘        └─────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     CONFIGURATION TABLES                             │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                    email_configurations                               │
├──────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                               │
│ school_id (FK) ────────────────► schools                             │
│ smtp_server, smtp_port                                               │
│ smtp_username, smtp_password                                         │
│ smtp_use_ssl, smtp_use_tls                                           │
│ from_email, from_name                                                │
│ is_active                                                             │
└──────────────────────────────────────────────────────────────────────┘


┌──────────────────────────────────────────────────────────────────────┐
│                     security_settings                                 │
├──────────────────────────────────────────────────────────────────────┤
│ id (PK)                                                               │
│ school_id (FK) ────────────────► schools                             │
│ password_min_length (default: 8)                                     │
│ require_uppercase, require_lowercase                                 │
│ require_numbers, require_special                                     │
│ expiry_days (default: 90)                                            │
│ prevent_reuse (default: 5)                                           │
│ max_login_attempts (default: 5)                                      │
│ session_timeout_minutes (default: 30)                                │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 DIAGRAMA DE FLUJO: REGISTRO DE CALIFICACIONES

```
┌─────────────────────────────────────────────────────────────────────┐
│                   FLUJO: Registro de Calificaciones                  │
└─────────────────────────────────────────────────────────────────────┘

    START
      │
      ▼
┌───────────────┐
│ Docente Login │
└───────┬───────┘
        │
        ▼
┌──────────────────────────┐
│ Ver Portal Docente       │
│ - Materias asignadas     │
│ - Grupos                 │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Seleccionar:             │
│ - Materia                │
│ - Grupo                  │
│ - Trimestre              │
└───────┬──────────────────┘
        │
        ▼
    ┌───────┐
    │ ¿Ya    │
    │ existe │ NO
    │ activ?─┼────────► Crear Nueva Actividad
    └───┬───┘              │
        │ SÍ               ├─ Nombre
        │                  ├─ Tipo (Examen/Tarea/Proyecto)
        │                  ├─ Fecha límite
        │                  └─ Archivo adjunto (opcional)
        │                              │
        ▼                              │
┌──────────────────────────┐          │
│ Seleccionar Actividad    │◄─────────┘
│ Existente                │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Ver Lista de Estudiantes │
│ del Grupo                │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Registrar Calificación   │
│ por Estudiante           │
│                          │
│ Rango: 0.0 - 9.9        │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Sistema Valida:          │
│ - Rango válido           │
│ - No duplicados          │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Guardar en BD            │
│ (student_activity_scores)│
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Sistema Calcula          │
│ Promedio Automático      │
│ por Estudiante/Trimestre │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Registrar Auditoría      │
│ (audit_logs)             │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Mostrar Confirmación     │
└───────┬──────────────────┘
        │
        ▼
      END
```

---

## 🔄 DIAGRAMA DE FLUJO: CONTROL DE ASISTENCIA

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FLUJO: Control de Asistencia                      │
└─────────────────────────────────────────────────────────────────────┘

    START
      │
      ▼
┌───────────────┐
│ Docente Login │
└───────┬───────┘
        │
        ▼
┌──────────────────────────┐
│ Ir a Módulo Asistencia   │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Seleccionar:             │
│ - Fecha (hoy por def.)   │
│ - Grado                  │
│ - Grupo                  │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Sistema Carga Lista de   │
│ Estudiantes del Grupo    │
└───────┬──────────────────┘
        │
        ▼
    ┌───────┐
    │ ¿Ya    │
    │ existe │ SÍ
    │ regist?─┼──────► Mostrar Registro Existente
    └───┬───┘         (Modo Edición)
        │ NO              │
        │                 │
        ▼                 │
┌──────────────────────────┐
│ Mostrar Lista Vacía      │◄────┘
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Por cada Estudiante:     │
│ Marcar Estado:           │
│                          │
│ ┌──┐ P - Presente        │
│ ├──┤ A - Ausente         │
│ ├──┤ T - Tardanza        │
│ └──┘ J - Justificado     │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ ¿Confirmar               │
│  Registro? ──────────NO──┼──► Cancelar
└───────┬──────────────────┘
        │ SÍ
        ▼
┌──────────────────────────┐
│ Guardar en BD            │
│ (attendance)             │
│ - student_id             │
│ - teacher_id             │
│ - date                   │
│ - status                 │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Actualizar Estadísticas  │
│ de Asistencia            │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Registrar Auditoría      │
│ (audit_logs)             │
└───────┬──────────────────┘
        │
        ▼
┌──────────────────────────┐
│ Mostrar Confirmación     │
│ + Resumen:               │
│ - Presentes: X           │
│ - Ausentes: Y            │
│ - Tardanzas: Z           │
└───────┬──────────────────┘
        │
        ▼
      END
```

---

## 🔄 DIAGRAMA DE SECUENCIA: AUTENTICACIÓN

```
Usuario          Browser       AuthController    UserService      Database
  │                │                 │               │               │
  │  1. Ir a Login │                 │               │               │
  ├───────────────>│                 │               │               │
  │                │                 │               │               │
  │                │  2. GET /Auth/Login            │               │
  │                ├────────────────>│               │               │
  │                │                 │               │               │
  │                │  3. Return View │               │               │
  │                │<────────────────┤               │               │
  │                │                 │               │               │
  │ 4. Mostrar Form│                 │               │               │
  │<───────────────┤                 │               │               │
  │                │                 │               │               │
  │ 5. Ingresar    │                 │               │               │
  │    Email+Pass  │                 │               │               │
  ├───────────────>│                 │               │               │
  │                │                 │               │               │
  │                │  6. POST /Auth/Login            │               │
  │                │     [LoginViewModel]            │               │
  │                ├────────────────>│               │               │
  │                │                 │               │               │
  │                │                 │ 7. ValidateUser(email, pass) │
  │                │                 ├──────────────>│               │
  │                │                 │               │               │
  │                │                 │               │ 8. SELECT user
  │                │                 │               ├──────────────>│
  │                │                 │               │               │
  │                │                 │               │ 9. User record
  │                │                 │               │<──────────────┤
  │                │                 │               │               │
  │                │                 │ 10. BCrypt.Verify(pass, hash)
  │                │                 │               │               │
  │                │                 │ 11. Valid User│               │
  │                │                 │<──────────────┤               │
  │                │                 │               │               │
  │                │ 12. Create Auth Cookie          │               │
  │                │     (Claims: Id, Name, Role)   │               │
  │                │                 │               │               │
  │                │                 │ 13. UPDATE last_login          │
  │                │                 ├──────────────────────────────>│
  │                │                 │               │               │
  │                │                 │ 14. INSERT audit_log (LOGIN) │
  │                │                 ├──────────────────────────────>│
  │                │                 │               │               │
  │                │ 15. Redirect /Home/Index       │               │
  │                │<────────────────┤               │               │
  │                │                 │               │               │
  │ 16. Dashboard  │                 │               │               │
  │<───────────────┤                 │               │               │
  │                │                 │               │               │
```

---

## 📊 DIAGRAMA DE COMPONENTES

```
┌─────────────────────────────────────────────────────────────────────┐
│                        WEB APPLICATION                               │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                     FRONTEND                                │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  Views (Razor)                                        │  │    │
│  │  │  - _AdminLayout.cshtml                               │  │    │
│  │  │  - Login.cshtml, Dashboard.cshtml                    │  │    │
│  │  │  - Gradebook/*.cshtml, Attendance/*.cshtml           │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  Static Files (wwwroot)                              │  │    │
│  │  │  ├─ css/ (Bootstrap, Custom)                         │  │    │
│  │  │  ├─ js/ (jQuery, Custom)                             │  │    │
│  │  │  ├─ lib/ (Bootstrap, FontAwesome)                    │  │    │
│  │  │  ├─ images/ (logos)                                  │  │    │
│  │  │  └─ uploads/ (user files)                            │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                   BACKEND (MVC)                             │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  Controllers                                          │  │    │
│  │  │  - AuthController                                     │  │    │
│  │  │  - UserController                                     │  │    │
│  │  │  - TeacherGradebookController                        │  │    │
│  │  │  - AttendanceController                              │  │    │
│  │  │  - DisciplineReportController                        │  │    │
│  │  │  - (21 more controllers)                             │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  ViewModels / DTOs                                    │  │    │
│  │  │  - LoginViewModel                                     │  │    │
│  │  │  - ActivityDto                                        │  │    │
│  │  │  - AttendanceDto                                      │  │    │
│  │  │  - (30+ more DTOs)                                    │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                   BUSINESS LOGIC                            │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  Services (Interfaces + Implementations)             │  │    │
│  │  │  - IAuthService / AuthService                         │  │    │
│  │  │  - IUserService / UserService                         │  │    │
│  │  │  - IActivityService / ActivityService                 │  │    │
│  │  │  - IAttendanceService / AttendanceService            │  │    │
│  │  │  - (29 more services)                                 │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  AutoMapper Profiles                                  │  │    │
│  │  │  - Model ↔ DTO ↔ ViewModel                           │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                   DATA ACCESS                               │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  DbContext (SchoolDbContext)                          │  │    │
│  │  │  - Entities Configuration                             │  │    │
│  │  │  - Relationships                                      │  │    │
│  │  │  - Constraints                                        │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  Models (Entities)                                    │  │    │
│  │  │  - User, School, Activity, Grade, etc.               │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  │  ┌──────────────────────────────────────────────────────┐  │    │
│  │  │  EF Core Migrations                                   │  │    │
│  │  └──────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                   MIDDLEWARE                                │    │
│  │  - Authentication Middleware                                │    │
│  │  - Authorization Middleware                                 │    │
│  │  - DateTime Conversion Middleware                           │    │
│  │  - Exception Handler Middleware                             │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 │ Npgsql Driver
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│              POSTGRESQL DATABASE (Render Cloud)                      │
│  - 27 Tables                                                         │
│  - 64 Indexes                                                        │
│  - Foreign Keys, Constraints                                         │
│  - Extensions: uuid-ossp, pgcrypto                                  │
└─────────────────────────────────────────────────────────────────────┘
```

---

**Fecha:** 10 de Octubre de 2025  
**Versión:** 1.0

