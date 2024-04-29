@echo off
set "desktop=%USERPROFILE%\Downloads"
powercfg /batteryreport /output "%desktop%\battery-report.html"
pause
