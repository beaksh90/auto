@echo off

setlocal
set service_port=8080

net start PlatformJS(%service_port%)

