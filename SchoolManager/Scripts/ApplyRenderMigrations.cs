using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace SchoolManager.Scripts;

/// <summary>
/// Script para aplicar migraciones a la base de datos de Render (producción)
/// </summary>
public static class ApplyRenderMigrations
{
    // Cadena de conexión de Render (producción)
    private const string RenderConnectionString = 
        "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true";

    /// <summary>
    /// Crea un SchoolDbContext con la conexión de Render
    /// </summary>
    private static SchoolDbContext CreateRenderDbContext()
    {
        var optionsBuilder = new DbContextOptionsBuilder<SchoolDbContext>();
        optionsBuilder.UseNpgsql(RenderConnectionString);
        
        // Configurar interceptor de DateTime
        optionsBuilder.AddInterceptors(new DateTimeInterceptor());
        
        return new SchoolDbContext(optionsBuilder.Options);
    }

    /// <summary>
    /// Aplica todas las migraciones necesarias a la base de datos de Render
    /// </summary>
    public static async Task ApplyAllMigrationsAsync()
    {
        Console.WriteLine("═══════════════════════════════════════════════════");
        Console.WriteLine("   APLICANDO MIGRACIONES A RENDER (PRODUCCIÓN)");
        Console.WriteLine("═══════════════════════════════════════════════════\n");

        try
        {
            using var context = CreateRenderDbContext();

            // Paso 1: Verificar conexión
            Console.WriteLine("🔍 Paso 1: Verificando conexión...");
            var canConnect = await context.Database.CanConnectAsync();
            if (!canConnect)
            {
                Console.WriteLine("❌ No se puede conectar a la base de datos de Render");
                return;
            }
            Console.WriteLine("✅ Conexión exitosa\n");

            // Paso 2: Aplicar cambios de prematriculación
            Console.WriteLine("🔧 Paso 2: Aplicando cambios de prematriculación...");
            await ApplyDatabaseChanges.ApplyPrematriculationChangesAsync(context);
            Console.WriteLine("✅ Cambios de prematriculación aplicados\n");

            // Paso 3: Aplicar cambios de año académico
            Console.WriteLine("🔧 Paso 3: Aplicando cambios de año académico...");
            await ApplyAcademicYearChanges.ApplyAsync(context);
            Console.WriteLine("✅ Cambios de año académico aplicados\n");

            // Paso 4: Verificar estado final
            Console.WriteLine("🔍 Paso 4: Verificando estado final...");
            await TestRenderConnection.CheckMigrationStatusAsync();

            Console.WriteLine("\n═══════════════════════════════════════════════════");
            Console.WriteLine("✅ MIGRACIONES APLICADAS EXITOSAMENTE");
            Console.WriteLine("═══════════════════════════════════════════════════");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n❌ ERROR al aplicar migraciones:");
            Console.WriteLine($"   Tipo: {ex.GetType().Name}");
            Console.WriteLine($"   Mensaje: {ex.Message}");
            if (ex.InnerException != null)
            {
                Console.WriteLine($"   Inner: {ex.InnerException.Message}");
            }
            Console.WriteLine($"\n📋 Stack trace:");
            Console.WriteLine(ex.StackTrace);
            throw;
        }
    }

    /// <summary>
    /// Aplica solo los cambios de prematriculación
    /// </summary>
    public static async Task ApplyPrematriculationOnlyAsync()
    {
        Console.WriteLine("═══════════════════════════════════════════════════");
        Console.WriteLine("   APLICANDO CAMBIOS DE PREMATRICULACIÓN A RENDER");
        Console.WriteLine("═══════════════════════════════════════════════════\n");

        try
        {
            using var context = CreateRenderDbContext();

            Console.WriteLine("🔍 Verificando conexión...");
            var canConnect = await context.Database.CanConnectAsync();
            if (!canConnect)
            {
                Console.WriteLine("❌ No se puede conectar a la base de datos de Render");
                return;
            }
            Console.WriteLine("✅ Conexión exitosa\n");

            Console.WriteLine("🔧 Aplicando cambios de prematriculación...");
            await ApplyDatabaseChanges.ApplyPrematriculationChangesAsync(context);
            Console.WriteLine("✅ Cambios aplicados exitosamente\n");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ ERROR: {ex.Message}");
            throw;
        }
    }

    /// <summary>
    /// Aplica solo los cambios de año académico
    /// </summary>
    public static async Task ApplyAcademicYearOnlyAsync()
    {
        Console.WriteLine("═══════════════════════════════════════════════════");
        Console.WriteLine("   APLICANDO CAMBIOS DE AÑO ACADÉMICO A RENDER");
        Console.WriteLine("═══════════════════════════════════════════════════\n");

        try
        {
            using var context = CreateRenderDbContext();

            Console.WriteLine("🔍 Verificando conexión...");
            var canConnect = await context.Database.CanConnectAsync();
            if (!canConnect)
            {
                Console.WriteLine("❌ No se puede conectar a la base de datos de Render");
                return;
            }
            Console.WriteLine("✅ Conexión exitosa\n");

            Console.WriteLine("🔧 Aplicando cambios de año académico...");
            await ApplyAcademicYearChanges.ApplyAsync(context);
            Console.WriteLine("✅ Cambios aplicados exitosamente\n");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ ERROR: {ex.Message}");
            throw;
        }
    }
}

