@echo off
setlocal enabledelayedexpansion

REM Move into the directory with all Windows-Minecraft-Scripts
cd /d "%~dp0"

REM Read configuration file
for /f "tokens=1,2 delims==" %%i in (config.cfg) do (
    set %%i=%%j
)

REM Set script Directory
set SHDIR=%cd%

REM *-------------------------* SCRIPT *-------------------------*

cd %MCDIR%

REM Set today's backup dir
if %LOGIT%==1 (
    echo %date% %time% [LOG] Starting AutoBackup Script..
    echo %date% %time% [LOG] Working in directory: %cd%.
)

set BACKUPDATE=%date:~-4%-%date:~4,2%-%date:~7,2%
set FINALDIR=%BACKUPDIR%\%BACKUPDATE%

if %LOGIT%==1 (
    echo %date% %time% [LOG] Checking if backup folders exist, if not then create them.
)

if not exist %BACKUPDIR% (
    mkdir "%BACKUPDIR%"
    if %LOGIT%==1 (
        echo %date% %time% [LOG] Created Folder: %BACKUPDIR%
    )
)

if not exist "%FINALDIR%" (
    mkdir "%FINALDIR%"
    if %LOGIT%==1 (
        echo %date% %time% [LOG] Created Folder: %FINALDIR%
    )
)

if %OLDBACKUPS% LSS 0 (
    set OLDBACKUPS=3
)

REM Deletes backups that are 'n' days old
if %LOGIT%==1 (
    echo %date% %time% [LOG] Removing backups older than 3 days.
)

forfiles /p %BACKUPDIR% /d -%OLDBACKUPS% /c "cmd /c rd /s /q @path"

REM Get level-name
if %LOGIT%==1 (
    echo %date% %time% [LOG] Fetching Level Name..
)

for /f "tokens=1,2 delims==" %%i in (%PROPFILE%) do (
    if "%%i"=="level-name" set WORLD=%%j
)

if %LOGIT%==1 (
    echo %date% %time% [LOG] Level-Name is %WORLD%
)

set BFILE=%WORLD%.%STAMP%.tar.gz
set CMD="tar -czf %FINALDIR%\%BFILE% %WORLD%"
set BFILEC=config.%STAMP%.tar.gz
set CMDC="tar -czf %FINALDIR%\%BFILEC% config"

if %LOGIT%==1 (
    echo %date% %time% [LOG] Packing and compressing folder: %WORLD% to tar file: %FINALDIR%\%BFILE%
    echo %date% %time% [LOG] Packing and compressing folder: config to tar file: %FINALDIR%\%BFILEC%
)

REM Find the server window by its title
for /f "tokens=2 delims=," %%a in ('tasklist /v /fo csv ^| findstr /i "start.bat"') do set PID=%%a

if %NOTIFY%==1 (
    call echo say Backing up world: '%WORLD%' Server go in readonly | tasklist /fi "PID eq %PID%" | find /i "cmd.exe"
)

REM Put the server in readonly mode to reduce the chance of backing up half of a chunk.
call echo save-off | tasklist /fi "PID eq %PID%" | find /i "cmd.exe"

REM Send save-all to the console
if %AUTOSAVE%==1 (
    call echo save-all | tasklist /fi "PID eq %PID%" | find /i "cmd.exe"
    timeout /t 2 > nul
)

REM Run backup command
%CMD%
%CMDC%
call echo save-on | tasklist /fi "PID eq %PID%" | find /i "cmd.exe"

if %NOTIFY%==1 (
    call echo say Backup Completed. | tasklist /fi "PID eq %PID%" | find /i "cmd.exe"
)

REM --Cron Job Install--

cd %SHDIR%

if %CRONJOB%==1 (

    REM Work out crontime
    if %UPDATEHOURS%==0 set MINS=* & set HOURS=*
    if %UPDATEHOURS% LSS 0 set MINS=* & set HOURS=*
    if %UPDATEHOURS% GTR 0 set MINS=0 & set HOURS=%%/%UPDATEHOURS%

    REM Check if cronjob exists, if not then create.
    schtasks /query /tn "MinecraftBackup" > nul 2>&1
    if errorlevel 1 (
        schtasks /create /tn "MinecraftBackup" /tr "%cd%\%~nx0" /sc hourly /mo %UPDATEHOURS%
        echo Autobackup has been installed.
    ) else (
        echo Cronjob already exists.
    )

    exit
)

endlocal
