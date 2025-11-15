using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using Npgsql;

namespace SchoolManager.Scripts;

/// <summary>
/// Script para verificar la conexión a la base de datos de Render y probar ejecutar migraciones
/// </summary>
public static class TestRenderConnection
{
    // Cadena de conexión de Render (producción)
    private const string RenderConnectionString = 
        "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true";

    /// <summary>
    /// Verifica la conexión a la base de datos de Render
    /// </summary>
    public static async Task<bool> TestConnectionAsync()
    {
        try
        {
            Console.WriteLine("🔍 Verificando conexión a Render...");
            Console.WriteLine($"📡 Host: dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com");
            Console.WriteLine($"🗄️  Database: schoolmanagement_xqks");
            
            using var connection = new NpgsqlConnection(RenderConnectionString);
            await connection.OpenAsync();
            
            Console.WriteLine("✅ Conexión exitosa a la base de datos de Render!");
            
            // Verificar versión de PostgreSQL
            using var versionCmd = new NpgsqlCommand("SELECT version();", connection);
            var version = await versionCmd.ExecuteScalarAsync();
            Console.WriteLine($"📊 Versión PostgreSQL: {version}");
            
            // Listar tablas existentes
            using var tablesCmd = new NpgsqlCommand(@"
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' 
                ORDER BY table_name;", connection);
            
            using var reader = await tablesCmd.ExecuteReaderAsync();
            var tables = new List<string>();
            while (await reader.ReadAsync())
            {
                tables.Add(reader.GetString(0));
            }
            
            Console.WriteLine($"\n📋 Tablas encontradas ({tables.Count}):");
            foreach (var table in tables)
            {
                Console.WriteLine($"   - {table}");
            }
            
            await connection.CloseAsync();
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error al conectar a Render:");
            Console.WriteLine($"   {ex.GetType().Name}: {ex.Message}");
            if (ex.InnerException != null)
            {
                Console.WriteLine($"   Inner: {ex.InnerException.Message}");
            }
            return false;
        }
    }

    /// <summary>
    /// Verifica si las tablas/columnas de migración ya existen
    /// </summary>
    public static async Task CheckMigrationStatusAsync()
    {
        try
        {
            Console.WriteLine("\n🔍 Verificando estado de las migraciones...");
            
            using var connection = new NpgsqlConnection(RenderConnectionString);
            await connection.OpenAsync();

            // Verificar tabla academic_years
            var academicYearsExists = await CheckTableExistsAsync(connection, "academic_years");
            Console.WriteLine($"   academic_years: {(academicYearsExists ? "✅ Existe" : "❌ No existe")}");

            // Verificar tabla prematriculation_histories
            var historiesExists = await CheckTableExistsAsync(connection, "prematriculation_histories");
            Console.WriteLine($"   prematriculation_histories: {(historiesExists ? "✅ Existe" : "❌ No existe")}");

            // Verificar columna academic_year_id en student_assignments
            var studentAssignmentsExists = await CheckColumnExistsAsync(connection, "student_assignments", "academic_year_id");
            Console.WriteLine($"   student_assignments.academic_year_id: {(studentAssignmentsExists ? "✅ Existe" : "❌ No existe")}");

            // Verificar columna academic_year_id en student_activity_scores
            var scoresExists = await CheckColumnExistsAsync(connection, "student_activity_scores", "academic_year_id");
            Console.WriteLine($"   student_activity_scores.academic_year_id: {(scoresExists ? "✅ Existe" : "❌ No existe")}");

            // Verificar columna academic_year_id en trimester (sin 's')
            var trimestersExists = await CheckColumnExistsAsync(connection, "trimester", "academic_year_id");
            Console.WriteLine($"   trimester.academic_year_id: {(trimestersExists ? "✅ Existe" : "❌ No existe")}");

            // Verificar columna is_active en student_assignments
            var isActiveExists = await CheckColumnExistsAsync(connection, "student_assignments", "is_active");
            Console.WriteLine($"   student_assignments.is_active: {(isActiveExists ? "✅ Existe" : "❌ No existe")}");

            // Verificar columna required_amount en prematriculation_periods
            var requiredAmountExists = await CheckColumnExistsAsync(connection, "prematriculation_periods", "required_amount");
            Console.WriteLine($"   prematriculation_periods.required_amount: {(requiredAmountExists ? "✅ Existe" : "❌ No existe")}");

            await connection.CloseAsync();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error al verificar estado: {ex.Message}");
        }
    }

    private static async Task<bool> CheckTableExistsAsync(NpgsqlConnection connection, string tableName)
    {
        var sql = @"
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = @tableName
            );";
        
        using var cmd = new NpgsqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("tableName", tableName.ToLower());
        var result = await cmd.ExecuteScalarAsync();
        return result != null && (bool)result;
    }

    private static async Task<bool> CheckColumnExistsAsync(NpgsqlConnection connection, string tableName, string columnName)
    {
        var sql = @"
            SELECT EXISTS (
                SELECT FROM information_schema.columns 
                WHERE table_schema = 'public' 
                AND table_name = @tableName
                AND column_name = @columnName
            );";
        
        using var cmd = new NpgsqlCommand(sql, connection);
        cmd.Parameters.AddWithValue("tableName", tableName.ToLower());
        cmd.Parameters.AddWithValue("columnName", columnName.ToLower());
        var result = await cmd.ExecuteScalarAsync();
        return result != null && (bool)result;
    }

    /// <summary>
    /// Ejecuta todas las verificaciones
    /// </summary>
    public static async Task RunAsync()
    {
        Console.WriteLine("═══════════════════════════════════════════════════");
        Console.WriteLine("   VERIFICACIÓN DE CONEXIÓN A RENDER (PRODUCCIÓN)");
        Console.WriteLine("═══════════════════════════════════════════════════\n");

        var connected = await TestConnectionAsync();
        
        if (connected)
        {
            await CheckMigrationStatusAsync();
            
            Console.WriteLine("\n═══════════════════════════════════════════════════");
            Console.WriteLine("✅ CONEXIÓN EXITOSA - Puedes proceder con las migraciones");
            Console.WriteLine("═══════════════════════════════════════════════════");
            Console.WriteLine("\n📝 Para aplicar migraciones, puedes usar:");
            Console.WriteLine("   1. Script ApplyAcademicYearChanges.ApplyAsync()");
            Console.WriteLine("   2. Script ApplyDatabaseChanges.ApplyPrematriculationChangesAsync()");
            Console.WriteLine("   3. Comando: dotnet ef database update --connection \"[connection string]\"");
        }
        else
        {
            Console.WriteLine("\n═══════════════════════════════════════════════════");
            Console.WriteLine("❌ NO SE PUDO CONECTAR - Verifica credenciales o firewall");
            Console.WriteLine("═══════════════════════════════════════════════════");
        }
    }
}

