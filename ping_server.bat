@echo off
setlocal enabledelayedexpansion

REM Find the PID of the server window by its title
for /f "tokens=2 delims=," %%a in ('tasklist /v /fo csv ^| findstr /i "server_screen"') do set PID=%%a

REM Check if the PID was found
if "%PID%"=="" (
    echo [ERROR] Could not find the server running in start.bat
    exit /b 1
)

echo [INFO] Found server with PID: %PID%
echo [INFO] Sending "say TEST" command to the server every 5 seconds.

:loop
REM Send the "say TEST" command to the server
echo [INFO] Pinging server...
call echo say TEST | tasklist /fi "PID eq %PID%" | find /i "cmd.exe"

REM Wait for 5 seconds
timeout /t 5 > nul

REM Repeat the loop
goto loop

echo [INFO] Out of ping loop
endlocal
pause
