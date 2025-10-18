# 🚀 Instrucciones para Ejecutar Script en Render

**Fecha:** 16 de Octubre, 2025

---

## 🎯 Objetivo

Ejecutar el script completo para verificar y generar datos dummy con notas en la base de datos de Render.

---

## 📋 Información de Conexión

**Host:** `dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com`  
**Database:** `schoolmanagement_xqks`  
**User:** `admin`  
**Password:** `2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk`  
**Port:** `5432`  
**SSL:** `Require`

---

## 🚀 Opciones de Ejecución

### Opción 1: pgAdmin (Recomendada)

1. **Abrir pgAdmin**
2. **Crear nueva conexión:**
   - Host: `dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com`
   - Port: `5432`
   - Database: `schoolmanagement_xqks`
   - Username: `admin`
   - Password: `2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk`
   - SSL Mode: `Require`

3. **Ejecutar script:**
   - Abrir Query Tool (F5)
   - Copiar y pegar el contenido de `ScriptCompletoRender_Final.sql`
   - Ejecutar (F5)

### Opción 2: psql desde línea de comandos

```bash
# Usar la ruta completa de PostgreSQL
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks

# Cuando pida la contraseña, ingresar: 2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
```

### Opción 3: DBeaver o cualquier cliente PostgreSQL

1. **Crear nueva conexión PostgreSQL**
2. **Configurar:**
   - Host: `dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com`
   - Port: `5432`
   - Database: `schoolmanagement_xqks`
   - Username: `admin`
   - Password: `2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk`
   - SSL: `Require`

3. **Ejecutar script:**
   - Abrir SQL Editor
   - Copiar y pegar el contenido de `ScriptCompletoRender_Final.sql`
   - Ejecutar

---

## 📊 Lo que hará el script

### 🔍 **PASO 1: Verificación de Datos Existentes**
- Contar usuarios por rol
- Verificar estudiantes y su estado inclusivo
- Verificar estructura académica
- Verificar asignaciones existentes

### 👥 **PASO 2: Actualizar Estudiantes Inclusivos**
- Actualizar campo `inclusivo` (30% serán inclusivos)
- Actualizar campo `orientacion` (20% tendrán orientación)
- Actualizar campo `disciplina` (10% tendrán disciplina)

### 📚 **PASO 3: Crear Datos Dummy**
- Crear hasta 20 estudiantes adicionales
- Crear hasta 10 profesores adicionales
- Crear grados (7° a 12°)
- Crear grupos (7°A, 7°B, 8°A, 8°B, etc.)
- Crear áreas académicas
- Crear especialidades
- Crear materias con códigos

### 🔗 **PASO 4: Crear Asignaciones**
- Asignar estudiantes a grados/grupos
- Crear asignaciones de materias
- Asignar profesores a materias

### 📅 **PASO 5: Crear Trimestres y Tipos de Actividades**
- Crear 3 trimestres (I, II, III)
- Crear 6 tipos de actividades (Evaluación, Tarea, Proyecto, etc.)

### 📚 **PASO 6: Generar Actividades**
- Crear hasta 100 actividades distribuidas por trimestre
- Asignar actividades a profesores y materias

### 📊 **PASO 7: Generar Notas**
- Crear hasta 500 calificaciones
- Distribución realista:
  - 10% notas bajas (1.0-2.0)
  - 20% notas regulares (2.0-3.0)
  - 40% notas buenas (3.0-4.0)
  - 30% notas excelentes (4.0-5.0)

### 📊 **PASO 8: Verificación Final**
- Mostrar estadísticas completas
- Verificar cobertura de datos
- Mostrar resumen final

---

## ✅ Resultados Esperados

Después de ejecutar el script:

- **Estudiantes:** 30+ con datos realistas
- **Profesores:** 10+ con asignaciones
- **Materias:** 14+ con códigos
- **Actividades:** 100+ distribuidas por trimestre
- **Calificaciones:** 500+ con distribución realista
- **Promedio general:** 3.5-4.0 (realista)
- **Cobertura de notas:** 90%+ de estudiantes

---

## 🎯 Módulos Listos para Pruebas

- ✅ **Gestión de Usuarios** - Filtros por rol funcionando
- ✅ **Asignaciones de Estudiantes** - Estudiantes asignados a grados/grupos
- ✅ **Asignaciones de Profesores** - Profesores asignados a materias
- ✅ **Catálogo Académico** - Materias, áreas, especialidades
- ✅ **Sistema de Notas** - Actividades y calificaciones
- ✅ **Reportes de Estudiantes** - Notas y promedios
- ✅ **Libro de Calificaciones** - Actividades por trimestre
- ✅ **Aprobados/Reprobados** - Cálculos automáticos
- ✅ **Mensajería Interna** - Sistema de mensajes

---

## ⚠️ Notas Importantes

1. **Seguridad:** El script usa `ON CONFLICT DO NOTHING` para evitar duplicados
2. **Datos Realistas:** Los datos siguen patrones realistas de distribución
3. **Fácil Limpieza:** Se pueden limpiar fácilmente con queries de DELETE
4. **Idempotente:** Se puede ejecutar múltiples veces sin problemas
5. **Tiempo de Ejecución:** Aproximadamente 2-3 minutos

---

## 🔧 Solución de Problemas

### Error de Conexión
- Verificar que la contraseña sea exactamente: `2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk`
- Verificar que el host sea: `dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com`
- Verificar que el puerto sea: `5432`
- Verificar que SSL esté habilitado

### Error de Permisos
- El usuario `admin` tiene permisos completos
- Si hay errores, verificar que la base de datos esté activa

### Error de Script
- Ejecutar el script completo de una vez
- No interrumpir la ejecución
- Si hay errores, revisar los logs

---

## 📞 Soporte

Si encuentras problemas:

1. Verificar la conexión a la base de datos
2. Ejecutar el script completo sin interrupciones
3. Revisar los logs de error
4. Contactar al equipo de desarrollo

---

**¡Sistema completamente funcional y listo para pruebas!** 🎉
