# 📝 Cómo Crear la Tabla Messages en tu Base de Datos Local

## ⚡ Método Rápido (RECOMENDADO)

### Opción 1: Usando pgAdmin (Más fácil)

1. **Abre pgAdmin**

2. **Conecta a tu servidor PostgreSQL**
   - Servidor: `localhost`
   - Usuario: `postgres`
   - Contraseña: `Panama2020$`

3. **Navega a la base de datos**
   ```
   📂 Servers
     └── 📂 PostgreSQL 
         └── 📂 Databases
             └── 📂 schoolmanagement
   ```

4. **Abre Query Tool**
   - Clic derecho en `schoolmanagement`
   - Selecciona **"Query Tool"**

5. **Ejecuta el script**
   - Abre el archivo: `EjecutarMigracionMessages.sql`
   - Copia TODO el contenido
   - Pégalo en Query Tool
   - Presiona **F5** o clic en el botón ▶️ **Execute/Refresh**

6. **Verifica el resultado**
   - Deberías ver en la salida:
     ```
     ✅✅✅ TABLA MESSAGES CREADA EXITOSAMENTE ✅✅✅
     📊 Columnas creadas: 18
     🔍 Índices creados: 8
     ⚡ Triggers creados: 1
     ```

7. **Confirma que existe**
   - En pgAdmin, refresca (F5)
   - Ve a: `schoolmanagement → Schemas → public → Tables`
   - Deberías ver la tabla **`messages`**

---

### Opción 2: Desde la Terminal (Si tienes psql configurado)

Abre PowerShell en la carpeta del proyecto y ejecuta:

```powershell
# Navega a la carpeta del proyecto
cd C:\Proyectos\Proyectos\EduPlanner\EduPlanner\SchoolManager

# Ejecuta el script (ajusta la ruta de psql según tu instalación)
& "C:\Program Files\PostgreSQL\16\bin\psql.exe" -h localhost -U postgres -d schoolmanagement -f EjecutarMigracionMessages.sql
```

---

## ✅ Verificación Post-Creación

### Verificar en pgAdmin:

1. Ve a: `schoolmanagement → Schemas → public → Tables`
2. Busca: **`messages`**
3. Clic derecho → **Properties** para ver detalles

### Verificar con SQL:

Ejecuta esto en Query Tool:

```sql
-- Ver estructura
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'messages'
ORDER BY ordinal_position;

-- Ver índices
SELECT indexname FROM pg_indexes
WHERE tablename = 'messages';

-- Contar registros (debería ser 0)
SELECT COUNT(*) FROM messages;
```

---

## 🎯 Después de Crear la Tabla

1. **Inicia tu aplicación:**
   ```powershell
   dotnet run
   ```

2. **Accede al módulo de mensajería:**
   ```
   http://localhost:5172/Messaging/Inbox
   ```

3. **Prueba enviando un mensaje**

---

## 📋 Estructura de la Tabla Creada

La tabla `messages` incluye:

**Columnas principales:**
- `id` - UUID único
- `sender_id` - Quien envía
- `recipient_id` - Quien recibe
- `school_id` - Multi-tenancy
- `subject` - Asunto (máx 200 caracteres)
- `content` - Contenido (máx 5000 caracteres)
- `message_type` - Tipo: Individual, Group, AllTeachers, etc.
- `sent_at` - Fecha de envío
- `is_read` - Estado de lectura
- `priority` - Low, Normal, High, Urgent

**Características:**
- ✅ 7 índices para optimización
- ✅ Trigger automático para `updated_at`
- ✅ Validaciones de CHECK
- ✅ Relaciones con foreign keys
- ✅ Soporte para mensajes anidados (respuestas)
- ✅ Soft delete

---

## ❓ Solución de Problemas

### Error: "uuid_generate_v4 no existe"

Ejecuta esto primero:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Error: "la tabla ya existe"

Si ves este error, significa que la tabla YA ESTÁ CREADA. Verifica:
```sql
SELECT * FROM messages;
```

### Error de permisos

Asegúrate de estar conectado como usuario `postgres` o un usuario con permisos de creación.

---

## 📁 Archivos Relacionados

- ✅ `EjecutarMigracionMessages.sql` - Script principal (USA ESTE)
- 📄 `Migrations/CreateMessagesTable.sql` - Script original
- 📄 `VerificarTablaMessages.sql` - Script de verificación
- 📖 `ESTADO_MODULO_MENSAJERIA.md` - Documentación completa

---

## 🆘 Si Necesitas Ayuda

1. Verifica que PostgreSQL esté corriendo
2. Verifica que la base de datos `schoolmanagement` existe
3. Verifica tus credenciales de conexión
4. Revisa los logs de PostgreSQL para más detalles

---

**✅ Una vez creada la tabla, tu módulo de mensajería estará completamente funcional.**

