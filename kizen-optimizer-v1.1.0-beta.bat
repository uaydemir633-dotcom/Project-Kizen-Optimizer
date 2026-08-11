@echo off
title Gelismis Sistem Bakim ve Onarim Araci
color 0A

:: YONETICI IZNI KONTROLU
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [HATA] Bu betik YONETICI haklari gerektirir!
    echo Lutfen dosyaya sag tiklayip "Yonetici olarak calistirin".
    pause
    exit
)

:MENU
cls
echo =======================================================================
echo               GELISMIS SISTEM BAKIM VE ONARIM MENUSU
echo =======================================================================
echo [1] Hizli Temizlik (Temp, Ag, GPU, Olay Gunlukleri, Telemetri)
echo [2] Kapsamli Onarim (Kurtarma Noktasi, Update, DISM, SFC, Disk)
echo [3] Tam Kapsamli Bakim (1 ve 2 Numarali Islemlerin Tamami)
echo [4] Cikis
echo =======================================================================
set /p secim="Lutfen bir islem secin (1-4): "

if "%secim%"=="1" goto HIZLI
if "%secim%"=="2" goto KAPSAMLI
if "%secim%"=="3" goto TAM
if "%secim%"=="4" exit
goto MENU

:HIZLI
cls
echo === HIZLI TEMIZLIK VE OPTIMIZASYON BASLIYOR ===
call :GECICI_TEMIZLE
call :AG_SIFIRLA
call :GPU_TEMIZLE
call :LOG_TEMIZLE
call :TELEMETRI_KAPAT
echo =======================================================================
echo                     ISLEM TAMAMLANDI!
echo =======================================================================
pause
goto MENU

:KAPSAMLI
cls
echo === KAPSAMLI ONARIM BASLIYOR ===
call :KURTARMA_NOKTASI
call :UPDATE_SIFIRLA
call :DISM_ONAR
call :SFC_ONAR
call :DISK_OPTIMIZE
echo =======================================================================
echo                     ISLEM TAMAMLANDI!
echo =======================================================================
pause
goto MENU

:TAM
cls
echo === TAM KAPSAMLI BAKIM BASLIYOR ===
call :KURTARMA_NOKTASI
call :GECICI_TEMIZLE
call :GPU_TEMIZLE
call :LOG_TEMIZLE
call :TELEMETRI_KAPAT
call :AG_SIFIRLA
call :UPDATE_SIFIRLA
call :DISM_ONAR
call :SFC_ONAR
call :DISK_OPTIMIZE
echo =======================================================================
echo                     ISLEM TAMAMLANDI!
echo =======================================================================
pause
goto MENU

:: -------------------------------------------------------------------------
:: ALT FONKSIYONLAR (ISLEM MODULLERI)
:: -------------------------------------------------------------------------

:KURTARMA_NOKTASI
echo [!] Sistem Kurtarma Noktasi olusturuluyor...
powershell -ExecutionPolicy Bypass -Command "try { Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'Bakim_Oncesi_Yedek' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop; Write-Host '[OK] Kurtarma noktasi basariyla olusturuldu.' } catch { Write-Host '[UYARI] Kurtarma noktasi olusturulamadi (Sistem korumasi kapali veya son 24 saatte zaten olusturulmus).' }"
echo.
goto :eof

:GECICI_TEMIZLE
echo [!] Gecici ve cop dosyalar temizleniyor...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%p in ("C:\Windows\Temp\*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
rd /s /q C:\$Recycle.bin >nul 2>&1
echo [OK] Gecici dosyalar ve Geri Donusum Kutusu temizlendi.
echo.
goto :eof

:GPU_TEMIZLE
echo [!] Ekran karti ve DirectX onbellekleri temizleniyor...
del /s /f /q "%LocalAppData%\NVIDIA\DXCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\NVIDIA\GLCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\AMD\DxCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\Intel\ShaderCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\D3DSCache\*.*" >nul 2>&1
echo [OK] GPU ve Shader onbellekleri sifirlandi.
echo.
goto :eof

:LOG_TEMIZLE
echo [!] Windows Olay Gunlukleri (Event Logs) temizleniyor...
for /f "tokens=*" %%1 in ('wevtutil.exe el') do wevtutil.exe cl "%%1" >nul 2>&1
echo [OK] Olay gunlukleri sifirlandi.
echo.
goto :eof

:TELEMETRI_KAPAT
echo [!] Telemetri ve arka plan servisleri kapatiliyor...
sc config DiagTrack start= disabled >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1
net stop DiagTrack >nul 2>&1
net stop dmwappushservice >nul 2>&1
echo [OK] Microsoft veri toplama servisleri devre disi birakildi.
echo.
goto :eof

:AG_SIFIRLA
echo [!] Ag ayarlari ve DNS onbellegi sifirlaniyor...
ipconfig /flushdns >nul
ipconfig /registerdns >nul
ipconfig /release >nul
ipconfig /renew >nul
netsh winsock reset >nul
netsh int ip reset >nul
echo [OK] Ag onbellegi ve soketler sifirlandi.
echo.
goto :eof

:UPDATE_SIFIRLA
echo [!] Windows Update servisleri yenileniyor...
taskkill /F /FI "SERVICES eq wuauserv" >nul 2>&1
taskkill /F /FI "SERVICES eq bits" >nul 2>&1
taskkill /F /FI "SERVICES eq cryptsvc" >nul 2>&1
ren C:\Windows\SoftwareDistribution SoftwareDistribution.bak >nul 2>&1
ren C:\Windows\System32\catroot2 catroot2.bak >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
net start cryptsvc >nul 2>&1
echo [OK] Windows Update onbellegi sifirlandi.
echo.
goto :eof

:DISM_ONAR
echo [!] DISM ile sistem goruntusu taraniyor ve onariliyor...
DISM.exe /Online /Cleanup-Image /ScanHealth
DISM.exe /Online /Cleanup-Image /RestoreHealth
DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
echo [OK] Sistem goruntusu onarildi.
echo.
goto :eof

:SFC_ONAR
echo [!] SFC ile bozuk sistem dosyalari taraniyor...
sfc /scannow
echo [OK] Sistem dosyalari taramasi tamamlandi.
echo.
goto :eof

:DISK_OPTIMIZE
echo [!] Suruculer optimize ediliyor...
defrag C: /O /H
echo [OK] Disk optimizasyonu tamamlandi.
echo.
goto :eof