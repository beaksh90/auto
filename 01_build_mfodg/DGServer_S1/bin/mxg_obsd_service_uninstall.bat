@echo off
setlocal

set SERVICE_NAME=DGServer_OBS_S1

sc delete "%SERVICE_NAME%"