using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;

namespace SchoolManager.Scripts;

/// <summary>
/// Crea la tabla school_schedule_configurations si no existe (por si la migración no se aplicó).
/// </summary>
public static class EnsureSchoolScheduleConfigurationTable
{
    public static async Task EnsureAsync(SchoolDbContext context)
    {
        try
        {
            var exists = await context.Database
                .SqlQueryRaw<int>(
                    @"SELECT 1 FROM information_schema.tables 
                      WHERE table_schema = 'public' AND table_name = 'school_schedule_configurations' 
                      LIMIT 1")
                .ToListAsync();

            if (exists.Count > 0)
            {
                // Asegurar que existan las columnas de tarde (por si la tabla se creó sin ellas)
                await EnsureAfternoonColumnsAsync(context);
                return;
            }

            await context.Database.ExecuteSqlRawAsync(@"
CREATE TABLE school_schedule_configurations (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    school_id uuid NOT NULL,
    morning_start_time time NOT NULL,
    morning_block_duration_minutes integer NOT NULL,
    morning_block_count integer NOT NULL,
    afternoon_start_time time NULL,
    afternoon_block_duration_minutes integer NULL,
    afternoon_block_count integer NULL,
    created_at timestamp with time zone NULL,
    updated_at timestamp with time zone NULL,
    CONSTRAINT school_schedule_configurations_pkey PRIMARY KEY (id),
    CONSTRAINT school_schedule_configurations_school_id_fkey
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX IX_school_schedule_configurations_school_id
    ON school_schedule_configurations (school_id);
");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[EnsureSchoolScheduleConfigurationTable] Error: {ex.Message}");
        }
    }

    /// <summary>
    /// Añade las columnas de jornada tarde si no existen (tabla creada antes de tener tarde).
    /// </summary>
    private static async Task EnsureAfternoonColumnsAsync(SchoolDbContext context)
    {
        try
        {
            var hasColumn = await context.Database
                .SqlQueryRaw<int>(
                    @"SELECT 1 FROM information_schema.columns 
                      WHERE table_schema = 'public' AND table_name = 'school_schedule_configurations' AND column_name = 'afternoon_start_time' 
                      LIMIT 1")
                .ToListAsync();
            if (hasColumn.Count > 0)
                return;

            await context.Database.ExecuteSqlRawAsync(@"
ALTER TABLE school_schedule_configurations ADD COLUMN IF NOT EXISTS afternoon_start_time time NULL;
ALTER TABLE school_schedule_configurations ADD COLUMN IF NOT EXISTS afternoon_block_duration_minutes integer NULL;
ALTER TABLE school_schedule_configurations ADD COLUMN IF NOT EXISTS afternoon_block_count integer NULL;
");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"[EnsureSchoolScheduleConfigurationTable] EnsureAfternoonColumns: {ex.Message}");
        }
    }
}
