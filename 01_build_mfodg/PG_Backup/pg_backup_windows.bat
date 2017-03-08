@ECHO OFF
REM pg engine, 경로설정
SET PGPATH=""
SET SCRIPT_PATH=
SET OUTPUT_PATH=

REM pg 접속정보 설정
SET PGIP=127.0.0.1
SET pgport=5432
SET PGUSER=postgres
SET PGPASS=postgres
SET DBNAME=MFO



set ARG1=%1
set ARG2=%2

if "%ARG1%"=="" (call :sub_mainmenu) 

if %ARG1% leq 5 ( 
	if %ARG1% geq 1 (
		if %ARG1%==1 call :sub_menu1
		if %ARG1%==2 call :sub_menu2
	)
)else echo Invalid Argument [1~5]

goto :eof

:sub_mainmenu
echo.
echo *** Select Menu [Interactive Mode]
echo -------------------------------------------------
echo 1. Full Backup 
echo 2. Daily Backup 
echo 3. Export
echo 4. Restore
echo 5. Exit
echo.

set /p MENU1="Select Number :"
echo go to %MENU1%
echo.
goto :sub_menu%MENU1%


:sub_menu1
echo.
echo *** Select Instance List [Interactive Mode]
echo -------------------------------------------------
%PGPATH%\psql --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select db_id,instance_name from apm_db_info order by db_id;"  

if "%ARG2%"=="" (set /p SMENU1= "- Select Number of Instance For Backup (Type [all] for All Instances)  :") else (set SMENU1=%ARG2%)

if "%SMENU1%"=="all" (
	echo %SMENU1%
	%PGPATH%\pg_dump.exe --verbose --host %PGIP% --port %PGPORT% --username %PGUSER% --no-password --format custom --encoding UTF8 --file "%OUTPUT_PATH%\Full_Backup.backup" %DBNAME%
) else ( %PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select instance_name from apm_db_info where db_id=%SMENU1%;"  > %SCRIPT_PATH%\temp0.txt
	FOR /f %%i IN (%SCRIPT_PATH%\temp0.txt) do SET INSTANCE_NAME=%%i
	echo.
	echo.
	del %SCRIPT_PATH%\temp0.txt
)
if not "%SMENU1%"=="all" (
	%PGPATH%\pg_dump.exe --verbose --host %PGIP% --port %PGPORT% --username %PGUSER% -n %INSTANCE_NAME% --no-password --format custom --encoding UTF8 --file "%OUTPUT_PATH%\Full_Backup_public.backup" %DBNAME%
	%PGPATH%\pg_dump.exe --verbose --host %PGIP% --port %PGPORT% --username %PGUSER% -n %INSTANCE_NAME% --no-password --format custom --encoding UTF8 --file "%OUTPUT_PATH%\Full_Backup_%INSTANCE_NAME%.backup" %DBNAME%
)
goto :eof


:sub_menu2
echo.
echo *** Select Instance List [Daily Backup]
echo -------------------------------------------------
%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select db_id,instance_name from apm_db_info order by db_id;" 
 
if "%ARG2%"=="" (set /p SMENU2= "- Select Number of Instance For Daily Backup (Type [all] for All Instances)  :") else (set SMENU2=%ARG2%)

 %PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c  "select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date - 1) order by 1 desc limit 1" > %SCRIPT_PATH%\YDATE.txt
 FOR /f %%t IN (%SCRIPT_PATH%\YDATE.txt) do set YDATE=%%t

if "%SMENU2%"=="all" (
	echo %SMENU2%
	%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select 'test'||' '||string_agg(tablename,' ') from (select ('--table'||' '||schemaname||'.'||tablename) as tablename,schemaname from pg_tables where tableowner='postgres' and tablename not like ('%%p1%%') and schemaname not in ('pg_catalog','information_schema','public') union all select ('--table'||' '||schemaname||'.'||tablename) as tablename,schemaname from pg_tables where tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') = current_date - 1)) a" >> %SCRIPT_PATH%\temp1.txt
	type %SCRIPT_PATH%\temp1.txt
	FOR /f "tokens=1 delims=*" %%j IN (%SCRIPT_PATH%\temp1.txt) do %PGPATH%\pg_dump.exe --verbose --host %PGIP% --port %PGPORT% --username %PGUSER% --no-password --format custom --encoding UTF8 --file "%OUTPUT_PATH%\Daily_%YDATE%_Backup.backup" --table %%j %DBNAME%
REM	del %SCRIPT_PATH%\temp1.txt
) else ( %PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select instance_name from apm_db_info where db_id=%SMENU2%;"  >> %SCRIPT_PATH%\temp0.txt
	FOR /f  %%j IN (%SCRIPT_PATH%\temp0.txt) do SET INSTANCE_NAME=%%j
	echo.
	echo.
)
if not "%SMENU2%"=="all" (
	%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% --no-password -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.instance_name ='%INSTANCE_NAME%') a;" >> %SCRIPT_PATH%\temp2.txt
	%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% --no-password -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') = current_date - 1) and b.instance_name ='%INSTANCE_NAME%')  a;" >> %SCRIPT_PATH%\temp2.txt
	FOR /f "tokens=1 delims=*" %%k IN (%SCRIPT_PATH%\temp2.txt) do %PGPATH%\pg_dump.exe --verbose --host %PGIP% --port %PGPORT% --username %PGUSER% --no-password --format custom --encoding UTF8 --file "%OUTPUT_PATH%\Daily_%YDATE%_%INSTANCE_NAME%.backup" --table %%k %DBNAME%
REM	del %SCRIPT_PATH%\temp0.txt
REM	del %SCRIPT_PATH%\temp2.txt
REM	del %SCRIPT_PATH%\YDATE.txt
)	
goto :eof


:sub_menu3
echo.
echo *** Select Instance List [Export Backup]
echo -------------------------------------------------
%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select db_id,instance_name from apm_db_info order by db_id;" 

if "%ARG2%"=="" (set /p SMENU3= "- Select Instance for Export  : ") else (set SMENU3=%ARG2%)
echo %SMENU3%
echo *** Available Date [Export Backup]
echo -------------------------------------------------
%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select string_agg(num,' ') from (select rownum||'.'||date as num from (select row_number() over() as rownum,a.date from (select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date - 1) and b.db_id =%SMENU3% order by 1)a)b)c;" > %SCRIPT_PATH%\edate.txt
%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select rownum||'.'||date as num from (select row_number() over() as rownum,a.date from (select distinct(substring(tablename,length(tablename)-8,6)) as date from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and to_date(substring(tablename,length(tablename)-8,6),'yymmdd') <= current_date - 1) and b.db_id =%SMENU3% order by 1)a)b;" > %SCRIPT_PATH%\sdate.txt > %SCRIPT_PATH%\eedate.txt
type %SCRIPT_PATH%\eedate.txt	
set /p ENUM= "Select Export for Date : (ex 160620) :"
set /a NUM=%ENUM%
echo %NUM%
FOR /f "tokens=%NUM% delims= " %%p IN (%SCRIPT_PATH%\edate.txt) do SET EDATE=%%p
echo %EDATE%
set EDATE=%EDATE:~-6%
echo %EDATE%
%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||schemaname||'.'||tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and tableowner='postgres' and tablename in (select tablename from pg_tables where tablename like ('%%p1%%') and substring(tablename,length(tablename)-8,6) like '%EDATE%' and b.db_id = %SMENU3%)) a;" >> %SCRIPT_PATH%\temp3.txt"
%PGPATH%\psql.exe --host %PGIP% --port %PGPORT% --username %PGUSER% -t -d %DBNAME% -c "select 'test'||' '||string_agg(tablename,' ') from(select ('--table'||' '||a.schemaname||'.'||a.tablename) as tablename from pg_tables a, apm_db_info b where b.instance_name =upper(a.schemaname) and a.tableowner='postgres' and a.tablename not like ('%%p1%%') and a.schemaname not in ('pg_catalog','information_schema','public') and b.db_id = %SMENU3%) a;" >> %SCRIPT_PATH%\temp3.txt"
FOR /f "tokens=1 delims=*" %%k IN (%SCRIPT_PATH%\temp3.txt) do %PGPATH%\pg_dump.exe --verbose --host %PGIP% --port %PGPORT% --username %PGUSER% --no-password --format custom --encoding UTF8 --file "%OUTPUT_PATH%\Daily_DBID_%SMENU3%_%EDATE%.backup" --table %%k %DBNAME%
	del %OUTPUT_PATH%\eedate.txt
	del %OUTPUT_PATH%\edate.txt
	del %OUTPUT_PATH%\temp3.txt

goto :sub_mainmenu



:sub_menu4
echo.
echo *** [Restore List]
echo -------------------------------------------------
dir /b %OUTPUT_PATH%
set /p FILE="Enter Restore file_name :"
echo %FILE% restore....... 

	%PGPATH%\pg_restore.exe -h %PGIP% -p %PGPORT% -U %PGUSER% --no-password -w -d %DBNAME% -v %OUTPUT_PATH%\%FILE%

echo "Restore Finish"
goto :sub_menu1


:sub_menu5
echo Bye
@echo off
exit