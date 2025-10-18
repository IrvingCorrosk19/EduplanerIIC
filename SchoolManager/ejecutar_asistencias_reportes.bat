@echo off
echo ========================================================
echo GENERANDO ASISTENCIAS Y REPORTES EN RENDER
echo ========================================================
pause
set PGPASSWORD=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks -f GenerarAsistenciasYReportesRender.sql
pause
