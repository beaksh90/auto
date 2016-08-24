set WORKING_DIR=%~dp0
sc create "PlatformJS_OBS(8080)" start=auto  binPath="%WORKING_DIR%mxg_obsd/win64/mxg_obsd_x64.exe -f %WORKING_DIR%config/common.service.conf -i  30 -D -OTHERD"