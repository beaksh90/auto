@echo off
setlocal

set SERVICE_NAME=DGServer_OBS_M
set DIR=%~dp0

cd %DIR%
%DIR:~0,2%
cd ..

set WORKING_DIR=%cd%\

IF EXIST "%PROGRAMFILES(X86)%" (
copy %WORKING_DIR%bin\mxg_obsd\win64\mxg_obsd_x64.exe %WORKING_DIR%bin
sc create "%SERVICE_NAME%" DisplayName= "Exem_%SERVICE_NAME%" start= auto  binPath= "%WORKING_DIR%bin\mxg_obsd_x64.exe -f %WORKING_DIR%conf\DG\common.conf -i 10 -D -OTHERD"
)ELSE (
copy %WORKING_DIR%bin\mxg_obsd\win32\mxg_obsd.exe %WORKING_DIR%bin
sc create "%SERVICE_NAME%" DisplayName= "Exem_%SERVICE_NAME%" start= auto  binPath= "%WORKING_DIR%bin\mxg_obsd.exe -f %WORKING_DIR%conf\DG\common.conf -i 10 -D -OTHERD"
)