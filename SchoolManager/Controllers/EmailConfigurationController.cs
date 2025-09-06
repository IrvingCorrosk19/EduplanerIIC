using Microsoft.AspNetCore.Mvc;
using SchoolManager.Dtos;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;

namespace SchoolManager.Controllers
{
    public class EmailConfigurationController : Controller
    {
        private readonly IEmailConfigurationService _emailConfigurationService;
        private readonly ISchoolService _schoolService;

        public EmailConfigurationController(
            IEmailConfigurationService emailConfigurationService,
            ISchoolService schoolService)
        {
            _emailConfigurationService = emailConfigurationService;
            _schoolService = schoolService;
        }

        public async Task<IActionResult> Index()
        {
            var configurations = await _emailConfigurationService.GetAllAsync();
            return View(configurations);
        }

        public async Task<IActionResult> Details(Guid id)
        {
            var configuration = await _emailConfigurationService.GetByIdAsync(id);
            if (configuration == null)
            {
                return NotFound();
            }

            return View(configuration);
        }

        public async Task<IActionResult> Create()
        {
            var schools = await _schoolService.GetAllAsync();
            var viewModel = new EmailConfigurationCreateViewModel
            {
                Schools = schools.Select(s => new Microsoft.AspNetCore.Mvc.Rendering.SelectListItem
                {
                    Value = s.Id.ToString(),
                    Text = s.Name
                }).ToList()
            };

            return View(viewModel);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(EmailConfigurationCreateViewModel model)
        {
            if (!ModelState.IsValid)
            {
                var schools = await _schoolService.GetAllAsync();
                model.Schools = schools.Select(s => new Microsoft.AspNetCore.Mvc.Rendering.SelectListItem
                {
                    Value = s.Id.ToString(),
                    Text = s.Name
                }).ToList();
                return View(model);
            }

            try
            {
                var createDto = new EmailConfigurationCreateDto
                {
                    SchoolId = model.SchoolId,
                    SmtpServer = model.SmtpServer,
                    SmtpPort = model.SmtpPort,
                    SmtpUsername = model.SmtpUsername,
                    SmtpPassword = model.SmtpPassword,
                    SmtpUseSsl = model.SmtpUseSsl,
                    SmtpUseTls = model.SmtpUseTls,
                    FromEmail = model.FromEmail,
                    FromName = model.FromName,
                    IsActive = model.IsActive
                };

                await _emailConfigurationService.CreateAsync(createDto);
                TempData["SuccessMessage"] = "Configuración de email creada exitosamente.";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"Error al crear la configuración: {ex.Message}");
                var schools = await _schoolService.GetAllAsync();
                model.Schools = schools.Select(s => new Microsoft.AspNetCore.Mvc.Rendering.SelectListItem
                {
                    Value = s.Id.ToString(),
                    Text = s.Name
                }).ToList();
                return View(model);
            }
        }

        public async Task<IActionResult> Edit(Guid id)
        {
            var configuration = await _emailConfigurationService.GetByIdAsync(id);
            if (configuration == null)
            {
                return NotFound();
            }

            var schools = await _schoolService.GetAllAsync();
            var viewModel = new EmailConfigurationEditViewModel
            {
                Id = configuration.Id,
                SchoolId = configuration.SchoolId,
                SmtpServer = configuration.SmtpServer,
                SmtpPort = configuration.SmtpPort,
                SmtpUsername = configuration.SmtpUsername,
                SmtpPassword = configuration.SmtpPassword,
                SmtpUseSsl = configuration.SmtpUseSsl,
                SmtpUseTls = configuration.SmtpUseTls,
                FromEmail = configuration.FromEmail,
                FromName = configuration.FromName,
                IsActive = configuration.IsActive,
                Schools = schools.Select(s => new Microsoft.AspNetCore.Mvc.Rendering.SelectListItem
                {
                    Value = s.Id.ToString(),
                    Text = s.Name,
                    Selected = s.Id == configuration.SchoolId
                }).ToList()
            };

            return View(viewModel);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(EmailConfigurationEditViewModel model)
        {
            if (!ModelState.IsValid)
            {
                var schools = await _schoolService.GetAllAsync();
                model.Schools = schools.Select(s => new Microsoft.AspNetCore.Mvc.Rendering.SelectListItem
                {
                    Value = s.Id.ToString(),
                    Text = s.Name,
                    Selected = s.Id == model.SchoolId
                }).ToList();
                return View(model);
            }

            try
            {
                var updateDto = new EmailConfigurationUpdateDto
                {
                    Id = model.Id,
                    SmtpServer = model.SmtpServer,
                    SmtpPort = model.SmtpPort,
                    SmtpUsername = model.SmtpUsername,
                    SmtpPassword = model.SmtpPassword,
                    SmtpUseSsl = model.SmtpUseSsl,
                    SmtpUseTls = model.SmtpUseTls,
                    FromEmail = model.FromEmail,
                    FromName = model.FromName,
                    IsActive = model.IsActive
                };

                await _emailConfigurationService.UpdateAsync(updateDto);
                TempData["SuccessMessage"] = "Configuración de email actualizada exitosamente.";
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"Error al actualizar la configuración: {ex.Message}");
                var schools = await _schoolService.GetAllAsync();
                model.Schools = schools.Select(s => new Microsoft.AspNetCore.Mvc.Rendering.SelectListItem
                {
                    Value = s.Id.ToString(),
                    Text = s.Name,
                    Selected = s.Id == model.SchoolId
                }).ToList();
                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(Guid id)
        {
            try
            {
                var result = await _emailConfigurationService.DeleteAsync(id);
                if (result)
                {
                    TempData["SuccessMessage"] = "Configuración de email eliminada exitosamente.";
                }
                else
                {
                    TempData["ErrorMessage"] = "No se pudo eliminar la configuración de email.";
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = $"Error al eliminar la configuración: {ex.Message}";
            }

            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> TestConnection(Guid id)
        {
            try
            {
                var result = await _emailConfigurationService.TestConnectionAsync(id);
                return Json(new { success = result, message = result ? "Conexión exitosa" : "Error en la conexión" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        [HttpPost]
        public async Task<IActionResult> TestConnectionBySchool(Guid schoolId)
        {
            try
            {
                var result = await _emailConfigurationService.TestConnectionBySchoolIdAsync(schoolId);
                return Json(new { success = result, message = result ? "Conexión exitosa" : "Error en la conexión" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }
    }
}
