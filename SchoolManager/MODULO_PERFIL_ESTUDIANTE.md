# 👤 MÓDULO: Perfil de Estudiante

## 📋 RESUMEN

Nuevo módulo que permite a los **estudiantes** editar su información personal desde el sistema.

---

## ✅ ARCHIVOS CREADOS

### **1. ViewModel**
- `ViewModels/StudentProfileViewModel.cs` - Modelo de datos para el perfil

### **2. Servicio**
- `Services/Interfaces/IStudentProfileService.cs` - Interfaz del servicio
- `Services/Implementations/StudentProfileService.cs` - Implementación del servicio

### **3. Controlador**
- `Controllers/StudentProfileController.cs` - Controlador con autorización solo para estudiantes

### **4. Vista**
- `Views/StudentProfile/Index.cshtml` - Interfaz de usuario moderna y responsive

---

## 🎯 FUNCIONALIDADES

### **Datos que el Estudiante PUEDE Editar:**
✅ Nombre  
✅ Apellido  
✅ Correo Electrónico (con validación de unicidad)  
✅ Documento de Identidad / Cédula (con validación de unicidad)  
✅ Fecha de Nacimiento  
✅ Teléfono Principal  
✅ Teléfono Secundario (opcional)

### **Datos de Solo Lectura (no editables):**
📖 Escuela  
📖 Grado  
📖 Grupo  
📖 Rol

---

## 🔒 SEGURIDAD

### **Autorización:**
- Solo usuarios con rol `Student` pueden acceder
- Validación de que el estudiante solo puede editar su propio perfil
- Token anti-falsificación (CSRF protection)

### **Validaciones:**
- Email único (validación en tiempo real AJAX)
- Documento de identidad único (validación en tiempo real AJAX)
- Validación de formato de email
- Validación de formato de teléfono
- Validación de campos requeridos
- Confirmación antes de guardar cambios

---

## 🎨 INTERFAZ DE USUARIO

### **Diseño:**
- ✨ Encabezado azul moderno con gradiente
- 📊 Información dividida en 2 columnas:
  - **Izquierda:** Información de solo lectura (escuela, grado, grupo)
  - **Derecha:** Formulario editable
- 🎨 Diseño responsive (se adapta a móviles)
- ⚡ Validación en tiempo real con feedback visual
- 🔔 Alertas con SweetAlert2
- ✅ Confirmación antes de guardar

### **Iconos:**
- 📍 Cada campo tiene su icono representativo
- 🎯 Interfaz intuitiva y fácil de usar

---

## 📍 ACCESO AL MÓDULO

### **URL:**
```
/StudentProfile/Index
```

### **Menú de Navegación:**
El enlace "**Mi Perfil**" aparece en el menú lateral izquierdo solo para usuarios con rol **Student**.

**Ubicación en el menú:**
```
├── Dashboard
├── Cambiar Contraseña
├── Mis Calificaciones
└── Mi Perfil ← NUEVO
```

---

## 🔄 FLUJO DE USO

1. **Estudiante inicia sesión**
2. **Hace clic en "Mi Perfil"** en el menú lateral
3. **Ve su información actual**
4. **Edita los campos** que desea actualizar
5. **Hace clic en "Guardar Cambios"**
6. **Confirma en el diálogo** de SweetAlert
7. **El sistema valida** la información
8. **Se actualiza** la base de datos
9. **Mensaje de éxito** confirma la actualización

---

## 🛡️ VALIDACIONES IMPLEMENTADAS

### **Email:**
- Formato válido (debe contener @)
- No puede estar vacío
- Debe ser único (no usado por otro usuario)
- Validación en tiempo real (aparece mensaje si ya existe)

### **Documento de Identidad:**
- Campo opcional
- Si se ingresa, debe ser único
- Validación en tiempo real

### **Nombre y Apellido:**
- Obligatorios
- Máximo 100 caracteres cada uno

### **Teléfonos:**
- Campos opcionales
- Validación de formato telefónico
- Máximo 20 caracteres

### **Fecha de Nacimiento:**
- Campo opcional
- Formato de fecha válido

---

## 📊 MÉTODOS DEL SERVICIO

### **IStudentProfileService:**

```csharp
// Obtener perfil del estudiante
Task<StudentProfileViewModel?> GetStudentProfileAsync(Guid studentId)

// Actualizar perfil
Task<bool> UpdateStudentProfileAsync(StudentProfileViewModel model)

// Validar email disponible
Task<bool> IsEmailAvailableAsync(string email, Guid currentUserId)

// Validar documento disponible
Task<bool> IsDocumentIdAvailableAsync(string? documentId, Guid currentUserId)
```

---

## 🔧 ENDPOINTS DEL CONTROLADOR

### **StudentProfileController:**

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/StudentProfile/Index` | Muestra el formulario de perfil |
| POST | `/StudentProfile/Update` | Actualiza el perfil del estudiante |
| GET | `/StudentProfile/CheckEmailAvailability` | Valida email vía AJAX |
| GET | `/StudentProfile/CheckDocumentAvailability` | Valida documento vía AJAX |

---

## 📝 REGISTROS EN PROGRAM.CS

El servicio fue registrado en `Program.cs`:

```csharp
builder.Services.AddScoped<IStudentProfileService, StudentProfileService>();
```

**Línea:** 80

---

## 🎯 PRUEBAS RECOMENDADAS

### **Caso 1: Actualización Exitosa**
1. Iniciar sesión como estudiante
2. Ir a "Mi Perfil"
3. Cambiar nombre, apellido, teléfono
4. Guardar
5. ✅ Verificar que se actualizó correctamente

### **Caso 2: Email Duplicado**
1. Intentar cambiar email a uno que ya existe
2. ❌ Debe mostrar error "Este correo ya está en uso"
3. ✅ No permite guardar

### **Caso 3: Documento Duplicado**
1. Intentar cambiar documento a uno que ya existe
2. ❌ Debe mostrar error en tiempo real
3. ✅ No permite guardar

### **Caso 4: Validación de Campos**
1. Dejar nombre vacío
2. Intentar guardar
3. ❌ Debe mostrar error de validación
4. ✅ No permite guardar hasta completar

---

## 🚀 CARACTERÍSTICAS DESTACADAS

### **✨ Validación en Tiempo Real:**
Cuando el estudiante escribe en los campos de Email o Documento, el sistema verifica automáticamente si ya están en uso, sin necesidad de enviar el formulario.

### **💾 Auto-guardado de Auditoría:**
El campo `UpdatedBy` se registra automáticamente con el ID del estudiante que hizo la modificación.

### **🔔 Feedback Visual:**
- ✅ Mensajes de éxito con SweetAlert2
- ❌ Mensajes de error claros
- ⚠️ Validaciones en tiempo real

### **📱 Responsive:**
La interfaz se adapta perfectamente a:
- 💻 Desktop
- 📱 Tablet
- 📲 Móvil

---

## 🎨 CARACTERÍSTICAS DE UX/UI

### **Diseño Moderno:**
- Gradientes azules profesionales
- Sombras suaves (box-shadow)
- Bordes redondeados
- Espaciado generoso

### **Interactividad:**
- Botones con efecto hover
- Transiciones suaves
- Iconos descriptivos
- Colores consistentes con el sistema

### **Accesibilidad:**
- Labels descriptivos
- Placeholders informativos
- Mensajes de error claros
- Textos de ayuda

---

## 📊 IMPACTO EN LA BASE DE DATOS

### **Tabla Afectada:**
- `users` - Se actualizan los siguientes campos:
  - `name`
  - `last_name`
  - `email`
  - `document_id`
  - `date_of_birth`
  - `cellphone_primary`
  - `cellphone_secondary`
  - `updated_at`
  - `updated_by`

### **Campos NO modificables:**
- `id` (identificador único)
- `school_id` (escuela asignada)
- `role` (rol del usuario)
- `password_hash` (contraseña)
- `status` (estado activo/inactivo)
- `created_at` (fecha de creación)
- `created_by` (quién lo creó)

---

## ⚙️ CONFIGURACIÓN COMPLETADA

### **✅ Servicio registrado en Program.cs**
```csharp
builder.Services.AddScoped<IStudentProfileService, StudentProfileService>();
```

### **✅ Menú actualizado en _AdminLayout.cshtml**
```html
<li class="nav-item">
    <a href="/StudentProfile/Index" class="nav-link">
        <i class="nav-icon fas fa-user-edit"></i>
        <p>Mi Perfil</p>
    </a>
</li>
```

### **✅ Autorización configurada**
```csharp
[Authorize(Roles = "Student")]
```

---

## 🔍 LOGS Y DEBUGGING

El servicio implementa logging completo:
- ✅ Cada operación registra información
- ⚠️ Los errores se registran con stack trace
- 📊 Se registra qué estudiante actualiza qué datos

**Ejemplo de logs:**
```
📋 Obteniendo perfil del estudiante: {StudentId}
✅ Perfil obtenido correctamente para: Juan Pérez
📝 Actualizando perfil del estudiante: {StudentId}
✅ Perfil actualizado correctamente: Juan Pérez
```

---

## 🧪 TESTING

### **Comandos para probar:**

```bash
# Compilar
dotnet build

# Ejecutar
dotnet run

# Acceder a:
http://localhost:5000/StudentProfile/Index
```

### **Usuario de Prueba:**
- Iniciar sesión con un usuario que tenga rol `Student`
- Navegar a "Mi Perfil"
- Probar actualizaciones

---

## 📚 DEPENDENCIAS

### **Servicios Utilizados:**
- `IStudentProfileService` - Lógica de negocio del perfil
- `ICurrentUserService` - Identificación del usuario actual
- `ILogger<StudentProfileController>` - Registro de eventos

### **Paquetes:**
- Bootstrap 5 (UI)
- jQuery (validaciones)
- SweetAlert2 (alertas)
- ASP.NET Core MVC
- Entity Framework Core

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [x] ViewModel creado
- [x] Interfaz del servicio creada
- [x] Implementación del servicio
- [x] Controlador creado
- [x] Vista creada
- [x] Servicio registrado en Program.cs
- [x] Enlace agregado al menú
- [x] Validaciones implementadas
- [x] Compilación exitosa
- [ ] Pruebas en localhost
- [ ] Despliegue a producción

---

## 🚀 PRÓXIMOS PASOS

1. **Probar en localhost:**
   ```bash
   dotnet run
   ```

2. **Iniciar sesión como estudiante**

3. **Ir a "Mi Perfil"** en el menú

4. **Probar todas las funcionalidades:**
   - Actualizar información
   - Validar email duplicado
   - Validar documento duplicado
   - Verificar mensajes de éxito/error

5. **Desplegar a producción** (Render):
   ```bash
   git add .
   git commit -m "Nuevo módulo: Perfil de Estudiante"
   git push origin main
   ```

---

## 🎉 BENEFICIOS

✅ **Autonomía:** Los estudiantes pueden actualizar su propia información  
✅ **Actualidad:** La información siempre estará al día  
✅ **Reducción de carga:** Admins no tienen que actualizar datos de cada estudiante  
✅ **Mejor UX:** Interfaz moderna y fácil de usar  
✅ **Seguridad:** Validaciones robustas y autorización estricta  

---

**Fecha de Creación:** 15 de Octubre de 2025  
**Estado:** ✅ Completado y Compilado  
**Versión:** 1.0

