@echo off
title Sistem Bakim ve Onarim Araci
color 0A

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [HATA] Bu betik YONETICI haklari gerektirir!
    echo Lutfen dosyaya sag tiklayip "Yonetici olarak calistirin".
    pause
    exit
)

echo =======================================================================
echo          TEPEDEN TIRNAGA SISTEM BAKIM VE ONARIM BASLATILIYOR           
echo =======================================================================
echo.

:: 1. ADIM: SISTEM KURTARMA NOKTASI OLUSTURMA
echo [1/7] Sistem Kurtarma Noktasi olusturuluyor...
powershell -ExecutionPolicy Bypass -Command "try { Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'Bakim_Oncesi_Yedek' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop; Write-Host '[OK] Kurtarma noktasi basariyla olusturuldu.' } catch { Write-Host '[UYARI] Kurtarma noktasi olusturulamadi (Sistem korumasi kapali veya son 24 saatte zaten olusturulmus).' }"
echo.

:: 2. ADIM: GECICI DOSYALARI TEMIZLEME
echo [2/7] Gecici ve cop dosyalar temizleniyor...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*") do rmdir /s /q "%%p" >nul 2>&1

del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%p in ("C:\Windows\Temp\*") do rmdir /s /q "%%p" >nul 2>&1

del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
del /s /f /q "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1

rd /s /q C:\$Recycle.bin >nul 2>&1
echo [OK] Gecici dosyalar ve Geri Donusum Kutusu temizlendi.
echo.

:: 3. ADIM: AG VE DNS SIFIRLAMA
echo [3/7] Ag ayarlari ve DNS onbellegi sifirlaniyor...
ipconfig /flushdns >nul
ipconfig /registerdns >nul
ipconfig /release >nul
ipconfig /renew >nul
netsh winsock reset >nul
netsh int ip reset >nul
echo [OK] Ag onbellegi ve soketler sifirlandi.
echo.

:: 4. ADIM: WINDOWS UPDATE HIZMETLERI (KILITLENME ONLEYICI ZORLAMALI KAPATMA)
echo [4/7] Windows Update servisleri yenileniyor...
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

:: 5. ADIM: DISM ONARIMI
echo [5/7] DISM ile sistem goruntusu taraniyor ve onariliyor...
echo Bu islem bilgisayar hizina bagli olarak birkac dakika surebilir...
DISM.exe /Online /Cleanup-Image /ScanHealth
DISM.exe /Online /Cleanup-Image /RestoreHealth
DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
echo [OK] Sistem goruntusu onarildi.
echo.

:: 6. ADIM: SFC ONARIMI
echo [6/7] SFC ile bozuk sistem dosyalari taraniyor...
sfc /scannow
echo [OK] Sistem dosyalari taramasi tamamlandi.
echo.

:: 7. ADIM: DISK OPTIMIZASYONU
echo [7/7] Suruculer optimize ediliyor...
defrag C: /O /H
echo [OK] Disk optimizasyonu tamamlandi.
echo.

echo =======================================================================
echo                     BAKIM ISLEMI TAMAMLANDI!                  
echo =======================================================================
echo.
echo Degisikliklerin tam etkili olmasi icin bilgisayarinizi yeniden baslatin.
echo.
pause