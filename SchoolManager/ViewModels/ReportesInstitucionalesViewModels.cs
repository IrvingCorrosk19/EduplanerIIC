namespace SchoolManager.ViewModels;

public enum InformeCalificacionesTipo
{
    ExpresionesArtisticas,
    Tecnologia
}

public class ReporteCatalogoItemViewModel
{
    public string Titulo { get; set; } = "";
    public string Descripcion { get; set; } = "";
    public string Icono { get; set; } = "bi-file-earmark-text";
    public string Action { get; set; } = "Index";
    public string Controller { get; set; } = "";
    public bool Disponible { get; set; } = true;
}

public class InformeInstitucionalFiltroViewModel
{
    public string Trimestre { get; set; } = "";
    public string NivelEducativo { get; set; } = "";
    public Guid MateriaId { get; set; }
    public Guid GroupId { get; set; }
    public Guid GradeLevelId { get; set; }
}

public class InformeEstudianteFilaDto
{
    public int Numero { get; set; }
    public Guid StudentId { get; set; }
    public string Nombre { get; set; } = "";
}
