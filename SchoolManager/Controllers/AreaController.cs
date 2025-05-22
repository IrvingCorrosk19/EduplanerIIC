using Microsoft.AspNetCore.Mvc;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

public class AreaController : Controller
{
    private readonly IAreaService _areaService;

    public AreaController(IAreaService areaService)
    {
        _areaService = areaService;
    }

    public async Task<IActionResult> Index()
    {
        var areas = await _areaService.GetAllAsync();
        return View(areas);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Area area)
    {
        if (string.IsNullOrWhiteSpace(area.Name))
        {
            return Json(new { success = false, message = "El nombre del área es obligatorio." });
        }

        try
        {
            var newArea = await _areaService.CreateAsync(area);
            return Json(new { 
                success = true, 
                id = newArea.Id, 
                name = newArea.Name,
                description = newArea.Description,
                message = "Área creada exitosamente."
            });
        }
        catch (Exception ex)
        {
            return Json(new { success = false, message = "Error al crear el área: " + ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> Edit([FromBody] Area area)
    {
        if (string.IsNullOrWhiteSpace(area.Name))
        {
            return Json(new { success = false, message = "El nombre del área es obligatorio." });
        }

        try
        {
            var updatedArea = await _areaService.UpdateAsync(area);
            return Json(new { 
                success = true, 
                id = updatedArea.Id, 
                name = updatedArea.Name,
                description = updatedArea.Description,
                message = "Área actualizada exitosamente."
            });
        }
        catch (Exception ex)
        {
            return Json(new { success = false, message = "Error al actualizar el área: " + ex.Message });
        }
    }

    [HttpPost]
    public async Task<IActionResult> Delete([FromBody] DeleteAreaRequest request)
    {
        if (request.Id == Guid.Empty)
        {
            return Json(new { success = false, message = "ID de área inválido." });
        }

        try
        {
            await _areaService.DeleteAsync(request.Id);
            return Json(new { success = true, message = "Área eliminada exitosamente." });
        }
        catch (Exception ex)
        {
            return Json(new { success = false, message = "Error al eliminar el área: " + ex.Message });
        }
    }
}

public class DeleteAreaRequest
{
    public Guid Id { get; set; }
} 