using System;

namespace SchoolManager.Dtos;

/// <summary>
/// Promedio por estudiante y materia en un trimestre (vista consejería, sin filtro por docente).
/// </summary>
public sealed class CounselorSubjectAverageDto
{
    public Guid StudentId { get; set; }
    public Guid SubjectId { get; set; }
    public double AverageScore { get; set; }
}
