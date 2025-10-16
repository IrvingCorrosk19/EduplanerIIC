# 📚 Guía de Datos de Prueba para EduPlanner

**Fecha:** 16 de Octubre, 2025

---

## 🎯 Scripts Disponibles

### 1️⃣ **DatosDummyNotasCompleto.sql** - Sistema de Notas

**Qué crea:**
- ✅ **15-30 actividades** de prueba (exámenes, tareas, proyectos)
- ✅ Actividades para **3 trimestres** (T1, T2, T3)
- ✅ **Calificaciones** para hasta 20 estudiantes
- ✅ Notas variadas: 60% buenas, 30% regulares, 10% bajas
- ✅ **Casos especiales:**
  - Estudiante con notas perfectas (5.0)
  - Estudiante con notas bajas (necesita recuperación)
  - Algunas actividades sin calificar

**Cómo ejecutar:**
```sql
-- En pgAdmin o psql:
\i DatosDummyNotasCompleto.sql

-- O desde Query Tool de pgAdmin:
-- Abrir archivo → Ejecutar (F5)
```

**Resultados esperados:**
```
✅ DATOS DUMMY DE NOTAS CREADOS EXITOSAMENTE
========================================================

📚 ACTIVIDADES CREADAS:
   Total de actividades: 33
   - Trimestre I: 15
   - Trimestre II: 10
   - Trimestre III: 8

📊 CALIFICACIONES GENERADAS:
   Total de calificaciones: 450+
   Promedio general: 3.7
   Nota mínima: 1.0
   Nota máxima: 5.0
```

---

### 2️⃣ **DatosDummyMessages.sql** - Sistema de Mensajería

**Qué crea:**
- ✅ **10 mensajes** de prueba
- ✅ Diferentes tipos: Individual, Grupo, AllTeachers, AllStudents
- ✅ Diferentes prioridades: Low, Normal, High, Urgent
- ✅ Mensajes leídos y no leídos
- ✅ Hilos de conversación (respuestas)

**Cómo ejecutar:**
```sql
-- En pgAdmin o psql:
\i DatosDummyMessages.sql
```

---

## 📊 Qué Puedes Probar con Estos Datos

### 🎓 Módulo de Reportes de Estudiantes

**Ruta:** `/StudentReport/Index`

**Pruebas:**
1. ✅ Ver notas por trimestre
2. ✅ Filtrar por materia
3. ✅ Ver promedio general
4. ✅ Identificar materias con notas bajas
5. ✅ Ver actividades pendientes

**Estudiantes especiales para probar:**
- **Primer estudiante** → Notas perfectas (5.0)
- **Último estudiante** → Notas bajas (1.0 - 2.5)
- **Otros** → Notas variadas

---

### 📈 Módulo de Aprobados/Reprobados

**Ruta:** `/AprobadosReprobados/Index`

**Pruebas:**
1. ✅ Ver cuadro por grado
2. ✅ Filtrar por trimestre
3. ✅ Ver estudiantes aprobados (≥3.0)
4. ✅ Ver estudiantes reprobados (<3.0)
5. ✅ Descargar PDF

**Datos esperados:**
- Aprox. 60-70% aprobados
- Aprox. 20-30% reprobados
- Aprox. 10% sin datos (T3)

---

### 📝 Libro de Calificaciones del Profesor

**Ruta:** `/TeacherGradebook/Index`

**Pruebas:**
1. ✅ Ver lista de estudiantes
2. ✅ Ver actividades por trimestre
3. ✅ Ingresar/editar calificaciones
4. ✅ Ver promedios automáticos
5. ✅ Filtrar por grupo/materia

---

### 📧 Sistema de Mensajería

**Ruta:** `/Messaging/Inbox`

**Pruebas:**
1. ✅ Ver bandeja de entrada
2. ✅ Mensajes no leídos
3. ✅ Mensajes urgentes
4. ✅ Responder mensajes
5. ✅ Enviar nuevo mensaje
6. ✅ Buscar mensajes

---

## 🔍 Consultas SQL Útiles

### Ver Promedio por Estudiante

```sql
SELECT 
    u.name || ' ' || u.last_name AS estudiante,
    a.trimester,
    COUNT(sas.id) AS actividades,
    ROUND(AVG(sas.score), 2) AS promedio,
    CASE 
        WHEN AVG(sas.score) >= 3.0 THEN 'APROBADO'
        ELSE 'REPROBADO'
    END AS estado
FROM users u
JOIN student_activity_scores sas ON sas.student_id = u.id
JOIN activities a ON a.id = sas.activity_id
WHERE a.name LIKE '[PRUEBA%'
GROUP BY u.id, u.name, u.last_name, a.trimester
ORDER BY promedio DESC;
```

### Ver Actividades por Materia

```sql
SELECT 
    s.name AS materia,
    a.trimester,
    COUNT(*) AS total_actividades,
    STRING_AGG(DISTINCT a.type, ', ') AS tipos
FROM activities a
JOIN subjects s ON s.id = a.subject_id
WHERE a.name LIKE '[PRUEBA%'
GROUP BY s.name, a.trimester
ORDER BY s.name, a.trimester;
```

### Ver Distribución de Calificaciones

```sql
SELECT 
    CASE 
        WHEN score >= 4.5 THEN '⭐ Excelente (4.5-5.0)'
        WHEN score >= 4.0 THEN '😊 Sobresaliente (4.0-4.4)'
        WHEN score >= 3.5 THEN '👍 Bueno (3.5-3.9)'
        WHEN score >= 3.0 THEN '✔️ Aceptable (3.0-3.4)'
        ELSE '⚠️ Bajo (<3.0)'
    END AS rango,
    COUNT(*) AS cantidad,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 1) AS porcentaje
FROM student_activity_scores sas
JOIN activities a ON a.id = sas.activity_id
WHERE a.name LIKE '[PRUEBA%'
GROUP BY 
    CASE 
        WHEN score >= 4.5 THEN '⭐ Excelente (4.5-5.0)'
        WHEN score >= 4.0 THEN '😊 Sobresaliente (4.0-4.4)'
        WHEN score >= 3.5 THEN '👍 Bueno (3.5-3.9)'
        WHEN score >= 3.0 THEN '✔️ Aceptable (3.0-3.4)'
        ELSE '⚠️ Bajo (<3.0)'
    END
ORDER BY MIN(score) DESC;
```

### Ver Mensajes de Prueba

```sql
SELECT 
    subject,
    message_type,
    priority,
    is_read,
    TO_CHAR(sent_at, 'DD/MM/YYYY HH24:MI') AS enviado
FROM messages 
WHERE subject LIKE '[PRUEBA%'
ORDER BY sent_at DESC;
```

---

## 🧹 Limpiar Datos de Prueba

### Limpiar Solo Notas

```sql
-- Paso 1: Borrar calificaciones
DELETE FROM student_activity_scores 
WHERE activity_id IN (
    SELECT id FROM activities WHERE name LIKE '[PRUEBA%'
);

-- Paso 2: Borrar actividades
DELETE FROM activities WHERE name LIKE '[PRUEBA%';

-- Verificar
SELECT 'Datos de notas eliminados' AS resultado;
```

### Limpiar Solo Mensajes

```sql
DELETE FROM messages WHERE subject LIKE '[PRUEBA%';
SELECT 'Mensajes de prueba eliminados' AS resultado;
```

### Limpiar Todo

```sql
-- Calificaciones
DELETE FROM student_activity_scores 
WHERE activity_id IN (
    SELECT id FROM activities WHERE name LIKE '[PRUEBA%'
);

-- Actividades
DELETE FROM activities WHERE name LIKE '[PRUEBA%';

-- Mensajes
DELETE FROM messages WHERE subject LIKE '[PRUEBA%';

SELECT 'Todos los datos de prueba eliminados' AS resultado;
```

---

## 📝 Checklist de Pruebas

### ✅ Sistema de Notas

- [ ] Ver notas de estudiante con promedio alto
- [ ] Ver notas de estudiante con promedio bajo
- [ ] Filtrar por trimestre (T1, T2, T3)
- [ ] Filtrar por materia
- [ ] Ver actividades pendientes
- [ ] Verificar cálculo de promedios

### ✅ Aprobados/Reprobados

- [ ] Ver reporte por grado
- [ ] Cambiar trimestre
- [ ] Ver estudiantes aprobados
- [ ] Ver estudiantes reprobados
- [ ] Descargar PDF
- [ ] Verificar porcentajes

### ✅ Libro de Calificaciones

- [ ] Ver lista de estudiantes
- [ ] Ver actividades creadas
- [ ] Editar una calificación
- [ ] Crear nueva actividad
- [ ] Ver promedio actualizado

### ✅ Mensajería

- [ ] Ver bandeja de entrada
- [ ] Abrir mensaje no leído
- [ ] Responder mensaje
- [ ] Enviar nuevo mensaje
- [ ] Ver mensajes enviados
- [ ] Buscar mensajes

---

## 🚀 Inicio Rápido

### Opción 1: Ejecutar Todo (Recomendado)

```bash
# 1. Navegar al directorio del proyecto
cd C:\Proyectos\Proyectos\EduPlanner\EduPlanner\SchoolManager

# 2. Ejecutar scripts en pgAdmin:
#    - DatosDummyNotasCompleto.sql
#    - DatosDummyMessages.sql

# 3. Iniciar la aplicación
dotnet run

# 4. Abrir navegador
http://localhost:5172
```

### Opción 2: Solo Notas

```bash
# 1. En pgAdmin, ejecutar:
DatosDummyNotasCompleto.sql

# 2. Probar:
/StudentReport/Index
/AprobadosReprobados/Index
/TeacherGradebook/Index
```

### Opción 3: Solo Mensajería

```bash
# 1. En pgAdmin, ejecutar:
DatosDummyMessages.sql

# 2. Probar:
/Messaging/Inbox
/Messaging/Compose
```

---

## 💡 Tips y Recomendaciones

### 📌 Identificar Datos de Prueba

Todos los datos dummy tienen el prefijo **`[PRUEBA]`** o **`[PRUEBA T2]`** para fácil identificación.

### 📌 Cantidad de Datos

- **Actividades:** ~30 por ejecución
- **Calificaciones:** ~500 por ejecución
- **Mensajes:** 10-15 por ejecución

### 📌 Datos Realistas

- Notas siguen distribución normal
- Mayoría de estudiantes aprueban (como en la realidad)
- Hay casos extremos para pruebas

### 📌 Seguridad

- Todos los scripts usan `ON CONFLICT DO NOTHING`
- No sobrescriben datos existentes
- Fácil de limpiar con queries provistas

---

## ✅ Resumen

**Archivos creados:**
- ✅ `DatosDummyNotasCompleto.sql` - 30+ actividades, 500+ calificaciones
- ✅ `DatosDummyMessages.sql` - 10+ mensajes de prueba
- ✅ `GUIA_DATOS_PRUEBA.md` - Esta guía

**Módulos que puedes probar:**
1. ✅ Reportes de Estudiantes
2. ✅ Aprobados/Reprobados
3. ✅ Libro de Calificaciones
4. ✅ Mensajería Interna
5. ✅ Perfil de Estudiante

**Tiempo total de setup:** ~3 minutos

---

**¡Listo para probar todo el sistema con datos realistas!** 🎉

