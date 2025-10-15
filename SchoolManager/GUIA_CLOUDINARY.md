# 🌩️ GUÍA: Configuración de Cloudinary para Persistencia de Archivos en Render

## 📋 **PROBLEMA**

**Render** usa un sistema de archivos **efímero**:
- ❌ Los archivos guardados en `wwwroot/uploads/` se pierden al reiniciar
- ❌ Se pierden con cada deploy
- ❌ No hay persistencia garantizada

**SOLUCIÓN:** Usar **Cloudinary** (almacenamiento en la nube) para guardar imágenes de forma permanente.

---

## 🚀 **PASO 1: Crear Cuenta en Cloudinary (GRATIS)**

### 1.1 Registro
1. Ir a: https://cloudinary.com/users/register/free
2. Crear cuenta gratuita
3. Verificar email

### 1.2 Obtener Credenciales
1. Ir al **Dashboard**: https://cloudinary.com/console
2. Copiar:
   - **Cloud Name**
   - **API Key**
   - **API Secret**

**Ejemplo de credenciales:**
```
Cloud name: dxyz123abc
API Key: 123456789012345
API Secret: AbCdEfGhIjKlMnOpQrStUvWxYz
```

---

## 📦 **PASO 2: Instalar Paquete NuGet**

### Opción A: Visual Studio
1. **Clic derecho** en el proyecto `SchoolManager`
2. **Manage NuGet Packages**
3. Buscar: `CloudinaryDotNet`
4. Instalar la última versión

### Opción B: Terminal/PowerShell
```bash
cd C:\Proyectos\Proyectos\EduPlanner\EduPlanner\SchoolManager
dotnet add package CloudinaryDotNet
```

---

## 🔧 **PASO 3: Configurar appsettings.json**

### 3.1 Abrir `appsettings.json`

### 3.2 Agregar sección de Cloudinary:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true"
  },
  "Cloudinary": {
    "CloudName": "TU_CLOUD_NAME_AQUI",
    "ApiKey": "TU_API_KEY_AQUI",
    "ApiSecret": "TU_API_SECRET_AQUI"
  },
  "AllowedHosts": "*"
}
```

### 3.3 Reemplazar con tus credenciales reales:
```json
"Cloudinary": {
  "CloudName": "dxyz123abc",
  "ApiKey": "123456789012345",
  "ApiSecret": "AbCdEfGhIjKlMnOpQrStUvWxYz"
}
```

---

## ⚙️ **PASO 4: Registrar Servicio en Program.cs**

### 4.1 Abrir `Program.cs`

### 4.2 Agregar registro del servicio:
```csharp
// Agregar ANTES de var app = builder.Build();

// Cloudinary para almacenamiento de archivos en producción
builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();
```

**Ubicación completa en Program.cs:**
```csharp
// ... otros servicios ...

builder.Services.AddScoped<ISubjectAssignmentService, SubjectAssignmentService>();
builder.Services.AddScoped<IStudentReportService, StudentReportService>();

// ✅ AGREGAR ESTA LÍNEA:
builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();

var app = builder.Build();
```

---

## 🛠️ **PASO 5: Modificar SuperAdminService**

### 5.1 Abrir `Services/Implementations/SuperAdminService.cs`

### 5.2 Agregar inyección de dependencia:

**ANTES (línea ~35):**
```csharp
public class SuperAdminService : ISuperAdminService
{
    private readonly SchoolDbContext _context;
    private readonly ILogger<SuperAdminService> _logger;

    public SuperAdminService(SchoolDbContext context, ILogger<SuperAdminService> logger)
    {
        _context = context;
        _logger = logger;
    }
```

**DESPUÉS:**
```csharp
public class SuperAdminService : ISuperAdminService
{
    private readonly SchoolDbContext _context;
    private readonly ILogger<SuperAdminService> _logger;
    private readonly ICloudinaryService _cloudinaryService;

    public SuperAdminService(
        SchoolDbContext context, 
        ILogger<SuperAdminService> logger,
        ICloudinaryService cloudinaryService)
    {
        _context = context;
        _logger = logger;
        _cloudinaryService = cloudinaryService;
    }
```

### 5.3 Modificar método `SaveLogoAsync`:

**ANTES (línea ~538):**
```csharp
public async Task<string?> SaveLogoAsync(IFormFile? logoFile, string uploadsPath)
{
    if (logoFile == null || logoFile.Length == 0)
        return null;

    try
    {
        var fileName = $"{Guid.NewGuid()}_{logoFile.FileName}";
        var filePath = Path.Combine(uploadsPath, "schools", fileName);

        Directory.CreateDirectory(Path.GetDirectoryName(filePath)!);

        using var stream = new FileStream(filePath, FileMode.Create);
        await logoFile.CopyToAsync(stream);

        Console.WriteLine($"📁 [SuperAdminService] Logo guardado: {fileName}");
        return fileName;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ [SuperAdminService] Error guardando logo: {ex.Message}");
        return null;
    }
}
```

**DESPUÉS:**
```csharp
public async Task<string?> SaveLogoAsync(IFormFile? logoFile, string uploadsPath = "")
{
    if (logoFile == null || logoFile.Length == 0)
        return null;

    try
    {
        // Usar Cloudinary en lugar del sistema de archivos local
        var logoUrl = await _cloudinaryService.UploadImageAsync(logoFile, "schools/logos");
        
        if (!string.IsNullOrEmpty(logoUrl))
        {
            Console.WriteLine($"✅ [SuperAdminService] Logo guardado en Cloudinary: {logoUrl}");
            return logoUrl; // Devuelve la URL completa de Cloudinary
        }

        Console.WriteLine($"❌ [SuperAdminService] Error: Cloudinary devolvió URL vacía");
        return null;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ [SuperAdminService] Error guardando logo: {ex.Message}");
        return null;
    }
}
```

### 5.4 Modificar método `GetLogoAsync`:

**ANTES (línea ~588):**
```csharp
public async Task<byte[]?> GetLogoAsync(string? logoUrl)
{
    if (string.IsNullOrEmpty(logoUrl))
        return null;

    try
    {
        var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
        var filePath = Path.Combine(uploadsPath, "schools", logoUrl);

        if (File.Exists(filePath))
        {
            return await File.ReadAllBytesAsync(filePath);
        }

        Console.WriteLine($"❌ [SuperAdminService] Logo no encontrado: {logoUrl}");
        return null;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ [SuperAdminService] Error leyendo logo: {ex.Message}");
        return null;
    }
}
```

**DESPUÉS:**
```csharp
public async Task<byte[]?> GetLogoAsync(string? logoUrl)
{
    // Ya no necesitamos este método porque Cloudinary devuelve URLs públicas
    // El navegador accede directamente a la imagen sin pasar por nuestro servidor
    
    // Si logoUrl es una URL de Cloudinary (https://res.cloudinary.com/...),
    // simplemente retorna null porque la vista debe usar la URL directamente
    
    return null;
}
```

---

## 🔄 **PASO 6: Actualizar Vistas**

### 6.1 Modificar vista de logos

**Buscar en las vistas donde se muestre el logo:**

**ANTES:**
```cshtml
@if (!string.IsNullOrEmpty(Model.LogoUrl))
{
    <img src="/File/GetSchoolLogo?logoUrl=@Model.LogoUrl" alt="Logo" class="img-fluid" />
}
```

**DESPUÉS:**
```cshtml
@if (!string.IsNullOrEmpty(Model.LogoUrl))
{
    @if (Model.LogoUrl.StartsWith("http"))
    {
        <!-- URL de Cloudinary - acceso directo -->
        <img src="@Model.LogoUrl" alt="Logo" class="img-fluid" />
    }
    else
    {
        <!-- URL local antigua (por compatibilidad) -->
        <img src="/File/GetSchoolLogo?logoUrl=@Model.LogoUrl" alt="Logo" class="img-fluid" />
    }
}
```

---

## 🚢 **PASO 7: Configurar Variables de Entorno en Render**

### ⚠️ **IMPORTANTE:** Por seguridad, NO subas las credenciales a GitHub

### 7.1 En Render Dashboard:
1. Ir a tu servicio en Render
2. **Settings** → **Environment**
3. Agregar variables:
   ```
   CLOUDINARY__CLOUDNAME=dxyz123abc
   CLOUDINARY__APIKEY=123456789012345
   CLOUDINARY__APISECRET=AbCdEfGhIjKlMnOpQrStUvWxYz
   ```
   *(Nota: Usar doble guión bajo `__` para secciones anidadas)*

### 7.2 En local (appsettings.Development.json):
```json
{
  "Cloudinary": {
    "CloudName": "tu_cloud_name_local",
    "ApiKey": "tu_api_key_local",
    "ApiSecret": "tu_api_secret_local"
  }
}
```

### 7.3 Modificar Program.cs para leer variables de entorno:
```csharp
// Configurar Cloudinary desde variables de entorno (producción) o appsettings (desarrollo)
builder.Configuration["Cloudinary:CloudName"] = Environment.GetEnvironmentVariable("CLOUDINARY__CLOUDNAME") 
    ?? builder.Configuration["Cloudinary:CloudName"];
builder.Configuration["Cloudinary:ApiKey"] = Environment.GetEnvironmentVariable("CLOUDINARY__APIKEY") 
    ?? builder.Configuration["Cloudinary:ApiKey"];
builder.Configuration["Cloudinary:ApiSecret"] = Environment.GetEnvironmentVariable("CLOUDINARY__APISECRET") 
    ?? builder.Configuration["Cloudinary:ApiSecret"];
```

---

## ✅ **PASO 8: Probar y Desplegar**

### 8.1 Probar en local:
```bash
dotnet build
dotnet run
```

### 8.2 Subir cambios a GitHub:
```bash
git add .
git commit -m "Implementar Cloudinary para persistencia de archivos"
git push origin main
```

### 8.3 Render detectará los cambios y desplegará automáticamente

### 8.4 Verificar en Render:
1. Subir un logo de prueba
2. Reiniciar la aplicación en Render
3. Verificar que el logo **NO desaparece** ✅

---

## 📊 **LÍMITES DEL PLAN GRATUITO**

| Recurso | Plan Gratuito |
|---------|---------------|
| **Almacenamiento** | 25 GB |
| **Ancho de banda** | 25 GB/mes |
| **Transformaciones** | 25,000/mes |
| **Archivos** | Ilimitados |

**¿Es suficiente?** Sí, para una escuela con ~500 alumnos y 50 profesores es más que suficiente.

---

## 🔍 **VERIFICAR QUE FUNCIONA**

### Ver archivos subidos:
1. Ir a Cloudinary Dashboard: https://cloudinary.com/console/media_library
2. Navegar a carpeta `schools/logos`
3. Deberías ver los logos subidos

### URL de ejemplo:
```
https://res.cloudinary.com/dxyz123abc/image/upload/v1697654321/schools/logos/abc123_logo.png
```

---

## 🐛 **SOLUCIÓN DE PROBLEMAS**

### Error: "Cloudinary no configurado"
✅ Verifica que las credenciales estén en `appsettings.json`

### Error: "401 Unauthorized"
✅ Verifica que ApiKey y ApiSecret sean correctos

### Imagen no se ve después de subir
✅ Verifica la URL en la base de datos (debe empezar con `https://res.cloudinary.com/`)

### Logo antiguo no aparece
✅ Mantener el método `GetLogoAsync` para compatibilidad con logos antiguos guardados localmente

---

## 🎯 **BENEFICIOS**

✅ **Persistencia:** Los archivos nunca se pierden  
✅ **CDN Global:** Carga rápida desde cualquier país  
✅ **Transformaciones:** Redimensionar imágenes automáticamente  
✅ **Backups:** Cloudinary hace backups automáticos  
✅ **Gratis:** Plan generoso para producción

---

## 📝 **CHECKLIST DE IMPLEMENTACIÓN**

- [ ] Crear cuenta en Cloudinary
- [ ] Instalar paquete `CloudinaryDotNet`
- [ ] Agregar credenciales en `appsettings.json`
- [ ] Crear archivos `ICloudinaryService.cs` y `CloudinaryService.cs`
- [ ] Registrar servicio en `Program.cs`
- [ ] Modificar `SuperAdminService.cs`
- [ ] Actualizar vistas de logos
- [ ] Configurar variables de entorno en Render
- [ ] Probar en local
- [ ] Desplegar a Render
- [ ] Verificar que funciona

---

**¿Necesitas ayuda con algún paso?** ¡Pregúntame!

