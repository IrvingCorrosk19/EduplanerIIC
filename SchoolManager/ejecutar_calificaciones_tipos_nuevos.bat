@echo off
echo ========================================================
echo GENERANDO CALIFICACIONES CON TIPOS NUEVOS EN RENDER
echo ========================================================
echo.
echo Tipos de actividades:
echo   1. Notas de apreciacion
echo   2. Ejercicios diarios
echo   3. Examen Final
echo.
echo Logica de calculo:
echo   - Promedio por tipo
echo   - Promedio final = (Prom1 + Prom2 + Prom3) / 3
echo.
echo ========================================================
pause
set PGPASSWORD=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks -f GenerarCalificacionesConTiposNuevos.sql
pause
