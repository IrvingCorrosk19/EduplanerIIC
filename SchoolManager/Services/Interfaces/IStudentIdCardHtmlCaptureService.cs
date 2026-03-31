namespace SchoolManager.Services.Interfaces;

public interface IStudentIdCardHtmlCaptureService
{
    /// <summary>
    /// Navega a la vista HTML del carnet del estudiante, captura cada elemento .idcard-face
    /// vía headless Chromium, los escala a dimensiones CR80/ISO ID-1 exactas y genera el PDF.
    /// </summary>
    /// <param name="studentId">ID del estudiante.</param>
    /// <param name="baseUrl">Esquema + host de la aplicación (p. ej. "https://app.edu.com").</param>
    /// <param name="cookies">Cookies de la petición HTTP actual (autenticación).</param>
    Task<byte[]> GeneratePdfFromHtmlAsync(Guid studentId, string baseUrl, IRequestCookieCollection cookies);
}
