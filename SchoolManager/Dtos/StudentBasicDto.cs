namespace SchoolManager.Dtos
{
    public class StudentBasicDto
    {
        public Guid StudentId { get; set; }
        public string FullName { get; set; } = "";
        public string GradeName { get; set; } = "";
        public string GroupName { get; set; } = "";
        public string DocumentId { get; set; } = "";

        /// <summary>Indicador de estudiante inclusivo (users.inclusivo).</summary>
        public bool IsInclusive { get; set; }
    }
}
