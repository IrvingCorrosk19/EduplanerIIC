@echo off
echo ========================================================
echo LIMPIANDO BASE DE DATOS LOCAL
echo ========================================================
echo.
echo Este script eliminara TODOS los datos excepto:
echo   - Usuarios Admin/SuperAdmin
echo   - Configuraciones de Email
echo   - Escuelas
echo   - Logs de Auditoria
echo.
echo ========================================================
pause
echo.
echo Ejecutando script de limpieza...
echo.
set PGPASSWORD=Panama2020$
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d schoolmanagement -f LimpiarDBLocalConservandoConfig.sql
echo.
echo ========================================================
echo PROCESO COMPLETADO
echo ========================================================
pause
