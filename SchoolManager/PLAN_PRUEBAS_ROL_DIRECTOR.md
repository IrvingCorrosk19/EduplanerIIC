# 📋 PLAN DE PRUEBAS - ROL DIRECTOR

## 🎯 OBJETIVO
Validar de manera integral todas las funcionalidades disponibles para el rol de **Director** en el sistema EduPlanner, enfocándose en la supervisión académica, análisis de desempeño y acceso a reportes institucionales.

---

## 👤 DATOS DE PRUEBA

### Usuario de Prueba: Director
- **Email**: director@test.com
- **Contraseña**: Director123!
- **Rol**: director
- **Escuela**: IPT San Miguelito

---

## 📑 MÓDULOS A PROBAR

### 1️⃣ DASHBOARD (Portal Principal)
### 2️⃣ PORTAL DIRECTOR (Supervisión Académica)
### 3️⃣ REPORTES DE APROBADOS Y REPROBADOS
### 4️⃣ MENSAJERÍA
### 5️⃣ CAMBIO DE CONTRASEÑA

---

## 🧪 CASOS DE PRUEBA DETALLADOS

---

## 1️⃣ DASHBOARD (Portal Principal)

### **CP-DIR-001: Acceso al Dashboard**
- **Precondición**: Usuario autenticado como director
- **Pasos**:
  1. Iniciar sesión con credenciales de director
  2. Verificar redirección automática a `/Home/Index`
  3. Observar los widgets y estadísticas del dashboard
- **Resultado Esperado**:
  - ✅ Dashboard se carga correctamente
  - ✅ Muestra información institucional general
  - ✅ Widgets relevantes visibles (estadísticas generales, etc.)
- **Validaciones**:
  - [ ] Nombre del director visible en la barra superior
  - [ ] Logo de la escuela cargado correctamente
  - [ ] Menú lateral con opciones de director
  - [ ] No se muestran opciones de administrador/superadmin

---

## 2️⃣ PORTAL DIRECTOR (Supervisión Académica)

### **CP-DIR-002: Acceso al Portal Director**
- **Precondición**: Usuario autenticado como director
- **Pasos**:
  1. Hacer clic en "Portal Director" en el menú
  2. Verificar carga de `/Director/Index`
- **Resultado Esperado**:
  - ✅ Vista del portal director se carga correctamente
  - ✅ Muestra estadísticas generales de la escuela
  - ✅ Sección de exportación de reportes visible
- **Validaciones**:
  - [ ] Totales de estudiantes, aprobados, reprobados visibles
  - [ ] Filtro por trimestre disponible
  - [ ] Botones de exportación a Excel funcionales
  - [ ] Información del director (nombre, escuela)

---

### **CP-DIR-003: Visualización de Estadísticas Generales**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Observar las tarjetas de estadísticas generales
  2. Verificar totales de estudiantes, aprobados, reprobados, sin evaluar
  3. Verificar porcentajes calculados
- **Resultado Esperado**:
  - ✅ Estadísticas generales se muestran correctamente
  - ✅ Porcentajes calculados automáticamente
  - ✅ Colores y iconos apropiados para cada métrica
- **Validaciones**:
  - [ ] Total estudiantes = Aprobados + Reprobados + Sin Evaluar
  - [ ] Porcentajes suman 100%
  - [ ] Colores: Verde (aprobados), Rojo (reprobados), Amarillo (sin evaluar)
  - [ ] Iconos representativos para cada métrica

---

### **CP-DIR-004: Filtrado por Trimestre**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Seleccionar un trimestre específico del dropdown
  2. Verificar que los datos se actualicen
  3. Seleccionar "Todos los trimestres"
  4. Verificar que se muestren datos consolidados
- **Resultado Esperado**:
  - ✅ Datos se filtran correctamente por trimestre
  - ✅ Estadísticas se actualizan dinámicamente
  - [ ] Filtro "Todos los trimestres" muestra datos consolidados
- **Validaciones**:
  - [ ] Cambio de trimestre actualiza todas las secciones
  - [ ] Datos consistentes entre filtros
  - [ ] Sin errores de carga durante el filtrado

---

### **CP-DIR-005: Desempeño por Materia**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Observar la sección "Desempeño por Materia"
  2. Verificar que se muestren las materias con sus estadísticas
  3. Probar la búsqueda de materias
  4. Navegar por las páginas de resultados
- **Resultado Esperado**:
  - ✅ Lista de materias con desempeño visible
  - ✅ Búsqueda funcional
  - ✅ Paginación operativa
- **Validaciones**:
  - [ ] Cada materia muestra: nombre, estudiantes, promedio, aprobados, reprobados
  - [ ] Barras de progreso con colores apropiados
  - [ ] Búsqueda filtra resultados en tiempo real
  - [ ] Paginación navega correctamente

---

### **CP-DIR-006: Análisis de Profesores**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Observar la tabla de profesores
  2. Verificar información de cada profesor
  3. Probar búsqueda por nombre o materia
  4. Navegar por las páginas
- **Resultado Esperado**:
  - ✅ Tabla de profesores con información completa
  - ✅ Búsqueda funcional
  - ✅ Estados de desempeño visibles
- **Validaciones**:
  - [ ] Cada profesor muestra: nombre, materia, desempeño, estudiantes, promedio
  - [ ] Estados: Excelente, Regular, Crítico con colores apropiados
  - [ ] Última actividad registrada
  - [ ] Búsqueda funciona por nombre y materia

---

### **CP-DIR-007: Estadísticas de Aprobación**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Observar la sección "Estadísticas de Aprobación"
  2. Verificar tasa de aprobación general
  3. Revisar análisis de tendencia
  4. Leer recomendaciones
- **Resultado Esperado**:
  - ✅ Tasa de aprobación general calculada correctamente
  - ✅ Barra de progreso visual
  - ✅ Análisis de tendencia mostrado
  - ✅ Recomendaciones listadas
- **Validaciones**:
  - [ ] Tasa de aprobación entre 0-100%
  - [ ] Barra de progreso con color verde
  - [ ] Análisis de tendencia descriptivo
  - [ ] Recomendaciones relevantes y útiles

---

### **CP-DIR-008: Aprobación por Materia**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Observar la sección "Aprobación por Materia"
  2. Verificar criterios de aprobación
  3. Navegar por las páginas de materias
- **Resultado Esperado**:
  - ✅ Lista de materias con porcentajes de aprobación
  - ✅ Criterios de aprobación visibles
  - ✅ Paginación funcional
- **Validaciones**:
  - [ ] Cada materia muestra porcentaje de aprobación
  - [ ] Colores: Verde (≥80%), Amarillo (60-79%), Rojo (<60%)
  - [ ] Criterios de aprobación claramente definidos
  - [ ] Información del profesor asignado

---

### **CP-DIR-009: Alertas y Notificaciones**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Observar la sección "Alertas y Notificaciones"
  2. Verificar diferentes tipos de alertas
  3. Navegar por las páginas de alertas
- **Resultado Esperado**:
  - ✅ Lista de alertas relevantes
  - ✅ Diferentes tipos de alertas con iconos apropiados
  - ✅ Paginación funcional
- **Validaciones**:
  - [ ] Tipos de alertas: Bajo, Excelente, Reporte, Crítico
  - [ ] Iconos y colores apropiados para cada tipo
  - [ ] Títulos y mensajes descriptivos
  - [ ] Alertas ordenadas por relevancia

---

### **CP-DIR-010: Exportación de Reportes - Desempeño por Materia**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Hacer clic en "Exportar Desempeño por Materia"
  2. Verificar descarga del archivo Excel
  3. Abrir el archivo y verificar contenido
- **Resultado Esperado**:
  - ✅ Archivo Excel descargado correctamente
  - ✅ Contenido completo y bien formateado
- **Validaciones**:
  - [ ] Archivo descargado con nombre descriptivo
  - [ ] Columnas: Materia, Estudiantes, Promedio, Aprobados, Reprobados
  - [ ] Datos consistentes con la vista web
  - [ ] Formato Excel legible

---

### **CP-DIR-011: Exportación de Reportes - Profesores**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Hacer clic en "Exportar Profesores"
  2. Verificar descarga del archivo Excel
  3. Abrir el archivo y verificar contenido
- **Resultado Esperado**:
  - ✅ Archivo Excel descargado correctamente
  - ✅ Información completa de profesores
- **Validaciones**:
  - [ ] Columnas: Profesor, Materia, Desempeño, Estudiantes, Promedio, etc.
  - [ ] Datos consistentes con la tabla web
  - [ ] Formato apropiado para análisis

---

### **CP-DIR-012: Exportación de Reportes - Aprobación por Materia**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Hacer clic en "Exportar Aprobación por Materia"
  2. Verificar descarga del archivo Excel
  3. Abrir el archivo y verificar contenido
- **Resultado Esperado**:
  - ✅ Archivo Excel descargado correctamente
  - ✅ Datos de aprobación por materia
- **Validaciones**:
  - [ ] Columnas: Materia, Profesor, Total Estudiantes, Aprobados, Reprobados, % Aprobación
  - [ ] Porcentajes calculados correctamente
  - [ ] Datos consistentes con la vista

---

### **CP-DIR-013: Exportación de Reportes - Alertas**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Hacer clic en "Exportar Alertas y Notificaciones"
  2. Verificar descarga del archivo Excel
  3. Abrir el archivo y verificar contenido
- **Resultado Esperado**:
  - ✅ Archivo Excel descargado correctamente
  - ✅ Lista completa de alertas
- **Validaciones**:
  - [ ] Columnas: Tipo, Título, Mensaje
  - [ ] Todas las alertas incluidas
  - [ ] Formato legible y organizado

---

## 3️⃣ REPORTES DE APROBADOS Y REPROBADOS

### **CP-DIR-014: Acceso a Reportes de Aprobados y Reprobados**
- **Precondición**: Usuario autenticado como director
- **Pasos**:
  1. Hacer clic en "Reportes" en el menú
  2. Seleccionar "Aprobados y Reprobados"
  3. Verificar carga de `/AprobadosReprobados/Index`
- **Resultado Esperado**:
  - ✅ Vista de reportes cargada correctamente
  - ✅ Filtros disponibles para generar reportes
  - ✅ Opciones de exportación visibles
- **Validaciones**:
  - [ ] Filtros: Trimestre, Nivel Educativo, Grado, Grupo, Especialidad, Área, Materia
  - [ ] Botón "Generar Reporte" disponible
  - [ ] Opciones de exportación a PDF y Excel

---

### **CP-DIR-015: Generar Reporte con Filtros Básicos**
- **Precondición**: Estar en la vista de reportes
- **Pasos**:
  1. Seleccionar un trimestre
  2. Seleccionar un nivel educativo
  3. Hacer clic en "Generar Reporte"
  4. Verificar que se muestren los resultados
- **Resultado Esperado**:
  - ✅ Reporte generado correctamente
  - ✅ Datos filtrados según criterios seleccionados
  - ✅ Estadísticas y resúmenes visibles
- **Validaciones**:
  - [ ] Datos corresponden al trimestre seleccionado
  - [ ] Nivel educativo correcto
  - [ ] Estadísticas calculadas correctamente
  - [ ] Lista de estudiantes aprobados y reprobados

---

### **CP-DIR-016: Generar Reporte con Filtros Avanzados**
- **Precondición**: Estar en la vista de reportes
- **Pasos**:
  1. Seleccionar trimestre, nivel educativo, grado específico
  2. Seleccionar grupo específico
  3. Seleccionar especialidad y área
  4. Seleccionar materia específica
  5. Generar reporte
- **Resultado Esperado**:
  - ✅ Reporte generado con filtros específicos
  - ✅ Datos muy precisos según criterios
- **Validaciones**:
  - [ ] Solo estudiantes del grupo seleccionado
  - [ ] Solo datos de la materia específica
  - [ ] Filtros aplicados correctamente
  - [ ] Resultados coherentes con filtros

---

### **CP-DIR-017: Vista Previa del Reporte**
- **Precondición**: Reporte generado previamente
- **Pasos**:
  1. Hacer clic en "Vista Previa" o enlace similar
  2. Verificar carga de la vista previa
  3. Revisar formato y contenido
- **Resultado Esperado**:
  - ✅ Vista previa cargada correctamente
  - ✅ Formato apropiado para impresión
  - ✅ Información completa y bien organizada
- **Validaciones**:
  - [ ] Encabezado con información de la escuela
  - [ ] Datos del reporte bien formateados
  - [ ] Fecha y hora de generación
  - [ ] Firma del director/coordinador

---

### **CP-DIR-018: Exportar Reporte a PDF**
- **Precondición**: Reporte generado
- **Pasos**:
  1. Hacer clic en "Exportar PDF"
  2. Verificar descarga del archivo
  3. Abrir el PDF y verificar contenido
- **Resultado Esperado**:
  - ✅ Archivo PDF descargado correctamente
  - ✅ Formato profesional y legible
- **Validaciones**:
  - [ ] PDF se abre sin errores
  - [ ] Contenido idéntico al reporte web
  - [ ] Formato apropiado para impresión
  - [ ] Nombre de archivo descriptivo

---

### **CP-DIR-019: Exportar Reporte a Excel**
- **Precondición**: Reporte generado
- **Pasos**:
  1. Hacer clic en "Exportar Excel"
  2. Verificar descarga del archivo
  3. Abrir el archivo Excel
- **Resultado Esperado**:
  - ✅ Archivo Excel descargado correctamente
  - ✅ Datos organizados en hojas de cálculo
- **Validaciones**:
  - [ ] Excel se abre sin errores
  - [ ] Datos organizados en columnas apropiadas
  - [ ] Fórmulas y cálculos correctos
  - [ ] Formato profesional

---

### **CP-DIR-020: Filtros Dinámicos - Especialidades**
- **Precondición**: Estar en la vista de reportes
- **Pasos**:
  1. Seleccionar nivel educativo
  2. Verificar que se carguen las especialidades disponibles
  3. Seleccionar una especialidad
  4. Verificar que se actualicen otros filtros
- **Resultado Esperado**:
  - ✅ Especialidades se cargan dinámicamente
  - ✅ Filtros dependientes se actualizan
- **Validaciones**:
  - [ ] Solo especialidades del nivel seleccionado
  - [ ] Filtros de área y materia se actualizan
  - [ ] Sin errores de carga

---

### **CP-DIR-021: Filtros Dinámicos - Áreas y Materias**
- **Precondición**: Especialidad seleccionada
- **Pasos**:
  1. Seleccionar un área
  2. Verificar que se carguen las materias de esa área
  3. Seleccionar una materia específica
- **Resultado Esperado**:
  - ✅ Materias se filtran por área
  - ✅ Filtros funcionan correctamente
- **Validaciones**:
  - [ ] Solo materias del área seleccionada
  - [ ] Filtros en cascada funcionan
  - [ ] Sin duplicados o errores

---

## 4️⃣ MENSAJERÍA

### **CP-DIR-022: Acceso al Sistema de Mensajería**
- **Precondición**: Usuario autenticado como director
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

### **CP-DIR-023: Enviar Mensaje a Profesores**
- **Precondición**: En la vista de mensajería
- **Pasos**:
  1. Hacer clic en "Nuevo Mensaje"
  2. Seleccionar destinatario (Profesor)
  3. Completar asunto y mensaje
  4. Enviar
- **Resultado Esperado**:
  - ✅ Mensaje enviado correctamente
  - ✅ Profesor recibe el mensaje
- **Validaciones**:
  - [ ] Lista de profesores disponible
  - [ ] Mensaje entregado correctamente
  - [ ] Confirmación de envío

---

### **CP-DIR-024: Enviar Mensaje a Administradores**
- **Precondición**: En la vista de mensajería
- **Pasos**:
  1. Hacer clic en "Nuevo Mensaje"
  2. Seleccionar destinatario (Administrador)
  3. Completar asunto y mensaje
  4. Enviar
- **Resultado Esperado**:
  - ✅ Mensaje enviado correctamente
  - ✅ Administrador recibe el mensaje
- **Validaciones**:
  - [ ] Lista de administradores disponible
  - [ ] Mensaje entregado correctamente
  - [ ] Sin errores de permisos

---

### **CP-DIR-025: Responder Mensajes**
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

### **CP-DIR-026: Gestionar Estado de Mensajes**
- **Precondición**: Mensajes en bandeja de entrada
- **Pasos**:
  1. Seleccionar mensajes
  2. Marcar como leído/no leído
  3. Archivar mensajes
- **Resultado Esperado**:
  - ✅ Estados actualizados correctamente
  - ✅ Indicadores visuales correctos
- **Validaciones**:
  - [ ] Estados persistentes
  - [ ] Contador de no leídos actualizado
  - [ ] Mensajes archivados no aparecen en bandeja principal

---

## 5️⃣ CAMBIO DE CONTRASEÑA

### **CP-DIR-027: Cambiar Contraseña Correctamente**
- **Precondición**: Usuario autenticado como director
- **Pasos**:
  1. Ir a "Cambiar Contraseña"
  2. Ingresar:
     - **Contraseña Actual**: Director123!
     - **Nueva Contraseña**: NuevaDir456!
     - **Confirmar Contraseña**: NuevaDir456!
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

### **CP-DIR-028: Validar Contraseña Actual Incorrecta**
- **Precondición**: Usuario autenticado como director
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

### **CP-DIR-029: Validar Confirmación de Contraseña**
- **Precondición**: Usuario autenticado como director
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

### **CP-DIR-030: Restricción de Acceso a Módulos de Admin**
- **Precondición**: Usuario autenticado como director
- **Pasos**:
  1. Intentar acceder manualmente a:
     - `/User/Index` (administración de usuarios)
     - `/School/Index` (administración de escuelas)
     - `/SuperAdmin/Index` (super administración)
- **Resultado Esperado**:
  - ✅ Acceso denegado (403 Forbidden)
  - ✅ Redirección a página de error o dashboard
- **Validaciones**:
  - [ ] No se puede acceder a módulos no autorizados
  - [ ] Mensaje de error apropiado
  - [ ] Sin exposición de información sensible

---

### **CP-DIR-031: Acceso Solo a Datos de su Escuela**
- **Precondición**: Usuario autenticado como director
- **Pasos**:
  1. Acceder al Portal Director
  2. Verificar que solo se muestren datos de su escuela
  3. Intentar acceder a datos de otras escuelas (si aplica)
- **Resultado Esperado**:
  - ✅ Solo datos de su escuela visibles
  - ✅ Sin acceso a datos de otras escuelas
- **Validaciones**:
  - [ ] Filtrado correcto por escuela
  - [ ] Sin exposición de datos de otras instituciones
  - [ ] Validación de permisos en backend

---

### **CP-DIR-032: Verificación de Roles en Menú**
- **Precondición**: Usuario autenticado como director
- **Pasos**:
  1. Verificar opciones del menú lateral
  2. Confirmar que solo aparecen opciones autorizadas
- **Resultado Esperado**:
  - ✅ Solo opciones de director visibles
  - ✅ Sin opciones de admin/superadmin
- **Validaciones**:
  - [ ] Portal Director visible
  - [ ] Reportes visibles
  - [ ] Mensajería visible
  - [ ] Cambio de contraseña visible
  - [ ] Sin opciones de gestión de usuarios/escuelas

---

## 7️⃣ PRUEBAS DE RENDIMIENTO Y UX

### **CP-DIR-033: Tiempo de Carga del Portal Director**
- **Precondición**: Usuario autenticado como director
- **Pasos**:
  1. Acceder al Portal Director
  2. Medir tiempo de carga inicial
  3. Medir tiempo de carga de datos AJAX
- **Resultado Esperado**:
  - ✅ Página cargada en < 3 segundos
  - ✅ Datos AJAX cargados en < 5 segundos
- **Validaciones**:
  - [ ] Tiempo de carga aceptable
  - [ ] Sin errores de timeout
  - [ ] Indicadores de carga visibles

---

### **CP-DIR-034: Rendimiento con Grandes Volúmenes de Datos**
- **Precondición**: Escuela con muchos estudiantes y profesores
- **Pasos**:
  1. Acceder al Portal Director
  2. Generar reportes con muchos datos
  3. Exportar archivos grandes
- **Resultado Esperado**:
  - ✅ Sistema maneja grandes volúmenes
  - ✅ Exportaciones completas sin errores
- **Validaciones**:
  - [ ] Sin errores de memoria
  - [ ] Paginación funciona correctamente
  - [ ] Exportaciones completas

---

### **CP-DIR-035: Responsive en Dispositivos Móviles**
- **Precondición**: Acceso desde smartphone/tablet
- **Pasos**:
  1. Abrir aplicación en dispositivo móvil
  2. Navegar por el Portal Director
  3. Generar reportes
  4. Exportar archivos
- **Resultado Esperado**:
  - ✅ Interface adaptada a pantalla móvil
  - ✅ Funcionalidades accesibles
  - ✅ Botones y controles de tamaño adecuado
- **Validaciones**:
  - [ ] Layout responsive correcto
  - [ ] Sin overflow horizontal
  - [ ] Navegación funcional en móvil
  - [ ] Tablas y gráficos legibles

---

### **CP-DIR-036: Filtros y Búsquedas en Tiempo Real**
- **Precondición**: Estar en el Portal Director
- **Pasos**:
  1. Usar filtro de trimestre
  2. Usar búsqueda de materias
  3. Usar búsqueda de profesores
  4. Verificar tiempo de respuesta
- **Resultado Esperado**:
  - ✅ Filtros responden en < 2 segundos
  - ✅ Búsquedas en tiempo real funcionan
- **Validaciones**:
  - [ ] Sin retrasos notables
  - [ ] Resultados precisos
  - [ ] Sin errores de JavaScript

---

## 📊 RESUMEN DE CASOS DE PRUEBA

| Módulo | Casos de Prueba | Prioridad |
|--------|----------------|-----------|
| Dashboard | 1 | Alta |
| Portal Director | 12 | Crítica |
| Reportes Aprobados/Reprobados | 8 | Crítica |
| Mensajería | 5 | Media |
| Cambio de Contraseña | 3 | Alta |
| Seguridad y Permisos | 3 | Crítica |
| Rendimiento y UX | 4 | Media |
| **TOTAL** | **36** | - |

---

## ✅ CHECKLIST GLOBAL DE VALIDACIÓN

### Funcionalidad General
- [ ] Todas las vistas cargan sin errores
- [ ] Navegación entre módulos fluida
- [ ] Mensajes de error/éxito claros
- [ ] Logs de auditoría registrados

### Portal Director
- [ ] Estadísticas generales calculadas correctamente
- [ ] Filtros por trimestre funcionan
- [ ] Desempeño por materia visible
- [ ] Análisis de profesores completo
- [ ] Alertas y notificaciones relevantes
- [ ] Exportaciones a Excel funcionan

### Reportes
- [ ] Generación de reportes funcional
- [ ] Filtros dinámicos operativos
- [ ] Vista previa correcta
- [ ] Exportación a PDF/Excel exitosa
- [ ] Datos consistentes y precisos

### Mensajería
- [ ] Envío de mensajes a profesores
- [ ] Envío de mensajes a administradores
- [ ] Respuesta a mensajes
- [ ] Gestión de estados
- [ ] Notificaciones de nuevos mensajes

### Seguridad
- [ ] No acceso a módulos de admin
- [ ] Solo datos de su escuela visibles
- [ ] Cambio de contraseña funcional
- [ ] Sesión expira correctamente
- [ ] Tokens de seguridad válidos

### Experiencia de Usuario
- [ ] Interface intuitiva y profesional
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
2. **Datos de prueba**: Usar datos dummy consistentes con estudiantes, profesores y calificaciones
3. **Documentar hallazgos**: Registrar todos los bugs encontrados
4. **Capturas de pantalla**: Tomar evidencia de errores
5. **Logs del servidor**: Revisar logs en caso de errores
6. **Pruebas de integración**: Verificar que los datos del director se integren correctamente con otros módulos

---

## 🔄 PRÓXIMOS PASOS

Después de completar estas pruebas:
1. Documentar todos los bugs encontrados
2. Priorizar correcciones (Crítico → Alto → Medio → Bajo)
3. Re-ejecutar pruebas después de correcciones
4. Proceder con pruebas para rol **Estudiante**
5. Realizar pruebas de integración entre roles
6. Validar flujos de trabajo completos (Director → Profesor → Estudiante)

---

**Fecha de Creación**: 16 de Octubre de 2025  
**Versión**: 1.0  
**Estado**: Listo para Ejecución
