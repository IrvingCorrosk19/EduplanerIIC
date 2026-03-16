using System;

namespace SchoolManager.Models;

public class SchoolIdCardSetting
{
    public Guid Id { get; set; }
    public Guid SchoolId { get; set; }
    public string TemplateKey { get; set; } = "default_v1";
    public int PageWidthMm { get; set; } = 54;
    public int PageHeightMm { get; set; } = 86;
    public int BleedMm { get; set; } = 0;
    public string BackgroundColor { get; set; } = "#FFFFFF";
    public string PrimaryColor { get; set; } = "#0D6EFD";
    public string TextColor { get; set; } = "#111111";
    public bool ShowQr { get; set; } = true;
    public bool ShowPhoto { get; set; } = true;
    /// <summary>Mostrar teléfono del colegio en el reverso del carnet.</summary>
    public bool ShowSchoolPhone { get; set; } = true;
    /// <summary>Mostrar contacto de emergencia en el reverso del carnet.</summary>
    public bool ShowEmergencyContact { get; set; } = false;
    /// <summary>Mostrar alergias en el reverso del carnet.</summary>
    public bool ShowAllergies { get; set; } = false;
    /// <summary>Orientación del carnet: Vertical (54×86 mm) u Horizontal (86×54 mm).</summary>
    public string Orientation { get; set; } = "Vertical";
    /// <summary>Mostrar logo del colegio como marca de agua en el frente y reverso del carnet.</summary>
    public bool ShowWatermark { get; set; } = true;
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public virtual School School { get; set; } = null!;
}
