using System;
using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;

namespace SchoolManager.Models;

/// <summary>
/// Configuración de jornada escolar por escuela. Una sola por escuela.
/// Define horario de mañana (y opcionalmente tarde) para generar bloques (TimeSlots) automáticamente.
/// Horas en formato 24 h (07:00, 13:00) estándar en la aplicación.
/// </summary>
public class SchoolScheduleConfiguration
{
    public Guid Id { get; set; }
    public Guid SchoolId { get; set; }

    /// <summary>Hora de inicio de la jornada de mañana (formato 24 h, ej. 07:00).</summary>
    [DisplayFormat(DataFormatString = "{0:HH:mm}", ApplyFormatInEditMode = true)]
    public TimeOnly MorningStartTime { get; set; }
    public int MorningBlockDurationMinutes { get; set; }
    public int MorningBlockCount { get; set; }

    /// <summary>Hora de inicio de la jornada de tarde (formato 24 h, ej. 13:00); null si solo hay mañana.</summary>
    [DisplayFormat(DataFormatString = "{0:HH:mm}", ApplyFormatInEditMode = true)]
    public TimeOnly? AfternoonStartTime { get; set; }
    public int? AfternoonBlockDurationMinutes { get; set; }
    public int? AfternoonBlockCount { get; set; }

    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    [ValidateNever]
    public virtual School School { get; set; } = null!;
}
