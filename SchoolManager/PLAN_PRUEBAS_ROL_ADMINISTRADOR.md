# 🧪 PLAN DE PRUEBAS COMPLETO - ROL ADMINISTRADOR

**Sistema:** EduPlanner - Sistema de Gestión Escolar  
**Rol bajo prueba:** Administrador (Admin)  
**Fecha creación:** 16 de Octubre de 2025  
**Versión:** 1.0  
**Entorno:** Desarrollo Local (localhost:5172)

---

## 📋 ÍNDICE
1. [Información General](#información-general)
2. [Módulos a Probar](#módulos-a-probar)
3. [Datos de Prueba](#datos-de-prueba)
4. [Casos de Prueba por Módulo](#casos-de-prueba-por-módulo)
5. [Matriz de Trazabilidad](#matriz-de-trazabilidad)
6. [Checklist de Ejecución](#checklist-de-ejecución)

---

## 📌 INFORMACIÓN GENERAL

### Objetivos de las Pruebas
- ✅ Verificar que todas las funcionalidades del rol **Administrador** funcionen correctamente
- ✅ Validar restricciones de acceso y seguridad
- ✅ Comprobar la integridad de datos y validaciones
- ✅ Asegurar la correcta comunicación con la base de datos
- ✅ Verificar la experiencia de usuario y flujos completos

### Alcance
**EN ALCANCE:**
- Todas las funcionalidades exclusivas del rol Admin
- Funcionalidades compartidas con permisos específicos de Admin
- Validaciones de negocio y restricciones de seguridad
- Flujos CRUD completos
- Integración con servicios (Email, Mensajería, etc.)

**FUERA DE ALCANCE:**
- Funcionalidades exclusivas de SuperAdmin
- Funcionalidades exclusivas de Teacher, Director o Student
- Pruebas de carga y rendimiento
- Pruebas de seguridad avanzadas (penetración)

### Prerrequisitos
1. ✅ Base de datos local `schoolmanagement` configurada
2. ✅ Tabla `messages` creada en la base de datos
3. ✅ Usuario Admin creado con credenciales conocidas
4. ✅ Datos de prueba cargados (estudiantes, profesores, materias, etc.)
5. ✅ Aplicación compilada y corriendo en `localhost:5172`

---

## 🎯 MÓDULOS A PROBAR

### Módulos Exclusivos de Administrador

| # | Módulo | Controlador | Prioridad | Complejidad |
|---|--------|-------------|-----------|-------------|
| 1 | Gestión de Usuarios | `UserController` | 🔴 ALTA | ALTA |
| 2 | Catálogo Académico | `AcademicCatalogController` | 🔴 ALTA | MEDIA |
| 3 | Asignaciones de Materias | `SubjectAssignmentController` | 🟡 MEDIA | MEDIA |
| 4 | Asignación de Docentes | `TeacherAssignmentController` | 🔴 ALTA | ALTA |
| 5 | Asignación de Estudiantes | `StudentAssignmentController` | 🔴 ALTA | ALTA |
| 6 | Carga Masiva - Docentes | `AcademicAssignmentController` | 🟡 MEDIA | MEDIA |
| 7 | Carga Masiva - Estudiantes | `StudentAssignmentController.Upload` | 🟡 MEDIA | MEDIA |
| 8 | Configuración de Email | `EmailConfigurationController` | 🟢 BAJA | BAJA |
| 9 | Asignaciones de Consejeros | `CounselorAssignmentController` | 🟡 MEDIA | MEDIA |

### Módulos Compartidos con Permisos Admin

| # | Módulo | Permisos Especiales Admin | Prioridad |
|---|--------|---------------------------|-----------|
| 10 | Mensajería | Enviar a todos (Broadcast) | 🟡 MEDIA |
| 11 | Reportes Aprobados/Reprobados | Acceso completo con filtros | 🟢 BAJA |
| 12 | Cambio de Contraseña | Usuario propio | 🟢 BAJA |
| 13 | Dashboard | Vista general del sistema | 🟢 BAJA |

---

## 👥 DATOS DE PRUEBA

### Usuarios de Prueba

```sql
-- ADMINISTRADOR DE PRUEBAS
Email: admin@eduplaner.net
Password: Admin123!
Rol: admin
SchoolId: [Tu School ID]

-- PROFESOR DE PRUEBA (para asignaciones)
Email: profesor.test@eduplaner.net
Password: Profesor123!
Rol: teacher

-- ESTUDIANTE DE PRUEBA (para asignaciones)
Email: estudiante.test@eduplaner.net
Password: Estudiante123!
Rol: student
```

### Datos Académicos de Prueba

```text
✅ NIVELES DE GRADO (Grade Levels):
- 7° Grado
- 8° Grado
- 9° Grado
- 10° Grado
- 11° Grado
- 12° Grado

✅ GRUPOS:
- 7°A, 7°B
- 8°A, 8°B
- 9°A, 9°B
- 10°A, 10°B, 10°C
- 11°A, 11°B
- 12°A, 12°B

✅ ESPECIALIDADES:
- Bachiller en Ciencias
- Bachiller en Letras
- Bachiller en Comercio

✅ ÁREAS:
- Ciencias Naturales
- Ciencias Sociales
- Matemáticas
- Lenguaje
- Inglés

✅ MATERIAS (ejemplos):
- Matemática
- Español
- Inglés
- Ciencias Naturales
- Estudios Sociales
- Informática
```

---

## 🧪 CASOS DE PRUEBA POR MÓDULO

---

## MÓDULO 1: GESTIÓN DE USUARIOS

**URL Base:** `/User/Index`  
**Prioridad:** 🔴 ALTA  
**Controlador:** `UserController`

### CP-001: Visualizar Lista de Usuarios
**Objetivo:** Verificar que el administrador puede ver todos los usuarios de su escuela  
**Precondiciones:**
- Usuario Admin autenticado
- Base de datos con al menos 5 usuarios

**Pasos:**
1. Iniciar sesión como Admin
2. Navegar a **Administración > Administrar Usuarios**
3. Verificar que aparece la tabla de usuarios

**Resultado Esperado:**
- ✅ Se muestra tabla con columnas: Nombre, Email, Rol, Estado, Acciones
- ✅ Se muestran todos los usuarios de la escuela (excepto SuperAdmin)
- ✅ Tabla es paginada/filtrable (DataTables)
- ✅ Botones de acción: Ver, Editar, Eliminar, Enviar Contraseña

**Datos de Validación:**
- Roles mostrados: Teacher, Student, Director (NO SuperAdmin, NO Admin)
- Estados: active, inactive

---

### CP-002: Crear Nuevo Usuario - Docente
**Objetivo:** Crear un nuevo usuario con rol Teacher  
**Precondiciones:**
- Usuario Admin autenticado
- Email único no registrado

**Pasos:**
1. Ir a `/User/Index`
2. Click en botón "Crear Nuevo Usuario"
3. Completar formulario:
   ```
   Nombre: Carlos
   Apellido: Rodríguez
   Email: carlos.rodriguez@test.com
   Documento: 8-111-2222
   Rol: Teacher
   Estado: active
   Fecha Nacimiento: 15/05/1985
   Celular Principal: +507 6000-1111
   Celular Secundario: +507 6000-2222
   Contraseña: Test123!@#
   ```
4. Marcar checkboxes (si aplica):
   - ☑️ Disciplina
   - ☑️ Orientación
5. Click en "Guardar"

**Resultado Esperado:**
- ✅ Usuario creado correctamente
- ✅ Mensaje de éxito: "Usuario creado correctamente"
- ✅ Usuario aparece en la lista
- ✅ Contraseña está hasheada en BD (BCrypt)
- ✅ Email de bienvenida enviado (si configuración SMTP está lista)

**Validaciones:**
- Email único (no duplicado)
- Contraseña cumple política de seguridad (8+ caracteres, mayúscula, minúscula, número, especial)
- Documento ID válido

---

### CP-003: Crear Usuario - Validaciones de Email
**Objetivo:** Validar que no se permiten emails duplicados  
**Precondiciones:**
- Usuario con email `test@eduplaner.net` ya existe

**Pasos:**
1. Intentar crear usuario con email `test@eduplaner.net`
2. Llenar formulario completo
3. Click en "Guardar"

**Resultado Esperado:**
- ❌ Error: "El correo electrónico ya está registrado en el sistema"
- ❌ Usuario NO se crea
- ✅ Formulario permanece con datos ingresados

---

### CP-004: Crear Usuario - Validación de Contraseña Débil
**Objetivo:** Validar política de contraseñas seguras  
**Precondiciones:** Ninguna

**Casos de Prueba:**
| Contraseña | ¿Válida? | Razón |
|------------|----------|-------|
| `123` | ❌ | Muy corta |
| `password` | ❌ | Sin mayúsculas, números, caracteres especiales |
| `Password1` | ❌ | Sin caracteres especiales |
| `Password!` | ❌ | Sin números |
| `Pass1!` | ❌ | Menos de 8 caracteres |
| `Password1!` | ✅ | Cumple todos los requisitos |

**Resultado Esperado:**
- ❌ Contraseñas débiles son rechazadas
- ✅ Mensaje: "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial"

---

### CP-005: Editar Usuario Existente
**Objetivo:** Modificar datos de un usuario existente  
**Precondiciones:**
- Usuario Teacher existe con ID conocido

**Pasos:**
1. Ir a `/User/Index`
2. Click en botón "Editar" del usuario
3. Modificar datos:
   ```
   Celular Principal: +507 6999-9999
   Disciplina: ☑️ (marcar)
   Orientación: ☐ (desmarcar)
   ```
4. Click en "Actualizar"

**Resultado Esperado:**
- ✅ Usuario actualizado correctamente
- ✅ Mensaje: "Usuario actualizado correctamente"
- ✅ Cambios reflejados en la lista
- ✅ Campos no modificados permanecen igual
- ✅ Logs en consola muestran proceso de actualización

**Validaciones:**
- `UpdatedAt` debe cambiar en BD
- Contraseña NO cambia si el campo está vacío

---

### CP-006: Editar Usuario - Cambiar Contraseña
**Objetivo:** Cambiar contraseña de un usuario  
**Precondiciones:**
- Usuario existente

**Pasos:**
1. Editar usuario
2. Ingresar nueva contraseña en campo `PasswordHash`: `NewPass123!`
3. Guardar cambios
4. Cerrar sesión e intentar login con nueva contraseña

**Resultado Esperado:**
- ✅ Contraseña actualizada correctamente
- ✅ Login funciona con nueva contraseña
- ✅ Contraseña hasheada en BD (diferente al hash anterior)

---

### CP-007: Eliminar Usuario
**Objetivo:** Eliminar un usuario del sistema  
**Precondiciones:**
- Usuario sin asignaciones activas (o que las asignaciones puedan eliminarse)

**Pasos:**
1. Ir a `/User/Index`
2. Click en botón "Eliminar" de un usuario
3. Confirmar eliminación en el modal/diálogo

**Resultado Esperado:**
- ✅ Usuario eliminado correctamente
- ✅ Usuario desaparece de la lista
- ✅ Registro eliminado o marcado como inactivo en BD

**Validaciones:**
- Si usuario tiene asignaciones activas: evaluar si bloquea o permite

---

### CP-008: Enviar Contraseña por Email
**Objetivo:** Enviar contraseña temporal a usuario por email  
**Precondiciones:**
- Configuración SMTP válida y activa
- Usuario con email válido

**Pasos:**
1. Ir a `/User/Index`
2. Click en botón "Enviar Contraseña" de un usuario
3. Esperar respuesta

**Resultado Esperado:**
- ✅ Email enviado exitosamente
- ✅ Mensaje: "Contraseña enviada exitosamente a {email}"
- ✅ Contraseña temporal generada (12 caracteres, segura)
- ✅ Usuario recibe email con formato HTML bonito
- ✅ Email contiene: credenciales, enlace a `https://www.eduplaner.net`, advertencia de cambio
- ✅ Contraseña hasheada en BD
- ✅ Usuario puede hacer login con nueva contraseña

**Validaciones:**
- Email tiene formato correcto (HTML)
- Link a `eduplaner.net` funciona
- SMTP logs sin errores

---

### CP-009: Enviar Email - Sin Configuración SMTP
**Objetivo:** Validar mensaje de error cuando no hay configuración SMTP  
**Precondiciones:**
- Sin configuración SMTP para la escuela

**Pasos:**
1. Eliminar/desactivar configuración SMTP
2. Intentar enviar contraseña por email

**Resultado Esperado:**
- ❌ Error: "No hay configuración de email para esta escuela. Configure el servidor SMTP primero."
- ❌ Email NO se envía
- ✅ Contraseña NO se regenera

---

### CP-010: Filtrar Usuarios por Rol
**Objetivo:** Filtrar lista de usuarios por rol  
**Precondiciones:**
- Múltiples usuarios con diferentes roles

**Pasos:**
1. Ir a `/User/Index`
2. Usar filtro/dropdown de roles
3. Seleccionar "Teacher"

**Resultado Esperado:**
- ✅ Solo se muestran usuarios con rol "Teacher"
- ✅ Contador de resultados actualizado

---

### CP-011: Buscar Usuario por Nombre/Email
**Objetivo:** Buscar usuario específico  
**Precondiciones:**
- DataTables implementado

**Pasos:**
1. Ir a `/User/Index`
2. Escribir en buscador: "Carlos"
3. Verificar resultados

**Resultado Esperado:**
- ✅ Se muestran solo usuarios con "Carlos" en nombre o apellido
- ✅ Búsqueda es case-insensitive

---

## MÓDULO 2: CATÁLOGO ACADÉMICO

**URL Base:** `/AcademicCatalog/Index`  
**Prioridad:** 🔴 ALTA  
**Controlador:** `AcademicCatalogController`

### CP-012: Visualizar Catálogo Académico Completo
**Objetivo:** Ver todas las entidades del catálogo académico  
**Precondiciones:**
- Admin autenticado

**Pasos:**
1. Navegar a **Administración > Catálogo Académico**
2. Verificar secciones visibles

**Resultado Esperado:**
- ✅ Se muestran 6 secciones:
  - Niveles de Grado (Grade Levels)
  - Grupos (Groups)
  - Materias (Subjects)
  - Áreas (Areas)
  - Especialidades (Specialties)
  - Trimestres (Trimestres)
- ✅ Cada sección muestra lista de elementos
- ✅ Botones: Crear Nuevo, Editar, Eliminar

---

### CP-013: Crear Nivel de Grado
**Objetivo:** Crear nuevo nivel de grado  
**Precondiciones:** Ninguna

**Pasos:**
1. Ir a sección "Niveles de Grado"
2. Click en "Crear Nuevo"
3. Completar:
   ```
   Nombre: 7° Grado
   Descripción: Séptimo grado de educación secundaria
   ```
4. Guardar

**Resultado Esperado:**
- ✅ Nivel creado correctamente
- ✅ Aparece en lista de niveles
- ✅ Disponible en dropdowns de asignaciones

---

### CP-014: Crear Grupo
**Objetivo:** Crear nuevo grupo asociado a un grado  
**Precondiciones:**
- Al menos 1 nivel de grado existe

**Pasos:**
1. Ir a sección "Grupos"
2. Click en "Crear Nuevo"
3. Completar:
   ```
   Nombre: 7°A
   Grado: 7° Grado
   Capacidad: 30
   ```
4. Guardar

**Resultado Esperado:**
- ✅ Grupo creado correctamente
- ✅ Asociado al grado correcto
- ✅ Aparece en lista de grupos

---

### CP-015: Crear Materia
**Objetivo:** Crear nueva materia  
**Precondiciones:**
- Al menos 1 área existe
- Al menos 1 especialidad existe

**Pasos:**
1. Ir a sección "Materias"
2. Click en "Crear Nuevo"
3. Completar:
   ```
   Nombre: Matemática Avanzada
   Código: MAT-301
   Área: Matemáticas
   Especialidad: Bachiller en Ciencias
   Créditos: 3
   ```
4. Guardar

**Resultado Esperado:**
- ✅ Materia creada correctamente
- ✅ Asociada a área y especialidad
- ✅ Disponible para asignaciones

---

### CP-016: Crear Área
**Objetivo:** Crear nueva área académica  
**Precondiciones:** Ninguna

**Pasos:**
1. Ir a sección "Áreas"
2. Click en "Crear Nuevo"
3. Completar:
   ```
   Nombre: Ciencias Naturales
   Descripción: Área de ciencias experimentales
   ```
4. Guardar

**Resultado Esperado:**
- ✅ Área creada correctamente
- ✅ Disponible al crear materias

---

### CP-017: Crear Especialidad
**Objetivo:** Crear nueva especialidad  
**Precondiciones:** Ninguna

**Pasos:**
1. Ir a sección "Especialidades"
2. Click en "Crear Nuevo"
3. Completar:
   ```
   Nombre: Bachiller en Ciencias
   Descripción: Especialidad enfocada en ciencias exactas
   ```
4. Guardar

**Resultado Esperado:**
- ✅ Especialidad creada correctamente
- ✅ Disponible al crear materias y grupos

---

### CP-018: Configurar Trimestres
**Objetivo:** Configurar períodos académicos (trimestres)  
**Precondiciones:** Ninguna

**Pasos:**
1. Ir a sección "Trimestres"
2. Click en "Configurar Trimestres"
3. Definir 3 trimestres:
   ```
   Trimestre 1:
   - Nombre: Primer Trimestre
   - Fecha Inicio: 01/03/2025
   - Fecha Fin: 31/05/2025
   - Estado: Activo
   
   Trimestre 2:
   - Nombre: Segundo Trimestre
   - Fecha Inicio: 01/06/2025
   - Fecha Fin: 31/08/2025
   - Estado: Inactivo
   
   Trimestre 3:
   - Nombre: Tercer Trimestre
   - Fecha Inicio: 01/09/2025
   - Fecha Fin: 30/11/2025
   - Estado: Inactivo
   ```
4. Guardar configuración

**Resultado Esperado:**
- ✅ Trimestres guardados correctamente
- ✅ Solo trimestre activo aparece como período actual
- ✅ Trimestres disponibles en actividades y calificaciones

---

### CP-019: Editar Elemento del Catálogo
**Objetivo:** Modificar un elemento existente  
**Precondiciones:**
- Elemento creado previamente

**Pasos:**
1. Seleccionar cualquier sección
2. Click en "Editar" de un elemento
3. Modificar datos
4. Guardar

**Resultado Esperado:**
- ✅ Elemento actualizado correctamente
- ✅ Cambios reflejados inmediatamente

---

### CP-020: Eliminar Elemento del Catálogo
**Objetivo:** Eliminar elemento sin dependencias  
**Precondiciones:**
- Elemento sin asignaciones/relaciones

**Pasos:**
1. Click en "Eliminar"
2. Confirmar eliminación

**Resultado Esperado:**
- ✅ Elemento eliminado
- ✅ Desaparece de la lista

---

### CP-021: Eliminar Elemento con Dependencias
**Objetivo:** Validar bloqueo de eliminación si hay dependencias  
**Precondiciones:**
- Grado con grupos asignados
- Materia con asignaciones a profesores

**Pasos:**
1. Intentar eliminar grado con grupos asociados
2. Confirmar eliminación

**Resultado Esperado:**
- ❌ Error: "No se puede eliminar porque tiene elementos relacionados"
- ❌ Elemento NO se elimina
- ✅ Integridad referencial protegida

---

## MÓDULO 3: ASIGNACIONES DE MATERIAS

**URL Base:** `/SubjectAssignment/Index`  
**Prioridad:** 🟡 MEDIA

### CP-022: Visualizar Asignaciones de Materias
**Objetivo:** Ver listado de asignaciones materia-profesor-grupo  
**Precondiciones:**
- Asignaciones existentes en el sistema

**Pasos:**
1. Navegar a **Administración > Catálogo de Asignaciones**

**Resultado Esperado:**
- ✅ Tabla con columnas: Materia, Profesor, Grupo, Grado, Trimestre
- ✅ Filtros disponibles: Por grado, por profesor, por materia

---

### CP-023: Crear Asignación de Materia
**Objetivo:** Asignar una materia a un profesor y grupo  
**Precondiciones:**
- Profesor existente
- Materia existente
- Grupo existente

**Pasos:**
1. Click en "Nueva Asignación"
2. Seleccionar:
   ```
   Materia: Matemática
   Profesor: Carlos Rodríguez
   Grupo: 7°A
   Trimestre: Primer Trimestre
   ```
3. Guardar

**Resultado Esperado:**
- ✅ Asignación creada correctamente
- ✅ Profesor puede ver la materia en su portal
- ✅ Estudiantes del grupo pueden ver la materia

---

### CP-024: Validar Asignación Duplicada
**Objetivo:** Evitar asignación duplicada de misma materia-profesor-grupo  
**Precondiciones:**
- Asignación ya existe: Matemática - Carlos - 7°A

**Pasos:**
1. Intentar crear la misma asignación nuevamente

**Resultado Esperado:**
- ❌ Error: "Esta asignación ya existe"
- ❌ Asignación NO se crea

---

## MÓDULO 4: ASIGNACIÓN DE DOCENTES

**URL Base:** `/TeacherAssignment/Index`  
**Prioridad:** 🔴 ALTA

### CP-025: Visualizar Asignaciones de Docentes
**Objetivo:** Ver asignaciones de profesores  
**Precondiciones:** Ninguna

**Pasos:**
1. Navegar a **Administración > Asignar Docentes**

**Resultado Esperado:**
- ✅ Lista de profesores con sus asignaciones
- ✅ Muestra: Nombre, Materias, Grupos

---

### CP-026: Asignar Docente a Materias y Grupos
**Objetivo:** Asignar múltiples materias/grupos a un docente  
**Precondiciones:**
- Profesor sin asignaciones

**Pasos:**
1. Seleccionar profesor
2. Marcar materias: Matemática, Física
3. Marcar grupos: 7°A, 7°B
4. Guardar

**Resultado Esperado:**
- ✅ Docente asignado correctamente
- ✅ Puede acceder al portal docente
- ✅ Ve las materias y grupos asignados

---

## MÓDULO 5: ASIGNACIÓN DE ESTUDIANTES

**URL Base:** `/StudentAssignment/Index`  
**Prioridad:** 🔴 ALTA

### CP-027: Visualizar Asignaciones de Estudiantes
**Objetivo:** Ver estudiantes asignados a grupos  
**Precondiciones:** Ninguna

**Pasos:**
1. Navegar a **Administración > Asignar Estudiantes**

**Resultado Esperado:**
- ✅ Lista de estudiantes con sus grupos
- ✅ Filtros: Por grado, por grupo

---

### CP-028: Asignar Estudiante a Grupo
**Objetivo:** Asignar estudiante a un grupo específico  
**Precondiciones:**
- Estudiante sin grupo
- Grupo disponible

**Pasos:**
1. Seleccionar estudiante
2. Seleccionar grupo: 7°A
3. Seleccionar trimestre: Primer Trimestre
4. Guardar

**Resultado Esperado:**
- ✅ Estudiante asignado correctamente
- ✅ Aparece en lista del grupo
- ✅ Puede ver sus materias

---

## MÓDULO 6: CARGA MASIVA DE ASIGNACIONES

**URL Base:** `/AcademicAssignment/Upload` y `/StudentAssignment/Upload`  
**Prioridad:** 🟡 MEDIA

### CP-029: Cargar Asignaciones Docentes por Excel
**Objetivo:** Importar asignaciones masivas desde archivo Excel  
**Precondiciones:**
- Archivo Excel con formato correcto

**Pasos:**
1. Ir a **Carga Asignaciones Docentes**
2. Seleccionar archivo `.xlsx`
3. Click en "Cargar"

**Resultado Esperado:**
- ✅ Archivo procesado correctamente
- ✅ Asignaciones creadas en lote
- ✅ Reporte de éxitos y errores

---

### CP-030: Validar Formato Incorrecto en Carga Masiva
**Objetivo:** Rechazar archivo con formato inválido  
**Precondiciones:**
- Archivo Excel con columnas faltantes

**Pasos:**
1. Cargar archivo inválido

**Resultado Esperado:**
- ❌ Error: "Formato de archivo incorrecto"
- ❌ Asignaciones NO se crean
- ✅ Mensaje detalla errores encontrados

---

## MÓDULO 7: CONFIGURACIÓN DE EMAIL

**URL Base:** `/EmailConfiguration/Index`  
**Prioridad:** 🟢 BAJA

### CP-031: Ver Configuración SMTP Actual
**Objetivo:** Visualizar configuración de email  
**Precondiciones:**
- Configuración SMTP creada

**Pasos:**
1. Navegar a **Administración > Configuración de Email**

**Resultado Esperado:**
- ✅ Muestra configuración actual
- ✅ Campos: Servidor, Puerto, Usuario, From Email, SSL/TLS

---

### CP-032: Crear Configuración SMTP
**Objetivo:** Configurar servidor de email  
**Precondiciones:**
- Sin configuración previa

**Pasos:**
1. Click en "Crear Configuración"
2. Completar:
   ```
   Servidor SMTP: smtp.gmail.com
   Puerto: 587
   Usuario: eduplaner@gmail.com
   Contraseña: [App Password]
   From Email: eduplaner@gmail.com
   From Name: EduPlaner System
   Usar SSL: ☑️
   Usar TLS: ☐
   ```
3. Guardar

**Resultado Esperado:**
- ✅ Configuración guardada
- ✅ Emails pueden enviarse

---

### CP-033: Probar Conexión SMTP
**Objetivo:** Validar configuración con prueba de conexión  
**Precondiciones:**
- Configuración SMTP creada

**Pasos:**
1. Click en "Probar Conexión"

**Resultado Esperado:**
- ✅ Mensaje: "Conexión exitosa"
- ✅ O error detallado si falla

---

### CP-034: Editar Configuración SMTP
**Objetivo:** Modificar configuración existente  
**Precondiciones:**
- Configuración existente

**Pasos:**
1. Click en "Editar"
2. Cambiar puerto a 465
3. Guardar

**Resultado Esperado:**
- ✅ Configuración actualizada
- ✅ Cambios aplicados

---

## MÓDULO 8: ASIGNACIONES DE CONSEJEROS

**URL Base:** `/CounselorAssignment/Index`  
**Prioridad:** 🟡 MEDIA

### CP-035: Crear Asignación de Consejero
**Objetivo:** Asignar consejero a un grupo específico  
**Precondiciones:**
- Profesor disponible
- Grupo con estudiantes

**Pasos:**
1. Ir a **Asignaciones de Consejeros**
2. Click en "Nueva Asignación"
3. Seleccionar:
   ```
   Usuario: [Profesor]
   Tipo: Grupo
   Grado: 7° Grado
   Grupo: 7°A
   ```
4. Guardar

**Resultado Esperado:**
- ✅ Asignación creada
- ✅ Profesor puede ver estudiantes del grupo
- ✅ Solo un consejero por grupo

---

### CP-036: Ver Estadísticas de Consejeros
**Objetivo:** Ver resumen de asignaciones  
**Precondiciones:**
- Asignaciones existentes

**Pasos:**
1. Click en "Estadísticas"

**Resultado Esperado:**
- ✅ Muestra total de asignaciones
- ✅ Grupos con/sin consejero
- ✅ Gráficos visuales

---

## MÓDULO 9: MENSAJERÍA (Permisos Admin)

**URL Base:** `/Messaging/Inbox`  
**Prioridad:** 🟡 MEDIA

### CP-037: Enviar Mensaje Broadcast (Todos los Usuarios)
**Objetivo:** Enviar mensaje masivo a toda la escuela  
**Precondiciones:**
- Admin autenticado

**Pasos:**
1. Ir a **Mensajería > Nuevo Mensaje**
2. Seleccionar:
   ```
   Tipo: Broadcast (Todos)
   Asunto: Anuncio Importante
   Contenido: Mensaje de prueba
   Prioridad: Alta
   ```
3. Enviar

**Resultado Esperado:**
- ✅ Mensaje enviado a todos los usuarios activos
- ✅ Excluye al remitente
- ✅ Todos reciben notificación

---

### CP-038: Enviar Mensaje a Todos los Estudiantes
**Objetivo:** Mensaje masivo solo a estudiantes  
**Precondiciones:** Ninguna

**Pasos:**
1. Nuevo mensaje
2. Tipo: Todos los Estudiantes
3. Enviar

**Resultado Esperado:**
- ✅ Solo estudiantes reciben el mensaje

---

### CP-039: Enviar Mensaje a Todos los Profesores
**Objetivo:** Mensaje masivo solo a profesores  
**Precondiciones:** Ninguna

**Pasos:**
1. Nuevo mensaje
2. Tipo: Todos los Profesores
3. Enviar

**Resultado Esperado:**
- ✅ Solo profesores reciben el mensaje

---

### CP-040: Enviar Mensaje Individual
**Objetivo:** Mensaje privado a usuario específico  
**Precondiciones:** Ninguna

**Pasos:**
1. Nuevo mensaje
2. Tipo: Individual
3. Seleccionar destinatario
4. Enviar

**Resultado Esperado:**
- ✅ Solo destinatario recibe mensaje

---

### CP-041: Responder Mensaje
**Objetivo:** Responder a mensaje recibido  
**Precondiciones:**
- Mensaje en bandeja de entrada

**Pasos:**
1. Abrir mensaje
2. Click en "Responder"
3. Escribir respuesta
4. Enviar

**Resultado Esperado:**
- ✅ Respuesta enviada
- ✅ Enlazada al mensaje original
- ✅ Asunto tiene "RE:"

---

### CP-042: Marcar Mensaje como Leído
**Objetivo:** Actualizar estado de lectura  
**Precondiciones:**
- Mensaje no leído

**Pasos:**
1. Abrir mensaje

**Resultado Esperado:**
- ✅ Automáticamente se marca como leído
- ✅ Badge de no leídos disminuye

---

### CP-043: Eliminar Mensaje
**Objetivo:** Eliminar mensaje de la bandeja  
**Precondiciones:**
- Mensaje existente

**Pasos:**
1. Click en "Eliminar"
2. Confirmar

**Resultado Esperado:**
- ✅ Mensaje marcado como eliminado
- ✅ Desaparece de la bandeja

---

### CP-044: Buscar Mensajes
**Objetivo:** Buscar por asunto o contenido  
**Precondiciones:**
- Múltiples mensajes

**Pasos:**
1. Usar barra de búsqueda
2. Escribir: "Importante"

**Resultado Esperado:**
- ✅ Solo mensajes con "Importante" se muestran

---

## MÓDULO 10: REPORTES APROBADOS/REPROBADOS

**URL Base:** `/AprobadosReprobados/Index`  
**Prioridad:** 🟢 BAJA

### CP-045: Ver Reporte de Aprobados/Reprobados
**Objetivo:** Generar reporte con filtros  
**Precondiciones:**
- Calificaciones cargadas

**Pasos:**
1. Ir a **Reportes > Aprobados y Reprobados**
2. Seleccionar filtros:
   ```
   Grado: 7° Grado
   Grupo: 7°A
   Trimestre: Primer Trimestre
   Especialidad: [Opcional]
   Área: [Opcional]
   Materia: [Opcional]
   ```
3. Click en "Generar Reporte"

**Resultado Esperado:**
- ✅ Reporte generado con estadísticas
- ✅ Muestra: Total Aprobados, Reprobados, Porcentajes
- ✅ Gráficos visuales

---

### CP-046: Exportar Reporte a PDF
**Objetivo:** Descargar reporte en PDF  
**Precondiciones:**
- Reporte generado

**Pasos:**
1. Click en "Exportar PDF"

**Resultado Esperado:**
- ✅ PDF descargado con logo de escuela
- ✅ Formato profesional
- ✅ Datos correctos

---

### CP-047: Exportar Reporte a Excel
**Objetivo:** Descargar reporte en Excel  
**Precondiciones:**
- Reporte generado

**Pasos:**
1. Click en "Exportar Excel"

**Resultado Esperado:**
- ✅ Excel descargado
- ✅ Datos estructurados en columnas

---

## MÓDULO 11: CAMBIO DE CONTRASEÑA

**URL Base:** `/ChangePassword/Index`  
**Prioridad:** 🟢 BAJA

### CP-048: Cambiar Contraseña Propia
**Objetivo:** Admin cambia su contraseña  
**Precondiciones:**
- Admin autenticado

**Pasos:**
1. Ir a **Cambiar Contraseña**
2. Completar:
   ```
   Contraseña Actual: Admin123!
   Nueva Contraseña: NewAdmin123!
   Confirmar Contraseña: NewAdmin123!
   ```
3. Guardar

**Resultado Esperado:**
- ✅ Contraseña cambiada
- ✅ Puede hacer login con nueva contraseña
- ✅ Contraseña antigua no funciona

---

### CP-049: Cambiar Contraseña - Validación de Contraseña Actual
**Objetivo:** Validar contraseña actual incorrecta  
**Precondiciones:** Ninguna

**Pasos:**
1. Ingresar contraseña actual incorrecta

**Resultado Esperado:**
- ❌ Error: "Contraseña actual incorrecta"
- ❌ Contraseña NO cambia

---

### CP-050: Cambiar Contraseña - Confirmación No Coincide
**Objetivo:** Validar coincidencia de nueva contraseña  
**Precondiciones:** Ninguna

**Pasos:**
1. Nueva contraseña: Pass1!
2. Confirmar: Pass2!

**Resultado Esperado:**
- ❌ Error: "Las contraseñas no coinciden"
- ❌ Contraseña NO cambia

---

## MÓDULO 12: DASHBOARD

**URL Base:** `/Home/Index`  
**Prioridad:** 🟢 BAJA

### CP-051: Visualizar Dashboard Admin
**Objetivo:** Ver estadísticas generales  
**Precondiciones:**
- Admin autenticado

**Pasos:**
1. Ir a **Dashboard**

**Resultado Esperado:**
- ✅ Muestra widgets con:
  - Total de Estudiantes
  - Total de Profesores
  - Total de Grupos
  - Total de Materias
- ✅ Gráficos de actividad
- ✅ Accesos rápidos a módulos

---

## 📊 MATRIZ DE TRAZABILIDAD

| Req. Funcional | Caso de Prueba | Prioridad | Estado |
|----------------|----------------|-----------|--------|
| RF-001: Gestionar Usuarios | CP-001 a CP-011 | ALTA | ⏳ Pendiente |
| RF-002: Gestionar Catálogo | CP-012 a CP-021 | ALTA | ⏳ Pendiente |
| RF-003: Asignaciones Materias | CP-022 a CP-024 | MEDIA | ⏳ Pendiente |
| RF-004: Asignaciones Docentes | CP-025 a CP-026 | ALTA | ⏳ Pendiente |
| RF-005: Asignaciones Estudiantes | CP-027 a CP-028 | ALTA | ⏳ Pendiente |
| RF-006: Carga Masiva | CP-029 a CP-030 | MEDIA | ⏳ Pendiente |
| RF-007: Config Email | CP-031 a CP-034 | BAJA | ⏳ Pendiente |
| RF-008: Consejeros | CP-035 a CP-036 | MEDIA | ⏳ Pendiente |
| RF-009: Mensajería | CP-037 a CP-044 | MEDIA | ⏳ Pendiente |
| RF-010: Reportes | CP-045 a CP-047 | BAJA | ⏳ Pendiente |
| RF-011: Cambio Password | CP-048 a CP-050 | BAJA | ⏳ Pendiente |
| RF-012: Dashboard | CP-051 | BAJA | ⏳ Pendiente |

---

## ✅ CHECKLIST DE EJECUCIÓN

### Antes de Empezar
- [ ] Compilar aplicación sin errores
- [ ] Verificar base de datos conectada (localhost)
- [ ] Verificar tabla `messages` existe
- [ ] Limpiar datos de prueba anteriores (opcional)
- [ ] Cargar datos dummy de prueba
- [ ] Verificar usuario Admin tiene credenciales correctas

### Durante las Pruebas
- [ ] Documentar todos los errores encontrados
- [ ] Capturar pantallazos de evidencia
- [ ] Registrar logs de consola para errores
- [ ] Verificar datos en BD después de cada prueba
- [ ] No saltar casos de prueba obligatorios

### Después de las Pruebas
- [ ] Generar reporte de resultados
- [ ] Clasificar bugs por severidad
- [ ] Crear issues en sistema de tickets
- [ ] Actualizar matriz de trazabilidad
- [ ] Compartir resultados con equipo

---

## 📝 FORMATO DE REPORTE DE BUG

```markdown
**ID:** BUG-001  
**Módulo:** [Nombre del módulo]  
**Caso de Prueba:** CP-XXX  
**Severidad:** 🔴 Crítico | 🟡 Importante | 🟢 Menor  
**Prioridad:** Alta | Media | Baja  

**Descripción:**
[Descripción detallada del bug]

**Pasos para Reproducir:**
1. 
2. 
3. 

**Resultado Esperado:**
[Lo que debería pasar]

**Resultado Actual:**
[Lo que realmente pasó]

**Evidencia:**
[Captura de pantalla, logs, etc.]

**Entorno:**
- Navegador: 
- OS: 
- Versión App: 

**Notas Adicionales:**
[Información extra]
```

---

## 🎯 MÉTRICAS DE CALIDAD

### Criterios de Aceptación
- ✅ **100% de casos críticos (ALTA) deben pasar**
- ✅ **≥ 95% de casos importantes (MEDIA) deben pasar**
- ✅ **≥ 80% de casos menores (BAJA) deben pasar**
- ✅ **0 bugs críticos sin resolver**
- ✅ **≤ 2 bugs importantes sin resolver**

### Definición de "Pasó"
Un caso de prueba **PASA** si:
- Todos los resultados esperados se cumplen
- No hay errores en consola del navegador
- No hay excepciones en logs del servidor
- Datos en BD son consistentes
- UX es fluida sin bloqueos

Un caso de prueba **FALLA** si:
- Cualquier resultado esperado no se cumple
- Hay errores críticos en consola/logs
- Datos en BD son incorrectos o inconsistentes
- Funcionalidad no está disponible

---

## 📌 NOTAS FINALES

**Responsable de Pruebas:** [Nombre]  
**Fecha Inicio:** [Fecha]  
**Fecha Fin Estimada:** [Fecha]  
**Estado General:** ⏳ En Progreso

**Riesgos Identificados:**
- 🚨 Tabla `messages` podría no existir en BD
- 🚨 Configuración SMTP podría no estar lista
- 🚨 Datos de prueba podrían ser insuficientes

**Recomendaciones:**
- Ejecutar casos de prueba en orden
- Empezar con módulos de ALTA prioridad
- Validar cada cambio en BD directamente
- Mantener capturas de evidencia organizadas

---

**FIN DEL PLAN DE PRUEBAS ROL ADMINISTRADOR**


