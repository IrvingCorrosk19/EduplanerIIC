# 🔧 CONFIGURACIÓN DE ENTORNOS - LOCAL vs RENDER

## 📍 ESTADO ACTUAL: **PRODUCCIÓN RENDER** ✅

El sistema está configurado para conectarse a la base de datos **RENDER (producción)**.

---

## ☁️ CONFIGURACIÓN ACTUAL (RENDER - PRODUCCIÓN)

### **Base de Datos:**
- **Host:** dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com
- **Database:** schoolmanagement_xqks
- **Username:** admin
- **Password:** 2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
- **Port:** 5432
- **SSL:** Require (obligatorio)

### **Archivos Configurados:**
1. ✅ `appsettings.json` → Render
2. ✅ `appsettings.Development.json` → Render
3. ✅ `Models/SchoolDbContext.cs` → Render

---

## 🔄 CÓMO CAMBIAR DE ENTORNO

### **📍 Para cambiar a RENDER (Producción):**

#### **1. Editar `appsettings.json`:**
```json
"ConnectionStrings": {
  // Conexión LOCAL (desarrollo) - Comentada
  //"DefaultConnection": "Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$",
  
  // Conexión RENDER (producción) - ACTIVA
  "DefaultConnection": "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true"
},
```

#### **2. Editar `appsettings.Development.json`:**
```json
"ConnectionStrings": {
  // Para desarrollo LOCAL - Comentada
  //"DefaultConnection": "Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$"
  
  // Para desarrollo con RENDER - ACTIVA
  "DefaultConnection": "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true"
}
```

#### **3. Editar `Models/SchoolDbContext.cs`:**
```csharp
// Conexión LOCAL (desarrollo) - Comentada
//=> optionsBuilder.UseNpgsql("Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$");

// Conexión RENDER (producción) - ACTIVA
=> optionsBuilder.UseNpgsql("Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true");
```

---

### **🏠 Para cambiar a LOCAL (Desarrollo):**

#### **1. Editar `appsettings.json`:**
```json
"ConnectionStrings": {
  // Conexión LOCAL (desarrollo) - ACTIVA
  "DefaultConnection": "Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$",
  
  // Conexión RENDER (producción) - Comentada
  //"DefaultConnection": "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true"
},
```

#### **2. Editar `appsettings.Development.json`:**
```json
"ConnectionStrings": {
  // Para desarrollo LOCAL - ACTIVA
  "DefaultConnection": "Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$"
  
  // Para desarrollo con RENDER - Comentada
  //"DefaultConnection": "Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true"
}
```

#### **3. Editar `Models/SchoolDbContext.cs`:**
```csharp
// Conexión LOCAL (desarrollo) - ACTIVA
=> optionsBuilder.UseNpgsql("Host=localhost;Database=schoolmanagement;Username=postgres;Password=Panama2020$");

// Conexión RENDER (producción) - Comentada
//=> optionsBuilder.UseNpgsql("Host=dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com;Database=schoolmanagement_xqks;Username=admin;Password=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk;Port=5432;SSL Mode=Require;Trust Server Certificate=true");
```

---

## 🛠️ REQUISITOS PARA DESARROLLO LOCAL

### **1. PostgreSQL Instalado:**
```bash
# Verificar instalación
psql --version

# Debería mostrar: PostgreSQL 18.0 o superior
```

### **2. Base de Datos Creada:**
```sql
-- Conectarse a PostgreSQL
psql -U postgres

-- Crear base de datos
CREATE DATABASE schoolmanagement;

-- Salir
\q
```

### **3. Restaurar Datos (Opcional):**

Si quieres tener los mismos datos que Render:

```bash
# Opción A: Restaurar desde backup
psql -U postgres -d schoolmanagement -f SchoolManagement.sql

# Opción B: Empezar desde cero (migraciones)
dotnet ef database update
```

---

## 🚀 VERIFICAR CONEXIÓN

### **Método 1: psql**
```bash
psql -h localhost -U postgres -d schoolmanagement
```

### **Método 2: Ejecutar aplicación**
```bash
dotnet run
```

Si todo está bien, verás:
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
```

---

## 📊 COMPARACIÓN DE ENTORNOS

| Aspecto | LOCAL | RENDER |
|---------|-------|--------|
| **Host** | localhost | dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com |
| **Database** | schoolmanagement | schoolmanagement_xqks |
| **User** | postgres | admin |
| **Password** | Panama2020$ | 2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk |
| **Port** | 5432 | 5432 |
| **SSL** | No | Require |
| **Backup** | Manual | Automático (diario) |
| **Latencia** | ~1ms | ~100-200ms |
| **Datos** | Desarrollo/Testing | Producción |

---

## ⚠️ ADVERTENCIAS

### **🔴 NUNCA hacer en LOCAL:**
- ❌ Eliminar tablas sin backup
- ❌ Ejecutar scripts destructivos sin probar
- ❌ Modificar directamente la estructura sin migraciones

### **🔴 NUNCA hacer en RENDER:**
- ❌ Ejecutar scripts no probados
- ❌ Hacer cambios directos sin backup
- ❌ Usar comandos DROP sin confirmación
- ❌ Exponer las credenciales en repositorios públicos

---

## 🔄 SINCRONIZACIÓN DE DATOS

### **De RENDER a LOCAL:**
```bash
# 1. Descargar dump desde Render
pg_dump -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com \
        -U admin -d schoolmanagement_xqks > render_backup.sql

# 2. Restaurar en local
psql -U postgres -d schoolmanagement < render_backup.sql
```

### **De LOCAL a RENDER:**
```bash
# 1. Hacer dump local
pg_dump -U postgres -d schoolmanagement > local_backup.sql

# 2. Restaurar en Render
psql -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com \
     -U admin -d schoolmanagement_xqks < local_backup.sql
```

---

## 📝 MEJORES PRÁCTICAS

### **✅ DESARROLLO:**
1. Siempre trabajar en LOCAL
2. Probar cambios exhaustivamente
3. Crear migraciones para cambios de BD
4. Hacer commits frecuentes
5. Documentar cambios importantes

### **✅ DESPLIEGUE:**
1. Probar en LOCAL primero
2. Hacer backup de RENDER antes de cambios
3. Aplicar migraciones en RENDER
4. Verificar funcionalidad
5. Monitorear logs

### **✅ BASE DE DATOS:**
1. Usar migraciones EF Core para cambios
2. Nunca modificar BD directamente en producción
3. Hacer backups antes de cambios grandes
4. Mantener LOCAL y RENDER sincronizados (estructura)
5. Usar datos de prueba en LOCAL

---

## 🛡️ SEGURIDAD

### **Credentials Management:**

Para mayor seguridad, considera usar variables de entorno:

```bash
# En LOCAL (PowerShell)
$env:DB_HOST="localhost"
$env:DB_NAME="schoolmanagement"
$env:DB_USER="postgres"
$env:DB_PASS="Panama2020$"

# En código (Program.cs)
var connectionString = $"Host={Environment.GetEnvironmentVariable("DB_HOST")};Database={Environment.GetEnvironmentVariable("DB_NAME")};Username={Environment.GetEnvironmentVariable("DB_USER")};Password={Environment.GetEnvironmentVariable("DB_PASS")}";
```

---

## 📞 SOLUCIÓN DE PROBLEMAS

### **Problema: No puede conectar a LOCAL**
```bash
# Verificar que PostgreSQL está corriendo
# Windows:
Get-Service postgresql*

# Si no está corriendo:
Start-Service postgresql-x64-18
```

### **Problema: Error de autenticación**
```bash
# Verificar pg_hba.conf
# Ubicación típica: C:\Program Files\PostgreSQL\18\data\pg_hba.conf
# Cambiar método de autenticación a 'md5' o 'trust'
```

### **Problema: Base de datos no existe**
```sql
-- Crear base de datos
CREATE DATABASE schoolmanagement;
```

### **Problema: Migraciones no aplican**
```bash
# Limpiar y recrear
dotnet ef database drop
dotnet ef database update
```

---

## 🎯 CHECKLIST DE CAMBIO DE ENTORNO

### **Antes de cambiar a RENDER:**
- [ ] Hacer commit de cambios locales
- [ ] Probar que todo funciona en LOCAL
- [ ] Hacer backup de RENDER
- [ ] Actualizar 3 archivos de configuración
- [ ] Compilar sin errores
- [ ] Verificar conexión

### **Antes de cambiar a LOCAL:**
- [ ] Hacer backup de cambios en RENDER (si hay)
- [ ] Actualizar 3 archivos de configuración
- [ ] Verificar que PostgreSQL local está corriendo
- [ ] Verificar que la BD existe
- [ ] Compilar sin errores

---

## 📚 COMANDOS ÚTILES

### **PostgreSQL:**
```bash
# Listar bases de datos
psql -U postgres -l

# Conectarse a BD
psql -U postgres -d schoolmanagement

# Listar tablas
\dt

# Ver estructura de tabla
\d+ users

# Salir
\q
```

### **.NET:**
```bash
# Compilar
dotnet build

# Ejecutar
dotnet run

# Crear migración
dotnet ef migrations add NombreMigracion

# Aplicar migraciones
dotnet ef database update

# Revertir última migración
dotnet ef migrations remove
```

---

**Última actualización:** 11 de Octubre de 2025  
**Estado:** Configurado para PRODUCCIÓN RENDER ☁️✅

