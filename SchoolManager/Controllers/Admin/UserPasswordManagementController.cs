using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Dtos;
using SchoolManager.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace SchoolManager.Controllers.Admin
{
    [Authorize(Roles = "SuperAdmin,superadmin,Admin,admin")]
    [Route("Admin/UserPasswordManagement")]
    public class UserPasswordManagementController : Controller
    {
        public const int MaxEnqueuePerRequest = 2000;

        private readonly IUserPasswordManagementService _userPasswordManagementService;
        private readonly IEmailQueueService _emailQueueService;
        private readonly ICurrentUserService _currentUserService;
        private readonly ILogger<UserPasswordManagementController> _logger;

        public UserPasswordManagementController(
            IUserPasswordManagementService userPasswordManagementService,
            IEmailQueueService emailQueueService,
            ICurrentUserService currentUserService,
            ILogger<UserPasswordManagementController> logger)
        {
            _userPasswordManagementService = userPasswordManagementService;
            _emailQueueService = emailQueueService;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        [HttpGet]
        [Route("")]
        [Route("Index")]
        public async Task<IActionResult> Index(
            [FromQuery] Guid? gradeId,
            [FromQuery] Guid? groupId,
            [FromQuery] string? role,
            [FromQuery] string? q)
        {
            if (gradeId == Guid.Empty) gradeId = null;
            if (groupId == Guid.Empty) groupId = null;

            var me = await _currentUserService.GetCurrentUserAsync();
            var isSuper = string.Equals(me?.Role, "superadmin", StringComparison.OrdinalIgnoreCase);
            var vm = await _userPasswordManagementService.GetIndexViewModelAsync(
                gradeId,
                groupId,
                string.IsNullOrWhiteSpace(role) ? null : role.Trim(),
                string.IsNullOrWhiteSpace(q) ? null : q.Trim(),
                me?.SchoolId,
                isSuper);
            return View("~/Views/Admin/UserPasswordManagement/Index.cshtml", vm);
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

        [HttpPost]
        [Route("SendPasswords")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SendPasswords([FromBody] SendPasswordsRequestDto? body)
        {
            var ids = (body?.UserIds ?? new List<Guid>()).Distinct().ToList();
            if (ids.Count == 0)
                return BadRequest(new { success = false, message = "Seleccione al menos un usuario." });

            if (ids.Count > MaxEnqueuePerRequest)
                return BadRequest(new
                {
                    success = false,
                    message = $"Máximo {MaxEnqueuePerRequest} usuarios por solicitud."
                });

            if (User?.Identity?.IsAuthenticated != true)
                return Unauthorized();

            try
            {
                await _emailQueueService.EnqueueUsersAsync(ids, User);
                return Json(new { success = true, message = "Correos en proceso" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SendPasswords enqueue failed");
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }
}
