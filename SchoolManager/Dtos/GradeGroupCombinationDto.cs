using System;

namespace SchoolManager.Dtos
{
    public class GradeGroupCombinationDto
    {
        public Guid GradeId { get; set; }
        public string GradeName { get; set; } = string.Empty;
        public Guid GroupId { get; set; }
        public string GroupName { get; set; } = string.Empty;
        public string GroupGrade { get; set; } = string.Empty;
        public int StudentCount { get; set; }
        public string DisplayText => $"{GradeName} - {GroupName} ({StudentCount} estudiantes)";
    }
}
