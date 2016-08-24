@echo off
rem            서비스이름

set service_port=8080

net stop PlatformJS(%service_port%)

