using System.Reflection;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Controllers;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

public class TeacherGradebookExportAuthorizationTests
{
    [Fact]
    public void Controller_RequiresAuthenticatedTeacherRole()
    {
        var attr = typeof(TeacherGradebookController).GetCustomAttribute<AuthorizeAttribute>();
        Assert.NotNull(attr);
        Assert.Equal("teacher", attr!.Roles);
        Assert.Null(typeof(TeacherGradebookController).GetCustomAttribute<AllowAnonymousAttribute>());
    }

    [Fact]
    public void ExportRegistroExcel_IsGet_AndDoesNotAllowAnonymous()
    {
        var method = typeof(TeacherGradebookController).GetMethod(nameof(TeacherGradebookController.ExportRegistroExcel));
        Assert.NotNull(method);
        Assert.NotNull(method!.GetCustomAttribute<HttpGetAttribute>());
        Assert.Null(method.GetCustomAttribute<AllowAnonymousAttribute>());
        Assert.Null(method.GetCustomAttribute<AuthorizeAttribute>());
    }

    [Fact]
    public void ExportRegistroExcel_DoesNotAcceptTeacherIdParameter()
    {
        var method = typeof(TeacherGradebookController).GetMethod(nameof(TeacherGradebookController.ExportRegistroExcel));
        var names = method!.GetParameters().Select(p => p.Name).ToArray();
        Assert.Equal(new[] { "groupId", "trimester", "subjectId", "gradeLevelId" }, names);
        Assert.DoesNotContain("teacherId", names, StringComparer.OrdinalIgnoreCase);
    }

    [Fact]
    public void IndexView_ContainsExcelButtonAndEndpoint_WithoutWindowOpen()
    {
        var path = Path.Combine(FindRepoRoot(), "SchoolManager", "Views", "TeacherGradebook", "Index.cshtml");
        var source = File.ReadAllText(path);
        Assert.Contains("Exportar Excel", source);
        Assert.Contains("btnExportRegistroExcel", source);
        Assert.Contains("/TeacherGradebook/ExportRegistroExcel", source);
        Assert.Contains("aria-label=\"Exportar registro a Excel\"", source);
        var excelBlockStart = source.IndexOf("exportRegistroExcel", StringComparison.Ordinal);
        Assert.True(excelBlockStart > 0);
        var excelBlock = source[excelBlockStart..];
        Assert.DoesNotContain("window.open", excelBlock.Split("syncGradebookExportButtons")[0]);
    }

    [Fact]
    public void ExcelAndPdf_ShareCanonicalRegistroService()
    {
        var pdf = File.ReadAllText(Path.Combine(FindRepoRoot(), "SchoolManager", "Services", "Implementations", "TeacherGradebookPdfService.cs"));
        var excel = File.ReadAllText(Path.Combine(FindRepoRoot(), "SchoolManager", "Services", "Implementations", "TeacherGradebookExcelService.cs"));
        Assert.Contains("ITeacherGradebookRegistroService", pdf);
        Assert.Contains("ITeacherGradebookRegistroService", excel);
        Assert.Contains("GetRegistroAsync", pdf);
        Assert.Contains("GetRegistroAsync", excel);
        Assert.DoesNotContain("GetGradeBookAsync", excel);
        Assert.DoesNotContain("GetGradeBookAsync", pdf);
    }

    [Fact]
    public void CanonicalRegistro_IsReadOnlyLinq()
    {
        var source = File.ReadAllText(Path.Combine(
            FindRepoRoot(),
            "SchoolManager",
            "Services",
            "Implementations",
            "TeacherGradebookRegistroService.cs"));
        Assert.DoesNotContain("SaveChanges", source);
        Assert.DoesNotContain("ExecuteDelete", source);
        Assert.DoesNotContain("ExecuteUpdate", source);
        Assert.DoesNotContain("_context.Add", source);
        Assert.Contains("AsNoTracking()", source);
    }

    private static string FindRepoRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir != null)
        {
            if (File.Exists(Path.Combine(dir.FullName, "SchoolManager.sln")))
                return dir.FullName;
            dir = dir.Parent;
        }

        return Directory.GetCurrentDirectory();
    }
}

public class GradebookExportFileNameTests
{
    [Fact]
    public void BuildXlsx_SanitizesInvalidAndPathCharacters()
    {
        var name = GradebookExportFileName.BuildXlsx("1T", "9 G", "CÍVICA");
        Assert.Equal("Registro_Calificaciones_1T_9 G_CÍVICA.xlsx", name);

        var unsafeName = GradebookExportFileName.BuildXlsx("1T/../x", "9\\G", "Cívica:A");
        Assert.DoesNotContain("..", unsafeName);
        Assert.DoesNotContain("/", unsafeName);
        Assert.DoesNotContain("\\", unsafeName);
        Assert.DoesNotContain(":", unsafeName);
        Assert.EndsWith(".xlsx", unsafeName);
    }
}

public class GradebookExcelSafetyTests
{
    [Theory]
    [InlineData("=1+1", true)]
    [InlineData("+2+2", true)]
    [InlineData("-SUM(A1)", true)]
    [InlineData("@SUM(A1)", true)]
    [InlineData("Abadía, Yosuan", false)]
    [InlineData("8-123-001", false)]
    [InlineData("", false)]
    public void NeedsFormulaGuard_DetectsExcelFormulaPrefixes(string value, bool expected)
    {
        Assert.Equal(expected, GradebookExcelSafety.NeedsFormulaGuard(value));
    }

    [Fact]
    public void AsSafeExcelText_PrefixesDangerousValues()
    {
        Assert.Equal("'=1+1", GradebookExcelSafety.AsSafeExcelText("=1+1"));
        Assert.Equal("Abadía, Yosuan", GradebookExcelSafety.AsSafeExcelText("Abadía, Yosuan"));
    }
}
