@ECHO OFF 
SETLOCAL
TITLE EXEM

PUSHD %~DP0

call ./app/set.bat 

set config_path=./config/config.json
set service_port=8080
set debug_mode=info
set work_dir=%~dp0

for /f "tokens=1,2 delims=:, " %%a in (' find ":" ^< %config_path% ') do (
	if "service_port"==%%a set service_port=%%~b
	if "debug_mode"==%%a set debug_mode=%%~b
)

set /a stop_port=%service_port% + 50001

@ECHO "PlatformJS(%service_port%)" service stopping.
@ECHO ===============================================
"%JAVA_HOME%"\bin\java -jar %cd%/bin/jetty/start.jar --stop STOP.KEY="secret" STOP.PORT=%stop_port% STOP.WAIT=10 
@ECHO ===============================================
@ECHO "PlatformJS(%service_port%)" service stop.

