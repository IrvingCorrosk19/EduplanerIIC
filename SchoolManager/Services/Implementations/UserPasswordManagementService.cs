using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SchoolManager.Services.Implementations
{
    public class UserPasswordManagementService : IUserPasswordManagementService
    {
        private readonly SchoolDbContext _context;

        public UserPasswordManagementService(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<List<UserListDto>> GetAllUsersAsync()
        {
            var users = await _context.Users
                .IgnoreQueryFilters()
                .OrderBy(u => u.Name)
                .ThenBy(u => u.LastName)
                .Select(u => new UserListDto
                {
                    Id = u.Id,
                    FirstName = u.Name,
                    LastName = u.LastName ?? string.Empty,
                    Email = u.Email,
                    Role = u.Role ?? string.Empty,
                    Status = u.Status ?? string.Empty,
                    PasswordEmailStatus = u.PasswordEmailStatus,
                    PasswordEmailSentAt = u.PasswordEmailSentAt,
                    CreatedAt = u.CreatedAt
                })
                .ToListAsync();
            return users;
        }

        public async Task<List<UserListDto>> GetUsersByRoleAsync(string? role)
        {
            if (string.IsNullOrWhiteSpace(role) || role.Equals("All", StringComparison.OrdinalIgnoreCase))
                return await GetAllUsersAsync();

            var roleLower = (role ?? string.Empty).Trim().ToLowerInvariant();
            var roleFilter = roleLower switch
            {
                "superadmin" => new[] { "superadmin" },
                "admin" => new[] { "admin" },
                "teacher" => new[] { "teacher" },
                "student" => new[] { "student", "estudiante" },
                _ => new[] { roleLower }
            };

            var users = await _context.Users
                .IgnoreQueryFilters()
                .Where(u => roleFilter.Contains((u.Role ?? string.Empty).ToLowerInvariant()))
                .OrderBy(u => u.Name)
                .ThenBy(u => u.LastName)
                .Select(u => new UserListDto
                {
                    Id = u.Id,
                    FirstName = u.Name,
                    LastName = u.LastName ?? string.Empty,
                    Email = u.Email,
                    Role = u.Role ?? string.Empty,
                    Status = u.Status ?? string.Empty,
                    PasswordEmailStatus = u.PasswordEmailStatus,
                    PasswordEmailSentAt = u.PasswordEmailSentAt,
                    CreatedAt = u.CreatedAt
                })
                .ToListAsync();
            return users;
        }
    }
}
