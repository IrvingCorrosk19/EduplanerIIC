namespace SchoolManager.Services.Implementations;

public class StudentIdCardPdfPrintOptions
{
    public const string SectionName = "StudentIdCardPdf";

    // Valores soportados: CardPrinter, A4Portrait
    public string Profile { get; set; } = "CardPrinter";

    // Escala de contenido de la página HTML antes de capturar.
    // 1.00 = sin ajuste, 0.95 = reduce 5% para dar aire a textos largos.
    public decimal ContentScale { get; set; } = 0.96m;

    /// <summary>Factor de píxeles del viewport de Chromium al capturar (2 = captura más densa, menos borrosidad al redimensionar).</summary>
    public int DeviceScaleFactor { get; set; } = 2;
}
