using SchoolManager.Models;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Services.Interfaces;

public class GroupService : IGroupService
{
    private readonly SchoolDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public GroupService(SchoolDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }
    public async Task<Group?> GetByNameAndGradeAsync(string groupName)
    {
        return await _context.Groups
            .FirstOrDefaultAsync(g =>
                g.Name.ToLower() == groupName.ToLower());
    }
    public async Task<Group> GetOrCreateAsync(string name)
    {
        name = name.Trim().ToUpper();
        var group = await _context.Groups.FirstOrDefaultAsync(g => g.Name.ToUpper() == name);
        if (group == null)
        {
            group = new Group
            {
                Id = Guid.NewGuid(),
                Name = name,
                CreatedAt = DateTime.UtcNow
            };
            _context.Groups.Add(group);
            await _context.SaveChangesAsync();
        }
        return group;
    }

    public async Task<List<Group>> GetAllAsync()
    {
        return await _context.Groups.ToListAsync();
    }


    public async Task<Group?> GetByIdAsync(Guid id) =>
        await _context.Groups.FindAsync(id);

    public async Task<Group> CreateAsync(Group group)
    {
        try
        {
            group.Id = Guid.NewGuid();
            group.CreatedAt = DateTime.UtcNow;

            _context.Groups.Add(group);
            await _context.SaveChangesAsync();

            return group;
        }
        catch (Exception ex)
        {
            throw new Exception($"Error al crear el grupo: {ex.Message}", ex);
        }
    }


    public async Task UpdateAsync(Group group)
    {
        _context.Groups.Update(group);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Guid id)
    {
        // Validar si el grupo está en uso en alguna asignación de materia
        bool enUso = await _context.SubjectAssignments.AnyAsync(sa => sa.GroupId == id);
        if (enUso)
            throw new InvalidOperationException("No se puede borrar el grupo porque está siendo utilizado en el catálogo de materias. Elimina o reasigna esas asignaciones primero.");
        try
        {
            var group = await _context.Groups.FindAsync(id);
            if (group != null)
            {
                _context.Groups.Remove(group);
                await _context.SaveChangesAsync();
            }
        }
        catch (Exception ex)
        {
            throw new Exception("Error al eliminar el grupo.", ex);
        }
    }

}
