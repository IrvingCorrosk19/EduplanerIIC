# 🚨 SOLUCIÓN: Logos que Desaparecen en Render

## ❓ **¿QUÉ ESTÁ PASANDO?**

Cuando subes un logo, se guarda en la carpeta `wwwroot/uploads/` del servidor. Sin embargo, **Render usa un sistema de archivos efímero**, lo que significa que:

❌ **Cada vez que el servidor se reinicia, los archivos desaparecen**  
❌ **Cada vez que haces un deploy, se pierden**  
❌ **No hay persistencia garantizada**

**Esto es normal en servicios como Render, Heroku, Railway, etc.**

---

## ✅ **SOLUCIÓN: Cloudinary**

**Cloudinary** es un servicio de almacenamiento en la nube para imágenes.

### **Ventajas:**
- ✅ **Persistencia permanente:** Los archivos NUNCA se pierden
- ✅ **Gratis:** Plan gratuito con 25GB (suficiente para tu escuela)
- ✅ **CDN Global:** Carga rápida desde cualquier país
- ✅ **Fácil de usar:** Solo necesitas 3 credenciales

---

## 🚀 **IMPLEMENTACIÓN EN 5 PASOS**

### **PASO 1: Instalar el paquete**
```powershell
cd C:\Proyectos\Proyectos\EduPlanner\EduPlanner\SchoolManager
dotnet add package CloudinaryDotNet
```

---

### **PASO 2: Crear cuenta en Cloudinary (2 minutos)**

1. **Ir a:** https://cloudinary.com/users/register/free
2. **Registrarse** con tu email
3. **Ir al Dashboard:** https://cloudinary.com/console
4. **Copiar estas 3 credenciales:**
   - Cloud Name: `dxyz123abc` (ejemplo)
   - API Key: `123456789012345` (ejemplo)
   - API Secret: `AbCdEfGhIjKlMnOpQrStUvWxYz` (ejemplo)

---

### **PASO 3: Configurar credenciales**

#### En `appsettings.json` (ya lo hice por ti):
```json
"Cloudinary": {
  "CloudName": "TU_CLOUD_NAME_AQUI",
  "ApiKey": "TU_API_KEY_AQUI",
  "ApiSecret": "TU_API_SECRET_AQUI"
}
```

**🔴 REEMPLAZA** con tus credenciales reales de Cloudinary.

---

### **PASO 4: Registrar el servicio en `Program.cs`**

Abre `Program.cs` y agrega esta línea **ANTES de `var app = builder.Build();`**:

```csharp
// Cloudinary para persistencia de archivos
builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();
```

**Ejemplo completo:**
```csharp
// ... otros servicios ...
builder.Services.AddScoped<IStudentReportService, StudentReportService>();

// ✅ AGREGAR ESTA LÍNEA:
builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();

var app = builder.Build();
```

---

### **PASO 5: Modificar SuperAdminService**

Abre `Services/Implementations/SuperAdminService.cs`:

#### 5.1 Agregar inyección de dependencia (línea ~35):

**BUSCAR:**
```csharp
public SuperAdminService(SchoolDbContext context, ILogger<SuperAdminService> logger)
{
    _context = context;
    _logger = logger;
}
```

**REEMPLAZAR POR:**
```csharp
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

#### 5.2 Modificar método SaveLogoAsync (línea ~538):

**BUSCAR:**
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

**REEMPLAZAR POR:**
```csharp
public async Task<string?> SaveLogoAsync(IFormFile? logoFile, string uploadsPath = "")
{
    if (logoFile == null || logoFile.Length == 0)
        return null;

    try
    {
        // Usar Cloudinary para persistencia en Render
        var logoUrl = await _cloudinaryService.UploadImageAsync(logoFile, "schools/logos");
        
        if (!string.IsNullOrEmpty(logoUrl))
        {
            Console.WriteLine($"✅ [SuperAdminService] Logo guardado en Cloudinary: {logoUrl}");
            return logoUrl; // URL completa: https://res.cloudinary.com/.../logo.png
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

---

### **PASO 6: Actualizar la vista del logo**

Busca donde se muestre el logo (probablemente en `Views/SuperAdmin/` o `Views/Shared/_Layout.cshtml`):

**BUSCAR:**
```cshtml
<img src="/File/GetSchoolLogo?logoUrl=@Model.LogoUrl" alt="Logo" />
```

**REEMPLAZAR POR:**
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
        <!-- URL local antigua (compatibilidad) -->
        <img src="/File/GetSchoolLogo?logoUrl=@Model.LogoUrl" alt="Logo" class="img-fluid" />
    }
}
```

---

## ⚙️ **CONFIGURACIÓN EN RENDER (Seguridad)**

### **IMPORTANTE:** Por seguridad, usar variables de entorno en producción

1. **Ir a Render Dashboard:** https://dashboard.render.com
2. **Seleccionar tu servicio**
3. **Settings → Environment**
4. **Agregar estas variables:**
   ```
   CLOUDINARY__CLOUDNAME = tu_cloud_name
   CLOUDINARY__APIKEY = tu_api_key
   CLOUDINARY__APISECRET = tu_api_secret
   ```
   *(Nota: usar doble guión bajo `__` para secciones anidadas)*

5. **Save Changes**

---

## 🧪 **PROBAR**

### En local:
```bash
dotnet build
dotnet run
```

1. Subir un logo de prueba
2. Verificar que aparece
3. Reiniciar la aplicación
4. Verificar que el logo **sigue ahí** ✅

### En Render:
1. Hacer commit y push:
   ```bash
   git add .
   git commit -m "Implementar Cloudinary para persistencia de logos"
   git push origin main
   ```

2. Render desplegará automáticamente

3. Subir un logo de prueba

4. **Reiniciar manualmente** el servicio en Render

5. Verificar que el logo **NO desaparece** ✅

---

## 📊 **VERIFICAR QUE FUNCIONA**

### Ver archivos en Cloudinary:
1. Ir a: https://cloudinary.com/console/media_library
2. Carpeta: `schools/logos`
3. Verás los logos subidos

### URL de ejemplo:
```
https://res.cloudinary.com/dxyz123abc/image/upload/v1697654321/schools/logos/abc123_logo.png
```

---

## ✅ **CHECKLIST**

- [ ] Instalar `CloudinaryDotNet`
- [ ] Crear cuenta en Cloudinary (gratis)
- [ ] Copiar credenciales (Cloud Name, API Key, API Secret)
- [ ] Configurar `appsettings.json`
- [ ] Registrar servicio en `Program.cs`
- [ ] Modificar `SuperAdminService.cs` (constructor y SaveLogoAsync)
- [ ] Actualizar vista del logo
- [ ] Configurar variables de entorno en Render
- [ ] Probar en local
- [ ] Desplegar y probar en Render

---

## 🐛 **SOLUCIÓN DE PROBLEMAS**

### Error: "Cloudinary no configurado"
✅ Verifica que las credenciales estén en `appsettings.json`

### Error: "Could not load type CloudinaryService"
✅ Verifica que instalaste el paquete: `dotnet add package CloudinaryDotNet`

### Error: "401 Unauthorized"
✅ Verifica que ApiKey y ApiSecret sean correctos (cópialos de nuevo del dashboard)

### El logo no se ve después de subir
✅ Abre las herramientas de desarrollador del navegador (F12)
✅ Verifica la URL de la imagen (debe empezar con `https://res.cloudinary.com/`)

---

## 💰 **PLAN GRATUITO DE CLOUDINARY**

| Recurso | Límite Gratis |
|---------|---------------|
| Almacenamiento | **25 GB** |
| Ancho de banda | **25 GB/mes** |
| Transformaciones | **25,000/mes** |
| Archivos | **Ilimitados** |

**¿Es suficiente?** Sí, para una escuela con 500 alumnos es más que suficiente.

---

## 📚 **RECURSOS**

- 📖 **Guía completa:** Ver `GUIA_CLOUDINARY.md`
- 🌐 **Cloudinary Dashboard:** https://cloudinary.com/console
- 📦 **Documentación:** https://cloudinary.com/documentation

---

**¿Necesitas ayuda con algún paso?** ¡Pregúntame! 🚀

