# 📊 LÓGICA DE CÁLCULO DE NOTAS

## **Tipos de Actividades**

El sistema utiliza 3 tipos de actividades:

1. **Notas de apreciación**
2. **Ejercicios diarios**
3. **Examen Final**

## **Cálculo de la Nota Final**

La nota final se calcula de la siguiente manera:

### **Paso 1: Calcular Promedio por Tipo**

Para cada tipo de actividad, se calcula el promedio de todas las notas de ese tipo:

- **Promedio Notas de Apreciación** = Suma de todas las notas de apreciación / Cantidad de notas de apreciación
- **Promedio Ejercicios Diarios** = Suma de todas las notas de ejercicios diarios / Cantidad de ejercicios diarios
- **Promedio Examen Final** = Suma de todas las notas de examen final / Cantidad de exámenes finales

### **Paso 2: Calcular Nota Final**

La nota final es el **promedio de los 3 promedios** calculados en el Paso 1:

```
Nota Final = (Promedio Notas Apreciación + Promedio Ejercicios Diarios + Promedio Examen Final) / 3
```

**Importante:** Solo se promedian los tipos que tienen al menos una nota. Si un estudiante no tiene notas en algún tipo, ese tipo no se incluye en el cálculo.

### **Ejemplo:**

Si un estudiante tiene:
- Notas de apreciación: 4.0, 3.5, 4.5 → **Promedio: 4.0**
- Ejercicios diarios: 3.0, 3.5, 4.0, 3.5 → **Promedio: 3.5**
- Examen Final: 4.5 → **Promedio: 4.5**

**Nota Final = (4.0 + 3.5 + 4.5) / 3 = 4.0**

## **Estado del Estudiante**

El estado del estudiante se determina según la nota final:

- **Aprobado:** Nota Final ≥ 3.0
- **Reprobado:** Nota Final < 3.0
- **Sin calificar:** No tiene notas en ningún tipo de actividad

## **Implementación en el Sistema**

### **Frontend (JavaScript)**

La lógica se implementa en las siguientes vistas:

1. **TeacherGradebook/Index.cshtml** (líneas 1664-1685)
2. **OrientationReport/Index.cshtml** (líneas 1730-1755)
3. **TeacherGradebookDuplicate/Index.cshtml** (líneas 1740-1765)

```javascript
// Para cada tipo de actividad
activeTypes.forEach(type => {
    const values = row.find(`.score-cell[data-type='${type}']`)
        .map((_, td) => {
            const val = parseFloat($(td).text());
            return isNaN(val) ? 0 : val;
        }).get();
    const valid = values.filter(n => n > 0);
    const avg = valid.length > 0 ? (valid.reduce((a, b) => a + b, 0) / valid.length) : 0;
    const truncAvg = Math.floor(avg * 10) / 10;
    typeAvgs[type] = truncAvg;
});

// Calcular nota final como promedio de los 3 promedios
let finalGrade = 0;
let activeTypeCount = activeTypes.length;

if (activeTypeCount > 0) {
    finalGrade = activeTypes.reduce((sum, type) => sum + typeAvgs[type], 0) / activeTypeCount;
}
```

### **Backend (C#)**

La lógica se implementa en:

**Services/Implementations/StudentActivityScoreService.cs** (líneas 324-353)

```csharp
// Calcular promedios por tipo de actividad
var promedioNotasApreciacion = notasEstudianteTrimestre
    .Where(x => x.ActivityType.ToLower() == "notas de apreciación" && x.Score.HasValue)
    .Any() ? notasEstudianteTrimestre
    .Where(x => x.ActivityType.ToLower() == "notas de apreciación" && x.Score.HasValue)
    .Average(x => x.Score.Value) : (decimal?)null;

var promedioEjerciciosDiarios = notasEstudianteTrimestre
    .Where(x => x.ActivityType.ToLower() == "ejercicios diarios" && x.Score.HasValue)
    .Any() ? notasEstudianteTrimestre
    .Where(x => x.ActivityType.ToLower() == "ejercicios diarios" && x.Score.HasValue)
    .Average(x => x.Score.Value) : (decimal?)null;

var promedioExamenFinal = notasEstudianteTrimestre
    .Where(x => x.ActivityType.ToLower() == "examen final" && x.Score.HasValue)
    .Any() ? notasEstudianteTrimestre
    .Where(x => x.ActivityType.ToLower() == "examen final" && x.Score.HasValue)
    .Average(x => x.Score.Value) : (decimal?)null;

// Calcular nota final como el promedio de los 3 promedios (solo los que tienen valor)
var promediosConValor = new[] { promedioNotasApreciacion, promedioEjerciciosDiarios, promedioExamenFinal }
    .Where(p => p.HasValue)
    .Select(p => p.Value)
    .ToList();

var notaFinal = promediosConValor.Any() ? promediosConValor.Average() : (decimal?)null;
```

## **Notas Importantes**

1. **Redondeo:** Las notas se truncan a un decimal (no se redondean hacia arriba o abajo).
   - Ejemplo: 4.567 → 4.5

2. **Notas Válidas:** Solo se consideran las notas mayores a 0.

3. **Escala:** El sistema usa una escala de 0.0 a 5.0.

4. **Nota Mínima de Aprobación:** 3.0

## **Mapeo de Propiedades**

En el DTO `PromedioFinalDto`, las propiedades se mapean de la siguiente manera:

- `PromedioTareas` → Contiene el promedio de **"Notas de apreciación"**
- `PromedioParciales` → Contiene el promedio de **"Ejercicios diarios"**
- `PromedioExamenes` → Contiene el promedio de **"Examen Final"**
- `NotaFinal` → Contiene el **promedio de los 3 promedios**

*Nota: Los nombres de las propiedades se mantuvieron por compatibilidad con el código existente.*

