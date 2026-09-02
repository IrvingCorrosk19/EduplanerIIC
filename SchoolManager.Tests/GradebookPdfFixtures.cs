using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

internal static class GradebookPdfFixtures
{
    public static GradebookPdfDto SanMiguelitoCivica9G(
        int exerciseCount = 8,
        int studentCount = 5,
        bool withRecovery = false)
    {
        var appreciation = NamedActivities("notas de apreciación", "Aprec", 4);
        var exercises = NamedActivities("ejercicios diarios", "Ejercicio", exerciseCount);
        var exam = NamedActivities("examen final", "Examen", 1);
        var recovery = withRecovery
            ? NamedActivities("recuperación", "Recuperación", 1)
            : new List<ActivityHeaderDto>();

        var headers = appreciation.Concat(exercises).Concat(exam).Concat(recovery).ToList();
        var sections = GradebookVisibleActivitySelector.SelectVisibleColumns(headers).ToList();

        var names = new[]
        {
            ("Abadía, Yosuan", "8-123-001"),
            ("Agrazal, Stephany", "8-123-002"),
            ("Alvarado P., Amado E.", "8-123-003"),
            ("Amagara M., Xavier A.", "8-123-004"),
            ("Arauaz, Ruth", "8-123-005")
        };

        var extra = Enumerable.Range(6, Math.Max(0, studentCount - 5))
            .Select(i => ($"Estudiante Extra {i:00}, Nombre Muy Largo Para Verificar Envoltorio", $"8-999-{i:000}"));

        var people = names.Concat(extra).Take(studentCount).ToList();
        var students = new List<GradebookPdfStudentRowDto>();
        var n = 1;
        foreach (var (fullName, doc) in people)
        {
            var scores = new Dictionary<Guid, decimal?>();
            foreach (var section in sections)
            {
                var i = 0;
                foreach (var act in section.Activities)
                {
                    scores[act.Id] = SeedScore(n, i, section.TypeKey);
                    i++;
                }
            }

            var typeAvgs = new Dictionary<string, decimal>();
            var typesWithScores = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var section in sections)
            {
                var cells = section.Activities
                    .Select(a => GradebookVisibleActivitySelector.ResolveScore(a, scores))
                    .ToList();
                if (GradebookFinalGradeCalculator.HasAnyScore(cells))
                    typesWithScores.Add(section.TypeKey);
                typeAvgs[section.TypeKey] = GradebookFinalGradeCalculator.TruncatedAverageOrZero(cells);
            }

            var final = GradebookFinalGradeCalculator.ComputeFinalGradeFromTypeAverages(typeAvgs, typesWithScores) ?? 0m;

            students.Add(new GradebookPdfStudentRowDto
            {
                Number = n++,
                Name = fullName,
                DocumentId = doc,
                ScoresByActivityId = scores,
                TypeAverages = typeAvgs,
                FinalGrade = final
            });
        }

        return new GradebookPdfDto
        {
            SchoolName = "Instituto Profesional y Técnico San Miguelito",
            TeacherName = "GERTRUDIS KIRTON WINTER",
            SubjectName = "CÍVICA",
            GroupLabel = "9 G",
            Trimester = "1T",
            AcademicYear = "2026",
            GradeLevelName = "9",
            GroupName = "G",
            GeneratedAt = new DateTime(2026, 9, 1, 21, 0, 0, DateTimeKind.Utc),
            GeneratedAtDisplay = "01/09/2026 16:00",
            TypeSections = sections,
            Students = students
        };
    }

    public static List<ActivityHeaderDto> NamedActivities(string type, string prefix, int count) =>
        Enumerable.Range(1, count)
            .Select(i => new ActivityHeaderDto
            {
                Id = Guid.Parse($"00000000-0000-0000-0000-{(TypeSalt(type) + i):D12}"),
                Name = $"{prefix} {i}",
                Type = type,
                DueDate = new DateTime(2026, 4, Math.Clamp(i, 1, 28), 0, 0, 0, DateTimeKind.Utc)
            })
            .ToList();

    private static int TypeSalt(string type) => type switch
    {
        "notas de apreciación" => 1000,
        "ejercicios diarios" => 2000,
        "examen final" => 3000,
        "recuperación" => 4000,
        _ => 9000
    };

    private static decimal? SeedScore(int studentNumber, int activityIndex, string typeKey)
    {
        if (studentNumber == 3 && activityIndex == 0 && typeKey == "ejercicios diarios")
            return null;
        if (studentNumber == 5 && activityIndex == 1 && typeKey == "notas de apreciación")
            return 0.0m;

        var raw = 3.0m + (studentNumber % 3) * 0.53m + activityIndex * 0.11m;
        if (raw > 5m) raw = 5m;
        return GradebookFinalGradeCalculator.TruncateOneDecimal(raw);
    }
}
