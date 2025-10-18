@echo off
echo ========================================================
echo CARGANDO DATOS DUMMY EN BASE DE DATOS LOCAL
echo ========================================================
echo.
echo Este script cargara:
echo   - Trimestres (3)
echo   - Areas academicas (5)
echo   - Especialidades (4)
echo   - Niveles de grado (6: 7 al 12)
echo   - Grupos (18: A, B, C por cada nivel)
echo   - Materias (20)
echo   - Tipos de actividad (3)
echo   - Profesores (8)
echo   - Orientadores (2)
echo   - Director (1)
echo   - Estudiantes (50)
echo   - Asignaciones completas
echo   - Actividades (300)
echo   - Calificaciones (1000)
echo.
echo ========================================================
pause
echo.
echo Ejecutando script de carga...
echo.
set PGPASSWORD=Panama2020$
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d schoolmanagement -f CargarDatosDummyLocal.sql
echo.
echo ========================================================
echo PROCESO COMPLETADO
echo ========================================================
pause
