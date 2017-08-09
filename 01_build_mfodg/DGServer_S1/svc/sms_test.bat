@echo off
echo ### SMS 전송 테스트 ###
echo.
echo.
set DIR=%~sdp0

set REPO_JDBC="%DIR%..\lib\repo.jar"

java -cp "./sms.jar;%REPO_JDBC%" com.exem.mfo.service.sms.XmAlarmMGR test

timeout /t 10