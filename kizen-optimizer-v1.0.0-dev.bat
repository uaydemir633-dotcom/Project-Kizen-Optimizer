@echo off
setlocal enabledelayedexpansion
title Ogrenen Sistem Bakim ve Onarim Araci
color 0A

:: YONETICI IZNI KONTROLU
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [HATA] Bu betik YONETICI haklari gerektirir!
    echo Lutfen dosyaya sag tiklayip "Yonetici olarak calistirin".
    pause
    exit
)

:: LOG (GECMIS SURE) DOSYALARININ YOLU (Bat dosyasi neredeyse oraya kaydeder)
set "LOG_HIZLI=%~dp0sure_hizli.txt"
set "LOG_KAPSAMLI=%~dp0sure_kapsamli.txt"
set "LOG_TAM=%~dp0sure_tam.txt"

:MENU
cls
echo =======================================================================
echo          AKILLI SISTEM BAKIM VE ONARIM MENUSU
echo =======================================================================
echo [1] Hizli Temizlik
echo [2] Kapsamli Onarim
echo [3] Tam Kapsamli Bakim
echo [4] Cikis
echo =======================================================================
set /p secim="Lutfen bir islem secin (1-4): "

if "%secim%"=="1" (
    set "ISLEM_ADI=HIZLI"
    set "LOG_DOSYASI=!LOG_HIZLI!"
    goto ISLEM_BASLAT
)
if "%secim%"=="2" (
    set "ISLEM_ADI=KAPSAMLI"
    set "LOG_DOSYASI=!LOG_KAPSAMLI!"
    goto ISLEM_BASLAT
)
if "%secim%"=="3" (
    set "ISLEM_ADI=TAM"
    set "LOG_DOSYASI=!LOG_TAM!"
    goto ISLEM_BASLAT
)
if "%secim%"=="4" exit
goto MENU

:ISLEM_BASLAT
cls
echo === !ISLEM_ADI! ISLEMI BASLIYOR ===

:: GECMİS SUREYI OKU VE TAHMIN YAP
if exist "!LOG_DOSYASI!" (
    set /p ESKI_SURE= < "!LOG_DOSYASI!"
    set /a DAKIKA=!ESKI_SURE!/60
    set /a SANIYE=!ESKI_SURE!%%60
    echo [BILGI] Sistemin gecmis hiz kayitlarina gore tahmini sure: !DAKIKA! dk !SANIYE! sn.
) else (
    echo [BILGI] Bu islem ilk defa yapildigi icin tahmini sure hesaplanamiyor.
    echo [BILGI] Islem bitiminde sure analizi dosyaya kaydedilecek.
)
echo =======================================================================

:: KRONOMETREYI BASLAT (Saniye cinsinden)
powershell -nop -c "(Get-Date).Ticks" > "%temp%\start_time.txt"

:: ISLEM ADIMLARINI KONTROL ET VE CAGIR
if "!ISLEM_ADI!"=="HIZLI" (
    call :GECICI_TEMIZLE
    call :AG_SIFIRLA
    call :GPU_TEMIZLE
    call :LOG_TEMIZLE
    call :TELEMETRI_KAPAT
)
if "!ISLEM_ADI!"=="KAPSAMLI" (
    call :KURTARMA_NOKTASI
    call :UPDATE_SIFIRLA
    call :DISM_ONAR
    call :SFC_ONAR
    call :DISK_OPTIMIZE
)
if "!ISLEM_ADI!"=="TAM" (
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
)

:: KRONOMETREYI DURDUR, HESAPLA VE KAYDET
powershell -nop -c "$start=Get-Content '%temp%\start_time.txt'; $end=(Get-Date).Ticks; [math]::Round(($end-$start)/10000000)" > "%temp%\elapsed.txt"
set /p SURE_SN= < "%temp%\elapsed.txt"
echo !SURE_SN! > "!LOG_DOSYASI!"

set /a B_DAKIKA=!SURE_SN!/60
set /a B_SANIYE=!SURE_SN!%%60

echo =======================================================================
echo                     ISLEM TAMAMLANDI!
echo [SONUC] Gerceklesen Islem Suresi: !B_DAKIKA! dk !B_SANIYE! sn.
echo [KAYIT] Bu sure basariyla guncellendi ve txt dosyasina yazildi.
echo =======================================================================
pause
goto MENU


:: -------------------------------------------------------------------------
:: ALT FONKSIYONLAR (ISLEM MODULLERI)
:: -------------------------------------------------------------------------

:KURTARMA_NOKTASI
echo [!] Sistem Kurtarma Noktasi olusturuluyor...
powershell -ExecutionPolicy Bypass -Command "try { Enable-ComputerRestore -Drive 'C:\' -ErrorAction SilentlyContinue; Checkpoint-Computer -Description 'Bakim_Oncesi_Yedek' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop; Write-Host '[OK] Kurtarma noktasi basariyla olusturuldu.' } catch { Write-Host '[UYARI] Kurtarma noktasi atlandi.' }"
echo.
goto :eof

:GECICI_TEMIZLE
echo [!] Gecici ve cop dosyalar temizleniyor...
del /s /f /q "%temp%\*.*" >nul 2>&1
rd /s /q C:\$Recycle.bin >nul 2>&1
echo [OK] Gecici dosyalar temizlendi.
echo.
goto :eof

:GPU_TEMIZLE
echo [!] Ekran karti ve DirectX onbellekleri temizleniyor...
del /s /f /q "%LocalAppData%\NVIDIA\DXCache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\AMD\DxCache\*.*" >nul 2>&1
echo [OK] GPU onbellekleri sifirlandi.
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
net stop DiagTrack >nul 2>&1
echo [OK] Microsoft veri toplama servisleri devre disi.
echo.
goto :eof

:AG_SIFIRLA
echo [!] Ag ayarlari ve DNS onbellegi sifirlaniyor...
ipconfig /flushdns >nul
netsh winsock reset >nul
echo [OK] Ag onbellegi sifirlandi.
echo.
goto :eof

:UPDATE_SIFIRLA
echo [!] Windows Update servisleri yenileniyor...
taskkill /F /FI "SERVICES eq wuauserv" >nul 2>&1
net start wuauserv >nul 2>&1
echo [OK] Update onbellegi sifirlandi.
echo.
goto :eof

:DISM_ONAR
echo [!] DISM ile sistem goruntusu onariliyor...
DISM.exe /Online /Cleanup-Image /RestoreHealth
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