# Verificación completa del módulo de carnet digital

**Fecha:** 2026-03-15  
**Objetivo:** Validar que todo sigue funcionando tras la extensión (alergias, contacto de emergencia, teléfono colegio, configuración de datos visibles).

---

## 1. Generación de carnet

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| **GenerateAsync** sin cambios de lógica | OK | `StudentIdCardService.GenerateAsync` (líneas 25-114): misma secuencia: validar estudiante y asignación activa → revocar carnet anterior → revocar tokens anteriores → generar CardNumber → crear `StudentIdCard` y `StudentQrToken` → SaveChanges → devolver `StudentIdCardDto`. No se tocaron condiciones ni flujo. |
| Salida **StudentIdCardDto** | OK | Sigue devolviendo: StudentId, CardNumber, FullName, Grade, Group, Shift, QrToken, PhotoUrl. Sin campos nuevos en el DTO de generación (solo en ScanResultDto y en el DTO interno de PDF). |
| Controlador **GenerateView** y **GenerateApi** | OK | Siguen llamando a `_service.GenerateAsync(studentId, userId)` y devolviendo el mismo DTO/vista. |

**Conclusión:** La generación de carnet no se rompió; `GenerateAsync` permanece intacto en su lógica core.

---

## 2. Revocación de carnet anterior

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| Carnet activo previo | OK | Líneas 51-60: `existingCard.Status = "revoked"` y `Update(existingCard)` sin cambios. |
| Tokens QR previos | OK | Líneas 63-71: búsqueda de tokens no revocados y con `ExpiresAt` válido; `IsRevoked = true` y `UpdateRange(existingTokens)`. |

**Conclusión:** La revocación de carnet y de tokens anteriores se mantiene igual.

---

## 3. Generación de QR token

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| **StudentQrToken** (modelo) | OK | `Models/StudentQrToken.cs`: Id, StudentId, Token, ExpiresAt, IsRevoked, Student. Sin modificaciones. |
| Creación del token en **GenerateAsync** | OK | Líneas 84-92: `new StudentQrToken { StudentId, Token = Guid.NewGuid().ToString(), ExpiresAt = DateTime.UtcNow.AddHours(12) }`; se añade con `_context.StudentQrTokens.Add(newToken)`. Sin cambios. |
| Uso en **StudentIdCardPdfService** | OK | El PDF sigue usando el token existente (o lo crea en `BuildStudentCardDtoAsync` si no hay carnet/token); no se altera la lógica de generación ni almacenamiento del token. |

**Conclusión:** La lógica de `StudentQrToken` no fue modificada; la generación del token sigue en `GenerateAsync` únicamente.

---

## 4. Escaneo de QR

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| **ScanApi** (controller) | OK | `StudentIdCardController.ScanApi`: `[AllowAnonymous]`, POST `api/scan`, valida `dto.Token`, llama `_service.ScanAsync(dto)`, devuelve `Ok(result)`. Sin cambios. |
| **ScanAsync** – búsqueda del token | OK | Misma query: `StudentQrTokens` con Include(Student + Assignments + SchoolNavigation), filtro por `Token == request.Token && !IsRevoked && (ExpiresAt == null \|\| ExpiresAt > UtcNow)`. |
| **ScanAsync** – respuestas denied | OK | Token inválido → ScanLog(Result=denied) + ScanResultDto(Allowed=false). Sin asignación activa → mismo patrón. Sin cambios. |
| **ScanAsync** – respuesta allowed | OK | ScanLog(Result=allowed) + conteo DisciplineCount + **nuevo:** consulta rol de `ScannedBy` y `canSeeSensitiveData`; se rellenan EmergencyContactName, EmergencyContactPhone, Allergies solo si el rol lo permite. El resto de campos (Allowed, Message, StudentName, Grade, Group, StudentId, DisciplineCount, StudentPhotoUrl, SchoolName, StudentCode) sin cambios. |

**Conclusión:** El escaneo de QR funciona igual; solo se añadió la consulta de rol y el rellenado condicional de tres campos sensibles en el DTO.

---

## 5. Registro en scan_logs

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| Modelo **ScanLog** | OK | `Models/ScanLog.cs`: Id, StudentId, ScanType, Result, ScannedBy, ScannedAt. Sin modificaciones. |
| Inserción en **ScanAsync** | OK | Tres puntos: (1) token inválido → `ScanLog { StudentId=null, ScanType, Result="denied", ScannedBy }`; (2) sin asignación → `ScanLog { StudentId, ScanType, Result="denied", ScannedBy }`; (3) acceso permitido → `ScanLog { StudentId, ScanType, Result="allowed", ScannedBy }`. Todos con `_context.ScanLogs.Add` y `SaveChangesAsync`. Sin cambios. |

**Conclusión:** `scan_logs` no se alteró; se sigue registrando igual en los tres casos (denied por token, denied por asignación, allowed).

---

## 6. Descarga de PDF

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| **Print** (controller) | OK | `StudentIdCardController.Print`: obtiene userId, llama `_pdfService.GenerateCardPdfAsync(studentId, userId)`, devuelve `File(pdf, "application/pdf", $"carnet-{studentId}.pdf")`. Sin cambios. |
| **GenerateCardPdfAsync** | OK | Misma secuencia: escuela, settings, campos opcionales, `BuildStudentCardDtoAsync`, logo/foto, Document.Create. Se añadió solo el paso de `school.Phone` a `RenderCarnetQrBack`. Frente y primera página sin cambios; segunda página (reverso) extendida con bloques condicionales. |

**Conclusión:** La descarga de PDF sigue operativa; el reverso se extendió sin romper el flujo.

---

## 7. Renderizado del reverso (teléfono colegio, contacto emergencia, alergias)

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| **RenderCarnetQrBack** | OK | Firma: `(container, schoolName, schoolPhone, dto, settings)`. Contenido fijo: QR, nombre institución, texto “Escanea…”, “Carnet: {CardNumber}`. |
| Teléfono colegio | OK | `if (settings.ShowSchoolPhone && !string.IsNullOrWhiteSpace(schoolPhone))` → línea “Tel. colegio: {schoolPhone}”. |
| Contacto emergencia | OK | `if (settings.ShowEmergencyContact && (EmergencyContactName \|\| EmergencyContactPhone))` → “Contacto emergencia: …” y, si hay teléfono, “Tel: …”. |
| Alergias | OK | `if (settings.ShowAllergies && !string.IsNullOrWhiteSpace(dto.Allergies))` → “Alergias: {dto.Allergies}”. |
| **BuildStudentCardDtoAsync** | OK | Asigna `Allergies`, `EmergencyContactName`, `EmergencyContactPhone`, `EmergencyRelationship` desde `User` al `StudentCardRenderDto`. |
| Invocación desde **GenerateCardPdfAsync** | OK | `RenderCarnetQrBack(c, school.Name, school.Phone, dto, settings)`. |

**Conclusión:** El reverso muestra de forma condicional teléfono del colegio, contacto de emergencia y alergias según settings y datos disponibles; el layout base (QR, institución, carnet) no se alteró.

---

## 8. Validación por rol en ScanAsync

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| Obtención del rol del escáner | OK | `scannedByUser = await _context.Users.Where(u => u.Id == request.ScannedBy).Select(u => u.Role).FirstOrDefaultAsync()`. |
| Condición de datos sensibles | OK | `canSeeSensitiveData = role is "inspector" or "teacher" or "docente" or "admin" or "superadmin"`. |
| Asignación en **ScanResultDto** | OK | `EmergencyContactName = canSeeSensitiveData ? token.Student.EmergencyContactName : null`, e igual para `EmergencyContactPhone` y `Allergies`. |

**Conclusión:** Solo usuarios con rol inspector, teacher, docente, admin o superadmin reciben en la respuesta los campos sensibles; el resto recibe null.

---

## 9. Visualización del perfil del estudiante

| Verificación | Estado | Evidencia en código |
|--------------|--------|---------------------|
| **StudentProfileController.Index** | OK | Obtiene perfil con `GetStudentProfileAsync`; calcula `ShowEmergencyInfo` según rol actual (inspector, teacher, docente, admin, superadmin); asigna `profile.ShowEmergencyInfo`. |
| **StudentProfileService** | OK | Incluye en la proyección y en el ViewModel: EmergencyContactName, EmergencyContactPhone, EmergencyRelationship, Allergies. |
| **StudentProfile/Index.cshtml** | OK | Sección “Información de emergencia” (contacto, teléfono, relación, alergias) dentro de `@if (Model.ShowEmergencyInfo)`. |

**Conclusión:** La sección de emergencia solo se muestra cuando el usuario actual tiene uno de los roles permitidos; el perfil del estudiante sigue cargando y mostrándose correctamente.

---

## Confirmaciones solicitadas

| Afirmación | Verificación |
|------------|--------------|
| **No se rompió GenerateAsync** | Confirmado. La firma, la secuencia (validación → revocación carnet → revocación tokens → nuevo carnet + nuevo token → SaveChanges → return DTO) y el contenido del `StudentIdCardDto` devuelto no cambiaron. |
| **No se modificó la lógica de StudentQrToken** | Confirmado. El modelo `StudentQrToken` no se tocó. La creación del token sigue solo en `GenerateAsync` (mismo formato Guid, mismo ExpiresAt). La revocación sigue con `IsRevoked = true`. El PDF y el escaneo solo leen el token existente. |
| **No se alteró scan_logs** | Confirmado. El modelo `ScanLog` no cambió. Las inserciones en `ScanAsync` (tres puntos: token inválido, sin asignación, allowed) siguen igual en estructura y momento. |

---

## Compilación

```
dotnet build -c Release --no-incremental
→ Build succeeded. 0 Warning(s). 0 Error(s).
```

---

## Resumen

- **Generación de carnet, revocación, QR token, escaneo, scan_logs y descarga PDF:** sin cambios de comportamiento que rompan el flujo; solo extensiones (reverso con datos opcionales, campos sensibles en ScanResultDto según rol).
- **Reverso del PDF:** renderizado condicional de teléfono colegio, contacto de emergencia y alergias correcto.
- **Validación por rol en ScanAsync:** implementada y limitada a inspector, teacher, docente, admin, superadmin.
- **Perfil del estudiante:** sección de emergencia condicionada a `ShowEmergencyInfo` (roles permitidos).

**GenerateAsync, StudentQrToken y scan_logs permanecen sin alteraciones en su lógica esencial.**
