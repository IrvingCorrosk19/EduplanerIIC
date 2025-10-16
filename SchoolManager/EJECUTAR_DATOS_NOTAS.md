# 🚀 Guía Rápida: Ejecutar Datos Dummy de Notas

## ⚡ PASOS RÁPIDOS (2 minutos)

### 1️⃣ Abre pgAdmin
```
Aplicación: pgAdmin 4
```

### 2️⃣ Conecta a la Base de Datos
```
Servidor: localhost
Base de datos: schoolmanagement
Usuario: postgres
Contraseña: Panama2020$
```

### 3️⃣ Abre Query Tool
```
Clic derecho en "schoolmanagement" → Query Tool
```

### 4️⃣ Ejecuta el Script
```
1. Menú: File → Open
2. Busca: DatosDummyNotasCompleto.sql
3. Presiona: F5 (o botón ▶️ Execute)
```

### 5️⃣ Verifica el Resultado
```
Deberías ver en la salida:

========================================================
✅ DATOS DUMMY DE NOTAS CREADOS EXITOSAMENTE
========================================================

📚 ACTIVIDADES CREADAS:
   Total de actividades: 30+
   - Trimestre I: 15
   - Trimestre II: 10
   - Trimestre III: 8

📊 CALIFICACIONES GENERADAS:
   Total de calificaciones: 500+
   Promedio general: 3.7
   Nota mínima: 1.0
   Nota máxima: 5.0

🎯 CASOS ESPECIALES:
   ✅ Estudiante con notas perfectas (5.0)
   ⚠️  Estudiante con notas bajas (1.0 - 2.5)
   📝 Algunas actividades sin calificar en T3
```

---

## 📊 Qué Crea Este Script

### Actividades por Trimestre:

**Trimestre I (T1):**
- 15 actividades
- Tipos: Exámenes, Tareas, Proyectos
- Todas las materias disponibles
- Fecha límite: +7 días

**Trimestre II (T2):**
- 10 actividades
- Tipos variados
- Fecha límite: +14 días

**Trimestre III (T3):**
- 8 actividades
- Algunas sin calificar (para probar pendientes)
- Fecha límite: +21 días

### Calificaciones:

**Distribución realista:**
- 60% notas buenas (3.5 - 5.0)
- 30% notas regulares (3.0 - 3.4)
- 10% notas bajas (<3.0)

**Casos especiales:**
- 1 estudiante con todas las notas en 5.0
- 1 estudiante con notas bajas (necesita recuperación)

---

## ✅ Qué Podrás Probar

### 📝 Reportes de Estudiantes
```
URL: /StudentReport/Index
- Ver notas por trimestre
- Filtrar por materia
- Ver promedio general
- Ver actividades pendientes
```

### 📊 Aprobados/Reprobados
```
URL: /AprobadosReprobados/Index
- Ver cuadro por grado
- Cambiar trimestre
- Ver % de aprobados
- Descargar PDF
```

### 📖 Libro de Calificaciones
```
URL: /TeacherGradebook/Index
- Ver todas las actividades
- Ver calificaciones de estudiantes
- Editar notas
- Ver promedios automáticos
```

---

## 🧹 Para Limpiar Después

```sql
-- Ejecutar en Query Tool cuando termines las pruebas:

-- Borrar calificaciones
DELETE FROM student_activity_scores 
WHERE activity_id IN (
    SELECT id FROM activities WHERE name LIKE '[PRUEBA%'
);

-- Borrar actividades
DELETE FROM activities WHERE name LIKE '[PRUEBA%';

-- Confirmar
SELECT 'Datos de prueba eliminados' AS resultado;
```

---

## 📁 Archivos Disponibles

1. ✅ **DatosDummyNotasCompleto.sql** ← USA ESTE para notas
2. ✅ **DatosDummyMessages.sql** ← Para mensajería (opcional)
3. ✅ **GUIA_DATOS_PRUEBA.md** ← Guía completa

---

## 🎯 Después de Ejecutar el Script

```bash
# Inicia la aplicación:
dotnet run

# Abre navegador:
http://localhost:5172

# Inicia sesión y ve a:
- /StudentReport/Index (ver notas)
- /AprobadosReprobados/Index (ver estadísticas)
- /TeacherGradebook/Index (editar notas)
```

---

**✅ Archivo listo para ejecutar: `DatosDummyNotasCompleto.sql`**

**¿Ejecuto alguna verificación adicional antes de que corras el script?** 🚀

