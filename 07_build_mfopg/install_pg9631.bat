set PG_ROOT_HOME=C:\Database
rem set PG_HOME=%PG_ROOT_HOME%\pg94\bin
rem set PGDATA=%PG_ROOT_HOME%\data\pg94
set PG_HOME=%PG_ROOT_HOME%\pg96\bin
set PGDATA=%PG_ROOT_HOME%\data\pg96
set PGPASSWORD=postgres
set CONFDIR=C:\Multi-Runner\mfobuild\07_build_mfopg
rem PostgreSQL-9.4.10-1-win64-bigsql.exe --mode unattended --unattendedmodeui minimal --disable-components bam2 --enable-components pgAdmin --prefix "%PG_ROOT_HOME%" --pgdatadir  "%PGDATA%" --password postgres --pgservicename "PostgreSQL" --pgfreeport 5432 --locale C
PostgreSQL-9.6.3-1-win64-bigsql.exe --mode unattended --unattendedmodeui minimal --disable-components bam4 --enable-components pgAdmin --installdir "%PG_ROOT_HOME%" --pgdatadir  "%PGDATA%" --password postgres --pgport 5432 --locale C --devopsUser maxgauge  --devopsPassword maxgauge
cd %PG_HOME%
initdb.exe -D "%PGDATA%" --username=postgres --locale C --encoding UTF8
cp %CONFDIR%\pg9631\pg_hba.conf %PGDATA%\pg_hba.conf
cp %CONFDIR%\pg9631\postgresql.conf %PGDATA%\postgresql.conf
pg_ctl.exe register -N "PostgreSQL" -D "%PGDATA%"
sc start PostgreSQL
createuser.exe -s -U postgres
psql.exe -p 5432 -U postgres -c "alter user postgres password 'postgres'";
createdb.exe --host=localhost  --encoding UTF8 --port=5432 --username=postgres MFO

rem --mode unattended