using Microsoft.AspNetCore.Mvc;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using SchoolManager.Dtos;
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
        private readonly ITrimesterService _trimesterService;

        public AcademicCatalogController(
            ISpecialtyService specialtyService,
            IAreaService areaService,
            ISubjectService subjectService,
            IGradeLevelService gradeLevelService,
            IGroupService groupService,
            ICurrentUserService currentUserService,
            ITrimesterService trimesterService)
        {
            _specialtyService = specialtyService;
            _areaService = areaService;
            _subjectService = subjectService;
            _gradeLevelService = gradeLevelService;
            _groupService = groupService;
            _currentUserService = currentUserService;
            _trimesterService = trimesterService;
        }

        public async Task<IActionResult> Index()
        {
            var specialties = await _specialtyService.GetAllAsync();
            var areas = await _areaService.GetAllAsync();
            var subjects = await _subjectService.GetAllAsync();
            var grades = await _gradeLevelService.GetAllAsync();
            var groups = await _groupService.GetAllAsync();
            var trimestres = await _trimesterService.GetAllAsync();

            var viewModel = new AcademicCatalogViewModel
            {
                Specialties = specialties,
                Areas = areas,
                Subjects = subjects,
                GradesLevel = grades,
                Groups = groups,
                Trimestres = trimestres
            };

            return View(viewModel);
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

        [HttpPost]
        public async Task<IActionResult> GuardarTrimestres([FromBody] List<TrimesterDto> trimestres)
        {
            try
            {
                if (trimestres == null || trimestres.Count == 0)
                {
                    return BadRequest(new { success = false, message = "No se recibieron datos de trimestres." });
                }

                await _trimesterService.GuardarTrimestresAsync(trimestres);
                return Ok(new { success = true, message = "Configuración de trimestres guardada correctamente." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> ActivarTrimestre([FromBody] TrimestreIdRequest request)
        {
            try
            {
                if (request == null || request.Id == Guid.Empty)
                {
                    return BadRequest(new { success = false, message = "ID de trimestre inválido." });
                }

                var resultado = await _trimesterService.ActivarTrimestreAsync(request.Id);
                if (resultado)
                {
                    return Ok(new { success = true, message = "Trimestre activado correctamente." });
                }
                else
                {
                    return NotFound(new { success = false, message = "Trimestre no encontrado." });
                }
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> DesactivarTrimestre([FromBody] TrimestreIdRequest request)
        {
            try
            {
                if (request == null || request.Id == Guid.Empty)
                {
                    return BadRequest(new { success = false, message = "ID de trimestre inválido." });
                }

                var resultado = await _trimesterService.DesactivarTrimestreAsync(request.Id);
                if (resultado)
                {
                    return Ok(new { success = true, message = "Trimestre desactivado correctamente." });
                }
                else
                {
                    return NotFound(new { success = false, message = "Trimestre no encontrado." });
                }
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> EditarTrimestre([FromBody] EditarTrimestreRequest request)
        {
            try
            {
                if (request == null || request.Id == Guid.Empty)
                {
                    return BadRequest(new { success = false, message = "ID de trimestre inválido." });
                }

                if (string.IsNullOrEmpty(request.StartDate) || string.IsNullOrEmpty(request.EndDate))
                {
                    return BadRequest(new { success = false, message = "Debes proporcionar ambas fechas." });
                }

                if (!DateTime.TryParse(request.StartDate, out var startDate) || 
                    !DateTime.TryParse(request.EndDate, out var endDate))
                {
                    return BadRequest(new { success = false, message = "Formato de fechas inválido." });
                }

                var dto = new TrimesterDto
                {
                    Id = request.Id,
                    StartDate = startDate,
                    EndDate = endDate
                };

                var resultado = await _trimesterService.EditarFechasTrimestreAsync(dto);
                if (resultado)
                {
                    return Ok(new { success = true, message = "Fechas actualizadas correctamente." });
                }
                else
                {
                    return NotFound(new { success = false, message = "Trimestre no encontrado." });
                }
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> EliminarTodosLosTrimestres()
        {
            try
            {
                await _trimesterService.EliminarTodosLosTrimestresAsync();
                return Ok(new { success = true, message = "Todos los trimestres han sido eliminados." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }

    public class TrimestreIdRequest
    {
        public Guid Id { get; set; }
    }

    public class EditarTrimestreRequest
    {
        public Guid Id { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }
    }
}