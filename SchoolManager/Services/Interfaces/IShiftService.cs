using SchoolManager.Models;

namespace SchoolManager.Services.Interfaces
{
    public interface IShiftService
    {
        Task<List<Shift>> GetAllAsync();
        Task<List<Shift>> GetAllIncludingInactiveAsync();
        Task<Shift?> GetByIdAsync(Guid id);
        Task<Shift?> GetByNameAsync(string name);
        Task<Shift> CreateAsync(Shift shift);
        Task UpdateAsync(Shift shift);
        Task DeleteAsync(Guid id);
        Task<Shift> GetOrCreateAsync(string name);
    }
}

