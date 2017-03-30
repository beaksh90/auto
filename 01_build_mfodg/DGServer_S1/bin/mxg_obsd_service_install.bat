@echo off
setlocal

set SERVICE_NAME=DGServer_OBS_S1
set DIR=%~dp0

cd %DIR%
%DIR:~0,2%
cd ..

set WORKING_DIR=%cd%\

IF EXIST "%PROGRAMFILES(X86)%" (
sc create "%SERVICE_NAME%" DisplayName= "Exem_%SERVICE_NAME%" start=auto  binPath="%WORKING_DIR%bin\mxg_obsd\win64\mxg_obsd_x64.exe -f %WORKING_DIR%conf\DG\common.conf -i 10 -D -OTHERD"
)ELSE (
sc create "%SERVICE_NAME%" DisplayName= "Exem_%SERVICE_NAME%" start=auto  binPath="%WORKING_DIR%bin\mxg_obsd\win32\mxg_obsd.exe -f %WORKING_DIR%conf\DG\common.conf -i 10 -D -OTHERD"
)