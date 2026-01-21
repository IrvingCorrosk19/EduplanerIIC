using QRCoder;

namespace SchoolManager.Helpers;

public static class QrHelper
{
    public static byte[] GenerateQrPng(string content)
    {
        using var generator = new QRCodeGenerator();
        using var data = generator.CreateQrCode(content, QRCodeGenerator.ECCLevel.Q);
        var qr = new PngByteQRCode(data);
        return qr.GetGraphic(10);
    }
}
