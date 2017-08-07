@ECHO OFF
REM pg engine, 경로설정
SET PGPATH=G:\EXEM\bin

%PGPATH%\psql --host 127.0.0.1 --port 5432 --username postgres -d MFO -f %PGPATH%\age_check.sql >>%PGPATH%\age_check.log
