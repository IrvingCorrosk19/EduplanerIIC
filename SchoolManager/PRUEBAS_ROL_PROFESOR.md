# 📋 PLAN DE PRUEBAS - ROL PROFESOR

## 🎯 OBJETIVO
Validar de manera integral todas las funcionalidades disponibles para el rol de **Profesor** en el sistema EduPlanner.

---

## 👤 DATOS DE PRUEBA

### Usuario de Prueba: Profesor
- **Email**: profesor@test.com
- **Contraseña**: Profesor123!
- **Rol**: teacher
- **Escuela**: IPT San Miguelito

---

## 📑 MÓDULOS A PROBAR

### 1️⃣ DASHBOARD (Portal Principal)
### 2️⃣ PORTAL DOCENTE (Gestión Académica)
### 3️⃣ REPORTES DE ORIENTACIÓN (Consejería)
### 4️⃣ MENSAJERÍA
### 5️⃣ CAMBIO DE CONTRASEÑA

---

## 🧪 CASOS DE PRUEBA DETALLADOS

---

## 1️⃣ DASHBOARD (Portal Principal)

### **CP-PROF-001: Acceso al Dashboard**
- **Precondición**: Usuario autenticado como profesor
- **Pasos**:
  1. Iniciar sesión con credenciales de profesor
  2. Verificar redirección automática a `/Home/Index`
  3. Observar los widgets y estadísticas del dashboard
- **Resultado Esperado**:
  - ✅ Dashboard se carga correctamente
  - ✅ Muestra información personalizada del profesor
  - ✅ Widgets relevantes visibles (grupos asignados, materias, etc.)
- **Validaciones**:
  - [ ] Nombre del profesor visible en la barra superior
  - [ ] Logo de la escuela cargado correctamente
  - [ ] Menú lateral con opciones de profesor
  - [ ] No se muestran opciones de administrador/director

---

## 2️⃣ PORTAL DOCENTE (Gestión Académica)

### **CP-PROF-002: Acceso al Portal Docente**
- **Precondición**: Usuario autenticado como profesor
- **Pasos**:
  1. Hacer clic en "Portal Docente" en el menú
  2. Verificar carga de `/TeacherGradebook/Index`
- **Resultado Esperado**:
  - ✅ Vista del portal docente se carga correctamente
  - ✅ Muestra las asignaturas del profesor
  - ✅ Muestra los grupos asignados por materia
- **Validaciones**:
  - [ ] Lista de materias asignadas visible
  - [ ] Grupos asociados a cada materia
  - [ ] Información del profesor (nombre, email)
  - [ ] Filtros de trimestre disponibles

---

### **CP-PROF-003: Selección de Materia y Grupo**
- **Precondición**: Estar en el Portal Docente
- **Pasos**:
  1. Seleccionar una materia del listado
  2. Seleccionar un grupo específico
  3. Seleccionar un trimestre
  4. Hacer clic en "Cargar Estudiantes" o botón equivalente
- **Resultado Esperado**:
  - ✅ Lista de estudiantes del grupo se carga
  - ✅ Se muestran las actividades existentes
  - ✅ Grid de calificaciones visible
- **Validaciones**:
  - [ ] Estudiantes ordenados alfabéticamente
  - [ ] Columnas de actividades visibles
  - [ ] Posibilidad de ingresar/editar notas
  - [ ] Pestañas: Notas, Asistencia, Actividades

---

### **CP-PROF-004: Crear Nueva Actividad**
- **Precondición**: Materia, grupo y trimestre seleccionados
- **Pasos**:
  1. Ir a la pestaña "Actividades"
  2. Hacer clic en "Crear Nueva Actividad"
  3. Completar el formulario:
     - **Nombre**: "Examen Parcial 1"
     - **Tipo**: Examen
     - **Fecha de entrega**: [Fecha futura]
     - **Trimestre**: I Trimestre
  4. Opcionalmente adjuntar un PDF
  5. Hacer clic en "Guardar"
- **Resultado Esperado**:
  - ✅ Actividad creada exitosamente
  - ✅ Mensaje de confirmación
  - ✅ Actividad aparece en el listado
  - ✅ Nueva columna en la tabla de notas
- **Validaciones**:
  - [ ] Actividad visible en la tabla
  - [ ] PDF adjunto (si aplica) descargable
  - [ ] Fecha de entrega correcta
  - [ ] Tipo de actividad correcto

---

### **CP-PROF-005: Ingresar Notas de Estudiantes**
- **Precondición**: Actividad creada previamente
- **Pasos**:
  1. Ir a la pestaña "Notas"
  2. Seleccionar la actividad creada
  3. Ingresar notas para varios estudiantes:
     - Estudiante 1: 4.5
     - Estudiante 2: 3.8
     - Estudiante 3: 2.9
     - Estudiante 4: 5.0
  4. Hacer clic en "Guardar Notas"
- **Resultado Esperado**:
  - ✅ Notas guardadas correctamente
  - ✅ Mensaje de confirmación
  - ✅ Notas visibles en el grid
- **Validaciones**:
  - [ ] Notas se guardan sin errores
  - [ ] Promedios se calculan automáticamente
  - [ ] Indicador de estado (Aprobado/Reprobado) correcto
  - [ ] Notas no se pierden al refrescar la página

---

### **CP-PROF-006: Editar Actividad Existente**
- **Precondición**: Actividad creada previamente
- **Pasos**:
  1. Ir a la pestaña "Actividades"
  2. Seleccionar una actividad existente
  3. Hacer clic en "Editar"
  4. Modificar el nombre: "Examen Parcial 1 - Actualizado"
  5. Cambiar la fecha de entrega
  6. Guardar cambios
- **Resultado Esperado**:
  - ✅ Actividad actualizada correctamente
  - ✅ Mensaje de confirmación
  - ✅ Cambios reflejados en el listado
- **Validaciones**:
  - [ ] Nombre actualizado
  - [ ] Fecha de entrega actualizada
  - [ ] Notas previamente ingresadas no se pierden

---

### **CP-PROF-007: Eliminar Actividad**
- **Precondición**: Actividad sin notas asignadas
- **Pasos**:
  1. Ir a la pestaña "Actividades"
  2. Seleccionar una actividad
  3. Hacer clic en "Eliminar"
  4. Confirmar la eliminación
- **Resultado Esperado**:
  - ✅ Actividad eliminada correctamente
  - ✅ Mensaje de confirmación
  - ✅ Actividad ya no aparece en el listado
- **Validaciones**:
  - [ ] Actividad eliminada de la base de datos
  - [ ] Columna eliminada del grid de notas
  - [ ] Sin errores de integridad

---

### **CP-PROF-008: Registro de Asistencia**
- **Precondición**: Grupo y grado seleccionados
- **Pasos**:
  1. Ir a la pestaña "Asistencia"
  2. Seleccionar una fecha
  3. Marcar asistencia para cada estudiante:
     - Presente (P)
     - Ausente (A)
     - Tardanza (T)
     - Justificado (J)
  4. Hacer clic en "Guardar Asistencias"
- **Resultado Esperado**:
  - ✅ Asistencias guardadas correctamente
  - ✅ Mensaje de confirmación
  - ✅ Estadísticas de asistencia actualizadas
- **Validaciones**:
  - [ ] Asistencias guardadas para la fecha correcta
  - [ ] Estadísticas reflejan datos actualizados
  - [ ] Historial de asistencia disponible
  - [ ] Posibilidad de editar asistencias pasadas

---

### **CP-PROF-009: Ver Historial de Asistencia**
- **Precondición**: Asistencias registradas previamente
- **Pasos**:
  1. Ir a la pestaña "Asistencia"
  2. Hacer clic en "Ver Historial"
  3. Seleccionar rango de fechas
  4. Hacer clic en "Buscar"
- **Resultado Esperado**:
  - ✅ Historial de asistencia se muestra
  - ✅ Datos organizados por fecha
  - ✅ Estadísticas por estudiante
- **Validaciones**:
  - [ ] Datos correctos por fecha
  - [ ] Porcentajes de asistencia calculados
  - [ ] Opción de exportar a Excel/PDF

---

### **CP-PROF-010: Ver Estadísticas de Asistencia**
- **Precondición**: Asistencias registradas
- **Pasos**:
  1. Ir a la pestaña "Asistencia"
  2. Hacer clic en "Estadísticas"
  3. Seleccionar trimestre
  4. Ver resumen estadístico
- **Resultado Esperado**:
  - ✅ Estadísticas generales visibles
  - ✅ Gráficos o indicadores visuales
  - ✅ Porcentaje de asistencia por grupo
- **Validaciones**:
  - [ ] Estadísticas correctas
  - [ ] Visualización clara (gráficos/tablas)
  - [ ] Filtros por trimestre funcionales

---

### **CP-PROF-011: Ver Promedios Finales de Estudiantes**
- **Precondición**: Notas ingresadas en múltiples actividades
- **Pasos**:
  1. Ir a la pestaña "Notas"
  2. Hacer clic en "Ver Promedios Finales"
  3. Verificar cálculo de promedios
- **Resultado Esperado**:
  - ✅ Promedios calculados correctamente
  - ✅ Indicador de Aprobado/Reprobado
  - ✅ Promedios por trimestre y final
- **Validaciones**:
  - [ ] Cálculo correcto de promedios
  - [ ] Estado correcto (>=3.0 Aprobado, <3.0 Reprobado)
  - [ ] Exportación disponible

---

### **CP-PROF-012: Descargar Material Adjunto de Actividad**
- **Precondición**: Actividad con PDF adjunto
- **Pasos**:
  1. Ir a la pestaña "Actividades"
  2. Hacer clic en el ícono de PDF de una actividad
  3. Verificar descarga del archivo
- **Resultado Esperado**:
  - ✅ Archivo PDF descargado correctamente
  - ✅ Contenido del PDF correcto
- **Validaciones**:
  - [ ] Descarga exitosa
  - [ ] Archivo no corrupto
  - [ ] Nombre de archivo descriptivo

---

## 3️⃣ REPORTES DE ORIENTACIÓN (Consejería)

### **CP-PROF-013: Acceso a Reportes de Orientación**
- **Precondición**: Profesor asignado como consejero de un grupo
- **Pasos**:
  1. Hacer clic en "Reportes de Orientación" (si visible en menú)
  2. O acceder desde el Portal Docente
  3. Verificar carga de `/OrientationReport/Index`
- **Resultado Esperado**:
  - ✅ Vista de reportes de orientación cargada
  - ✅ Listado de reportes existentes (si los hay)
  - ✅ Opción de crear nuevo reporte
- **Validaciones**:
  - [ ] Solo grupos asignados como consejero visibles
  - [ ] Botón "Crear Reporte" disponible
  - [ ] Filtros de búsqueda disponibles

---

### **CP-PROF-014: Crear Reporte de Orientación**
- **Precondición**: Ser consejero de al menos un grupo
- **Pasos**:
  1. Hacer clic en "Crear Nuevo Reporte"
  2. Seleccionar estudiante del grupo
  3. Completar formulario:
     - **Tipo**: Académico / Conductual / Personal
     - **Descripción**: "Estudiante muestra mejoras en comportamiento"
     - **Recomendaciones**: "Continuar con seguimiento"
     - **Fecha**: [Fecha actual]
  4. Adjuntar archivos (opcional)
  5. Guardar reporte
- **Resultado Esperado**:
  - ✅ Reporte creado exitosamente
  - ✅ Mensaje de confirmación
  - ✅ Reporte visible en el listado
- **Validaciones**:
  - [ ] Reporte guardado correctamente
  - [ ] Archivos adjuntos (si los hay) almacenados
  - [ ] Información completa en el reporte

---

### **CP-PROF-015: Editar Reporte de Orientación**
- **Precondición**: Reporte creado previamente
- **Pasos**:
  1. Seleccionar un reporte del listado
  2. Hacer clic en "Editar"
  3. Modificar descripción o recomendaciones
  4. Guardar cambios
- **Resultado Esperado**:
  - ✅ Reporte actualizado
  - ✅ Cambios reflejados en el listado
- **Validaciones**:
  - [ ] Información actualizada correctamente
  - [ ] Fecha de modificación registrada

---

### **CP-PROF-016: Ver Detalles de Reporte**
- **Precondición**: Reporte existente
- **Pasos**:
  1. Hacer clic en un reporte del listado
  2. Verificar vista de detalles
- **Resultado Esperado**:
  - ✅ Todos los detalles del reporte visibles
  - ✅ Archivos adjuntos descargables
- **Validaciones**:
  - [ ] Información completa
  - [ ] Formato legible
  - [ ] Archivos accesibles

---

### **CP-PROF-017: Enviar Reporte por Email**
- **Precondición**: Reporte creado y configuración de email activa
- **Pasos**:
  1. Seleccionar un reporte
  2. Hacer clic en "Enviar por Email"
  3. Confirmar envío
- **Resultado Esperado**:
  - ✅ Email enviado correctamente
  - ✅ Mensaje de confirmación
- **Validaciones**:
  - [ ] Email recibido por destinatario
  - [ ] Contenido del email correcto
  - [ ] Adjuntos incluidos (si aplica)

---

### **CP-PROF-018: Ver Promedios del Grupo como Consejero**
- **Precondición**: Ser consejero de un grupo con notas registradas
- **Pasos**:
  1. Acceder al Portal Docente
  2. Seleccionar opción "Consejería" o "Mi Grupo"
  3. Ver promedios generales del grupo
- **Resultado Esperado**:
  - ✅ Promedios de todas las materias visibles
  - ✅ Estadísticas del grupo
  - ✅ Identificación de estudiantes en riesgo
- **Validaciones**:
  - [ ] Promedios correctos por materia
  - [ ] Promedio general del grupo calculado
  - [ ] Porcentaje de aprobación/reprobación
  - [ ] Lista de estudiantes ordenada por rendimiento

---

## 4️⃣ MENSAJERÍA

### **CP-PROF-019: Acceso al Sistema de Mensajería**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Hacer clic en "Mensajes" en el menú
  2. Verificar carga de `/Messaging/Index`
- **Resultado Esperado**:
  - ✅ Bandeja de entrada visible
  - ✅ Mensajes recibidos listados
  - ✅ Opción de enviar nuevo mensaje
- **Validaciones**:
  - [ ] Mensajes ordenados por fecha
  - [ ] Indicador de mensajes no leídos
  - [ ] Botón "Nuevo Mensaje" disponible

---

### **CP-PROF-020: Enviar Mensaje a un Estudiante**
- **Precondición**: En la vista de mensajería
- **Pasos**:
  1. Hacer clic en "Nuevo Mensaje"
  2. Seleccionar destinatario (Estudiante)
  3. Completar:
     - **Asunto**: "Recordatorio de tarea"
     - **Mensaje**: "Recuerda entregar tu trabajo el viernes"
  4. Hacer clic en "Enviar"
- **Resultado Esperado**:
  - ✅ Mensaje enviado correctamente
  - ✅ Confirmación de envío
  - ✅ Mensaje aparece en "Enviados"
- **Validaciones**:
  - [ ] Mensaje recibido por estudiante
  - [ ] Mensaje en bandeja de enviados
  - [ ] Fecha y hora correctas

---

### **CP-PROF-021: Enviar Mensaje a Administrador/Director**
- **Precondición**: En la vista de mensajería
- **Pasos**:
  1. Hacer clic en "Nuevo Mensaje"
  2. Seleccionar destinatario (Admin/Director)
  3. Completar asunto y mensaje
  4. Enviar
- **Resultado Esperado**:
  - ✅ Mensaje enviado correctamente
  - ✅ Admin/Director recibe el mensaje
- **Validaciones**:
  - [ ] Mensaje entregado correctamente
  - [ ] Sin errores de permisos

---

### **CP-PROF-022: Responder un Mensaje**
- **Precondición**: Mensaje recibido
- **Pasos**:
  1. Abrir un mensaje de la bandeja de entrada
  2. Hacer clic en "Responder"
  3. Escribir respuesta
  4. Enviar
- **Resultado Esperado**:
  - ✅ Respuesta enviada
  - ✅ Hilo de conversación visible
- **Validaciones**:
  - [ ] Respuesta vinculada al mensaje original
  - [ ] Destinatario correcto
  - [ ] Historial de conversación completo

---

### **CP-PROF-023: Marcar Mensaje como Leído/No Leído**
- **Precondición**: Mensajes en bandeja de entrada
- **Pasos**:
  1. Seleccionar un mensaje
  2. Marcar como leído/no leído
- **Resultado Esperado**:
  - ✅ Estado actualizado
  - ✅ Indicador visual correcto
- **Validaciones**:
  - [ ] Estado persistente
  - [ ] Contador de no leídos actualizado

---

## 5️⃣ CAMBIO DE CONTRASEÑA

### **CP-PROF-024: Cambiar Contraseña Correctamente**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Ir a "Cambiar Contraseña"
  2. Ingresar:
     - **Contraseña Actual**: Profesor123!
     - **Nueva Contraseña**: NuevaProf456!
     - **Confirmar Contraseña**: NuevaProf456!
  3. Hacer clic en "Cambiar"
- **Resultado Esperado**:
  - ✅ Contraseña cambiada exitosamente
  - ✅ Mensaje de confirmación
  - ✅ Siguiente login requiere nueva contraseña
- **Validaciones**:
  - [ ] Contraseña actualizada en BD
  - [ ] Login con nueva contraseña exitoso
  - [ ] Login con contraseña antigua falla

---

### **CP-PROF-025: Validar Contraseña Actual Incorrecta**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Ir a "Cambiar Contraseña"
  2. Ingresar contraseña actual incorrecta
  3. Intentar cambiar
- **Resultado Esperado**:
  - ✅ Error: "Contraseña actual incorrecta"
  - ✅ Cambio no permitido
- **Validaciones**:
  - [ ] Mensaje de error claro
  - [ ] Contraseña no cambiada

---

### **CP-PROF-026: Validar Confirmación de Contraseña**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Ir a "Cambiar Contraseña"
  2. Ingresar contraseña actual correcta
  3. Nueva contraseña y confirmación NO coinciden
  4. Intentar cambiar
- **Resultado Esperado**:
  - ✅ Error: "Las contraseñas no coinciden"
  - ✅ Cambio no permitido
- **Validaciones**:
  - [ ] Validación del lado del cliente
  - [ ] Validación del lado del servidor
  - [ ] Mensaje de error apropiado

---

## 6️⃣ PRUEBAS DE SEGURIDAD Y PERMISOS

### **CP-PROF-027: Restricción de Acceso a Módulos de Admin**
- **Precondición**: Usuario autenticado como profesor
- **Pasos**:
  1. Intentar acceder manualmente a:
     - `/Student/Index` (administración de estudiantes)
     - `/User/Index` (administración de usuarios)
     - `/School/Index` (administración de escuelas)
- **Resultado Esperado**:
  - ✅ Acceso denegado (403 Forbidden)
  - ✅ Redirección a página de error o dashboard
- **Validaciones**:
  - [ ] No se puede acceder a módulos no autorizados
  - [ ] Mensaje de error apropiado
  - [ ] Sin exposición de información sensible

---

### **CP-PROF-028: Ver Solo Grupos Asignados**
- **Precondición**: Usuario autenticado como profesor
- **Pasos**:
  1. Acceder al Portal Docente
  2. Verificar listado de grupos
- **Resultado Esperado**:
  - ✅ Solo grupos asignados al profesor visibles
  - ✅ No se muestran grupos de otros profesores
- **Validaciones**:
  - [ ] Filtrado correcto por profesor
  - [ ] Sin acceso a datos de otros profesores

---

### **CP-PROF-029: Editar Solo Notas de Grupos Propios**
- **Precondición**: Usuario autenticado como profesor
- **Pasos**:
  1. Intentar acceder a notas de un grupo no asignado (URL directa)
  2. Intentar modificar notas
- **Resultado Esperado**:
  - ✅ Acceso denegado o sin datos
  - ✅ No se permite modificación
- **Validaciones**:
  - [ ] Validación de permisos
  - [ ] Sin acceso a datos no autorizados

---

## 7️⃣ PRUEBAS DE RENDIMIENTO Y UX

### **CP-PROF-030: Tiempo de Carga del Portal Docente**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Acceder al Portal Docente
  2. Medir tiempo de carga
- **Resultado Esperado**:
  - ✅ Página cargada en < 3 segundos
  - ✅ Datos visibles rápidamente
- **Validaciones**:
  - [ ] Tiempo de carga aceptable
  - [ ] Sin errores de timeout

---

### **CP-PROF-031: Guardar Notas de Forma Masiva**
- **Precondición**: Grupo con 30+ estudiantes
- **Pasos**:
  1. Ingresar notas para todos los estudiantes
  2. Guardar
  3. Verificar tiempo de respuesta
- **Resultado Esperado**:
  - ✅ Todas las notas guardadas correctamente
  - ✅ Proceso completado en < 5 segundos
- **Validaciones**:
  - [ ] Sin pérdida de datos
  - [ ] Feedback visual del proceso
  - [ ] Mensaje de éxito claro

---

### **CP-PROF-032: Responsive en Dispositivos Móviles**
- **Precondición**: Acceso desde smartphone/tablet
- **Pasos**:
  1. Abrir aplicación en dispositivo móvil
  2. Navegar por módulos principales
  3. Ingresar notas
  4. Ver asistencias
- **Resultado Esperado**:
  - ✅ Interface adaptada a pantalla móvil
  - ✅ Funcionalidades accesibles
  - ✅ Botones y controles de tamaño adecuado
- **Validaciones**:
  - [ ] Layout responsive correcto
  - [ ] Sin overflow horizontal
  - [ ] Navegación funcional en móvil

---

## 📊 RESUMEN DE CASOS DE PRUEBA

| Módulo | Casos de Prueba | Prioridad |
|--------|----------------|-----------|
| Dashboard | 1 | Alta |
| Portal Docente | 11 | Crítica |
| Reportes de Orientación | 6 | Alta |
| Mensajería | 5 | Media |
| Cambio de Contraseña | 3 | Alta |
| Seguridad y Permisos | 3 | Crítica |
| Rendimiento y UX | 3 | Media |
| **TOTAL** | **32** | - |

---

## ✅ CHECKLIST GLOBAL DE VALIDACIÓN

### Funcionalidad General
- [ ] Todas las vistas cargan sin errores
- [ ] Navegación entre módulos fluida
- [ ] Mensajes de error/éxito claros
- [ ] Logs de auditoría registrados

### Gestión de Notas
- [ ] Crear actividades funciona correctamente
- [ ] Editar actividades mantiene integridad de datos
- [ ] Eliminar actividades sin impacto negativo
- [ ] Ingresar notas guarda correctamente
- [ ] Promedios se calculan automáticamente
- [ ] Exportación de notas disponible

### Asistencias
- [ ] Registro de asistencia diaria funcional
- [ ] Historial de asistencia accesible
- [ ] Estadísticas calculadas correctamente
- [ ] Filtros por fecha/trimestre funcionan

### Reportes de Orientación
- [ ] Crear reportes como consejero
- [ ] Editar reportes existentes
- [ ] Ver detalles completos
- [ ] Envío por email funcional
- [ ] Adjuntar archivos posible

### Mensajería
- [ ] Enviar mensajes a estudiantes
- [ ] Enviar mensajes a admin/director
- [ ] Responder mensajes
- [ ] Marcar como leído/no leído
- [ ] Notificaciones de nuevos mensajes

### Seguridad
- [ ] No acceso a módulos de admin
- [ ] Solo datos propios visibles
- [ ] Cambio de contraseña funcional
- [ ] Sesión expira correctamente
- [ ] Tokens de seguridad válidos

### Experiencia de Usuario
- [ ] Interface intuitiva
- [ ] Responsive design funcional
- [ ] Tiempos de carga aceptables
- [ ] Feedback visual claro
- [ ] Sin errores de consola JavaScript

---

## 🎯 CRITERIOS DE ACEPTACIÓN

### ✅ Prueba EXITOSA si:
1. Todos los casos críticos y de alta prioridad PASAN
2. Al menos 90% de casos totales PASAN
3. No hay errores bloqueantes (Severity 1)
4. Rendimiento dentro de límites aceptables
5. Seguridad sin vulnerabilidades críticas

### ❌ Prueba FALLIDA si:
1. Cualquier caso crítico FALLA
2. Más de 10% de casos totales FALLAN
3. Existen errores bloqueantes
4. Problemas de seguridad críticos detectados
5. Rendimiento inaceptable en funcionalidades clave

---

## 📝 NOTAS IMPORTANTES

1. **Ejecutar en orden**: Los casos de prueba están ordenados de forma lógica
2. **Datos de prueba**: Usar datos dummy consistentes
3. **Documentar hallazgos**: Registrar todos los bugs encontrados
4. **Capturas de pantalla**: Tomar evidencia de errores
5. **Logs del servidor**: Revisar logs en caso de errores

---

## 🔄 PRÓXIMOS PASOS

Después de completar estas pruebas:
1. Documentar todos los bugs encontrados
2. Priorizar correcciones (Crítico → Alto → Medio → Bajo)
3. Re-ejecutar pruebas después de correcciones
4. Proceder con pruebas para rol **Estudiante**
5. Realizar pruebas de integración entre roles

---

**Fecha de Creación**: 16 de Octubre de 2025  
**Versión**: 1.0  
**Estado**: Listo para Ejecución

