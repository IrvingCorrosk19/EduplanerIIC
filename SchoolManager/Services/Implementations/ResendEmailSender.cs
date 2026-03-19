using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public class ResendEmailSender : IEmailSender
{
    private const string ResendEmailsUrl = "https://api.resend.com/emails";
    private readonly IEmailApiConfigurationService _emailApiConfig;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<ResendEmailSender> _logger;

    public ResendEmailSender(
        IEmailApiConfigurationService emailApiConfig,
        IHttpClientFactory httpClientFactory,
        ILogger<ResendEmailSender> logger)
    {
        _emailApiConfig = emailApiConfig;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<(bool Success, string? Error)> SendAsync(string to, string subject, string body, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(to))
            return (false, "Correo destino vacío.");

        var cfg = await _emailApiConfig.GetActiveAsync(cancellationToken);
        if (cfg == null)
            return (false, "No hay configuración API de correo activa.");
        if (string.IsNullOrWhiteSpace(cfg.ApiKey))
            return (false, "API key no configurada.");
        if (string.IsNullOrWhiteSpace(cfg.FromEmail))
            return (false, "FromEmail no configurado.");

        var provider = (cfg.Provider ?? "").Trim();
        if (!provider.Equals("Resend", StringComparison.OrdinalIgnoreCase))
            return (false, $"Proveedor no soportado: {provider}.");

        var fromDisplay = $"{cfg.FromName} <{cfg.FromEmail.Trim()}>";
        var client = _httpClientFactory.CreateClient();
        client.Timeout = TimeSpan.FromSeconds(45);
        using var request = new HttpRequestMessage(HttpMethod.Post, ResendEmailsUrl);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", cfg.ApiKey.Trim());

        var payload = new { from = fromDisplay, to = new[] { to.Trim() }, subject, html = body };
        request.Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

        try
        {
            using var response = await client.SendAsync(request, cancellationToken);
            var responseBody = await response.Content.ReadAsStringAsync(cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning("Resend API {Code}: {Body}", (int)response.StatusCode, responseBody);
                return (false, string.IsNullOrWhiteSpace(responseBody) ? response.ReasonPhrase : responseBody);
            }
            return (true, null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Resend SendAsync falló para {Email}", to);
            return (false, ex.Message);
        }
    }
}
