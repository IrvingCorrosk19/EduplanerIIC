# Pruebas de integración: schoolmanager_id_scanner ↔ SchoolManager

## 1. Resumen de endpoints (backend SchoolManager)

| Endpoint | Método | Auth | Descripción |
|----------|--------|------|-------------|
| `/api/auth/login` | POST | No | Login app móvil. Devuelve `token`, `userId`, `email`, `name`, `role`. |
| `/StudentIdCard/api/scan` | POST | No (`[AllowAnonymous]`) | Valida token del QR del carné y registra el escaneo. |

---

## 2. Login — `POST /api/auth/login`

- **Controlador:** `AuthController.ApiLogin`
- **Body (JSON):** `{ "email": "...", "password": "..." }`
- **Respuesta 200:** `{ "token": "...", "userId": "...", "email": "...", "name": "...", "role": "..." }`
- **Respuesta 401:** credenciales inválidas.
- **Uso en la app:** La app Flutter guarda `token` en `Storage` y lo envía como `Authorization: Bearer <token>` en el scan (el backend no lo valida para scan; el endpoint es anónimo).

---

## 3. Scan — `POST /StudentIdCard/api/scan`

- **Controlador:** `StudentIdCardController.ScanApi`
- **Body (JSON):**
  - `token` (string, obligatorio): valor leído del código QR del carné.
  - `scanType` (string, opcional): ej. `"entry"`. Por defecto `"entry"`.
  - `scannedBy` (string GUID, opcional): quien escanea. La app envía `"00000000-0000-0000-0000-000000000000"` si no se usa.

- **Qué hace el backend (`StudentIdCardService.ScanAsync`):**
  1. Busca en `student_qr_tokens` un token válido (no revocado, no expirado).
  2. Si **no hay token válido:** escribe en `scan_logs` con `student_id = null`, `result = "denied"` y devuelve `allowed: false`, `message: "QR inválido o expirado"`.
  3. Si **hay token pero el estudiante no tiene asignación activa:** escribe en `scan_logs` con `result = "denied"` y devuelve `allowed: false`, `message: "Estudiante sin asignación activa"`.
  4. Si **todo es válido:** escribe en `scan_logs` con `result = "allowed"` y devuelve `allowed: true`, `message: "Acceso permitido"`, `studentName`, `grade`, `group`.

- **Respuesta 200 (JSON):**
  - `allowed` (bool)
  - `message` (string)
  - `studentName` (string)
  - `grade` (string)
  - `group` (string)

- **Respuesta 400:** body inválido o `token` vacío.

La app Flutter usa estos campos en `ScanResult` y los muestra en `ResultScreen` (verde/confetti si `allowed`, rojo si no).

---

## 4. Cómo probar la integración

### 4.1 Requisitos

- Backend SchoolManager corriendo (ej. `http://localhost:5172` o IP de tu PC en la red).
- BD con al menos un estudiante que tenga:
  - Carné generado (token en `student_qr_tokens`).
  - Asignación activa (`student_assignments` con `is_active = true` y grado/grupo).
- App Flutter en `C:\src\schoolmanager_id_scanner` con `localUrl` apuntando al backend.

### 4.2 Configurar la URL en la app Flutter

En `C:\src\schoolmanager_id_scanner\lib\services\id_card_api.dart`:

- **Dispositivo físico en la misma red:** pon la IP de tu PC (ej. `http://192.168.0.8:5172`). Obtener IP: `ipconfig` (Windows) y usar la IPv4 de la interfaz activa.
- **Emulador Android:** usa `http://10.0.2.2:5172` (10.0.2.2 = localhost del host desde el emulador).
- **Producción:** `useLocalhost = false` y `productionUrl = "https://eduplaner.net"` (o la URL real).

### 4.3 Probar solo el backend (sin app)

Con PowerShell o Postman:

**Login (para obtener token si luego quieres usarlo en otros endpoints):**
```powershell
$body = '{"email":"admin@tuescuela.com","password":"TuPassword"}'
Invoke-RestMethod -Uri "http://localhost:5172/api/auth/login" -Method Post -Body $body -ContentType "application/json"
```

**Scan (token válido de un carné generado):**
```powershell
# Sustituir TOKEN_DEL_QR por el valor real (ej. desde student_qr_tokens en la BD)
$body = '{"token":"TOKEN_DEL_QR","scanType":"entry","scannedBy":"00000000-0000-0000-0000-000000000000"}'
Invoke-RestMethod -Uri "http://localhost:5172/StudentIdCard/api/scan" -Method Post -Body $body -ContentType "application/json"
```

**Scan (token inválido, para probar denegación):**
```powershell
$body = '{"token":"token-invalido-123","scanType":"entry","scannedBy":"00000000-0000-0000-0000-000000000000"}'
Invoke-RestMethod -Uri "http://localhost:5172/StudentIdCard/api/scan" -Method Post -Body $body -ContentType "application/json"
```

Debes recibir JSON con `allowed: false` y `message: "QR inválido o expirado"`.

### 4.4 Probar con la app Flutter

1. Arrancar el backend (ej. `dotnet run` en SchoolManager con `ASPNETCORE_ENVIRONMENT=Development`).
2. Ajustar `localUrl` en `id_card_api.dart` (IP o 10.0.2.2 para emulador).
3. Ejecutar la app: `cd C:\src\schoolmanager_id_scanner` y `flutter run`.
4. **Login:** iniciar sesión con un usuario válido (Admin/Director para poder generar carnés).
5. **Generar un carné (desde el backend web):** en el navegador, ir a Carnés / Generar para un estudiante que tenga asignación activa. Así se crea/actualiza el token en `student_qr_tokens`.
6. **Escanear:** en la app, abrir la cámara y escanear el QR del carné (o uno de prueba que contenga un token válido). Debe aparecer la pantalla de resultado (verde con nombre/grado/grupo si es válido, rojo si no).
7. **Comprobar registro:** en la BD, revisar la tabla `scan_logs`: debe haber una fila por cada escaneo con `scan_type`, `result` (allowed/denied), `scanned_at`, etc.

### 4.5 Obtener un token de prueba desde la BD

Si quieres probar el scan sin imprimir el carné:

```sql
SELECT token FROM student_qr_tokens WHERE is_revoked = false AND (expires_at IS NULL OR expires_at > NOW()) LIMIT 1;
```

Usa ese valor en el body de `POST /StudentIdCard/api/scan` como `"token": "valor_copiado"` o escanea un QR que contenga ese mismo texto.

---

## 5. Resumen de flujo

1. **App:** Usuario inicia sesión → `POST /api/auth/login` → guarda token.
2. **App:** Usuario escanea QR del carné → lee `token` del código.
3. **App:** `POST /StudentIdCard/api/scan` con `{ token, scanType, scannedBy }`.
4. **Backend:** Busca token en `student_qr_tokens`, valida estudiante y asignación, escribe en `scan_logs`, devuelve `allowed`, `message`, `studentName`, `grade`, `group`.
5. **App:** Muestra `ResultScreen` (éxito o denegado) según `allowed`.

---

## 6. Errores frecuentes

| Síntoma | Revisar |
|--------|--------|
| App no conecta al backend | Firewall, URL en `id_card_api.dart`, que el backend esté en 5172 (o el puerto configurado). |
| Login 401 | Usuario/contraseña en la BD; que el usuario no esté inactivo y que la escuela esté activa. |
| Scan siempre "QR inválido" | Que el estudiante tenga carné generado (token en `student_qr_tokens`), que el token no esté revocado ni expirado, y que el valor escaneado sea exactamente el mismo que en la BD. |
| Scan "Estudiante sin asignación activa" | Que exista una fila en `student_assignments` con `is_active = true` para ese estudiante y con grado/grupo. |
