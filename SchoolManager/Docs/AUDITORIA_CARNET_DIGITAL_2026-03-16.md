# Auditoría y corrección del módulo de carnet digital

**Fecha:** 2026-03-16  
**Objetivo:** Resolver tres problemas reportados: (1) política del colegio única por escuela, (2) configuración del carnet que no afectaba al PDF, (3) códigos QR no visibles en el PDF.

---

## 1. Archivos modificados

| Archivo | Cambios |
|---------|---------|
| **Models/School.cs** | Añadida propiedad `string? IdCardPolicy` (política del carnet, única por escuela). |
| **Models/SchoolDbContext.cs** | Configuración de la propiedad `IdCardPolicy` en la entidad `School` (columna `id_card_policy`, tipo `text`). |
| **Migrations/20260316020619_AddSchoolIdCardPolicy.cs** | Migración EF: `Up` agrega columna `id_card_policy` a `schools`; `Down` la elimina. |
| **Migrations/SchoolDbContextModelSnapshot.cs** | Añadida propiedad `IdCardPolicy` al snapshot de la entidad `School`. |
| **Controllers/IdCardSettingsController.cs** | En `Index`: se asigna `ViewBag.IdCardPolicy = school.IdCardPolicy ?? ""`. En `Save`: se lee `Request.Form["IdCardPolicy"]` y se actualiza `schoolEntity.IdCardPolicy` antes de guardar la configuración del carnet. |
| **Views/IdCardSettings/Index.cshtml** | Nueva sección "Política del carnet" con `<textarea name="IdCardPolicy">` que muestra y envía el texto de política. |
| **Services/Implementations/StudentIdCardPdfService.cs** | (1) Carga de settings con `.IgnoreQueryFilters()` y objeto por defecto con todos los `Show*` definidos. (2) Nuevo parámetro `idCardPolicy` en `RenderCarnetQrBack` y bloque que muestra la política debajo del QR si no está vacía. (3) Método `SafeGenerateQrPng(token)` para generar el QR con try/catch. (4) Uso de `SafeGenerateQrPng` en frente, reverso y en `RenderField` (caso "Qr"); comprobación de `settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken)` antes de renderizar el QR. |
| **Scripts/ApplySchoolIdCardPolicy.sql** | Script idempotente para agregar la columna `id_card_policy` a `schools` (por si se aplica el cambio a mano en lugar de la migración). |

**No se modificaron:** `StudentQrToken`, `scan_logs`, `GenerateAsync` (tal como se indicó).

---

## 2. Migraciones creadas

- **Nombre:** `20260316020619_AddSchoolIdCardPolicy`
- **Acción:** Agrega la columna `id_card_policy` (tipo `text`, nullable) a la tabla `schools`.
- **Aplicación:**  
  - Con EF: `dotnet ef database update` (o el proceso de despliegue que aplique migraciones).  
  - Manual (local/Render): ejecutar `Scripts/ApplySchoolIdCardPolicy.sql` con `psql` o el cliente que uses.

---

## 3. Corrección del QR (FASE 3)

**Problema:** Los códigos QR no se mostraban en el PDF.

**Cambios realizados:**

1. **Comprobación de token y opción ShowQr**  
   Antes de generar o dibujar el QR se comprueba:
   - `settings.ShowQr == true`
   - `!string.IsNullOrWhiteSpace(dto.QrToken)`

2. **Método `SafeGenerateQrPng(string token)`**  
   - Llama a `QrHelper.GenerateQrPng(token, _qrSignatureService)` dentro de un try/catch.  
   - Si hay excepción, se registra en log y se devuelve `null`.  
   - Evita que un fallo en la generación del QR rompa todo el PDF.

3. **Uso consistente del QR**  
   - **Frente (layout CarnetQR):** se usa `SafeGenerateQrPng(dto.QrToken)` y solo se dibuja la imagen si los bytes son válidos.  
   - **Reverso:** mismo patrón (generar bytes con `SafeGenerateQrPng` y dibujar solo si hay bytes).  
   - **Plantilla con campos (RenderField, caso "Qr"):** también se usa `SafeGenerateQrPng` y se comprueba token y `ShowQr` antes de llamar.

Con esto, el QR se renderiza siempre que `ShowQr` esté activo y exista un token válido, y los errores de generación no tiran el PDF.

---

## 4. Corrección de la configuración (FASE 2)

**Problema:** Los cambios en `/id-card/settings` no se reflejaban al imprimir el carnet.

**Cambios realizados:**

1. **Carga explícita de settings por escuela**  
   Se mantiene la carga por `SchoolId`:
   ```csharp
   var settings = await _context.Set<SchoolIdCardSetting>()
       .AsNoTracking()
       .IgnoreQueryFilters()
       .FirstOrDefaultAsync(x => x.SchoolId == school.Id);
   ```
   - `.IgnoreQueryFilters()` evita que un filtro global (p. ej. sobre `School`) impida encontrar el `SchoolIdCardSetting` cuando la escuela está inactiva o hay filtros por defecto.

2. **Objeto por defecto completo**  
   Cuando no existe fila en `school_id_card_settings`, el objeto por defecto ahora define todos los flags usados en el PDF:
   - `ShowQr`, `ShowPhoto`, `ShowSchoolPhone`, `ShowEmergencyContact`, `ShowAllergies`
   así no se usan valores implícitos de C# que pudieran no coincidir con lo guardado en la UI.

3. **Uso de `settings` en el PDF**  
   El mismo objeto `settings` cargado arriba se pasa a:
   - `RenderCarnetQrFront`
   - `RenderCarnetQrBack`
   - `RenderField` (plantillas personalizadas)  
   de modo que `ShowQr`, `ShowPhoto`, `ShowSchoolPhone`, `ShowEmergencyContact` y `ShowAllergies` se respetan en todo el documento.

Con esto, la configuración guardada en IdCardSettings se aplica correctamente al generar el PDF.

---

## 5. Implementación de la política del carnet (FASE 1)

**Requisito:** Una política del colegio única para todos los estudiantes, mostrada en el reverso del carnet.

**Implementación:**

1. **Modelo y base de datos**  
   - En `School` se añade `string? IdCardPolicy`.  
   - Columna `schools.id_card_policy` (text, nullable).  
   - Una sola política por escuela (la entidad es `School`).

2. **Configuración en la UI**  
   - En **IdCardSettings/Index** se añade la sección "Política del carnet" con un `<textarea name="IdCardPolicy">`.  
   - El valor mostrado viene de `ViewBag.IdCardPolicy` (rellenado en el controlador desde `school.IdCardPolicy`).  
   - Al guardar el formulario, en **IdCardSettingsController.Save** se lee `Request.Form["IdCardPolicy"]` y se actualiza `schoolEntity.IdCardPolicy`; luego se hace `SaveChangesAsync` (junto con el guardado de `SchoolIdCardSetting`).

3. **PDF (reverso)**  
   - `GenerateCardPdfAsync` obtiene la escuela (con `IdCardPolicy`) y llama a `RenderCarnetQrBack(..., school.IdCardPolicy, ...)`.  
   - En `RenderCarnetQrBack`, si `idCardPolicy` no es null ni blanco, se añade un bloque de texto debajo del QR con la política (fuente pequeña, centrada, color de texto según settings).

La política queda así: una sola por escuela, configurable en `/id-card/settings`, y visible en el reverso del carnet debajo del QR.

---

## 6. Pruebas funcionales recomendadas (FASE 4)

1. Ir a `http://localhost:5172/id-card/settings?schoolId=<guid-de-la-escuela>`.
2. Cambiar colores, dimensiones y opciones (Mostrar QR, foto, teléfono, contacto de emergencia, alergias).
3. Escribir un texto en "Política del carnet" y guardar.
4. Ir a la pantalla de carnets, generar/descargar el PDF de un estudiante.
5. Comprobar en el PDF:
   - El código QR se ve en frente y/o reverso según la opción.
   - La configuración (qué se muestra u oculta) coincide con lo guardado.
   - La política del colegio aparece en el reverso, debajo del QR, cuando está configurada.

---

## 7. Resumen

| Fase | Descripción | Estado |
|------|-------------|--------|
| **FASE 1** | Política del colegio en `School`, UI en IdCardSettings y reverso del PDF | Hecho |
| **FASE 2** | Configuración del carnet cargada y aplicada correctamente en el PDF | Hecho |
| **FASE 3** | QR generado de forma segura y mostrado cuando `ShowQr` y token válido | Hecho |
| **FASE 4** | Pruebas funcionales | Pendiente (ejecutar según sección 6) |
| **FASE 5** | Reporte | Este documento |

**Nota:** Si la aplicación está en ejecución, detenerla antes de compilar (`dotnet build`). Para aplicar la nueva columna en bases ya desplegadas sin usar EF, ejecutar `Scripts/ApplySchoolIdCardPolicy.sql`.
