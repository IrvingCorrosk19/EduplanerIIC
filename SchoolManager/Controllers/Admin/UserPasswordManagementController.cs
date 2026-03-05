using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Services.Interfaces;
using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace SchoolManager.Controllers.Admin
{
    [Authorize(Roles = "SuperAdmin,superadmin,Admin,admin,Director,director")]
    [Route("Admin/UserPasswordManagement")]
    public class UserPasswordManagementController : Controller
    {
        private readonly IUserPasswordManagementService _userPasswordManagementService;
        private readonly ILogger<UserPasswordManagementController> _logger;

        public UserPasswordManagementController(
            IUserPasswordManagementService userPasswordManagementService,
            ILogger<UserPasswordManagementController> logger)
        {
            _userPasswordManagementService = userPasswordManagementService;
            _logger = logger;
        }

        [HttpGet]
        [Route("")]
        [Route("Index")]
        public IActionResult Index()
        {
            return View("~/Views/Admin/UserPasswordManagement/Index.cshtml");
        }

        [HttpGet]
        [Route("ListJson")]
        public async Task<IActionResult> ListJson()
        {
            var users = await _userPasswordManagementService.GetAllUsersAsync();
            return Json(users);
        }

        [HttpGet]
        [Route("FilterByRole")]
        public async Task<IActionResult> FilterByRole([FromQuery] string? role)
        {
            try
            {
                var users = await _userPasswordManagementService.GetUsersByRoleAsync(role ?? string.Empty);
                return Json(users);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "FilterByRole failed for role={Role}", role);
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}
