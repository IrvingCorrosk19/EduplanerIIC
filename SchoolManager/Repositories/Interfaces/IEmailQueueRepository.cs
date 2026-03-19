using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using SchoolManager.Models;

namespace SchoolManager.Repositories.Interfaces;

public interface IEmailQueueRepository
{
    void AddRange(List<EmailQueue> items);
    Task<List<EmailQueue>> GetPendingBatchAsync(int batchSize);
    void Update(EmailQueue item);
    Task SaveChangesAsync();
}
