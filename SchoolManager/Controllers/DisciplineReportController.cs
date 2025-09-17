using Microsoft.AspNetCore.Mvc;
using SchoolManager.Models;
using SchoolManager.Dtos;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using SchoolManager.Services.Interfaces;

public class DisciplineReportController : Controller
{
    private readonly IDisciplineReportService _disciplineReportService;
    private readonly IUserService _userService;
    private readonly IEmailService _emailService;
    private readonly ILogger<DisciplineReportController> _logger;

    public DisciplineReportController(
        IDisciplineReportService disciplineReportService, 
        IUserService userService,
        IEmailService emailService,
        ILogger<DisciplineReportController> logger)
    {
        _disciplineReportService = disciplineReportService;
        _userService = userService;
        _emailService = emailService;
        _logger = logger;
    }

    public async Task<IActionResult> Index()
    {
        var reports = await _disciplineReportService.GetAllAsync();
        return View(reports);
    }

    public async Task<IActionResult> Details(Guid id)
    {
        var report = await _disciplineReportService.GetByIdAsync(id);
        if (report == null) return NotFound();
        return View(report);
    }

    public IActionResult Create() => View();

    [HttpPost]
    public async Task<IActionResult> CreateWithFiles()
    {
        try
        {
            // Obtener datos del formulario
            var studentId = Request.Form["StudentId"].ToString();
            var teacherId = Request.Form["TeacherId"].ToString();
            var subjectId = Request.Form["SubjectId"].ToString();
            var groupId = Request.Form["GroupId"].ToString();
            var gradeLevelId = Request.Form["GradeLevelId"].ToString();
            var date = Request.Form["Date"].ToString();
            var hora = Request.Form["Hora"].ToString();
            var reportType = Request.Form["ReportType"].ToString();
            var status = Request.Form["Status"].ToString();
            var description = Request.Form["Description"].ToString();
            var category = Request.Form["Category"].ToString();

            // Validar datos requeridos
            if (string.IsNullOrEmpty(studentId) || string.IsNullOrEmpty(teacherId) || string.IsNullOrEmpty(date) || string.IsNullOrEmpty(hora))
            {
                return Json(new { success = false, error = "Datos requeridos faltantes" });
            }

            // Procesar archivos si existen
            var documentsJson = "";
            var files = Request.Form.Files.Where(f => f.Name == "Documents").ToList();
            if (files.Any())
            {
                var documentList = new List<object>();
                foreach (var file in files)
                {
                    if (file.Length > 0)
                    {
                        // Crear directorio si no existe
                        var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "discipline");
                        if (!Directory.Exists(uploadsPath))
                        {
                            Directory.CreateDirectory(uploadsPath);
                        }

                        // Generar nombre único para el archivo
                        var fileName = $"{Guid.NewGuid()}_{file.FileName}";
                        var filePath = Path.Combine(uploadsPath, fileName);

                        // Guardar archivo
                        using (var stream = new FileStream(filePath, FileMode.Create))
                        {
                            await file.CopyToAsync(stream);
                        }

                        documentList.Add(new
                        {
                            fileName = file.FileName,
                            savedName = fileName,
                            size = file.Length,
                            uploadDate = DateTime.UtcNow
                        });
                    }
                }
                documentsJson = System.Text.Json.JsonSerializer.Serialize(documentList);
            }

            var disciplineReport = new DisciplineReport
            {
                Id = Guid.NewGuid(),
                StudentId = Guid.Parse(studentId),
                TeacherId = Guid.Parse(teacherId),
                SubjectId = !string.IsNullOrEmpty(subjectId) ? Guid.Parse(subjectId) : (Guid?)null,
                GroupId = !string.IsNullOrEmpty(groupId) ? Guid.Parse(groupId) : (Guid?)null,
                GradeLevelId = !string.IsNullOrEmpty(gradeLevelId) ? Guid.Parse(gradeLevelId) : (Guid?)null,
                Date = DateTime.SpecifyKind(DateTime.Parse($"{date} {hora}"), DateTimeKind.Local).ToUniversalTime(),
                ReportType = reportType,
                Status = status,
                Description = description,
                Category = category,
                Documents = documentsJson,
                CreatedAt = DateTime.UtcNow
            };

            try
            {
                await _disciplineReportService.CreateAsync(disciplineReport);
                return Json(new { success = true, message = "Registro guardado correctamente", disciplineReportId = disciplineReport.Id });
            }
            catch (DbUpdateException ex)
            {
                _logger.LogError(ex, "Error al guardar en la base de datos");
                return Json(new { success = false, error = "Error al guardar en la base de datos", details = ex.InnerException?.Message });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear el reporte de disciplina");
            return Json(new { success = false, error = "Error al crear el reporte", details = ex.Message });
        }
    }

    public async Task<IActionResult> Edit(Guid id)
    {
        var report = await _disciplineReportService.GetByIdAsync(id);
        if (report == null) return NotFound();
        return View(report);
    }

    [HttpPost]
    public async Task<IActionResult> Edit(DisciplineReport report)
    {
        if (ModelState.IsValid)
        {
            await _disciplineReportService.UpdateAsync(report);
            return RedirectToAction(nameof(Index));
        }
        return View(report);
    }

    public async Task<IActionResult> Delete(Guid id)
    {
        var report = await _disciplineReportService.GetByIdAsync(id);
        if (report == null) return NotFound();
        return View(report);
    }

    [HttpPost, ActionName("Delete")]
    public async Task<IActionResult> DeleteConfirmed(Guid id)
    {
        await _disciplineReportService.DeleteAsync(id);
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public async Task<IActionResult> GetByStudent(Guid studentId)
    {
        var reports = await _disciplineReportService.GetByStudentDtoAsync(studentId);
        return Json(reports.Select(r => new {
            date = r.Date,
            time = r.Date.ToString("HH:mm"),
            type = r.Type,
            categoria = r.Category,
            status = r.Status,
            description = r.Description,
            documents = r.Documents,
            teacher = r.Teacher
        }));
    }

    [HttpGet]
    public async Task<IActionResult> GetFiltered(DateTime? fechaInicio, DateTime? fechaFin, Guid? gradoId, Guid? groupId = null, Guid? studentId = null)
    {
        if (!gradoId.HasValue)
        {
            return BadRequest(new { error = "El grado es obligatorio" });
        }

        try
        {
            var reports = await _disciplineReportService.GetFilteredAsync(fechaInicio, fechaFin, gradoId, groupId, studentId);
            
            var result = reports.Select(r => new {
                estudiante = r.Student != null ? $"{r.Student.Name} {r.Student.LastName}" : null,
                documentId = r.Student?.DocumentId,
                fecha = r.Date.ToString("dd/MM/yyyy"),
                hora = r.Date.ToString("HH:mm"),
                tipo = r.ReportType,
                categoria = r.Category,
                status = r.Status,
                description = r.Description,
                documents = r.Documents,
                grupo = r.Group?.Name,
                grado = r.GradeLevel?.Name
            });

            return Json(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet]
    public async Task<IActionResult> ExportToExcel(DateTime? fechaInicio, DateTime? fechaFin, Guid? gradoId)
    {
        var reports = await _disciplineReportService.GetFilteredAsync(fechaInicio, fechaFin, gradoId);
        var csv = "Estudiante,Fecha,Tipo,Estado,Descripción\n" +
            string.Join("\n", reports.Select(r => $"{(r.Student != null ? r.Student.Name : "")},{r.Date:yyyy-MM-dd},{r.ReportType},{r.Status},{r.Description}"));
        var bytes = System.Text.Encoding.UTF8.GetBytes(csv);
        return File(bytes, "text/csv", "registros_disciplina.csv");
    }

    [HttpPost]
    public async Task<IActionResult> SendEmailToStudent([FromBody] SendDisciplineEmailDto request)
    {
        try
        {
            if (request.StudentId == Guid.Empty || request.DisciplineReportId == Guid.Empty)
            {
                return Json(new { success = false, message = "ID de estudiante y reporte son requeridos" });
            }

            var success = await _emailService.SendDisciplineReportEmailAsync(
                request.StudentId, 
                request.DisciplineReportId, 
                request.CustomMessage ?? "");

            if (success)
            {
                return Json(new { success = true, message = "Correo enviado exitosamente al estudiante" });
            }
            else
            {
                return Json(new { success = false, message = "Error al enviar el correo. Verifique que el estudiante tenga email configurado y que la configuración SMTP esté activa." });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar correo disciplinario");
            return Json(new { success = false, message = "Error interno del servidor al enviar el correo" });
        }
    }
}
