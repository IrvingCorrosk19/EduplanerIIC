using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;

namespace SchoolManager.Services.Interfaces;

public interface IEmailQueueService
{
    Task EnqueueUsersAsync(List<Guid> userIds, ClaimsPrincipal currentUser);
}
