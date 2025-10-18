@echo off
echo Verificando y completando notas para TODOS los estudiantes...
set PGPASSWORD=2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com -U admin -d schoolmanagement_xqks -f VerificarYCompletarNotas.sql
pause
