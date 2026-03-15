using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;

namespace SchoolManager.Services.Security;

/// <summary>Configuración de firma para el QR del carnet (appsettings: QrSecurity:SecretKey).</summary>
public class QrSecurityOptions
{
    public const string SectionName = "QrSecurity";
    public string SecretKey { get; set; } = "CHANGE_THIS_TO_RANDOM_SECRET";
}

public interface IQrSignatureService
{
    /// <summary>Genera token firmado: token|timestamp|signature (HMAC-SHA256).</summary>
    string GenerateSignedToken(string token);
    /// <summary>Valida la firma del token en formato token|timestamp|signature.</summary>
    bool ValidateSignedToken(string signedToken);
    /// <summary>Extrae el token interno (primera parte) cuando el formato es token|timestamp|signature.</summary>
    string? ExtractTokenFromSigned(string signedToken);
}

public class QrSignatureService : IQrSignatureService
{
    private readonly byte[] _secretKeyBytes;
    private const char Separator = '|';

    public QrSignatureService(IOptions<QrSecurityOptions> options)
    {
        var key = options?.Value?.SecretKey ?? QrSecurityOptions.SectionName;
        _secretKeyBytes = Encoding.UTF8.GetBytes(key);
    }

    public string GenerateSignedToken(string token)
    {
        if (string.IsNullOrEmpty(token))
            return token;
        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();
        var payload = token + timestamp;
        var signature = ComputeHmacSha256(payload);
        return $"{token}{Separator}{timestamp}{Separator}{signature}";
    }

    public bool ValidateSignedToken(string signedToken)
    {
        if (string.IsNullOrEmpty(signedToken) || !signedToken.Contains(Separator))
            return false;
        var parts = signedToken.Split(Separator, 3, StringSplitOptions.None);
        if (parts.Length != 3)
            return false;
        var token = parts[0];
        var timestamp = parts[1];
        var receivedSignature = parts[2];
        var payload = token + timestamp;
        var expectedSignature = ComputeHmacSha256(payload);
        try
        {
            var receivedBytes = Convert.FromHexString(receivedSignature);
            var expectedBytes = Convert.FromHexString(expectedSignature);
            return receivedBytes.Length == expectedBytes.Length
                   && CryptographicOperations.FixedTimeEquals(receivedBytes, expectedBytes);
        }
        catch
        {
            return false;
        }
    }

    public string? ExtractTokenFromSigned(string signedToken)
    {
        if (string.IsNullOrEmpty(signedToken) || !signedToken.Contains(Separator))
            return null;
        var parts = signedToken.Split(Separator, 3, StringSplitOptions.None);
        return parts.Length == 3 ? parts[0] : null;
    }

    private string ComputeHmacSha256(string payload)
    {
        using var hmac = new HMACSHA256(_secretKeyBytes);
        var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(payload));
        return Convert.ToHexString(hash).ToLowerInvariant();
    }
}
