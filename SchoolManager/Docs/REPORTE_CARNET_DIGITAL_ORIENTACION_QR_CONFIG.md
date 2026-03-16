# Reporte: Corrección módulo carnet digital (QR, configuración, orientación)

**Fecha:** 2026-03-16  
**Objetivo:** Resolver (1) QR no visible en el PDF, (2) configuración no aplicada al PDF, (3) orientación vertical/horizontal del carnet.

---

## 1. Archivos modificados

| Archivo | Cambios |
|---------|---------|
| **Models/SchoolIdCardSetting.cs** | Añadida propiedad `string Orientation` (default `"Vertical"`). |
| **Models/SchoolDbContext.cs** | Configuración de la propiedad `Orientation` (columna `orientation`, varchar 20, default "Vertical"). |
| **Migrations/20260316023039_AddIdCardOrientation.cs** | Migración: agregar columna `orientation` a `school_id_card_settings`. |
| **Migrations/SchoolDbContextModelSnapshot.cs** | Añadida propiedad `Orientation` al snapshot de `SchoolIdCardSetting`. |
| **Controllers/IdCardSettingsController.cs** | Carga y guardado de `Orientation`; sincronización de `PageWidthMm`/`PageHeightMm` con orientación (Vertical 54×86, Horizontal 86×54) al guardar. Valores por defecto en settings incluyen `Orientation = "Vertical"`. |
| **Controllers/StudentIdCardController.cs** | En `GenerateView`: carga de `SchoolIdCardSetting` y envío de `IdCardOrientation`, `IdCardShowQr`, `IdCardShowPhoto` a la vista para la vista previa. |
| **Views/IdCardSettings/Index.cshtml** | Sección "Orientación del carnet" con radios Vertical (54×86 mm) y Horizontal (86×54 mm). Vista previa del modal usa `Orientation` para dimensiones y ya respetaba ShowQr/ShowPhoto. |
| **Views/StudentIdCard/Generate.cshtml** | Variables `orientation`, `showQr`, `showPhoto` desde ViewBag. Contenedor del carnet con dimensiones y aspect-ratio según orientación. Foto y fila QR condicionados a `showPhoto` y `showQr`. Script de QR solo se ejecuta cuando `showQr` y existe el canvas. |
| **Services/Implementations/StudentIdCardPdfService.cs** | `GetCardDimensions(settings)`: devuelve (54, 86) para Vertical y (86, 54) para Horizontal. Layout por defecto usa estas dimensiones en `page.Size()` (frente y reverso). Footer del frente usa `cardHeightMm`. `SafeGenerateQrPng`: si falla con firma, intenta sin firma para que el QR se muestre. Objeto por defecto de settings incluye `Orientation = "Vertical"`. |
| **Scripts/ApplyIdCardOrientation.sql** | Script idempotente para agregar la columna `orientation` en bases existentes. |

---

## 2. Migración creada

- **Nombre:** `20260316023039_AddIdCardOrientation`
- **Tabla:** `school_id_card_settings`
- **Cambio:** Columna `orientation` (character varying(20), NOT NULL, default `'Vertical'`).
- **Aplicación:** `dotnet ef database update` o ejecutar `Scripts/ApplyIdCardOrientation.sql` en local y Render.

---

## 3. Corrección del QR (FASE 1)

**Problema:** El código QR no aparecía en el carnet generado.

**Causas abordadas:**

1. **Firma del token:** Si `QrSignatureService` fallaba o generaba un contenido inválido, el QR no se generaba.  
   **Solución:** En `SafeGenerateQrPng` se intenta primero con firma; si lanza excepción, se llama a `QrHelper.GenerateQrPng(token, null)` (sin firma) para que el QR se muestre igual.

2. **Comprobaciones ya existentes:** Se mantienen las comprobaciones de `dto.QrToken` no vacío y `settings.ShowQr`, y el uso de `SafeGenerateQrPng` en frente, reverso y plantilla (caso "Qr").  
   **Verificación:** `BuildStudentCardDtoAsync` crea o reutiliza `StudentQrToken` y asigna `QrToken = token.Token` al DTO, por lo que el token está disponible cuando hay carnet.

3. **QuestPDF:** Se sigue usando `container.Image(qrBytes)` con los bytes devueltos por `SafeGenerateQrPng`; no se modificó la API de QuestPDF.

---

## 4. Corrección de la configuración (FASE 2)

**Problema:** Los cambios en la configuración del carnet no afectaban al PDF.

**Causa:** En el layout por defecto (CarnetQR) se usaban constantes fijas `CardWidthMm`/`CardHeightMm` (85.6×54) en lugar de la configuración guardada.

**Cambios:**

1. **Dimensiones desde configuración:** Se eliminaron las constantes fijas y se usa `GetCardDimensions(settings)`, que devuelve (54, 86) para Vertical y (86, 54) para Horizontal, de modo que el PDF use la orientación guardada.

2. **Settings ya se cargaban bien:** La carga con `_context.Set<SchoolIdCardSetting>().AsNoTracking().IgnoreQueryFilters().FirstOrDefaultAsync(x => x.SchoolId == school.Id)` se mantiene; el objeto `settings` se pasa a `RenderCarnetQrFront`, `RenderCarnetQrBack` y `RenderField`, por lo que **ShowQr**, **ShowPhoto**, **ShowSchoolPhone**, **ShowEmergencyContact** y **ShowAllergies** se aplican en el PDF.

3. **Sincronización con orientación:** Al guardar en IdCardSettings se actualizan `PageWidthMm` y `PageHeightMm` según la orientación (Vertical: 54×86, Horizontal: 86×54), para que el layout con campos personalizados y la vista previa coincidan con la orientación.

---

## 5. Implementación de la orientación (FASES 3, 4, 5)

**Requisito:** Poder elegir orientación Vertical u Horizontal del carnet.

**Implementación:**

1. **Modelo y BD:** `SchoolIdCardSetting.Orientation` (string, valores "Vertical" | "Horizontal", default "Vertical"). Migración y script SQL.

2. **UI de configuración:** En `/id-card/settings`, sección "Orientación del carnet" con dos radios: "Vertical (54 × 86 mm)" y "Horizontal (86 × 54 mm)". El valor se guarda en `SchoolIdCardSetting.Orientation`.

3. **PDF:** `GetCardDimensions(settings)` devuelve (54, 86) para Vertical y (86, 54) para Horizontal. Se usa en `page.Size(cardWidthMm, cardHeightMm, Unit.Millimetre)` para la página del frente y la del reverso. El footer del frente usa `cardHeightMm` para la posición.

4. **Vista previa (IdCardSettings):** El modal de vista previa toma la orientación del formulario y aplica 54×86 o 86×54 para ancho/alto y escala del preview, y ya usaba ShowQr y ShowPhoto.

5. **Vista previa (Generate):** En `StudentIdCard/Generate.cshtml` se usan `ViewBag.IdCardOrientation`, `IdCardShowQr` e `IdCardShowPhoto`. El contenedor del carnet usa dimensiones y aspect-ratio según orientación; la foto y la fila del QR se muestran u ocultan según la configuración.

---

## 6. Resumen de pruebas recomendadas (FASE 7)

1. En `/id-card/settings` elegir **Horizontal**, guardar, abrir vista previa y comprobar proporción 86×54.
2. Cambiar a **Vertical**, guardar, generar un carnet y descargar PDF: debe ser 54×86 mm.
3. Desmarcar "Mostrar código QR", guardar, generar PDF: no debe aparecer página de reverso con QR (y en vista previa sin QR).
4. Desmarcar "Mostrar foto", guardar, generar PDF: el frente no debe mostrar foto.
5. Comprobar que el QR se ve en el PDF cuando está activado y que, si falla la firma, se muestra el QR sin firma.

---

## 7. Resumen final

| Fase | Descripción | Estado |
|------|-------------|--------|
| **FASE 1** | Investigar y corregir QR no visible | Hecho (fallback sin firma + uso consistente de SafeGenerateQrPng) |
| **FASE 2** | Asegurar que la configuración afecte al PDF | Hecho (dimensiones desde GetCardDimensions, settings en todo el PDF) |
| **FASE 3** | Añadir Orientation a SchoolIdCardSetting y migración | Hecho |
| **FASE 4** | Selector de orientación en UI y guardado | Hecho |
| **FASE 5** | Aplicar orientación en el PDF (page.Size) | Hecho |
| **FASE 6** | Vista previa con Orientation, ShowQr, ShowPhoto | Hecho (IdCardSettings modal + Generate.cshtml) |
| **FASE 7** | Pruebas funcionales | Pendiente (ejecutar por el usuario) |
| **FASE 8** | Reporte | Este documento |

**Nota:** Para bases ya desplegadas sin aplicar la migración EF, ejecutar `Scripts/ApplyIdCardOrientation.sql` en local y en Render.
