# 📋 PLAN DE PRUEBAS - ROL ESTUDIANTE

## 🎯 OBJETIVO
Validar de manera integral todas las funcionalidades disponibles para el rol de **Estudiante** en el sistema EduPlanner.

---

## 👤 DATOS DE PRUEBA

### Usuario de Prueba: Estudiante
- **Email**: estudiante@test.com
- **Contraseña**: Estudiante123!
- **Rol**: estudiante (o student)
- **Escuela**: IPT San Miguelito
- **Grado**: 10° (ejemplo)
- **Grupo**: A (ejemplo)

---

## 📑 MÓDULOS A PROBAR

### 1️⃣ DASHBOARD (Portal Principal)
### 2️⃣ MI PERFIL (Información Personal)
### 3️⃣ MIS CALIFICACIONES (Rendimiento Académico)
### 4️⃣ MENSAJERÍA (Comunicación)
### 5️⃣ CAMBIO DE CONTRASEÑA (Seguridad)

---

## 🧪 CASOS DE PRUEBA DETALLADOS

---

## 1️⃣ DASHBOARD (Portal Principal)

### **CP-EST-001: Acceso al Dashboard**
- **Precondición**: Usuario autenticado como estudiante
- **Pasos**:
  1. Iniciar sesión con credenciales de estudiante
  2. Verificar redirección automática a `/Home/Index`
  3. Observar widgets y contenido del dashboard
- **Resultado Esperado**:
  - ✅ Dashboard se carga correctamente
  - ✅ Información personalizada del estudiante visible
  - ✅ Widgets relevantes para estudiantes (calificaciones, asistencia, etc.)
  - ✅ Nombre del estudiante en la barra superior
- **Validaciones**:
  - [ ] Logo de la escuela cargado
  - [ ] Menú lateral con opciones de estudiante
  - [ ] No se muestran opciones de admin/profesor/director
  - [ ] Información relevante visible (grado, grupo, etc.)

---

### **CP-EST-002: Navegación desde el Dashboard**
- **Precondición**: Estar en el dashboard
- **Pasos**:
  1. Verificar opciones disponibles en el menú lateral
  2. Identificar accesos directos en el dashboard
  3. Hacer clic en diferentes secciones
- **Resultado Esperado**:
  - ✅ Todas las opciones del menú son accesibles
  - ✅ Navegación fluida entre módulos
  - ✅ Breadcrumbs correctos
- **Validaciones**:
  - [ ] "Dashboard" visible
  - [ ] "Mi Perfil" visible
  - [ ] "Mis Calificaciones" visible (si aplica)
  - [ ] "Mensajería" visible
  - [ ] "Cambiar Contraseña" visible

---

## 2️⃣ MI PERFIL (Información Personal)

### **CP-EST-003: Acceso a Mi Perfil**
- **Precondición**: Usuario autenticado como estudiante
- **Pasos**:
  1. Hacer clic en "Mi Perfil" en el menú
  2. Verificar carga de `/StudentProfile/Index`
  3. Revisar información mostrada
- **Resultado Esperado**:
  - ✅ Perfil del estudiante se carga correctamente
  - ✅ Información personal visible
  - ✅ Datos de solo lectura claramente diferenciados
- **Validaciones**:
  - [ ] Nombre completo visible
  - [ ] Email visible
  - [ ] Documento de identidad visible
  - [ ] Grado y grupo (solo lectura)
  - [ ] Escuela (solo lectura)
  - [ ] Fecha de nacimiento
  - [ ] Teléfonos

---

### **CP-EST-004: Actualizar Información Personal**
- **Precondición**: Estar en la vista de perfil
- **Pasos**:
  1. Modificar los siguientes campos:
     - **Nombre**: Cambiar a "Juan Carlos"
     - **Apellido**: Cambiar a "Pérez González"
     - **Teléfono Principal**: Cambiar a "6123-4567"
     - **Teléfono Secundario**: Cambiar a "6987-6543"
  2. Hacer clic en "Guardar Cambios"
  3. Confirmar en el diálogo de SweetAlert
- **Resultado Esperado**:
  - ✅ Información actualizada correctamente
  - ✅ Mensaje de éxito mostrado
  - ✅ Datos persistentes al recargar página
- **Validaciones**:
  - [ ] Campos actualizados en la BD
  - [ ] Mensaje "Tu perfil ha sido actualizado correctamente"
  - [ ] `updated_at` actualizado
  - [ ] `updated_by` registra ID del estudiante

---

### **CP-EST-005: Cambiar Email Válido**
- **Precondición**: Estar en la vista de perfil
- **Pasos**:
  1. Cambiar email a uno nuevo y válido: "nuevo.estudiante@test.com"
  2. Guardar cambios
  3. Confirmar
- **Resultado Esperado**:
  - ✅ Email actualizado correctamente
  - ✅ Mensaje de éxito
  - ✅ Login posterior requiere nuevo email
- **Validaciones**:
  - [ ] Email actualizado en BD
  - [ ] Sin mensajes de error
  - [ ] Login con nuevo email exitoso

---

### **CP-EST-006: Validar Email Duplicado**
- **Precondición**: Estar en la vista de perfil
- **Pasos**:
  1. Cambiar email a uno que ya existe en el sistema
  2. Salir del campo (trigger validación AJAX)
  3. Intentar guardar
- **Resultado Esperado**:
  - ✅ Mensaje de error en tiempo real: "Este correo ya está en uso"
  - ✅ No se permite guardar
  - ✅ Campo marcado como inválido
- **Validaciones**:
  - [ ] Validación AJAX funciona
  - [ ] Mensaje de error visible
  - [ ] Email no se actualiza
  - [ ] Usuario puede corregir y reintentar

---

### **CP-EST-007: Validar Documento de Identidad Duplicado**
- **Precondición**: Estar en la vista de perfil
- **Pasos**:
  1. Cambiar documento a uno que ya existe
  2. Salir del campo (trigger validación AJAX)
  3. Intentar guardar
- **Resultado Esperado**:
  - ✅ Mensaje de error: "Este documento ya está registrado"
  - ✅ No se permite guardar
- **Validaciones**:
  - [ ] Validación en tiempo real funciona
  - [ ] Feedback visual claro
  - [ ] Documento no se actualiza

---

### **CP-EST-008: Validar Formato de Email Inválido**
- **Precondición**: Estar en la vista de perfil
- **Pasos**:
  1. Ingresar email sin formato válido: "estudiante.test"
  2. Intentar guardar
- **Resultado Esperado**:
  - ✅ Error de validación: "Email inválido"
  - ✅ No se permite guardar
- **Validaciones**:
  - [ ] Validación de formato funciona
  - [ ] Mensaje de error apropiado

---

### **CP-EST-009: Campos Requeridos Vacíos**
- **Precondición**: Estar en la vista de perfil
- **Pasos**:
  1. Borrar el campo "Nombre"
  2. Intentar guardar
- **Resultado Esperado**:
  - ✅ Error: "El nombre es obligatorio"
  - ✅ No se permite guardar
- **Validaciones**:
  - [ ] Validación de campos requeridos funciona
  - [ ] Mensajes claros para cada campo

---

### **CP-EST-010: Actualizar Fecha de Nacimiento**
- **Precondición**: Estar en la vista de perfil
- **Pasos**:
  1. Cambiar fecha de nacimiento a "01/01/2005"
  2. Guardar cambios
- **Resultado Esperado**:
  - ✅ Fecha actualizada correctamente
  - ✅ Formato de fecha correcto
- **Validaciones**:
  - [ ] Fecha guardada en formato correcto
  - [ ] DatePicker funcional
  - [ ] Validación de fecha lógica (no futuro)

---

### **CP-EST-011: Cancelar Cambios en Perfil**
- **Precondición**: Estar editando el perfil
- **Pasos**:
  1. Modificar varios campos
  2. Hacer clic en "Cancelar" o navegar a otra página
  3. Volver al perfil
- **Resultado Esperado**:
  - ✅ Cambios no guardados se descartan
  - ✅ Información original intacta
- **Validaciones**:
  - [ ] Datos originales permanecen
  - [ ] Sin actualizaciones en BD

---

## 3️⃣ MIS CALIFICACIONES (Rendimiento Académico)

### **CP-EST-012: Acceso a Mis Calificaciones**
- **Precondición**: Usuario autenticado como estudiante
- **Pasos**:
  1. Hacer clic en "Mis Calificaciones" o similar en el menú
  2. Verificar carga de la vista de calificaciones
- **Resultado Esperado**:
  - ✅ Vista de calificaciones cargada
  - ✅ Materias del estudiante visibles
  - ✅ Calificaciones organizadas por trimestre
- **Validaciones**:
  - [ ] Todas las materias asignadas visibles
  - [ ] Notas organizadas por tipo de actividad
  - [ ] Promedios calculados correctamente
  - [ ] Layout claro y organizado

---

### **CP-EST-013: Ver Calificaciones por Trimestre**
- **Precondición**: Estar en la vista de calificaciones
- **Pasos**:
  1. Seleccionar "I Trimestre"
  2. Verificar calificaciones mostradas
  3. Cambiar a "II Trimestre"
  4. Verificar calificaciones
- **Resultado Esperado**:
  - ✅ Calificaciones filtradas por trimestre correctamente
  - ✅ Promedios por trimestre visibles
  - ✅ Datos correspondientes al trimestre seleccionado
- **Validaciones**:
  - [ ] Filtro de trimestre funcional
  - [ ] Datos correctos por trimestre
  - [ ] Promedios recalculados

---

### **CP-EST-014: Ver Detalle de Actividad**
- **Precondición**: Calificaciones disponibles
- **Pasos**:
  1. Hacer clic en una actividad específica
  2. Ver detalles (nombre, tipo, fecha, calificación)
- **Resultado Esperado**:
  - ✅ Detalles de la actividad visibles
  - ✅ Calificación obtenida
  - ✅ Fecha de entrega
  - ✅ Descripción de la actividad
- **Validaciones**:
  - [ ] Información completa de la actividad
  - [ ] Posibilidad de descargar material (si aplica)

---

### **CP-EST-015: Descargar Material de Actividad**
- **Precondición**: Actividad con archivo PDF adjunto
- **Pasos**:
  1. Hacer clic en el ícono de descarga/PDF
  2. Verificar descarga del archivo
- **Resultado Esperado**:
  - ✅ Archivo descargado correctamente
  - ✅ PDF legible y sin errores
- **Validaciones**:
  - [ ] Descarga exitosa
  - [ ] Archivo íntegro
  - [ ] Nombre descriptivo

---

### **CP-EST-016: Ver Promedio General**
- **Precondición**: Calificaciones registradas
- **Pasos**:
  1. Navegar a la sección de promedios
  2. Ver promedio general del estudiante
  3. Ver promedio por materia
- **Resultado Esperado**:
  - ✅ Promedio general calculado correctamente
  - ✅ Promedio por materia visible
  - ✅ Indicador de Aprobado/Reprobado
- **Validaciones**:
  - [ ] Cálculo de promedio correcto
  - [ ] Estado (Aprobado >= 3.0, Reprobado < 3.0)
  - [ ] Visualización clara (colores, badges)

---

### **CP-EST-017: Ver Calificaciones por Materia**
- **Precondición**: Estar en vista de calificaciones
- **Pasos**:
  1. Seleccionar una materia específica
  2. Ver todas las actividades de esa materia
  3. Ver promedio de la materia
- **Resultado Esperado**:
  - ✅ Actividades de la materia listadas
  - ✅ Calificaciones por actividad
  - ✅ Promedio de la materia
- **Validaciones**:
  - [ ] Filtro por materia funcional
  - [ ] Datos correctos
  - [ ] Promedio bien calculado

---

### **CP-EST-018: Exportar Reporte de Calificaciones**
- **Precondición**: Calificaciones disponibles
- **Pasos**:
  1. Hacer clic en "Exportar a PDF" o "Descargar"
  2. Verificar generación del reporte
- **Resultado Esperado**:
  - ✅ PDF generado correctamente
  - ✅ Contenido completo y legible
  - ✅ Logo de la escuela incluido
- **Validaciones**:
  - [ ] PDF descargado
  - [ ] Formato profesional
  - [ ] Datos correctos
  - [ ] Logo visible

---

### **CP-EST-019: Ver Estadísticas de Asistencia**
- **Precondición**: Asistencias registradas
- **Pasos**:
  1. Navegar a sección de asistencia (si está integrada)
  2. Ver porcentaje de asistencia
  3. Ver historial de asistencias
- **Resultado Esperado**:
  - ✅ Porcentaje de asistencia visible
  - ✅ Historial detallado
  - ✅ Filtros por fecha/trimestre
- **Validaciones**:
  - [ ] Cálculo de porcentaje correcto
  - [ ] Historial completo
  - [ ] Indicadores visuales claros (P, A, T, J)

---

## 4️⃣ MENSAJERÍA (Comunicación)

### **CP-EST-020: Acceso al Sistema de Mensajería**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Hacer clic en "Mensajería" en el menú
  2. Verificar carga de `/Messaging/Index`
- **Resultado Esperado**:
  - ✅ Bandeja de entrada visible
  - ✅ Mensajes recibidos listados
  - ✅ Opción de redactar nuevo mensaje
- **Validaciones**:
  - [ ] Mensajes ordenados por fecha (más reciente primero)
  - [ ] Indicador de mensajes no leídos
  - [ ] Botón "Nuevo Mensaje" disponible
  - [ ] Contador de mensajes no leídos

---

### **CP-EST-021: Ver Mensaje Recibido**
- **Precondición**: Mensajes en bandeja de entrada
- **Pasos**:
  1. Hacer clic en un mensaje
  2. Ver contenido completo
- **Resultado Esperado**:
  - ✅ Mensaje se abre correctamente
  - ✅ Contenido completo visible
  - ✅ Información del remitente visible
  - ✅ Fecha y hora del mensaje
- **Validaciones**:
  - [ ] Asunto claro
  - [ ] Cuerpo del mensaje legible
  - [ ] Remitente identificado
  - [ ] Fecha/hora correctas
  - [ ] Mensaje marcado como leído automáticamente

---

### **CP-EST-022: Enviar Mensaje a un Profesor**
- **Precondición**: En la vista de mensajería
- **Pasos**:
  1. Hacer clic en "Nuevo Mensaje"
  2. Seleccionar destinatario (Profesor)
  3. Completar:
     - **Asunto**: "Consulta sobre tarea de matemáticas"
     - **Mensaje**: "Profesor, tengo una duda sobre el ejercicio 5..."
  4. Hacer clic en "Enviar"
- **Resultado Esperado**:
  - ✅ Mensaje enviado correctamente
  - ✅ Confirmación de envío
  - ✅ Mensaje aparece en "Enviados"
- **Validaciones**:
  - [ ] Mensaje recibido por el profesor
  - [ ] Mensaje en bandeja de enviados
  - [ ] Fecha y hora correctas
  - [ ] Sin errores de envío

---

### **CP-EST-023: Enviar Mensaje a Administrador**
- **Precondición**: En la vista de mensajería
- **Pasos**:
  1. Hacer clic en "Nuevo Mensaje"
  2. Seleccionar destinatario (Administrador)
  3. Completar asunto y mensaje
  4. Enviar
- **Resultado Esperado**:
  - ✅ Mensaje enviado correctamente
  - ✅ Admin recibe el mensaje
- **Validaciones**:
  - [ ] Mensaje entregado
  - [ ] Sin errores de permisos
  - [ ] Confirmación visible

---

### **CP-EST-024: Responder un Mensaje**
- **Precondición**: Mensaje recibido de un profesor
- **Pasos**:
  1. Abrir mensaje recibido
  2. Hacer clic en "Responder"
  3. Escribir respuesta
  4. Enviar
- **Resultado Esperado**:
  - ✅ Respuesta enviada
  - ✅ Hilo de conversación visible
  - ✅ Profesor recibe la respuesta
- **Validaciones**:
  - [ ] Respuesta vinculada al mensaje original
  - [ ] Hilo de conversación completo
  - [ ] Destinatario correcto (profesor original)

---

### **CP-EST-025: Marcar Mensaje como No Leído**
- **Precondición**: Mensaje leído
- **Pasos**:
  1. Seleccionar un mensaje leído
  2. Marcar como no leído
  3. Verificar cambio de estado
- **Resultado Esperado**:
  - ✅ Estado actualizado a "No leído"
  - ✅ Indicador visual correcto
  - ✅ Contador de no leídos actualizado
- **Validaciones**:
  - [ ] Estado persistente
  - [ ] Badge de no leído visible
  - [ ] Contador actualizado

---

### **CP-EST-026: Eliminar Mensaje**
- **Precondición**: Mensajes en bandeja de entrada
- **Pasos**:
  1. Seleccionar un mensaje
  2. Hacer clic en "Eliminar"
  3. Confirmar eliminación
- **Resultado Esperado**:
  - ✅ Mensaje eliminado de la vista
  - ✅ Mensaje movido a "Eliminados" o eliminado definitivamente
  - ✅ Confirmación de la acción
- **Validaciones**:
  - [ ] Mensaje ya no en bandeja de entrada
  - [ ] Posibilidad de recuperar (si hay papelera)
  - [ ] Sin errores

---

### **CP-EST-027: Buscar Mensajes**
- **Precondición**: Múltiples mensajes en el sistema
- **Pasos**:
  1. Usar barra de búsqueda
  2. Buscar por palabra clave: "tarea"
  3. Ver resultados
- **Resultado Esperado**:
  - ✅ Mensajes filtrados por palabra clave
  - ✅ Resultados relevantes
  - ✅ Búsqueda rápida
- **Validaciones**:
  - [ ] Búsqueda funcional
  - [ ] Resultados precisos
  - [ ] Sin errores de búsqueda

---

### **CP-EST-028: Ver Mensajes Enviados**
- **Precondición**: Mensajes enviados previamente
- **Pasos**:
  1. Navegar a "Mensajes Enviados"
  2. Ver listado de mensajes enviados
- **Resultado Esperado**:
  - ✅ Todos los mensajes enviados visibles
  - ✅ Información completa (destinatario, fecha, asunto)
- **Validaciones**:
  - [ ] Solo mensajes enviados por el estudiante
  - [ ] Ordenados por fecha
  - [ ] Detalles completos

---

## 5️⃣ CAMBIO DE CONTRASEÑA (Seguridad)

### **CP-EST-029: Cambiar Contraseña Correctamente**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Ir a "Cambiar Contraseña"
  2. Ingresar:
     - **Contraseña Actual**: Estudiante123!
     - **Nueva Contraseña**: NuevaEst456!
     - **Confirmar Contraseña**: NuevaEst456!
  3. Hacer clic en "Cambiar"
- **Resultado Esperado**:
  - ✅ Contraseña cambiada exitosamente
  - ✅ Mensaje de confirmación
  - ✅ Siguiente login requiere nueva contraseña
- **Validaciones**:
  - [ ] Contraseña actualizada en BD
  - [ ] Hash de contraseña correcto
  - [ ] Login con nueva contraseña exitoso
  - [ ] Login con contraseña antigua falla

---

### **CP-EST-030: Validar Contraseña Actual Incorrecta**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Ir a "Cambiar Contraseña"
  2. Ingresar contraseña actual incorrecta
  3. Intentar cambiar
- **Resultado Esperado**:
  - ✅ Error: "Contraseña actual incorrecta"
  - ✅ Cambio no permitido
  - ✅ Contraseña actual permanece igual
- **Validaciones**:
  - [ ] Mensaje de error claro
  - [ ] Contraseña no cambiada
  - [ ] Usuario puede reintentar

---

### **CP-EST-031: Validar Confirmación de Contraseña**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Ir a "Cambiar Contraseña"
  2. Ingresar contraseña actual correcta
  3. Nueva contraseña: "Test123!"
  4. Confirmar contraseña: "Test456!" (diferente)
  5. Intentar cambiar
- **Resultado Esperado**:
  - ✅ Error: "Las contraseñas no coinciden"
  - ✅ Cambio no permitido
- **Validaciones**:
  - [ ] Validación del lado del cliente
  - [ ] Validación del lado del servidor
  - [ ] Mensaje de error apropiado

---

### **CP-EST-032: Validar Complejidad de Contraseña**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Ir a "Cambiar Contraseña"
  2. Intentar cambiar a contraseña débil: "123456"
  3. Confirmar
- **Resultado Esperado**:
  - ✅ Error: "La contraseña no cumple con los requisitos"
  - ✅ Indicación de requisitos (mayúsculas, números, caracteres especiales)
  - ✅ Cambio no permitido
- **Validaciones**:
  - [ ] Validación de complejidad funcional
  - [ ] Mensaje descriptivo
  - [ ] Requisitos claramente especificados

---

## 6️⃣ PRUEBAS DE SEGURIDAD Y PERMISOS

### **CP-EST-033: Restricción de Acceso a Módulos de Admin**
- **Precondición**: Usuario autenticado como estudiante
- **Pasos**:
  1. Intentar acceder manualmente a:
     - `/User/Index` (administración de usuarios)
     - `/TeacherAssignment/Index` (asignaciones de profesores)
     - `/School/Index` (administración de escuelas)
     - `/TeacherGradebook/Index` (portal docente)
     - `/Director/Index` (portal director)
- **Resultado Esperado**:
  - ✅ Acceso denegado (403 Forbidden)
  - ✅ Redirección a página de error o dashboard
  - ✅ Mensaje de error apropiado
- **Validaciones**:
  - [ ] No acceso a módulos no autorizados
  - [ ] Mensaje de error claro
  - [ ] Sin exposición de información sensible
  - [ ] Redirección segura

---

### **CP-EST-034: Ver Solo Información Propia**
- **Precondición**: Usuario autenticado como estudiante
- **Pasos**:
  1. Acceder a perfil
  2. Acceder a calificaciones
  3. Intentar modificar URL para ver datos de otro estudiante
- **Resultado Esperado**:
  - ✅ Solo información propia visible
  - ✅ Acceso denegado a datos de otros estudiantes
- **Validaciones**:
  - [ ] Filtrado correcto por estudiante actual
  - [ ] Sin exposición de datos de terceros
  - [ ] Validación de permisos en el backend

---

### **CP-EST-035: No Modificar Calificaciones**
- **Precondición**: Usuario autenticado como estudiante
- **Pasos**:
  1. Ver calificaciones
  2. Verificar que no hay opciones de edición
  3. Intentar modificar vía consola de desarrollador (si aplica)
- **Resultado Esperado**:
  - ✅ Calificaciones en modo solo lectura
  - ✅ No hay botones de edición
  - ✅ Requests de modificación rechazados
- **Validaciones**:
  - [ ] Sin opciones de edición en UI
  - [ ] Protección en el backend
  - [ ] Auditoría de intentos de modificación

---

### **CP-EST-036: Sesión y Tokens de Seguridad**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Iniciar sesión
  2. Realizar operaciones
  3. Cerrar sesión
  4. Intentar acceder a páginas protegidas
- **Resultado Esperado**:
  - ✅ Sesión válida durante uso activo
  - ✅ Tokens CSRF presentes en formularios
  - ✅ Redirección a login después de cerrar sesión
  - ✅ No acceso a recursos sin autenticación
- **Validaciones**:
  - [ ] Tokens anti-CSRF en todos los formularios
  - [ ] Sesión expira correctamente
  - [ ] Redirección a login funcional
  - [ ] Sin acceso sin autenticación

---

## 7️⃣ PRUEBAS DE EXPERIENCIA DE USUARIO (UX)

### **CP-EST-037: Navegación Intuitiva**
- **Precondición**: Usuario nuevo en el sistema
- **Pasos**:
  1. Iniciar sesión por primera vez
  2. Explorar todas las secciones
  3. Realizar tareas comunes sin ayuda
- **Resultado Esperado**:
  - ✅ Interface intuitiva y fácil de usar
  - ✅ Etiquetas claras en menús
  - ✅ Íconos representativos
  - ✅ Breadcrumbs útiles
- **Validaciones**:
  - [ ] Usuario puede completar tareas básicas sin ayuda
  - [ ] Menú claro y organizado
  - [ ] Tooltips informativos
  - [ ] Ayuda contextual disponible

---

### **CP-EST-038: Responsive Design en Móvil**
- **Precondición**: Acceso desde smartphone
- **Pasos**:
  1. Abrir aplicación en dispositivo móvil
  2. Navegar por todos los módulos
  3. Ver perfil
  4. Ver calificaciones
  5. Enviar mensaje
- **Resultado Esperado**:
  - ✅ Interface adaptada a pantalla móvil
  - ✅ Todas las funcionalidades accesibles
  - ✅ Botones de tamaño adecuado para touch
  - ✅ Texto legible sin zoom
- **Validaciones**:
  - [ ] Layout responsive correcto
  - [ ] Sin overflow horizontal
  - [ ] Menú móvil funcional
  - [ ] Formularios usables en móvil

---

### **CP-EST-039: Tiempos de Carga Aceptables**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Acceder a diferentes secciones
  2. Medir tiempo de carga de cada página
  3. Cargar calificaciones con muchos datos
- **Resultado Esperado**:
  - ✅ Páginas cargan en < 3 segundos
  - ✅ Feedback visual durante carga
  - ✅ Loaders/spinners apropiados
- **Validaciones**:
  - [ ] Tiempo de carga aceptable
  - [ ] Indicadores de carga visibles
  - [ ] Sin timeouts
  - [ ] Performance optimizada

---

### **CP-EST-040: Mensajes de Error Claros**
- **Precondición**: Usuario realizando operaciones
- **Pasos**:
  1. Provocar diferentes errores intencionalmente:
     - Formulario inválido
     - Email duplicado
     - Contraseña incorrecta
  2. Observar mensajes de error
- **Resultado Esperado**:
  - ✅ Mensajes de error claros y descriptivos
  - ✅ Indicación de cómo corregir el error
  - ✅ Colores y estilos apropiados
- **Validaciones**:
  - [ ] Mensajes en lenguaje natural
  - [ ] Sin códigos técnicos confusos
  - [ ] Sugerencias de corrección
  - [ ] Estilo consistente

---

### **CP-EST-041: Feedback Visual en Acciones**
- **Precondición**: Usuario realizando acciones
- **Pasos**:
  1. Guardar cambios en perfil
  2. Enviar mensaje
  3. Cambiar contraseña
  4. Observar feedback visual
- **Resultado Esperado**:
  - ✅ Mensajes de éxito claros
  - ✅ Alertas con SweetAlert2 o similar
  - ✅ Confirmaciones antes de acciones críticas
  - ✅ Indicadores de progreso
- **Validaciones**:
  - [ ] Mensajes de éxito visibles
  - [ ] Confirmaciones funcionales
  - [ ] Animaciones suaves
  - [ ] Feedback inmediato

---

### **CP-EST-042: Accesibilidad Básica**
- **Precondición**: Usuario con necesidades especiales
- **Pasos**:
  1. Navegar usando solo teclado (Tab, Enter)
  2. Probar con lector de pantalla (si disponible)
  3. Verificar contraste de colores
- **Resultado Esperado**:
  - ✅ Navegación por teclado funcional
  - ✅ Etiquetas ARIA apropiadas
  - ✅ Contraste de colores adecuado
- **Validaciones**:
  - [ ] Foco visible en elementos
  - [ ] Orden lógico de tabulación
  - [ ] Textos alternativos en imágenes
  - [ ] Contraste mínimo WCAG AA

---

## 8️⃣ PRUEBAS DE INTEGRACIÓN

### **CP-EST-043: Flujo Completo: Login → Perfil → Mensajería → Logout**
- **Precondición**: Usuario creado en el sistema
- **Pasos**:
  1. Iniciar sesión
  2. Ver dashboard
  3. Ir a perfil
  4. Actualizar información
  5. Ir a mensajería
  6. Enviar mensaje a profesor
  7. Ver calificaciones
  8. Cambiar contraseña
  9. Cerrar sesión
- **Resultado Esperado**:
  - ✅ Flujo completo sin errores
  - ✅ Todas las acciones exitosas
  - ✅ Datos persistentes entre módulos
- **Validaciones**:
  - [ ] Sin errores en consola
  - [ ] Sin errores en servidor
  - [ ] Datos consistentes
  - [ ] Logout funcional

---

### **CP-EST-044: Actualizar Perfil y Ver Cambios en Otros Módulos**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Cambiar nombre en perfil
  2. Guardar
  3. Verificar que el nombre aparece actualizado en:
     - Dashboard (barra superior)
     - Mensajería (remitente)
     - Calificaciones (nombre del estudiante)
- **Resultado Esperado**:
  - ✅ Nombre actualizado en todos los módulos
  - ✅ Consistencia de datos
- **Validaciones**:
  - [ ] Actualización reflejada en toda la app
  - [ ] Sin datos desactualizados
  - [ ] Caché invalidado correctamente

---

### **CP-EST-045: Recibir Mensaje de Profesor y Responder**
- **Precondición**: Profesor envió mensaje al estudiante
- **Pasos**:
  1. Iniciar sesión como estudiante
  2. Ver notificación de mensaje nuevo
  3. Abrir mensaje
  4. Leer contenido
  5. Responder
- **Resultado Esperado**:
  - ✅ Notificación visible
  - ✅ Mensaje legible
  - ✅ Respuesta enviada
  - ✅ Profesor recibe respuesta
- **Validaciones**:
  - [ ] Notificación en tiempo real (o al login)
  - [ ] Hilo de conversación completo
  - [ ] Respuesta vinculada correctamente

---

## 📊 RESUMEN DE CASOS DE PRUEBA

| Módulo | Casos de Prueba | Prioridad |
|--------|----------------|-----------|
| Dashboard | 2 | Alta |
| Mi Perfil | 9 | Crítica |
| Mis Calificaciones | 8 | Crítica |
| Mensajería | 9 | Alta |
| Cambio de Contraseña | 4 | Alta |
| Seguridad y Permisos | 4 | Crítica |
| Experiencia de Usuario | 6 | Media |
| Integración | 3 | Alta |
| **TOTAL** | **45** | - |

---

## ✅ CHECKLIST GLOBAL DE VALIDACIÓN

### Funcionalidad General
- [ ] Todas las vistas cargan sin errores
- [ ] Navegación fluida entre módulos
- [ ] Mensajes de error/éxito claros
- [ ] Logs de auditoría registrados
- [ ] Sin errores en consola del navegador

### Mi Perfil
- [ ] Actualizar información personal funciona
- [ ] Validaciones en tiempo real (email, documento)
- [ ] Campos de solo lectura no editables
- [ ] Confirmación antes de guardar
- [ ] Mensajes de éxito/error apropiados

### Calificaciones
- [ ] Ver calificaciones por trimestre
- [ ] Ver calificaciones por materia
- [ ] Promedios calculados correctamente
- [ ] Indicadores de aprobado/reprobado
- [ ] Exportar reportes funcional
- [ ] Descargar materiales de actividades
- [ ] Ver estadísticas de asistencia

### Mensajería
- [ ] Enviar mensajes a profesores
- [ ] Enviar mensajes a administradores
- [ ] Recibir y leer mensajes
- [ ] Responder mensajes
- [ ] Marcar como leído/no leído
- [ ] Buscar mensajes
- [ ] Notificaciones de mensajes nuevos

### Seguridad
- [ ] No acceso a módulos de admin/profesor
- [ ] Solo información propia visible
- [ ] No modificar calificaciones
- [ ] Cambio de contraseña funcional
- [ ] Sesión expira correctamente
- [ ] Tokens CSRF en formularios

### Experiencia de Usuario
- [ ] Interface intuitiva
- [ ] Responsive design funcional
- [ ] Tiempos de carga aceptables
- [ ] Mensajes claros
- [ ] Feedback visual en acciones
- [ ] Accesibilidad básica

---

## 🎯 CRITERIOS DE ACEPTACIÓN

### ✅ Prueba EXITOSA si:
1. Todos los casos críticos y de alta prioridad PASAN
2. Al menos 90% de casos totales PASAN
3. No hay errores bloqueantes (Severity 1)
4. Rendimiento dentro de límites aceptables
5. Seguridad sin vulnerabilidades críticas
6. UX intuitiva y sin confusiones

### ❌ Prueba FALLIDA si:
1. Cualquier caso crítico FALLA
2. Más de 10% de casos totales FALLAN
3. Existen errores bloqueantes
4. Problemas de seguridad críticos detectados
5. Rendimiento inaceptable en funcionalidades clave
6. UX confusa o con errores graves

---

## 📝 NOTAS IMPORTANTES

1. **Ejecutar en orden**: Los casos están organizados de forma lógica
2. **Datos de prueba**: Usar datos dummy consistentes
3. **Documentar hallazgos**: Registrar todos los bugs con screenshots
4. **Verificar permisos**: Asegurar que solo estudiantes accedan a sus propios datos
5. **Probar en diferentes navegadores**: Chrome, Firefox, Edge, Safari
6. **Probar en móvil**: Android y iOS

---

## 🔄 ESCENARIOS ADICIONALES

### **Escenario 1: Estudiante Nuevo (Primer Login)**
1. Iniciar sesión por primera vez
2. Verificar que se solicite cambio de contraseña (si aplica)
3. Completar perfil
4. Explorar sistema guiado (onboarding si existe)

### **Escenario 2: Estudiante con Bajo Rendimiento**
1. Ver calificaciones con promedio < 3.0
2. Verificar indicadores visuales (rojo, advertencia)
3. Ver mensajes de profesores/orientación
4. Acceder a recursos de ayuda (si existen)

### **Escenario 3: Fin de Trimestre**
1. Ver promedios finales del trimestre
2. Exportar reporte de calificaciones
3. Verificar cierre de trimestre
4. Acceso a calificaciones de trimestres anteriores

---

## 🚀 PRÓXIMOS PASOS DESPUÉS DE PRUEBAS

1. **Documentar bugs encontrados** con:
   - Título descriptivo
   - Pasos para reproducir
   - Resultado esperado vs obtenido
   - Capturas de pantalla
   - Severidad (Crítico, Alto, Medio, Bajo)

2. **Priorizar correcciones**:
   - Crítico: Corregir inmediatamente
   - Alto: Corregir antes de producción
   - Medio: Corregir en próxima iteración
   - Bajo: Backlog

3. **Re-ejecutar pruebas** después de correcciones

4. **Realizar pruebas de regresión** en módulos afectados

5. **Proceder con pruebas para rol Director** (si aplica)

6. **Pruebas de integración** entre todos los roles

---

## 🎓 DATOS DE PRUEBA SUGERIDOS

### **Estudiante 1: Rendimiento Alto**
- Nombre: María González
- Email: maria.gonzalez@test.com
- Grado: 10°
- Grupo: A
- Promedio: 4.5
- Asistencia: 98%

### **Estudiante 2: Rendimiento Medio**
- Nombre: Carlos Rodríguez
- Email: carlos.rodriguez@test.com
- Grado: 11°
- Grupo: B
- Promedio: 3.2
- Asistencia: 85%

### **Estudiante 3: Rendimiento Bajo**
- Nombre: Ana López
- Email: ana.lopez@test.com
- Grado: 9°
- Grupo: C
- Promedio: 2.8
- Asistencia: 75%

---

**Fecha de Creación**: 16 de Octubre de 2025  
**Versión**: 1.0  
**Estado**: Listo para Ejecución  
**Complementa**: PRUEBAS_ROL_PROFESOR.md

