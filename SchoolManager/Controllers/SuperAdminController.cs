using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services;
using SchoolManager.ViewModels;
using BCrypt.Net;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Controllers;

[Authorize(Roles = "superadmin")]
public class SuperAdminController : Controller
{
    private readonly ISuperAdminService _superAdminService;
    private readonly IWebHostEnvironment _webHostEnvironment;
    private readonly ILogger<SuperAdminController> _logger;

    public SuperAdminController(
        ISuperAdminService superAdminService,
        IWebHostEnvironment webHostEnvironment,
        ILogger<SuperAdminController> logger)
    {
        _superAdminService = superAdminService;
        _webHostEnvironment = webHostEnvironment;
        _logger = logger;
    }

    public IActionResult Index()
    {
        return View();
    }

    // GET: SuperAdmin/CreateSchoolWithAdmin
    public IActionResult CreateSchoolWithAdmin()
    {
        return View();
    }

    // POST: SuperAdmin/CreateSchoolWithAdmin
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CreateSchoolWithAdmin(SchoolAdminViewModel model, IFormFile? logoFile)
    {
        if (ModelState.IsValid)
        {
            try
            {
                var uploadsPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads");
                var success = await _superAdminService.CreateSchoolWithAdminAsync(model, logoFile, uploadsPath);
                
                if (success)
                {
                    TempData["SuccessMessage"] = "Escuela y administrador creados exitosamente.";
                    return RedirectToAction(nameof(ListSchools));
                }
                else
                {
                    ModelState.AddModelError("", "Error al crear la escuela y el administrador.");
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "Error al crear la escuela y el administrador: " + ex.Message);
                _logger.LogError(ex, "Error al crear escuela y administrador");
            }
        }

        return View(model);
    }

    // GET: SuperAdmin/ListSchools
    public async Task<IActionResult> ListSchools(string searchString)
    {
        Console.WriteLine($"🔍 [ListSchools] Cargando lista de escuelas...");
        Console.WriteLine($"🔍 [ListSchools] Filtro de búsqueda: '{searchString}'");
        
        try
        {
            var schools = await _superAdminService.GetAllSchoolsAsync(searchString);
            ViewData["CurrentFilter"] = searchString;
            return View(schools);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"💥 [ListSchools] Error al cargar escuelas: {ex.Message}");
            Console.WriteLine($"📊 [ListSchools] Stack Trace: {ex.StackTrace}");
            _logger.LogError(ex, "Error al cargar lista de escuelas");
            
            ViewData["CurrentFilter"] = searchString;
            return View(new List<SchoolListViewModel>());
        }
    }

    // GET: SuperAdmin/ListAdmins
    public async Task<IActionResult> ListAdmins()
    {
        var admins = await _superAdminService.GetAllAdminsAsync();

        return View(admins);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteSchool(Guid id)
    {
        Console.WriteLine($"🔍 [DeleteSchool] Iniciando eliminación de escuela con ID: {id}");
        
        try
        {
            var success = await _superAdminService.DeleteSchoolAsync(id);
            
            if (success)
            {
                Console.WriteLine($"✅ [DeleteSchool] Institución desactivada correctamente");
                TempData["SuccessMessage"] = "Institución desactivada correctamente.";
            }
            else
            {
                Console.WriteLine($"❌ [DeleteSchool] No se pudo desactivar la institución");
                TempData["ErrorMessage"] = "No se pudo desactivar la institución.";
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ [DeleteSchool] Error eliminando escuela: {ex.Message}");
            Console.WriteLine($"📊 [DeleteSchool] Stack Trace: {ex.StackTrace}");
            _logger.LogError(ex, "Error eliminando escuela");
            TempData["ErrorMessage"] = "Error al eliminar la escuela: " + ex.Message;
        }

        Console.WriteLine($"🔄 [DeleteSchool] Redirigiendo a ListSchools");
        return RedirectToAction(nameof(ListSchools));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        Console.WriteLine($"🔍 [DeleteUser] Iniciando eliminación de usuario con ID: {id}");
        
        try
        {
            var success = await _superAdminService.DeleteUserAsync(id);
            
            if (success)
            {
                Console.WriteLine($"✅ [DeleteUser] Usuario eliminado exitosamente");
                TempData["SuccessMessage"] = "Usuario eliminado exitosamente.";
            }
            else
            {
                Console.WriteLine($"❌ [DeleteUser] No se pudo eliminar el usuario");
                TempData["ErrorMessage"] = "No se pudo eliminar el usuario.";
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ [DeleteUser] Error eliminando usuario: {ex.Message}");
            Console.WriteLine($"📊 [DeleteUser] Stack Trace: {ex.StackTrace}");
            _logger.LogError(ex, "Error eliminando usuario");
            TempData["ErrorMessage"] = "Error al eliminar el usuario: " + ex.Message;
        }

        Console.WriteLine($"🔄 [DeleteUser] Redirigiendo a ListSchools");
        return RedirectToAction(nameof(ListSchools));
    }

    [HttpGet]
    public async Task<IActionResult> EditSchool(Guid id)
    {
        var viewModel = await _superAdminService.GetSchoolForEditWithAdminAsync(id);
        
        if (viewModel == null)
        {
            return NotFound();
        }

        return View(viewModel);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> EditSchool(SchoolAdminEditViewModel model, IFormFile? logoFile)
    {
        if (ModelState.IsValid)
        {
            try
            {
                var uploadsPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads");
                var success = await _superAdminService.UpdateSchoolAsync(model, logoFile, uploadsPath);
                
                if (success)
                {
                    TempData["SuccessMessage"] = "Escuela actualizada exitosamente.";
                    return RedirectToAction(nameof(ListSchools));
                }
                else
                {
                    ModelState.AddModelError("", "Error al actualizar la escuela.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar escuela");
                ModelState.AddModelError("", "Error al actualizar la escuela: " + ex.Message);
            }
        }

        return View(model);
    }

    [HttpGet]
    public async Task<IActionResult> EditUser(Guid id)
    {
        var viewModel = await _superAdminService.GetUserForEditAsync(id);
        
        if (viewModel == null)
        {
            return NotFound();
        }

        return View(viewModel);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> EditUser(UserEditViewModel model)
    {
        if (ModelState.IsValid)
        {
            try
            {
                var success = await _superAdminService.UpdateUserAsync(model);
                
                if (success)
                {
                    TempData["SuccessMessage"] = "Usuario actualizado exitosamente.";
                    return RedirectToAction(nameof(ListSchools));
                }
                else
                {
                    ModelState.AddModelError("", "Error al actualizar el usuario.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar usuario");
                ModelState.AddModelError("", "Error al actualizar el usuario: " + ex.Message);
            }
        }

        return View(model);
    }



    // Método para diagnosticar problemas de eliminación
    [HttpGet]
    public async Task<IActionResult> DiagnoseSchool(Guid id)
    {
        Console.WriteLine($"🔍 [DiagnoseSchool] Diagnosticando escuela con ID: {id}");
        
        try
        {
            var result = await _superAdminService.DiagnoseSchoolAsync(id);
            return Json(result);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"💥 [DiagnoseSchool] Error: {ex.Message}");
            return Json(new { success = false, message = ex.Message });
        }
    }

    // Método temporal para crear el superadmin inicial
    [HttpGet]
    public async Task<IActionResult> CreateInitialSuperAdmin()
    {
        try
        {
            // Verificar si ya existe un superadmin
            var existingSuperAdmin = await _superAdminService.GetAllAdminsAsync();
            if (existingSuperAdmin.Any(u => u.Role == "superadmin"))
            {
                return Json(new { 
                    success = false, 
                    message = "Ya existe un superadmin en el sistema" 
                });
            }

            // Crear el superadmin
            var superAdmin = new User
            {
                Id = Guid.NewGuid(),
                Name = "Super",
                LastName = "Administrador",
                Email = "superadmin@schoolmanager.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!"),
                Role = "superadmin",
                Status = "active",
                SchoolId = null, // Sin SchoolId para superadmin
                DocumentId = "8-000-0000",
                DateOfBirth = new DateTime(1990, 1, 1),
                CellphonePrimary = "+507 0000 0000",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            // Usar el contexto directamente para insertar
            using var context = new SchoolDbContext();
            context.Users.Add(superAdmin);
            await context.SaveChangesAsync();

            return Json(new { 
                success = true, 
                message = "Superadmin creado exitosamente",
                user = new {
                    id = superAdmin.Id,
                    name = superAdmin.Name,
                    lastName = superAdmin.LastName,
                    email = superAdmin.Email,
                    role = superAdmin.Role
                }
            });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"💥 [CreateInitialSuperAdmin] Error: {ex.Message}");
            return Json(new { 
                success = false, 
                message = "Error al crear superadmin: " + ex.Message 
            });
        }
    }

    // GET: SuperAdmin/SystemSettings
    [HttpGet]
    public async Task<IActionResult> SystemSettings()
    {
        try
        {
            var stats = await _superAdminService.GetSystemStatsAsync();
            return View(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error cargando configuración del sistema");
            TempData["ErrorMessage"] = "Error al cargar la configuración.";
            return RedirectToAction(nameof(Index));
        }
    }

    // GET: SuperAdmin/Backup
    [HttpGet]
    public IActionResult Backup()
    {
        return View();
    }

    // POST: SuperAdmin/ExecuteBackup
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ExecuteBackup()
    {
        try
        {
            TempData["InfoMessage"] = "El respaldo debe realizarse desde pgAdmin o mediante comandos pg_dump. " +
                "Consulte la documentación para más información.";
            return RedirectToAction(nameof(Backup));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error ejecutando respaldo");
            TempData["ErrorMessage"] = "Error al ejecutar el respaldo.";
            return RedirectToAction(nameof(Backup));
        }
    }

    // GET: SuperAdmin/SystemStats
    [HttpGet]
    public async Task<IActionResult> SystemStats()
    {
        try
        {
            var stats = await _superAdminService.GetSystemStatsAsync();
            return View(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error cargando estadísticas");
            TempData["ErrorMessage"] = "Error al cargar las estadísticas.";
            return RedirectToAction(nameof(Index));
        }
    }

    // GET: SuperAdmin/ActivityLog
    [HttpGet]
    public async Task<IActionResult> ActivityLog(int page = 1, int pageSize = 50)
    {
        try
        {
            var logs = await _superAdminService.GetActivityLogsAsync(page, pageSize);
            return View(logs);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error cargando registro de actividad");
            TempData["ErrorMessage"] = "Error al cargar el registro.";
            return RedirectToAction(nameof(Index));
        }
    }
} 