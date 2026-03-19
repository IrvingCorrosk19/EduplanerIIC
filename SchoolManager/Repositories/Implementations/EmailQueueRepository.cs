using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Repositories.Interfaces;

namespace SchoolManager.Repositories.Implementations;

public class EmailQueueRepository : IEmailQueueRepository
{
    private readonly SchoolDbContext _db;

    public EmailQueueRepository(SchoolDbContext db)
    {
        _db = db;
    }

    public void AddRange(List<EmailQueue> items)
    {
        if (items == null || items.Count == 0) return;
        _db.EmailQueues.AddRange(items);
    }

    public async Task<List<EmailQueue>> GetPendingBatchAsync(int batchSize)
    {
        return await _db.EmailQueues
            .Where(e => e.Status == EmailQueueStatus.Pending)
            .OrderBy(e => e.CreatedAt)
            .Take(batchSize)
            .Include(e => e.User)
            .ToListAsync();
    }

    public void Update(EmailQueue item)
    {
        _db.EmailQueues.Update(item);
    }

    public Task SaveChangesAsync() => _db.SaveChangesAsync();
}
