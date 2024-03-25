@echo off
echo Deleting empty directories that are not system-related...

rem Define the temporary file to store deleted directories
set "tempfile=%temp%\exclusions.tmp"

rem Clear the temporary file
echo. > "%tempfile%"

rem Loop to delete empty directories that are not system-related
for /f "tokens=*" %%d in ('dir /ad /b /s ^| findstr /v /i /c:"$" ^| sort /R') do (
    rem Attempt to delete the directory. If deletion is successful, log it in the temporary file.
    rd "%%d" 2>nul && (
        echo Directory deleted: "%%d" >> "%tempfile%"
    )
)

rem Display only the deleted directories
type "%tempfile%"

rem Clear the temporary file
del "%tempfile%" 2>nul

echo.
echo Press any key to exit...
pause >nul
