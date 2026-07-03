# Análisis de memoria y rendimiento — módulo `/StudentIdCard/ui`

**Alcance:** rutas y flujos bajo `StudentIdCard` relacionados con la UI de carnet (`/StudentIdCard/ui`, `/StudentIdCard/ui/generate/{id}`, `/StudentIdCard/ui/print/{id}`, impresión masiva vía API), servicios de captura HTML→PDF (Puppeteer), generación nativa PDF (QuestPDF + SkiaSharp), y carga de imágenes (Cloudinary / HTTP).

**Metodología:** inspección estática del código en el repositorio (sin ejecución ni cambios).

**Fecha del análisis:** 2026-04-13 (contexto de incidentes tipo OOM en planes ~512 MB — p. ej. Render).

---

## 1. Resumen ejecutivo

| Aspecto | Evaluación |
|--------|------------|
| **Estado general** | El módulo combina **Chromium headless (PuppeteerSharp)**, **capturas PNG a alta resolución**, **QuestPDF** y **SkiaSharp**. Es inherentemente **intensivo en RAM y CPU** frente a un endpoint típico CRUD. |
| **Riesgo global** | **Alto** en instancias con **≤512 MB** si se ejecutan impresiones PDF (simple o masiva) concurrentes o en cadena con otros servicios (cola de correo, EF, etc.). |
| **Riesgo solo vista HTML** | **Medio** — `GET /StudentIdCard/ui` devuelve una página ligera; el coste aparece al abrir **generate** en Chromium o al **print/bulk**. |

---

## 2. Hallazgos detallados

### H1 — Proceso Chromium + Puppeteer por generación PDF (HTML)

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `SchoolManager/Services/Implementations/StudentIdCardHtmlCaptureService.cs` — `GenerateFromUrl` (aprox. L33–L56), `GenerateBulkFromUrls` (aprox. L58–L106), `CaptureCardFacesAsync` (aprox. L161–L227), `Capture` (aprox. L309–L328). |
| **Tipo** | Proceso nativo pesado + buffers de imagen grandes en heap administrado. |
| **Memoria** | Chromium suele reservar **cientos de MB** además del runtime .NET. Una instancia compartida en bulk reduce lanzamientos pero **mantiene el heap del navegador** durante todo el bucle. |
| **Escenario** | `GET /StudentIdCard/ui/print/{studentId}` → `_htmlCapture.GenerateFromUrl(url)` (`StudentIdCardController.cs`, aprox. L261–L268). |
| **Severidad** | **Crítica** en planes pequeños; **Alta** en 2 GB si hay concurrencia. |

**Detalle técnico:** `WaitUntil = DOMContentLoaded + Networkidle2` (aprox. L183–L187) puede alargar la vida de la pestaña y el tráfico de red (fuentes Google, imágenes vía `/File/...`), reteniendo recursos hasta cumplir la condición.

---

### H2 — DPR dinámico hasta `MaxDeviceScaleFactor` (p. ej. 4×)

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `StudentIdCardHtmlCaptureService.cs` — `ResolvePageSize` (aprox. L244–L254), `SetCaptureViewportAsync` (aprox. L229–L235), ajuste DPR en perfil `CardPrinter` (aprox. L194–L218). |
| **Configuración** | `StudentIdCardPdfPrintOptions.cs` — `DeviceScaleFactor` default **2**, `MaxDeviceScaleFactor` default **4** (aprox. L14–L18). |
| **Tipo** | Multiplicador de píxeles del viewport y del screenshot; aumenta **ancho × alto × factor²** aprox. en superficie de captura. |
| **Memoria** | Screenshots PNG sin comprimir en memoria (`ScreenshotDataAsync`) + `SKBitmap.Decode` + posible `Resize` (aprox. L309–L327) ⇒ **varias copias** del mismo contenido en distintas fases. |
| **Escenario** | Carnet vertical CR80 a ~300 dpi base (`IdCardPhysicalDimensions` en `SchoolManager/Services/IdCardPhysicalDimensions.cs`, aprox. L8–L15) ya implica dimensiones altas; subir DPR a 3–4 **dispara** el uso de RAM. |
| **Severidad** | **Alta**. |

---

### H3 — `GenerateBulkFromUrls`: lista de PDFs completos en memoria antes de fusionar

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `StudentIdCardHtmlCaptureService.cs` — `GenerateBulkFromUrls` acumula `List<byte[]>` (aprox. L67–L104). `StudentIdCardController.cs` — `PrintBulk` (aprox. L384–L424). |
| **Tipo** | Retención simultánea de **N documentos PDF** como `byte[]` (N ≤ 30 por límite de negocio, `BulkPrintMaxStudents`, aprox. L21 y L350). |
| **Memoria** | Cada PDF puede ser **varios MB** (imágenes embebidas). **30 × varios MB** + objeto `PdfDocument` fusionado + `MemoryStream` + `ToArray()` ⇒ picos muy altos. |
| **Escenario** | Impresión masiva desde la UI índice (`POST .../api/print-bulk`). |
| **Severidad** | **Crítica** en 512 MB; **Alta** en 2 GB con otros procesos activos. |

---

### H4 — Fusión PDF masiva: `PdfDocument` + `MemoryStream.Save` + `ToArray()`

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `StudentIdCardController.cs` — bucle `PdfReader.Open` / `merged.AddPage` (aprox. L395–L406), `outStream` y `return File(outStream.ToArray(), ...)` (aprox. L421–L424). |
| **Tipo** | Copias adicionales del PDF final en memoria administrada. |
| **Memoria** | `Save` al `MemoryStream` y luego **`ToArray()`** duplica el tamaño del resultado final en un único bloque contiguo antes de enviar la respuesta. |
| **Escenario** | Mismo flujo masivo. |
| **Severidad** | **Alta**. |

---

### H5 — Descarga de imágenes con `GetByteArrayAsync` (logo / URLs HTTP)

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `StudentIdCardPdfService.cs` — `SafeDownloadBytesAsync` (aprox. L293–L307): `_http.GetByteArrayAsync(url, cts.Token)` con tope **5 MB** (`MaxImageDownloadBytes`, aprox. L35–L36). |
| **Tipo** | Carga **completa** en un `byte[]` por cada URL HTTP(S) exitosa. |
| **Memoria** | Hasta varios MB por logo + copias en Skia (`CreateWatermarkImage`, aprox. L347–L377) y embebido en PNG/PDF. |
| **Escenario** | Fallback **nativo** cuando falla HTML: `GenerateCardPdfAsync` (`StudentIdCardPdfService.cs`, aprox. L59–L178). También rutas que cargan foto vía `_fileStorage.GetUserPhotoBytesAsync` (aprox. L133–L134). |
| **Severidad** | **Media–Alta** según tamaño real de logos y número de imágenes por carnet. |

---

### H6 — Foto de usuario: `GetUserPhotoBytesAsync` para Cloudinary

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `LocalFileStorageService.cs` — `GetUserPhotoBytesAsync` (aprox. L362–L377): `client.GetByteArrayAsync(new Uri(trimmed))` con timeout **45 s** (aprox. L374–L376). |
| **Tipo** | Misma pauta: **respuesta completa en memoria**; sin límite explícito de bytes en este método (a diferencia del PDF service para logos). |
| **Memoria** | Fotos mal configuradas o URLs que devuelvan objetos grandes podrían acercarse a límites del plan. |
| **Escenario** | `StudentIdCardPdfService.GenerateCardPdfAsync` cuando `ShowPhoto` y hay `PhotoUrl` (aprox. L133–L134). |
| **Severidad** | **Media** (típicamente fotos acotadas; riesgo sube si las URLs no son imágenes pequeñas). |

---

### H7 — Strings grandes en el modelo de vista HTML: Data URLs de QR

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `StudentIdCardService.cs` — `GetCurrentCardAsync` (aprox. L101–L118): `QrImageDataUrl` y `EmergencyInfoQrImageDataUrl` como `data:image/png;base64,...`. Vista `Views/StudentIdCard/Generate.cshtml` (aprox. L434, L457, L489) incrusta esas cadenas en `<img src="...">`. |
| **Tipo** | HTML de respuesta y DOM de Chromium contienen **base64 inline** (no es fuga entre requests, pero **aumenta el tamaño del documento** y la presión en el proceso del navegador). |
| **Memoria** | Moderada por request; suma con capturas de pantalla y red. |
| **Escenario** | Cada carga de `/StudentIdCard/ui/generate/{id}` usada para captura. |
| **Severidad** | **Media**. |

---

### H8 — `GenerateView` carga entidad `School` completa en proyección anónima

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `StudentIdCardController.cs` — `GenerateView` (aprox. L102–L117): `School = s` dentro del `Select` del bundle. |
| **Tipo** | Materialización de **toda** la fila de `Schools` (muchas columnas) aunque la vista use un subconjunto. |
| **Memoria** | Incremento por request; menor que Chromium/PDF pero innecesario si la tabla escuela es ancha. |
| **Escenario** | Cada visita a la vista de generación. |
| **Severidad** | **Baja**. |

---

### H9 — Uso de `using` / `await using` en servicios críticos

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `StudentIdCardHtmlCaptureService.cs` — `await using (var browser = ...)` en `GenerateFromUrl` (aprox. L41–L53); `await using var browser` en bulk (aprox. L68); `await using var page` en captura (aprox. L163). |
| **Tipo** | **Correcto** — el navegador y la página se disponen al salir del scope. |
| **Riesgo de fuga por stream no cerrado** | Bajo en este archivo para el ciclo de vida de Puppeteer; el riesgo principal no es IDisposable omitido sino **picos por tamaño de buffers**. |

---

### H10 — Concurrencia: mismo host sirve HTML a Chromium

| Campo | Detalle |
|-------|---------|
| **Ubicación** | `StudentIdCardController.Print` construye URL al mismo host (aprox. L263) y llama a `GenerateFromUrl`. |
| **Tipo** | El proceso **abre una segunda petición HTTP** al mismo aplicativo (cookies replicadas en `SetCookieAsync`, aprox. L173–L180). |
| **Memoria / CPU** | Bajo carga, **dos solicitudes concurrentes por impresión** (cliente + headless) duplican trabajo y memoria transitoria (Kestrel + Chromium + render). |
| **Severidad** | **Alta** en concurrencia moderada sobre hardware pequeño. |

---

## 3. Mapa de consumo de memoria (flujo conceptual)

### A) Vista lista `/StudentIdCard/ui` (`Index.cshtml`)

1. Navegador del usuario: DataTables + JSON de estudiantes (memoria **del cliente**).
2. Servidor: consultas EF para listados/filtros (fuera del alcance estricto de “generate”, pero comparten el mismo proceso).

### B) Vista previa `/StudentIdCard/ui/generate/{studentId}`

1. **Servidor:** EF + `GetCurrentCardAsync` → DTO con QRs en base64.
2. **Respuesta HTML:** fuentes externas (Google Fonts en `Generate.cshtml`, aprox. L35), imágenes vía `/File/GetSchoolLogo` y `UserPhotoLinks.Href` (aprox. L379–L397).
3. **Si Chromium abre esta URL:** parseo DOM, layout, imágenes decodificadas en el proceso del navegador, luego captura PNG y pipeline Skia/QuestPDF en .NET.

### C) PDF individual `GET /StudentIdCard/ui/print/{studentId}`

1. Intento **HTML:** `GenerateFromUrl` → Chromium + 1–2 capturas PNG grandes + `BuildPdfFromFaceImages` → `Document.Create(...).GeneratePdf()` → `byte[]`.
2. Fallback **nativo:** `StudentIdCardPdfService.GenerateCardPdfAsync` → descargas HTTP (`GetByteArrayAsync`), foto (`GetUserPhotoBytesAsync`), bitmaps Skia, `GeneratePdf()` → `byte[]`.
3. **Controlador:** `return File(pdf, ...)` — el arreglo vive hasta enviar la respuesta.

### D) PDF masivo `POST .../api/print-bulk`

1. Lista de URLs → `GenerateBulkFromUrls` → **N** PDFs en `List<byte[]>` + un Chromium compartido.
2. Fusión con **PdfSharpCore** en memoria (`StudentIdCardController.cs`, aprox. L395–L424).
3. **`ToArray()`** del `MemoryStream` final — otra copia monolítica.

---

## 4. Riesgos en producción (Render, 1 vCPU, RAM limitada)

| Escenario | Comportamiento esperado |
|-----------|---------------------------|
| **Varios usuarios** generando PDF a la vez | Múltiples procesos Chromium y múltiples `byte[]` grandes ⇒ **OOM** o **thrashing** si el plan es ~512 MB. |
| **Impresión masiva (30)** | Pico **muy superior** a un PDF único; ventana de riesgo **alta** aunque sea un solo usuario. |
| **Imágenes grandes** (logo Cloudinary sin transformaciones, foto original) | Mayor tamaño de PNG embebido y mayor RAM en captura y en QuestPDF. |
| **HTML con `networkidle2`** | Puede demorar o retener red abierta (fuentes, imágenes), aumentando tiempo con Chromium vivo. |

**Nota:** El usuario citó “Standard plan / 2 GB” en el brief; los incidentes reportados en conversación previa mencionaban **512 MB**. El riesgo es **escala con el límite real del servicio**.

---

## 5. Patrones problemáticos detectados (checklist)

| Patrón | ¿Presente? | Dónde |
|--------|-------------|--------|
| `byte[]` grandes retenidos en colecciones | Sí | Lista `studentPdfs`, resultados de bulk, PDFs finales. |
| `MemoryStream` + `ToArray()` (copia extra) | Sí | `PrintBulk` respuesta (aprox. L421–L424). |
| `GetByteArrayAsync` (carga completa) | Sí | `StudentIdCardPdfService`, `LocalFileStorageService.GetUserPhotoBytesAsync`. |
| Proceso externo pesado (Chromium) | Sí | Puppeteer en `StudentIdCardHtmlCaptureService`. |
| Múltiples decodificaciones Skia de la misma imagen | Parcial | Captura: PNG screenshot → `SKBitmap` → encode PNG otra vez (aprox. L316–L327). |
| `static` con estado mutable peligroso | No crítico | `StudentIdCardImageService` usa `static readonly` para dimensiones (constantes); **no** indica fuga por sí solo. |
| Dependencia fuerte del GC | Sí | Muchos arrays grandes de vida corta; presión de **Gen2** y fragmentación bajo ráfagas. |

---

## 6. Puntos críticos — Top 5

1. **Chromium (Puppeteer) + captura alta DPR** — principal consumidor de RAM fuera del heap típico de ASP.NET Core.  
2. **Impresión masiva: N PDFs en memoria + fusión + `ToArray()`** — pico máximo predecible del módulo.  
3. **`GetByteArrayAsync` sin tope de tamaño en foto de usuario** — riesgo si las URLs devuelven payloads anómalos.  
4. **Concurrencia: impresión + self-fetch al mismo Kestrel** — amplifica CPU/RAM bajo carga.  
5. **`Networkidle2` + recursos externos** — alarga ventana de uso de Chromium y memoria del documento.

---

## 7. Recomendaciones (solo conceptuales — sin código)

1. **Dimensionar instancia** por el peor caso conocido: “un PDF carnet” y “30 PDFs fusionados” no son equivalentes; los planes deben contemplar **Chromium + pico de arrays**.  
2. **Reducir o acotar** el grado de paralelismo de generación PDF en el mismo proceso (cola dedicada, semáforo de concurrencia, worker separado).  
3. **Revisar política de DPR** (`DeviceScaleFactor` / `MaxDeviceScaleFactor`) frente a calidad aceptable; el trade-off calidad/RAM es directo.  
4. **Para logos y fotos en rutas HTTP:** preferir **transformaciones en CDN** (ancho máximo, calidad) para reducir bytes descargados y decodificados.  
5. **Masivo:** valorar estrategias que **no** retengan los N PDFs completos a la vez (streaming, fusionar en disco temporal, o menor lote máximo operativo).  
6. **Observabilidad:** métricas de memoria de proceso y contadores de “PDF iniciado / completado” por instancia para correlacionar con OOM.  
7. **Separar** el trabajo de Chromium en un **servicio con más RAM** o contenedor dedicado si el volumen de impresión es alto.

---

## 8. Referencias de archivos clave

| Archivo | Rol |
|---------|-----|
| `Controllers/StudentIdCardController.cs` | Rutas `ui`, `ui/generate`, `ui/print`, `api/print-bulk`. |
| `Services/Implementations/StudentIdCardHtmlCaptureService.cs` | Puppeteer, captura, QuestPDF desde imágenes. |
| `Services/Implementations/StudentIdCardPdfService.cs` | PDF nativo, descargas HTTP, integración foto/logo. |
| `Services/Implementations/StudentIdCardImageService.cs` | Render Skia del frente/reverso. |
| `Services/Implementations/LocalFileStorageService.cs` | Descarga de foto (Cloudinary URL). |
| `Services/Implementations/StudentIdCardPdfPrintOptions.cs` | DPR y escala de captura. |
| `Services/IdCardPhysicalDimensions.cs` | Resolución base en px a 300 DPI. |
| `Views/StudentIdCard/Generate.cshtml` | HTML que consume Chromium. |
| `Views/StudentIdCard/Index.cshtml` | UI masiva y llamadas a API. |

---

*Fin del informe. Documento generado solo con fines de análisis; no implica cambios en el código.*
