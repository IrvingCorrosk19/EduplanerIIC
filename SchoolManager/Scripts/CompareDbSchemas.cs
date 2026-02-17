using Npgsql;

namespace SchoolManager.Scripts;

/// <summary>
/// Compara la estructura de la BD LOCAL (referencia) con la BD RENDER.
/// La BD local se considera la más nueva; identifica qué le falta a Render.
/// Ejecutar: dotnet run -- --compare-db-schemas
/// </summary>
public static class CompareDbSchemas
{
    private const string LocalConnectionString =
        "Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$;Port=5432";
    private const string RenderConnectionString =
        "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true";

    public static async Task RunAsync()
    {
        Console.WriteLine("═══════════════════════════════════════════════════════════════════");
        Console.WriteLine("   ANÁLISIS: ESTRUCTURA LOCAL vs RENDER");
        Console.WriteLine("   (Local = referencia más nueva; Render = destino a homologar)");
        Console.WriteLine("═══════════════════════════════════════════════════════════════════\n");

        try
        {
            var localTables = await GetTablesAndColumnsAsync(LocalConnectionString, "LOCAL");
            var renderTables = await GetTablesAndColumnsAsync(RenderConnectionString, "RENDER");

            // 1. Tablas en LOCAL que no existen en RENDER
            var tablesOnlyInLocal = localTables.Keys.Except(renderTables.Keys).OrderBy(t => t).ToList();
            // 2. Tablas en RENDER que no existen en LOCAL (información)
            var tablesOnlyInRender = renderTables.Keys.Except(localTables.Keys).OrderBy(t => t).ToList();
            // 3. Columnas faltantes: en cada tabla común, columnas que están en LOCAL pero no en RENDER
            var missingColumns = new List<(string Table, string Column, string DataType)>();

            foreach (var table in localTables.Keys.Intersect(renderTables.Keys))
            {
                var localCols = localTables[table];
                var renderCols = renderTables[table];
                foreach (var col in localCols)
                {
                    if (!renderCols.ContainsKey(col.Key))
                        missingColumns.Add((table, col.Key, col.Value));
                }
            }

            // Salida del análisis
            Console.WriteLine("┌─────────────────────────────────────────────────────────────────┐");
            Console.WriteLine("│ 1. TABLAS QUE EXISTEN EN LOCAL PERO NO EN RENDER                │");
            Console.WriteLine("│    (Faltan crear en Render)                                      │");
            Console.WriteLine("└─────────────────────────────────────────────────────────────────┘");
            if (tablesOnlyInLocal.Count == 0)
                Console.WriteLine("   Ninguna. Todas las tablas de Local existen en Render.\n");
            else
            {
                foreach (var t in tablesOnlyInLocal)
                    Console.WriteLine($"   • {t}");
                Console.WriteLine();
            }

            Console.WriteLine("┌─────────────────────────────────────────────────────────────────┐");
            Console.WriteLine("│ 2. TABLAS QUE EXISTEN EN RENDER PERO NO EN LOCAL                │");
            Console.WriteLine("│    (Pueden ser legado o desusadas)                               │");
            Console.WriteLine("└─────────────────────────────────────────────────────────────────┘");
            if (tablesOnlyInRender.Count == 0)
                Console.WriteLine("   Ninguna.\n");
            else
            {
                foreach (var t in tablesOnlyInRender)
                    Console.WriteLine($"   • {t}");
                Console.WriteLine();
            }

            Console.WriteLine("┌─────────────────────────────────────────────────────────────────┐");
            Console.WriteLine("│ 3. COLUMNAS QUE EXISTEN EN LOCAL PERO NO EN RENDER              │");
            Console.WriteLine("│    (Faltan agregar en Render)                                    │");
            Console.WriteLine("└─────────────────────────────────────────────────────────────────┘");
            if (missingColumns.Count == 0)
                Console.WriteLine("   Ninguna. Todas las columnas están homologadas.\n");
            else
            {
                foreach (var (tbl, col, dt) in missingColumns.OrderBy(x => x.Table).ThenBy(x => x.Column))
                    Console.WriteLine($"   • {tbl}.{col}  ({dt})");
                Console.WriteLine();
            }

            // Índices (opcional, resumido)
            var localIndexes = await GetIndexesAsync(LocalConnectionString);
            var renderIndexes = await GetIndexesAsync(RenderConnectionString);
            var indexesOnlyInLocal = localIndexes.Except(renderIndexes).OrderBy(x => x).ToList();

            Console.WriteLine("┌─────────────────────────────────────────────────────────────────┐");
            Console.WriteLine("│ 4. ÍNDICES QUE EXISTEN EN LOCAL PERO NO EN RENDER               │");
            Console.WriteLine("└─────────────────────────────────────────────────────────────────┘");
            if (indexesOnlyInLocal.Count == 0)
                Console.WriteLine("   Ninguno.\n");
            else
            {
                foreach (var idx in indexesOnlyInLocal)
                    Console.WriteLine($"   • {idx}");
                Console.WriteLine();
            }

            // Constraints CHECK (ej. users_role_check)
            var localChecks = await GetCheckConstraintsAsync(LocalConnectionString);
            var renderChecks = await GetCheckConstraintsAsync(RenderConnectionString);
            var checksOnlyInLocal = localChecks.Except(renderChecks).OrderBy(x => x).ToList();

            Console.WriteLine("┌─────────────────────────────────────────────────────────────────┐");
            Console.WriteLine("│ 5. CONSTRAINTS CHECK EN LOCAL QUE NO ESTÁN EN RENDER            │");
            Console.WriteLine("└─────────────────────────────────────────────────────────────────┘");
            if (checksOnlyInLocal.Count == 0)
                Console.WriteLine("   Ninguno.\n");
            else
            {
                foreach (var c in checksOnlyInLocal)
                    Console.WriteLine($"   • {c}");
                Console.WriteLine();
            }

            Console.WriteLine("═══════════════════════════════════════════════════════════════════");
            Console.WriteLine("   FIN DEL ANÁLISIS (solo lectura, no se modificó nada)");
            Console.WriteLine("═══════════════════════════════════════════════════════════════════");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n❌ Error: {ex.Message}");
            if (ex.InnerException != null)
                Console.WriteLine($"   Inner: {ex.InnerException.Message}");
        }
    }

    private static async Task<Dictionary<string, Dictionary<string, string>>> GetTablesAndColumnsAsync(
        string connStr, string label)
    {
        var result = new Dictionary<string, Dictionary<string, string>>(StringComparer.OrdinalIgnoreCase);
        await using var conn = new NpgsqlConnection(connStr);
        await conn.OpenAsync();

        var sql = @"
            SELECT table_name, column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = 'public' AND table_catalog = current_database()
            ORDER BY table_name, ordinal_position;";
        await using var cmd = new NpgsqlCommand(sql, conn);
        await using var r = await cmd.ExecuteReaderAsync();
        while (await r.ReadAsync())
        {
            var tbl = r.GetString(0).ToLowerInvariant();
            var col = r.GetString(1).ToLowerInvariant();
            var dt = r.GetString(2);
            if (!result.ContainsKey(tbl))
                result[tbl] = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            result[tbl][col] = dt;
        }
        return result;
    }

    private static async Task<HashSet<string>> GetIndexesAsync(string connStr)
    {
        var result = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        await using var conn = new NpgsqlConnection(connStr);
        await conn.OpenAsync();
        var sql = @"
            SELECT indexname FROM pg_indexes
            WHERE schemaname = 'public';";
        await using var cmd = new NpgsqlCommand(sql, conn);
        await using var r = await cmd.ExecuteReaderAsync();
        while (await r.ReadAsync())
            result.Add(r.GetString(0).ToLowerInvariant());
        return result;
    }

    private static async Task<HashSet<string>> GetCheckConstraintsAsync(string connStr)
    {
        var result = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        await using var conn = new NpgsqlConnection(connStr);
        await conn.OpenAsync();
        var sql = @"
            SELECT conname FROM pg_constraint
            WHERE contype = 'c' AND connamespace = 'public'::regnamespace;";
        await using var cmd = new NpgsqlCommand(sql, conn);
        await using var r = await cmd.ExecuteReaderAsync();
        while (await r.ReadAsync())
            result.Add(r.GetString(0).ToLowerInvariant());
        return result;
    }
}
