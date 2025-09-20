namespace SchoolManager.Dtos
{
    public class HistorialAsistenciaFiltroDto
    {
        public Guid GroupId { get; set; }
        public Guid GradeId { get; set; }
        public string? FechaInicio { get; set; }
        public string? FechaFin { get; set; }
        public string? StudentId { get; set; }
    }
} 