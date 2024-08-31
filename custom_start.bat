@echo off
setlocal

REM Start the server in a new window
start "server_screen" cmd /c "call start.bat"
REM Give the server some time to start

REM Run the backup script
@REM call backup.bat
@REM call ping_server.bat

pause
endlocal