@echo off
echo Conectando a Render y ejecutando script...
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks -f ScriptCompletoRender_Final.sql
pause
