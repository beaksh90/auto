@echo off
setlocal

set SERVICE_NAME=DGServer_OBS_M

sc delete "%SERVICE_NAME%"