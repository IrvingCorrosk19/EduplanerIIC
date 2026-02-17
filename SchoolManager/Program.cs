using Microsoft.EntityFrameworkCore;
using SchoolManager.Mappings;
using SchoolManager.Models;
using AutoMapper;
using SchoolManager.Services.Implementations;
using SchoolManager.Services.Interfaces;
using SchoolManager.Application.Interfaces;
using SchoolManager.Infrastructure.Services;
using SchoolManager.Services;
using SchoolManager.Interfaces;
using Microsoft.AspNetCore.Authentication.Cookies;
using BCrypt.Net;
using SchoolManager.Middleware;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Globalization;

var builder = WebApplication.CreateBuilder(args);

// Aplicar columna schools.is_active sin arrancar la app (evita usar Schools antes de que exista la columna)
if (args.Length > 0 && args[0] == "--apply-school-is-active")
{
    var connStr = builder.Configuration.GetConnectionString("DefaultConnection");
    if (string.IsNullOrEmpty(connStr)) { Console.WriteLine("No hay ConnectionStrings:DefaultConnection."); Environment.Exit(1); return; }
    var opts = new DbContextOptionsBuilder<SchoolDbContext>().UseNpgsql(connStr).Options;
    using var ctx = new SchoolDbContext(opts);
    await SchoolManager.Scripts.ApplySchoolIsActive.RunAsync(ctx);
    Console.WriteLine("✅ Columna schools.is_active aplicada y migración registrada. Saliendo...");
    return;
}

// Cultura oficial del sistema (estándar corporativo de fechas)
var culture = new CultureInfo("es-PA");
CultureInfo.DefaultThreadCurrentCulture = culture;
CultureInfo.DefaultThreadCurrentUICulture = culture;

// Add services to the container.
builder.Services.AddControllersWithViews();

// Configurar Antiforgery para aceptar el token desde header (usado por fetch en Schedule y otros módulos AJAX)
builder.Services.AddAntiforgery(options =>
{
    options.HeaderName = "RequestVerificationToken";
});

// Conexión a la base de datos PostgreSQL
builder.Services.AddDbContext<SchoolDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"));
    
    // Configurar Entity Framework para manejar DateTime automáticamente
    options.ConfigureWarnings(warnings => warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.CoreEventId.RowLimitingOperationWithoutOrderByWarning));
});

// Configurar MVC para usar los convertidores JSON personalizados
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
        options.JsonSerializerOptions.Converters.Add(new DateTimeJsonConverter());
        options.JsonSerializerOptions.Converters.Add(new NullableDateTimeJsonConverter());
    })
    .AddMvcOptions(options =>
    {
        // Agregar filtro global para conversión de DateTime
        options.Filters.Add<SchoolManager.Attributes.DateTimeConversionAttribute>();
    });

// Registrando todos los servicios con inyección de dependencias
builder.Services.AddScoped<ISchoolService, SchoolService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IStudentService, StudentService>();
builder.Services.AddScoped<ISubjectService, SubjectService>();
builder.Services.AddScoped<IGroupService, GroupService>();
builder.Services.AddScoped<ITeacherAssignmentService, TeacherAssignmentService>();
builder.Services.AddScoped<ITrimesterService, TrimesterService>();
builder.Services.AddScoped<IActivityTypeService, ActivityTypeService>();
builder.Services.AddScoped<ITeacherGroupService, TeacherGroupService>();
builder.Services.AddScoped<IActivityService, ActivityService>();
builder.Services.AddScoped<IStudentActivityScoreService, StudentActivityScoreService>();

builder.Services.AddSingleton<IFileStorage, LocalFileStorage>(); // o tu propio servicio

builder.Services.AddScoped<IAttendanceService, AttendanceService>();
builder.Services.AddScoped<IDisciplineReportService, DisciplineReportService>();
builder.Services.AddScoped<IOrientationReportService, OrientationReportService>();
builder.Services.AddScoped<ISecuritySettingService, SecuritySettingService>();
builder.Services.AddScoped<IAuditLogService, AuditLogService>();

builder.Services.AddAutoMapper(typeof(AutoMapperProfile).Assembly);
builder.Services.AddScoped<IStudentReportService, StudentReportService>();
builder.Services.AddScoped<IGradeLevelService, GradeLevelService>();
builder.Services.AddScoped<IAcademicAssignmentService, AcademicAssignmentService>();
builder.Services.AddScoped<IStudentAssignmentService, StudentAssignmentService>();
builder.Services.AddScoped<IAreaService, AreaService>();
builder.Services.AddScoped<ISpecialtyService, SpecialtyService>();
builder.Services.AddScoped<IShiftService, ShiftService>();
builder.Services.AddScoped<ISubjectAssignmentService, SubjectAssignmentService>();
builder.Services.AddScoped<IDirectorService, DirectorService>();
builder.Services.AddScoped<ISuperAdminService, SuperAdminService>();
builder.Services.AddScoped<IDateTimeHomologationService, DateTimeHomologationService>();
builder.Services.AddScoped<IEmailConfigurationService, EmailConfigurationService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<ICounselorAssignmentService, CounselorAssignmentService>();
builder.Services.AddScoped<IStudentProfileService, StudentProfileService>();
builder.Services.AddScoped<IMessagingService, MessagingService>();
builder.Services.AddScoped<IAprobadosReprobadosService, AprobadosReprobadosService>();
builder.Services.AddScoped<IPrematriculationPeriodService, PrematriculationPeriodService>();
builder.Services.AddScoped<IPrematriculationService, PrematriculationService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IPaymentConceptService, PaymentConceptService>();
builder.Services.AddScoped<IAcademicYearService, AcademicYearService>();
builder.Services.AddScoped<IScheduleService, ScheduleService>();
builder.Services.AddScoped<IScheduleConfigurationService, ScheduleConfigurationService>();
builder.Services.AddScoped<IStudentIdCardService, StudentIdCardService>();
builder.Services.AddScoped<IStudentIdCardPdfService, StudentIdCardPdfService>();

// Identidad visual del usuario (foto): almacenamiento desacoplado + servicio de aplicación
builder.Services.AddScoped<IFileStorageService, LocalFileStorageService>();
builder.Services.AddScoped<IUserPhotoService, UserPhotoService>();

// HttpClient para descargar imágenes
builder.Services.AddHttpClient();

// Cloudinary para almacenamiento persistente de archivos en la nube
builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();

// Agregar servicios de autenticación
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Auth/Login";
        options.LogoutPath = "/Auth/Logout";
        options.AccessDeniedPath = "/Auth/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.FromHours(24);
        options.SlidingExpiration = true;
    });

// Agregar configuración de autorización
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("SuperAdmin", policy => policy.RequireRole("SuperAdmin"));
    options.AddPolicy("Admin", policy => policy.RequireRole("Admin"));
    options.AddPolicy("Teacher", policy => policy.RequireRole("Teacher"));
    options.AddPolicy("Student", policy => policy.RequireRole("Student"));
    options.AddPolicy("Parent", policy => policy.RequireRole("Parent", "Acudiente"));
    options.AddPolicy("Accounting", policy => policy.RequireRole("Contabilidad", "Admin", "SuperAdmin"));
});

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IMenuService, MenuService>();
builder.Services.AddScoped<ITimeZoneService, TimeZoneService>();

var app = builder.Build();

// Asegurar que existan las tablas del módulo de carnets (por si la migración no se aplicó)
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<SchoolDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    await SchoolManager.Scripts.EnsureIdCardTables.EnsureAsync(db);
    await SchoolManager.Scripts.EnsureUsersRoleCheck.EnsureAsync(db);
    await SchoolManager.Scripts.EnsureScheduleTables.EnsureAsync(db);
    await SchoolManager.Scripts.EnsureSchoolScheduleConfigurationTable.EnsureAsync(db);
    await SchoolManager.Scripts.VerifyAcademicYearsInDb.RunAsync(db, logger);

    // Garantizar que cada escuela tenga al menos un año académico (evitar mensaje "No hay años académicos configurados")
    var academicYearService = scope.ServiceProvider.GetRequiredService<IAcademicYearService>();
    var schools = await db.Schools.Select(s => s.Id).ToListAsync();
    foreach (var schoolId in schools)
    {
        try
        {
            await academicYearService.EnsureDefaultAcademicYearForSchoolAsync(schoolId);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "No se pudo asegurar año académico para la escuela {SchoolId}.", schoolId);
        }
    }

    // Garantizar que cada escuela tenga bloques horarios por defecto (8 bloques de 35 min desde 07:00) si no tiene ninguno
    try
    {
        foreach (var schoolId in schools)
        {
            await SchoolManager.Scripts.EnsureDefaultTimeSlots.EnsureForSchoolAsync(db, schoolId);
        }
    }
    catch (Exception ex)
    {
        logger.LogWarning(ex, "No se pudo asegurar bloques horarios por defecto (tabla time_slots puede no existir aún).");
    }
}

// Script temporal para aplicar cambios a la base de datos
// Ejecutar con: 
//   --apply-db-changes: Aplica cambios locales
//   --apply-school-is-active: Añade columna schools.is_active (Soft Delete) y registra migración
//   --apply-academic-year: Aplica cambios de año académico locales
//   --test-render: Prueba conexión a Render
//   --apply-render-all: Aplica todas las migraciones a Render
//   --apply-render-prematriculation: Aplica solo prematriculación a Render
//   --apply-render-academic-year: Aplica solo año académico a Render
if (args.Length > 0)
{
    if (args[0] == "--test-render")
    {
        await SchoolManager.Scripts.TestRenderConnection.RunAsync();
        return;
    }
    else if (args[0] == "--apply-render-all")
    {
        await SchoolManager.Scripts.ApplyRenderMigrations.ApplyAllMigrationsAsync();
        return;
    }
    else if (args[0] == "--apply-render-prematriculation")
    {
        await SchoolManager.Scripts.ApplyRenderMigrations.ApplyPrematriculationOnlyAsync();
        return;
    }
    else if (args[0] == "--apply-render-academic-year")
    {
        await SchoolManager.Scripts.ApplyRenderMigrations.ApplyAcademicYearOnlyAsync();
        return;
    }
    else if (args[0] == "--compare-db-schemas")
    {
        await SchoolManager.Scripts.CompareDbSchemas.RunAsync();
        return;
    }
    
    // Comandos locales (usando la conexión del appsettings.json)
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<SchoolDbContext>();
    
    if (args[0] == "--apply-db-changes")
    {
        await SchoolManager.Scripts.ApplyDatabaseChanges.ApplyPrematriculationChangesAsync(context);
        Console.WriteLine("✅ Cambios de prematriculación aplicados. Saliendo...");
        return;
    }
    else if (args[0] == "--apply-academic-year")
    {
        await SchoolManager.Scripts.ApplyAcademicYearChanges.ApplyAsync(context);
        Console.WriteLine("✅ Cambios de año académico aplicados. Saliendo...");
        return;
    }
    else if (args[0] == "--check-users")
    {
        await SchoolManager.Scripts.CheckUsers.RunAsync(context);
        return;
    }
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}

app.UseStaticFiles();

app.UseRouting();

// Agregar middleware global para DateTime
app.UseMiddleware<DateTimeMiddleware>();

app.UseAuthentication();
app.UseAuthorization();

// Usar el método de extensión para el middleware
// app.UseSessionValidation();

app.MapControllers(); // Rutas por atributos (ej. StudentIdCard/ui)
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Auth}/{action=Login}/{id?}");

app.Run();
