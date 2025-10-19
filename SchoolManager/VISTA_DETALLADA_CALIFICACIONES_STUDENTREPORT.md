# 📊 Vista Detallada de Calificaciones en StudentReport/Index

## ✨ **Nueva Funcionalidad Implementada**

Se ha rediseñado completamente la tabla de calificaciones para mostrar **TODAS las actividades individuales** con su agrupación por tipo y promedios.

---

## 🎯 **Problema Anterior**

### **Antes:**
```
| Materia       | Notas Aprec | Ejercicios | Examen | Promedio |
|---------------|-------------|------------|--------|----------|
| MATEMÁTICAS   | 4.0         | 4.3        | 4.3    | 4.2      |
| ESPAÑOL       | 2.7         | 2.7        | 2.6    | 2.7      |
```

❌ Solo mostraba promedios generales por tipo
❌ No se veían las actividades individuales
❌ No se sabía qué actividades específicas tenía el estudiante
❌ Difícil de entender el desglose

---

## ✅ **Solución Implementada**

### **Ahora:**
```
| Materia       | Tipo de Actividad         | Actividad      | Nota | Promedio |
|---------------|---------------------------|----------------|------|----------|
| MATEMÁTICAS   | Notas de Apreciación      | Tarea 1        | 4.2  |          |
|               |                           | Tarea 2        | 3.8  |          |
|               |                           | Tarea 3        | 4.0  | ⌀ 4.0    |
|               | Ejercicios Diarios        | Ejercicio 1    | 4.5  |          |
|               |                           | Ejercicio 2    | 4.1  | ⌀ 4.3    |
|               | Examen Final              | Examen T1      | 4.3  | 4.2      |
```

✅ Muestra TODAS las actividades individuales
✅ Agrupa por tipo de actividad
✅ Muestra promedio por tipo (⌀)
✅ Muestra promedio final de la materia
✅ Visual claro y organizado

---

## 🏗️ **Estructura de la Tabla**

### **Columnas**
1. **Materia** (25%): Nombre de la materia (rowspan para todas las actividades)
2. **Tipo de Actividad** (25%): Notas de Apreciación, Ejercicios Diarios, Examen Final (rowspan para cada tipo)
3. **Actividad** (30%): Nombre específico de la actividad (Tarea 1, Ejercicio 2, etc.)
4. **Nota** (10%): Calificación individual (badge verde ≥3.0, rojo <3.0)
5. **Promedio** (10%): Promedio del tipo (⌀) o promedio final de la materia

### **Jerarquía Visual**
```
├── MATERIA (span todas las filas)
│   ├── Tipo 1: Notas de Apreciación
│   │   ├── Actividad 1 | Nota 1 | 
│   │   ├── Actividad 2 | Nota 2 |
│   │   └── Actividad 3 | Nota 3 | ⌀ Promedio Tipo 1
│   ├── Tipo 2: Ejercicios Diarios
│   │   ├── Actividad 1 | Nota 1 |
│   │   └── Actividad 2 | Nota 2 | ⌀ Promedio Tipo 2
│   └── Tipo 3: Examen Final
│       └── Actividad 1 | Nota 1 | PROMEDIO FINAL MATERIA
```

---

## 🎨 **Estilos Visuales**

### **Colores por Sección**
- **Materia**: Borde derecho grueso (#dee2e6)
- **Tipo de Actividad**: Fondo azul claro (#e3f2fd)
- **Filas alternas**: Gris claro (#f8f9fa)
- **Promedio Final**: Fondo amarillo (#fff3cd)

### **Badges de Notas**
```css
Nota ≥ 3.0: badge bg-success (verde)
Nota < 3.0: badge bg-danger (rojo)
```

### **Indicadores**
- `⌀ X.X` : Promedio por tipo de actividad
- `X.X` (grande): Promedio final de la materia

---

## 💻 **Lógica Implementada**

### **Paso 1: Agrupar por Materia**
```csharp
var gradesBySubject = Model.Grades
    .Where(g => g.Value.HasValue)
    .GroupBy(g => g.Subject)
    .OrderBy(g => g.Key);
```

### **Paso 2: Definir Tipos de Actividad**
```csharp
var tiposActividad = new[] { 
    new { Nombre = "Notas de Apreciación", Filtro = ... },
    new { Nombre = "Ejercicios Diarios", Filtro = ... },
    new { Nombre = "Examen Final", Filtro = ... }
};
```

### **Paso 3: Contar Filas y Calcular Promedios**
```csharp
// Contar total de actividades para rowspan
int totalRowsForSubject = 0;
List<decimal> promediosTipos = new List<decimal>();

foreach (var tipoActividad in tiposActividad)
{
    var actividadesTipo = subjectGroup.Where(tipoActividad.Filtro).ToList();
    if (actividadesTipo.Any())
    {
        totalRowsForSubject += actividadesTipo.Count;
        promediosTipos.Add(actividadesTipo.Average(g => g.Value.Value));
    }
}

// Promedio final = promedio de promedios de tipos
decimal? promedioFinal = promediosTipos.Any() ? promediosTipos.Average() : null;
```

### **Paso 4: Renderizar Filas**
```csharp
// Materia con rowspan para todas sus actividades
<td rowspan="@totalRowsForSubject">
    <strong>@materia</strong>
</td>

// Tipo con rowspan para todas las actividades del tipo
<td rowspan="@actividadesTipo.Count">
    @tipoActividad.Nombre
</td>

// Actividad individual
<td>@actividad.ActivityName</td>
<td><span class="badge">@actividad.Value</span></td>

// Promedio (solo en última fila del tipo o de la materia)
@if (última fila del tipo)
{
    <td>⌀ @promedioTipo</td>
}
else if (última fila de la materia)
{
    <td>@promedioFinal</td>
}
```

---

## 📊 **Ejemplo Visual Completo**

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CALIFICACIONES DEL TRIMESTRE                      │
├─────────────────┬───────────────────────┬──────────────┬──────┬─────────┤
│ MATERIA         │ TIPO DE ACTIVIDAD      │ ACTIVIDAD    │ NOTA │ PROMEDIO│
├─────────────────┼───────────────────────┼──────────────┼──────┼─────────┤
│                 │ Notas de Apreciación  │ Tarea 1      │ 4.2  │         │
│                 │                       │ Tarea 2      │ 3.8  │         │
│                 │                       │ Participación│ 4.0  │ ⌀ 4.0   │
│ MATEMÁTICAS     ├───────────────────────┼──────────────┼──────┼─────────┤
│                 │ Ejercicios Diarios    │ Ejercicio 1  │ 4.5  │         │
│                 │                       │ Ejercicio 2  │ 4.1  │ ⌀ 4.3   │
│                 ├───────────────────────┼──────────────┼──────┼─────────┤
│                 │ Examen Final          │ Examen T1    │ 4.3  │ 4.2     │
├─────────────────┼───────────────────────┼──────────────┼──────┼─────────┤
│                 │ Notas de Apreciación  │ Tarea 1      │ 2.8  │         │
│                 │                       │ Tarea 2      │ 2.6  │ ⌀ 2.7   │
│ ESPAÑOL         ├───────────────────────┼──────────────┼──────┼─────────┤
│                 │ Ejercicios Diarios    │ Ejercicio 1  │ 2.9  │         │
│                 │                       │ Ejercicio 2  │ 2.5  │ ⌀ 2.7   │
│                 ├───────────────────────┼──────────────┼──────┼─────────┤
│                 │ Examen Final          │ Examen T1    │ 2.6  │ 2.7     │
├─────────────────┴───────────────────────┴──────────────┴──────┴─────────┤
│                     PROMEDIO GENERAL DEL TRIMESTRE:           2.9        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 **Características Especiales**

### **1. Rowspan Dinámico**
- La celda de **Materia** se expande para todas sus actividades
- La celda de **Tipo** se expande para todas las actividades de ese tipo
- Uso de `firstRowForSubject` y `firstRowForType` para control

### **2. Promedios en Cascada**
```
Nota Individual → Promedio por Tipo → Promedio de Materia → Promedio General
    4.2                ⌀ 4.0               4.2                  2.9
```

### **3. Colores Semánticos**
```
Verde (success): Nota ≥ 3.0
Rojo (danger):   Nota < 3.0
Azul (#e3f2fd):  Tipo de actividad
Amarillo (#fff3cd): Promedio final de materia
```

### **4. Sin Datos**
```html
<tr>
    <td><strong>MATERIA</strong></td>
    <td colspan="3">Sin calificaciones</td>
    <td class="text-danger fw-bold">-</td>
</tr>
```

---

## 📱 **Responsive Design**

### **Ancho de Columnas**
```css
Materia:           25% (width)
Tipo de Actividad: 25% (width)
Actividad:         30% (width)
Nota:              10% (width)
Promedio:          10% (width)
```

### **Scroll Horizontal**
La tabla es responsive y permite scroll horizontal en pantallas pequeñas.

---

## 🔄 **Cálculo de Promedios**

### **Promedio por Tipo**
```csharp
decimal promedioTipo = actividadesTipo.Average(g => g.Value.Value);
```

### **Promedio Final de Materia**
```csharp
// Promedio de los 3 promedios de tipos
decimal promedioFinal = promediosTipos.Average();
```

### **Promedio General**
```csharp
decimal promedioGeneral = totalPromedios / materiaCount;
```

---

## 🎉 **Beneficios para el Usuario**

### **Estudiantes**
✅ Ven todas sus actividades individuales
✅ Entienden cómo se calcula cada promedio
✅ Identifican qué actividades les bajaron la nota
✅ Transparencia total en la evaluación

### **Padres**
✅ Visibilidad completa del desempeño
✅ Pueden identificar áreas de mejora
✅ Ven el historial completo de actividades

### **Profesores/Coordinadores**
✅ Vista detallada del rendimiento estudiantil
✅ Facilita el análisis de desempeño
✅ Identificación de patrones

---

## 📊 **Datos Mostrados**

Para cada actividad:
- ✅ Nombre de la actividad
- ✅ Tipo de actividad
- ✅ Nota individual
- ✅ Promedio por tipo
- ✅ Promedio final de materia
- ✅ Promedio general del trimestre

---

## 🚀 **Resultado Final**

**Una vista completamente detallada, organizada y visual que muestra:**
1. Todas las actividades individuales
2. Agrupación por tipo
3. Promedios en cascada
4. Colores semánticos
5. Estructura clara y profesional

**¡Ahora los estudiantes y padres pueden ver EXACTAMENTE qué actividades tienen, qué notas obtuvieron, y cómo se calculan todos los promedios! 📚✨**
