@echo off
echo Generando calificaciones para TODOS con tipos nuevos (corregido)...
set PGPASSWORD=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks -f GenerarCalificacionesTodosCorregido.sql
pause
