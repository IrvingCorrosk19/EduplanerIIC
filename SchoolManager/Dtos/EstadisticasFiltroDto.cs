namespace SchoolManager.Dtos
{
    public class EstadisticasFiltroDto
    {
        public Guid GroupId { get; set; }
        public Guid GradeId { get; set; }
        public string Trimestre { get; set; }
        public string? FechaInicio { get; set; }
        public string? FechaFin { get; set; }
    }
} 