using SkiaSharp;
using SchoolManager.Dtos;
using SchoolManager.Helpers;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.Services.Security;

namespace SchoolManager.Services.Implementations;

/// <summary>
/// Renderiza carnets estudiantiles sobre un canvas SkiaSharp de coordenadas absolutas.
/// PRINCIPIO: esto NO es un documento — es un lienzo de impresión.
/// Sin Column/Row, sin layouts dinámicos, sin conflictos de tamaño. Siempre determinístico.
/// </summary>
public class StudentIdCardImageService : IStudentIdCardImageService
{
    // ── Constantes físicas ID-1 CR80 ──────────────────────────────────────────
    private const float Dpi          = 300f;
    private const float CardWidthMm  = 85.60f;   // lado largo
    private const float CardHeightMm = 53.98f;   // lado corto

    // Landscape canvas (Classic / Modern Horizontal): 1011 × 638 px
    private static readonly int LandW = (int)((CardWidthMm  / 25.4f) * Dpi);  // 1011
    private static readonly int LandH = (int)((CardHeightMm / 25.4f) * Dpi);  // 638

    // Portrait canvas (Institutional Vertical): 638 × 1011 px
    private static readonly int PortW = (int)((CardHeightMm / 25.4f) * Dpi);  // 638
    private static readonly int PortH = (int)((CardWidthMm  / 25.4f) * Dpi);  // 1011

    private static float Px(float mm) => (mm / 25.4f) * Dpi;

    private readonly IQrSignatureService _qrSig;

    public StudentIdCardImageService(IQrSignatureService qrSig)
    {
        _qrSig = qrSig;
    }

    // ── Dimensiones ───────────────────────────────────────────────────────────

    private static bool IsInstitutionalVertical(SchoolIdCardSetting s) =>
        s.UseModernLayout && !IsHorizontalOrientation(s);

    private static bool IsHorizontalOrientation(SchoolIdCardSetting s) =>
        string.Equals((s.Orientation ?? "Vertical").Trim(), "Horizontal",
            StringComparison.OrdinalIgnoreCase);

    private static (int w, int h) GetDims(SchoolIdCardSetting s) =>
        IsInstitutionalVertical(s) ? (PortW, PortH) : (LandW, LandH);

    public (float WidthMm, float HeightMm) GetCardMmDimensions(SchoolIdCardSetting s) =>
        IsInstitutionalVertical(s)
            ? (CardHeightMm, CardWidthMm)   // portrait: 53.98 × 85.60
            : (CardWidthMm,  CardHeightMm); // landscape: 85.60 × 53.98

    // ── Entrypoints ───────────────────────────────────────────────────────────

    public byte[] GenerateCardImage(StudentCardRenderDto dto, SchoolIdCardSetting settings,
        IReadOnlyList<IdCardTemplateField>? customFields = null)
    {
        var (w, h) = GetDims(settings);
        using var bitmap = new SKBitmap(w, h);
        using var canvas = new SKCanvas(bitmap);

        if (customFields is { Count: > 0 })
            DrawCustomFields(canvas, w, h, dto, settings, customFields);
        else if (IsInstitutionalVertical(settings))
            DrawInstitutionalVerticalFront(canvas, w, h, dto, settings);
        else if (settings.UseModernLayout)
            DrawModernHorizontalFront(canvas, w, h, dto, settings);
        else
            DrawClassicFront(canvas, w, h, dto, settings);

        return ToPng(bitmap);
    }

    public byte[] GenerateCardBackImage(StudentCardRenderDto dto, SchoolIdCardSetting settings)
    {
        var (w, h) = GetDims(settings);
        using var bitmap = new SKBitmap(w, h);
        using var canvas = new SKCanvas(bitmap);
        DrawBack(canvas, w, h, dto, settings);
        return ToPng(bitmap);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // LAYOUT: CLÁSICO (1011 × 638 — landscape)
    // Header | [Foto · Datos · QR] | Footer
    // ══════════════════════════════════════════════════════════════════════════
    private void DrawClassicFront(SKCanvas canvas, int w, int h,
        StudentCardRenderDto dto, SchoolIdCardSetting settings)
    {
        var bg      = Col(settings.BackgroundColor, SKColors.White);
        var primary = Col(settings.PrimaryColor,    new SKColor(13, 110, 253));
        var textCol = Col(settings.TextColor,        SKColors.Black);

        canvas.Clear(bg);
        DrawWatermark(canvas, dto.WatermarkBytes, w, h, 0.42f);

        float headerH = Px(14f);
        float footerH = Px(8f);
        float pad     = Px(4f);
        float bodyTop = headerH;
        float bodyH   = h - headerH - footerH;

        // ── Header ────────────────────────────────────────────────────────────
        using (var p = Fill(primary)) canvas.DrawRect(0, 0, w, headerH, p);

        float logoAreaH = headerH - Px(4f);
        float logoAreaW = Px(10f);
        float nameX     = pad;

        if (dto.LogoBytes != null)
        {
            using var logoBmp = SafeDecode(dto.LogoBytes);
            if (logoBmp != null)
            {
                var lr = FitRect(logoBmp.Width, logoBmp.Height, logoAreaW, logoAreaH,
                    pad, (headerH - logoAreaH) / 2f);
                BmpDraw(canvas, logoBmp, lr);
                nameX = lr.Right + Px(2f);
            }
        }
        Txt(canvas, dto.SchoolName, nameX, headerH / 2f + 10f, w - nameX - pad, 28f,
            SKColors.White, bold: true);

        // ── Foto ──────────────────────────────────────────────────────────────
        float photoW = Px(22f);
        float photoH = Math.Min(Px(24f), bodyH - pad * 2f);
        float photoX = pad;
        float photoY = bodyTop + Px(2f);

        using (var bp = Stroke(primary, 2f)) canvas.DrawRect(photoX, photoY, photoW, photoH, bp);
        if (settings.ShowPhoto)
            DrawPhoto(canvas, dto.PhotoBytes, photoX + 2f, photoY + 2f, photoW - 4f, photoH - 4f, textCol);

        // ── QR ────────────────────────────────────────────────────────────────
        float qrSize = Px(22f);
        float qrX    = w - pad - qrSize;
        float qrY    = bodyTop + (bodyH - qrSize) / 2f;

        if (settings.ShowQr)
            DrawQr(canvas, dto.QrToken, SKRect.Create(qrX, qrY, qrSize, qrSize));

        // ── Datos ─────────────────────────────────────────────────────────────
        float dataX = photoX + photoW + Px(3f);
        float dataW = (settings.ShowQr ? qrX - Px(3f) : w - pad) - dataX;
        float lineH = Px(5.5f);
        float ty    = bodyTop + Px(2f) + 36f;

        Txt(canvas, dto.FullName, dataX, ty, dataW, 36f, textCol, bold: true); ty += lineH;
        Txt(canvas, $"Carnet: {dto.CardNumber}", dataX, ty, dataW, 30f, primary);         ty += lineH;
        Txt(canvas, $"{dto.Grade} - {dto.Group}", dataX, ty, dataW, 30f, textCol);        ty += lineH;
        Txt(canvas, dto.Shift, dataX, ty, dataW, 26f, textCol);

        // ── Footer ────────────────────────────────────────────────────────────
        float footerY = h - footerH;
        using (var lp = Stroke(Col("#e5e7eb", SKColors.LightGray), 1f))
            canvas.DrawLine(0, footerY, w, footerY, lp);
        Txt(canvas, $"Emitido: {DateTime.UtcNow:dd/MM/yyyy}",
            pad, footerY + (footerH + 22f) / 2f, w - pad * 2f, 22f, textCol);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // LAYOUT: INSTITUCIONAL VERTICAL (638 × 1011 — portrait)
    // Header(logo+nombre) | Foto centrada | Datos centrados | Bottom(QR+póliza) | Footer
    //
    // Zonas con alturas fijas (px):
    //   190 + 15 + 260 + 20 + 190 + 30 + 180 + 61 + 65 = 1011 ✓
    // ══════════════════════════════════════════════════════════════════════════
    private void DrawInstitutionalVerticalFront(SKCanvas canvas, int w, int h,
        StudentCardRenderDto dto, SchoolIdCardSetting settings)
    {
        var bg      = Col(settings.BackgroundColor, SKColors.White);
        var primary = Col(settings.PrimaryColor,    new SKColor(13, 110, 253));
        var textCol = Col(settings.TextColor,        SKColors.Black);

        canvas.Clear(bg);
        DrawWatermark(canvas, dto.WatermarkBytes, w, h, 0.45f);

        const float headerH  = 190f;
        const float gapH1    =  15f;
        const float photoZH  = 260f;
        const float gapH2    =  20f;
        const float dataH    = 190f;
        const float gapH3    =  30f;
        const float bottomH  = 180f;
        const float spacerH  =  61f;
        const float footerH  =  65f;
        // Σ = 190+15+260+20+190+30+180+61+65 = 1011

        float hPad    = 30f;
        float textW   = w - hPad * 2f;

        // ── Header ────────────────────────────────────────────────────────────
        using (var p = Fill(primary)) canvas.DrawRect(0, 0, w, headerH, p);

        if (dto.LogoBytes != null)
        {
            using var logoBmp = SafeDecode(dto.LogoBytes);
            if (logoBmp != null)
            {
                float logoMax = 100f;
                var lr = FitRect(logoBmp.Width, logoBmp.Height, logoMax, logoMax,
                    (w - logoMax) / 2f, 10f);
                BmpDraw(canvas, logoBmp, lr);
                Txt(canvas, dto.SchoolName, hPad, lr.Bottom + 28f, textW, 26f,
                    SKColors.White, bold: true, center: true);
            }
            else
            {
                Txt(canvas, dto.SchoolName, hPad, headerH / 2f + 13f, textW, 26f,
                    SKColors.White, bold: true, center: true);
            }
        }
        else
        {
            Txt(canvas, dto.SchoolName, hPad, headerH / 2f + 13f, textW, 26f,
                SKColors.White, bold: true, center: true);
        }

        // Insignia secundaria (esquina superior derecha del header)
        if (dto.SecondaryLogoBytes != null)
        {
            using var sb = SafeDecode(dto.SecondaryLogoBytes);
            if (sb != null)
                BmpDraw(canvas, sb, FitRect(sb.Width, sb.Height, 60f, 60f,
                    w - hPad - 60f, (headerH - 60f) / 2f));
        }

        // ── Foto ──────────────────────────────────────────────────────────────
        float photoZoneTop = headerH + gapH1;
        float photoSize    = 200f;
        float photoX       = (w - photoSize) / 2f;
        float photoY       = photoZoneTop + (photoZH - photoSize) / 2f;

        using (var bp = Stroke(primary, 2f)) canvas.DrawRect(photoX, photoY, photoSize, photoSize, bp);
        if (settings.ShowPhoto)
            DrawPhoto(canvas, dto.PhotoBytes, photoX + 2f, photoY + 2f, photoSize - 4f, photoSize - 4f, textCol);

        // ── Datos ─────────────────────────────────────────────────────────────
        float dataTop = photoZoneTop + photoZH + gapH2;
        float ty      = dataTop + 36f;

        Txt(canvas, dto.FullName, hPad, ty, textW, 36f, textCol, bold: true, center: true);
        ty += 55f;

        bool showDocId = settings.ShowDocumentId && !string.IsNullOrWhiteSpace(dto.DocumentId);
        if (showDocId)
        {
            Txt(canvas, $"Cédula: {dto.DocumentId}", hPad, ty, textW, 26f, textCol, center: true);
            ty += 42f;
        }

        Txt(canvas, $"Grado: {dto.Grade}  —  {dto.Group}", hPad, ty, textW, 26f, textCol, center: true);
        ty += 42f;

        if (settings.ShowAcademicYear && !string.IsNullOrWhiteSpace(dto.AcademicYear))
            Txt(canvas, $"Año: {dto.AcademicYear}", hPad, ty, textW, 24f, textCol, center: true);

        // ── Bottom: QR + info de póliza ───────────────────────────────────────
        float bottomTop = dataTop + dataH + gapH3;
        using (var p = Fill(new SKColor(230, 238, 247))) canvas.DrawRect(0, bottomTop, w, bottomH, p);

        float qrSize = 120f;
        float qrX    = w - hPad - qrSize;
        float qrY    = bottomTop + (bottomH - qrSize) / 2f;

        if (settings.ShowQr)
            DrawQr(canvas, dto.QrToken, SKRect.Create(qrX, qrY, qrSize, qrSize));

        float leftW = qrX - hPad - hPad;
        float lty   = bottomTop + 30f;

        if (settings.ShowPolicyNumber && !string.IsNullOrWhiteSpace(dto.PolicyNumber))
        {
            Txt(canvas, "Póliza de Seguro Educativo", hPad, lty, leftW, 20f, primary, bold: true);
            lty += 30f;
            Txt(canvas, Trunc(dto.PolicyNumber, 28), hPad, lty, leftW, 20f, textCol);
            lty += 38f;
        }
        Txt(canvas, Trunc($"ID: {dto.CardNumber}", 22), hPad, lty, leftW, 24f, textCol, bold: true);

        // ── Footer ────────────────────────────────────────────────────────────
        float footerTop = bottomTop + bottomH + spacerH;
        using (var p = Fill(primary)) canvas.DrawRect(0, footerTop, w, footerH, p);
        Txt(canvas, "Documento de identificación estudiantil",
            hPad, footerTop + (footerH + 20f) / 2f, textW, 20f, SKColors.White, center: true);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // LAYOUT: MODERNO HORIZONTAL (1011 × 638 — landscape)
    // Header(logo+nombre+logo2) | [Foto · Datos · QR] | Footer
    // ══════════════════════════════════════════════════════════════════════════
    private void DrawModernHorizontalFront(SKCanvas canvas, int w, int h,
        StudentCardRenderDto dto, SchoolIdCardSetting settings)
    {
        var bg      = Col(settings.BackgroundColor, SKColors.White);
        var primary = Col(settings.PrimaryColor,    new SKColor(13, 110, 253));
        var textCol = Col(settings.TextColor,        SKColors.Black);

        canvas.Clear(bg);
        DrawWatermark(canvas, dto.WatermarkBytes, w, h, 0.40f);

        float headerH = Px(12f);
        float footerH = Px(6f);
        float pad     = Px(3f);
        float spacer  = Px(2f);

        // ── Header ────────────────────────────────────────────────────────────
        using (var p = Fill(primary)) canvas.DrawRect(0, 0, w, headerH, p);

        float logoSize = headerH - Px(3f);
        float nameX    = pad;

        if (dto.LogoBytes != null)
        {
            using var logoBmp = SafeDecode(dto.LogoBytes);
            if (logoBmp != null)
            {
                var lr = FitRect(logoBmp.Width, logoBmp.Height, logoSize, logoSize,
                    pad, (headerH - logoSize) / 2f);
                BmpDraw(canvas, logoBmp, lr);
                nameX = lr.Right + spacer;
            }
        }

        float nameW = w - nameX - pad;
        if (settings.ShowSecondaryLogo && dto.SecondaryLogoBytes != null)
        {
            using var sb = SafeDecode(dto.SecondaryLogoBytes);
            if (sb != null)
            {
                var sr = FitRect(sb.Width, sb.Height, logoSize, logoSize,
                    w - pad - logoSize, (headerH - logoSize) / 2f);
                BmpDraw(canvas, sb, sr);
                nameW = sr.Left - spacer - nameX;
            }
        }
        Txt(canvas, dto.SchoolName, nameX, headerH / 2f + 10f, nameW, 24f, SKColors.White, bold: true);

        // ── Body ──────────────────────────────────────────────────────────────
        float bodyTop  = headerH;
        float bodyH    = h - headerH - footerH;
        float photoSz  = Px(18f);
        float qrSz     = Px(18f);
        float photoX   = pad;
        float photoY   = bodyTop + (bodyH - photoSz) / 2f;

        using (var bp = Stroke(primary, 2f)) canvas.DrawRect(photoX, photoY, photoSz, photoSz, bp);
        if (settings.ShowPhoto)
            DrawPhoto(canvas, dto.PhotoBytes, photoX + 2f, photoY + 2f, photoSz - 4f, photoSz - 4f, textCol);

        float qrX = w - pad - qrSz;
        float qrY = bodyTop + (bodyH - qrSz) / 2f;
        if (settings.ShowQr)
            DrawQr(canvas, dto.QrToken, SKRect.Create(qrX, qrY, qrSz, qrSz));

        float dataX = photoX + photoSz + spacer;
        float dataW = (settings.ShowQr ? qrX - spacer : w - pad) - dataX;
        float lineH = Px(4.5f);
        float ty    = bodyTop + Px(3f) + 28f;

        Txt(canvas, dto.FullName, dataX, ty, dataW, 28f, textCol, bold: true);         ty += lineH;
        Txt(canvas, $"Carnet: {dto.CardNumber}", dataX, ty, dataW, 24f, primary);       ty += lineH;
        Txt(canvas, $"{dto.Grade} - {dto.Group}", dataX, ty, dataW, 24f, textCol);      ty += lineH;
        Txt(canvas, dto.Shift, dataX, ty, dataW, 20f, textCol);                         ty += lineH;

        if (settings.ShowDocumentId && !string.IsNullOrWhiteSpace(dto.DocumentId))
            Txt(canvas, $"Cédula: {dto.DocumentId}", dataX, ty, dataW, 20f, textCol);

        // ── Footer ────────────────────────────────────────────────────────────
        float footerY = h - footerH;
        using (var lp = Stroke(Col("#e5e7eb", SKColors.LightGray), 1f))
            canvas.DrawLine(0, footerY, w, footerY, lp);
        Txt(canvas, $"Emitido: {DateTime.UtcNow:dd/MM/yyyy}",
            pad, footerY + (footerH + 20f) / 2f, w - pad * 2f, 20f, textCol);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // LAYOUT: CAMPOS PERSONALIZADOS (custom template fields)
    // Fondo + header de color + cada campo posicionado por coordenadas absolutas
    // ══════════════════════════════════════════════════════════════════════════
    private void DrawCustomFields(SKCanvas canvas, int w, int h,
        StudentCardRenderDto dto, SchoolIdCardSetting settings,
        IReadOnlyList<IdCardTemplateField> fields)
    {
        var bg      = Col(settings.BackgroundColor, SKColors.White);
        var primary = Col(settings.PrimaryColor,    new SKColor(13, 110, 253));
        var textCol = Col(settings.TextColor,        SKColors.Black);

        canvas.Clear(bg);

        // Header de color (12mm)
        float hdrH = Px(12f);
        using (var p = Fill(primary)) canvas.DrawRect(0, 0, w, hdrH, p);

        foreach (var f in fields)
        {
            if (!f.IsEnabled) continue;
            float fx = Px((float)f.XMm);
            float fy = Px((float)f.YMm);
            float fw = Px((float)f.WMm);
            float fh = Px((float)f.HMm);
            // Tamaño de fuente: CSS pt → px a 300 DPI (1pt = 1/72 in, 300dpi)
            float fs = (float)f.FontSize * (300f / 72f);

            switch (f.FieldKey)
            {
                case "SchoolName":
                    Txt(canvas, dto.SchoolName, fx, fy + fs, fw, fs, SKColors.White, bold: true);
                    break;
                case "SchoolLogo":
                    if (dto.LogoBytes != null)
                    {
                        using var lb = SafeDecode(dto.LogoBytes);
                        if (lb != null) BmpDraw(canvas, lb, FitRect(lb.Width, lb.Height, fw, fh, fx, fy));
                    }
                    break;
                case "Photo":
                    using (var bp = Stroke(textCol, 2f)) canvas.DrawRect(fx, fy, fw, fh, bp);
                    DrawPhoto(canvas, dto.PhotoBytes, fx + 2f, fy + 2f, fw - 4f, fh - 4f, textCol);
                    break;
                case "FullName":
                    Txt(canvas, dto.FullName, fx, fy + fs, fw, fs, textCol, bold: true);
                    break;
                case "DocumentId":
                    Txt(canvas, dto.DocumentId ?? "", fx, fy + fs, fw, fs, textCol);
                    break;
                case "Grade":
                    Txt(canvas, dto.Grade, fx, fy + fs, fw, fs, textCol);
                    break;
                case "Group":
                    Txt(canvas, dto.Group, fx, fy + fs, fw, fs, textCol);
                    break;
                case "Shift":
                    Txt(canvas, dto.Shift, fx, fy + fs, fw, fs, textCol);
                    break;
                case "CardNumber":
                    Txt(canvas, dto.CardNumber, fx, fy + fs, fw, fs, textCol);
                    break;
                case "Qr":
                    if (settings.ShowQr)
                        DrawQr(canvas, dto.QrToken, SKRect.Create(fx, fy, fw, fh));
                    break;
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // REVERSO — se adapta al canvas (landscape o portrait)
    // QR centrado arriba · nombre · instrucción · número de carnet · campos opcionales · footer
    // ══════════════════════════════════════════════════════════════════════════
    private void DrawBack(SKCanvas canvas, int w, int h,
        StudentCardRenderDto dto, SchoolIdCardSetting settings)
    {
        var bg      = Col(settings.BackgroundColor, SKColors.White);
        var primary = Col(settings.PrimaryColor,    new SKColor(13, 110, 253));
        var textCol = Col(settings.TextColor,        SKColors.Black);

        canvas.Clear(bg);
        DrawWatermark(canvas, dto.WatermarkBytes, w, h, 0.45f);

        float hPad    = 30f;
        float contentW = w - hPad * 2f;
        float qrSize  = Math.Min(w, h) * 0.35f;  // 35% del lado menor
        float qrX     = (w - qrSize) / 2f;
        float qrY     = hPad;

        if (settings.ShowQr)
            DrawQr(canvas, dto.QrToken, SKRect.Create(qrX, qrY, qrSize, qrSize));

        float ty      = qrY + qrSize + 24f;
        float lineH   = 40f;
        float smallLH = 32f;

        Txt(canvas, Trunc(dto.SchoolName, 50), hPad, ty, contentW, 28f, textCol, bold: true, center: true);
        ty += lineH;
        Txt(canvas, "Escanea el código QR para verificar la información del carnet",
            hPad, ty, contentW, 22f, textCol, center: true);
        ty += lineH;
        Txt(canvas, Trunc($"Carnet: {dto.CardNumber}", 30), hPad, ty, contentW, 24f, textCol, center: true);
        ty += lineH;

        if (!string.IsNullOrWhiteSpace(dto.IdCardPolicy))
        {
            var pol = dto.IdCardPolicy.Trim();
            if (pol.Length > 120) pol = pol[..119] + "…";
            Txt(canvas, pol, hPad, ty, contentW, 20f, textCol, center: true);
            ty += smallLH;
        }
        if (settings.ShowSchoolPhone && !string.IsNullOrWhiteSpace(dto.SchoolPhone))
        {
            Txt(canvas, Trunc($"Tel. colegio: {dto.SchoolPhone}", 35), hPad, ty, contentW, 22f, textCol, center: true);
            ty += smallLH;
        }
        if (settings.ShowEmergencyContact && !string.IsNullOrWhiteSpace(dto.EmergencyContactName))
        {
            Txt(canvas, Trunc($"Emergencia: {dto.EmergencyContactName}", 35), hPad, ty, contentW, 22f, textCol, center: true);
            ty += smallLH;
            if (!string.IsNullOrWhiteSpace(dto.EmergencyContactPhone))
            {
                Txt(canvas, Trunc($"Tel: {dto.EmergencyContactPhone}", 30), hPad, ty, contentW, 22f, textCol, center: true);
                ty += smallLH;
            }
        }
        if (settings.ShowAllergies && !string.IsNullOrWhiteSpace(dto.Allergies))
        {
            var allg = dto.Allergies.Length > 100 ? dto.Allergies[..99] + "…" : dto.Allergies;
            Txt(canvas, $"Alergias: {allg}", hPad, ty, contentW, 20f, textCol, center: true);
        }

        // Footer
        float footerH = 58f;
        using (var p = Fill(primary)) canvas.DrawRect(0, h - footerH, w, footerH, p);
        Txt(canvas, "Documento de identificación estudiantil",
            hPad, h - (footerH - 20f) / 2f, contentW, 20f, SKColors.White, center: true);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // HELPERS PRIMITIVOS
    // ══════════════════════════════════════════════════════════════════════════

    private void DrawQr(SKCanvas canvas, string? token, SKRect dest)
    {
        if (string.IsNullOrWhiteSpace(token)) return;
        var qrBytes = SafeQr(token);
        if (qrBytes == null) return;
        using var qrBmp = SafeDecode(qrBytes);
        if (qrBmp != null) BmpDraw(canvas, qrBmp, dest);
    }

    private static void DrawWatermark(SKCanvas canvas, byte[]? wmBytes, int w, int h, float pct)
    {
        if (wmBytes == null || wmBytes.Length == 0) return;
        using var bmp = SafeDecode(wmBytes);
        if (bmp == null) return;
        float size = Math.Min(w, h) * pct;
        BmpDraw(canvas, bmp, FitRect(bmp.Width, bmp.Height, size, size,
            (w - size) / 2f, (h - size) / 2f));
    }

    private static void DrawPhoto(SKCanvas canvas, byte[]? photoBytes,
        float x, float y, float w, float h, SKColor textCol)
    {
        if (photoBytes != null && photoBytes.Length > 0)
        {
            using var bmp = SafeDecode(photoBytes);
            if (bmp != null) { BmpDraw(canvas, bmp, FitRect(bmp.Width, bmp.Height, w, h, x, y)); return; }
        }
        // Placeholder
        using var p = new SKPaint { Color = textCol, TextSize = 28f, IsAntialias = true };
        float tw = p.MeasureText("FOTO");
        canvas.DrawText("FOTO", x + (w - tw) / 2f, y + (h + 28f) / 2f, p);
    }

    private static void BmpDraw(SKCanvas canvas, SKBitmap bmp, SKRect dest)
    {
        using var p = new SKPaint { IsAntialias = true, FilterQuality = SKFilterQuality.High };
        canvas.DrawBitmap(bmp, dest, p);
    }

    /// <summary>
    /// Dibuja texto con auto-reducción de tamaño y truncado con "…".
    /// y = baseline. Si center=true, centra horizontalmente dentro de [x, x+maxW].
    /// </summary>
    private static void Txt(SKCanvas canvas, string text, float x, float y, float maxW,
        float fontSize, SKColor color, bool bold = false, bool center = false)
    {
        if (string.IsNullOrEmpty(text)) return;

        using var tf   = SKTypeface.FromFamilyName(null, bold ? SKFontStyle.Bold : SKFontStyle.Normal);
        using var paint = new SKPaint
        {
            Color       = color,
            TextSize    = fontSize,
            IsAntialias = true,
            Typeface    = tf
        };

        // Auto-reducir hasta que el texto quepa
        while (paint.MeasureText(text) > maxW && paint.TextSize > 10f)
            paint.TextSize -= 0.5f;

        // Truncar si aún no cabe
        string d = text;
        if (paint.MeasureText(d) > maxW)
        {
            while (d.Length > 1 && paint.MeasureText(d + "…") > maxW)
                d = d[..^1];
            d += "…";
        }

        float drawX = center ? x + (maxW - paint.MeasureText(d)) / 2f : x;
        canvas.DrawText(d, drawX, y, paint);
    }

    private static SKRect FitRect(int imgW, int imgH, float maxW, float maxH, float ox, float oy)
    {
        float scale = Math.Min(maxW / Math.Max(imgW, 1), maxH / Math.Max(imgH, 1));
        float fw    = imgW * scale;
        float fh    = imgH * scale;
        return SKRect.Create(ox + (maxW - fw) / 2f, oy + (maxH - fh) / 2f, fw, fh);
    }

    private static SKPaint Fill(SKColor color)   => new() { Color = color, Style = SKPaintStyle.Fill };
    private static SKPaint Stroke(SKColor color, float w) =>
        new() { Color = color, Style = SKPaintStyle.Stroke, StrokeWidth = w };

    private static SKColor Col(string? hex, SKColor fallback = default)
    {
        if (string.IsNullOrWhiteSpace(hex)) return fallback;
        try { return SKColor.Parse(hex.StartsWith('#') ? hex : '#' + hex); }
        catch { return fallback; }
    }

    private static string Trunc(string? text, int max)
    {
        if (string.IsNullOrEmpty(text)) return string.Empty;
        return text.Length <= max ? text : text[..(max - 1)] + "…";
    }

    private byte[]? SafeQr(string? token)
    {
        if (string.IsNullOrWhiteSpace(token)) return null;
        try   { return QrHelper.GenerateQrPng(token, _qrSig); }
        catch
        {
            try   { return QrHelper.GenerateQrPng(token, null); }
            catch { return null; }
        }
    }

    private static SKBitmap? SafeDecode(byte[]? bytes)
    {
        if (bytes == null || bytes.Length == 0) return null;
        try { return SKBitmap.Decode(bytes); } catch { return null; }
    }

    private static byte[] ToPng(SKBitmap bitmap)
    {
        using var image = SKImage.FromBitmap(bitmap);
        using var data  = image.Encode(SKEncodedImageFormat.Png, 100);
        return data.ToArray();
    }
}
