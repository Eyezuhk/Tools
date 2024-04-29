@echo off
set "desktop=%USERPROFILE%\Desktop"
powercfg /batteryreport /output "%desktop%\battery-report.html"
