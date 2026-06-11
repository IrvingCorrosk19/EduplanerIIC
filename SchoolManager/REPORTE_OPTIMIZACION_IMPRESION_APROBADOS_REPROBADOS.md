# Optimización de impresión — Aprobados y Reprobados

**Proyecto:** `C:\Proyectos\EduplanerIIC\SchoolManager`  
**Vista:** `/AprobadosReprobados/VistaPrevia`  
**Fecha:** 2026-06-10  
**Alcance:** Solo presentación e impresión (sin cambios en datos, consultas ni cálculos académicos)

---

## 1. Hallazgos del análisis

### Controller — `AprobadosReprobadosController.cs`

| Acción | Comportamiento |
|--------|----------------|
| `VistaPrevia` (GET) | Llama `GenerarReporteAsync`, asigna coordinador y devuelve `Views/AprobadosReprobados/VistaPrevia.cshtml` con `Layout = null`. |
| `ExportarPdf` (GET) | Misma data + QuestPDF (`ExportarAPdfAsync`) — PDF institucional sin URL del navegador. |
| Impresión desde Index | `window.open(VistaPrevia?...&autoprint=1)` o `window.print()` en preview embebido. |

**No hay layout admin** en VistaPrevia: página autónoma con Bootstrap CDN + estilos locales.

### Service — `AprobadosReprobadosService.cs`

- `GenerarReporteAsync`: única fuente de datos del reporte (sin cambios en esta intervención).
- `ExportarAPdfAsync`: QuestPDF con header, tabla, footer institucional y paginación `Página X de Y` nativa del motor PDF.

### ViewModel — `AprobadosReprobadosReportViewModel`

Campos usados en impresión: `InstitutoNombre`, `LogoUrl`, `ProfesorCoordinador`, `Trimestre`, `AnoLectivo`, `NivelEducativo`, `FechaGeneracion`, `Estadisticas`, `TotalesGenerales`, `MostrarColumnaMateria`, `EsConsolidado`, `CantidadAsignaciones`.

### Vista — `VistaPrevia.cshtml` (antes)

- `@page` con margen 10 mm y tamaño dinámico portrait/landscape.
- `@media print` mínimo: ocultar `.no-print`, reducir fuente a 9 px.
- **Sin** `thead { display: table-header-group }`.
- **Sin** `page-break-inside: avoid` en filas.
- **Sin** pie institucional propio.
- **Sin** instrucción sobre encabezados del navegador.
- Firmas con `<hr>` básico.
- `window.print()` directo (y autoprint en query `autoprint=1`).

### Partial — `_TablaReporte.cshtml`

Tabla Bootstrap con clases `apr-tabla`, encabezados de dos filas, fila TOTALES.

### JavaScript relacionado

- `VistaPrevia.cshtml`: autoprint en load.
- `Index.cshtml`: abre VistaPrevia, `window.print()` en preview inline — **no modificado** (solo VistaPrevia).

### CSS existente en el proyecto

Patrones reutilizables en `wwwroot/css/reporte-institucional-base.css` y `reporte-pagina-legal.css` (thead repetible, evitar filas partidas, `@page`).

---

## 2. Causa raíz — URL en el pie de página

### Síntoma

Al imprimir aparece:

```text
https://eduplaner.net/AprobadosReprobados/VistaPrevia?trimestre=...&nivelEducativo=... 1/2
```

### Causa raíz (confirmada)

**No proviene del CSS, del layout, del servicio ni de scripts de la aplicación.**

Es el **encabezado/pie de página predeterminado del navegador** (Chrome, Edge, Firefox) cuando se usa `window.print()`. El navegador inserta automáticamente:

- URL de la página
- Título o fecha (según configuración)
- Numeración `1/2`, `2/2`, etc.

**CSS `@page` no puede desactivar** esos encabezados nativos del navegador. No existe propiedad estándar soportada en Chrome/Edge para ocultarlos desde código.

### Soluciones posibles

| Solución | Efectividad |
|----------|-------------|
| Usuario desactiva «Encabezados y pies de página» en diálogo de impresión | **100%** para impresión HTML |
| Exportar PDF servidor (QuestPDF — ya implementado en `ExportarPdf`) | **100%** — documento sin URL del navegador |
| CSS `@page margin` | Solo ajusta márgenes; **no elimina** la URL |

### Acción implementada

1. Banner instructivo visible en pantalla (clase `.no-print`) explicando desactivar encabezados del navegador.
2. Pie institucional propio fijo en impresión (`Sistema EduPlanner`, título del reporte, fecha, `Página N` vía `counter(page)`).
3. Documentación explícita en este informe.

---

## 3. Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `Views/AprobadosReprobados/VistaPrevia.cshtml` | Reestructuración HTML institucional, hint de impresión, cabecera repetible, firmas, pie |
| `Views/AprobadosReprobados/_TablaReporte.cshtml` | Sin cambios funcionales (ya compatible con clases `apr-*`) |
| `wwwroot/css/aprobados-reprobados-vista-previa.css` | **Nuevo** — CSS screen + `@media print` profesional |

**No modificados:** Controller, Service, ViewModels, consultas, cálculos.

---

## 4. CSS agregado — resumen

Archivo: `wwwroot/css/aprobados-reprobados-vista-previa.css`

### Configuración de página

- `@page` en VistaPrevia: `A4 portrait` (asignación única) / `A4 landscape` (consolidado), márgenes `10mm` laterales y `18mm` inferior para pie fijo.

### Impresión

```css
thead { display: table-header-group; }
tr, .apr-fila-total { page-break-inside: avoid; }
table { page-break-inside: auto; }
```

### Tipografía

- `Arial, Helvetica, sans-serif`
- Cuerpo: 10 pt pantalla / 8–9 pt tabla en impresión
- Encabezados institucionales: 11–13 pt

### Densidad

- `td/th` padding: 3–4 px en impresión (más registros por página)

### Cabecera repetida

- `.apr-running-header` con `position: fixed; top: 0` visible solo en `@media print`
- Cabecera completa en pantalla; compacta fija en cada hoja impresa

### Pie institucional

- `.apr-pie-institucional` fijo al fondo en impresión
- `counter(page)` para numeración propia

### Colores impresión

- Azul institucional `#1f4e79` en encabezados (con `print-color-adjust: exact`)
- Verdes/rojos moderados para aprobados/reprobados
- Fondo fila totales `#e3f2fd` (legible en escala de grises)

### Elementos ocultos al imprimir

- Toolbar (Imprimir / Cerrar)
- Banner instructivo
- Cualquier `.no-print`

---

## 5. Mejoras UX/UI aplicadas

| Problema | Solución |
|----------|----------|
| URL en pie | Documentada causa + instrucción visual al usuario |
| Numeración navegador | Misma instrucción + pie propio con `Página N` |
| Tabla partida | `page-break-inside: avoid` en filas |
| Encabezado tabla no repetido | `display: table-header-group` en `thead` |
| Cabecera institucional | MINISTERIO + DR San Miguelito + centro + título MEDUCA |
| Cabecera en multipágina | Header fijo compacto en impresión |
| Firmas básicas | Línea de firma + título centrado con separación |
| Pie inexistente | Pie EduPlanner con fecha de generación |
| Aspecto “web impresa” | Documento blanco, sin sombras, tipografía institucional |
| Páginas vacías | Márgenes controlados; firmas con `break-inside: avoid` |
| `table-responsive` corta tabla | `overflow: visible` en impresión |

---

## 6. Capturas antes / después

No se generaron capturas automáticas en este entorno (requieren navegador interactivo).

**Antes (comportamiento observado):**

- Pie del navegador: URL + `1/2`
- Encabezado de tabla solo en primera página
- Cabecera grande solo al inicio
- Firmas con `<hr>` simple

**Después (esperado al imprimir con encabezados del navegador desactivados):**

- Pie: `Sistema EduPlanner | Reporte de Aprobados y Reprobados | Generado: dd/MM/yyyy HH:mm | Página N`
- Encabezados de columnas en cada hoja
- Cabecera institucional compacta repetida arriba
- Firmas con línea profesional

**Validación manual recomendada:**

1. Abrir `/AprobadosReprobados/VistaPrevia?...`
2. Imprimir → desactivar «Encabezados y pies de página»
3. Verificar multipágina con consolidado
4. Comparar con `ExportarPdf` (QuestPDF) si se requiere archivo sin intervención del usuario

---

## 7. Resultado final

VistaPrevia convertida en documento institucional imprimible con:

- Identidad MEDUCA / Dirección Regional / centro educativo
- Tabla optimizada para archivo y supervisión
- Pie y firmas de nivel secretaría académica
- Guía clara para eliminar la URL del navegador

Funcionalidad de datos, filtros, consolidado y cálculos **intacta**.

---

## 8. Riesgos identificados

| Riesgo | Mitigación |
|--------|------------|
| Usuario no desactiva encabezados del navegador | Banner visible antes de imprimir |
| `counter(page)` parcial en algunos navegadores | QuestPDF disponible para PDF oficial |
| Header fijo puede solaparse en impresoras con margen mínimo | `@page margin-bottom: 18mm` |
| Logo Cloudinary no carga offline en impresión | Mismo comportamiento previo; logo opcional con `onerror` |

---

## 9. Compilación

```text
dotnet build → OK (verificado al finalizar implementación)
```

---

## 10. Confirmaciones

| Restricción | Cumplida |
|-------------|----------|
| Sin modificar cálculos académicos | ✅ |
| Sin modificar datos | ✅ |
| Sin modificar consultas / servicio | ✅ |
| Sin romper VistaPrevia / autoprint | ✅ |
| Solo UX/UI impresión | ✅ |

---

*Intervención completada. Para documento PDF sin configuración manual del navegador, usar la acción `ExportarPdf` (QuestPDF) cuando esté habilitada en la UI.*
