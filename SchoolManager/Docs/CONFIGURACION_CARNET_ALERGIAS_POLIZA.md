# Configuración del carnet: alergias, contacto de emergencia y póliza

## Dónde se configura cada cosa

### 1. Alergias y contacto de emergencia **por estudiante**

- **Dónde:** El propio estudiante (o quien tenga acceso a su perfil) los edita en **Mi Perfil**.
- **Ruta:** Menú **Mi Perfil** (o `/StudentProfile`) → sección *"Información para el carnet estudiantil"*.
- **Campos:** Alergias, nombre del contacto de emergencia, teléfono y relación (ej. Padre, Madre, Acudiente).
- **Base de datos:** Tabla `users`, columnas `allergies`, `emergency_contact_name`, `emergency_contact_phone`, `emergency_relationship`.

Si el estudiante no rellena estos datos, en el carnet no aparecerán (o saldrá “Ninguna registrada” según el diseño).

### 2. Configuración del carnet (qué se muestra al imprimir)

- **Dónde:** **Configuración del Carnet Estudiantil**.
- **Ruta:** `/id-card/settings` (o desde **Carnets** → botón **Configuración**).
- **Quién puede:** SuperAdmin, **admin** y **director** (cada uno para su escuela).
- **Opciones relevantes:**
  - **Mostrar alergias:** si está activado, en el **reverso** del carnet se imprime el texto de alergias del estudiante (cuando tenga dato).
  - **Mostrar contacto de emergencia:** si está activado, se muestra nombre, teléfono y relación del contacto de emergencia en el reverso.
  - **Mostrar teléfono del colegio:** muestra el teléfono de la escuela en el reverso.

Para que la configuración **sí afecte al imprimir**:

1. Entra a **Configuración del Carnet** (`/id-card/settings`).
2. Si eres SuperAdmin, elige la escuela.
3. Activa las casillas que quieras (por ejemplo **Mostrar alergias**, **Mostrar contacto de emergencia**).
4. Pulsa **Guardar**.

Esa configuración se guarda en `school_id_card_settings` por escuela y es la que usa el PDF al generar el carnet.

### 3. Póliza (seguro / número de póliza)

- **Estado actual:** No existe en el sistema (ni en modelo, ni en BD, ni en carnet).
- **Si se quiere agregar:** habría que:
  - Añadir un campo en la tabla `users` (por ejemplo `policy_number` o `poliza`) y en el modelo `User`.
  - Mostrarlo y editarlo en **Mi Perfil** (y/o en la ficha del estudiante si la edita un admin).
  - Incluirlo en el DTO y en el diseño del PDF del carnet (por ejemplo en el reverso, junto a alergias y contacto de emergencia).

---

## Resumen rápido

| Qué | Dónde configurarlo | Afecta al imprimir carnet |
|-----|--------------------|----------------------------|
| Alergias del estudiante | Mi Perfil → Información para el carnet | Sí, si en Config. carnet está “Mostrar alergias” |
| Contacto de emergencia | Mi Perfil → Información para el carnet | Sí, si en Config. carnet está “Mostrar contacto de emergencia” |
| Mostrar alergias / contacto en el carnet | Configuración del Carnet (`/id-card/settings`) | Sí, define si esos datos se imprimen o no |
| Póliza | No existe aún en el sistema | — |
