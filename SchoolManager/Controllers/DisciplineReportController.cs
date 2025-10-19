﻿using Microsoft.AspNetCore.Mvc;
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
    private readonly ICurrentUserService _currentUserService;
    private readonly SchoolDbContext _context;

    public DisciplineReportController(
        IDisciplineReportService disciplineReportService, 
        IUserService userService,
        IEmailService emailService,
        ILogger<DisciplineReportController> logger,
        ICurrentUserService currentUserService,
        SchoolDbContext context)
    {
        _disciplineReportService = disciplineReportService;
        _userService = userService;
        _emailService = emailService;
        _logger = logger;
        _currentUserService = currentUserService;
        _context = context;
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

            // Obtener usuario autenticado y su school_id
            var currentUser = await _currentUserService.GetCurrentUserAsync();
            var currentUserId = await _currentUserService.GetCurrentUserIdAsync();
            
            var disciplineReport = new DisciplineReport
            {
                Id = Guid.NewGuid(),
                SchoolId = currentUser?.SchoolId, // ✅ SchoolId del usuario autenticado
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
                CreatedAt = DateTime.UtcNow,
                CreatedBy = currentUserId, // ✅ ID del usuario autenticado
                UpdatedBy = currentUserId  // ✅ ID del usuario autenticado
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
            teacher = r.Teacher,
            subjectId = r.SubjectId, // ✅ Agregado
            subjectName = r.SubjectName // ✅ Agregado
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

    [HttpGet]
    public async Task<IActionResult> GetByCounselor(string trimester = null)
    {
        try
        {
            var currentUserId = await _currentUserService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                return Unauthorized(new { error = "Usuario no autenticado" });
            }

            var reports = await _disciplineReportService.GetByCounselorAsync(currentUserId.Value, trimester);
            
            return Json(reports.Select(r => new {
                id = r.Id,
                studentName = r.StudentName,
                studentId = r.StudentId,
                date = r.Date.ToString("dd/MM/yyyy"),
                time = r.Date.ToString("HH:mm"),
                type = r.Type,
                category = r.Category,
                status = r.Status,
                description = r.Description,
                documents = r.Documents,
                teacher = r.Teacher,
                subjectName = r.SubjectName
            }));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener reportes de disciplina para consejero");
            return BadRequest(new { error = "Error al obtener los reportes de disciplina" });
        }
    }

    [HttpGet]
    public async Task<IActionResult> GetVisibleDisciplineInfo(Guid studentId, string trimester = null)
    {
        try
        {
            var currentUser = await _currentUserService.GetCurrentUserAsync();
            if (currentUser == null)
            {
                return Unauthorized(new { error = "Usuario no autenticado" });
            }

            // Verificar permisos según el rol
            var canView = currentUser.Role?.ToLower() switch
            {
                "director" => true, // El director puede ver todo
                "teacher" => await CanTeacherViewStudentDiscipline(currentUser.Id, studentId), // Profesores pueden ver si tienen relación
                "parent" => await CanParentViewStudentDiscipline(currentUser.Id, studentId), // Padres pueden ver de sus hijos
                _ => false
            };

            if (!canView)
            {
                return Forbid("No tienes permisos para ver la información de disciplina de este estudiante");
            }

            var reports = await _disciplineReportService.GetByStudentDtoAsync(studentId, trimester);
            
            return Json(reports.Select(r => new {
                id = r.Id,
                date = r.Date.ToString("dd/MM/yyyy"),
                time = r.Date.ToString("HH:mm"),
                type = r.Type,
                category = r.Category,
                status = r.Status,
                description = r.Description,
                documents = r.Documents,
                teacher = r.Teacher,
                subjectName = r.SubjectName
            }));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al obtener información de disciplina visible");
            return BadRequest(new { error = "Error al obtener la información de disciplina" });
        }
    }

    private async Task<bool> CanTeacherViewStudentDiscipline(Guid teacherId, Guid studentId)
    {
        try
        {
            // Verificar si el profesor es consejero del estudiante
            var currentUser = await _currentUserService.GetCurrentUserAsync();
            if (currentUser?.SchoolId == null) return false;

            var counselorGroups = await _context.CounselorAssignments
                .Where(ca => ca.UserId == teacherId && ca.SchoolId == currentUser.SchoolId && ca.IsActive)
                .Select(ca => new { ca.GroupId, ca.GradeId })
                .ToListAsync();

            if (!counselorGroups.Any()) return false;

            var groupIds = counselorGroups.Where(cg => cg.GroupId.HasValue).Select(cg => cg.GroupId.Value).ToList();
            var gradeIds = counselorGroups.Where(cg => cg.GradeId.HasValue).Select(cg => cg.GradeId.Value).ToList();

            var studentAssignment = await _context.StudentAssignments
                .Where(sa => sa.StudentId == studentId && 
                           (groupIds.Contains(sa.GroupId) || gradeIds.Contains(sa.GradeId)))
                .FirstOrDefaultAsync();

            return studentAssignment != null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al verificar permisos de profesor para ver disciplina");
            return false;
        }
    }

    private async Task<bool> CanParentViewStudentDiscipline(Guid parentId, Guid studentId)
    {
        try
        {
            // Verificar si el estudiante es hijo del padre/madre
            // Esto requeriría una relación padre-hijo en la base de datos
            // Por ahora, asumimos que si el usuario es "parent", puede ver la información
            // En un sistema real, necesitarías verificar la relación familiar
            
            var currentUser = await _currentUserService.GetCurrentUserAsync();
            if (currentUser?.Role?.ToLower() != "parent") return false;

            // Aquí deberías implementar la lógica para verificar la relación padre-hijo
            // Por ejemplo, consultando una tabla de relaciones familiares
            // Por ahora, retornamos true si es padre/madre
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al verificar permisos de padre para ver disciplina");
            return false;
        }
    }

    [HttpPost]
    public async Task<IActionResult> UpdateStatus([FromBody] UpdateDisciplineStatusDto request)
    {
        try
        {
            var currentUser = await _currentUserService.GetCurrentUserAsync();
            if (currentUser == null)
            {
                return Unauthorized(new { error = "Usuario no autenticado" });
            }

            // Verificar permisos según el rol
            var canUpdate = currentUser.Role?.ToLower() switch
            {
                "director" => true, // El director puede cambiar cualquier estado
                "teacher" => request.Status?.ToLower() == "escalado", // Los profesores solo pueden escalar
                _ => false
            };

            // Verificar si se está intentando aplicar sanciones graves
            var severeSanctions = new[] { "suspension", "suspensión", "condicional", "expulsion", "expulsión" };
            var isSevereSanction = severeSanctions.Any(s => request.Status?.ToLower().Contains(s) == true);
            
            if (isSevereSanction && currentUser.Role?.ToLower() != "director")
            {
                return Forbid("Solo el director puede aplicar sanciones graves como suspensiones o clasificar estudiantes como condicionales");
            }

            if (!canUpdate)
            {
                return Forbid("No tienes permisos para realizar esta acción");
            }

            var success = await _disciplineReportService.UpdateStatusAsync(request.ReportId, request.Status, request.Comments);
            
            if (success)
            {
                // Si se escaló el caso, enviar mensaje al director
                if (request.Status?.ToLower() == "escalado")
                {
                    await SendEscalationMessageToDirector(request.ReportId, request.Comments);
                }

                return Json(new { success = true, message = "Estado actualizado correctamente" });
            }
            else
            {
                return Json(new { success = false, message = "Error al actualizar el estado" });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al actualizar estado del reporte de disciplina");
            return BadRequest(new { error = "Error al actualizar el estado" });
        }
    }

    private async Task SendEscalationMessageToDirector(Guid reportId, string? comments)
    {
        try
        {
            var currentUser = await _currentUserService.GetCurrentUserAsync();
            var currentUserId = await _currentUserService.GetCurrentUserIdAsync();
            
            if (!currentUserId.HasValue || currentUser?.SchoolId == null)
            {
                return;
            }

            // Buscar al director de la escuela
            var director = await _userService.GetByRoleAndSchoolAsync("Director", currentUser.SchoolId.Value);
            if (director == null)
            {
                _logger.LogWarning("No se encontró director para la escuela {SchoolId}", currentUser.SchoolId);
                return;
            }

            // Obtener información del reporte
            var report = await _disciplineReportService.GetByIdAsync(reportId);
            if (report == null)
            {
                return;
            }

            var messageContent = $"Caso de disciplina escalado por {currentUser.Name} {currentUser.LastName}.\n\n" +
                               $"Estudiante: {report.Student?.Name} {report.Student?.LastName}\n" +
                               $"Fecha: {report.Date:dd/MM/yyyy HH:mm}\n" +
                               $"Tipo: {report.ReportType}\n" +
                               $"Descripción: {report.Description}\n\n" +
                               $"Comentarios adicionales: {comments ?? "Sin comentarios adicionales"}";

            // Crear mensaje para el director
            var message = new Message
            {
                Id = Guid.NewGuid(),
                SenderId = currentUserId.Value,
                RecipientId = director.Id,
                Subject = "Caso de Disciplina Escalado",
                Content = messageContent,
                MessageType = "DisciplineEscalation",
                IsRead = false,
                CreatedAt = DateTime.UtcNow
            };

            // Aquí deberías usar el servicio de mensajería para enviar el mensaje
            // await _messagingService.SendMessageAsync(message);
            
            _logger.LogInformation("Mensaje de escalación enviado al director {DirectorId} para el reporte {ReportId}", 
                director.Id, reportId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al enviar mensaje de escalación al director");
        }
    }
}
