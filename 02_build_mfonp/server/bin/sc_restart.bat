@echo off

rem 서비스 이름이 바뀔 경우 서비스 이름만 변경하면 됨.
rem            서비스이름
setlocal
set service_port=8080

net stop PlatformJS(%service_port%)  && net start PlatformJS(%service_port%)
