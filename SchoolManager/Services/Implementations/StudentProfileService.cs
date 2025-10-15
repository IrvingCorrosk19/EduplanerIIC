using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;

namespace SchoolManager.Services.Implementations
{
    /// <summary>
    /// Implementación del servicio de perfil de estudiantes
    /// </summary>
    public class StudentProfileService : IStudentProfileService
    {
        private readonly SchoolDbContext _context;
        private readonly ILogger<StudentProfileService> _logger;

        public StudentProfileService(SchoolDbContext context, ILogger<StudentProfileService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<StudentProfileViewModel?> GetStudentProfileAsync(Guid studentId)
        {
            try
            {
                _logger.LogInformation("📋 Obteniendo perfil del estudiante: {StudentId}", studentId);

                var user = await _context.Users
                    .Where(u => u.Id == studentId && (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante"))
                    .Select(u => new
                    {
                        u.Id,
                        u.Name,
                        u.LastName,
                        u.Email,
                        u.DocumentId,
                        u.DateOfBirth,
                        u.CellphonePrimary,
                        u.CellphoneSecondary,
                        u.Role,
                        u.SchoolId
                    })
                    .FirstOrDefaultAsync();

                if (user == null)
                {
                    _logger.LogWarning("⚠️ Usuario no encontrado o no es estudiante: {StudentId}", studentId);
                    return null;
                }

                // Obtener información de asignación (grado y grupo)
                var assignment = await _context.StudentAssignments
                    .Where(sa => sa.StudentId == studentId)
                    .Join(_context.GradeLevels,
                          sa => sa.GradeId,
                          gl => gl.Id,
                          (sa, gl) => new { sa.GroupId, GradeName = gl.Name })
                    .Join(_context.Groups,
                          sa => sa.GroupId,
                          g => g.Id,
                          (sa, g) => new { GradeName = sa.GradeName, GroupName = g.Name })
                    .FirstOrDefaultAsync();

                // Obtener nombre de la escuela
                var school = user.SchoolId.HasValue
                    ? await _context.Schools
                        .Where(s => s.Id == user.SchoolId.Value)
                        .Select(s => s.Name)
                        .FirstOrDefaultAsync()
                    : null;

                var profile = new StudentProfileViewModel
                {
                    Id = user.Id,
                    Name = user.Name,
                    LastName = user.LastName,
                    Email = user.Email,
                    DocumentId = user.DocumentId,
                    DateOfBirth = user.DateOfBirth,
                    CellphonePrimary = user.CellphonePrimary,
                    CellphoneSecondary = user.CellphoneSecondary,
                    Role = user.Role,
                    Grade = assignment?.GradeName,
                    GroupName = assignment?.GroupName,
                    SchoolName = school
                };

                _logger.LogInformation("✅ Perfil obtenido correctamente para: {Name} {LastName}", user.Name, user.LastName);
                return profile;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error obteniendo perfil del estudiante: {StudentId}", studentId);
                throw;
            }
        }

        public async Task<bool> UpdateStudentProfileAsync(StudentProfileViewModel model)
        {
            try
            {
                _logger.LogInformation("📝 Actualizando perfil del estudiante: {StudentId}", model.Id);

                var user = await _context.Users.FindAsync(model.Id);

                if (user == null || (user.Role.ToLower() != "student" && user.Role.ToLower() != "estudiante"))
                {
                    _logger.LogWarning("⚠️ Usuario no encontrado o no es estudiante: {StudentId}", model.Id);
                    return false;
                }

                // Validar que el email no esté en uso
                if (user.Email != model.Email)
                {
                    var emailInUse = await _context.Users
                        .AnyAsync(u => u.Email == model.Email && u.Id != model.Id);

                    if (emailInUse)
                    {
                        _logger.LogWarning("⚠️ El email ya está en uso: {Email}", model.Email);
                        return false;
                    }
                }

                // Validar que el documento de identidad no esté en uso
                if (!string.IsNullOrEmpty(model.DocumentId) && user.DocumentId != model.DocumentId)
                {
                    var documentInUse = await _context.Users
                        .AnyAsync(u => u.DocumentId == model.DocumentId && u.Id != model.Id);

                    if (documentInUse)
                    {
                        _logger.LogWarning("⚠️ El documento de identidad ya está en uso: {DocumentId}", model.DocumentId);
                        return false;
                    }
                }

                // Actualizar solo los campos permitidos
                user.Name = model.Name;
                user.LastName = model.LastName;
                user.Email = model.Email;
                user.DocumentId = model.DocumentId;
                user.DateOfBirth = model.DateOfBirth;
                user.CellphonePrimary = model.CellphonePrimary;
                user.CellphoneSecondary = model.CellphoneSecondary;
                user.UpdatedAt = DateTime.UtcNow;
                user.UpdatedBy = model.Id; // El estudiante se actualiza a sí mismo

                await _context.SaveChangesAsync();

                _logger.LogInformation("✅ Perfil actualizado correctamente: {Name} {LastName}", user.Name, user.LastName);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error actualizando perfil del estudiante: {StudentId}", model.Id);
                throw;
            }
        }

        public async Task<bool> IsEmailAvailableAsync(string email, Guid currentUserId)
        {
            try
            {
                var exists = await _context.Users
                    .AnyAsync(u => u.Email == email && u.Id != currentUserId);

                return !exists;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error validando disponibilidad de email: {Email}", email);
                return false;
            }
        }

        public async Task<bool> IsDocumentIdAvailableAsync(string? documentId, Guid currentUserId)
        {
            if (string.IsNullOrEmpty(documentId))
                return true;

            try
            {
                var exists = await _context.Users
                    .AnyAsync(u => u.DocumentId == documentId && u.Id != currentUserId);

                return !exists;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error validando disponibilidad de documento: {DocumentId}", documentId);
                return false;
            }
        }
    }
}

