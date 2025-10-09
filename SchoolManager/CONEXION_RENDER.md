# Configuración de Conexión a Render PostgreSQL

## 🗄️ Base de Datos en Render

**Database Name:** `schoolmanagement_xqks`  
**Username:** `admin`  
**Password:** `2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk`

---

## 🔗 Cadenas de Conexión

### **Internal Database URL** (Solo desde servicios dentro de Render)
```
postgresql://admin:2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk@dpg-d3jfdcb3fgac73cblbag-a/schoolmanagement_xqks
```

### **External Database URL** (Desde cualquier lugar)
```
postgresql://admin:2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk@dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com/schoolmanagement_xqks
```

---

## 🔧 Configuración para .NET (Npgsql)

### Para appsettings.json
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true"
  }
}
```

### Para DbContext (OnConfiguring)
```csharp
optionsBuilder.UseNpgsql("Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true");
```

---

## 🖥️ Conexión con psql (línea de comandos)

```bash
# Windows PowerShell
$env:PGPASSWORD="2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk"
psql -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks
```

```bash
# Linux/Mac
PGPASSWORD=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk psql -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks
```

---

## 🔐 Configuración para clientes GUI

### **pgAdmin / DBeaver / TablePlus**
- **Host:** `dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com`
- **Port:** `5432`
- **Database:** `schoolmanagement_xqks`
- **Username:** `admin`
- **Password:** `2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk`
- **SSL Mode:** `Require` (o `Verify-Full`)
- **Trust Server Certificate:** `Yes` / `true`

---

## ✅ Estado Actual de la Base de Datos

### **Tablas creadas:** 27
- ✅ schools (1 registro)
- ✅ users (2 registros: admin y superadmin)
- ✅ email_configurations (1 registro)
- ✅ __EFMigrationsHistory (25 migraciones)
- ✅ Todas las tablas del sistema (vacías, listas para usar)

### **Usuarios activos:**
1. **Superadmin:** admin@correo.com
2. **Admin:** Quenna Lopez (quenna.lopez@qlservice.net)

---

## 🔄 Cambiar entre LOCAL y RENDER

### Para usar LOCAL (localhost):
Descomenta en `appsettings.json` y `SchoolDbContext.cs`:
```
Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$
```

### Para usar RENDER (producción):
Usa la conexión actual (ya configurada):
```
Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;...
```

---

## 📝 Notas Importantes

⚠️ **SEGURIDAD:** No subas este archivo a repositorios públicos (está en .gitignore recomendado)

✅ La base de datos está en **Oregon, USA** (región oregon-postgres)

✅ SSL/TLS está **habilitado y requerido**

✅ Todas las tablas y datos fueron migrados exitosamente desde la base de datos local

---

**Última actualización:** 8 de octubre de 2025

