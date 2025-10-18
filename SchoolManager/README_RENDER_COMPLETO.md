# 🚀 Guía Completa para Render - Análisis y Generación de Datos

**Fecha:** 16 de Octubre, 2025

---

## 🎯 Objetivo

Analizar las relaciones existentes en Render y generar datos dummy completos para probar todas las funcionalidades del sistema EduPlanner, incluyendo el sistema de notas.

---

## 📋 Scripts Disponibles

### 1️⃣ **ScriptCompletoRender.sql** - Script Principal
**Ejecuta todo el proceso completo en secuencia**

```sql
-- Ejecutar en pgAdmin o psql:
\i ScriptCompletoRender.sql
```

### 2️⃣ **ConsultasAnalisisRender.sql** - Análisis de Relaciones
**Analiza cómo están relacionados los datos existentes**

```sql
\i ConsultasAnalisisRender.sql
```

### 3️⃣ **CargarDatosDummyCompletos.sql** - Carga de Datos
**Carga estudiantes, profesores y estructura académica**

```sql
\i CargarDatosDummyCompletos.sql
```

### 4️⃣ **VerificarAsignacionesProfesores.sql** - Asignaciones
**Verifica y crea asignaciones de profesores y estudiantes**

```sql
\i VerificarAsignacionesProfesores.sql
```

### 5️⃣ **GenerarActividadesYNotas.sql** - Sistema de Notas
**Genera actividades y notas para todos los estudiantes**

```sql
\i GenerarActividadesYNotas.sql
```

### 6️⃣ **VerificarDatosRender.sql** - Verificación Final
**Verifica todos los datos generados y sus relaciones**

```sql
\i VerificarDatosRender.sql
```

---

## 🚀 Instrucciones de Ejecución

### Opción 1: Ejecución Completa (Recomendada)
```bash
# Conectar a la base de datos de Render
psql "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true"

# Ejecutar script completo
\i ScriptCompletoRender.sql
```

### Opción 2: Ejecución Paso a Paso
```bash
# 1. Análisis de relaciones existentes
\i ConsultasAnalisisRender.sql

# 2. Cargar datos dummy completos
\i CargarDatosDummyCompletos.sql

# 3. Verificar y completar asignaciones
\i VerificarAsignacionesProfesores.sql

# 4. Generar actividades y notas
\i GenerarActividadesYNotas.sql

# 5. Verificación final
\i VerificarDatosRender.sql
```

---

## 📊 Datos que se Generarán

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
- **50+ asignaciones de estudiantes** a grados/grupos
- **100+ asignaciones de materias** a grados/grupos
- **50+ asignaciones de profesores** a materias

### 📊 Sistema de Notas
- **3 trimestres** (Trimestre I, II, III)
- **6 tipos de actividades** (Evaluación, Tarea, Proyecto, Participación, Laboratorio, Práctica)
- **100+ actividades** distribuidas por trimestre
- **500+ calificaciones** con distribución realista:
  - 10% notas bajas (1.0-2.0)
  - 20% notas regulares (2.0-3.0)
  - 40% notas buenas (3.0-4.0)
  - 30% notas excelentes (4.0-5.0)

---

## ✅ Verificaciones Post-Ejecución

### 1. Verificar Estudiantes con Notas
```sql
SELECT 
    COUNT(DISTINCT u.id) as total_estudiantes,
    COUNT(DISTINCT sas.student_id) as estudiantes_con_notas,
    ROUND(COUNT(DISTINCT sas.student_id)::DECIMAL / COUNT(DISTINCT u.id) * 100, 1) as porcentaje_con_notas
FROM users u
LEFT JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active';
```

### 2. Verificar Actividades Generadas
```sql
SELECT 
    a.trimester as trimestre,
    a.type as tipo_actividad,
    COUNT(a.id) as total_actividades,
    COUNT(sas.id) as total_calificaciones
FROM activities a
LEFT JOIN student_activity_scores sas ON a.id = sas.activity_id
GROUP BY a.trimester, a.type
ORDER BY a.trimester, a.type;
```

### 3. Verificar Promedios por Materia
```sql
SELECT 
    s.name as materia,
    a.name as area,
    COUNT(sas.id) as total_calificaciones,
    ROUND(AVG(sas.score), 2) as promedio_general
FROM subjects s
INNER JOIN areas a ON s."AreaId" = a.id
INNER JOIN activities act ON s.id = act.subject_id
INNER JOIN student_activity_scores sas ON act.id = sas.activity_id
GROUP BY s.id, s.name, a.name
ORDER BY promedio_general DESC;
```

---

## 🎯 Módulos Listos para Pruebas

Después de ejecutar los scripts, estos módulos estarán completamente funcionales:

### ✅ Gestión de Usuarios
- Lista de estudiantes con filtros por rol
- Estudiantes inclusivos identificados
- Profesores con asignaciones

### ✅ Asignaciones
- Estudiantes asignados a grados/grupos
- Profesores asignados a materias
- Materias asignadas a grados/grupos

### ✅ Sistema de Notas
- Actividades por trimestre
- Calificaciones para todos los estudiantes
- Promedios por materia y estudiante
- Reportes de notas

### ✅ Reportes
- Reportes de estudiantes inclusivos
- Reportes de asignaciones
- Reportes de profesores
- Reportes de notas y promedios

### ✅ Catálogo Académico
- Materias por área
- Grupos por grado
- Especialidades disponibles

---

## 📈 Estadísticas Esperadas

Después de ejecutar todos los scripts:

- **Estudiantes**: 30+ con datos realistas
- **Profesores**: 10+ con asignaciones
- **Materias**: 14+ con códigos
- **Actividades**: 100+ distribuidas por trimestre
- **Calificaciones**: 500+ con distribución realista
- **Promedio general**: 3.5-4.0 (realista)
- **Cobertura de notas**: 90%+ de estudiantes

---

## ⚠️ Notas Importantes

1. **Seguridad**: Los scripts usan `ON CONFLICT DO NOTHING` para evitar duplicados
2. **Datos Realistas**: Los datos siguen patrones realistas de distribución
3. **Fácil Limpieza**: Se pueden limpiar fácilmente con queries de DELETE
4. **Idempotente**: Se pueden ejecutar múltiples veces sin problemas
5. **Relaciones**: Todas las relaciones entre tablas están correctamente establecidas

---

## 🔧 Solución de Problemas

### Error: "No hay estudiantes con asignaciones"
```sql
-- Verificar asignaciones de estudiantes
SELECT COUNT(*) FROM student_assignments;
```

### Error: "No hay profesores con asignaciones"
```sql
-- Verificar asignaciones de profesores
SELECT COUNT(*) FROM teacher_assignments;
```

### Error: "No hay actividades generadas"
```sql
-- Verificar actividades
SELECT COUNT(*) FROM activities;
```

### Error: "No hay calificaciones"
```sql
-- Verificar calificaciones
SELECT COUNT(*) FROM student_activity_scores;
```

---

## 📞 Soporte

Si encuentras problemas al ejecutar los scripts:

1. Verifica la conexión a la base de datos de Render
2. Ejecuta los scripts en orden
3. Revisa los logs de error
4. Contacta al equipo de desarrollo

---

**¡Sistema completamente funcional y listo para pruebas!** 🎉
