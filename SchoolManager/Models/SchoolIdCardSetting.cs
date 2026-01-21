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
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public virtual School School { get; set; } = null!;
}
