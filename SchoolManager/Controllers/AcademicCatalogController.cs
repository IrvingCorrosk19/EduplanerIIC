using Microsoft.AspNetCore.Mvc;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SchoolManager.Controllers
{
    public class AcademicCatalogController : Controller
    {
        private readonly ISpecialtyService _specialtyService;
        private readonly IAreaService _areaService;
        private readonly ISubjectService _subjectService;
        private readonly IGradeLevelService _gradeLevelService;
        private readonly IGroupService _groupService;
        private readonly ICurrentUserService _currentUserService;

        public AcademicCatalogController(
            ISpecialtyService specialtyService,
            IAreaService areaService,
            ISubjectService subjectService,
            IGradeLevelService gradeLevelService,
            IGroupService groupService,
            ICurrentUserService currentUserService)
        {
            _specialtyService = specialtyService;
            _areaService = areaService;
            _subjectService = subjectService;
            _gradeLevelService = gradeLevelService;
            _groupService = groupService;
            _currentUserService = currentUserService;
        }

        public IActionResult Upload()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> SaveCatalog([FromBody] List<AcademicCatalogInputModel> catalogData)
        {
            if (catalogData == null || catalogData.Count == 0)
                return BadRequest(new { success = false, message = "No se recibieron datos del catálogo." });

            int especialidadesCreadas = 0;
            int areasCreadas = 0;
            int materiasCreadas = 0;
            int gradosCreados = 0;
            int gruposCreados = 0;
            int duplicadas = 0;
            var errores = new List<string>();

            var currentUser = await _currentUserService.GetCurrentUserAsync();
            var schoolId = currentUser?.SchoolId;

            if (schoolId == null)
            {
                return BadRequest(new { success = false, message = "No se pudo obtener el ID de la escuela." });
            }

            foreach (var item in catalogData)
            {
                try
                {
                    Console.WriteLine($"[SaveCatalog] Procesando: {item.Especialidad} - {item.Area} - {item.Materia} - {item.Grado} - {item.Grupo}");

                    // Normalizar entradas
                    var especialidad = string.IsNullOrWhiteSpace(item.Especialidad) ? "N/A" : item.Especialidad.Trim().ToUpper();
                    var area = string.IsNullOrWhiteSpace(item.Area) ? "N/A" : item.Area.Trim().ToUpper();
                    var materia = string.IsNullOrWhiteSpace(item.Materia) ? "N/A" : item.Materia.Trim().ToUpper();
                    var grado = string.IsNullOrWhiteSpace(item.Grado) ? "N/A" : item.Grado.Trim().ToUpper();
                    var grupo = string.IsNullOrWhiteSpace(item.Grupo) ? "N/A" : item.Grupo.Trim().ToUpper();

                    // Crear o obtener especialidad
                    var specialty = await _specialtyService.GetOrCreateAsync(especialidad);
                    if (specialty == null)
                    {
                        errores.Add($"Error al crear/obtener especialidad: {especialidad}");
                        continue;
                    }
                    if (specialty.Name == especialidad && specialty.Id != Guid.Empty)
                        especialidadesCreadas++;

                    // Crear o obtener área
                    var areaEntity = await _areaService.GetOrCreateAsync(area);
                    if (areaEntity == null)
                    {
                        errores.Add($"Error al crear/obtener área: {area}");
                        continue;
                    }
                    if (areaEntity.Name == area && areaEntity.Id != Guid.Empty)
                        areasCreadas++;

                    // Crear o obtener materia
                    var subject = await _subjectService.GetOrCreateAsync(materia);
                    if (subject == null)
                    {
                        errores.Add($"Error al crear/obtener materia: {materia}");
                        continue;
                    }
                    if (subject.Name == materia && subject.Id != Guid.Empty)
                        materiasCreadas++;

                    // Crear o obtener grado
                    var grade = await _gradeLevelService.GetOrCreateAsync(grado);
                    if (grade == null)
                    {
                        errores.Add($"Error al crear/obtener grado: {grado}");
                        continue;
                    }
                    if (grade.Name == grado && grade.Id != Guid.Empty)
                        gradosCreados++;

                    // Crear o obtener grupo
                    var groupEntity = await _groupService.GetOrCreateAsync(grupo);
                    if (groupEntity == null)
                    {
                        errores.Add($"Error al crear/obtener grupo: {grupo}");
                        continue;
                    }
                    if (groupEntity.Name == grupo && groupEntity.Id != Guid.Empty)
                        gruposCreados++;

                    Console.WriteLine($"[SaveCatalog] Procesado exitosamente: {especialidad} - {area} - {materia} - {grado} - {grupo}");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[SaveCatalog] Excepción en {item.Especialidad} - {item.Area} - {item.Materia}: {ex.Message}");
                    errores.Add($"Excepción en {item.Especialidad} - {item.Area} - {item.Materia}: {ex.Message}");
                }
            }

            return Ok(new
            {
                success = true,
                especialidadesCreadas,
                areasCreadas,
                materiasCreadas,
                gradosCreados,
                gruposCreados,
                duplicadas,
                errores,
                message = "Carga masiva del catálogo completada."
            });
        }
    }
}