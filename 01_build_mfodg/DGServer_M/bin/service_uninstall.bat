@echo off
setlocal

set SERVICE_NAME=DGServer_M
set WORKING_DIR=%~dp0

IF EXIST "%PROGRAMFILES(X86)%" (
set OSBIT=_x86_64.exe
)ELSE (
set OSBIT=_x86.exe
)

%WORKING_DIR%%SERVICE_NAME%%OSBIT% /uninstall