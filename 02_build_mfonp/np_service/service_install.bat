@echo off
rem ############# set.bat start ##########################################

rem set the version of jdk you would like to use (1.4, 1.5, 1.6, etc)
set JDK_Version=1.8

rem echo.
rem echo Locating JDK %JDK_Version%

for /d %%i in ("%ProgramFiles%\Java\jdk%jdk_Version%*") do (set Located=%%i)
rem check if JDK was located
if "%Located%"=="" goto else
rem if JDK located display message to user
rem update %JAVA_HOME%
set JAVA_HOME=%Located%
rem echo     Located JDK %jdk_Version%
rem echo     JAVA_HOME has been set to:
rem echo         %JAVA_HOME%
goto endif

:else
rem if JDK was not located
rem if %JAVA_HOME% has been defined then use the existing value
echo     Could not locate JDK %JDK_Version%
if "%JAVA_HOME%"=="" goto NoExistingJavaHome
rem echo     Existing value of JAVA_HOME will be used:
rem echo         %JAVA_HOME%
goto endif

:NoExistingJavaHome
rem display message to the user that %JAVA_HOME% is not available
rem echo     No Existing value of JAVA_HOME is available
goto endif

:endif
rem clear the variables used by this script
set JDK_Version=
set Located=
rem ############# set.bat end ##########################################

IF EXIST "%PROGRAMFILES(X86)%" (
set OSBIT=64
)ELSE (
set OSBIT=32
)
echo %OSBIT%


set HOME_DIR=%cd%
set JAVA_HOME=%JAVA_HOME%
set JETTY_PORT=8080
set PRODUCT=MFO

set SERVICE_NAME=PlatformJS(%JETTY_PORT%)
set JETTY_HOME=%HOME_DIR%\bin\jetty
set JETTY_BASE=%HOME_DIR%\svc
set STOPKEY=secret
set STOPPORT=58081
set PR_INSTALL=%HOME_DIR%\app\%OSBIT%\prunsrv.exe
set JETTY_TEMP=%HOME_DIR%\jetty_tmp
set USER_TEMP_LOCAL=%HOME_DIR%\tmp
set USER_TEMP_WWW=%HOME_DIR%\svc\www\download
set USER_LOG_PATH=%HOME_DIR%\log

@REM Service Log Configuration
set PR_LOGPREFIX=%SERVICE_NAME%
@REM set PR_LOGPATH=%HOME_DIR%\svc\service_log
set PR_LOGPATH=%USER_LOG_PATH%
set PR_STDOUTPUT=auto
set PR_STDERROR=auto
set PR_LOGLEVEL=Debug
@REM Path to Java Installation
set PR_JVM=%JAVA_HOME%\jre\bin\server\jvm.dll
set PR_CLASSPATH=%JETTY_HOME%\start.jar;%JAVA_HOME%\lib\tools.jar

 
@REM JVM Configuration
set PR_JVMMS=1024
set PR_JVMMX=1024
set PR_JVMSS=4000

@REM set PR_JVMOPTIONS=-Duser.dir="%JETTY_BASE%";-Djava.io.tmpdir="%JETTY_TEMP%";-Djetty.home="%JETTY_HOME%";-Djetty.base="%JETTY_BASE%"
set PR_JVMOPTIONS=-Duser.log.path=%USER_LOG_PATH%;-Duser.tmp.local=%USER_TEMP_LOCAL%;-Duser.tmp.www=%USER_TEMP_WWW%;-Djetty.port=%JETTY_PORT%;-Djava.util.Arrays.useLegacyMergeSort=true;-Duser.region=US;-Duser.language=en;-Duser.country=US;-Dfile.encoding=UTF-8;-Djava.io.tmpdir="%JETTY_TEMP%";-Djetty.home="%JETTY_HOME%";-Djetty.base="%JETTY_BASE%";-Duser.dir="%JETTY_BASE%";-Duser.product="%PRODUCT%";

@REM Startup Configuration
set JETTY_START_CLASS=org.eclipse.jetty.start.Main

set PR_STARTUP=auto
set PR_STARTMODE=java
set PR_STARTCLASS=%JETTY_START_CLASS%
set PR_STARTPARAMS=STOP.KEY="%STOPKEY%";STOP.PORT=%STOPPORT%

@REM Shutdown Configuration 
set PR_STOPMODE=java
set PR_STOPCLASS=%JETTY_START_CLASS%
set PR_STOPPARAMS=--stop;STOP.KEY="%STOPKEY%";STOP.PORT=%STOPPORT%;STOP.WAIT=10

"%PR_INSTALL%" //IS/%SERVICE_NAME% ^
 --DisplayName="Exem_%SERVICE_NAME%" ^
 --Install="%PR_INSTALL%" ^
 --Startup="%PR_STARTUP%" ^
 --LogPath="%PR_LOGPATH%" ^
 --LogPrefix="%PR_LOGPREFIX%" ^
 --LogLevel="%PR_LOGLEVEL%" ^
 --StdOutput="%PR_STDOUTPUT%" ^
 --StdError="%PR_STDERROR%" ^
 --JavaHome="%JAVA_HOME%" ^
 --Jvm="%PR_JVM%" ^
 --JvmMs="%PR_JVMMS%" ^
 --JvmMx="%PR_JVMMX%" ^
 --JvmSs="%PR_JVMSS%" ^
 --JvmOptions="%PR_JVMOPTIONS%" ^
 --Classpath="%PR_CLASSPATH%" ^
 --StartMode="%PR_STARTMODE%" ^
 --StartClass="%JETTY_START_CLASS%" ^
 --StartParams="%PR_STARTPARAMS%" ^
 --StopMode="%PR_STOPMODE%" ^
 --StopClass="%PR_STOPCLASS%" ^
 --StopParams="%PR_STOPPARAMS%"

@REM echo "%PR_INSTALL%" //IS/%SERVICE_NAME%  --DisplayName="%SERVICE_NAME%"   --Install="%PR_INSTALL%"   --Startup="%PR_STARTUP%"   --LogPath="%PR_LOGPATH%"   --LogPrefix="%PR_LOGPREFIX%"   --LogLevel="%PR_LOGLEVEL%"  --StdOutput="%PR_STDOUTPUT%"   --StdError="%PR_STDERROR%"   --JavaHome="%JAVA_HOME%"   --Jvm="%PR_JVM%"   --JvmMs="%PR_JVMMS%"   --JvmMx="%PR_JVMMX%"   --JvmSs="%PR_JVMSS%"   --JvmOptions="%PR_JVMOPTIONS%"   --Classpath="%PR_CLASSPATH%" ^ --StartMode="%PR_STARTMODE%"   --StartClass="%JETTY_START_CLASS%"   --StartParams="%PR_STARTPARAMS%"  --StopMode="%PR_STOPMODE%"  --StopClass="%PR_STOPCLASS%"  --StopParams="%PR_STOPPARAMS%"

sc start %SERVICE_NAME%

if not errorlevel 1 goto installed
echo Failed to install "%SERVICE_NAME%" service. Refer to log in %PR_LOGPATH%
goto end

:installed
echo The Service "%SERVICE_NAME%" has been installed

:end
