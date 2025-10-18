@echo off
echo ========================================================
echo CARGANDO DATOS DUMMY CORREGIDOS EN DB LOCAL
echo ========================================================
pause
set PGPASSWORD=Panama2020$
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d schoolmanagement -f CargarDatosDummyLocal_Corregido.sql
pause
