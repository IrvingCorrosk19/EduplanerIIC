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
    private readonly ICurrentUserService _currentUserService;
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
        ICurrentUserService currentUserService,
        IFileStorageService fileStorage,
        IHttpClientFactory httpClientFactory,
        ILogger<StudentIdCardPdfService> logger,
        IQrSignatureService qrSignatureService,
        IWebHostEnvironment environment)
    {
        _context = context;
        _currentUserService = currentUserService;
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

            // 1) Datos escuela (multi-escuela correcto)
            var school = await _currentUserService.GetCurrentUserSchoolAsync();
            if (school == null)
            {
                _logger.LogWarning("[StudentIdCardPdf] No se pudo determinar la escuela del usuario actual");
                throw new Exception("No se pudo determinar la escuela del usuario actual.");
            }

            // 2) Settings de carnet — siempre desde BD por school.Id para que la configuración afecte al PDF
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

            // 3) Campos configurables
            var fields = await _context.Set<IdCardTemplateField>()
                .AsNoTracking()
                .Where(x => x.SchoolId == school.Id && x.IsEnabled)
                .ToListAsync();

            // 4) Asegurar carnet + token (con transacción — CONC-2 fix)
            var dto = await BuildStudentCardDtoAsync(studentId, createdBy, school.Name);

            // 5) Logo, marca de agua (logo con opacidad) y foto del estudiante
            byte[]? logoBytes = null;
            if (!string.IsNullOrWhiteSpace(school.LogoUrl))
                logoBytes = await SafeDownloadBytesAsync(school.LogoUrl);
            byte[]? watermarkBytes = (settings.ShowWatermark && logoBytes != null) ? CreateWatermarkImage(logoBytes, 0.14f) : null;

            byte[]? photoBytes = null;
            if (settings.ShowPhoto && !string.IsNullOrWhiteSpace(dto.PhotoUrl))
                photoBytes = await _fileStorage.GetUserPhotoBytesAsync(dto.PhotoUrl);

            // 6) Generar PDF
            QuestPDF.Settings.License = LicenseType.Community;

            var pdf = Document.Create(container =>
            {
                if (fields.Any())
                {
                    // Con campos personalizados: layout por posiciones
                    container.Page(page =>
                    {
                        page.Size(settings.PageWidthMm, settings.PageHeightMm, Unit.Millimetre);
                        page.Margin(0);
                        page.Content().Layers(layers =>
                        {
                            layers.Layer().Background(ParseColor(settings.BackgroundColor));
                            layers.Layer().Unconstrained()
                                .TranslateX(0, Unit.Millimetre).TranslateY(0, Unit.Millimetre)
                                .Width(settings.PageWidthMm, Unit.Millimetre).Height(12, Unit.Millimetre)
                                .Background(ParseColor(settings.PrimaryColor));
                            foreach (var f in fields)
                                layers.Layer().Element(e => RenderField(e, f, dto, school.Name, logoBytes, photoBytes, settings));
                        });
                    });
                }
                else
                {
                    // Layout estilo CarnetQR: dimensiones desde configuración/orientación
                    var (cardWidthMm, cardHeightMm) = GetCardDimensions(settings);
                    container.Page(page =>
                    {
                        page.Size(cardWidthMm, cardHeightMm, Unit.Millimetre);
                        page.Margin(0);
                        page.Content().Element(c => RenderCarnetQrFront(c, school.Name, logoBytes, photoBytes, dto, settings, cardWidthMm, cardHeightMm, watermarkBytes));
                    });

                    if (settings.ShowQr)
                    {
                        container.Page(page =>
                        {
                            page.Size(cardWidthMm, cardHeightMm, Unit.Millimetre);
                            page.Margin(0);
                            page.Content().Element(c => RenderCarnetQrBack(c, school.Name, school.Phone, school.IdCardPolicy, dto, settings, watermarkBytes));
                        });
                    }
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

    /// <summary>Frente del carnet — diseño CarnetQR: marca de agua (logo), header, cuerpo foto+datos, footer.</summary>
    private IContainer RenderCarnetQrFront(IContainer container, string schoolName, byte[]? logoBytes,
        byte[]? photoBytes, StudentCardRenderDto dto, SchoolIdCardSetting settings, float cardWidthMm, float cardHeightMm,
        byte[]? watermarkBytes = null)
    {
        const float paddingMm = 4f;
        const float headerHeightMm = 10f;
        const float photoW = 22f;
        const float photoH = 28f;
        const float qrSizeMm = 18f;
        const float watermarkSizePercent = 0.42f; // tamaño de la marca de agua respecto al ancho del carnet (visible pero discreta)

        container.Layers(layers =>
        {
            layers.Layer().Background(ParseColor(settings.BackgroundColor));

            // Marca de agua: logo del colegio centrado, semi-transparente, que se vea bien sin tapar el contenido
            if (watermarkBytes != null && watermarkBytes.Length > 0)
            {
                var wMm = cardWidthMm * watermarkSizePercent;
                layers.Layer()
                    .AlignCenter()
                    .AlignMiddle()
                    .Width(wMm, Unit.Millimetre)
                    .Height(wMm, Unit.Millimetre)
                    .Image(watermarkBytes);
            }

            // Header con color primario
            layers.Layer().Background(ParseColor(settings.PrimaryColor)).Padding(paddingMm).Height(headerHeightMm).Row(r =>
            {
                if (logoBytes != null)
                {
                    r.ConstantItem(24).Height(8).AlignLeft().AlignMiddle().Image(logoBytes);
                    r.ConstantItem(2);
                }
                r.RelativeItem().AlignLeft().AlignMiddle().Text(schoolName)
                    .FontSize(8).FontColor(Colors.White).Bold();
            });

            // Cuerpo: foto izquierda, datos derecha
            layers.Layer().Padding(paddingMm).PaddingTop(headerHeightMm + 2).Row(r =>
            {
                if (settings.ShowPhoto)
                {
                    var photoBlock = r.ConstantItem(photoW).Height(photoH)
                        .Border(1).BorderColor(ParseColor(settings.PrimaryColor))
                        .Padding(2);
                    if (photoBytes != null && photoBytes.Length > 0)
                        photoBlock.AlignCenter().AlignMiddle().Image(photoBytes);
                    else
                        photoBlock.AlignCenter().AlignMiddle().Text("FOTO").FontSize(6).FontColor(ParseColor(settings.TextColor));
                    r.ConstantItem(3);
                }

                r.RelativeItem().Column(col =>
                {
                    col.Item().Text(dto.FullName).FontSize(9).Bold().FontColor(ParseColor(settings.TextColor));
                    col.Item().Text($"Carnet: {dto.CardNumber}").FontSize(7).FontColor(ParseColor(settings.PrimaryColor)).SemiBold();
                    col.Item().Text($"{dto.Grade} - {dto.Group}").FontSize(7).FontColor(ParseColor(settings.TextColor));
                    col.Item().Text(dto.Shift).FontSize(6).FontColor(ParseColor(settings.TextColor));

                    if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
                    {
                        var qrBytesFront = SafeGenerateQrPng(dto.QrToken);
                        if (qrBytesFront != null && qrBytesFront.Length > 0)
                        {
                            col.Item().PaddingTop(2).Row(qrRow =>
                            {
                                qrRow.RelativeItem().AlignMiddle().Text("Escanea para verificar").FontSize(5).FontColor(ParseColor(settings.TextColor));
                                qrRow.ConstantItem(qrSizeMm).Height(qrSizeMm).Image(qrBytesFront);
                            });
                        }
                    }
                });
            });

            // Footer sutil (usa altura del carnet desde configuración)
            layers.Layer().Padding(paddingMm).PaddingTop(cardHeightMm - 8).BorderTop(0.5f).BorderColor(ParseColor("#e5e7eb"))
                .Text($"Emitido: {DateTime.UtcNow:dd/MM/yyyy}").FontSize(5).FontColor(ParseColor(settings.TextColor));
        });
        return container;
    }

    /// <summary>Reverso del carnet — marca de agua (opcional), QR centrado, política del colegio e información de emergencia.</summary>
    private IContainer RenderCarnetQrBack(IContainer container, string schoolName, string? schoolPhone,
        string? idCardPolicy, StudentCardRenderDto dto, SchoolIdCardSetting settings, byte[]? watermarkBytes = null)
    {
        const float qrBackSizeMm = 28f;

        container.Layers(layers =>
        {
            layers.Layer().Background(ParseColor(settings.BackgroundColor));
            if (watermarkBytes != null && watermarkBytes.Length > 0)
            {
                layers.Layer()
                    .Padding(6)
                    .AlignCenter()
                    .AlignMiddle()
                    .Width(28f, Unit.Millimetre)
                    .Height(28f, Unit.Millimetre)
                    .Image(watermarkBytes);
            }
            layers.Layer().Padding(6).Column(col =>
            {
            // QR: solo si ShowQr y token no vacío (FASE 3 — corrección visualización QR)
            if (settings.ShowQr && !string.IsNullOrWhiteSpace(dto.QrToken))
            {
                var qrBytes = SafeGenerateQrPng(dto.QrToken);
                if (qrBytes != null && qrBytes.Length > 0)
                    col.Item().Width(qrBackSizeMm, Unit.Millimetre).Height(qrBackSizeMm, Unit.Millimetre)
                        .AlignCenter().Image(qrBytes);
            }
            col.Item().PaddingTop(3).AlignCenter().Text(schoolName).FontSize(8).Bold().FontColor(ParseColor(settings.TextColor));
            col.Item().AlignCenter().Text("Escanea el código QR para verificar la información del carnet")
                .FontSize(6).FontColor(ParseColor(settings.TextColor));
            col.Item().AlignCenter().Text($"Carnet: {dto.CardNumber}").FontSize(6).FontColor(ParseColor(settings.TextColor));

            // Política del colegio (FASE 1) — debajo del QR si está configurada
            if (!string.IsNullOrWhiteSpace(idCardPolicy))
            {
                col.Item().PaddingTop(2).PaddingHorizontal(2)
                    .AlignCenter().Text(idCardPolicy.Trim()).FontSize(4).FontColor(ParseColor(settings.TextColor));
            }

            if (settings.ShowSchoolPhone && !string.IsNullOrWhiteSpace(schoolPhone))
            {
                col.Item().PaddingTop(2).AlignCenter()
                    .Text($"Tel. colegio: {schoolPhone}").FontSize(5).FontColor(ParseColor(settings.TextColor));
            }

            if (settings.ShowEmergencyContact &&
                (!string.IsNullOrWhiteSpace(dto.EmergencyContactName) || !string.IsNullOrWhiteSpace(dto.EmergencyContactPhone)))
            {
                col.Item().PaddingTop(2).AlignCenter()
                    .Text($"Contacto emergencia: {dto.EmergencyContactName ?? "—"}").FontSize(5).FontColor(ParseColor(settings.TextColor));
                if (!string.IsNullOrWhiteSpace(dto.EmergencyContactPhone))
                    col.Item().AlignCenter()
                        .Text($"Tel: {dto.EmergencyContactPhone}").FontSize(5).FontColor(ParseColor(settings.TextColor));
            }

            // BUG-3 fix: truncar alergias para evitar desbordamiento del layout del carnet
            if (settings.ShowAllergies && !string.IsNullOrWhiteSpace(dto.Allergies))
            {
                var allergiesText = dto.Allergies.Length > MaxAllergiesCharsOnCard
                    ? dto.Allergies[..( MaxAllergiesCharsOnCard - 3)] + "..."
                    : dto.Allergies;
                col.Item().PaddingTop(2).AlignCenter()
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
                EmergencyRelationship = student.EmergencyRelationship
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
    }
}
