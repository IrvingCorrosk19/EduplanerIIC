@echo off
echo Conectando a Render usando conexion interna...
set PGPASSWORD=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a -U admin -d schoolmanagement_xqks -f ScriptCompletoRender_Final.sql
pause
