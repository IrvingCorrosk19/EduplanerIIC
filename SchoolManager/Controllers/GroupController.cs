﻿using Microsoft.AspNetCore.Mvc;
using SchoolManager.Models;

public class GroupController : Controller
{
    private readonly IGroupService _groupService;

    public GroupController(IGroupService groupService)
    {
        _groupService = groupService;
    }

    // Vista tradicional
    public async Task<IActionResult> Index()
    {
        var groups = await _groupService.GetAllAsync();
        return View(groups);
    }

    // 🔹 API para obtener lista JSON de grupos
    [HttpGet]
    public async Task<IActionResult> ListJson()
    {
        var groups = await _groupService.GetAllAsync();
        return Json(new { success = true, data = groups });
    }

    // 🔹 Crear grupo desde modal
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Group group)
    {
        if (string.IsNullOrWhiteSpace(group.Name))
        {
            return Json(new { success = false, message = "El nombre del grupo es obligatorio." });
        }

        try
        {
            var newGroup = await _groupService.CreateAsync(group);
            return Json(new { 
                success = true, 
                id = newGroup.Id,
                name = newGroup.Name,
                description = newGroup.Description
            });
        }
        catch (Exception ex)
        {
            return Json(new { success = false, message = $"Error al crear el grupo: {ex.Message}" });
        }
    }

    // 🔹 Editar grupo desde modal (por AJAX)
    [HttpPost]
    public async Task<IActionResult> Edit([FromBody] Group group)
    {
        if (group == null || string.IsNullOrWhiteSpace(group.Name))
        {
            return Json(new { success = false, message = "Datos inválidos." });
        }

        try
        {
            var existing = await _groupService.GetByIdAsync(group.Id);
            if (existing == null) 
                return Json(new { success = false, message = "Grupo no encontrado." });

            existing.Name = group.Name;
            existing.Description = group.Description;
            await _groupService.UpdateAsync(existing);

            return Json(new { success = true });
        }
        catch (Exception ex)
        {
            return Json(new { success = false, message = $"Error al actualizar el grupo: {ex.Message}" });
        }
    }

    // 🔹 Eliminar grupo desde modal (por AJAX)
    [HttpPost]
    public async Task<IActionResult> Delete([FromBody] Group group)
    {
        if (group == null || group.Id == Guid.Empty)
        {
            return Json(new { success = false, message = "ID de grupo inválido." });
        }

        try
        {
            await _groupService.DeleteAsync(group.Id);
            return Json(new { success = true });
        }
        catch (Exception ex)
        {
            return Json(new { success = false, message = $"Error al eliminar el grupo: {ex.Message}" });
        }
    }

    // ⚠️ Opcional: puedes eliminar estos si no usas vistas tradicionales:
    public async Task<IActionResult> Details(Guid id)
    {
        var group = await _groupService.GetByIdAsync(id);
        if (group == null) return NotFound();
        return View(group);
    }

    public IActionResult Create() => View();

    public async Task<IActionResult> Edit(Guid id)
    {
        var group = await _groupService.GetByIdAsync(id);
        if (group == null) return NotFound();
        return View(group);
    }
}

public class DeleteGroupRequest
{
    public Guid Id { get; set; }
}
