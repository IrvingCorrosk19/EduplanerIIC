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
        public const int MaxPasswordEmailsPerRequest = 30;

        private readonly IUserPasswordManagementService _userPasswordManagementService;
        private readonly IBulkPasswordEmailService _bulkPasswordEmailService;
        private readonly ILogger<UserPasswordManagementController> _logger;

        public UserPasswordManagementController(
            IUserPasswordManagementService userPasswordManagementService,
            IBulkPasswordEmailService bulkPasswordEmailService,
            ILogger<UserPasswordManagementController> logger)
        {
            _userPasswordManagementService = userPasswordManagementService;
            _bulkPasswordEmailService = bulkPasswordEmailService;
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

        [HttpPost]
        [Route("SendPasswords")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SendPasswords([FromBody] SendPasswordsRequestDto? body)
        {
            var ids = (body?.UserIds ?? new List<Guid>()).Distinct().ToList();
            if (ids.Count == 0)
                return BadRequest(new { success = false, message = "Seleccione al menos un usuario." });

            if (ids.Count > MaxPasswordEmailsPerRequest)
            {
                _logger.LogWarning("SendPasswords rechazado: {Count} ids (máx {Max})", ids.Count, MaxPasswordEmailsPerRequest);
                return BadRequest(new
                {
                    success = false,
                    message = $"Máximo {MaxPasswordEmailsPerRequest} usuarios por envío. Seleccione menos e intente de nuevo."
                });
            }

            if (User?.Identity?.IsAuthenticated != true)
                return Unauthorized();

            try
            {
                var result = await _bulkPasswordEmailService.SendPasswordsAsync(ids, User);

                var sent = result.Items.Count(x => x.Success);
                var failed = result.Items.Count(x => !x.Success);
                var total = result.Items.Count;

                _logger.LogInformation(
                    "SendPasswords completado total={Total} sent={Sent} failed={Failed}",
                    total, sent, failed);

                return Json(new
                {
                    success = true,
                    total,
                    sent,
                    failed,
                    message = "Proceso completado",
                    items = result.Items.Select(i => new { i.UserId, i.Success, i.Message })
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SendPasswords failed");
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }
}
