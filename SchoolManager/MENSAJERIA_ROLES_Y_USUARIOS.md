# 📧 Sistema de Mensajería: Por Roles y Por Usuarios

## 📊 Estado Actual del Sistema

### ✅ Tipos de Envío Implementados

El sistema actualmente soporta **5 tipos de envío**:

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| **Individual** | A un usuario específico | "Enviar a: Juan Pérez (docente@email.com)" |
| **Group** | A todos los estudiantes de un grupo | "Enviar a: Grupo 10-A" |
| **AllTeachers** | A todos los profesores | "Enviar a: Todos los profesores" |
| **AllStudents** | A todos los estudiantes | "Enviar a: Todos los estudiantes" |
| **Broadcast** | A todos los usuarios | "Enviar a: Todos" |

---

## 🔐 Permisos por Rol

### 👨‍🎓 **ESTUDIANTE** (`student` / `estudiante`)

**Puede enviar a:**
- ✅ Profesores individuales
- ✅ Todos los profesores (AllTeachers)

**NO puede enviar a:**
- ❌ Otros estudiantes
- ❌ Grupos
- ❌ Broadcast

**Validación en código:**
```csharp
// Líneas 522-528 en MessagingService.cs
case "student":
case "estudiante":
    options.CanSendToAllTeachers = true;
    options.CanSendToAllStudents = false;
    options.CanSendToBroadcast = false;
    break;
```

---

### 👨‍🏫 **PROFESOR** (`teacher`)

**Puede enviar a:**
- ✅ Profesores individuales
- ✅ Estudiantes individuales
- ✅ Grupos completos (todos los estudiantes de un grupo)

**NO puede enviar a:**
- ❌ Todos los profesores
- ❌ Todos los estudiantes
- ❌ Broadcast

**Validación en código:**
```csharp
// Líneas 530-559 en MessagingService.cs
case "teacher":
    options.Students = await _context.Users
        .Where(u => u.SchoolId == user.SchoolId && 
               (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante") && 
               u.Status == "active")
        .ToListAsync();

    options.Groups = await _context.Groups
        .Where(g => g.SchoolId == user.SchoolId)
        .ToListAsync();

    options.CanSendToAllTeachers = false;
    options.CanSendToAllStudents = false;
    options.CanSendToBroadcast = false;
    break;
```

---

### 👔 **DIRECTOR / ADMIN / SUPERADMIN**

**Puede enviar a:**
- ✅ Cualquier usuario individual
- ✅ Grupos completos
- ✅ Todos los profesores
- ✅ Todos los estudiantes
- ✅ Broadcast (todos)

**Validación en código:**
```csharp
// Líneas 561-582 en MessagingService.cs
case "admin":
case "director":
case "superadmin":
    options.Students = await _context.Users
        .Where(u => u.SchoolId == user.SchoolId && 
               (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante") && 
               u.Status == "active")
        .ToListAsync();

    options.CanSendToAllTeachers = true;
    options.CanSendToAllStudents = true;
    options.CanSendToBroadcast = true;
    break;
```

---

## 🎯 Cómo Funciona Actualmente

### 1️⃣ **Envío Individual** (Por Usuario Puntual)

**Flujo:**
1. Usuario selecciona "Individual"
2. Escoge un usuario específico de la lista
3. Se crea 1 mensaje con `RecipientId` específico

**Código:**
```csharp
// Líneas 48-68 en MessagingService.cs
case "Individual":
    if (!model.RecipientId.HasValue)
        return false;

    messages.Add(new Message
    {
        SenderId = senderId,
        RecipientId = model.RecipientId.Value,
        MessageType = "Individual",
        // ... resto de propiedades
    });
    break;
```

---

### 2️⃣ **Envío por Rol** (AllTeachers / AllStudents)

**Flujo:**
1. Usuario selecciona "AllTeachers" o "AllStudents"
2. Sistema busca TODOS los usuarios con ese rol
3. Se crea UN mensaje para CADA usuario encontrado

**Código - AllTeachers:**
```csharp
// Líneas 101-125 en MessagingService.cs
case "AllTeachers":
    var teachers = await _context.Users
        .Where(u => u.SchoolId == sender.SchoolId && 
               u.Role.ToLower() == "teacher" && 
               u.Status == "active")
        .Select(u => u.Id)
        .ToListAsync();

    foreach (var teacherId in teachers)
    {
        messages.Add(new Message
        {
            SenderId = senderId,
            RecipientId = teacherId,
            MessageType = "AllTeachers",
            // ... resto
        });
    }
    break;
```

**Código - AllStudents:**
```csharp
// Líneas 127-153 en MessagingService.cs
case "AllStudents":
    var students = await _context.Users
        .Where(u => u.SchoolId == sender.SchoolId && 
               (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante") && 
               u.Status == "active")
        .Select(u => u.Id)
        .ToListAsync();

    foreach (var studentId in students)
    {
        messages.Add(new Message
        {
            SenderId = senderId,
            RecipientId = studentId,
            MessageType = "AllStudents",
            // ... resto
        });
    }
    break;
```

---

### 3️⃣ **Envío a Grupo**

**Flujo:**
1. Usuario selecciona "Group"
2. Escoge un grupo específico (ej: 10-A)
3. Sistema busca todos los estudiantes asignados a ese grupo
4. Se crea UN mensaje para CADA estudiante del grupo

**Código:**
```csharp
// Líneas 70-99 en MessagingService.cs
case "Group":
    if (!model.GroupId.HasValue)
        return false;

    var groupStudents = await _context.StudentAssignments
        .Where(sa => sa.GroupId == model.GroupId.Value)
        .Select(sa => sa.StudentId)
        .Distinct()
        .ToListAsync();

    foreach (var studentId in groupStudents)
    {
        messages.Add(new Message
        {
            SenderId = senderId,
            RecipientId = studentId,
            GroupId = model.GroupId.Value,
            MessageType = "Group",
            // ... resto
        });
    }
    break;
```

---

### 4️⃣ **Broadcast** (Todos)

**Flujo:**
1. Usuario selecciona "Broadcast"
2. Sistema busca TODOS los usuarios de la escuela (excepto el remitente)
3. Se crea UN mensaje para CADA usuario

**Código:**
```csharp
// Líneas 155-181 en MessagingService.cs
case "Broadcast":
    var allUsers = await _context.Users
        .Where(u => u.SchoolId == sender.SchoolId && 
               u.Id != senderId && 
               u.Status == "active")
        .Select(u => u.Id)
        .ToListAsync();

    foreach (var userId in allUsers)
    {
        messages.Add(new Message
        {
            SenderId = senderId,
            RecipientId = userId,
            MessageType = "Broadcast",
            // ... resto
        });
    }
    break;
```

---

## 🔒 Función de Validación de Permisos

**Ubicación:** Líneas 661-703 en `MessagingService.cs`

```csharp
public async Task<bool> CanSendToRecipientAsync(Guid senderId, string recipientType, Guid? recipientId, Guid? groupId)
{
    var sender = await _context.Users.FindAsync(senderId);
    if (sender == null) return false;

    var role = sender.Role.ToLower();

    switch (recipientType)
    {
        case "Individual":
            return recipientId.HasValue;

        case "Group":
            // Solo profesores y administradores
            return groupId.HasValue && 
                   (role == "teacher" || role == "admin" || role == "director" || role == "superadmin");

        case "AllTeachers":
            // Estudiantes y administradores
            return role == "student" || role == "estudiante" || 
                   role == "admin" || role == "director" || role == "superadmin";

        case "AllStudents":
            // Solo administradores
            return role == "admin" || role == "director" || role == "superadmin";

        case "Broadcast":
            // Solo administradores
            return role == "admin" || role == "director" || role == "superadmin";

        default:
            return false;
    }
}
```

---

## 💡 Características Importantes

### ✅ Multi-Tenancy
- Todos los mensajes están limitados por `SchoolId`
- Un usuario solo ve y puede enviar mensajes dentro de su escuela

### ✅ Filtro de Estado
- Solo se envía a usuarios con `Status == "active"`
- Los usuarios inactivos no reciben mensajes

### ✅ Soft Delete
- Los mensajes eliminados se marcan con `IsDeleted = true`
- No se eliminan físicamente de la base de datos

### ✅ Lectura Automática
- Cuando el destinatario abre un mensaje, se marca automáticamente como leído
- Se registra la fecha/hora de lectura en `ReadAt`

---

## 📊 Resumen de Capacidades

| Rol | Individual | Grupo | AllTeachers | AllStudents | Broadcast |
|-----|-----------|-------|-------------|-------------|-----------|
| **Estudiante** | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Profesor** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Director** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Admin** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **SuperAdmin** | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 🔄 Flujo Completo de Envío

```
1. Usuario abre Compose
   ↓
2. Sistema carga opciones según su rol (GetRecipientOptionsAsync)
   ↓
3. Usuario completa formulario:
   - Asunto
   - Mensaje
   - Tipo de destinatario
   - Destinatario específico (si aplica)
   ↓
4. Sistema valida permisos (CanSendToRecipientAsync)
   ↓
5. Si es válido, crea mensaje(s):
   - Individual: 1 mensaje
   - Grupo: N mensajes (N = estudiantes en grupo)
   - AllTeachers: N mensajes (N = profesores activos)
   - AllStudents: N mensajes (N = estudiantes activos)
   - Broadcast: N mensajes (N = todos los usuarios activos)
   ↓
6. Inserta en DB (messages table)
   ↓
7. Redirige a "Sent" con confirmación
```

---

## 🎯 Ejemplo Práctico

### Ejemplo 1: Estudiante envía consulta a un profesor

```
Remitente: Juan Estudiante (student)
Tipo: Individual
Destinatario: Prof. María García
Resultado: 1 mensaje creado
```

### Ejemplo 2: Director envía anuncio a todos los profesores

```
Remitente: Director López (director)
Tipo: AllTeachers
Destinatario: (automático)
Resultado: 15 mensajes creados (uno para cada profesor)
```

### Ejemplo 3: Profesor envía tarea a un grupo

```
Remitente: Prof. Carlos Ruiz (teacher)
Tipo: Group
Grupo: 10-A
Resultado: 25 mensajes creados (uno para cada estudiante de 10-A)
```

---

## ✅ Conclusión

**El sistema ACTUAL ya soporta:**
1. ✅ Mensajería por **usuario puntual** (Individual)
2. ✅ Mensajería por **rol** (AllTeachers, AllStudents)
3. ✅ Mensajería por **grupo**
4. ✅ Mensajería **broadcast**

**Validaciones por rol:**
- ✅ Estudiantes: solo a profesores
- ✅ Profesores: a estudiantes y grupos
- ✅ Directores/Admins: sin restricciones

**El sistema es flexible y puede extenderse fácilmente para agregar:**
- AllDirectors
- AllAdmins
- Por especialidad
- Por grado
- etc.

