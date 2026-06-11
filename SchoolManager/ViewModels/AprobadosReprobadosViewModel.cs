using System.ComponentModel.DataAnnotations;

namespace SchoolManager.ViewModels
{
    /// <summary>
    /// ViewModel para el reporte de aprobados y reprobados por grado
    /// </summary>
    public class AprobadosReprobadosReportViewModel
    {
        public string InstitutoNombre { get; set; } = null!;
        public string LogoUrl { get; set; } = null!;
        public string ProfesorCoordinador { get; set; } = null!;
        public string Trimestre { get; set; } = null!;
        public string AnoLectivo { get; set; } = null!;
        public string NivelEducativo { get; set; } = null!; // Etiqueta del grado (ej. 1°, 9°) o "Todos mis niveles"
        public DateTime FechaGeneracion { get; set; }
        
        public List<GradoEstadisticaDto> Estadisticas { get; set; } = new();
        public TotalesGeneralesDto TotalesGenerales { get; set; } = new();
        
        // Para filtros
        public List<string> TrimestresDisponibles { get; set; } = new();
        public List<string> NivelesDisponibles { get; set; } = new();

        /// <summary>Muestra columna Materia cuando el reporte incluye varias asignaturas.</summary>
        public bool MostrarColumnaMateria { get; set; }

        /// <summary>Reporte de todas las asignaciones del alcance (docente o escuela).</summary>
        public bool EsConsolidado { get; set; }

        public int CantidadAsignaciones { get; set; }
    }

    /// <summary>
    /// Estadísticas por grado y grupo
    /// </summary>
    public class GradoEstadisticaDto
    {
        public string? Materia { get; set; }
        public string Grado { get; set; } = null!;
        public string Grupo { get; set; } = null!;
        public int TotalEstudiantes { get; set; }
        
        // Aprobados
        public int Aprobados { get; set; }
        public decimal PorcentajeAprobados { get; set; }
        
        // Reprobados
        public int Reprobados { get; set; }
        public decimal PorcentajeReprobados { get; set; }
        
        // Reprobados hasta la fecha
        public int ReprobadosHastaLaFecha { get; set; }
        public decimal PorcentajeReprobadosHastaLaFecha { get; set; }
        
        // Sin calificaciones
        public int SinCalificaciones { get; set; }
        public decimal PorcentajeSinCalificaciones { get; set; }
        
        // Retirados
        public int Retirados { get; set; }
        public decimal PorcentajeRetirados { get; set; }
    }

    /// <summary>
    /// Totales generales del reporte
    /// </summary>
    public class TotalesGeneralesDto
    {
        public int TotalEstudiantes { get; set; }
        public int TotalAprobados { get; set; }
        public decimal PorcentajeAprobados { get; set; }
        public int TotalReprobados { get; set; }
        public decimal PorcentajeReprobados { get; set; }
        public int TotalReprobadosHastaLaFecha { get; set; }
        public decimal PorcentajeReprobadosHastaLaFecha { get; set; }
        public int TotalSinCalificaciones { get; set; }
        public decimal PorcentajeSinCalificaciones { get; set; }
        public int TotalRetirados { get; set; }
        public decimal PorcentajeRetirados { get; set; }
    }

    /// <summary>
    /// ViewModel para los filtros del reporte
    /// </summary>
    public class AprobadosReprobadosFiltroViewModel
    {
        [Required(ErrorMessage = "Debe seleccionar un trimestre")]
        public string Trimestre { get; set; } = null!;

        /// <summary>Guid del grade_level, o __TODOS__ para todos los grados del alcance.</summary>
        [Required(ErrorMessage = "Debe seleccionar un nivel (grado)")]
        public string NivelEducativo { get; set; } = null!;

        /// <summary>Guid.Empty = todas las materias.</summary>
        public Guid MateriaId { get; set; }

        /// <summary>Guid.Empty = todos los grupos.</summary>
        public Guid GroupId { get; set; }

        /// <summary>Guid.Empty = todos los grupos (junto con GroupId).</summary>
        public Guid GradeLevelId { get; set; }
    }
}

