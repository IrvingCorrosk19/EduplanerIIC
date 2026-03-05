using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Services.Interfaces;
using System;
using System.Threading.Tasks;

namespace SchoolManager.Controllers.Admin
{
    [Authorize(Roles = "SuperAdmin,superadmin,Admin,admin,Director,director")]
    [Route("Admin/UserPasswordManagement")]
    public class UserPasswordManagementController : Controller
    {
        private readonly IUserPasswordManagementService _userPasswordManagementService;

        public UserPasswordManagementController(IUserPasswordManagementService userPasswordManagementService)
        {
            _userPasswordManagementService = userPasswordManagementService;
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
        public async Task<IActionResult> FilterByRole([FromQuery] string role)
        {
            var users = await _userPasswordManagementService.GetUsersByRoleAsync(role ?? string.Empty);
            return Json(users);
        }
    }
}
