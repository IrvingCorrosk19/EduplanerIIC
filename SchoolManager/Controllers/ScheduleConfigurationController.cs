using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Controllers;

[Authorize(Roles = "Admin,Director,admin,director")]
[AutoValidateAntiforgeryToken]
public class ScheduleConfigurationController : Controller
{
    private readonly IScheduleConfigurationService _configService;
    private readonly ICurrentUserService _currentUserService;

    public ScheduleConfigurationController(
        IScheduleConfigurationService configService,
        ICurrentUserService currentUserService)
    {
        _configService = configService;
        _currentUserService = currentUserService;
    }

    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var user = await _currentUserService.GetCurrentUserAsync();
        if (user?.SchoolId == null)
            return RedirectToAction("Index", "Home");

        var config = await _configService.GetBySchoolIdAsync(user.SchoolId.Value);
        var model = config ?? new SchoolScheduleConfiguration
        {
            SchoolId = user.SchoolId.Value,
            MorningStartTime = new TimeOnly(7, 0),
            MorningBlockDurationMinutes = 45,
            MorningBlockCount = 8,
            AfternoonStartTime = null,
            AfternoonBlockDurationMinutes = null,
            AfternoonBlockCount = null
        };
        return View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> SaveConfiguration(SchoolScheduleConfiguration model, bool forceRegenerate = false)
    {
        var user = await _currentUserService.GetCurrentUserAsync();
        if (user?.SchoolId == null)
            return RedirectToAction("Index", "Home");

        model.SchoolId = user.SchoolId.Value;

        var (success, message) = await _configService.SaveAndGenerateBlocksAsync(model, user.SchoolId.Value, forceRegenerate);
        if (success)
        {
            TempData["Success"] = message;
            return RedirectToAction(nameof(Index));
        }

        TempData["Error"] = message;
        return View("Index", model);
    }
}
