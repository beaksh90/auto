set PG_ROOT_HOME=C:\Database
set PG_HOME=%PG_ROOT_HOME%\pg94\bin
set PGDATA=%PG_ROOT_HOME%\data\pg94
sc stop PostgreSQL
sc delete PostgreSQL

%PG_ROOT_HOME%\uninstall\uninstall.exe --mode unattended 
rm -rf %PG_ROOT_HOME%