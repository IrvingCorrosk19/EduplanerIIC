# 🧹 Guía de Limpieza de Base de Datos

## 📋 **¿Qué Hace el Script?**

### ✅ **MANTIENE:**
- ✅ Usuarios con rol: `admin`, `superadmin`, `director`
- ✅ Configuraciones de email (`email_configurations`)
- ✅ Escuelas (`schools`)
- ✅ Estructura de tablas (no se borra nada de estructura)

### ❌ **ELIMINA:**
- ❌ Profesores (`teacher`)
- ❌ Estudiantes (`student`, `estudiante`)
- ❌ Actividades
- ❌ Calificaciones
- ❌ Mensajes
- ❌ Asistencias
- ❌ Reportes de disciplina y orientación
- ❌ Grupos
- ❌ Asignaciones de estudiantes
- ❌ Asignaciones de profesores
- ❌ Logs de auditoría

---

## 🚀 **Cómo Ejecutar el Script**

### **Opción 1: En pgAdmin LOCAL (Recomendado primero)**

```
1. Abre pgAdmin
2. Conecta a: localhost/schoolmanagement
3. Query Tool
4. File → Open → LimpiarDBMantenerAdmins.sql
5. F5 → Ejecutar
6. Esperar mensaje: ✅ LIMPIEZA COMPLETADA EXITOSAMENTE
```

### **Opción 2: En pgAdmin RENDER (Producción)**

```
1. Abre pgAdmin
2. Conecta a: Render (dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com)
3. Query Tool
4. File → Open → LimpiarDBMantenerAdmins.sql
5. F5 → Ejecutar
6. Esperar mensaje: ✅ LIMPIEZA COMPLETADA EXITOSAMENTE
```

---

## 📊 **Resultado Esperado**

```
========================================================
✅ LIMPIEZA COMPLETADA EXITOSAMENTE
========================================================

📊 DATOS ELIMINADOS:
   Mensajes: 0
   Actividades: 0
   Calificaciones: 0
   Estudiantes: 390
   Grupos: 25

✅ DATOS MANTENIDOS:
   Total usuarios: 5
   - Admins/Directors: 5
   Configuraciones de email: 1

========================================================
🎯 BASE DE DATOS LISTA PARA PRODUCCIÓN
========================================================
```

---

## ⚠️ **ADVERTENCIAS IMPORTANTES**

### 🔴 **ANTES DE EJECUTAR:**

1. **HACER BACKUP:**
   ```sql
   -- En pgAdmin:
   Clic derecho en "schoolmanagement" → Backup
   ```

2. **VERIFICAR QUE ESTÁS EN LA BD CORRECTA:**
   ```sql
   SELECT current_database();
   -- Debe devolver: schoolmanagement
   ```

3. **NO EJECUTAR EN PRODUCCIÓN SIN BACKUP**

---

## 🔄 **Orden de Eliminación (Respeta Foreign Keys)**

```
1. student_activity_scores (calificaciones)
2. messages (mensajes)
3. activities (actividades)
4. attendance (asistencias)
5. discipline_reports (reportes)
6. student_assignments (asignaciones)
7. teacher_assignments (asignaciones)
8. students (estudiantes)
9. user_grades, user_groups, user_subjects (relaciones)
10. users con rol teacher/student (usuarios)
11. groups (grupos)
```

---

## 🎯 **Casos de Uso**

### **Caso 1: Nuevo Año Escolar**
```
Ejecutar script → Mantiene admins → Listo para nuevo año
```

### **Caso 2: Migración de Datos**
```
Ejecutar script → Importar datos limpios → Sin conflictos
```

### **Caso 3: Reset de Pruebas**
```
Ejecutar script → Borrar datos dummy → Base limpia
```

---

## 🔍 **Verificación Post-Limpieza**

### **Ver usuarios que quedaron:**
```sql
SELECT 
    name,
    last_name,
    email,
    role,
    status
FROM users
ORDER BY role, name;
```

### **Ver configuraciones de email:**
```sql
SELECT 
    school_id,
    smtp_server,
    from_email,
    is_active
FROM email_configurations;
```

### **Ver escuelas:**
```sql
SELECT 
    id,
    name,
    address,
    logo_url
FROM schools;
```

---

## 🛡️ **Seguridad del Script**

✅ **Usa transacción** (`BEGIN` / `COMMIT`)  
✅ **Si hay error, hace ROLLBACK automático**  
✅ **No elimina estructura** (solo datos)  
✅ **Respeta foreign keys** (orden correcto)  
✅ **Mantiene email configurations**  
✅ **Mantiene escuelas**

---

## 📝 **Notas Adicionales**

### **Si quieres TAMBIÉN limpiar catálogos:**

Descomenta en el script (líneas 85-96):
```sql
-- Descomentar estas líneas si quieres borrar también:
DELETE FROM trimester WHERE school_id IS NOT NULL;
DELETE FROM activity_types WHERE is_global = false;
DELETE FROM subjects WHERE school_id IS NOT NULL;
DELETE FROM grade_levels WHERE school_id IS NOT NULL;
DELETE FROM specialties WHERE school_id IS NOT NULL;
```

### **Si hay error:**

El script automáticamente hace `ROLLBACK` y NO se aplican los cambios.

---

## ✅ **Checklist**

- [ ] Hacer backup de la base de datos
- [ ] Verificar que estás en la BD correcta
- [ ] Ejecutar `LimpiarDBMantenerAdmins.sql`
- [ ] Verificar mensaje de éxito
- [ ] Verificar usuarios mantenidos
- [ ] Verificar email configurations

---

**Archivo listo:** `LimpiarDBMantenerAdmins.sql`

**⚠️ IMPORTANTE:** Ejecuta PRIMERO en LOCAL para probar, luego en RENDER si todo está bien.

