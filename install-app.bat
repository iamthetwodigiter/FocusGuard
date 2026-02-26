@echo off
setlocal EnableExtensions

echo ------------------------------------------------
echo    FocusGuard APK Installer (Windows)
echo ------------------------------------------------

:: ==============================
:: 1. Ensure ADB exists
:: ==============================

set "ADB_BIN=adb"
where adb >nul 2>nul
if %errorlevel% neq 0 (
    if exist "platform-tools\adb.exe" (
        set "ADB_BIN=platform-tools\adb.exe"
    ) else (
        echo ADB not found. Downloading platform-tools...

        powershell -NoProfile -Command "Invoke-WebRequest 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'pt.zip'"
        powershell -NoProfile -Command "Expand-Archive 'pt.zip' '.' -Force"

        del pt.zip >nul 2>nul

        if not exist "platform-tools\adb.exe" (
            echo Failed to download ADB.
            pause
            exit /b 1
        )

        set "ADB_BIN=platform-tools\adb.exe"
    )
)

:: ==============================
:: 2. Get Latest APK URL (NO pipes, NO braces)
:: ==============================

echo Fetching latest release...

set "DOWNLOAD_URL="

for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "(Invoke-RestMethod 'https://api.github.com/repos/iamthetwodigiter/FocusGuard/releases/latest').assets[0].browser_download_url"`) do (
    set "DOWNLOAD_URL=%%A"
)

if not defined DOWNLOAD_URL (
    echo Failed to fetch latest release.
    goto :local_check
)

for %%F in ("%DOWNLOAD_URL%") do set "APK_NAME=%%~nxF"

if not exist "%APK_NAME%" (
    echo Downloading %APK_NAME% ...
    powershell -NoProfile -Command "Invoke-WebRequest '%DOWNLOAD_URL%' -OutFile '%APK_NAME%'"
)

set "APK_PATH=%APK_NAME%"
goto :after_apk

:local_check
echo Checking local directory for APK...
for %%F in (*.apk) do (
    set "APK_PATH=%%F"
    goto :after_apk
)

:after_apk
if not defined APK_PATH (
    echo No APK found locally or online.
    pause
    exit /b 1
)

echo Selected APK: %APK_PATH%

:: ==============================
:: 3. Check for device
:: ==============================

echo Checking for connected devices...
%ADB_BIN% devices | findstr "device" | findstr /v "List" >nul

if %errorlevel% neq 0 (
    echo ------------------------------------------------
    echo No Android devices found.
    echo Please:
    echo   1. Connect your phone via USB
    echo   2. Enable 'USB Debugging' in Developer Options
    echo   3. Accept the debugging prompt on your phone
    echo ------------------------------------------------
    pause
    exit /b 1
)

:: ==============================
:: 4. Install APK
:: ==============================

echo Installing %APK_PATH% ...
%ADB_BIN% install -r "%APK_PATH%"

if %errorlevel% equ 0 (
    echo ------------------------------------------------
    echo Success! FocusGuard installed successfully.
    echo ------------------------------------------------
) else (
    echo ------------------------------------------------
    echo Error: Failed to install APK.
    echo ------------------------------------------------
)

pause
