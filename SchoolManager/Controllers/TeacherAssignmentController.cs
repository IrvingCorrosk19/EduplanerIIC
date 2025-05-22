﻿using System;
using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using Microsoft.EntityFrameworkCore;

public class TeacherAssignmentController : Controller
{
    private readonly ITeacherAssignmentService _teacherAssignmentService;
    private readonly IUserService _userService;
    private readonly ISubjectService _subjectService;
    private readonly IGroupService _groupService;
    private readonly IAreaService _areaService;
    private readonly ISpecialtyService _specialtyService;
    private readonly IGradeLevelService _gradeLevelService;
    private readonly ISubjectAssignmentService _subjectAssignmentService;
    private readonly IMapper _mapper;

    public TeacherAssignmentController(
        ITeacherAssignmentService teacherAssignmentService,
        IUserService userService,
        ISubjectService subjectService,
        IGroupService groupService,
        IAreaService areaService,
        ISpecialtyService specialtyService,
        IGradeLevelService gradeLevelService,
        IMapper mapper,
        ISubjectAssignmentService subjectAssignmentService)
    {
        _teacherAssignmentService = teacherAssignmentService;
        _userService = userService;
        _subjectService = subjectService;
        _groupService = groupService;
        _areaService = areaService;
        _specialtyService = specialtyService;
        _gradeLevelService = gradeLevelService;
        _mapper = mapper;
        _subjectAssignmentService = subjectAssignmentService;
    }

    [HttpPost("SaveAssignments")]
    public async Task<IActionResult> SaveAssignments([FromBody] SaveTeacherAssignmentsRequest request)
    {
        try
        {
            // Validar que no haya asignaciones duplicadas con otros profesores
            foreach (var assignment in request.Assignments)
            {
                var existingAssignment = await _teacherAssignmentService.GetExistingAssignmentAsync(
                    request.TeacherId,
                    assignment.SpecialtyId,
                    assignment.AreaId,
                    assignment.SubjectId,
                    assignment.GradeLevelId,
                    assignment.GroupId);

                if (existingAssignment != null)
                {
                    return Json(new { 
                        success = false, 
                        message = $"La combinación de Especialidad '{existingAssignment.SubjectAssignment.Specialty?.Name}', " +
                                 $"Área '{existingAssignment.SubjectAssignment.Area?.Name}', " +
                                 $"Materia '{existingAssignment.SubjectAssignment.Subject?.Name}', " +
                                 $"Grado '{existingAssignment.SubjectAssignment.GradeLevel?.Name}' y " +
                                 $"Grupo '{existingAssignment.SubjectAssignment.Group?.Name}' " +
                                 $"ya está asignada al profesor {existingAssignment.Teacher.Name}."
                    });
                }
            }

            // Obtener los IDs de las asignaciones de materias
            var (success, subjectAssignmentIds, failedAssignment) = 
                await _teacherAssignmentService.GetSubjectAssignmentIdsAsync(request);

            if (!success)
            {
                return Json(new { 
                    success = false, 
                    message = "No se pudo procesar alguna de las asignaciones solicitadas." 
                });
            }

            // Eliminar asignaciones existentes
            await _teacherAssignmentService.DeleteAllAssignmentsByTeacherIdAsync(request.TeacherId);

            // Crear nuevas asignaciones
            foreach (var subjectAssignmentId in subjectAssignmentIds)
            {
                await _teacherAssignmentService.AddAssignmentAsync(request.TeacherId, subjectAssignmentId);
            }

            return Json(new { success = true, message = "Asignaciones guardadas correctamente." });
        }
        catch (Exception ex)
        {
            return Json(new { success = false, message = "Error al guardar las asignaciones: " + ex.Message });
        }
    }

    [HttpGet]
    public async Task<IActionResult> GetGroupsByGrade(Guid subjectId, Guid specialtyId, Guid areaId, Guid gradeLevelId)
    {
        var groups = await _subjectAssignmentService.GetGroupsByGradeLevelAsync(subjectId, specialtyId, areaId, gradeLevelId);
        return Json(groups.Select(g => new { g.Id, g.Name }));
    }

    [HttpGet]
    public async Task<IActionResult> GetGradeLevelsBySubjectAsync(Guid subjectId, Guid specialtyId, Guid areaId)
    {
        var gradeLevels = await _subjectAssignmentService.GetGradeLevelsBySubjectIdAsync(subjectId, specialtyId, areaId);
        return Json(gradeLevels.Select(g => new { g.Id, g.Name }));
    }

    [HttpGet]
    public async Task<IActionResult> GetSubjectsBySpecialtyAndArea(Guid specialtyId, Guid areaId)
    {
        var subjects = await _subjectAssignmentService.GetSubjectsBySpecialtyAndAreaAsync(specialtyId, areaId); // Este método debe aceptar ambos IDs
        return Json(subjects.Select(s => new { s.Id, s.Name }));
    }

    [HttpGet]
    public async Task<IActionResult> GetAreasBySpecialtyId(Guid specialtyId)
    {
        var areas = await _subjectAssignmentService.GetBySpecialtyIdAsync(specialtyId); // Debes tener este método implementado
        return Json(areas.Select(a => new { a.Id, a.Name }));
    }

    [HttpGet]
    public async Task<IActionResult> GetAllSubjectAssignments()
    {
        var assignments = await _subjectAssignmentService.GetAllSubjectAssignments(); // Asegúrate de incluir .Include() en tu servicio

        var result = assignments.Select(a => new {
            id = a.Id,
            specialtyId = a.SpecialtyId,
            specialtyName = a.Specialty?.Name,
            areaId = a.AreaId,
            areaName = a.Area?.Name,
            subjectId = a.SubjectId,
            subjectName = a.Subject?.Name,
            gradeLevelId = a.GradeLevelId,
            gradeLevelName = a.GradeLevel?.Name,
            groupId = a.GroupId,
            groupName = a.Group?.Name
        });

        return Json(result);
    }

    public async Task<IActionResult> Index()
    {
        // 🔹 Obtener todos los usuarios con rol "teacher", con asignaciones incluidas
        var teachers = await _userService.GetAllWithAssignmentsByRoleAsync("teacher");

        var teacherDtos = new List<TeacherAssignmentDisplayDto>();

        foreach (var teacher in teachers)
        {
            var assignments = teacher.TeacherAssignments ?? new List<TeacherAssignment>();

            var dto = new TeacherAssignmentDisplayDto
            {
                TeacherId = teacher.Id,
                FullName = teacher.Name,
                Email = teacher.Email,
                Role = teacher.Role,
                IsActive = string.Equals(teacher.Status, "active", StringComparison.OrdinalIgnoreCase),

                SubjectGroupDetails = assignments.Any()
                    ? assignments
                        .Where(a => a.SubjectAssignment != null && a.SubjectAssignment.Subject != null) // Solo validamos lo esencial
                        .GroupBy(a => new
                        {
                            SubjectId = a.SubjectAssignment.SubjectId,
                            SubjectName = a.SubjectAssignment.Subject.Name
                        })
                        .Select(g => new SubjectGroupSummary
                        {
                            SubjectId = g.Key.SubjectId,
                            SubjectName = g.Key.SubjectName,
                            GroupGradePairs = g.Select(x => new GroupGradeItem
                            {
                                GroupId = x.SubjectAssignment.GroupId,
                                GroupName = x.SubjectAssignment.Group?.Name ?? "Sin grupo",
                                GradeLevelId = x.SubjectAssignment.GradeLevelId,
                                GradeLevelName = x.SubjectAssignment.GradeLevel?.Name ?? "Sin grado",
                                SpecialtyName = x.SubjectAssignment.Specialty?.Name ?? "Sin especialidad",
                                AreaName = x.SubjectAssignment.Area?.Name ?? "Sin área"
                            })
                            .OrderBy(x => x.GradeLevelName)
                            .ThenBy(x => x.GroupName)
                            .ToList()
                        })
                        .OrderBy(g => g.SubjectName)
                        .ToList()
                    : new List<SubjectGroupSummary>()
            };

            teacherDtos.Add(dto);
        }

        // 🔹 Obtener datos de catálogo para los dropdowns
        var specialties = await _specialtyService.GetAllAsync();

        // 🔹 Cargar en ViewBag para usar en dropdowns dinámicos
        ViewBag.Subjects = null;
        ViewBag.Groups = null;
        ViewBag.Areas = null;
        ViewBag.Specialties = specialties;
        ViewBag.GradeLevels = null;

        var viewModel = new TeacherAssignmentViewModel
        {
            TeachersWithAssignments = teacherDtos
        };

        return View(viewModel);
    }

    [HttpPost]
    public async Task<IActionResult> Edit(Guid TeacherId, Guid SubjectId, Guid GradeLevelId, Guid GroupId, Guid AreaId, Guid SpecialtyId)
    {
        // Aquí debes aplicar lógica para actualizar la asignación del docente
        await _teacherAssignmentService.UpdateAsync(TeacherId, SubjectId, GradeLevelId, GroupId, AreaId, SpecialtyId);
        return RedirectToAction(nameof(Index));
    }

    [HttpGet]
    public async Task<IActionResult> GetAssignmentsByTeacher(Guid id)
    {
        var assignments = await _teacherAssignmentService.GetAssignmentsForModalByTeacherIdAsync(id);
        var assignmentsAll = await _subjectAssignmentService.GetAllSubjectAssignments();

        var subjects = await _subjectService.GetAllAsync();
        var groups = await _groupService.GetAllAsync();
        var areas = await _areaService.GetAllAsync();
        var specialties = await _specialtyService.GetAllAsync();
        var gradeLevels = await _gradeLevelService.GetAllAsync();

        var currentAssignments = assignments.Select(a => new
        {
            teacherAssignmentId = a.Id,
            subjectAssignmentId = a.SubjectAssignmentId,
            specialtyId = a.SubjectAssignment.SpecialtyId,
            specialty = a.SubjectAssignment.Specialty?.Name,
            areaId = a.SubjectAssignment.AreaId,
            area = a.SubjectAssignment.Area?.Name,
            subjectId = a.SubjectAssignment.SubjectId,
            subject = a.SubjectAssignment.Subject?.Name,
            gradeLevelId = a.SubjectAssignment.GradeLevelId,
            grade = a.SubjectAssignment.GradeLevel?.Name,
            groupId = a.SubjectAssignment.GroupId,
            group = a.SubjectAssignment.Group?.Name
        });

        var allPossibleAssignments = assignmentsAll.Select(a => new
        {
            id = a.Id,
            specialtyId = a.SpecialtyId,
            specialtyName = a.Specialty?.Name,
            areaId = a.AreaId,
            areaName = a.Area?.Name,
            subjectId = a.SubjectId,
            subjectName = a.Subject?.Name,
            gradeLevelId = a.GradeLevelId,
            gradeLevelName = a.GradeLevel?.Name,
            groupId = a.GroupId,
            groupName = a.Group?.Name
        });

        return Json(new
        {
            currentAssignments,
            allPossibleAssignments
        });
    }

    [HttpPost]
    public async Task<IActionResult> DeleteConfirmed(Guid id)
    {
        await _teacherAssignmentService.DeleteAllAssignmentsByTeacherIdAsync(id);

        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    public async Task<IActionResult> Edit(Guid id, TeacherAssignmentViewModel model)
    {
        if (!ModelState.IsValid || model.SelectedSubjectId == null || model.SelectedGroupId == null ||
            model.SelectedGradeLevelId == null || model.SelectedAreaId == null || model.SelectedSpecialtyId == null)
        {
            return BadRequest("Datos inválidos para la edición.");
        }

        await _teacherAssignmentService.UpdateAsync(
            id,
            model.SelectedSubjectId.Value,
            model.SelectedGroupId.Value,
            model.SelectedGradeLevelId.Value,
            model.SelectedAreaId.Value,
            model.SelectedSpecialtyId.Value
        );

        return RedirectToAction(nameof(Index));
    }
}
