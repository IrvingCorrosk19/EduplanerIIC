@echo off
echo ========================================================
echo GENERANDO NOTAS PARA USUARIOS EXISTENTES EN RENDER
echo ========================================================
echo.
echo Este script generara:
echo   - Mas actividades para todos los trimestres
echo   - Calificaciones para TODOS los estudiantes existentes
echo   - Distribucion realista de aprobados y reprobados
echo.
echo ========================================================
pause
echo.
echo Conectando a Render y ejecutando script...
echo.
set PGPASSWORD=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks -f GenerarNotasUsuariosExistentesRender.sql
echo.
echo ========================================================
echo PROCESO COMPLETADO
echo ========================================================
pause
