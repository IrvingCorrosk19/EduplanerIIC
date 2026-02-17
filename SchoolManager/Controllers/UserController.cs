using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using SchoolManager.Enums;
using SchoolManager.Models;
using SchoolManager.ViewModels;
using Microsoft.AspNetCore.Authorization;
using BCrypt.Net;
using SchoolManager.Services.Interfaces;
using SchoolManager.Dtos;
using Microsoft.Extensions.Logging;

[Authorize(Roles = "admin")]
public class UserController : Controller
{
    private readonly IUserService _userService;
    private readonly IUserPhotoService _userPhotoService;
    private readonly ISubjectService _subjectService;
    private readonly IGroupService _groupService;
    private readonly IMapper _mapper;
    private readonly IEmailConfigurationService _emailConfigurationService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<UserController> _logger;

    public UserController(
        IUserService userService,
        IUserPhotoService userPhotoService,
        ISubjectService subjectService,
        IGroupService groupService,
        IMapper mapper,
        IEmailConfigurationService emailConfigurationService,
        ICurrentUserService currentUserService,
        ILogger<UserController> logger)
    {
        _userService = userService;
        _userPhotoService = userPhotoService;
        _subjectService = subjectService;
        _groupService = groupService;
        _mapper = mapper;
        _emailConfigurationService = emailConfigurationService;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    [HttpPost]
    public async Task<IActionResult> CreateJson([FromBody] CreateUserViewModel model)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        // Validar formato del correo electrónico
        if (!IsValidEmail(model.Email))
        {
            return BadRequest(new { message = "El formato del correo electrónico no es válido" });
        }

        // Validar si el correo electrónico ya existe
        var existingUser = await _userService.GetByEmailAsync(model.Email);
        if (existingUser != null)
        {
            return BadRequest(new { message = "El correo electrónico ya está registrado en el sistema" });
        }

        // Validar fortaleza de la contraseña
        if (!string.IsNullOrEmpty(model.PasswordHash) && !IsStrongPassword(model.PasswordHash))
        {
            return BadRequest(new { message = "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial" });
        }

        // Validar que el rol sea uno permitido (coherente con el enum y la BD)
        var roleLower = model.Role?.Trim().ToLower() ?? "";
        var allowedRoles = new[] { "director", "teacher", "contable", "secretaria", "estudiante", "acudiente", "contabilidad", "parent" };
        if (string.IsNullOrEmpty(roleLower) || !allowedRoles.Contains(roleLower))
        {
            return BadRequest(new { message = "El rol seleccionado no es válido." });
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            Name = model.Name,
            LastName = model.LastName,
            Email = model.Email,
            DocumentId = model.DocumentId,
            Role = roleLower,
            Status = model.Status,
            CreatedAt = DateTime.UtcNow,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(model.PasswordHash ?? "123456"),
            DateOfBirth = model.DateOfBirth?.ToUniversalTime(),
            CellphonePrimary = model.CellphonePrimary,
            CellphoneSecondary = model.CellphoneSecondary,
            Disciplina = model.Disciplina ?? false,
            Inclusion = model.Inclusion,
            Orientacion = model.Orientacion ?? false,
            Inclusivo = model.Inclusivo ?? false,
        };

        await _userService.CreateAsync(user, model.Subjects, model.Groups);

        return Ok(new { message = "Usuario creado correctamente", id = user.Id });
    }

    private bool IsValidEmail(string email)
    {
        try
        {
            var addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        }
        catch
        {
            return false;
        }
    }

    private bool IsStrongPassword(string password)
    {
        // La contraseña debe tener:
        // - Al menos 8 caracteres
        // - Al menos una letra mayúscula
        // - Al menos una letra minúscula
        // - Al menos un número
        // - Al menos un carácter especial
        var hasNumber = password.Any(char.IsDigit);
        var hasUpperChar = password.Any(char.IsUpper);
        var hasLowerChar = password.Any(char.IsLower);
        var hasSpecialChar = password.Any(c => !char.IsLetterOrDigit(c));
        var hasMinLength = password.Length >= 8;

        return hasNumber && hasUpperChar && hasLowerChar && hasSpecialChar && hasMinLength;
    }


    public async Task<IActionResult> Index(string role = "")
    {
        ViewBag.Roles = Enum.GetValues(typeof(UserRole))
      .Cast<UserRole>()
      .Where(r => r != UserRole.Superadmin && r != UserRole.Admin && r != UserRole.Student)
      .Select(r => r.ToString())
      .ToList();

        var users = await _userService.GetAllAsync();
        
        // Filtrar por rol si se especifica
        if (!string.IsNullOrEmpty(role))
        {
            users = users.Where(u => u.Role?.ToLower() == role.ToLower()).ToList();
        }
        
        return View(users);
    }

    public async Task<IActionResult> Details(Guid id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user == null) return NotFound();
        return View(user);
    }

    public IActionResult Create()
    {
        ViewBag.Roles = Enum.GetValues(typeof(UserRole))
            .Cast<UserRole>()
            .Where(r => r != UserRole.Superadmin && r != UserRole.Admin && r != UserRole.Student && r != UserRole.Estudiante)
            .Select(r => new SelectListItem(r.ToString(), r.ToString().ToLower()))
            .ToList();
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> Create(User user)
    {
        if (ModelState.IsValid)
        {
            return RedirectToAction(nameof(Index));
        }
        return View(user);
    }

    public async Task<IActionResult> Edit(Guid id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user == null) return NotFound();
        ViewBag.Roles = Enum.GetValues(typeof(UserRole))
            .Cast<UserRole>()
            .Where(r => r != UserRole.Superadmin && r != UserRole.Admin && r != UserRole.Student && r != UserRole.Estudiante)
            .Select(r => new SelectListItem(r.ToString(), r.ToString().ToLower()))
            .ToList();
        return View(user);
    }

    [HttpPost]
    public async Task<IActionResult> Edit(User user)
    {
        if (ModelState.IsValid)
        {
            await _userService.UpdateAsync(user);
            return RedirectToAction(nameof(Index));
        }
        return View(user);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(2 * 1024 * 1024)]
    public async Task<IActionResult> UpdatePhoto(Guid id, IFormFile? photo)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user == null) return NotFound();
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school != null && user.SchoolId != school.Id)
        {
            TempData["Error"] = "No puede modificar la foto de un usuario de otra escuela.";
            return RedirectToAction(nameof(Edit), new { id });
        }
        if (photo == null || photo.Length == 0)
        {
            TempData["Error"] = "Seleccione una imagen (JPEG o PNG, máx. 2 MB).";
            return RedirectToAction(nameof(Edit), new { id });
        }
        try
        {
            await _userPhotoService.UpdatePhotoAsync(id, photo);
            TempData["SuccessMessage"] = "Foto actualizada correctamente.";
            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
            {
                var updated = await _userService.GetByIdAsync(id);
                return Json(new { success = true, photoUrl = updated?.PhotoUrl });
            }
        }
        catch (InvalidOperationException ex)
        {
            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                return Json(new { success = false, message = ex.Message });
            TempData["Error"] = ex.Message;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error actualizando foto del usuario {UserId}", id);
            var errMsg = "No se pudo actualizar la foto. Verifique que sea JPEG o PNG y no supere 2 MB.";
            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                return Json(new { success = false, message = errMsg });
            TempData["Error"] = errMsg;
        }
        return RedirectToAction(nameof(Edit), new { id });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> RemovePhoto(Guid id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user == null) return NotFound();
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school != null && user.SchoolId != school.Id)
        {
            TempData["Error"] = "No puede modificar la foto de un usuario de otra escuela.";
            return RedirectToAction(nameof(Edit), new { id });
        }
        try
        {
            await _userPhotoService.RemovePhotoAsync(id);
            TempData["SuccessMessage"] = "Foto eliminada.";
            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                return Json(new { success = true });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error eliminando foto del usuario {UserId}", id);
            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                return Json(new { success = false, message = "No se pudo eliminar la foto." });
            TempData["Error"] = "No se pudo eliminar la foto.";
        }
        return RedirectToAction(nameof(Edit), new { id });
    }

    public async Task<IActionResult> Delete(Guid id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user == null) return NotFound();
        return View(user);
    }

    [HttpPost, ActionName("Delete")]
    public async Task<IActionResult> DeleteConfirmed(Guid id)
    {
        await _userService.DeleteAsync(id);
        TempData["SuccessMessage"] = "Usuario eliminado exitosamente.";
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public async Task<IActionResult> GetById(Guid id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user == null) return NotFound();

        var result = new
        {
            user.Id,
            user.Name,
            user.LastName,
            user.Email,
            user.DocumentId
        };

        return Json(result);
    }

    [HttpGet]
    public async Task<IActionResult> GetUserJson(Guid id)
    {
        var user = await _userService.GetByIdWithRelationsAsync(id);
        if (user == null) return NotFound();

        var result = new
        {
            user.Id,
            user.Name,
            user.LastName,
            user.Email,
            user.DocumentId,
            user.PasswordHash,
            Role = char.ToUpper(user.Role[0]) + user.Role.Substring(1).ToLower(),
            user.Status,
            user.DateOfBirth,
            user.CellphonePrimary,
            user.CellphoneSecondary,
            user.Disciplina,
            user.Inclusion,
            user.Orientacion,
            user.Inclusivo,
            user.PhotoUrl,
            Subjects = user.Subjects.Select(s => s.Id),
            Groups = user.Groups.Select(g => g.Id)
        };

        return Json(result);
    }

    [HttpGet]
    public async Task<IActionResult> GetUsersByRole(string role = "")
    {
        var users = await _userService.GetAllAsync();
        
        // Filtrar por rol si se especifica
        if (!string.IsNullOrEmpty(role))
        {
            users = users.Where(u => u.Role?.ToLower() == role.ToLower()).ToList();
        }

        var result = users.Select(u => new
        {
            u.Id,
            u.Name,
            u.LastName,
            u.Email,
            u.DocumentId,
            u.DateOfBirth,
            u.CellphonePrimary,
            u.CellphoneSecondary,
            Role = char.ToUpper(u.Role[0]) + u.Role.Substring(1).ToLower(),
            u.Status,
            u.Disciplina,
            u.Inclusion,
            u.Orientacion,
            u.Inclusivo
        });

        return Json(result);
    }

    [HttpPost]
    public async Task<IActionResult> UpdateJson([FromBody] CreateUserViewModel model)
    {
        try
        {
            Console.WriteLine($"=== INICIO ACTUALIZACIÓN USUARIO ===");
            Console.WriteLine($"Usuario ID: {model.Id}");
            Console.WriteLine($"Nombre: {model.Name}");
            Console.WriteLine($"Email: {model.Email}");
            Console.WriteLine($"Celular Principal: {model.CellphonePrimary}");
            Console.WriteLine($"Celular Secundario: {model.CellphoneSecondary}");
            Console.WriteLine($"Disciplina: {model.Disciplina}");
            Console.WriteLine($"Inclusion: {model.Inclusion}");
            Console.WriteLine($"Orientacion: {model.Orientacion}");
            Console.WriteLine($"Inclusivo: {model.Inclusivo}");
            
            _logger.LogInformation("Iniciando actualización de usuario {UserId}", model.Id);

            if (!ModelState.IsValid)
            {
                Console.WriteLine($"ModelState inválido: {string.Join(", ", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage))}");
                _logger.LogWarning("ModelState inválido para usuario {UserId}", model.Id);
                return BadRequest(ModelState);
            }

            Console.WriteLine("Buscando usuario existente...");
            var existingUser = await _userService.GetByIdWithRelationsAsync(model.Id);
            if (existingUser == null)
            {
                Console.WriteLine("Usuario no encontrado en la base de datos");
                _logger.LogWarning("Usuario {UserId} no encontrado", model.Id);
                return NotFound(new { message = "Usuario no encontrado" });
            }

            Console.WriteLine($"Usuario encontrado: {existingUser.Name} {existingUser.LastName}");
            Console.WriteLine("Actualizando campos del usuario...");

            var roleLower = model.Role?.Trim().ToLower() ?? "";
            var allowedRoles = new[] { "director", "teacher", "contable", "secretaria", "estudiante", "acudiente", "contabilidad", "parent", "admin" };
            if (string.IsNullOrEmpty(roleLower) || !allowedRoles.Contains(roleLower))
            {
                return BadRequest(new { message = "El rol seleccionado no es válido." });
            }

            existingUser.Name = model.Name;
            existingUser.LastName = model.LastName;
            existingUser.Email = model.Email;
            existingUser.DocumentId = model.DocumentId;
            existingUser.Role = roleLower;
            existingUser.Status = model.Status;
            existingUser.DateOfBirth = model.DateOfBirth?.ToUniversalTime();
            existingUser.CellphonePrimary = model.CellphonePrimary;
            existingUser.CellphoneSecondary = model.CellphoneSecondary;
            existingUser.Disciplina = model.Disciplina ?? false;
            existingUser.Inclusion = model.Inclusion;
            existingUser.Orientacion = model.Orientacion ?? false;
            existingUser.Inclusivo = model.Inclusivo ?? false;

            Console.WriteLine("=== CAMPOS ASIGNADOS ===");
            Console.WriteLine($"existingUser.Disciplina: {existingUser.Disciplina}");
            Console.WriteLine($"existingUser.Inclusion: {existingUser.Inclusion}");
            Console.WriteLine($"existingUser.Orientacion: {existingUser.Orientacion}");
            Console.WriteLine($"existingUser.Inclusivo: {existingUser.Inclusivo}");
            Console.WriteLine("Campos actualizados, guardando cambios...");
            _logger.LogInformation("Campos actualizados para usuario {UserId}", model.Id);

            if (!string.IsNullOrEmpty(model.PasswordHash))
            {
                Console.WriteLine("Actualizando contraseña...");
                // Hash de la contraseña antes de guardarla
                existingUser.PasswordHash = BCrypt.Net.BCrypt.HashPassword(model.PasswordHash);
                _logger.LogInformation("Contraseña actualizada para usuario {UserId}", model.Id);
            }

            Console.WriteLine("Llamando al servicio para guardar cambios...");
            await _userService.UpdateAsync(existingUser, model.Subjects, model.Groups);

            Console.WriteLine("Usuario actualizado exitosamente");
            _logger.LogInformation("Usuario {UserId} actualizado exitosamente", model.Id);
            return Ok(new { message = "Usuario actualizado correctamente" });
        }
        catch (Exception ex)
        {
            Console.WriteLine($"=== ERROR EN ACTUALIZACIÓN ===");
            Console.WriteLine($"Error: {ex.Message}");
            Console.WriteLine($"Stack Trace: {ex.StackTrace}");
            if (ex.InnerException != null)
            {
                Console.WriteLine($"Inner Exception: {ex.InnerException.Message}");
            }
            
            _logger.LogError(ex, "Error al actualizar usuario {UserId}", model.Id);
            return StatusCode(500, new { message = "Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo." });
        }
    }

    [HttpPost]
    public async Task<IActionResult> SendPasswordEmail(Guid id)
    {
        try
        {
            _logger.LogInformation("Iniciando envío de email de contraseña para usuario ID: {UserId}", id);
            
            // Obtener el usuario
            var user = await _userService.GetByIdAsync(id);
            if (user == null)
            {
                _logger.LogWarning("Usuario no encontrado con ID: {UserId}", id);
                return NotFound(new { message = "Usuario no encontrado" });
            }

            _logger.LogInformation("Usuario encontrado: {UserName} {UserLastName}, Email: {UserEmail}", 
                user.Name, user.LastName, user.Email);

            // Obtener la configuración de email de la escuela
            var currentUser = await _currentUserService.GetCurrentUserAsync();
            if (currentUser?.SchoolId == null)
            {
                _logger.LogError("No se pudo obtener la información de la escuela para el usuario actual");
                return BadRequest(new { message = "No se pudo obtener la información de la escuela" });
            }

            _logger.LogInformation("SchoolId del usuario actual: {SchoolId}", currentUser.SchoolId.Value);

            var emailConfig = await _emailConfigurationService.GetBySchoolIdAsync(currentUser.SchoolId.Value);
            if (emailConfig == null)
            {
                _logger.LogError("No hay configuración de email para SchoolId: {SchoolId}", currentUser.SchoolId.Value);
                return BadRequest(new { message = "No hay configuración de email para esta escuela. Configure el servidor SMTP primero." });
            }

            _logger.LogInformation("Configuración de email encontrada: SMTP={SmtpServer}, Puerto={SmtpPort}, Usuario={SmtpUsername}", 
                emailConfig.SmtpServer, emailConfig.SmtpPort, emailConfig.SmtpUsername);

            // Generar una nueva contraseña temporal
            var newPassword = GenerateTemporaryPassword();
            _logger.LogInformation("Contraseña temporal generada para usuario: {UserEmail}", user.Email);
            
            // Actualizar la contraseña del usuario
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
            await _userService.UpdateAsync(user);
            _logger.LogInformation("Contraseña actualizada en la base de datos para usuario: {UserEmail}", user.Email);

            // Enviar el email
            _logger.LogInformation("Iniciando envío de email de bienvenida a: {UserEmail}", user.Email);
            var emailSent = await SendWelcomeEmailAsync(user, newPassword, emailConfig);
            
            if (emailSent)
            {
                _logger.LogInformation("Email enviado exitosamente a: {UserEmail}", user.Email);
                return Ok(new { message = $"Contraseña enviada exitosamente a {user.Email}" });
            }
            else
            {
                _logger.LogError("Error al enviar email a: {UserEmail}", user.Email);
                return BadRequest(new { message = "Error al enviar el email. Verifique la configuración SMTP." });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error inesperado al enviar email de contraseña para usuario ID: {UserId}", id);
            return BadRequest(new { message = $"Error: {ex.Message}" });
        }
    }

    private string GenerateTemporaryPassword()
    {
        const int length = 12;
        const string charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
        var random = new Random();
        
        // Asegurar al menos un carácter de cada tipo
        var password = new char[length];
        password[0] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[random.Next(26)]; // Mayúscula
        password[1] = "abcdefghijklmnopqrstuvwxyz"[random.Next(26)]; // Minúscula
        password[2] = "0123456789"[random.Next(10)]; // Número
        password[3] = "!@#$%^&*"[random.Next(8)]; // Especial
        
        // Completar con caracteres aleatorios
        for (int i = 4; i < length; i++)
        {
            password[i] = charset[random.Next(charset.Length)];
        }
        
        // Mezclar la contraseña
        for (int i = 0; i < length; i++)
        {
            int randomIndex = random.Next(length);
            (password[i], password[randomIndex]) = (password[randomIndex], password[i]);
        }
        
        return new string(password);
    }

    private async Task<bool> SendWelcomeEmailAsync(User user, string password, EmailConfigurationDto emailConfig)
    {
        try
        {
            _logger.LogInformation("Iniciando configuración SMTP para envío de email");
            _logger.LogInformation("Configuración SMTP: Servidor={SmtpServer}, Puerto={SmtpPort}, Usuario={SmtpUsername}, SSL={SmtpUseSsl}, TLS={SmtpUseTls}", 
                emailConfig.SmtpServer, emailConfig.SmtpPort, emailConfig.SmtpUsername, emailConfig.SmtpUseSsl, emailConfig.SmtpUseTls);
            
            // Limpiar credenciales de espacios ocultos
            var cleanUsername = emailConfig.SmtpUsername?.Trim() ?? string.Empty;
            var cleanPassword = emailConfig.SmtpPassword?.Trim() ?? string.Empty;
            
            _logger.LogInformation("Credenciales limpias - Usuario: '{Username}' (longitud: {UserLength}), Contraseña: '{Password}' (longitud: {PassLength})", 
                cleanUsername, cleanUsername.Length, 
                string.IsNullOrEmpty(cleanPassword) ? "[VACÍA]" : "[OCULTA]", cleanPassword.Length);
            
            using var client = new System.Net.Mail.SmtpClient(emailConfig.SmtpServer, emailConfig.SmtpPort);
            
            // Para Gmail con puerto 587, necesitamos SSL habilitado para STARTTLS
            // Si es Gmail y puerto 587, forzar SSL a true
            bool enableSsl = emailConfig.SmtpUseSsl;
            if (emailConfig.SmtpServer.ToLower().Contains("gmail") && emailConfig.SmtpPort == 587)
            {
                enableSsl = true;
                _logger.LogInformation("Detectado Gmail con puerto 587, forzando SSL a true para STARTTLS");
            }
            
            client.EnableSsl = enableSsl;
            client.UseDefaultCredentials = false; // CRÍTICO: debe ser false para Gmail
            client.Credentials = new System.Net.NetworkCredential(cleanUsername, cleanPassword);
            client.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
            
            _logger.LogInformation("Cliente SMTP configurado: SSL={EnableSsl}, UseDefaultCredentials={UseDefaultCredentials}, Credentials configuradas", 
                client.EnableSsl, client.UseDefaultCredentials);

            var message = new System.Net.Mail.MailMessage();
            message.From = new System.Net.Mail.MailAddress(cleanUsername, emailConfig.FromName); // Usar el usuario limpio como From
            message.To.Add(user.Email);
            message.Subject = "Credenciales de Acceso - Eduplaner";
            message.IsBodyHtml = true;
            
            message.Body = $@"
                <html>
                <body style='font-family: Arial, sans-serif; line-height: 1.6; color: #333;'>
                    <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
                        <h2 style='color: #2563eb; text-align: center;'>Credenciales de Acceso - Eduplaner</h2>
                        <p>Hola <strong>{user.Name} {user.LastName}</strong>,</p>
                        <p>Te enviamos tu contraseña temporal para acceder a la plataforma Eduplaner.</p>
                        
                        <div style='background-color: #f8fafc; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #2563eb;'>
                            <p style='margin: 0;'><strong>Tus credenciales de acceso:</strong></p>
                            <p style='margin: 10px 0;'><strong>Email:</strong> {user.Email}</p>
                            <p style='margin: 0;'><strong>Contraseña temporal:</strong></p>
                            <p style='font-size: 18px; font-weight: bold; color: #2563eb; margin: 10px 0;'>{password}</p>
                        </div>

                        <div style='text-align: center; margin: 30px 0;'>
                            <a href='https://eduplaner.net/' 
                               style='display: inline-block; 
                                      background-color: #2563eb; 
                                      color: white; 
                                      padding: 15px 40px; 
                                      text-decoration: none; 
                                      border-radius: 8px; 
                                      font-weight: bold; 
                                      font-size: 16px;
                                      box-shadow: 0 4px 6px rgba(37, 99, 235, 0.3);'>
                                🚀 Acceder a la Plataforma
                            </a>
                            <p style='margin-top: 15px; font-size: 14px; color: #6b7280;'>
                                O copia y pega este enlace en tu navegador:<br>
                                <a href='https://eduplaner.net/' style='color: #2563eb; text-decoration: none;'>
                                    https://eduplaner.net/
                                </a>
                            </p>
                        </div>

                        <p><strong>Información de tu cuenta:</strong></p>
                        <ul>
                            <li><strong>Email:</strong> {user.Email}</li>
                            <li><strong>Rol:</strong> {GetRoleDisplayName(user.Role)}</li>
                            <li><strong>Estado:</strong> {user.Status}</li>
                        </ul>
                        
                        <div style='background-color: #fef3c7; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #f59e0b;'>
                            <p style='margin: 0; color: #92400e; font-size: 14px;'>
                                <strong>⚠️ Importante:</strong> Por seguridad, te recomendamos cambiar esta contraseña temporal en tu primer acceso al sistema.
                            </p>
                        </div>

                        <hr style='border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;'>
                        <p style='text-align: center; color: #6b7280; font-size: 12px;'>
                            Este es un mensaje automático del sistema Eduplaner. Por favor, no respondas a este email.
                        </p>
                    </div>
                </body>
                </html>";

            _logger.LogInformation("Enviando mensaje de bienvenida desde {FromEmail} a {ToEmail}", cleanUsername, user.Email);
            await client.SendMailAsync(message);
            _logger.LogInformation("Mensaje enviado exitosamente a: {UserEmail}", user.Email);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error en envío de email de bienvenida a {UserEmail}: {ErrorMessage}", user.Email, ex.Message);
            _logger.LogError("Detalles del error: {ExceptionType} - {StackTrace}", ex.GetType().Name, ex.StackTrace);
            return false;
        }
    }

    private string GetRoleDisplayName(string role)
    {
        return role?.ToLower() switch
        {
            "admin" => "Administrador",
            "superadmin" => "Super Administrador",
            "teacher" => "Docente",
            "student" => "Estudiante",
            "estudiante" => "Estudiante",
            "parent" => "Padre/Madre",
            "acudiente" => "Acudiente",
            "director" => "Director",
            "contable" => "Contable",
            "contabilidad" => "Contabilidad",
            "secretaria" => "Secretaria",
            _ => role ?? "Sin rol"
        };
    }
}
