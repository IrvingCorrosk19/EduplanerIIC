# Diferencias: base de datos Render vs Local

**Fecha del análisis:** generado por comparación automática (script `--compare-db-schemas`).

**Origen de datos:**
- **Local:** `localhost` / base de datos `schoolmanagement` (referencia considerada más nueva).
- **Render:** `dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com` / base de datos `schoolmanagement_xqks`.

---

## 1. Resumen ejecutivo

| Concepto | En Local | En Render | Diferencia |
|----------|----------|-----------|------------|
| Tablas solo en Local (faltan en Render) | 1 | — | `student_payment_access` |
| Tablas solo en Render (no en Local) | — | 0 | Ninguna |
| Columnas en tablas comunes (solo en Local) | — | 0 | Homologadas |
| Índices solo en Local | 7 | — | Todos asociados a `student_payment_access` |
| Constraints CHECK solo en Local | 0 | — | Ninguno |

**Conclusión:** La única diferencia estructural es que en **Render no existe la tabla `student_payment_access`** (ni sus índices). El resto de tablas y columnas están alineadas.

---

## 2. Tablas que existen en LOCAL y NO en RENDER

Estas tablas hay que crearlas en Render si se desea homologar el esquema.

| Tabla | Uso |
|-------|-----|
| `student_payment_access` | Módulo Club de Padres: estado de pago de carnet y acceso a plataforma por estudiante/escuela. |

---

## 3. Tablas que existen en RENDER y NO en LOCAL

Ninguna. No hay tablas en Render que no existan en Local.

---

## 4. Columnas: diferencias en tablas comunes

En las tablas que existen en **ambas** bases, no hay columnas que existan en Local y falten en Render.  
Las diferencias de “columnas” vienen únicamente de que la tabla `student_payment_access` no existe en Render, por lo que todas sus columnas faltan allí.

---

## 5. Definición de la tabla que falta en Render

Para crear en Render la tabla `student_payment_access` y sus índices (y dejar el esquema alineado con Local), puede usarse el siguiente SQL:

```sql
CREATE TABLE IF NOT EXISTS student_payment_access (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    student_id uuid NOT NULL,
    school_id uuid NOT NULL,
    carnet_status character varying(20) NOT NULL DEFAULT 'Pendiente',
    platform_access_status character varying(20) NOT NULL DEFAULT 'Pendiente',
    carnet_status_updated_at timestamp with time zone NULL,
    platform_status_updated_at timestamp with time zone NULL,
    carnet_updated_by_user_id uuid NULL,
    platform_updated_by_user_id uuid NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NULL,
    CONSTRAINT student_payment_access_pkey PRIMARY KEY (id),
    CONSTRAINT student_payment_access_student_id_fkey FOREIGN KEY (student_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT student_payment_access_school_id_fkey FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE RESTRICT,
    CONSTRAINT student_payment_access_carnet_updated_by_fkey FOREIGN KEY (carnet_updated_by_user_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT student_payment_access_platform_updated_by_fkey FOREIGN KEY (platform_updated_by_user_id) REFERENCES users (id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS IX_student_payment_access_student_id ON student_payment_access (student_id);
CREATE INDEX IF NOT EXISTS IX_student_payment_access_school_id ON student_payment_access (school_id);
CREATE INDEX IF NOT EXISTS IX_student_payment_access_carnet_status_school_id ON student_payment_access (carnet_status, school_id);
CREATE UNIQUE INDEX IF NOT EXISTS IX_student_payment_access_student_id_school_id ON student_payment_access (student_id, school_id);
CREATE INDEX IF NOT EXISTS IX_student_payment_access_carnet_updated_by_user_id ON student_payment_access (carnet_updated_by_user_id);
CREATE INDEX IF NOT EXISTS IX_student_payment_access_platform_updated_by_user_id ON student_payment_access (platform_updated_by_user_id);
```

### Columnas de `student_payment_access`

| Columna | Tipo | Nulable | Default / Notas |
|---------|------|---------|------------------|
| id | uuid | NOT NULL | uuid_generate_v4() |
| student_id | uuid | NOT NULL | FK → users(id) |
| school_id | uuid | NOT NULL | FK → schools(id) |
| carnet_status | character varying(20) | NOT NULL | 'Pendiente' |
| platform_access_status | character varying(20) | NOT NULL | 'Pendiente' |
| carnet_status_updated_at | timestamp with time zone | NULL | |
| platform_status_updated_at | timestamp with time zone | NULL | |
| carnet_updated_by_user_id | uuid | NULL | FK → users(id) |
| platform_updated_by_user_id | uuid | NULL | FK → users(id) |
| created_at | timestamp with time zone | NOT NULL | CURRENT_TIMESTAMP |
| updated_at | timestamp with time zone | NULL | |

---

## 6. Índices que existen en LOCAL y NO en RENDER

Todos corresponden a la tabla `student_payment_access`, que en Render no existe:

| Índice |
|--------|
| student_payment_access_pkey |
| ix_student_payment_access_carnet_status_school_id |
| ix_student_payment_access_carnet_updated_by_user_id |
| ix_student_payment_access_platform_updated_by_user_id |
| ix_student_payment_access_school_id |
| ix_student_payment_access_student_id |
| ix_student_payment_access_student_id_school_id (UNIQUE) |

Al crear la tabla en Render con el SQL de la sección 5, estos índices quedan creados.

---

## 7. Constraints CHECK

No hay constraints CHECK presentes en Local que falten en Render. El constraint `users_role_check` está aplicado en ambas bases (incluye los roles clubparentsadmin, qlservices, inspector).

---

## 8. Aplicar la tabla en Render (script disponible)

El proyecto incluye un script que crea `student_payment_access` en Render si no existe. **Detén la aplicación** (para poder compilar) y ejecuta:

```bash
dotnet run -- --apply-render-student-payment-access
```

El script se ejecuta al inicio (no arranca el servidor web), se conecta a Render y ejecuta el DDL. Si la tabla ya existe, indica "Nada que hacer".

---

## 9. Cómo regenerar este análisis

Sin modificar código, desde la raíz del proyecto:

```bash
dotnet run --no-build -- --compare-db-schemas
```

La salida en consola refleja las mismas diferencias (tablas, columnas en tablas comunes, índices y checks) entre Local y Render.
