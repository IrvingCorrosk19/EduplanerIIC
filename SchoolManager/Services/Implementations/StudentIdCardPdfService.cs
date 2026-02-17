using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Helpers;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public class StudentIdCardPdfService : IStudentIdCardPdfService
{
    private readonly SchoolDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly IFileStorageService _fileStorage;
    private readonly HttpClient _http;
    private readonly ILogger<StudentIdCardPdfService> _logger;

    public StudentIdCardPdfService(
        SchoolDbContext context,
        ICurrentUserService currentUserService,
        IFileStorageService fileStorage,
        IHttpClientFactory httpClientFactory,
        ILogger<StudentIdCardPdfService> logger)
    {
        _context = context;
        _currentUserService = currentUserService;
        _fileStorage = fileStorage;
        _http = httpClientFactory.CreateClient();
        _logger = logger;
    }

    /// <summary>Genera un número de carnet único (evita duplicados con carnets revocados).</summary>
    private static string GenerateUniqueCardNumber(Guid studentId)
    {
        return $"SM-{DateTime.UtcNow:yyyyMMdd}-{studentId.ToString("N")[..8].ToUpper()}-{Guid.NewGuid().ToString("N")[..6].ToUpper()}";
    }

    public async Task<byte[]> GenerateCardPdfAsync(Guid studentId, Guid createdBy)
    {
        try
        {
        _logger.LogInformation("[StudentIdCardPdf] GenerateCardPdfAsync inicio StudentId={StudentId} CreatedBy={CreatedBy}", studentId, createdBy);

        // 1) Datos escuela (multi-escuela correcto)
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null)
        {
            _logger.LogWarning("[StudentIdCardPdf] No se pudo determinar la escuela del usuario actual");
            throw new Exception("No se pudo determinar la escuela del usuario actual.");
        }

        // 2) Settings de carnet
        var settings = await _context.Set<SchoolIdCardSetting>()
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.SchoolId == school.Id);

        settings ??= new SchoolIdCardSetting
        {
            SchoolId = school.Id,
            TemplateKey = "default_v1",
            PageWidthMm = 54,
            PageHeightMm = 86,
            BackgroundColor = "#FFFFFF",
            PrimaryColor = "#0D6EFD",
            TextColor = "#111111",
            ShowQr = true,
            ShowPhoto = true
        };

        // 3) Campos configurables
        var fields = await _context.Set<IdCardTemplateField>()
            .AsNoTracking()
            .Where(x => x.SchoolId == school.Id && x.IsEnabled)
            .ToListAsync();

        // 4) Asegurar carnet + token
        var dto = await BuildStudentCardDtoAsync(studentId, createdBy, school.Name);

        // 5) Logo y foto del estudiante (solo URL en BD; archivo vía almacenamiento)
        byte[]? logoBytes = null;
        if (!string.IsNullOrWhiteSpace(school.LogoUrl))
            logoBytes = await SafeDownloadBytesAsync(school.LogoUrl);

        byte[]? photoBytes = null;
        if (settings.ShowPhoto && !string.IsNullOrWhiteSpace(dto.PhotoUrl))
            photoBytes = await _fileStorage.GetUserPhotoBytesAsync(dto.PhotoUrl);

        // 6) Generar PDF - Diseño referencia: CarnetQR Platform (horizontal 85.6x54 mm, header, cuerpo foto+info, reverso con QR)
        QuestPDF.Settings.License = LicenseType.Community;

        var pdf = Document.Create(container =>
        {
            if (fields.Any())
            {
                // Con campos personalizados: usar tamaño de settings y layout por posiciones
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
                // Layout estilo CarnetQR: frente (header + cuerpo + footer) y reverso con QR
                container.Page(page =>
                {
                    page.Size(CardWidthMm, CardHeightMm, Unit.Millimetre);
                    page.Margin(0);
                    page.Content().Element(c => RenderCarnetQrFront(c, school.Name, logoBytes, photoBytes, dto, settings));
                });

                if (settings.ShowQr)
                {
                    container.Page(page =>
                    {
                        page.Size(CardWidthMm, CardHeightMm, Unit.Millimetre);
                        page.Margin(0);
                        page.Content().Element(c => RenderCarnetQrBack(c, school.Name, dto, settings));
                    });
                }
            }
        }).GeneratePdf();

        _logger.LogInformation("[StudentIdCardPdf] GenerateCardPdfAsync OK StudentId={StudentId} SchoolId={SchoolId}", studentId, school.Id);
        return pdf;
        }
        catch (Exception ex)
    {
        _logger.LogError(ex, "[StudentIdCardPdf] GenerateCardPdfAsync error StudentId={StudentId}: {Message}", studentId, ex.Message);
        throw;
    }
    }

    private IContainer RenderField(IContainer container, IdCardTemplateField f, StudentCardRenderDto dto, string schoolName,
        byte[]? logoBytes, byte[]? photoBytes, SchoolIdCardSetting settings)
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
                    .FontSize((float)f.FontSize)
                    .FontColor(Colors.White); // si va sobre barra
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
                if (settings.ShowQr)
                    positioned.Image(QrHelper.GenerateQrPng(dto.QrToken));
                break;
        }
        
        return positioned;
    }

    /// <summary>Frente del carnet - diseño CarnetQR: header (logo + escuela), cuerpo (foto izq + datos), footer.</summary>
    private IContainer RenderCarnetQrFront(IContainer container, string schoolName, byte[]? logoBytes,
        byte[]? photoBytes, StudentCardRenderDto dto, SchoolIdCardSetting settings)
    {
        const float paddingMm = 4f;
        const float headerHeightMm = 10f;
        const float photoW = 22f;
        const float photoH = 28f;
        const float qrSizeMm = 18f;

        container.Layers(layers =>
        {
            layers.Layer().Background(ParseColor(settings.BackgroundColor));

            // Header con color primario (logo + nombre institución)
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

            // Cuerpo: foto a la izquierda, datos a la derecha (como CarnetQR)
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

                    if (settings.ShowQr)
                    {
                        col.Item().PaddingTop(2).Row(qrRow =>
                        {
                            qrRow.RelativeItem().AlignMiddle().Text("Escanea para verificar").FontSize(5).FontColor(ParseColor(settings.TextColor));
                            qrRow.ConstantItem(qrSizeMm).Height(qrSizeMm).Image(QrHelper.GenerateQrPng(dto.QrToken));
                        });
                    }
                });
            });

            // Footer sutil
            layers.Layer().Padding(paddingMm).PaddingTop(CardHeightMm - 8).BorderTop(0.5f).BorderColor(ParseColor("#e5e7eb"))
                .Text($"Emitido: {DateTime.UtcNow:dd/MM/yyyy}").FontSize(5).FontColor(ParseColor(settings.TextColor));
        });
        return container;
    }

    private const float CardWidthMm = 85.6f;
    private const float CardHeightMm = 54f;

    /// <summary>Reverso del carnet - QR centrado e instrucciones (estilo CarnetQR).</summary>
    private IContainer RenderCarnetQrBack(IContainer container, string schoolName, StudentCardRenderDto dto, SchoolIdCardSetting settings)
    {
        const float qrBackSizeMm = 28f;

        container.Background(ParseColor(settings.BackgroundColor)).Padding(6).Column(col =>
        {
            col.Item().Width(qrBackSizeMm, Unit.Millimetre).Height(qrBackSizeMm, Unit.Millimetre).AlignCenter().Image(QrHelper.GenerateQrPng(dto.QrToken));
            col.Item().PaddingTop(3).AlignCenter().Text(schoolName).FontSize(8).Bold().FontColor(ParseColor(settings.TextColor));
            col.Item().AlignCenter().Text("Escanea el código QR para verificar la información del carnet").FontSize(6).FontColor(ParseColor(settings.TextColor));
            col.Item().AlignCenter().Text($"Carnet: {dto.CardNumber}").FontSize(6).FontColor(ParseColor(settings.TextColor));
        });
        return container;
    }

    private string ParseColor(string colorHex)
    {
        // QuestPDF acepta hex directamente, pero asegurémonos del formato
        if (colorHex.StartsWith("#"))
            return colorHex;
        return "#" + colorHex;
    }

    private async Task<byte[]?> SafeDownloadBytesAsync(string url)
    {
        try
        {
            if (url.StartsWith("http://") || url.StartsWith("https://"))
            {
                return await _http.GetByteArrayAsync(url);
            }
            else if (url.StartsWith("/"))
            {
                // Ruta local - necesitarías leer del filesystem
                // Por ahora retornamos null para rutas locales
                return null;
            }
            return null;
        }
        catch
        {
            return null;
        }
    }

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
            _logger.LogWarning("[StudentIdCardPdf] BuildStudentCardDtoAsync estudiante no encontrado StudentId={StudentId}", studentId);
            throw new Exception("Estudiante no encontrado.");
        }

        var assignment = student.StudentAssignments.FirstOrDefault(a => a.IsActive);
        if (assignment == null)
        {
            _logger.LogWarning("[StudentIdCardPdf] BuildStudentCardDtoAsync estudiante sin asignación activa StudentId={StudentId}", studentId);
            throw new Exception("El estudiante no tiene asignación activa.");
        }

        var card = await _context.StudentIdCards
            .FirstOrDefaultAsync(c => c.StudentId == studentId && c.Status == "active");

        if (card == null)
        {
            var newCardNumber = GenerateUniqueCardNumber(studentId);
            _logger.LogInformation("[StudentIdCardPdf] Creando carnet nuevo CardNumber={CardNumber} StudentId={StudentId}", newCardNumber, studentId);
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
            _logger.LogInformation("[StudentIdCardPdf] Usando carnet existente CardNumber={CardNumber} StudentId={StudentId}", card.CardNumber, studentId);
        }

        var token = await _context.StudentQrTokens
            .FirstOrDefaultAsync(t => t.StudentId == studentId && !t.IsRevoked &&
                (t.ExpiresAt == null || t.ExpiresAt > DateTime.UtcNow));

        if (token == null)
        {
            token = new StudentQrToken
            {
                StudentId = studentId,
                Token = Guid.NewGuid().ToString("N"),
                ExpiresAt = DateTime.UtcNow.AddMonths(6),
                IsRevoked = false
            };
            _context.StudentQrTokens.Add(token);
        }

        await _context.SaveChangesAsync();

        return new StudentCardRenderDto
        {
            StudentId = studentId,
            FullName = $"{student.Name} {student.LastName}",
            DocumentId = student.DocumentId,        // si existe
            Grade = assignment.Grade?.Name ?? "",
            Group = assignment.Group?.Name ?? "",
            Shift = assignment.Shift?.Name ?? "",
            CardNumber = card.CardNumber,
            QrToken = token.Token,
            PhotoUrl = student.PhotoUrl
        };
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
    }
}
