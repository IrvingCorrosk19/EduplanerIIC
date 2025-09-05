using Microsoft.AspNetCore.Mvc;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using BCrypt.Net;

namespace SchoolManager.Controllers
{
    public class AuthController : Controller
    {
        private readonly IAuthService _authService;
        private readonly IUserService _userService;

        public AuthController(IAuthService authService, IUserService userService)
        {
            _authService = authService;
            _userService = userService;
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult Login(string returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        public async Task<IActionResult> Login(LoginViewModel model, string returnUrl = null)
        {
            if (!ModelState.IsValid)
            {
                TempData["Error"] = "Por favor, corrija los errores en el formulario.";
                return View(model);
            }

            var (success, message, user) = await _authService.LoginAsync(model.Email, model.Password);

            Console.WriteLine($"[Login] Intento de login para {model.Email} - Éxito: {success}");

            if (!success)
            {
                TempData["Error"] = message;
                return View(model);
            }

            TempData["Success"] = "¡Bienvenido " + user.Name + "!";

            // Redirigir según el rol del usuario
            if (user.Role.ToLower() == "superadmin")
            {
                return RedirectToAction("Index", "SuperAdmin");
            }

            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }

            return RedirectToAction("Index", "Home");
        }

        [HttpPost]
        public async Task<IActionResult> Logout()
        {
            await _authService.LogoutAsync();
            TempData["Success"] = "Sesión cerrada correctamente";
            return RedirectToAction("Login");
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult AccessDenied(string returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            return View();
        }

        // Método temporal para arreglar contraseñas no hasheadas
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> FixPasswords()
        {
            try
            {
                var users = await _userService.GetAllAsync();
                int fixedCount = 0;
                var results = new List<string>();

                foreach (var user in users)
                {
                    if (!_authService.IsPasswordHashed(user.PasswordHash))
                    {
                        // La contraseña no está hasheada, hashearla
                        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(user.PasswordHash);
                        await _userService.UpdateAsync(user);
                        fixedCount++;
                        results.Add($"Usuario {user.Email}: contraseña hasheada");
                    }
                }

                return Json(new { 
                    success = true, 
                    message = $"Se arreglaron {fixedCount} contraseñas", 
                    results = results 
                });
            }
            catch (Exception ex)
            {
                return Json(new { 
                    success = false, 
                    message = $"Error: {ex.Message}" 
                });
            }
        }
    }
} 