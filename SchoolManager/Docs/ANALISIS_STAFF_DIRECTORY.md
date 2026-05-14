# Análisis del directorio de estudiantes (`SuperAdmin/StudentDirectory`) y base para directorio de personal

**Ámbito:** `C:\Proyectos\EduplanerIIC\SchoolManager`.  
**Objetivo:** entender fotos, listados, APIs y datos para replicar un **Directorio de personal** desacoplado, reutilizando servicios donde tenga sentido sin duplicar reglas de negocio.

---

## 1. Superficie funcional actual

### 1.1 Entrada HTTP

| Acción | Ruta / método | Descripción |
|--------|----------------|-------------|
| Listado paginado | `GET /SuperAdmin/StudentDirectory` | `SuperAdminController.StudentDirectory` → vista `Views/SuperAdmin/StudentDirectory.cshtml`. |
| Subir foto | `POST /SuperAdmin/StudentDirectoryUpdatePhoto` | `userId` + `photo` (multipart), anti-forgery, límite 12 MB. |
| Quitar foto | `POST /SuperAdmin/StudentDirectoryRemovePhoto` | Solo limpia `PhotoUrl` vía servicio. |

### 1.2 Restricción explícita de rol (solo estudiantes)

En `SuperAdminController`, ambos endpoints de foto validan:

```132:134:c:\Proyectos\EduplanerIIC\SchoolManager\Controllers\SuperAdminController.cs
        var role = (user.Role ?? "").ToLowerInvariant();
        if (role != "student" && role != "estudiante" && role != "alumno")
            return Json(new { success = false, message = "El usuario no es estudiante." });
```

Por tanto, **no** se puede “reutilizar” estos endpoints tal cual para docentes/administradores: hace falta **nuevas acciones** (p. ej. `StaffDirectoryUpdatePhoto`) o generalizar con validación de lista blanca de roles institucionales y nombres de ruta distintos.

### 1.3 Capa de aplicación

- **`SuperAdminService.GetStudentDirectoryPageAsync`** (`Services/Implementations/SuperAdminService.cs`, región “Directorio de estudiantes”):
  - Filtra asignaciones activas cuyo estudiante tiene rol alumno (`WhereAssignmentStudentRole` / `WhereUserStudentRole`).
  - Opciones de combo: escuela, grado, grupo, jornada (derivadas de `StudentAssignments` activas).
  - Modo “solo sin asignación”: filas huérfanas con grado/grupo nulos.
  - Paginación 1-based, `PageSize` acotado a 100.
  - Proyección a `SuperAdminStudentDirectoryRowVm`: `UserId`, `PhotoUrl`, nombre, documento, email, escuela, grado, grupo, jornada, estado, `HasActiveAssignment`.

### 1.4 ViewModels

- **`ViewModels/SuperAdminStudentDirectoryViewModels.cs`:** `SuperAdminStudentDirectoryFilterVm`, `SuperAdminStudentDirectoryRowVm`, `SuperAdminStudentDirectoryPageVm` con `GetDirectoryQueryForPage` para enlaces GET de paginación.

### 1.5 Vista Razor (`Views/SuperAdmin/StudentDirectory.cshtml`)

- Formulario GET de filtros (escuela, grado, grupo, jornada, búsqueda texto, estado usuario, checkbox sin asignación).
- Tabla con miniatura de foto: helpers tipo `buildUserPhotoThumbHref` / variantes Cloudinary (ver `OPTIMIZACION_SEGURA_CLOUDINARY.md`).
- Modal de gestión de foto:
  - Input archivo, vista previa, “Tomar/Subir”, sincronización.
  - **IndexedDB** para cola offline de fotos (`queuePhotoOffline`, `syncQueuedPhotos`) — UX avanzada para campo / conectividad intermitente.
  - `fetch` POST a `StudentDirectoryUpdatePhoto` con `FormData` (`userId`, `photo`, token).

### 1.6 Persistencia de fotos

- **`IUserPhotoService`** (`Services/Implementations/UserPhotoService.cs`):
  - `UpdatePhotoAsync`: `IFileStorageService.SaveUserPhotoAsync` → `user.UpdatePhoto(newPhotoUrl)` → `SaveChanges` → borra foto anterior con `DeleteUserPhotoAsync`.
  - `RemovePhotoAsync`: anula `PhotoUrl` y borra archivo remoto/local según URL.
- **Modelo `User`:** `PhotoUrl` privado con setter vía `UpdatePhoto` — misma entidad sirve para **cualquier rol**; la separación es de **UI y autorización**, no de almacenamiento.

### 1.7 Integración Cloudinary / archivos

- Implementación concreta en `IFileStorageService` / `LocalFileStorageService` / `CloudinaryService` (según configuración del entorno).
- El directorio de estudiantes **no** contiene lógica Cloudinary inline: delega en almacenamiento.

### 1.8 Relación con credenciales estudiantiles

- El carnet lee `User.PhotoUrl` a través de `GetUserPhotoBytesAsync` / URLs en HTML.
- Cualquier cambio en el directorio de estudiantes **actualiza la misma columna** que consume el carnet — patrón deseable para personal: **directorio maestro de foto → credencial solo lee**.

---

## 2. Qué NO existe hoy para personal

- No hay listado SuperAdmin filtrado por roles `teacher`, `admin`, `director`, etc.
- No hay columnas de **cargo**, **departamento** o **código de empleado** en `SuperAdminStudentDirectoryRowVm` ni en `User` (campos dedicados).
- No hay historial de versiones de foto en BD (solo reemplazo en `UserPhotoService`).

---

## 3. Propuesta de directorio equivalente

### 3.1 Nombre de ruta recomendado

- **`/SuperAdmin/StaffDirectory`** (GET) — paralelo a `StudentDirectory`, intuitivo en inglés institucional.
- Alternativa en español: **`PersonalInstitucional`** si se prefiere UI 100 % local.

### 3.2 Funcionalidad objetivo

| Función | En estudiantes | En personal (propuesto) |
|---------|----------------|---------------------------|
| Listado | Por matrícula / grado / grupo | Por escuela, rol, departamento, estado |
| Foto | Modal + upload + offline queue | Misma UX reutilizable (componente JS parcial o vista compartida) |
| Validación rol | Solo alumno | Lista blanca: admin, director, teacher, coordinator, secretary, security, staff, … |
| Credencial | Enlace a carnet estudiantil | Enlace a `/InstitutionalCredential/ui/generate/{userId}` |
| QR en tabla | No central | Opcional: QR de perfil o deep-link a ficha |

### 3.3 Modelo de datos sugerido (nueva migración)

Opciones (de menor a mayor normalización):

1. **Extender `users`** con `JobTitle`, `Department`, `EmployeeCode` (nullable, solo aplica a staff).
2. **Tabla `staff_profiles`** (`UserId` PK/FK, `JobTitle`, `DepartmentId`, `EmployeeCode`, `HireDate`, …) — preferible si muchos campos o historial futuro.
3. **Historial de fotos** (`user_photo_history`): id, `UserId`, `PhotoUrl`, `ChangedAt`, `ChangedBy` — opcional fase 2.

### 3.4 Servicios reutilizables sin duplicar lógica de archivo

- **`IUserPhotoService`** — núcleo único de actualización de foto.
- **`IFileStorageService`** — única puerta a Cloudinary/disco.
- **Nuevo:** `IStaffDirectoryService` / `SuperAdminService` región nueva con queries por rol, **sin** tocar `GetStudentDirectoryPageAsync`.

### 3.5 Controlador

- Acciones nuevas en `SuperAdminController` **o** `SuperAdminStaffDirectoryController` dedicado (más limpio si el archivo crece).
- Endpoints JSON análogos: `StaffDirectoryUpdatePhoto`, `StaffDirectoryRemovePhoto` con validación **invertida** a estudiantes (debe ser personal institucional).

---

## 4. Integración con credencial institucional

- El módulo de credencial (`InstitutionalCredential`) debe resolver foto con la misma cadena que el carnet: `PhotoUrl` + `GetUserPhotoBytesAsync`.
- La **generación** de la credencial no sube fotos; si falta foto, UI muestra placeholder premium y bloqueo suave según política.

---

## 5. Dependencias y tablas

| Tabla / entidad | Uso en directorio estudiantes |
|-----------------|------------------------------|
| `users` | Foto, nombre, email, documento, rol, escuela, estado |
| `student_assignments` | Filtros grado/grupo/jornada |
| `schools` | Nombre de escuela |
| `grades`, `groups`, `shifts` | Combos |

Para personal: principalmente **`users`** + **`schools`**; si se añaden departamentos, tabla **`departments`** o texto libre según complejidad.

---

## 6. Riesgos

1. Generalizar `StudentDirectoryUpdatePhoto` sin romper la regla “solo estudiantes” — mejor endpoints nuevos.
2. IndexedDB en vista: duplicar script en dos vistas puede divergir; extraer **`_PhotoManagerModal.cshtml`** + JS parcial común.
3. Roles inconsistentes (`Teacher` vs `teacher`) — centralizar con helper de normalización de rol.

---

## 7. Referencias de código

Servicio de directorio (inicio de la región):

```949:968:c:\Proyectos\EduplanerIIC\SchoolManager\Services\Implementations\SuperAdminService.cs
    public async Task<SuperAdminStudentDirectoryPageVm> GetStudentDirectoryPageAsync(SuperAdminStudentDirectoryFilterVm filter)
    {
        filter ??= new SuperAdminStudentDirectoryFilterVm();
        if (filter.Page < 1)
            filter.Page = 1;
        filter.PageSize = Math.Clamp(filter.PageSize <= 0 ? 25 : filter.PageSize, 1, 100);

        var page = new SuperAdminStudentDirectoryPageVm { Filter = filter };

        var optionsBase = WhereAssignmentStudentRole(
            _context.StudentAssignments.AsNoTracking().Where(sa => sa.IsActive));
```

Actualización de foto (dominio):

```26:41:c:\Proyectos\EduplanerIIC\SchoolManager\Services\Implementations\UserPhotoService.cs
    public async Task UpdatePhotoAsync(Guid userId, IFormFile file)
    {
        var user = await _context.Users.FindAsync(userId);
        // ...
        var newPhotoUrl = await _fileStorage.SaveUserPhotoAsync(file, userId);
        user.UpdatePhoto(newPhotoUrl);
        user.UpdatedAt = DateTime.UtcNow;
        _context.Users.Update(user);
        await _context.SaveChangesAsync();
```

---

## 8. Entregables relacionados

- Plan de implementación: **`PLAN_STAFF_DIRECTORY.md`**.
- Carnet institucional: **`ANALISIS_ADMINISTRATOR_IDCARD.md`**, **`PLAN_NEW_ADMINISTRATOR_CARD.md`**.
