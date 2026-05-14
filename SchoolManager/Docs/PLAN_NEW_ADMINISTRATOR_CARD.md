# Plan de implementación — Credencial institucional del personal (nuevo módulo)

**Nombre de producto / ruta recomendada:** `InstitutionalCredential` → **`/InstitutionalCredential/ui`**.  
**Principio:** no modificar rutas, vistas ni contratos públicos de `StudentIdCard`.  
**Proyecto:** `C:\Proyectos\EduplanerIIC\SchoolManager`.

---

## 1. Objetivos funcionales

1. UI de listado de personal elegible por escuela (y SuperAdmin global).
2. Vista previa HTML por usuario: **`GET /InstitutionalCredential/ui/generate/{staffUserId}`**.
3. Descarga PDF: **`GET /InstitutionalCredential/ui/print/{staffUserId}`** con pipeline HTML→Chromium→QuestPDF y fallback Skia+QuestPDF.
4. API de generación/regeneración de credencial sin pay-gate estudiantil.
5. Campos visibles: nombre, foto, QR, **rol**, **cargo**, **departamento**, código institucional, estado, logo escuela, firma (opcional), orientación vertical/horizontal, watermark configurable.
6. **Cero** dependencia de `StudentPaymentAccesses`, `StudentAssignments` (grado/grupo), y **cero** referencia a `ClubParents` o `/ClubParents/Students`.

---

## 2. Desacople respecto a Club de padres y pagos

- El carnet estudiantil usa **`StudentPaymentAccesses`** (estado `Pagado`). No hay referencias a `ClubParents` en archivos `StudentId*`, pero el negocio de “carnet pagado” puede alimentarse desde otros módulos en la BD.
- **Regla:** el nuevo controlador y servicios de credencial institucional **no importan** namespaces ni servicios de `ClubParents`; la autorización es por **claims de rol** y, si aplica, **asignación a escuela** (`User.SchoolId`).

---

## 3. Fases de implementación sugeridas

### Fase A — Dominio y persistencia

1. Entidad `InstitutionalCredentialCard` (nombre final acorde a convención de BD del proyecto):
   - `Id`, `UserId` (FK staff), `CardNumber`, `IssuedAt`, `ExpiresAt`, `Status`, `IsPrinted`, `PrintedAt`.
2. Tokens QR dedicados: nueva tabla `StaffQrTokens` (análoga a `StudentQrTokens` pero sin mezclar estudiantes) **o** reutilizar patrón de token con `Discriminator` — preferible tabla separada para claridad y migraciones seguras.
3. Migración EF + índices `(UserId, Status)`, `(CardNumber)`.

### Fase B — Configuración visual

1. `SchoolStaffIdCardSetting` (colores, `ShowQr`, `ShowPhoto`, orientación, watermark, flags de campos) **o** flags en misma escuela con sección JSON — evaluar mantenimiento vs `SchoolIdCardSetting` existente (riesgo: mezclar concerns).

### Fase C — Servicios

1. `IInstitutionalCredentialService` — `GetCurrentCardAsync`, `GenerateAsync`, `ScanAsync` (si aplica), consultas con filtro de roles institucionales.
2. `IInstitutionalCredentialPdfService` — construir `StaffCardRenderDto`, cargar bytes, llamar a renderer.
3. **Renderer:**  
   - Opción 1 (rápida): nueva clase `InstitutionalCredentialImageService` copiando patrones de layout desde `StudentIdCardImageService` pero con DTO distinto (controlar deuda técnica).  
   - Opción 2 (limpia): extraer primitivas comunes (`DrawPhotoBox`, `DrawQr`, watermark) a helper interno compartido en ensamblado o carpeta `Services/Cards/Shared/`.

### Fase D — Captura HTML / PDF

1. Introducir interfaz genérica, p. ej. `ICredentialHtmlPdfCaptureService` con método `Task<byte[]> GeneratePdfFromPreviewUrlAsync(string absoluteUrl, CredentialCaptureProfile profile)`.
2. Implementación inicial puede **envolver** lógica actual copiada desde `StudentIdCardHtmlCaptureService` ajustando:
   - selectores CSS compartidos (convención: mismos ids `#idCardFront`, `.idcard-face` en la nueva vista para reutilizar motor), **o**
   - parámetros de selector por perfil.
3. Configuración: reutilizar sección `StudentIdCardPdf` **o** nueva `InstitutionalCredentialPdf` con mismas claves (`Profile`, `DeviceScaleFactor`, …) para no acoplar perfiles distintos en el futuro.

### Fase E — MVC

1. `InstitutionalCredentialController` con `[Route("InstitutionalCredential")]`.
2. Vistas `Views/InstitutionalCredential/Index.cshtml`, `Generate.cshtml` (preview), opcionalmente `Scan.cshtml`.
3. ViewModels y DTOs dedicados.
4. Anti-forgery en POST análogos al estudiantil.

### Fase F — Menú AdminLTE (`_SuperAdminLayout.cshtml`)

**Estructura recomendada** (AdminLTE `nav-item has-treeview`):

```text
Credenciales
 ├── Carnet estudiantil     → /StudentIdCard/ui
 └── Credencial institucional → /InstitutionalCredential/ui

Directorios
 ├── Directorio estudiantil   → /SuperAdmin/StudentDirectory
 └── Directorio de personal   → /SuperAdmin/StaffDirectory
```

- Mantiene coherencia con headers existentes (“GESTIÓN DE USUARIOS” vs nuevo grupo “Credenciales” / “Directorios”).
- Si no se desea treeview, dos `nav-header` consecutivos con items hijos también es válido.

### Fase G — Autorización

1. `[Authorize]` con roles: `SuperAdmin`, `Director`, `Admin`, … según matriz real del sistema.
2. Filtrado por `SchoolId` para roles de escuela; SuperAdmin ve todas.

### Fase H — Pruebas

1. PDF único y (opcional) masivo con límite bajo al inicio.
2. Regresión manual: flujo completo `StudentIdCard` sin cambios de comportamiento.
3. Casos: foto ausente, logo ausente, Chromium ausente (fallback), orientación horizontal.

---

## 4. Lista exacta de archivos (crear / modificar)

### Crear

- `Controllers/InstitutionalCredentialController.cs`
- `Models/InstitutionalCredentialCard.cs` (ajustar nombre si convención plural)
- `Models/StaffQrToken.cs` (si aplica)
- `Services/Interfaces/IInstitutionalCredentialService.cs`
- `Services/Interfaces/IInstitutionalCredentialPdfService.cs`
- `Services/Interfaces/IInstitutionalCredentialImageService.cs`
- `Services/Implementations/InstitutionalCredentialService.cs`
- `Services/Implementations/InstitutionalCredentialPdfService.cs`
- `Services/Implementations/InstitutionalCredentialImageService.cs`
- `ViewModels/InstitutionalCredentialGenerateViewModel.cs` (+ listado si hace falta)
- `Dtos/StaffCardRenderDto.cs`, `InstitutionalCredentialCardDto.cs`
- `Views/InstitutionalCredential/Index.cshtml`
- `Views/InstitutionalCredential/Generate.cshtml`
- `Migrations/xxxx_AddInstitutionalCredential*.cs`
- `Options/InstitutionalCredentialOptions.cs`

### Modificar (mínimo)

- `Program.cs` — registrar servicios y `IOptions`.
- `SchoolDbContext.cs` — `DbSet` + configuración Fluent si aplica.
- `Views/Shared/_SuperAdminLayout.cshtml` — menú.
- `appsettings.json` — nueva sección opcional.

### Refactor opcional (reutilización inteligente)

- Nuevo `Services/Cards/CardHtmlCaptureService.cs` + extracción gradual desde `StudentIdCardHtmlCaptureService` **solo si** se prueba regresión en estudiantil.

---

## 5. Mockup textual resumido (PDF / pantalla)

- **Frente:** banda corporativa + logo + foto + nombre + tres líneas (ROL / CARGO / DEPARTAMENTO) + código + QR.
- **Reverso:** política, contactos de seguridad, QR secundario opcional — sin grado/grupo.
- **Preview:** misma composición con sombra suave y badges de estado (activo/inactivo) **fuera** del área `.idcard-face` para no capturarse en PDF.

---

## 6. Flujo de impresión (resumen)

1. Usuario abre preview autenticado.
2. Servidor valida rol y pertenencia a escuela.
3. `print/{id}` construye URL absoluta del preview, lanza captura o fallback nativo.
4. Marca `IsPrinted` en `InstitutionalCredentialCard`.
5. Cliente descarga blob PDF (mismo patrón `fetch` que `Generate.cshtml` estudiantil).

---

## 7. Riesgos (recordatorio)

- Duplicar HTML capture y olvidar cookies → PDF en blanco (mitigar copiando patrón de `SetCookieAsync`).
- Divergencia HTML vs Skia — documentar “fuente de verdad” o reducir layouts duales.
- Ausencia de datos laborales en `User` — bloquear hasta completar perfil o mostrar “—”.

---

## 8. Criterio de éxito

- Estudiantes: mismas rutas, mismos gates de pago, mismas vistas.
- Personal: nuevo ecosistema completo, fotos desde directorio de personal, sin consultas a pagos estudiantiles.
