using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;
using SchoolManager.Options;

namespace SchoolManager.Helpers;

/// <summary>
/// URL pública del sitio para códigos QR (carnet estudiantil y credencial institucional).
/// Prioridad: override explícito → appsettings/env → host de la petición HTTP (con proxy/HTTPS).
/// </summary>
public interface IPublicSiteUrlResolver
{
    string? ResolveStudentIdCardBaseUrl(string? overrideUrl = null);
    string? ResolveInstitutionalCredentialBaseUrl(string? overrideUrl = null);
}

public class PublicSiteUrlResolver : IPublicSiteUrlResolver
{
    private readonly IHttpContextAccessor _http;
    private readonly IOptions<StudentIdCardOptions> _studentOptions;
    private readonly IOptions<InstitutionalCredentialOptions> _institutionalOptions;

    public PublicSiteUrlResolver(
        IHttpContextAccessor http,
        IOptions<StudentIdCardOptions> studentOptions,
        IOptions<InstitutionalCredentialOptions> institutionalOptions)
    {
        _http = http;
        _studentOptions = studentOptions;
        _institutionalOptions = institutionalOptions;
    }

    public string? ResolveStudentIdCardBaseUrl(string? overrideUrl = null) =>
        Resolve(overrideUrl, _studentOptions.Value.PublicBaseUrl);

    public string? ResolveInstitutionalCredentialBaseUrl(string? overrideUrl = null) =>
        Resolve(overrideUrl, _institutionalOptions.Value.PublicBaseUrl);

    private string? Resolve(string? overrideUrl, string? configuredUrl)
    {
        var fromOverride = Normalize(overrideUrl);
        if (fromOverride != null)
            return fromOverride;

        var fromConfig = Normalize(configuredUrl);
        if (fromConfig != null)
            return fromConfig;

        return ResolveFromHttpContext();
    }

    private string? ResolveFromHttpContext()
    {
        var ctx = _http.HttpContext;
        if (ctx == null)
            return null;

        var scheme = ctx.Request.Scheme;
        var host = ctx.Request.Host.Value;
        if (string.IsNullOrWhiteSpace(host))
            return null;

        return $"{scheme}://{host}".TrimEnd('/');
    }

    private static string? Normalize(string? url)
    {
        if (string.IsNullOrWhiteSpace(url))
            return null;
        return url.Trim().TrimEnd('/');
    }
}
