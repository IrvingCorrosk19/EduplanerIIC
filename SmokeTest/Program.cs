using Npgsql;

var connStr = "Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$";
await using var conn = new NpgsqlConnection(connStr);
await conn.OpenAsync();

async Task<bool> TableExists(NpgsqlConnection c, string table)
{
    await using var cmd = new NpgsqlCommand($"SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='{table}' LIMIT 1", c);
    await using var r = await cmd.ExecuteReaderAsync();
    return r.HasRows;
}

Console.WriteLine("=== TEACHERS ===");
await using (var cmd = new NpgsqlCommand(@"
    SELECT u.id, u.email, u.role, u.school_id, u.name, u.last_name
    FROM users u WHERE u.role IN ('teacher','docente','Teacher') AND u.status = 'active' LIMIT 5", conn))
await using (var r = await cmd.ExecuteReaderAsync())
    while (await r.ReadAsync())
        Console.WriteLine($"  ID={r[0]} EMAIL={r[1]} ROLE={r[2]} SCHOOL={r[3]} NAME={r[4]} {r[5]}");

Console.WriteLine("=== ADMINS ===");
await using (var cmd2 = new NpgsqlCommand(@"
    SELECT u.id, u.email, u.role, u.school_id, u.name
    FROM users u WHERE u.role IN ('admin','superadmin','director') AND u.status = 'active' LIMIT 5", conn))
await using (var r2 = await cmd2.ExecuteReaderAsync())
    while (await r2.ReadAsync())
        Console.WriteLine($"  ID={r2[0]} EMAIL={r2[1]} ROLE={r2[2]} SCHOOL={r2[3]} NAME={r2[4]}");

Console.WriteLine("=== ACADEMIC YEARS ===");
if (await TableExists(conn, "academic_years"))
{
    await using var cmd3 = new NpgsqlCommand("SELECT id, school_id, name, is_active FROM academic_years LIMIT 5", conn);
    await using var r3 = await cmd3.ExecuteReaderAsync();
    var found = false;
    while (await r3.ReadAsync()) { Console.WriteLine($"  ID={r3[0]} SCHOOL={r3[1]} NAME={r3[2]} ACTIVE={r3[3]}"); found = true; }
    if (!found) Console.WriteLine("  (empty)");
}
else Console.WriteLine("  TABLE NOT EXISTS");

Console.WriteLine("=== TIME SLOTS ===");
if (await TableExists(conn, "time_slots"))
{
    await using var cmd4 = new NpgsqlCommand("SELECT id, school_id, name FROM time_slots WHERE is_active = true LIMIT 5", conn);
    await using var r4 = await cmd4.ExecuteReaderAsync();
    var found = false;
    while (await r4.ReadAsync()) { Console.WriteLine($"  ID={r4[0]} SCHOOL={r4[1]} NAME={r4[2]}"); found = true; }
    if (!found) Console.WriteLine("  (empty)");
}
else Console.WriteLine("  TABLE NOT EXISTS");

Console.WriteLine("=== TEACHER ASSIGNMENTS ===");
await using (var cmd5 = new NpgsqlCommand(@"
    SELECT ta.id, ta.teacher_id, u.email, s.name as subject, g.name as grp, sa.group_id
    FROM teacher_assignments ta
    JOIN users u ON u.id = ta.teacher_id
    JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
    LEFT JOIN subjects s ON s.id = sa.subject_id
    LEFT JOIN groups g ON g.id = sa.group_id
    LIMIT 10", conn))
await using (var r5 = await cmd5.ExecuteReaderAsync())
    while (await r5.ReadAsync())
        Console.WriteLine($"  TA={r5[0]} TEACHER={r5[1]} EMAIL={r5[2]} SUBJ={r5[3]} GRP={r5[4]} GRP_ID={r5[5]}");

Console.WriteLine("=== SCHEDULE ENTRIES ===");
if (await TableExists(conn, "schedule_entries"))
{
    await using var cmd6 = new NpgsqlCommand("SELECT count(*) FROM schedule_entries", conn);
    Console.WriteLine($"  Count={await cmd6.ExecuteScalarAsync()}");
}
else Console.WriteLine("  TABLE NOT EXISTS");
