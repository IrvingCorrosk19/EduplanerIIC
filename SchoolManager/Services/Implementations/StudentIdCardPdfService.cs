using System.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Helpers;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.Services.Security;
using SkiaSharp;

namespace SchoolManager.Services.Implementations;

public class StudentIdCardPdfService : IStudentIdCardPdfService
{
    private readonly SchoolDbContext _context;
    private readonly IFileStorageService _fileStorage;
    private readonly HttpClient _http;
    private readonly ILogger<StudentIdCardPdfService> _logger;
    private readonly IQrSignatureService _qrSignatureService;
    private readonly IWebHostEnvironment _environment;

    /// <summary>Dimensiones según orientación: Vertical = 54×86 mm, Horizontal = 86×54 mm.</summary>
    private static (float WidthMm, float HeightMm) GetCardDimensions(SchoolIdCardSetting settings)
    {
        var orientation = (settings?.Orientation ?? "Vertical").Trim();
        if (string.Equals(orientation, "Horizontal", StringComparison.OrdinalIgnoreCase))
            return (86f, 54f);
        return (54f, 86f); // Vertical por defecto
    }

    /// <summary>Máximo de caracteres de alergias en el reverso del carnet impreso (BUG-3 fix).</summary>
    private const int MaxAllergiesCharsOnCard = 100;

    /// <summary>Máximo de bytes para una imagen de logo descargada externamente (SEG-4 fix).</summary>
    private const int MaxImageDownloadBytes = 5 * 1024 * 1024; // 5 MB

    /// <summary>Timeout para descarga de imágenes externas (SEG-4 fix).</summary>
    private static readonly TimeSpan ImageDownloadTimeout = TimeSpan.FromSeconds(10);

    public StudentIdCardPdfService(
        SchoolDbContext context,
        IFileStorageService fileStorage,
        IHttpClientFactory httpClientFactory,
        ILogger<StudentIdCardPdfService> logger,
        IQrSignatureService qrSignatureService,
        IWebHostEnvironment environment)
    {
        _context = context;
        _fileStorage = fileStorage;
        _http = httpClientFactory.CreateClient();
        _logger = logger;
        _qrSignatureService = qrSignatureService;
        _environment = environment;
    }

    public async Task<byte[]> GenerateCardPdfAsync(Guid studentId, Guid createdBy)
    {
        try
        {
            _logger.LogInformation(
                "[StudentIdCardPdf] GenerateCardPdfAsync inicio StudentId={StudentId} CreatedBy={CreatedBy}",
                studentId, createdBy);

            // 1) Escuela siempre la del estudiante (misma fuente que la vista Generate y la configuración por colegio del alumno).
            //    No usar GetCurrentUserSchoolAsync: un admin de otra sede o SuperAdmin debe obtener el PDF correcto del alumno.
            var studentSchoolId = await _context.Users
                .AsNoTracking()
                .Where(u => u.Id == studentId)
                .Select(u => u.SchoolId)
                .FirstOrDefaultAsync();

            if (!studentSchoolId.HasValue)
            {
                _logger.LogWarning("[StudentIdCardPdf] Estudiante sin SchoolId StudentId={StudentId}", studentId);
                throw new Exception("El estudiante no tiene escuela asignada.");
            }

            var school = await _context.Schools
                .AsNoTracking()
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(s => s.Id == studentSchoolId.Value);

            if (school == null)
            {
                _logger.LogWarning("[StudentIdCardPdf] Escuela no encontrada SchoolId={SchoolId}", studentSchoolId);
                throw new Exception("No se encontró la institución del estudiante.");
            }

            _logger.LogInformation("[StudentIdCardPdf] Usando escuela del estudiante SchoolId={SchoolId}", school.Id);

            // 2) Settings de carnet — por school.Id del estudiante
            var settings = await _context.Set<SchoolIdCardSetting>()
                .AsNoTracking()
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(x => x.SchoolId == school.Id);

            if (settings == null)
            {
                settings = new SchoolIdCardSetting
                {
                    SchoolId = school.Id,
                    TemplateKey = "default_v1",
                    PageWidthMm = 54,
                    PageHeightMm = 86,
                    BackgroundColor = "#FFFFFF",
                    PrimaryColor = "#0D6EFD",
                    TextColor = "#111111",
                    ShowQr = true,
                    ShowPhoto = true,
                    ShowSchoolPhone = true,
                    ShowEmergencyContact = false,
                    ShowAllergies = false,
                    Orientation = "Vertical",
                    ShowWatermark = true
                };
            }

            // 3) Campos de plantilla PDF personalizada (id_card_template_fields).
            //    Si hay alguno habilitado: una sola página con posiciones fijas (no es el layout CarnetQR de dos caras).
            //    TemplateKey en school_id_card_settings no selecciona otro motor de layout; solo distingue "hay campos" vs CarnetQR.
            var fields = await _context.Set<IdCardTemplateField>()
                .AsNoTracking()
                .Where(x => x.SchoolId == school.Id && x.IsEnabled)
                .ToListAsync();

            // 4) Asegurar carnet + token (con transacción — CONC-2 fix)
            var dto = await BuildStudentCardDtoAsync(studentId, createdBy, school.Name);

            // 4b) Póliza institucional: dato del colegio, compartido por todos sus estudiantes.
            //     Fallback claro si la escuela no la ha configurado todavía.
            dto.PolicyNumber = string.IsNullOrWhiteSpace(school.PolicyNumber)
                ? "POLIZA-PENDIENTE-CONFIGURACION"
                : school.PolicyNumber.Trim();

            // 4c) Año lectivo: fallback explícito si el estudiante no tiene AcademicYear asignado.
            if (string.IsNullOrWhiteSpace(dto.AcademicYear))
                dto.AcademicYear = "NO DEFINIDO";

            // 5) Logo principal, insignia secundaria, marca de agua y foto del estudiante
            byte[]? logoBytes = null;
            if (!string.IsNullOrWhiteSpace(school.LogoUrl))
                logoBytes = await SafeDownloadBytesAsync(school.LogoUrl);
            byte[]? watermarkBytes = (settings.ShowWatermark && logoBytes != null) ? CreateWatermarkImage(logoBytes, 0.14f) : null;

            byte[]? secondaryLogoBytes = null;
            if (settings.ShowSecondaryLogo && !string.IsNullOrWhiteSpace(settings.SecondaryLogoUrl))
                secondaryLogoBytes = await SafeDownloadBytesAsync(settings.SecondaryLogoUrl);

            // Inyectar SecondaryLogoUrl en el DTO de render (para que RenderCarnetModern lo reciba)
            dto.SecondaryLogoUrl = settings.SecondaryLogoUrl;

            byte[]? photoBytes = null;
            if (settings.ShowPhoto && !string.IsNullOrWhiteSpace(dto.PhotoUrl))
                photoBytes = await _fileStorage.GetUserPhotoBytesAsync(dto.PhotoUrl);

            // 6) Generar PDF
            QuestPDF.Settings.License = LicenseType.Community;

            var pdf = Document.Create(container =>
            {
                if (fields.Any())
                {
                    // Layout personalizado: capas sobre fondo; QuestPDF exige exactamente una PrimaryLayer (tamaño del lienzo).
                    var pw = settings.PageWidthMm;
                    var ph = settings.PageHeightMm;
                    container.Page(page =>
                    {
                        page.Size(pw, ph, Unit.Millimetre);
                        page.Margin(0);
                        page.Content().Layers(layers =>
                        {
                            layers.Layer().Background(ParseColor(settings.BackgroundColor));
                            layers.PrimaryLayer().Width(pw, Unit.Millimetre).Height(ph, Unit.Millimetre);
                            layers.Layer().Unconstrained()
                                .TranslateX(0, Unit.Millimetre).TranslateY(0, Unit.Millimetre)
                                .Width(pw, Unit.Millimetre).Height(12, Unit.Millimetre)
                                .Background(ParseColor(settings.PrimaryColor));
                            foreach (var f in fields)
                                layers.Layer().Element(e => RenderField(e, f, dto, school.Name, logoBytes, photoBytes, settings));
                        });
                    });
                }
                else
                {
                    // CarnetQR / Moderno: página exacta al tamaño del carnet (sin márgenes de hoja).
                    var (cardWidthMm, cardHeightMm) = GetCardDimensions(settings);
                    var schoolNamePdf = school.Name;
                    var phonePdf = school.Phone;
                    var policyPdf = school.IdCardPolicy;

                    // Página exacta: frente(54) + gap(2) + reverso(54) = 110mm × 86mm
                    // Sin márgenes — se imprime a tamaño real del carnet
                    var pageWidthMm = settings.ShowQr
                        ? cardWidthMm * 2f + 2f   // 110mm con QR (dos caras)
                        : cardWidthMm;             // 54mm sin QR (solo frente)

                    container.Page(page =>
                    {
                        page.Size(pageWidthMm, cardHeightMm, Unit.Millimetre);
                        page.Margin(0);
                        // Dimensiones explícitas + ShowEntire: QuestPDF trata todo como una sola unidad visual
                        page.Content()
                            .Width(pageWidthMm, Unit.Millimetre)
                            .Height(cardHeightMm, Unit.Millimetre)
                            .ShowEntire()
                            .Row(row =>
                        {
                            if (settings.ShowQr)
                                row.Spacing(2f, Unit.Millimetre);

                            var isModern = settings.UseModernLayout;
                            var isVertical = cardHeightMm > cardWidthMm; // 86 > 54

                            // ── Frente ───────────────────────────────────────────────────────
                            row.ConstantItem(cardWidthMm, Unit.Millimetre)
                                .Height(cardHeightMm, Unit.Millimetre)
                                .ShowEntire()
                                .Border(0.2f).BorderColor(Colors.Grey.Medium)
                                .Element(c =>
                                {
                                    // Diseño institucional vertical (moderno ON + orientación vertical)
                                    if (isModern && isVertical)
                                        return RenderCarnetInstitutionalVerticalFront(
                                            c, schoolNamePdf, logoBytes, secondaryLogoBytes,
                                            photoBytes, dto, settings, watermarkBytes);

                                    // Diseño moderno horizontal (moderno ON + orientación horizontal)
                                    if (isModern)
                                        return RenderCarnetModernFront(c, schoolNamePdf, logoBytes,
                                            secondaryLogoBytes, photoBytes, dto, settings,
                                            cardWidthMm, cardHeightMm, watermarkBytes);

                                    // Diseño clásico (moderno OFF)
                                    return RenderCarnetQrFront(c, schoolNamePdf, logoBytes, photoBytes,
                                        dto, settings, cardWidthMm, cardHeightMm, watermarkBytes);
                                });

                            // ── Reverso ──────────────────────────────────────────────────────
                            if (settings.ShowQr)
                                row.ConstantItem(cardWidthMm, Unit.Millimetre)
                                    .Height(cardHeightMm, Unit.Millimetre)
                                    .ShowEntire()
                                    .Border(0.2f).BorderColor(Colors.Grey.Medium)
                                    .Element(c =>
                                    {
                                        if (isModern && isVertical)
                                            return RenderCarnetInstitutionalVerticalBack(
                                                c, schoolNamePdf, phonePdf, policyPdf, dto, settings, watermarkBytes);
                                        return RenderCarnetQrBack(c, schoolNamePdf, phonePdf, policyPdf, dto, settings, watermarkBytes);
                                    });
                        });
                    });
                }
            }).GeneratePdf();

            _logger.LogInformation(
                "[StudentIdCardPdf] GenerateCardPdfAsync OK StudentId={StudentId} SchoolId={SchoolId}",
                studentId, school.Id);
            return pdf;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "[StudentIdCardPdf] GenerateCardPdfAsync error StudentId={StudentId}: {Message}",
                studentId, ex.Message);
            throw;
        }
    }

    private IContainer RenderField(IContainer container, IdCardTemplateField f, StudentCardRenderDto dto,
        string schoolName, byte[]? logoBytes, byte[]? photoBytes, SchoolIdCardSetting settings)
    {
        var positioned = container.Unconstrained()
            .TranslateX((float)f.XMm, Unit.Millimetre)
            .TranslateY((float)f.YMm, Unit.Millimetre)
            .Width((float)f.WMm, Unit.Millimetre)
            .Height((float)f.HMm, Unit.Millimetre);

        switch (f.FieldKey)
        {
            case "SchoolName":
                positioned.AlignLeft().AlignMiddle().Text(schoolName)
                    .FontSize((float)f.FontSize).FontColor(Colors.White);
                break;

            case "SchoolLogo":
                if (logoBytes != null) positioned.Image(logoBytes);
                break;

            case "Photo":
                if (photoBytes != null && photoBytes.Length > 0)
                    positioned.Border(1).Padding(2).AlignCenter().AlignMiddle().Image(photoBytes);
                else
                    positioned.Border(1).Padding(2).AlignCenter().AlignMiddle().Text("FOTO");
                break;

            case "FullName":
                positioned.Text(dto.FullName).FontSize((float)f.FontSize).Bold().FontColor(ParseColor(settings.TextColor));
                break;

            case "DocumentId":
                positioned.Text(dto.DocumentId ?? "").FontSize((float)f.FontSize).FontColor(ParseColor(settings.TextColor));
                break;

            case "Grade":
                positioned.Text(dto.Grade).FontSize((float)f.FontSize).FontColor(ParseColor(settings.TextColor));
                break;

            case "Group":
                positioned.Text(dto.Group).FontSize((float)f.FontSize).FontColor(ParseColor(settings.TextColor));
                break;

            case "Shift":
                positioned.Text(dto.Shift).FontSize((float)f.FontSize).FontColor(ParseColor(settings.TextColor));
                break;

            case "CardNumber":
                positioned.Text(dto.CardNumber).FontSize((float)f.FontSize).FontColor(ParseColor(settings.TextColor));
                break;

            case "Qr":
                if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                {
                    var qrBytesField = SafeGenerateQrPng(dto.QrToken);
                    if (qrBytesField != null && qrBytesField.Length > 0)
                        positioned.Image(qrBytesField);
                }
                break;
        }

        return positioned;
    }

    /// <summary>
    /// Frente del carnet — diseño CarnetQR: marca de agua, header, cuerpo foto+datos+QR, footer.
    /// Soporta orientación Vertical (54×86 mm) y Horizontal (86×54 mm) con layouts adaptativos.
    /// Todas las dimensiones internas usan Unit.Millimetre para renderizado físicamente correcto.
    /// </summary>
    private IContainer RenderCarnetQrFront(IContainer container, string schoolName, byte[]? logoBytes,
        byte[]? photoBytes, StudentCardRenderDto dto, SchoolIdCardSetting settings, float cardWidthMm, float cardHeightMm,
        byte[]? watermarkBytes = null)
    {
        const float paddingMm = 4f;
        const float headerHeightMm = 14f;
        const float headerPaddingVMm = 2f;
        const float footerBandMm = 8f;
        const float photoWMm = 22f;
        const float photoHMaxMm = 28f;
        const float qrSizeMm = 18f;
        const float spacerMm = 3f;
        const float watermarkSizePercent = 0.42f;

        var isHorizontal = cardWidthMm > cardHeightMm;
        var bodyHeightMm = Math.Max(cardHeightMm - headerHeightMm - footerBandMm, 18f);

        // Dimensiones de foto y QR adaptadas a la orientación
        var photoHMm = Math.Min(photoHMaxMm, bodyHeightMm - paddingMm * 2f);
        // Horizontal: QR más grande en la fila derecha; Vertical: QR en columna bajo los datos
        var qrFrontMm = isHorizontal
            ? Math.Max(Math.Min(bodyHeightMm - paddingMm * 2f, qrSizeMm + 4f), 12f)
            : Math.Min(qrSizeMm, Math.Max(12f, bodyHeightMm - photoHMaxMm));

        var wMmWm = cardWidthMm * watermarkSizePercent;

        // QuestPDF: Layers requiere exactamente una PrimaryLayer; capas previas = fondo y marca de agua
        container.Layers(layers =>
        {
            layers.Layer().Background(ParseColor(settings.BackgroundColor));
            if (watermarkBytes != null && watermarkBytes.Length > 0)
            {
                layers.Layer()
                    .AlignCenter().AlignMiddle()
                    .Width(wMmWm, Unit.Millimetre)
                    .Height(wMmWm, Unit.Millimetre)
                    .Image(watermarkBytes);
            }

            layers.PrimaryLayer().Column(col =>
            {
                // ── Header ──────────────────────────────────────────────────────────────
                col.Item().Height(headerHeightMm, Unit.Millimetre)
                    .Background(ParseColor(settings.PrimaryColor))
                    .PaddingHorizontal(paddingMm, Unit.Millimetre)
                    .PaddingVertical(headerPaddingVMm, Unit.Millimetre)
                    .Row(r =>
                    {
                        if (logoBytes != null)
                        {
                            r.ConstantItem(10f, Unit.Millimetre)
                                .Height(8f, Unit.Millimetre)
                                .AlignLeft().AlignMiddle()
                                .Image(logoBytes);
                            r.ConstantItem(2f, Unit.Millimetre);
                        }
                        r.RelativeItem().AlignLeft().AlignMiddle()
                            .Text(schoolName).FontSize(7).FontColor(Colors.White).Bold().LineHeight(1.1f);
                    });

                // ── Body ─────────────────────────────────────────────────────────────────
                if (isHorizontal)
                {
                    // Horizontal: foto | datos | QR distribuidos lado a lado
                    col.Item().Height(bodyHeightMm, Unit.Millimetre)
                        .Padding(paddingMm, Unit.Millimetre).PaddingTop(2f, Unit.Millimetre)
                        .Row(r =>
                        {
                            if (settings.ShowPhoto)
                            {
                                var photoBlock = r.ConstantItem(photoWMm, Unit.Millimetre)
                                    .Height(photoHMm, Unit.Millimetre)
                                    .Border(1).BorderColor(ParseColor(settings.PrimaryColor))
                                    .Padding(2f, Unit.Millimetre);
                                if (photoBytes != null && photoBytes.Length > 0)
                                    photoBlock.AlignCenter().AlignMiddle().Image(photoBytes);
                                else
                                    photoBlock.AlignCenter().AlignMiddle().Text("FOTO").FontSize(6).FontColor(ParseColor(settings.TextColor));
                                r.ConstantItem(spacerMm, Unit.Millimetre);
                            }

                            r.RelativeItem().Column(c2 =>
                            {
                                c2.Item().Text(dto.FullName).FontSize(8).Bold().FontColor(ParseColor(settings.TextColor));
                                c2.Item().Text($"Carnet: {dto.CardNumber}").FontSize(6).FontColor(ParseColor(settings.PrimaryColor)).SemiBold();
                                c2.Item().Text($"{dto.Grade} - {dto.Group}").FontSize(6).FontColor(ParseColor(settings.TextColor));
                                c2.Item().Text(dto.Shift).FontSize(5).FontColor(ParseColor(settings.TextColor));
                            });

                            if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                            {
                                var qrBytesH = SafeGenerateQrPng(dto.QrToken);
                                if (qrBytesH != null && qrBytesH.Length > 0)
                                {
                                    r.ConstantItem(spacerMm, Unit.Millimetre);
                                    r.ConstantItem(qrFrontMm, Unit.Millimetre)
                                        .Height(qrFrontMm, Unit.Millimetre)
                                        .AlignCenter().AlignMiddle()
                                        .Image(qrBytesH);
                                }
                            }
                        });
                }
                else
                {
                    // Vertical: foto a la izquierda, datos+QR a la derecha en columna
                    col.Item().Height(bodyHeightMm, Unit.Millimetre)
                        .Padding(paddingMm, Unit.Millimetre).PaddingTop(2f, Unit.Millimetre)
                        .Row(r =>
                        {
                            if (settings.ShowPhoto)
                            {
                                var photoBlock = r.ConstantItem(photoWMm, Unit.Millimetre)
                                    .Height(photoHMm, Unit.Millimetre)
                                    .Border(1).BorderColor(ParseColor(settings.PrimaryColor))
                                    .Padding(2f, Unit.Millimetre);
                                if (photoBytes != null && photoBytes.Length > 0)
                                    photoBlock.AlignCenter().AlignMiddle().Image(photoBytes);
                                else
                                    photoBlock.AlignCenter().AlignMiddle().Text("FOTO").FontSize(6).FontColor(ParseColor(settings.TextColor));
                                r.ConstantItem(spacerMm, Unit.Millimetre);
                            }

                            r.RelativeItem().Column(c2 =>
                            {
                                c2.Item().Text(dto.FullName).FontSize(9).Bold().FontColor(ParseColor(settings.TextColor));
                                c2.Item().Text($"Carnet: {dto.CardNumber}").FontSize(7).FontColor(ParseColor(settings.PrimaryColor)).SemiBold();
                                c2.Item().Text($"{dto.Grade} - {dto.Group}").FontSize(7).FontColor(ParseColor(settings.TextColor));
                                c2.Item().Text(dto.Shift).FontSize(6).FontColor(ParseColor(settings.TextColor));

                                if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                                {
                                    var qrBytesFront = SafeGenerateQrPng(dto.QrToken);
                                    if (qrBytesFront != null && qrBytesFront.Length > 0)
                                    {
                                        c2.Item().PaddingTop(2f, Unit.Millimetre).Row(qrRow =>
                                        {
                                            qrRow.RelativeItem().AlignMiddle()
                                                .Text("Escanea para verificar").FontSize(5)
                                                .FontColor(ParseColor(settings.TextColor));
                                            qrRow.ConstantItem(qrFrontMm, Unit.Millimetre)
                                                .Height(qrFrontMm, Unit.Millimetre)
                                                .Image(qrBytesFront);
                                        });
                                    }
                                }
                            });
                        });
                }

                // ── Footer ───────────────────────────────────────────────────────────────
                col.Item().Height(footerBandMm, Unit.Millimetre)
                    .PaddingHorizontal(paddingMm, Unit.Millimetre)
                    .AlignMiddle()
                    .BorderTop(0.5f).BorderColor(ParseColor("#e5e7eb"))
                    .Text($"Emitido: {DateTime.UtcNow:dd/MM/yyyy}").FontSize(5).FontColor(ParseColor(settings.TextColor));
            });
        });
        return container;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // DISEÑO INSTITUCIONAL VERTICAL — 54×86 mm
    // RenderCarnetInstitutionalVerticalFront + RenderCarnetInstitutionalVerticalBack
    // Activado cuando settings.UseModernLayout == true
    // ══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Frente institucional vertical (54×86 mm) — layout centrado moderno.
    ///
    /// Distribución:
    ///  ┌─────────────────────┐  ← Header     (PrimaryColor, logo centrado + nombre centrado)
    ///  │    [LOGO]           │
    ///  │  Nombre colegio     │
    ///  ├─────────────────────┤  ← Foto centrada (22–24 mm con borde)
    ///  │       [FOTO]        │
    ///  ├─────────────────────┤  ← Datos centrados
    ///  │  Nombre completo    │
    ///  │  Jornada            │
    ///  │  Cédula (cond.)     │
    ///  │  Grado · Grupo      │
    ///  │  Año lectivo (cond.)│
    ///  ├─────────────────────┤  ← Badge póliza (cond., #F0F4FF)
    ///  │  Póliza de Seguro   │
    ///  │  POL-XXXXX          │
    ///  ├─────────────────────┤  ← QR abajo-derecha + ID centrado
    ///  │             [QR]    │
    ///  │   ID: XXXXXX        │
    ///  └─────────────────────┘  ← Footer 6 mm (PrimaryColor, fecha)
    /// </summary>
    private IContainer RenderCarnetInstitutionalVerticalFront(
        IContainer container,
        string schoolName,
        byte[]? logoBytes,
        byte[]? secondaryLogoBytes,
        byte[]? photoBytes,
        StudentCardRenderDto dto,
        SchoolIdCardSetting settings,
        byte[]? watermarkBytes = null)
    {
        // ══════════════════════════════════════════════════════════════════════
        // HEIGHT BUDGET ESTRICTO — card 54×86mm — NUNCA genera hoja 2
        //
        //  Zona 1  Header      22.0mm  (fijo — logo 11mm + nombre 8.5pt)
        //  Zona 2  Foto        27.0mm  (fijo = 3mm pad + 24mm foto ≈100px)
        //  Zona 3  Datos       12.0mm  (fijo)
        //  Zona 4  Spacer       var    (Extend() absorbe variación ≈7mm)
        //  Zona 5  Bloque inf  18.0mm  (fijo — policy+ID izq, QR der, #E6EEF7)
        //  ─────────────────────────────
        //  Total fijo: 79mm + spacer 7mm = 86mm ✓
        //
        // MaxLines en todos los textos dinámicos → sin overflow de texto.
        // ══════════════════════════════════════════════════════════════════════
        const float cardW      = 54f;
        const float hPad       = 2f;
        const float logoH      = 11f;   // logo dentro del header (22mm)
        const float photoMm    = 24f;   // zona 2 = 3mm pad + 24mm foto (≈100px preview)
        const float qrBlockMm  = 15f;   // QR en bloque inferior (≈58px preview = 14.9mm)
        const float wmPct      = 0.45f;

        var primary = ParseColor(settings.PrimaryColor);
        var textCol = ParseColor(settings.TextColor);

        // Truncados en C# para garantizar 1 sola línea sin depender de MaxLines
        var nameDisplay  = TruncateText(dto.FullName,  36);
        var gradeDisplay = TruncateText($"Grado: {dto.Grade}", 30);
        var yearDisplay  = TruncateText($"Año: {dto.AcademicYear}", 22);
        var cedDisplay   = TruncateText($"Cédula: {dto.DocumentId}", 26);
        var schoolDisp   = TruncateText(schoolName, 50); // 2 líneas posibles

        // ShowEntire: QuestPDF trata el carnet como una sola unidad — nunca lo parte
        container.ShowEntire().Layers(layers =>
        {
            // ── Capa 0: fondo sólido ──────────────────────────────────────────
            layers.Layer().Background(ParseColor(settings.BackgroundColor));

            // ── Capa 1: watermark centrado ────────────────────────────────────
            if (watermarkBytes != null && watermarkBytes.Length > 0)
                layers.Layer()
                    .AlignCenter().AlignMiddle()
                    .Width(cardW * wmPct, Unit.Millimetre)
                    .Height(cardW * wmPct, Unit.Millimetre)
                    .Image(watermarkBytes);

            // ── Capa principal — Width+Height+ShowEntire → budget estricto ────
            layers.PrimaryLayer()
                .Width(54f, Unit.Millimetre)
                .Height(86f, Unit.Millimetre)
                .ShowEntire()
                .Column(col =>
            {
                // ════════════════════════════════════════════════════════════════
                // ZONA 1 — HEADER (19mm FIJO)
                // Logo centrado arriba, nombre colegio centrado debajo
                // ════════════════════════════════════════════════════════════════
                col.Item()
                    .Height(22f, Unit.Millimetre)
                    .Background(primary)
                    .PaddingTop(1.5f, Unit.Millimetre)
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .PaddingBottom(1f, Unit.Millimetre)
                    .Column(hdr =>
                    {
                        if (logoBytes != null && logoBytes.Length > 0)
                        {
                            hdr.Item().AlignCenter()
                                .Width(logoH, Unit.Millimetre)
                                .Height(logoH, Unit.Millimetre)
                                .Image(logoBytes).FitArea();
                            hdr.Item().Height(0.5f, Unit.Millimetre);
                        }
                        hdr.Item().AlignCenter()
                            .Text(schoolDisp)
                            .FontSize(8.5f).Bold().FontColor(Colors.White).LineHeight(1.2f);

                        if (settings.ShowSecondaryLogo && secondaryLogoBytes != null && secondaryLogoBytes.Length > 0)
                        {
                            hdr.Item().Height(0.5f, Unit.Millimetre);
                            hdr.Item().AlignCenter()
                                .Width(5.5f, Unit.Millimetre)
                                .Height(5.5f, Unit.Millimetre)
                                .Image(secondaryLogoBytes).FitArea();
                        }
                    });

                // ════════════════════════════════════════════════════════════════
                // ZONA 2 — FOTO (27mm FIJO = 3mm pad + 24mm foto ≈ 100px preview)
                // ════════════════════════════════════════════════════════════════
                col.Item()
                    .Height(27f, Unit.Millimetre)
                    .PaddingTop(3f, Unit.Millimetre)
                    .AlignCenter()
                    .Element(slot =>
                    {
                        if (settings.ShowPhoto)
                        {
                            var ps = slot
                                .Width(photoMm, Unit.Millimetre)
                                .Height(photoMm, Unit.Millimetre)
                                .Border(0.3f).BorderColor(primary);
                            if (photoBytes != null && photoBytes.Length > 0)
                                ps.Image(photoBytes).FitArea();
                            else
                                ps.AlignCenter().AlignMiddle()
                                    .Text("FOTO").FontSize(6f).FontColor(textCol);
                        }
                    });

                // ════════════════════════════════════════════════════════════════
                // ZONA 3 — DATOS (12mm FIJO)
                // Textos truncados en C# → sin riesgo de wrap imprevisto
                // ════════════════════════════════════════════════════════════════
                col.Item()
                    .Height(12f, Unit.Millimetre)
                    .PaddingTop(1.5f, Unit.Millimetre)
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .Column(info =>
                    {
                        info.Item().AlignCenter()
                            .Text(nameDisplay)
                            .FontSize(9f).Bold().FontColor(textCol).LineHeight(1.15f);

                        if (settings.ShowDocumentId && !string.IsNullOrWhiteSpace(dto.DocumentId))
                            info.Item().AlignCenter().PaddingTop(0.3f, Unit.Millimetre)
                                .Text(cedDisplay)
                                .FontSize(6.5f).FontColor(textCol);

                        info.Item().AlignCenter().PaddingTop(0.3f, Unit.Millimetre)
                            .Text(gradeDisplay)
                            .FontSize(6.5f).FontColor(textCol);

                        if (settings.ShowAcademicYear && !string.IsNullOrWhiteSpace(dto.AcademicYear))
                            info.Item().AlignCenter().PaddingTop(0.3f, Unit.Millimetre)
                                .Text(yearDisplay)
                                .FontSize(6.5f).FontColor(textCol);
                    });

                // ════════════════════════════════════════════════════════════════
                // ZONA 4 — SPACER DINÁMICO (≈10mm)
                // Absorbe toda la variación de altura: NUNCA falla el budget
                // ════════════════════════════════════════════════════════════════
                col.Item().Extend();

                // ════════════════════════════════════════════════════════════════
                // ZONA 5 — BLOQUE INFERIOR UNIFICADO (18mm FIJO)
                // Idéntico al preview: #E6EEF7, policy+ID izquierda, QR derecha
                // ════════════════════════════════════════════════════════════════
                {
                    byte[]? qrBytes = (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                        ? SafeGenerateQrPng(dto.QrToken)
                        : null;

                    col.Item()
                        .Height(18f, Unit.Millimetre)
                        .Background("#E6EEF7")
                        .PaddingHorizontal(hPad, Unit.Millimetre)
                        .PaddingVertical(2f, Unit.Millimetre)
                        .Row(r =>
                        {
                            // Izquierda: Póliza (condicional) + ID
                            r.RelativeItem().Column(left =>
                            {
                                if (settings.ShowPolicyNumber && !string.IsNullOrWhiteSpace(dto.PolicyNumber))
                                {
                                    left.Item()
                                        .Text("Póliza de Seguro Educativo")
                                        .FontSize(5.5f).Bold().FontColor(primary);
                                    left.Item().PaddingTop(0.5f, Unit.Millimetre)
                                        .Text(TruncateText(dto.PolicyNumber, 28))
                                        .FontSize(5f).FontColor(textCol);
                                    left.Item().Height(1.5f, Unit.Millimetre);
                                }
                                left.Item()
                                    .Text(TruncateText($"ID: {dto.CardNumber}", 22))
                                    .FontSize(7f).Bold().FontColor(textCol);
                            });

                            // Derecha: QR fijo
                            if (qrBytes != null && qrBytes.Length > 0)
                                r.ConstantItem(qrBlockMm, Unit.Millimetre)
                                    .Height(qrBlockMm, Unit.Millimetre)
                                    .AlignMiddle()
                                    .Image(qrBytes).FitArea();
                        });
                }
            });
        });

        return container;
    }

    /// <summary>
    /// Trunca texto al máximo de caracteres especificado. Garantiza que una sola línea
    /// nunca desborde el budget de altura del carnet (alternativa a MaxLines inexistente).
    /// </summary>
    private static string TruncateText(string? text, int maxChars)
    {
        if (string.IsNullOrEmpty(text)) return string.Empty;
        return text.Length <= maxChars ? text : text[..(maxChars - 1)] + "…";
    }

    private IContainer RenderCarnetInstitutionalVerticalBack(
        IContainer container,
        string schoolName,
        string? schoolPhone,
        string? idCardPolicy,
        StudentCardRenderDto dto,
        SchoolIdCardSetting settings,
        byte[]? watermarkBytes = null)
    {
        const float hPad    = 2.1f;  // 8px * 0.2571
        const float vPad    = 1f;
        const float qrMm    = 19.5f; // 76px * 0.2571 mm/px
        const float footerH = 6f;
        const float wmPct   = 0.45f;
        const float cardW   = 54f;

        var primary = ParseColor(settings.PrimaryColor);
        var textCol = ParseColor(settings.TextColor);

        // ShowEntire: el reverso es una sola unidad — nunca se parte
        container.ShowEntire().Layers(layers =>
        {
            layers.Layer().Background(ParseColor(settings.BackgroundColor));

            if (watermarkBytes != null && watermarkBytes.Length > 0)
                layers.Layer()
                    .AlignCenter().AlignMiddle()
                    .Width(cardW * wmPct, Unit.Millimetre)
                    .Height(cardW * wmPct, Unit.Millimetre)
                    .Image(watermarkBytes);

            layers.PrimaryLayer()
                .Width(54f, Unit.Millimetre)
                .Height(86f, Unit.Millimetre)
                .ShowEntire()
                .Column(col =>
            {
                // ── Padding superior + QR centrado (≈ 76px del preview) ──────
                col.Item()
                    .PaddingTop(2.6f, Unit.Millimetre)
                    .AlignCenter()
                    .Width(qrMm, Unit.Millimetre)
                    .Height(qrMm, Unit.Millimetre)
                    .Element(slot =>
                    {
                        if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                        {
                            var qrBytes = SafeGenerateQrPng(dto.QrToken);
                            if (qrBytes != null && qrBytes.Length > 0)
                                slot.Image(qrBytes).FitArea();
                        }
                    });

                // ── Nombre de la escuela 9pt bold ─────────────────────────────
                col.Item()
                    .PaddingTop(vPad, Unit.Millimetre)
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .AlignCenter()
                    .Text(TruncateText(schoolName, 50))
                    .FontSize(9f).Bold().FontColor(textCol).LineHeight(1.1f);

                // ── Instrucción de escaneo ─────────────────────────────────────
                col.Item()
                    .PaddingTop(vPad, Unit.Millimetre)
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .AlignCenter()
                    .Text("Escanea el código QR para verificar la información del carnet")
                    .FontSize(7f).FontColor(textCol).LineHeight(1.2f);

                // ── Número de carnet ───────────────────────────────────────────
                col.Item()
                    .PaddingTop(vPad, Unit.Millimetre)
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .AlignCenter()
                    .Text($"Carnet: {dto.CardNumber}")
                    .FontSize(7f).SemiBold().FontColor(textCol);

                // ── Política del colegio (6.5pt, max 150 chars) ───────────────
                if (!string.IsNullOrWhiteSpace(idCardPolicy))
                {
                    const int maxPolicyChars = 150;
                    var policyTrimmed = idCardPolicy.Trim();
                    var policyText = policyTrimmed.Length > maxPolicyChars
                        ? policyTrimmed[..(maxPolicyChars - 3)] + "..."
                        : policyTrimmed;
                    col.Item()
                        .PaddingTop(vPad, Unit.Millimetre)
                        .PaddingHorizontal(hPad, Unit.Millimetre)
                        .AlignCenter()
                        .Text(policyText)
                        .FontSize(6.5f).FontColor(textCol).LineHeight(1.35f);
                }

                // ── Teléfono del colegio ───────────────────────────────────────
                if (settings.ShowSchoolPhone && !string.IsNullOrWhiteSpace(schoolPhone))
                    col.Item()
                        .PaddingTop(vPad, Unit.Millimetre)
                        .PaddingHorizontal(hPad, Unit.Millimetre)
                        .AlignCenter()
                        .Text($"Tel. colegio: {schoolPhone}")
                        .FontSize(7f).FontColor(textCol);

                // ── Contacto de emergencia ─────────────────────────────────────
                if (settings.ShowEmergencyContact &&
                    (!string.IsNullOrWhiteSpace(dto.EmergencyContactName) ||
                     !string.IsNullOrWhiteSpace(dto.EmergencyContactPhone)))
                {
                    col.Item()
                        .PaddingTop(vPad, Unit.Millimetre)
                        .PaddingHorizontal(hPad, Unit.Millimetre)
                        .AlignCenter()
                        .Text($"Contacto emergencia: {dto.EmergencyContactName ?? "—"}")
                        .FontSize(7f).FontColor(textCol);
                    if (!string.IsNullOrWhiteSpace(dto.EmergencyContactPhone))
                        col.Item()
                            .PaddingHorizontal(hPad, Unit.Millimetre)
                            .AlignCenter()
                            .Text($"Tel: {dto.EmergencyContactPhone}")
                            .FontSize(7f).FontColor(textCol);
                }

                // ── Alergias ───────────────────────────────────────────────────
                if (settings.ShowAllergies && !string.IsNullOrWhiteSpace(dto.Allergies))
                {
                    var txt = dto.Allergies.Length > MaxAllergiesCharsOnCard
                        ? dto.Allergies[..(MaxAllergiesCharsOnCard - 3)] + "..."
                        : dto.Allergies;
                    col.Item()
                        .PaddingTop(vPad, Unit.Millimetre)
                        .PaddingHorizontal(hPad, Unit.Millimetre)
                        .AlignCenter()
                        .Text($"Alergias: {txt}")
                        .FontSize(6.5f).FontColor(textCol);
                }

                // ── Spacer ─────────────────────────────────────────────────────
                col.Item().Extend();

                // ── Footer ─────────────────────────────────────────────────────
                col.Item().Height(footerH, Unit.Millimetre)
                    .Background(primary)
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .AlignMiddle().AlignCenter()
                    .Text("Documento de identificación estudiantil")
                    .FontSize(4.5f).FontColor(Colors.White);
            });
        });

        return container;
    }

    /// <summary>
    /// Frente del carnet — diseño MODERNO: watermark, fila de logos, foto circular (clipped), nombre,
    /// grado-grupo, bloque de datos condicionales (cédula, póliza, año lectivo) y QR centrado abajo.
    /// Soporta orientación Vertical y Horizontal. Todas las dimensiones en Unit.Millimetre.
    /// </summary>
    private IContainer RenderCarnetModernFront(IContainer container, string schoolName,
        byte[]? logoBytes, byte[]? secondaryLogoBytes, byte[]? photoBytes,
        StudentCardRenderDto dto, SchoolIdCardSetting settings,
        float cardWidthMm, float cardHeightMm, byte[]? watermarkBytes = null)
    {
        const float paddingMm = 3f;
        const float headerHeightMm = 12f;   // fila logos + nombre colegio
        const float photoSizeMm = 18f;      // foto circular (cuadrado que se verá como círculo con clip)
        const float qrSizeMm = 18f;
        const float footerMm = 6f;
        const float spacerMm = 2f;
        const float watermarkPct = 0.40f;
        var wMmWm = cardWidthMm * watermarkPct;

        container.Layers(layers =>
        {
            // Capa 1: fondo sólido
            layers.Layer().Background(ParseColor(settings.BackgroundColor));

            // Capa 2: marca de agua centrada
            if (watermarkBytes != null && watermarkBytes.Length > 0)
                layers.Layer()
                    .AlignCenter().AlignMiddle()
                    .Width(wMmWm, Unit.Millimetre)
                    .Height(wMmWm, Unit.Millimetre)
                    .Image(watermarkBytes);

            // Capa principal
            layers.PrimaryLayer().Column(col =>
            {
                // ── Header: barra de color con logos y nombre ─────────────────────
                col.Item().Height(headerHeightMm, Unit.Millimetre)
                    .Background(ParseColor(settings.PrimaryColor))
                    .PaddingHorizontal(paddingMm, Unit.Millimetre)
                    .PaddingVertical(1.5f, Unit.Millimetre)
                    .Row(r =>
                    {
                        // Logo principal (izquierda)
                        if (logoBytes != null)
                        {
                            r.ConstantItem(9f, Unit.Millimetre)
                                .Height(8f, Unit.Millimetre)
                                .AlignLeft().AlignMiddle()
                                .Image(logoBytes);
                            r.ConstantItem(spacerMm, Unit.Millimetre);
                        }

                        // Nombre del colegio (centro, crece)
                        r.RelativeItem().AlignLeft().AlignMiddle()
                            .Text(schoolName)
                            .FontSize(6f).Bold().FontColor(Colors.White).LineHeight(1.1f);

                        // Insignia secundaria (derecha, condicional)
                        if (settings.ShowSecondaryLogo && secondaryLogoBytes != null)
                        {
                            r.ConstantItem(spacerMm, Unit.Millimetre);
                            r.ConstantItem(9f, Unit.Millimetre)
                                .Height(8f, Unit.Millimetre)
                                .AlignRight().AlignMiddle()
                                .Image(secondaryLogoBytes);
                        }
                    });

                // ── Body ─────────────────────────────────────────────────────────
                var bodyMm = cardHeightMm - headerHeightMm - footerMm;
                col.Item().Height(bodyMm, Unit.Millimetre)
                    .Padding(paddingMm, Unit.Millimetre)
                    .Column(body =>
                    {
                        // Fila: foto + datos
                        body.Item().Row(r =>
                        {
                            // Foto (cuadrada — sin clip nativo en QuestPDF, borde redondeado lo simula)
                            if (settings.ShowPhoto)
                            {
                                var photoBlock = r.ConstantItem(photoSizeMm, Unit.Millimetre)
                                    .Height(photoSizeMm, Unit.Millimetre)
                                    .Border(1f).BorderColor(ParseColor(settings.PrimaryColor));
                                if (photoBytes != null && photoBytes.Length > 0)
                                    photoBlock.Image(photoBytes);
                                else
                                    photoBlock.AlignCenter().AlignMiddle()
                                        .Text("FOTO").FontSize(5f).FontColor(ParseColor(settings.TextColor));
                                r.ConstantItem(spacerMm, Unit.Millimetre);
                            }

                            // Columna de datos del estudiante
                            r.RelativeItem().Column(info =>
                            {
                                info.Item().Text(dto.FullName)
                                    .FontSize(8f).Bold().FontColor(ParseColor(settings.TextColor)).LineHeight(1.1f);
                                info.Item().Text($"{dto.Grade} · {dto.Group}")
                                    .FontSize(6f).FontColor(ParseColor(settings.PrimaryColor)).SemiBold();
                                info.Item().Text($"Carnet: {dto.CardNumber}")
                                    .FontSize(5.5f).FontColor(ParseColor(settings.TextColor));

                                // Bloque condicional: cédula, póliza, año lectivo
                                if (settings.ShowDocumentId && !string.IsNullOrWhiteSpace(dto.DocumentId))
                                    info.Item().Text($"Cédula: {dto.DocumentId}")
                                        .FontSize(5.5f).FontColor(ParseColor(settings.TextColor));

                                if (settings.ShowPolicyNumber && !string.IsNullOrWhiteSpace(dto.PolicyNumber))
                                    info.Item().Text($"Póliza: {dto.PolicyNumber}")
                                        .FontSize(5.5f).FontColor(ParseColor(settings.TextColor));

                                if (settings.ShowAcademicYear)
                                    info.Item().Text($"Año: {dto.AcademicYear ?? "N/A"}")
                                        .FontSize(5.5f).FontColor(ParseColor(settings.TextColor));
                            });
                        });

                        // QR centrado debajo (condicional)
                        if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                        {
                            var qrBytes = SafeGenerateQrPng(dto.QrToken);
                            if (qrBytes != null && qrBytes.Length > 0)
                            {
                                var qrAvailMm = bodyMm - photoSizeMm - paddingMm * 2f - 2f;
                                var qrActualMm = Math.Max(12f, Math.Min(qrSizeMm, qrAvailMm));
                                body.Item().PaddingTop(spacerMm, Unit.Millimetre).AlignCenter()
                                    .Width(qrActualMm, Unit.Millimetre)
                                    .Height(qrActualMm, Unit.Millimetre)
                                    .Image(qrBytes);
                            }
                        }
                    });

                // ── Footer ───────────────────────────────────────────────────────
                col.Item().Height(footerMm, Unit.Millimetre)
                    .PaddingHorizontal(paddingMm, Unit.Millimetre)
                    .AlignMiddle()
                    .BorderTop(0.5f).BorderColor(ParseColor("#e5e7eb"))
                    .Text($"Emitido: {DateTime.UtcNow:dd/MM/yyyy}")
                    .FontSize(4.5f).FontColor(ParseColor(settings.TextColor));
            });
        });

        return container;
    }

    /// <summary>
    /// Reverso del carnet — marca de agua (opcional), QR centrado, política e información de emergencia.
    /// Todas las dimensiones usan Unit.Millimetre para renderizado físicamente correcto.
    /// </summary>
    private IContainer RenderCarnetQrBack(IContainer container, string schoolName, string? schoolPhone,
        string? idCardPolicy, StudentCardRenderDto dto, SchoolIdCardSetting settings, byte[]? watermarkBytes = null)
    {
        const float qrBackSizeMm = 28f;
        const float paddingBackMm = 6f;

        container.Layers(layers =>
        {
            layers.Layer().Background(ParseColor(settings.BackgroundColor));
            if (watermarkBytes != null && watermarkBytes.Length > 0)
            {
                layers.Layer()
                    .Padding(paddingBackMm, Unit.Millimetre)
                    .AlignCenter()
                    .AlignMiddle()
                    .Width(28f, Unit.Millimetre)
                    .Height(28f, Unit.Millimetre)
                    .Image(watermarkBytes);
            }

            layers.PrimaryLayer().Padding(paddingBackMm, Unit.Millimetre).Column(col =>
            {
                if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                {
                    var qrBytes = SafeGenerateQrPng(dto.QrToken);
                    if (qrBytes != null && qrBytes.Length > 0)
                        col.Item().Width(qrBackSizeMm, Unit.Millimetre).Height(qrBackSizeMm, Unit.Millimetre)
                            .AlignCenter().Image(qrBytes);
                }
                col.Item().PaddingTop(3f, Unit.Millimetre).AlignCenter()
                    .Text(schoolName).FontSize(8).Bold().FontColor(ParseColor(settings.TextColor));
                col.Item().AlignCenter()
                    .Text("Escanea el código QR para verificar la información del carnet")
                    .FontSize(6).FontColor(ParseColor(settings.TextColor));
                col.Item().AlignCenter()
                    .Text($"Carnet: {dto.CardNumber}").FontSize(6).FontColor(ParseColor(settings.TextColor));

                if (!string.IsNullOrWhiteSpace(idCardPolicy))
                {
                    col.Item().PaddingTop(2f, Unit.Millimetre).PaddingHorizontal(2f, Unit.Millimetre)
                        .AlignCenter().Text(idCardPolicy.Trim()).FontSize(4).FontColor(ParseColor(settings.TextColor));
                }

                if (settings.ShowSchoolPhone && !string.IsNullOrWhiteSpace(schoolPhone))
                {
                    col.Item().PaddingTop(2f, Unit.Millimetre).AlignCenter()
                        .Text($"Tel. colegio: {schoolPhone}").FontSize(5).FontColor(ParseColor(settings.TextColor));
                }

                if (settings.ShowEmergencyContact &&
                    (!string.IsNullOrWhiteSpace(dto.EmergencyContactName) || !string.IsNullOrWhiteSpace(dto.EmergencyContactPhone)))
                {
                    col.Item().PaddingTop(2f, Unit.Millimetre).AlignCenter()
                        .Text($"Contacto emergencia: {dto.EmergencyContactName ?? "—"}").FontSize(5).FontColor(ParseColor(settings.TextColor));
                    if (!string.IsNullOrWhiteSpace(dto.EmergencyContactPhone))
                        col.Item().AlignCenter()
                            .Text($"Tel: {dto.EmergencyContactPhone}").FontSize(5).FontColor(ParseColor(settings.TextColor));
                }

                if (settings.ShowAllergies && !string.IsNullOrWhiteSpace(dto.Allergies))
                {
                    var allergiesText = dto.Allergies.Length > MaxAllergiesCharsOnCard
                        ? dto.Allergies[..(MaxAllergiesCharsOnCard - 3)] + "..."
                        : dto.Allergies;
                    col.Item().PaddingTop(2f, Unit.Millimetre).AlignCenter()
                        .Text($"Alergias: {allergiesText}").FontSize(5).FontColor(ParseColor(settings.TextColor));
                }
            });
        });
        return container;
    }

    /// <summary>Genera PNG del QR con manejo de errores. Si falla con firma, intenta sin firma para que el QR siempre se muestre.</summary>
    private byte[]? SafeGenerateQrPng(string token)
    {
        if (string.IsNullOrWhiteSpace(token)) return null;
        try
        {
            var bytes = QrHelper.GenerateQrPng(token, _qrSignatureService);
            if (bytes != null && bytes.Length > 0) return bytes;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "[StudentIdCardPdf] Error generando QR con firma (token length={Length}), intentando sin firma", token.Length);
        }
        try
        {
            var bytes = QrHelper.GenerateQrPng(token, null);
            return (bytes != null && bytes.Length > 0) ? bytes : null;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "[StudentIdCardPdf] Error generando QR sin firma");
            return null;
        }
    }

    /// <summary>Genera una versión del logo con opacidad reducida para usar como marca de agua (que se vea bien, sin tapar el contenido).</summary>
    private static byte[]? CreateWatermarkImage(byte[]? logoBytes, float opacity = 0.14f)
    {
        if (logoBytes == null || logoBytes.Length == 0 || opacity <= 0 || opacity >= 1) return null;
        try
        {
            using var data = SKData.CreateCopy(logoBytes);
            using var original = SKImage.FromEncodedData(data);
            if (original == null) return null;
            var info = new SKImageInfo(original.Width, original.Height, SKColorType.Rgba8888, SKAlphaType.Premul);
            using var surface = SKSurface.Create(info);
            if (surface == null) return null;
            using var canvas = surface.Canvas;
            using var paint = new SKPaint
            {
                ColorFilter = SKColorFilter.CreateBlendMode(
                    SKColors.White.WithAlpha((byte)(opacity * 255)),
                    SKBlendMode.DstIn)
            };
            canvas.DrawImage(original, 0, 0, paint);
            using var snapshot = surface.Snapshot();
            using var encoded = snapshot.Encode(SKEncodedImageFormat.Png, 100);
            if (encoded == null) return null;
            using var stream = new MemoryStream();
            encoded.SaveTo(stream);
            return stream.ToArray();
        }
        catch
        {
            return null;
        }
    }

    // BUG-6 fix: manejo de null y colores inválidos
    private static string ParseColor(string? colorHex)
    {
        if (string.IsNullOrWhiteSpace(colorHex)) return "#000000";
        if (colorHex.StartsWith("#")) return colorHex;
        return "#" + colorHex;
    }

    /// <summary>
    /// Descarga segura de imagen con timeout y límite de tamaño (SEG-4 fix).
    /// BUG-4 fix: soporta rutas locales /uploads/... usando WebRootPath.
    /// </summary>
    private async Task<byte[]?> SafeDownloadBytesAsync(string url)
    {
        try
        {
            if (url.StartsWith("http://") || url.StartsWith("https://"))
            {
                // SEG-4 fix: timeout para evitar hang y límite de tamaño
                using var cts = new CancellationTokenSource(ImageDownloadTimeout);
                var bytes = await _http.GetByteArrayAsync(url, cts.Token);
                if (bytes.Length > MaxImageDownloadBytes)
                {
                    _logger.LogWarning("[StudentIdCardPdf] Imagen en {Url} supera el límite de {Max} bytes, se ignora.", url, MaxImageDownloadBytes);
                    return null;
                }
                return bytes;
            }

            if (url.StartsWith("/"))
            {
                // BUG-4 fix: leer desde el sistema de archivos usando WebRootPath
                var fullPath = Path.Combine(
                    _environment.WebRootPath,
                    url.TrimStart('/').Replace('/', Path.DirectorySeparatorChar));

                if (File.Exists(fullPath))
                    return await File.ReadAllBytesAsync(fullPath);

                _logger.LogWarning("[StudentIdCardPdf] Archivo local no encontrado: {Path}", fullPath);
                return null;
            }

            // Bare-filename: logos de colegios guardados como solo nombre de archivo
            // (ej. "07bde5e1-..._IPT.jpg") almacenados en wwwroot/uploads/schools/
            if (!url.Contains('/') && !url.Contains('\\'))
            {
                var schoolsPath = Path.Combine(_environment.WebRootPath, "uploads", "schools",
                    url.Replace('/', Path.DirectorySeparatorChar));
                if (File.Exists(schoolsPath))
                    return await File.ReadAllBytesAsync(schoolsPath);

                // Segundo intento: wwwroot/uploads/ directamente
                var uploadsPath = Path.Combine(_environment.WebRootPath, "uploads",
                    url.Replace('/', Path.DirectorySeparatorChar));
                if (File.Exists(uploadsPath))
                    return await File.ReadAllBytesAsync(uploadsPath);

                _logger.LogWarning("[StudentIdCardPdf] Logo bare-filename no encontrado en uploads/schools/: {File}", url);
                return null;
            }

            return null;
        }
        catch (OperationCanceledException)
        {
            _logger.LogWarning("[StudentIdCardPdf] Timeout descargando imagen: {Url}", url);
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "[StudentIdCardPdf] Error descargando imagen: {Url}", url);
            return null;
        }
    }

    /// <summary>
    /// Construye el DTO de renderizado asegurando que existan carnet y token activos.
    /// CONC-2 fix: transacción serializable para evitar creación simultánea de duplicados.
    /// LÓGICA-3 fix: token usa la misma constante QrTokenValidityMonths que GenerateAsync.
    /// LÓGICA-5 fix: usa CardNumberHelper centralizado.
    /// </summary>
    private async Task<StudentCardRenderDto> BuildStudentCardDtoAsync(Guid studentId, Guid createdBy, string schoolName)
    {
        _logger.LogInformation("[StudentIdCardPdf] BuildStudentCardDtoAsync StudentId={StudentId}", studentId);

        var student = await _context.Users
            .Include(u => u.StudentAssignments)
                .ThenInclude(a => a.Grade)
            .Include(u => u.StudentAssignments)
                .ThenInclude(a => a.Group)
            .Include(u => u.StudentAssignments)
                .ThenInclude(a => a.Shift)
            .Include(u => u.StudentAssignments)
                .ThenInclude(a => a.AcademicYear)
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == studentId);

        if (student == null)
        {
            _logger.LogWarning("[StudentIdCardPdf] Estudiante no encontrado StudentId={StudentId}", studentId);
            throw new Exception("Estudiante no encontrado.");
        }

        var assignment = student.StudentAssignments.FirstOrDefault(a => a.IsActive);
        if (assignment == null)
        {
            _logger.LogWarning("[StudentIdCardPdf] Estudiante sin asignación activa StudentId={StudentId}", studentId);
            throw new Exception("El estudiante no tiene asignación activa.");
        }

        // PAY-GATE: no generar PDF sin pago confirmado (última línea de defensa)
        var payment = await _context.StudentPaymentAccesses
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.StudentId == studentId);

        if (payment == null || payment.CarnetStatus != "Pagado")
        {
            _logger.LogWarning(
                "[StudentIdCardPdf] BuildStudentCardDtoAsync denegado: CarnetStatus={Status} StudentId={StudentId}",
                payment?.CarnetStatus ?? "sin registro", studentId);
            throw new Exception("El estudiante no ha pagado el carnet.");
        }

        // CONC-2 fix: transacción serializable — previene creación simultánea de carnets duplicados
        using var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var card = await _context.StudentIdCards
                .FirstOrDefaultAsync(c => c.StudentId == studentId && c.Status == "active");

            if (card == null)
            {
                var newCardNumber = CardNumberHelper.Generate(studentId);
                _logger.LogInformation(
                    "[StudentIdCardPdf] Creando carnet nuevo CardNumber={CardNumber} StudentId={StudentId}",
                    newCardNumber, studentId);
                card = new StudentIdCard
                {
                    StudentId = studentId,
                    CardNumber = newCardNumber,
                    IssuedAt = DateTime.UtcNow,
                    ExpiresAt = DateTime.UtcNow.AddYears(1),
                    Status = "active"
                };
                _context.StudentIdCards.Add(card);
            }
            else
            {
                _logger.LogInformation(
                    "[StudentIdCardPdf] Usando carnet existente CardNumber={CardNumber} StudentId={StudentId}",
                    card.CardNumber, studentId);
            }

            // Buscar token activo; si no existe, crear uno nuevo
            // LÓGICA-3 fix: usar la misma constante de validez que GenerateAsync (6 meses)
            // LÓGICA-6 fix: formato GUID sin guiones ("N") — consistente con GenerateAsync
            var token = await _context.StudentQrTokens
                .FirstOrDefaultAsync(t => t.StudentId == studentId && !t.IsRevoked &&
                    (t.ExpiresAt == null || t.ExpiresAt > DateTime.UtcNow));

            if (token == null)
            {
                token = new StudentQrToken
                {
                    StudentId = studentId,
                    Token = Guid.NewGuid().ToString("N"),
                    ExpiresAt = DateTime.UtcNow.AddMonths(StudentIdCardService.QrTokenValidityMonths),
                    IsRevoked = false
                };
                _context.StudentQrTokens.Add(token);
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            return new StudentCardRenderDto
            {
                StudentId = studentId,
                FullName = $"{student.Name} {student.LastName}",
                DocumentId = student.DocumentId,
                Grade = assignment.Grade?.Name ?? "",
                Group = assignment.Group?.Name ?? "",
                Shift = assignment.Shift?.Name ?? "",
                CardNumber = card.CardNumber,
                QrToken = token.Token,
                PhotoUrl = student.PhotoUrl,
                Allergies = student.Allergies,
                EmergencyContactName = student.EmergencyContactName,
                EmergencyContactPhone = student.EmergencyContactPhone,
                EmergencyRelationship = student.EmergencyRelationship,
                // Campos del layout moderno — PolicyNumber se sobreescribe con school.PolicyNumber en GenerateCardPdfAsync
                PolicyNumber = null,
                AcademicYear = assignment.AcademicYear?.Name ?? null,
                SecondaryLogoUrl = null // Se sobreescribe en GenerateCardPdfAsync desde settings
            };
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    private class StudentCardRenderDto
    {
        public Guid StudentId { get; set; }
        public string FullName { get; set; } = "";
        public string? DocumentId { get; set; }
        public string Grade { get; set; } = "";
        public string Group { get; set; } = "";
        public string Shift { get; set; } = "";
        public string CardNumber { get; set; } = "";
        public string QrToken { get; set; } = "";
        public string? PhotoUrl { get; set; }
        public string? Allergies { get; set; }
        public string? EmergencyContactName { get; set; }
        public string? EmergencyContactPhone { get; set; }
        public string? EmergencyRelationship { get; set; }
        // ── Campos del layout moderno ────────────────────────────────────────
        /// <summary>
        /// Número de póliza TEMPORAL — derivado del studentId mientras no exista columna en BD.
        /// Fácil de reemplazar: buscar "POL-TEMPORAL" en este archivo para localizar el punto de origen.
        /// </summary>
        public string? PolicyNumber { get; set; }
        /// <summary>Año lectivo activo del estudiante (ej. "2024-2025"). Null si AcademicYearId no está asignado.</summary>
        public string? AcademicYear { get; set; }
        /// <summary>URL o path de la insignia secundaria (escudo, sello). Distinto al logo principal de la escuela.</summary>
        public string? SecondaryLogoUrl { get; set; }
    }
}
