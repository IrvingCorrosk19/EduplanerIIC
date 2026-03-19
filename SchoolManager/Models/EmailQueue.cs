using System;

namespace SchoolManager.Models;

public static class EmailQueueStatus
{
    public const string Pending = "Pending";
    public const string Processing = "Processing";
    public const string Sent = "Sent";
    public const string Failed = "Failed";
}

public class EmailQueue
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Email { get; set; } = null!;
    public string? Subject { get; set; }
    public string? Body { get; set; }
    public string Status { get; set; } = EmailQueueStatus.Pending;
    public int Attempts { get; set; }
    public int MaxAttempts { get; set; } = 3;
    public string? LastError { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ProcessedAt { get; set; }

    public virtual User User { get; set; } = null!;
}
