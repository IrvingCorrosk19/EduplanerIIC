@echo off
echo Verificando datos para TeacherGradebook...
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -d schoolmanagement -U postgres -f VerificarTeacherGradebook.sql
pause
