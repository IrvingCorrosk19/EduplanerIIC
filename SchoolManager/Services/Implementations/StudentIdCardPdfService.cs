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
    private readonly HttpClient _http;

    public StudentIdCardPdfService(
        SchoolDbContext context,
        ICurrentUserService currentUserService,
        IHttpClientFactory httpClientFactory)
    {
        _context = context;
        _currentUserService = currentUserService;
        _http = httpClientFactory.CreateClient();
    }

    public async Task<byte[]> GenerateCardPdfAsync(Guid studentId, Guid createdBy)
    {
        // 1) Datos escuela (multi-escuela correcto)
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null) throw new Exception("No se pudo determinar la escuela del usuario actual.");

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
            ShowPhoto = false // Por ahora false hasta que agreguemos PhotoUrl
        };

        // 3) Campos configurables
        var fields = await _context.Set<IdCardTemplateField>()
            .AsNoTracking()
            .Where(x => x.SchoolId == school.Id && x.IsEnabled)
            .ToListAsync();

        // 4) Asegurar carnet + token
        var dto = await BuildStudentCardDtoAsync(studentId, createdBy, school.Name);

        // 5) Descargar logo/foto (si tienes URL)
        byte[]? logoBytes = null;
        if (!string.IsNullOrWhiteSpace(school.LogoUrl))
            logoBytes = await SafeDownloadBytesAsync(school.LogoUrl);

        byte[]? photoBytes = null; // no existe aún

        // 6) Generar PDF
        QuestPDF.Settings.License = LicenseType.Community;

        var pdf = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(settings.PageWidthMm, settings.PageHeightMm, Unit.Millimetre);
                page.Margin(0);

                page.Content().Layers(layers =>
                {
                    // Fondo
                    layers.Layer().Background(ParseColor(settings.BackgroundColor));

                    // Barra superior con color primario
                    layers.Layer().Unconstrained()
                        .TranslateX(0, Unit.Millimetre)
                        .TranslateY(0, Unit.Millimetre)
                        .Width(settings.PageWidthMm, Unit.Millimetre)
                        .Height(12, Unit.Millimetre)
                        .Background(ParseColor(settings.PrimaryColor));

                    // Render basado en campos configurados (si no hay campos, cae a layout default)
                    if (fields.Any())
                    {
                        foreach (var f in fields)
                            layers.Layer().Element(e => RenderField(e, f, dto, school.Name, logoBytes, photoBytes, settings));
                    }
                    else
                    {
                        // Layout default simple (sirve mientras configuras campos)
                        layers.Layer().Padding(6).Column(col =>
                        {
                            col.Item().Row(r =>
                            {
                                r.RelativeItem().Text(school.Name).FontSize(10).FontColor(Colors.White);
                                if (logoBytes != null)
                                    r.ConstantItem(18).Height(18).Image(logoBytes);
                            });

                            col.Item().PaddingTop(6).Row(r =>
                            {
                                if (settings.ShowPhoto)
                                {
                                    r.ConstantItem(22).Height(28).Border(1).Padding(2).AlignCenter().AlignMiddle().Text("FOTO").FontSize(8);
                                }

                                r.RelativeItem().PaddingLeft(6).Column(info =>
                                {
                                    info.Item().Text(dto.FullName).FontSize(11).Bold().FontColor(ParseColor(settings.TextColor));
                                    info.Item().Text($"{dto.Grade} - {dto.Group}").FontSize(10).FontColor(ParseColor(settings.TextColor));
                                    info.Item().Text(dto.Shift).FontSize(9).FontColor(ParseColor(settings.TextColor));
                                    info.Item().Text(dto.CardNumber).FontSize(8).FontColor(ParseColor(settings.TextColor));
                                });
                            });

                            if (settings.ShowQr)
                            {
                                col.Item().PaddingTop(6).Row(r =>
                                {
                                    r.RelativeItem().Text("Escanee para ver ficha").FontSize(8).FontColor(ParseColor(settings.TextColor));
                                    r.ConstantItem(22).Height(22).Image(QrHelper.GenerateQrPng(dto.QrToken));
                                });
                            }
                        });
                    }
                });
            });
        }).GeneratePdf();

        return pdf;
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
                // No hay fotos aún, se deja vacío o placeholder
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
            throw new Exception("Estudiante no encontrado.");

        var assignment = student.StudentAssignments.FirstOrDefault(a => a.IsActive);
        if (assignment == null)
            throw new Exception("El estudiante no tiene asignación activa.");

        var card = await _context.StudentIdCards
            .FirstOrDefaultAsync(c => c.StudentId == studentId && c.Status == "active");

        if (card == null)
        {
            card = new StudentIdCard
            {
                StudentId = studentId,
                CardNumber = $"SM-{DateTime.UtcNow:yyyyMMdd}-{studentId.ToString()[..8]}",
                IssuedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddYears(1),
                Status = "active"
            };
            _context.StudentIdCards.Add(card);
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
            PhotoUrl = null                         // no hay foto aún
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
