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
                    // CarnetQR / Moderno: una sola hoja A4 con frente y reverso lado a lado.
                    var (cardWidthMm, cardHeightMm) = GetCardDimensions(settings);
                    const float sheetGapMm = 6f;
                    const float sheetMarginMm = 10f;
                    var schoolNamePdf = school.Name;
                    var phonePdf = school.Phone;
                    var policyPdf = school.IdCardPolicy;

                    container.Page(page =>
                    {
                        page.Size(PageSizes.A4);
                        page.Margin(sheetMarginMm, Unit.Millimetre);
                        page.Content().AlignCenter().AlignMiddle().Row(row =>
                        {
                            if (settings.ShowQr)
                                row.Spacing(sheetGapMm, Unit.Millimetre);

                            var isModern = settings.UseModernLayout;
                            var isVertical = cardHeightMm > cardWidthMm; // 86 > 54

                            // ── Frente ───────────────────────────────────────────────────────
                            row.ConstantItem(cardWidthMm, Unit.Millimetre)
                                .Height(cardHeightMm, Unit.Millimetre)
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
    /// Frente institucional vertical (54×86 mm).
    /// Zonas fijas sin Height() rígido interno — usa AutoItem/RelativeItem para evitar overflow.
    ///
    /// Distribución:
    ///  ┌─────────────────────┐  ← Header 16 mm  (PrimaryColor, logo+nombre+insignia)
    ///  │ HEADER              │
    ///  ├─────────────────────┤  ← Datos 30 mm   (foto izq + columna datos der)
    ///  │ FOTO  | Nombre      │
    ///  │       | Cédula      │
    ///  │       | Grado       │
    ///  │       | Año lectivo │
    ///  ├─────────────────────┤  ← Bloque póliza  ≈8 mm  (condicional ShowPolicyNumber)
    ///  │ Póliza / ID         │
    ///  ├─────────────────────┤  ← Zona QR         ≈24 mm (condicional ShowQr)
    ///  │      [QR]           │
    ///  └─────────────────────┘  ← Footer 6 mm   (fecha emisión)
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
        // ── Constantes de layout (todos en mm) ────────────────────────────────
        const float cardW         = 54f;
        const float cardH         = 86f;
        const float headerH       = 16f;
        const float footerH       = 6f;
        const float hPad          = 3f;   // padding horizontal general
        const float vPad          = 2f;   // padding vertical general
        const float photoSize     = 22f;  // foto cuadrada
        const float spacer        = 2f;   // separador entre columnas
        const float policyBlockH  = 9f;   // altura del bloque póliza
        const float wmPct         = 0.45f;

        container.Layers(layers =>
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

            // ── Capa principal ────────────────────────────────────────────────
            layers.PrimaryLayer().Column(col =>
            {
                // ── ZONA 1: Header ────────────────────────────────────────────
                col.Item().Height(headerH, Unit.Millimetre)
                    .Background(ParseColor(settings.PrimaryColor))
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .PaddingVertical(vPad, Unit.Millimetre)
                    .Row(r =>
                    {
                        if (logoBytes != null)
                        {
                            r.ConstantItem(10f, Unit.Millimetre)
                                .Height(10f, Unit.Millimetre)
                                .AlignMiddle().AlignLeft()
                                .Image(logoBytes);
                            r.ConstantItem(spacer, Unit.Millimetre);
                        }

                        r.RelativeItem().AlignMiddle().AlignLeft()
                            .Text(schoolName)
                            .FontSize(6.5f).Bold().FontColor(Colors.White).LineHeight(1.15f);

                        if (settings.ShowSecondaryLogo && secondaryLogoBytes != null)
                        {
                            r.ConstantItem(spacer, Unit.Millimetre);
                            r.ConstantItem(10f, Unit.Millimetre)
                                .Height(10f, Unit.Millimetre)
                                .AlignMiddle().AlignRight()
                                .Image(secondaryLogoBytes);
                        }
                    });

                // ── ZONA 2: Datos del estudiante (foto + columna) ─────────────
                col.Item()
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .PaddingTop(vPad, Unit.Millimetre)
                    .Row(r =>
                    {
                        // Foto
                        if (settings.ShowPhoto)
                        {
                            var photoSlot = r.ConstantItem(photoSize, Unit.Millimetre)
                                .Height(photoSize, Unit.Millimetre)
                                .Border(0.8f)
                                .BorderColor(ParseColor(settings.PrimaryColor));
                            if (photoBytes != null && photoBytes.Length > 0)
                                photoSlot.Image(photoBytes).FitArea();
                            else
                                photoSlot.AlignCenter().AlignMiddle()
                                    .Text("FOTO").FontSize(6f)
                                    .FontColor(ParseColor(settings.TextColor));
                            r.ConstantItem(spacer, Unit.Millimetre);
                        }

                        // Columna de datos
                        r.RelativeItem().Column(info =>
                        {
                            info.Item().Text(dto.FullName)
                                .FontSize(8f).Bold()
                                .FontColor(ParseColor(settings.TextColor))
                                .LineHeight(1.15f);

                            info.Item().PaddingTop(1f, Unit.Millimetre)
                                .Text($"{dto.Grade}  {dto.Group}")
                                .FontSize(6.5f).SemiBold()
                                .FontColor(ParseColor(settings.PrimaryColor));

                            info.Item().Text(dto.Shift)
                                .FontSize(5.5f)
                                .FontColor(ParseColor(settings.TextColor));

                            if (settings.ShowDocumentId && !string.IsNullOrWhiteSpace(dto.DocumentId))
                                info.Item().PaddingTop(0.8f, Unit.Millimetre)
                                    .Text($"Cédula: {dto.DocumentId}")
                                    .FontSize(5.5f)
                                    .FontColor(ParseColor(settings.TextColor));

                            if (settings.ShowAcademicYear)
                                info.Item()
                                    .Text($"Año: {dto.AcademicYear ?? "N/A"}")
                                    .FontSize(5.5f)
                                    .FontColor(ParseColor(settings.TextColor));
                        });
                    });

                // ── ZONA 3: Bloque póliza + número de carnet (condicional) ────
                if (settings.ShowPolicyNumber)
                {
                    col.Item()
                        .PaddingHorizontal(hPad, Unit.Millimetre)
                        .PaddingTop(vPad, Unit.Millimetre)
                        .Height(policyBlockH, Unit.Millimetre)
                        .Background("#F0F4FF")
                        .Padding(2f, Unit.Millimetre)
                        .Column(p =>
                        {
                            p.Item().Text("Póliza de Seguro Educativo")
                                .FontSize(5f).Bold()
                                .FontColor(ParseColor(settings.PrimaryColor));
                            p.Item().Text(dto.PolicyNumber ?? "POLIZA-PENDIENTE-CONFIGURACION")
                                .FontSize(6f).SemiBold()
                                .FontColor(ParseColor(settings.TextColor));
                            p.Item().Text($"ID: {dto.CardNumber}")
                                .FontSize(5f)
                                .FontColor(ParseColor(settings.TextColor));
                        });
                }

                // ── ZONA 4: QR centrado ───────────────────────────────────────
                if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                {
                    var qrBytes = SafeGenerateQrPng(dto.QrToken);
                    if (qrBytes != null && qrBytes.Length > 0)
                    {
                        // Espacio disponible restante: total - header - footer - datos(~30) - póliza
                        var usedMm = headerH + footerH + (settings.ShowPhoto ? photoSize + vPad : 0f)
                                     + (settings.ShowPolicyNumber ? policyBlockH + vPad : 0f) + vPad * 3f;
                        var availMm = cardH - usedMm;
                        var qrMm = Math.Clamp(availMm - 2f, 15f, 22f);

                        col.Item().Extend()
                            .PaddingHorizontal(hPad, Unit.Millimetre)
                            .AlignCenter().AlignMiddle()
                            .Column(q =>
                            {
                                q.Item().AlignCenter()
                                    .Width(qrMm, Unit.Millimetre)
                                    .Height(qrMm, Unit.Millimetre)
                                    .Image(qrBytes);
                                q.Item().AlignCenter().PaddingTop(0.5f, Unit.Millimetre)
                                    .Text("Escanea para verificar")
                                    .FontSize(4.5f)
                                    .FontColor(ParseColor(settings.TextColor));
                            });
                    }
                }
                else
                {
                    // Sin QR: ocupa el espacio restante con el número de carnet
                    col.Item().Extend()
                        .PaddingHorizontal(hPad, Unit.Millimetre)
                        .AlignCenter().AlignMiddle()
                        .Text($"N° {dto.CardNumber}")
                        .FontSize(6f).SemiBold()
                        .FontColor(ParseColor(settings.PrimaryColor));
                }

                // ── ZONA 5: Footer ────────────────────────────────────────────
                col.Item().Height(footerH, Unit.Millimetre)
                    .Background(ParseColor(settings.PrimaryColor))
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .AlignMiddle()
                    .Text($"Emitido: {DateTime.UtcNow:dd/MM/yyyy}")
                    .FontSize(4.5f).FontColor(Colors.White);
            });
        });

        return container;
    }

    /// <summary>
    /// Reverso institucional vertical (54×86 mm).
    /// Zonas: watermark + header, QR grande centrado, bloque validación, datos adicionales opcionales,
    /// política del colegio, footer.
    /// </summary>
    private IContainer RenderCarnetInstitutionalVerticalBack(
        IContainer container,
        string schoolName,
        string? schoolPhone,
        string? idCardPolicy,
        StudentCardRenderDto dto,
        SchoolIdCardSetting settings,
        byte[]? watermarkBytes = null)
    {
        const float hPad     = 4f;
        const float vPad     = 2.5f;
        const float qrMm     = 26f;
        const float headerH  = 10f;
        const float footerH  = 6f;
        const float wmPct    = 0.45f;
        const float cardW    = 54f;

        container.Layers(layers =>
        {
            // ── Capa 0: fondo ─────────────────────────────────────────────────
            layers.Layer().Background(ParseColor(settings.BackgroundColor));

            // ── Capa 1: watermark suave centrado ──────────────────────────────
            if (watermarkBytes != null && watermarkBytes.Length > 0)
                layers.Layer()
                    .AlignCenter().AlignMiddle()
                    .Width(cardW * wmPct, Unit.Millimetre)
                    .Height(cardW * wmPct, Unit.Millimetre)
                    .Image(watermarkBytes);

            // ── Capa principal ────────────────────────────────────────────────
            layers.PrimaryLayer().Column(col =>
            {
                // ── Header simple ─────────────────────────────────────────────
                col.Item().Height(headerH, Unit.Millimetre)
                    .Background(ParseColor(settings.PrimaryColor))
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .AlignMiddle().AlignCenter()
                    .Text(schoolName)
                    .FontSize(7f).Bold().FontColor(Colors.White).LineHeight(1.1f);

                // ── QR grande centrado ────────────────────────────────────────
                if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                {
                    var qrBytes = SafeGenerateQrPng(dto.QrToken);
                    if (qrBytes != null && qrBytes.Length > 0)
                        col.Item()
                            .PaddingTop(vPad, Unit.Millimetre)
                            .AlignCenter()
                            .Width(qrMm, Unit.Millimetre)
                            .Height(qrMm, Unit.Millimetre)
                            .Image(qrBytes);
                }

                // ── Bloque de validación ──────────────────────────────────────
                col.Item()
                    .PaddingTop(vPad, Unit.Millimetre)
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .AlignCenter()
                    .Column(v =>
                    {
                        v.Item().AlignCenter()
                            .Text("Escanea para verificar identidad")
                            .FontSize(5.5f).SemiBold()
                            .FontColor(ParseColor(settings.TextColor));
                        v.Item().AlignCenter()
                            .Text($"ID: {dto.CardNumber}")
                            .FontSize(5.5f)
                            .FontColor(ParseColor(settings.PrimaryColor));
                    });

                // ── Datos opcionales ──────────────────────────────────────────
                col.Item()
                    .PaddingTop(vPad, Unit.Millimetre)
                    .PaddingHorizontal(hPad, Unit.Millimetre)
                    .Column(extra =>
                    {
                        if (settings.ShowSchoolPhone && !string.IsNullOrWhiteSpace(schoolPhone))
                            extra.Item().AlignCenter()
                                .Text($"Tel: {schoolPhone}")
                                .FontSize(5.5f)
                                .FontColor(ParseColor(settings.TextColor));

                        if (settings.ShowEmergencyContact &&
                            !string.IsNullOrWhiteSpace(dto.EmergencyContactName))
                        {
                            extra.Item().PaddingTop(1f, Unit.Millimetre).AlignCenter()
                                .Text($"Emergencia: {dto.EmergencyContactName}")
                                .FontSize(5f)
                                .FontColor(ParseColor(settings.TextColor));
                            if (!string.IsNullOrWhiteSpace(dto.EmergencyContactPhone))
                                extra.Item().AlignCenter()
                                    .Text($"Tel: {dto.EmergencyContactPhone}")
                                    .FontSize(5f)
                                    .FontColor(ParseColor(settings.TextColor));
                        }

                        if (settings.ShowAllergies && !string.IsNullOrWhiteSpace(dto.Allergies))
                        {
                            var txt = dto.Allergies.Length > MaxAllergiesCharsOnCard
                                ? dto.Allergies[..(MaxAllergiesCharsOnCard - 3)] + "..."
                                : dto.Allergies;
                            extra.Item().PaddingTop(1f, Unit.Millimetre).AlignCenter()
                                .Text($"Alergias: {txt}")
                                .FontSize(4.5f)
                                .FontColor(ParseColor(settings.TextColor));
                        }
                    });

                // ── Política del colegio ──────────────────────────────────────
                if (!string.IsNullOrWhiteSpace(idCardPolicy))
                    col.Item()
                        .PaddingTop(vPad, Unit.Millimetre)
                        .PaddingHorizontal(hPad, Unit.Millimetre)
                        .AlignCenter()
                        .Text(idCardPolicy.Trim())
                        .FontSize(4f)
                        .FontColor(ParseColor(settings.TextColor))
                        .LineHeight(1.2f);

                // ── Extend + Footer ───────────────────────────────────────────
                col.Item().Extend();

                col.Item().Height(footerH, Unit.Millimetre)
                    .Background(ParseColor(settings.PrimaryColor))
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
