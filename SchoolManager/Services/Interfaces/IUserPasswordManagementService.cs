using SchoolManager.Dtos;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SchoolManager.Services.Interfaces
{
    public interface IUserPasswordManagementService
    {
        Task<List<UserListDto>> GetAllUsersAsync();
        Task<List<UserListDto>> GetUsersByRoleAsync(string role);
    }
}
