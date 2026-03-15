# Reporte: Extensión del módulo de carnet digital

**Fecha:** 2026-03-15  
**Alcance:** Soporte para alergias, contacto de emergencia, teléfono del colegio y configuración de datos visibles en el carnet. Sin nuevo módulo; sin cambios en lógica de QR ni en `GenerateAsync`.

---

## 1. Archivos modificados

| Archivo | Cambios |
|---------|--------|
| `Models/User.cs` | Añadidos: `Allergies`, `EmergencyContactName`, `EmergencyContactPhone`, `EmergencyRelationship` (todos opcionales). |
| `Models/SchoolIdCardSetting.cs` | Añadidos: `ShowSchoolPhone` (default true), `ShowEmergencyContact` (false), `ShowAllergies` (false). |
| `Models/SchoolDbContext.cs` | Configuración EF para las nuevas columnas de `User` y de `SchoolIdCardSetting`. |
| `Controllers/IdCardSettingsController.cs` | Persistencia de `ShowSchoolPhone`, `ShowEmergencyContact`, `ShowAllergies` en Save; valores por defecto en Index. |
| `Views/IdCardSettings/Index.cshtml` | Tres checkboxes: "Mostrar teléfono del colegio", "Mostrar contacto de emergencia", "Mostrar alergias". |
| `Services/Implementations/StudentIdCardPdfService.cs` | `RenderCarnetQrBack`: parámetro `schoolPhone`; render condicional de tel. colegio, contacto emergencia y alergias. `StudentCardRenderDto` y `BuildStudentCardDtoAsync`: nuevos campos y llenado desde `User`. |
| `Dtos/ScanResultDto.cs` | Añadidos: `EmergencyContactName`, `EmergencyContactPhone`, `Allergies`. |
| `Services/Implementations/StudentIdCardService.cs` | En `ScanAsync`: si el usuario que escanea (ScannedBy) tiene rol inspector/teacher/docente/admin/superadmin, se rellenan los tres campos sensibles; si no, se devuelven null. |
| `ViewModels/StudentProfileViewModel.cs` | Añadidos: `EmergencyContactName`, `EmergencyContactPhone`, `EmergencyRelationship`, `Allergies`, `ShowEmergencyInfo`. |
| `Services/Implementations/StudentProfileService.cs` | Inclusión de los campos de emergencia/alergias en la proyección y en el ViewModel. |
| `Controllers/StudentProfileController.cs` | Cálculo de `ShowEmergencyInfo` según rol actual (inspector, teacher, docente, admin, superadmin) y asignación a `profile.ShowEmergencyInfo`. |
| `Views/StudentProfile/Index.cshtml` | Sección "Información de emergencia" (contacto, teléfono, relación, alergias) visible solo cuando `Model.ShowEmergencyInfo` es true. |

---

## 2. Migraciones creadas

| Migración | Descripción |
|-----------|-------------|
| `20260315223827_ExtendIdCardUserAndSettings` | **users:** `allergies` (varchar 500), `emergency_contact_name` (varchar 200), `emergency_contact_phone` (varchar 30), `emergency_relationship` (varchar 50). **school_id_card_settings:** `show_school_phone` (bool, default true), `show_emergency_contact` (bool, default false), `show_allergies` (bool, default false). |

Aplicar en entorno local/Render:

```bash
dotnet ef database update --context SchoolDbContext
```

---

## 3. Nuevos campos agregados

### Tabla `users`

| Columna | Tipo | Nullable | Uso |
|---------|------|----------|-----|
| `allergies` | character varying(500) | Sí | Alergias o información médica. |
| `emergency_contact_name` | character varying(200) | Sí | Nombre del contacto de emergencia. |
| `emergency_contact_phone` | character varying(30) | Sí | Teléfono del contacto de emergencia. |
| `emergency_relationship` | character varying(50) | Sí | Relación (ej. Padre, Acudiente). |

### Tabla `school_id_card_settings`

| Columna | Tipo | Default | Uso |
|---------|------|---------|-----|
| `show_school_phone` | boolean | true | Mostrar teléfono del colegio en el reverso. |
| `show_emergency_contact` | boolean | false | Mostrar contacto de emergencia en el reverso. |
| `show_allergies` | boolean | false | Mostrar alergias en el reverso. |

---

## 4. Ejemplo del carnet con los nuevos datos

**Reverso del carnet (layout existente + opcionales):**

- QR (centrado).
- Nombre de la institución.
- Texto: "Escanea el código QR para verificar la información del carnet".
- Carnet: `{CardNumber}`.

Si **ShowSchoolPhone** y el colegio tiene teléfono:

- `Tel. colegio: {School.Phone}`

Si **ShowEmergencyContact** y el estudiante tiene datos:

- `Contacto emergencia: {EmergencyContactName}`
- `Tel: {EmergencyContactPhone}`

Si **ShowAllergies** y el estudiante tiene alergias:

- `Alergias: {Allergies}`

Solo se añaden líneas cuando el dato no está vacío. El orden y el estilo (tamaño de fuente, color) se mantienen; no se modifica la lógica del QR ni del número de carnet.

---

## 5. Validación de QR scan (seguridad por rol)

- **ScanResultDto** incluye `EmergencyContactName`, `EmergencyContactPhone`, `Allergies`.
- En **StudentIdCardService.ScanAsync**, tras resolver el token y el estudiante, se obtiene el rol del usuario que escanea (`request.ScannedBy`).
- Si el rol es **inspector**, **teacher**, **docente**, **admin** o **superadmin**, se rellenan esos tres campos desde el `User` del estudiante.
- En caso contrario, se devuelven **null** (la APK no recibe datos sensibles).

Con esto se cumple: *"Las alergias y contacto de emergencia solo deben verse si role = inspector, teacher, admin"* (incluyendo docente y superadmin para consistencia).

---

## 6. Verificaciones (Fase 8)

| Verificación | Estado |
|--------------|--------|
| Generación de carnet | Sin cambios en `GenerateAsync`; solo se extiende el DTO de render y el reverso del PDF. |
| Descarga PDF | Reverso extendido con datos opcionales; frente y QR intactos. |
| QR token | Sin cambios en `StudentQrToken`, generación ni revocación. |
| Escaneo QR | `ScanApi` y `ScanAsync` sin cambio de contrato de validación; solo se añade lógica de rol y nuevos campos en la respuesta. |
| APK login | No modificado. |
| Disciplina | No modificado. |
| Perfil estudiante | Solo se añade sección condicional; edición de perfil no toca los campos de emergencia/alergias (se gestionan por admin en User). La vista `StudentProfile/Index` está autorizada solo para rol student/estudiante, por tanto la sección "Información de emergencia" no se verá allí hasta que exista una ruta donde inspector/teacher/admin visualice el perfil de un estudiante (p. ej. ficha de usuario). |

**Compilación:** `dotnet build -c Release` correcta.

---

## 7. Resumen de entregables

1. **Archivos modificados:** listados en la sección 1.  
2. **Migraciones:** `ExtendIdCardUserAndSettings` (sección 2).  
3. **Nuevos campos:** sección 3.  
4. **Ejemplo de carnet:** sección 4.  
5. **Validación QR scan por rol:** sección 5.  

No se ha creado un módulo nuevo; no se ha modificado la lógica existente de `StudentQrToken`, `scan_logs` ni `StudentIdCardService.GenerateAsync`.
