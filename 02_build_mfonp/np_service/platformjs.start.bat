@ECHO OFF 
SETLOCAL
TITLE EXEM 

call ./app/set.bat

PUSHD %~DP0

set config_path=./config/config.json
set service_port=8080
set work_dir=%~dp0

for /f "tokens=1,2 delims=:, " %%a in (' find ":" ^< %config_path% ') do (
	if "service_port"==%%a set service_port=%%~b	
)

set /a stop_port=%service_port% + 50001

setlocal

if /i "%1" == "-r" goto PROC_RELEASE_MODE 
if /i "%1" == "-d" goto PROC_DEBUG_MODE 

:LOOP1
cls

echo.
echo.
echo		PlatformJS 
echo		Select the operation mode you wish to perform.
echo. 
echo		1. Release Mode ( background execution )
echo		2. Debug Mode ( Console execution )
echo.

set /p NB1= Choose Mode (Enter Key. Default "1") :

if "%NB1%" == ""  goto PROC_RELEASE_MODE 
if "%NB1%" == "1" goto PROC_RELEASE_MODE
if "%NB1%" == "2" goto PROC_DEBUG_MODE



goto LOOP1

:PROC_RELEASE_MODE
echo.
echo		PlatformJS(Release Mode)  Started. 


start "" "%JAVA_HOME%\bin\javaw.exe" ^
-Duser.debug.console=false ^
-Duser.debug.xview_no_groupby=false ^
-Duser.debug.xview_pg_used=true ^
-Xms1024m -Xmx1024m ^
-XX:NewRatio=4 -verbose:gc -XX:+PrintGCDetails ^
-XX:+PrintGCTimeStamps -Xloggc:"%cd%/log/gc.log" ^
-XX:+HeapDumpOnOutOfMemoryError ^
-XX:+UseParNewGC ^
-XX:+UseConcMarkSweepGC ^
-XX:CMSInitiatingOccupancyFraction=45 ^
-DPJS%service_port% -Duser.product=MFO -Djava.util.Arrays.useLegacyMergeSort=true -DSTOP.PORT=%stop_port% -DSTOP.KEY=secret -Djetty.port=%service_port% -Duser.region=US -Duser.language=en -Duser.country=US -Dfile.encoding=UTF-8  -Djava.io.tmpdir=%work_dir%jetty_tmp -Djetty.home=%work_dir%bin/jetty -Djetty.base=%work_dir%svc -Duser.tmp.local=%work_dir%tmp -Duser.tmp.www=%work_dir%svc/www/download -Duser.log.path=%work_dir%log -Duser.dir=%work_dir%svc -jar %work_dir%bin/jetty/start.jar

goto END

:PROC_DEBUG_MODE
echo.
echo		PlatformJS(Debug Mode)  Started. 

"%JAVA_HOME%"\bin\java ^
-Duser.debug.console=true ^
-Duser.debug.xview_no_groupby=false ^
-Duser.debug.xview_pg_used=true ^
-Xms1024m -Xmx1024m ^
-XX:NewRatio=4 -verbose:gc -XX:+PrintGCDetails ^
-XX:+PrintGCTimeStamps -Xloggc:"%cd%/log/gc.log" ^
-XX:+HeapDumpOnOutOfMemoryError ^
-XX:+UseParNewGC ^
-XX:+UseConcMarkSweepGC ^
-XX:CMSInitiatingOccupancyFraction=45 ^
-DPJS%service_port% -Duser.product=MFO -Djava.util.Arrays.useLegacyMergeSort=true -DSTOP.PORT=%stop_port% -DSTOP.KEY=secret -Djetty.port=%service_port% -Duser.region=US -Duser.language=en -Duser.country=US -Dfile.encoding=UTF-8  -Djava.io.tmpdir=%work_dir%jetty_tmp -Djetty.home=%work_dir%bin/jetty -Djetty.base=%work_dir%svc -Duser.tmp.local=%work_dir%tmp -Duser.tmp.www=%work_dir%svc/www/download -Duser.log.path=%work_dir%log -Duser.dir=%work_dir%svc -jar %work_dir%bin/jetty/start.jar

goto END

:END
if "%1" == "" pause
