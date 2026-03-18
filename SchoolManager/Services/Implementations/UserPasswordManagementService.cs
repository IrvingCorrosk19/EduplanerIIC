using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
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
                    Grade = u.StudentAssignments
                        .Where(sa => sa.IsActive)
                        .OrderByDescending(sa => sa.CreatedAt)
                        .Select(sa => sa.Grade.Name)
                        .FirstOrDefault() ?? "-",
                    Group = u.StudentAssignments
                        .Where(sa => sa.IsActive)
                        .OrderByDescending(sa => sa.CreatedAt)
                        .Select(sa => sa.Group.Name)
                        .FirstOrDefault() ?? "-",
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
                    Grade = u.StudentAssignments
                        .Where(sa => sa.IsActive)
                        .OrderByDescending(sa => sa.CreatedAt)
                        .Select(sa => sa.Grade.Name)
                        .FirstOrDefault() ?? "-",
                    Group = u.StudentAssignments
                        .Where(sa => sa.IsActive)
                        .OrderByDescending(sa => sa.CreatedAt)
                        .Select(sa => sa.Group.Name)
                        .FirstOrDefault() ?? "-",
                    Status = u.Status ?? string.Empty,
                    PasswordEmailStatus = u.PasswordEmailStatus,
                    PasswordEmailSentAt = u.PasswordEmailSentAt,
                    CreatedAt = u.CreatedAt
                })
                .ToListAsync();
            return users;
        }

        private static bool IsStudentRole(string? role)
        {
            var r = (role ?? string.Empty).ToLowerInvariant();
            return r is "student" or "estudiante";
        }

        public async Task<UserPasswordManagementIndexViewModel> GetIndexViewModelAsync(
            Guid? gradeId,
            Guid? groupId,
            Guid? callerSchoolId,
            bool callerIsSuperAdmin,
            CancellationToken cancellationToken = default)
        {
            var vm = new UserPasswordManagementIndexViewModel
            {
                SelectedGradeId = gradeId,
                SelectedGroupId = groupId
            };

            // Grados y grupos para dropdowns (alcance por escuela si no es SuperAdmin)
            var gradesQ = _context.GradeLevels.AsNoTracking().IgnoreQueryFilters();
            var groupsQ = _context.Groups.AsNoTracking().IgnoreQueryFilters();
            if (!callerIsSuperAdmin && callerSchoolId.HasValue)
            {
                gradesQ = gradesQ.Where(g => g.SchoolId == callerSchoolId.Value);
                groupsQ = groupsQ.Where(g => g.SchoolId == callerSchoolId.Value);
            }
            else if (!callerIsSuperAdmin)
            {
                vm.GradeLevels = new List<GradeLevel>();
                vm.Groups = new List<Group>();
                vm.Users = new List<UserPasswordViewModel>();
                return vm;
            }

            vm.GradeLevels = await gradesQ.OrderBy(g => g.Name).ToListAsync(cancellationToken);
            vm.Groups = await groupsQ.OrderBy(g => g.Name).ToListAsync(cancellationToken);

            var usersQ = _context.Users.IgnoreQueryFilters();
            if (!callerIsSuperAdmin && callerSchoolId.HasValue)
                usersQ = usersQ.Where(u => u.SchoolId == callerSchoolId.Value);

            if (gradeId.HasValue)
            {
                var gid = gradeId.Value;
                usersQ = usersQ.Where(u =>
                    !IsStudentRole(u.Role) ||
                    u.StudentAssignments.Any(sa => sa.IsActive && sa.GradeId == gid));
            }

            if (groupId.HasValue)
            {
                var grId = groupId.Value;
                usersQ = usersQ.Where(u =>
                    !IsStudentRole(u.Role) ||
                    u.StudentAssignments.Any(sa => sa.IsActive && sa.GroupId == grId));
            }

            vm.Users = await usersQ
                .OrderBy(u => u.Name)
                .ThenBy(u => u.LastName)
                .Select(u => new UserPasswordViewModel
                {
                    Id = u.Id,
                    FirstName = u.Name,
                    LastName = u.LastName ?? string.Empty,
                    Email = u.Email,
                    Role = u.Role ?? string.Empty,
                    Grade = u.StudentAssignments
                        .Where(sa => sa.IsActive)
                        .OrderByDescending(sa => sa.CreatedAt)
                        .Select(sa => sa.Grade.Name)
                        .FirstOrDefault() ?? "-",
                    Group = u.StudentAssignments
                        .Where(sa => sa.IsActive)
                        .OrderByDescending(sa => sa.CreatedAt)
                        .Select(sa => sa.Group.Name)
                        .FirstOrDefault() ?? "-",
                    Status = u.Status ?? string.Empty,
                    PasswordEmailStatus = u.PasswordEmailStatus,
                    PasswordEmailSentAt = u.PasswordEmailSentAt,
                    CreatedAt = u.CreatedAt
                })
                .ToListAsync(cancellationToken);

            return vm;
        }
    }
}
