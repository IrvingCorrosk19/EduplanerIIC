@echo off
echo Verificando asignaciones completas en Render...
set PGPASSWORD=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks -f VerificarAsignacionesCompletas.sql
pause
