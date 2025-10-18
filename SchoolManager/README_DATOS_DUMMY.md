# 📚 Guía de Carga de Datos Dummy para Render

**Fecha:** 16 de Octubre, 2025

---

## 🎯 Objetivo

Analizar y cargar datos dummy completos en la base de datos de Render para probar todas las funcionalidades del sistema EduPlanner.

---

## 📋 Scripts Disponibles

### 1️⃣ **ScriptMaestroDatosDummy.sql** - Script Principal
**Ejecuta todos los análisis y cargas en secuencia**

```sql
-- Ejecutar en pgAdmin o psql:
\i ScriptMaestroDatosDummy.sql
```

### 2️⃣ **AnalizarDatosRender.sql** - Análisis Inicial
**Analiza el estado actual de la base de datos**

```sql
\i AnalizarDatosRender.sql
```

### 3️⃣ **ActualizarEstudiantesInclusivos.sql** - Estudiantes Inclusivos
**Actualiza el campo inclusivo de estudiantes existentes**

```sql
\i ActualizarEstudiantesInclusivos.sql
```

### 4️⃣ **CargarDatosDummyCompletos.sql** - Carga Completa
**Carga estudiantes, profesores y estructura académica**

```sql
\i CargarDatosDummyCompletos.sql
```

### 5️⃣ **VerificarAsignacionesProfesores.sql** - Asignaciones
**Verifica y crea asignaciones de profesores y estudiantes**

```sql
\i VerificarAsignacionesProfesores.sql
```

---

## 🚀 Instrucciones de Ejecución

### Opción 1: Ejecución Completa (Recomendada)
```bash
# Conectar a la base de datos de Render
psql "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true"

# Ejecutar script maestro
\i ScriptMaestroDatosDummy.sql
```

### Opción 2: Ejecución Paso a Paso
```bash
# 1. Análisis inicial
\i AnalizarDatosRender.sql

# 2. Actualizar estudiantes inclusivos
\i ActualizarEstudiantesInclusivos.sql

# 3. Cargar datos completos
\i CargarDatosDummyCompletos.sql

# 4. Verificar asignaciones
\i VerificarAsignacionesProfesores.sql
```

---

## 📊 Datos que se Cargarán

### 👥 Usuarios
- **30 estudiantes** con datos realistas
- **10 profesores** con datos realistas
- **30% estudiantes inclusivos** (aleatorio)
- **20% estudiantes con orientación** (aleatorio)
- **10% estudiantes con disciplina** (aleatorio)

### 📚 Estructura Académica
- **6 grados** (7° a 12°)
- **13 grupos** (7°A, 7°B, 8°A, 8°B, 9°A, 9°B, 10°A, 10°B, 10°C, 11°A, 11°B, 12°A, 12°B)
- **8 áreas** (Matemáticas, Ciencias, Lengua, Historia, Geografía, Educación Física, Arte, Música)
- **5 especialidades** (Bachiller en Ciencias, Letras, Comercio, Técnico en Informática, Contabilidad)
- **14 materias** con códigos y descripciones

### 🔗 Asignaciones
- **50 asignaciones de estudiantes** a grados/grupos
- **100 asignaciones de materias** a grados/grupos
- **50 asignaciones de profesores** a materias

---

## ✅ Verificaciones Post-Carga

### 1. Verificar Estudiantes Inclusivos
```sql
SELECT 
    COUNT(*) as total_estudiantes,
    COUNT(CASE WHEN inclusivo = true THEN 1 END) as inclusivos,
    ROUND(COUNT(CASE WHEN inclusivo = true THEN 1 END)::DECIMAL / COUNT(*) * 100, 1) as porcentaje_inclusivos
FROM users 
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active';
```

### 2. Verificar Asignaciones de Profesores
```sql
SELECT 
    COUNT(DISTINCT u.id) as profesores_con_asignaciones,
    COUNT(ta.id) as total_asignaciones
FROM users u
INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
WHERE u.role IN ('teacher', 'Teacher') 
AND u.status = 'active';
```

### 3. Verificar Asignaciones de Estudiantes
```sql
SELECT 
    COUNT(DISTINCT u.id) as estudiantes_con_asignaciones,
    COUNT(sa.id) as total_asignaciones
FROM users u
INNER JOIN student_assignments sa ON u.id = sa.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active';
```

---

## 🎯 Módulos Listos para Pruebas

Después de ejecutar los scripts, estos módulos estarán listos para pruebas:

### ✅ Gestión de Usuarios
- Lista de estudiantes con filtros por rol
- Estudiantes inclusivos identificados
- Profesores con asignaciones

### ✅ Asignaciones
- Estudiantes asignados a grados/grupos
- Profesores asignados a materias
- Materias asignadas a grados/grupos

### ✅ Reportes
- Reportes de estudiantes inclusivos
- Reportes de asignaciones
- Reportes de profesores

### ✅ Catálogo Académico
- Materias por área
- Grupos por grado
- Especialidades disponibles

---

## ⚠️ Notas Importantes

1. **Seguridad**: Los scripts usan `ON CONFLICT DO NOTHING` para evitar duplicados
2. **Datos Realistas**: Los datos siguen patrones realistas de distribución
3. **Fácil Limpieza**: Se pueden limpiar fácilmente con queries de DELETE
4. **Idempotente**: Se pueden ejecutar múltiples veces sin problemas

---

## 🔧 Solución de Problemas

### Error: "No hay estudiantes"
```sql
-- Verificar que existan estudiantes
SELECT COUNT(*) FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante');
```

### Error: "No hay profesores"
```sql
-- Verificar que existan profesores
SELECT COUNT(*) FROM users WHERE role IN ('teacher', 'Teacher');
```

### Error: "No hay materias"
```sql
-- Verificar que existan materias
SELECT COUNT(*) FROM subjects;
```

---

## 📞 Soporte

Si encuentras problemas al ejecutar los scripts:

1. Verifica la conexión a la base de datos
2. Ejecuta los scripts en orden
3. Revisa los logs de error
4. Contacta al equipo de desarrollo

---

**¡Sistema listo para pruebas completas!** 🎉
