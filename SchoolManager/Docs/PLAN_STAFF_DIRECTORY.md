# Plan de implementación — Directorio de personal (SuperAdmin)

**Ruta objetivo recomendada:** `GET /SuperAdmin/StaffDirectory`  
**Proyecto:** `C:\Proyectos\EduplanerIIC\SchoolManager`  
**Dependencia clave:** reutilizar **`IUserPhotoService`** e **`IFileStorageService`** (sin duplicar lógica de Cloudinary/disco).

---

## 1. Alcance

1. Listado paginado de usuarios **no estudiantes** con cuenta en el sistema (roles institucionales).
2. Filtros: escuela, rol, estado (activo/inactivo), texto libre (nombre, email, documento), opcional departamento cuando exista en modelo.
3. Gestión de foto: misma UX que `StudentDirectory` (modal, upload, eliminar, cola IndexedDB opcional).
4. Accesos rápidos: “Ver credencial” → `/InstitutionalCredential/ui/generate/{userId}` (cuando el módulo de credencial exista).
5. **No** reutilizar `StudentDirectoryUpdatePhoto` porque rechaza roles no alumno.

---

## 2. Diseño de API HTTP

| Método | Ruta propuesta | Body | Respuesta |
|--------|----------------|------|-----------|
| GET | `/SuperAdmin/StaffDirectory` | Query: `Search`, `SchoolId`, `Role`, `UserStatus`, `Page`, `PageSize` | Vista Razor |
| POST | `/SuperAdmin/StaffDirectoryUpdatePhoto` | `userId`, `photo` + antiforgery | JSON `{ success, photoUrl }` |
| POST | `/SuperAdmin/StaffDirectoryRemovePhoto` | `userId` + antiforgery | JSON `{ success }` |

**Validación de rol en servidor:**

- Lista blanca de strings normalizados (`admin`, `director`, `teacher`, `coordinator`, `secretary`, `counselor`, `security`, `staff`, … — alineada con valores reales en BD del proyecto).
- Rechazar explícitamente `student` / `estudiante` / `alumno`.

---

## 3. Capa de datos y consultas

### 3.1 Query base (conceptual)

```sql
-- Pseudocódigo
SELECT u.*
FROM users u
WHERE lower(u.role) NOT IN ('student','estudiante','alumno')
  AND ( :schoolId IS NULL OR u.school_id = :schoolId )
  AND ( :roleFilter IS NULL OR lower(u.role) = :roleFilter )
```

### 3.2 Proyección a ViewModel

Campos mínimos del listado:

- `UserId`, `FullName`, `DocumentId`, `Email`, `PhotoUrl`, `SchoolId`, `SchoolName`, `Role`, `Status`
- Placeholders hasta migración: `JobTitle`, `Department` como `string?` nullables.

### 3.3 Paginación

- Reutilizar patrón de `SuperAdminStudentDirectoryPageVm`: `DisplayFrom`, `DisplayTo`, `GetDirectoryQueryForPage`.

---

## 4. Archivos a crear

- `ViewModels/SuperAdminStaffDirectoryViewModels.cs`  
  (`FilterVm`, `RowVm`, `PageVm`)
- `Views/SuperAdmin/StaffDirectory.cshtml`  
  (puede partir copiando estructura de `StudentDirectory.cshtml` y eliminando columnas grado/grupo/jornada; añadir columna Rol y Cargo/Depto cuando existan datos)
- Métodos en `Services/Interfaces/ISuperAdminService.cs` + implementación en `SuperAdminService.cs`:  
  `GetStaffDirectoryPageAsync`
- Acciones en `SuperAdminController.cs` **o** nuevo `SuperAdminStaffDirectoryController.cs`

---

## 5. Archivos a modificar

- `Controllers/SuperAdminController.cs` (si se mantienen acciones ahí)
- `Services/Interfaces/ISuperAdminService.cs`
- `Services/Implementations/SuperAdminService.cs`
- `Views/Shared/_SuperAdminLayout.cshtml` — enlace bajo grupo “Directorios”
- (Opcional) Extraer parcial `Views/Shared/_UserPhotoManagerModal.cshtml` + JS compartido entre directorios

---

## 6. Historial de fotografías (fase opcional)

**Fase 1 (MVP):** solo última foto en `users.photo_url` (igual que hoy).

**Fase 2:** tabla `user_photo_audit` con metadatos; `UserPhotoService` inserta fila antes de reemplazar.

---

## 7. Integración con credencial institucional

1. El directorio solo garantiza **calidad y existencia** de la foto institucional.
2. La credencial **nunca** sube archivos; solo consume `PhotoUrl`.
3. Mensajes UX: “Actualice la foto desde el Directorio de personal” si la política exige foto obligatoria.

---

## 8. Orden de trabajo recomendado

1. ViewModels + servicio de consulta + vista mínima (sin modal foto).
2. Endpoints de foto reutilizando `IUserPhotoService`.
3. Portar UX IndexedDB desde `StudentDirectory.cshtml` solo si es requisito inmediato; si no, upload online únicamente en MVP.
4. Enlace a credencial cuando `InstitutionalCredential` esté disponible (flag de configuración o comprobación de ruta).

---

## 9. Pruebas

- Subir foto a docente y verificar que `User.PhotoUrl` actualiza y que credencial preview muestra la misma imagen.
- Intentar `StaffDirectoryUpdatePhoto` con `userId` de estudiante → debe fallar con 400 JSON claro.
- SuperAdmin sin `SchoolId` sigue pudiendo listar todo con filtro opcional (mismo patrón que estudiantes).

---

## 10. Riesgos

- Roles heterogéneos en BD: normalizar con tabla `role_definitions` futura o enum en código documentado.
- Duplicación de ~600 líneas de JS del modal: extraer a `wwwroot/js/staff-photo-directory.js` compartido.
