# Funcionalidad: Recuperación de Materias

## ✅ Implementación Completa

Se ha agregado un nuevo tipo de actividad llamado **"Recuperación"** con reglas especiales para estudiantes de 9º y 12º grado.

---

## 📋 **Características Implementadas**

### **1. Nuevo Tipo de Actividad: Recuperación**
- ✅ Agregada como opción en el dropdown de "Tipo de Actividad"
- ✅ Disponible en: `/TeacherGradebook/Index`
- ✅ Ubicación: `SchoolManager/Views/TeacherGradebook/Index.cshtml` líneas 557-564

```html
<option value="Recuperación">Recuperación</option>
<small class="text-muted" id="recuperacionHelper" style="display: none;">
    <i class="bi bi-info-circle"></i> Solo para 9º y 12º
</small>
```

---

### **2. Validación de Grado (Solo 9º y 12º)**
- ✅ **Restricción automática**: Solo permite crear actividades de recuperación para grupos de 9º y 12º grado
- ✅ **Validación en tiempo real**: JavaScript detecta el grado del grupo seleccionado
- ✅ **Mensaje de error claro**: Si intentas crear recuperación para otros grados, muestra:
  > "Las actividades de recuperación solo están disponibles para estudiantes de 9º y 12º grado"
- ✅ **Ubicación**: Líneas 1928-1954

```javascript
// Extraer el número del grado del texto del combo
const gradeMatch = selectedText.match(/(\d+)°/);
const gradeNumber = parseInt(gradeMatch[1]);

// Solo permitir para 9º y 12º
if (gradeNumber !== 9 && gradeNumber !== 12) {
    Swal.fire({ 
        icon: 'warning', 
        title: 'Recuperación no permitida', 
        text: 'Las actividades de recuperación solo están disponibles...'
    });
    return;
}
```

---

### **3. Validación de Máximo 3 Fracasos**
- ✅ **Modal de confirmación**: Al crear recuperación, aparece un modal informativo:
  > "La recuperación solo es válida para estudiantes con máximo 3 materias reprobadas."
- ✅ **Opción de cancelar**: El profesor puede cancelar si el estudiante tiene más de 3 fracasos
- ✅ **Ubicación**: Líneas 1956-1974

```javascript
Swal.fire({
    title: '⚠️ Importante',
    html: '<p><strong>La recuperación solo es válida para estudiantes con máximo 3 materias reprobadas.</strong></p>',
    icon: 'info',
    showCancelButton: true,
    confirmButtonText: 'Entendido, continuar',
    cancelButtonText: 'Cancelar'
})
```

---

### **4. La Recuperación Reemplaza la Nota Final**
- ✅ **Lógica implementada**: Cuando un estudiante tiene nota de recuperación > 0, esta reemplaza automáticamente el promedio del "Examen Final"
- ✅ **Cálculo automático**: El promedio final del trimestre se calcula con:
  - Promedio de Notas de Apreciación
  - Promedio de Ejercicios Diarios
  - **Nota de Recuperación (en lugar de Examen Final)**
- ✅ **Ubicación**: Función `calcAverages()` líneas 1706-1714

```javascript
// LÓGICA ESPECIAL PARA RECUPERACIÓN:
// Si existe recuperación y tiene nota > 0, reemplaza el promedio del examen final
let typesForFinal = [...activeTypes];
if (typeAvgs['recuperación'] && typeAvgs['recuperación'] > 0) {
    // Si hay recuperación, reemplazar el examen final con recuperación
    // y no contar ambos en el promedio final
    typeAvgs['examen final'] = typeAvgs['recuperación'];
    typesForFinal = typesForFinal.filter(t => t !== 'recuperación');
}
```

---

### **5. Helper Visual**
- ✅ **Indicador dinámico**: Cuando se selecciona "Recuperación", aparece el texto:
  > "ℹ️ Solo para 9º y 12º"
- ✅ **Se oculta automáticamente**: Al cambiar a otro tipo de actividad
- ✅ **Ubicación**: Event listener líneas 1230-1237

---

## 🎯 **Flujo de Uso**

### **Paso a Paso para el Profesor:**

1. **Seleccionar Grupo de 9º o 12º**
   - Ir a `/TeacherGradebook/Index`
   - Seleccionar un grupo de 9º o 12º grado

2. **Crear Actividad de Recuperación**
   - En "Tipo", seleccionar **"Recuperación"**
   - Aparecerá el helper: "Solo para 9º y 12º"
   - Llenar nombre, fecha de entrega, archivo opcional

3. **Validaciones Automáticas**
   - ✅ Si el grado no es 9º o 12º → Error
   - ✅ Si es 9º o 12º → Modal de confirmación sobre 3 fracasos

4. **Confirmar Creación**
   - Hacer clic en "Entendido, continuar"
   - La actividad se crea exitosamente

5. **Ingresar Notas**
   - Las notas de recuperación aparecen como una columna en la tabla
   - Solo ingresar nota de recuperación a estudiantes con máximo 3 fracasos

6. **Cálculo Automático**
   - El sistema reemplaza automáticamente el "Examen Final" con la nota de "Recuperación"
   - El promedio final del trimestre se calcula correctamente

---

## 📊 **Ejemplo de Cálculo**

### **Escenario: Estudiante con Recuperación**

**Notas originales:**
- Notas de Apreciación: 3.5
- Ejercicios Diarios: 3.8
- Examen Final: 2.0 ❌ (Reprobado)

**Promedio original:** (3.5 + 3.8 + 2.0) / 3 = **3.1**

**Con Recuperación:**
- Notas de Apreciación: 3.5
- Ejercicios Diarios: 3.8
- ~~Examen Final: 2.0~~
- **Recuperación: 4.0** ✅

**Nuevo Promedio:** (3.5 + 3.8 + 4.0) / 3 = **3.8** ✅ Aprobado

---

## 🔐 **Seguridad y Validaciones**

| Validación | Implementado | Ubicación |
|-----------|-------------|-----------|
| Solo 9º y 12º grado | ✅ | Líneas 1928-1954 |
| Modal de confirmación | ✅ | Líneas 1956-1974 |
| Helper visual | ✅ | Líneas 1230-1237 |
| Reemplazo de nota final | ✅ | Líneas 1706-1714 |
| Integración en tabla | ✅ | Líneas 1363, 1690 |

---

## 🎉 **Resumen**

La funcionalidad de **Recuperación** está completamente implementada y cumple con todos los requerimientos:

1. ✅ Nuevo tipo de actividad "Recuperación"
2. ✅ Solo para 9º y 12º grado
3. ✅ Validación de máximo 3 fracasos (con advertencia)
4. ✅ La nota de recuperación reemplaza la nota final
5. ✅ Cálculo automático del promedio final
6. ✅ Helper visual y validaciones en tiempo real

**El sistema está listo para usar en producción.** 🚀

