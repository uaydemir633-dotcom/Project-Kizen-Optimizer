@echo off
setlocal enabledelayedexpansion
title Project Kizen Optimizer v1.3.1
color 0A

:: ADMINISTRATOR PRIVILEGE CHECK
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script requires ADMINISTRATOR privileges!
    echo Please right-click this file and select "Run as administrator".
    pause
    exit
)

:: LOG (RUNTIME HISTORY) FILE PATHS
set "LOG_QUICK=%~dp0runtime_quick.txt"
set "LOG_DEEP=%~dp0runtime_deep.txt"
set "LOG_FULL=%~dp0runtime_full.txt"

:MENU
cls
set "choice="
echo =======================================================================
echo          PROJECT KIZEN OPTIMIZER - SYSTEM MAINTENANCE MENU (v1.3.1)
echo =======================================================================
echo [1] Quick Cleanup   (Temp, Network, GPU Cache, Event Logs, Telemetry, Browser Cache)
echo [2] Deep Repair     (Restore Point, Update Reset, WER/Dumps, DISM, SFC, Storage)
echo [3] Full Maintenance (Complete execution of options 1 and 2 + Icon Cache)
echo [4] Exit
echo =======================================================================
set /p choice="Please select an option (1-4): "

if "%choice%"=="1" (
    set "ACTION_NAME=QUICK CLEANUP"
    set "LOG_FILE=!LOG_QUICK!"
    goto START_PROCESS
)
if "%choice%"=="2" (
    set "ACTION_NAME=DEEP REPAIR"
    set "LOG_FILE=!LOG_DEEP!"
    goto START_PROCESS
)
if "%choice%"=="3" (
    set "ACTION_NAME=FULL MAINTENANCE"
    set "LOG_FILE=!LOG_FULL!"
    goto START_PROCESS
)
if "%choice%"=="4" exit
goto MENU

:START_PROCESS
cls
echo === STARTING !ACTION_NAME! ===

:: READ RUNTIME HISTORY AND DISPLAY ESTIMATE
if exist "!LOG_FILE!" (
    set /p PREV_TIME=<"!LOG_FILE!"
    set /a MINS=!PREV_TIME!/60
    set /a SECS=!PREV_TIME!%%60
    echo [INFO] Estimated runtime based on history: !MINS!m !SECS!s.
) else (
    echo [INFO] First run detected for this operation. Estimated time unavailable.
    echo [INFO] Execution time will be logged upon completion.
)
echo =======================================================================

:: START TIMER
for /f %%a in ('powershell -nop -c "[long](Get-Date).Ticks"') do set "START_TICKS=%%a"

:: EXECUTE SUBROUTINES
if "!ACTION_NAME!"=="QUICK CLEANUP" (
    call :CLEAN_TEMP
    call :CLEAN_BROWSER_CACHE
    call :RESET_NETWORK
    call :CLEAN_GPU
    call :CLEAN_LOGS
    call :DISABLE_TELEMETRY
)
if "!ACTION_NAME!"=="DEEP REPAIR" (
    call :CREATE_RESTORE_POINT
    call :CLEAN_WER_DUMPS
    call :CLEAN_DELIVERY_OPT
    call :RESET_UPDATE
    call :REPAIR_DISM
    call :REPAIR_SFC
    call :OPTIMIZE_STORAGE
)
if "!ACTION_NAME!"=="FULL MAINTENANCE" (
    call :CREATE_RESTORE_POINT
    call :CLEAN_TEMP
    call :CLEAN_BROWSER_CACHE
    call :CLEAN_GPU
    call :CLEAN_LOGS
    call :CLEAN_WER_DUMPS
    call :CLEAN_DELIVERY_OPT
    call :DISABLE_TELEMETRY
    call :RESET_NETWORK
    call :RESET_UPDATE
    call :REPAIR_DISM
    call :REPAIR_SFC
    call :OPTIMIZE_STORAGE
    call :RESET_ICON_CACHE
)

:: STOP TIMER AND CALCULATE SECONDS
for /f %%a in ('powershell -nop -c "$end=[long](Get-Date).Ticks; [math]::Round(($end - %START_TICKS%)/10000000)"') do set "ELAPSED_SEC=%%a"

if not defined ELAPSED_SEC set "ELAPSED_SEC=1"
if !ELAPSED_SEC! LSS 1 set "ELAPSED_SEC=1"

echo !ELAPSED_SEC!> "!LOG_FILE!"

set /a FINAL_MIN=!ELAPSED_SEC!/60
set /a FINAL_SEC=!ELAPSED_SEC!%%60

echo =======================================================================
echo                     OPERATION COMPLETED!
echo [RESULT] Actual Execution Time: !FINAL_MIN!m !FINAL_SEC!s.
echo [LOGGED] Runtime history updated successfully.
echo =======================================================================
pause
goto MENU


:: -------------------------------------------------------------------------
:: SUBROUTINES / MODULES
:: -------------------------------------------------------------------------

:CREATE_RESTORE_POINT
echo [!] Creating System Restore Point...
powershell -ExecutionPolicy Bypass -Command "try { Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'Kizen_Maintenance_RestorePoint' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop; Write-Host '[OK] System restore point created successfully.' } catch { Write-Host '[WARNING] Restore point creation skipped (System Protection disabled or created within last 24h).' }"
echo.
goto :eof

:CLEAN_TEMP
echo [!] Cleaning temporary junk files, Prefetch, and Recycle Bin...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%p in ("C:\Windows\Temp\*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
rd /s /q C:\$Recycle.bin >nul 2>&1
echo [OK] Temporary files and Recycle Bin cleared.
echo.
goto :eof

:CLEAN_BROWSER_CACHE
echo [!] Cleaning Web Browser Caches (Chrome, Edge, Brave)...
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache\*.*" >nul 2>&1
echo [OK] Web browser caches purged.
echo.
goto :eof

:CLEAN_GPU
echo [!] Clearing Graphics Card and DirectX Shader Caches...
del /s /f /q "%LocalAppData%\NVIDIA\DXCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\NVIDIA\GLCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\AMD\DxCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\Intel\ShaderCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\D3DSCache\*.*" >nul 2>&1
echo [OK] GPU and Shader caches reset.
echo.
goto :eof

:CLEAN_WER_DUMPS
echo [!] Clearing Windows Error Reports and Crash Dumps...
del /s /f /q "C:\Windows\Minidump\*.*" >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Windows\WER\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\CrashDumps\*.*" >nul 2>&1
echo [OK] Crash dumps and error reports cleared.
echo.
goto :eof

:CLEAN_DELIVERY_OPT
echo [!] Clearing Windows Delivery Optimization Cache...
net stop dosvc >nul 2>&1
del /s /f /q "%ProgramData%\Microsoft\Network\Downloader\*.*" >nul 2>&1
net start dosvc >nul 2>&1
echo [OK] Delivery Optimization cache cleared.
echo.
goto :eof

:CLEAN_LOGS
echo [!] Clearing Windows Event Logs...
for /f "tokens=*" %%1 in ('wevtutil.exe el') do wevtutil.exe cl "%%1" >nul 2>&1
echo [OK] Event logs cleared.
echo.
goto :eof

:DISABLE_TELEMETRY
echo [!] Disabling telemetry and diagnostic background services...
sc config DiagTrack start= disabled >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1
net stop DiagTrack >nul 2>&1
net stop dmwappushservice >nul 2>&1
echo [OK] Telemetry services disabled.
echo.
goto :eof

:RESET_NETWORK
echo [!] Resetting network configuration and DNS cache...
ipconfig /flushdns >nul
ipconfig /registerdns >nul
ipconfig /release >nul
ipconfig /renew >nul
netsh winsock reset >nul
netsh int ip reset >nul
echo [OK] Network sockets and cache reset.
echo.
goto :eof

:RESET_UPDATE
echo [!] Resetting Windows Update services and caches...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop cryptsvc >nul 2>&1
if exist "C:\Windows\SoftwareDistribution.bak" rmdir /s /q "C:\Windows\SoftwareDistribution.bak" >nul 2>&1
ren "C:\Windows\SoftwareDistribution" "SoftwareDistribution.bak" >nul 2>&1
if exist "C:\Windows\System32\catroot2.bak" rmdir /s /q "C:\Windows\System32\catroot2.bak" >nul 2>&1
ren "C:\Windows\System32\catroot2" "catroot2.bak" >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
net start cryptsvc >nul 2>&1
echo [OK] Windows Update cache cleared and services restarted.
echo.
goto :eof

:REPAIR_DISM
echo [!] Running DISM system image repair...
DISM.exe /Online /Cleanup-Image /ScanHealth
DISM.exe /Online /Cleanup-Image /RestoreHealth
DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
echo [OK] DISM repair completed.
echo.
goto :eof

:REPAIR_SFC
echo [!] Running System File Checker (SFC)...
sfc /scannow
echo [OK] SFC system file scan completed.
echo.
goto :eof

:OPTIMIZE_STORAGE
echo [!] Detecting storage drive type (SSD vs HDD)...

for /f "tokens=*" %%a in ('powershell -nop -c "(Get-PhysicalDisk ^| Where-Object {$_.DeviceNumber -eq (Get-Partition -DriveLetter 'C').DiskNumber}).MediaType"') do set "DISK_TYPE=%%a"

if /i "!DISK_TYPE!"=="SSD" (
    echo [OK] Solid State Drive (SSD) detected. Executing TRIM (ReTrim) to preserve write endurance...
    defrag C: /L /H >nul 2>&1
    echo [OK] SSD TRIM optimization completed.
) else if /i "!DISK_TYPE!"=="HDD" (
    echo [OK] Hard Disk Drive (HDD) detected. Performing disk defragmentation...
    defrag C: /O /H >nul 2>&1
    echo [OK] HDD defragmentation completed.
) else (
    echo [WARNING] Drive type could not be determined with certainty. Applying safe TRIM...
    defrag C: /L /H >nul 2>&1
    echo [OK] Storage optimization completed.
)
echo.
goto :eof

:RESET_ICON_CACHE
echo [!] Rebuilding Windows Icon Cache database...
ie4uinit.exe -show >nul 2>&1
del /f /q "%LocalAppData%\IconCache.db" >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\Windows\Explorer\iconcache*" >nul 2>&1
echo [OK] Icon Cache rebuilt successfully.
echo.
goto :eof