@echo off

rem ���� �̸��� �ٲ� ��� ���� �̸��� �����ϸ� ��.
rem            �����̸�
setlocal
set service_port=8080

net stop PlatformJS(%service_port%)  && net start PlatformJS(%service_port%)
