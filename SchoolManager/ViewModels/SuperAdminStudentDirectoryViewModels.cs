using Microsoft.AspNetCore.Mvc.Rendering;

namespace SchoolManager.ViewModels;

public class SuperAdminStudentDirectoryFilterVm
{
    public string? Search { get; set; }
    public Guid? SchoolId { get; set; }
    public Guid? GradeId { get; set; }
    public Guid? GroupId { get; set; }
    public Guid? ShiftId { get; set; }

    /// <summary>Todos | active | inactive</summary>
    public string? UserStatus { get; set; }

    public bool OnlyWithoutAssignment { get; set; }
}

public class SuperAdminStudentDirectoryRowVm
{
    public Guid UserId { get; set; }
    public Guid? AssignmentId { get; set; }
    public string FullName { get; set; } = "";
    public string? DocumentId { get; set; }
    public string Email { get; set; } = "";
    public string? SchoolName { get; set; }
    public Guid? SchoolId { get; set; }
    public string? GradeLevelName { get; set; }
    public string? GroupName { get; set; }
    public string? ShiftName { get; set; }
    public string? UserShift { get; set; }
    public string Status { get; set; } = "";
    public bool HasActiveAssignment { get; set; }
}

public class SuperAdminStudentDirectoryPageVm
{
    public SuperAdminStudentDirectoryFilterVm Filter { get; set; } = new();
    public List<SuperAdminStudentDirectoryRowVm> Rows { get; set; } = new();
    public List<SelectListItem> SchoolOptions { get; set; } = new();
    public List<SelectListItem> GradeOptions { get; set; } = new();
    public List<SelectListItem> GroupOptions { get; set; } = new();
    public List<SelectListItem> ShiftOptions { get; set; } = new();
}
