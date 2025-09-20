// Services/ActivityTypeService.cs
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Enums;
using SchoolManager.Interfaces;
using SchoolManager.Models;   // SchoolDbContext, ActivityTypes
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations
{
    /// <summary>
    /// Devuelve la lista de tipos de actividad (tarea, parcial, examen…).
    /// </summary>
    public class ActivityTypeService : IActivityTypeService
    {
        private readonly SchoolDbContext _context;
        private readonly ICurrentUserService _currentUserService;

        public ActivityTypeService(SchoolDbContext context, ICurrentUserService currentUserService)
        {
            _context = context;
            _currentUserService = currentUserService;
        }

        public async Task<IEnumerable<ActivityTypeDto>> GetAllAsync()
        {
            var types = await _context.ActivityTypes
                .Where(t => t.IsActive)
                .OrderBy(t => t.DisplayOrder)
                .ThenBy(t => t.Name)
                .Select(t => new ActivityTypeDto
                {
                    Id = t.Id,
                    Name = t.Name
                })
                .ToListAsync();

            // Si no hay tipos en la base de datos, devolver los tipos por defecto del enum
            if (!types.Any())
            {
                return GetDefaultActivityTypes();
            }

            return types;
        }

        /// <summary>
        /// Obtiene los tipos de actividad por defecto desde el enum
        /// </summary>
        private static IEnumerable<ActivityTypeDto> GetDefaultActivityTypes()
        {
            return Enum.GetValues(typeof(ActivityTypeEnum))
                .Cast<ActivityTypeEnum>()
                .Select(GetActivityTypeDto)
                .ToList();
        }

        /// <summary>
        /// Obtiene el DTO con nombre interno y nombre para mostrar
        /// </summary>
        private static ActivityTypeDto GetActivityTypeDto(ActivityTypeEnum enumValue)
        {
            var (displayName, internalValue) = enumValue switch
            {
                ActivityTypeEnum.NotasDeApreciacion => ("Notas de apreciación", "tarea"),
                ActivityTypeEnum.EjerciciosDiarios => ("Ejercicios Diarios", "parcial"),
                ActivityTypeEnum.Examen => ("Examen", "examen"),
                _ => (enumValue.ToString(), enumValue.ToString().ToLower())
            };

            return new ActivityTypeDto
            {
                Id = Guid.Empty,
                Name = internalValue, // Valor interno que espera el JavaScript
                DisplayName = displayName // Nombre bonito para mostrar en el dropdown
            };
        }
    }
}
