@echo off
call ./app/set.bat
"%JAVA_HOME%"\bin\java -jar "%cd%"/bin/jetty/start.jar --stop STOP.KEY="secret" STOP.PORT=58081 STOP.WAIT=10
sc stop PlatformJS(8080)
@echo on
sc delete PlatformJS(8080)
