using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SchoolManager.Models;
using SchoolManager.Repositories.Interfaces;
using SchoolManager.Services.Implementations;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Background;

public class EmailQueueWorker : BackgroundService
{
    private const int BatchSize = 50;
    private const int IntervalSeconds = 10;
    private static readonly TimeSpan MinDelayBetweenSends = TimeSpan.FromMilliseconds(100);
    private static readonly TimeSpan MaxDelayBetweenSends = TimeSpan.FromMilliseconds(300);
    private static readonly Random Rng = new();

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<EmailQueueWorker> _logger;

    public EmailQueueWorker(IServiceScopeFactory scopeFactory, ILogger<EmailQueueWorker> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessBatchAsync(stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "EmailQueueWorker cycle error");
            }

            await Task.Delay(TimeSpan.FromSeconds(IntervalSeconds), stoppingToken);
        }
    }

    private async Task ProcessBatchAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IEmailQueueRepository>();
        var sender = scope.ServiceProvider.GetRequiredService<IEmailSender>();
        var db = scope.ServiceProvider.GetRequiredService<SchoolDbContext>();

        var batch = await repo.GetPendingBatchAsync(BatchSize);
        if (batch.Count == 0) return;

        foreach (var item in batch)
        {
            item.Status = EmailQueueStatus.Processing;
            repo.Update(item);
        }
        await repo.SaveChangesAsync();

        foreach (var item in batch)
        {
            if (ct.IsCancellationRequested) break;

            var (success, error) = await sender.SendAsync(
                item.Email,
                item.Subject ?? "Acceso a la plataforma",
                item.Body ?? "",
                ct);

            var now = DateTime.UtcNow;
            if (success)
            {
                item.Status = EmailQueueStatus.Sent;
                item.ProcessedAt = now;
                item.LastError = null;
                var user = await db.Users.IgnoreQueryFilters().FirstOrDefaultAsync(u => u.Id == item.UserId, ct);
                if (user != null)
                {
                    user.PasswordEmailStatus = PasswordEmailStatusValues.Sent;
                    user.PasswordEmailSentAt = now;
                    user.UpdatedAt = now;
                }
            }
            else
            {
                item.Attempts++;
                item.LastError = error != null && error.Length > 2000 ? error.Substring(0, 2000) : error;
                _logger.LogWarning("Email queue error Email={Email} Attempts={Attempts} Error={Error}",
                    item.Email, item.Attempts, item.LastError);

                if (item.Attempts >= item.MaxAttempts)
                {
                    item.Status = EmailQueueStatus.Failed;
                    item.ProcessedAt = now;
                    var user = await db.Users.IgnoreQueryFilters().FirstOrDefaultAsync(u => u.Id == item.UserId, ct);
                    if (user != null)
                    {
                        user.PasswordEmailStatus = PasswordEmailStatusValues.Failed;
                        user.PasswordEmailSentAt = now;
                        user.UpdatedAt = now;
                    }
                }
                else
                {
                    item.Status = EmailQueueStatus.Pending;
                }
            }

            repo.Update(item);
            await repo.SaveChangesAsync();

            var delayMs = Rng.Next((int)MinDelayBetweenSends.TotalMilliseconds, (int)MaxDelayBetweenSends.TotalMilliseconds + 1);
            await Task.Delay(delayMs, ct);
        }
    }
}
