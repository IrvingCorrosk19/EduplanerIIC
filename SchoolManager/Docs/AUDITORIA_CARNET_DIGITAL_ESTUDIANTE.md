# Auditoría: Funcionalidades existentes — Carnet digital del estudiante

**Fecha:** 2026-03-15  
**Alcance:** SchoolManager (backend + vistas) y flujo APK (escaneo, login, disciplina).  
**Objetivo:** Identificar qué está implementado en configuración, carnet, QR, perfil, contactos, incidencias y horarios antes de desarrollar nuevas funcionalidades.

---

## SECCIÓN 1 — Funcionalidades ya existentes

### 1.1 Módulo de carnet físico (frontal y reverso)

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Generación de carnet (frente) | ✅ Implementado | `StudentIdCardController` (ui/generate, ui/print), `StudentIdCardService.GenerateAsync`, `StudentIdCardPdfService` |
| Generación de carnet (reverso con QR) | ✅ Implementado | `StudentIdCardPdfService.RenderCarnetQrBack`: reverso con QR, nombre institución, texto “Escanea para verificar”, número de carnet |
| Número de carnet único | ✅ Implementado | `StudentIdCard.CardNumber`, formato `SM-{fecha}-{guid}-{sufijo}` |
| Revocación de carnet anterior al generar uno nuevo | ✅ Implementado | `StudentIdCardService`: marca `Status = "revoked"` y revoca tokens QR previos |
| Exportación a PDF para impresión | ✅ Implementado | `StudentIdCardController.Print`, `StudentIdCardPdfService.GenerateCardPdfAsync` (QuestPDF) |

### 1.2 QR del estudiante

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Generar token QR por estudiante | ✅ Implementado | `StudentIdCardService`: crea `StudentQrToken` (GUID) al generar carnet |
| Almacenar y revocar tokens | ✅ Implementado | Tabla `student_qr_tokens` (Token, StudentId, ExpiresAt, IsRevoked) |
| Renderizar QR en PDF (frente y/o reverso) | ✅ Implementado | `QrHelper.GenerateQrPng(dto.QrToken)`, usado en frente y reverso según `SchoolIdCardSetting.ShowQr` |
| Escanear QR y validar | ✅ Implementado | `StudentIdCardController.ScanApi` (POST `StudentIdCard/api/scan`), `StudentIdCardService.ScanAsync` |
| Registro de escaneos | ✅ Implementado | Tabla `scan_logs` (StudentId, ScanType, Result, ScannedBy, ScannedAt) |

### 1.3 Configuración del carnet por escuela

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Sección de configuración (UI) | ✅ Implementado | `IdCardSettingsController`, ruta `/id-card/settings`, vista `Views/IdCardSettings/Index.cshtml` |
| Colores (primario, texto, fondo) | ✅ Implementado | `SchoolIdCardSetting`: PrimaryColor, TextColor, BackgroundColor; guardado desde la vista |
| Dimensiones (ancho/alto en mm) | ✅ Implementado | `SchoolIdCardSetting`: PageWidthMm, PageHeightMm, BleedMm |
| Mostrar/ocultar QR | ✅ Implementado | `SchoolIdCardSetting.ShowQr` (reverso) |
| Mostrar/ocultar foto del estudiante | ✅ Implementado | `SchoolIdCardSetting.ShowPhoto` |
| Plantilla por escuela | ✅ Implementado | `SchoolIdCardSetting.TemplateKey` (ej. `default_v1`) |
| Campos de plantilla (posición/tamaño) | ✅ Implementado | Tabla `id_card_template_fields`: FieldKey (SchoolName, SchoolLogo, Photo, FullName, DocumentId, Grade, Group, Shift, CardNumber, Qr), XMm, YMm, WMm, HMm, FontSize, FontWeight, IsEnabled |

### 1.4 Información institucional

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Nombre de la institución en carnet | ✅ Implementado | `School.Name` en header del PDF y en reverso |
| Logo de la institución en carnet | ✅ Implementado | `School.LogoUrl`; se descarga y se muestra en header del frente |
| Teléfono del colegio en BD | ✅ Implementado | `School.Phone` (tabla `schools`) |
| Estado activo/inactivo de la escuela | ✅ Implementado | `School.IsActive` (soft delete) |

### 1.5 Plataforma web administrativa

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Listado de estudiantes para carnet | ✅ Implementado | `StudentIdCard/ui`, `StudentIdCard/api/list-json` (por SchoolId) |
| Generar carnet (vista previa HTML) | ✅ Implementado | `StudentIdCard/ui/generate/{studentId}`, vista `Generate.cshtml` |
| Descargar PDF del carnet | ✅ Implementado | `StudentIdCard/ui/print/{studentId}` |
| Página de escaneo (web) | ✅ Implementado | `StudentIdCard/ui/scan`, vista `Scan.cshtml` |
| Enlace a configuración desde menú | ✅ Implementado | Menú SuperAdmin/Admin: “Configuración carnet” → `/id-card/settings` |

### 1.6 Aplicación móvil (APK) y APIs

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Login (API) | ✅ Implementado | POST `/api/auth/login` (AuthController.ApiLogin), cliente `scanner`, restricción Inspector/Docente |
| Escanear QR (API) | ✅ Implementado | POST `/StudentIdCard/api/scan` con body `{ token, scanType, scannedBy }`; devuelve allowed, message, studentName, grade, group, studentId, disciplineCount, studentPhotoUrl, schoolName, studentCode |
| Autenticación Bearer para APIs desde APK | ✅ Implementado | Middleware `ApiBearerTokenMiddleware`: valida token base64 (userId:email:timestamp) y establece usuario en contexto |
| Crear reporte disciplinario desde APK | ✅ Implementado | POST `/DisciplineReport/CreateWithFiles` con JWT |
| Obtener historial disciplinario visible | ✅ Implementado | GET `/DisciplineReport/GetVisibleDisciplineInfo?studentId=...` con JWT |

### 1.7 Perfil del estudiante y datos académicos

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Perfil del estudiante (vista web) | ✅ Implementado | `StudentProfileController`, `StudentProfileService`, vista `StudentProfile/Index.cshtml`; datos desde User + StudentAssignment (no hay tabla `student_profiles`) |
| Grado y grupo actual | ✅ Implementado | Vía `StudentAssignment` activo → Grade, Group; usado en carnet y en perfil |
| Jornada (shift) | ✅ Implementado | `User.Shift` y/o `StudentAssignment.Shift`; se muestra en carnet |
| Estado activo/inactivo del usuario | ✅ Implementado | `User.Status` (active/inactive) |

### 1.8 Incidencias disciplinarias

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Modelo y tabla | ✅ Implementado | `DisciplineReport` (StudentId, TeacherId, Date, ReportType, Description, Status, Category, Documents, etc.) |
| Crear reporte con archivos | ✅ Implementado | `DisciplineReportController.CreateWithFiles` (multipart) |
| Consulta visible por rol (director, teacher, parent) | ✅ Implementado | `DisciplineReportController.GetVisibleDisciplineInfo` |
| Conteo de reportes en resultado de escaneo | ✅ Implementado | `ScanResultDto.DisciplineCount`, `StudentIdCardService.ScanAsync` |

### 1.9 Horarios

| Funcionalidad | Estado | Ubicación / detalle |
|---------------|--------|----------------------|
| Horarios de la escuela (bloques) | ✅ Implementado | `TimeSlot`, `SchoolScheduleConfiguration`, `ScheduleEntry` (por TeacherAssignment, TimeSlot, DayOfWeek, AcademicYear) |
| Horario del estudiante (vista) | ✅ Implementado | `StudentScheduleController`: horario del estudiante según sus asignaciones/grupos |

---

## SECCIÓN 2 — Datos que ya existen en la base de datos

| Dato / concepto | Tabla o origen | Campos / notas |
|-----------------|----------------|-----------------|
| Foto del estudiante | `users` | `PhotoUrl` |
| Nombre completo | `users` | `Name`, `LastName` |
| Grado | `grade_levels` + `student_assignments` | Grado actual vía asignación activa |
| Grupo | `groups` + `student_assignments` | Grupo actual vía asignación activa |
| Nombre de la institución | `schools` | `Name` |
| Código QR del estudiante | `student_qr_tokens` | `Token` (GUID usado en el QR) |
| Teléfono del colegio | `schools` | `Phone` |
| Registro disciplinario / historial | `discipline_reports` | Por StudentId, con permisos por rol |
| Estado activo/inactivo (usuario) | `users` | `Status` |
| Estado activo/inactivo (escuela) | `schools` | `IsActive` |
| Número de carnet | `student_id_cards` | `CardNumber`, `Status` (active/revoked) |
| Documento de identidad | `users` | `DocumentId` |
| Teléfonos del usuario (contacto) | `users` | `CellphonePrimary`, `CellphoneSecondary` |
| Acudiente / padre (referencia) | `students` | `ParentId` → `users` (rol parent/acudiente) |
| Jornada | `users.Shift` y/o `student_assignments` + `shifts` | `Shift` (string) o relación con `shifts` |

---

## SECCIÓN 3 — Funcionalidades parcialmente implementadas

| Funcionalidad | Lo que existe | Lo que falta |
|---------------|----------------|--------------|
| Contacto de emergencia | `Student.ParentId` → User (acudiente); `User.CellphonePrimary/CellphoneSecondary` para cualquier usuario | No hay entidad “Contacto de emergencia” (nombre, parentesco, teléfono dedicado); no hay campo “teléfono de emergencia” explícito en carnet ni en configuración |
| Teléfono del colegio | `School.Phone` en BD | No se usa en la configuración del carnet ni se imprime en el PDF del carnet |
| Configuración de “qué mostrar en el carnet” | Lista fija de `IdCardTemplateField.FieldKey` en código (SchoolName, SchoolLogo, Photo, FullName, DocumentId, Grade, Group, Shift, CardNumber, Qr) y opciones globales ShowQr/ShowPhoto | No hay UI para marcar “qué datos visibles” (checklist); no hay configuración específica para el reverso más allá de mostrar/ocultar QR |
| Reverso del carnet | Layout fijo: QR + nombre institución + texto + número de carnet | No hay campos configurables (FieldKey) para el reverso; no se puede elegir qué datos van al dorso |
| Abrir perfil del estudiante mediante QR | El QR contiene solo el token de validación; el escaneo devuelve datos (nombre, grado, grupo, foto, escuela, disciplina) y la APK muestra pantalla de resultado | No hay URL “abrir perfil en web” codificada en el QR; el flujo es “validar y mostrar datos en app”, no “ir al perfil en navegador” |

---

## SECCIÓN 4 — Funcionalidades faltantes

### 4.1 Datos y entidades

| Elemento | Estado | Notas |
|----------|--------|--------|
| Alergias / datos médicos | ❌ No existe | No hay tabla `student_medical_info` ni campos `allergy`/`alergias` en `users` ni en `students`; el análisis previo (ANALISIS_TABLAS_ID_MODULE.md) ya lo señaló |
| Contacto de emergencia (entidad) | ❌ No existe | No hay tabla `emergency_contacts` ni campos dedicados (nombre contacto emergencia, teléfono emergencia) |
| Teléfono de emergencia (campo explícito) | ❌ No existe | Solo teléfonos genéricos en User; no hay “emergency_phone” o “contacto_emergencia” |
| Práctica profesional / empresa / horario laboral | ❌ No existe | No hay entidades ni campos para práctica profesional, empresa ni horario laboral del estudiante |

### 4.2 Configuración y uso en carnet

| Elemento | Estado | Notas |
|----------|--------|--------|
| Configuración “datos visibles en el carnet” | ❌ No existe | No hay pantalla ni modelo para elegir qué campos mostrar (checklist) más allá de ShowQr/ShowPhoto y la plantilla por posiciones |
| Configuración del reverso (campos/editables) | ❌ No existe | Reverso fijo en código; no hay opciones ni campos configurables para el dorso |
| Mostrar teléfono del colegio en el carnet | ❌ No existe | No se lee `School.Phone` ni se imprime en el PDF |
| Mostrar contacto de emergencia en carnet | ❌ No existe | No hay dato ni diseño para ello |
| Mostrar alergias en carnet | ❌ No existe | No hay dato ni diseño para ello |
| Mostrar horario del estudiante en carnet | ❌ No existe | Aunque existe horario en el sistema, no se incluye en el diseño del carnet (ni frente ni reverso) |

### 4.3 Perfil y flujo QR

| Elemento | Estado | Notas |
|----------|--------|--------|
| Enlace “abrir perfil del estudiante” desde QR | ❌ No existe | El QR solo sirve para validación (token); no hay URL de perfil en el payload del QR |

---

## SECCIÓN 5 — Resumen: datos del listado solicitado

| Dato | ¿Existe en el sistema? | ¿Se usa en carnet/APK? |
|------|------------------------|-------------------------|
| Foto del estudiante | ✅ Sí (`users.PhotoUrl`) | ✅ Frente (si ShowPhoto); APK resultado |
| Nombre completo | ✅ Sí (`users.Name`, `LastName`) | ✅ Frente y resultado de escaneo |
| Grado | ✅ Sí (vía `student_assignments` + `grade_levels`) | ✅ Frente y resultado de escaneo |
| Grupo | ✅ Sí (vía `student_assignments` + `groups`) | ✅ Frente y resultado de escaneo |
| Nombre de la institución | ✅ Sí (`schools.Name`) | ✅ Frente y reverso |
| Código QR del estudiante | ✅ Sí (`student_qr_tokens.Token`) | ✅ Frente y/o reverso según configuración |
| Alergias | ❌ No | ❌ |
| Persona de contacto | ⚠️ Parcial (`students.ParentId` + User) | ❌ No en carnet |
| Teléfono de emergencia | ❌ No (solo teléfonos genéricos en User) | ❌ |
| Teléfono del colegio | ✅ Sí (`schools.Phone`) | ❌ No en carnet ni en configuración |
| Horario del estudiante | ✅ Sí (ScheduleEntry, StudentScheduleController) | ❌ No en carnet |
| Registro disciplinario / historial | ✅ Sí (`discipline_reports`, APIs) | ✅ Conteo en resultado de escaneo; APK puede ver historial |
| Estado activo/inactivo | ✅ Sí (`users.Status`, `schools.IsActive`) | ❌ No mostrado en carnet |
| Práctica profesional | ❌ No | ❌ |
| Empresa | ❌ No | ❌ |
| Horario laboral | ❌ No | ❌ |

---

## SECCIÓN 6 — Recomendación de arquitectura para completar el módulo

### 6.1 Prioridad alta (datos y configuración)

1. **Contacto de emergencia y teléfono de emergencia**  
   - Opción A: Campos en `users`: `EmergencyContactName`, `EmergencyContactPhone` (rápido, un contacto por usuario).  
   - Opción B: Tabla `emergency_contacts` (UserId, Name, Phone, Relationship, IsPrimary) si se requieren varios contactos.

2. **Alergias / datos médicos**  
   - Opción A: Campo `users.MedicalInfo` o `users.Allergies` (texto libre).  
   - Opción B: Tabla `student_medical_info` (StudentId, AllergyOrCondition, Notes, IsActive) si se necesita historial o varios ítems.

3. **Teléfono del colegio en carnet**  
   - Sin cambios de BD: leer `School.Phone` en `StudentIdCardPdfService` y añadir un campo en el diseño (frente o reverso) o un `IdCardTemplateField` tipo “SchoolPhone” si se usa plantilla por campos.

### 6.2 Prioridad media (configuración y reverso)

4. **Configuración “datos visibles en el carnet”**  
   - Ampliar `SchoolIdCardSetting` con flags booleanos (ShowDocumentId, ShowGrade, ShowGroup, ShowShift, ShowSchoolPhone, ShowEmergencyContact, ShowAllergies, etc.) o seguir usando `IdCardTemplateField` con FieldKeys bien definidos y una UI que permita activar/desactivar y posicionar.

5. **Reverso configurable**  
   - Definir FieldKeys para el reverso (por ejemplo en `IdCardTemplateField` con `Side = "back"` o convención de nombres) y que el PDF renderice esos campos en la segunda página; opcionalmente permitir “texto libre” o “instrucciones” editables desde configuración.

### 6.3 Prioridad baja u opcional

6. **Abrir perfil desde QR**  
   - El token actual puede seguir usándose para validación. Si se desea “ver perfil en web”, se puede generar una URL con token firmado o de un solo uso (ej. `/StudentProfile/Public/{signedToken}`) y codificarla en el QR además o en lugar del token actual; el escaneo podría abrir esa URL en el navegador.

7. **Práctica profesional / empresa / horario laboral**  
   - Solo si el negocio lo requiere: nuevas tablas o campos (por ejemplo `student_internships` o campos en una tabla de perfil extendido), y luego decidir si se muestran en carnet o solo en perfil.

### 6.4 Resumen de entidades/tablas revisadas

| Entidad / concepto | ¿Existe? | Uso en carnet/APK |
|--------------------|----------|--------------------|
| Student (legacy) | ✅ Tabla `students` | No usado en flujo actual de carnet (se usa User + StudentAssignment) |
| StudentProfile | ❌ No tabla; solo ViewModel + servicio | Perfil web; no en carnet |
| EmergencyContact | ❌ No | — |
| StudentMedicalInfo / alergias | ❌ No | — |
| StudentIncidents | ✅ Como `DisciplineReport` | Conteo y listado en APK |
| StudentSchedule | ✅ ScheduleEntry + StudentScheduleController | No en carnet |
| StudentQR | ✅ Como `StudentQrToken` | Generación y escaneo |
| SchoolIdCardSetting | ✅ | Configuración colores, dimensiones, ShowQr, ShowPhoto |
| IdCardTemplateField | ✅ | Posición/tamaño de campos en frente (lista fija de FieldKey) |

---

**Documento generado a partir del análisis del código y modelos del proyecto SchoolManager. No se ha modificado código.**
