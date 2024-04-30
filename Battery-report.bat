@echo off
set "downloads=%USERPROFILE%\Downloads"
powercfg /batteryreport /output "%downloads%\battery-report.html"
pause
