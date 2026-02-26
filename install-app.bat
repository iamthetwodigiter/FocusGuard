@echo off
setlocal enabledelayedexpansion

echo ------------------------------------------------
echo    FocusGuard APK Installer (Windows)
echo ------------------------------------------------

:: 1. Check for ADB
set "ADB_BIN=adb"
where adb >nul 2>nul
if %errorlevel% neq 0 (
    if exist "platform-tools\adb.exe" (
        set "ADB_BIN=.\platform-tools\adb.exe"
    ) else (
        echo ADB not found. Attempting to download platform-tools...
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'platform-tools.zip'"
        powershell -Command "Expand-Archive -Path 'platform-tools.zip' -DestinationPath '.' -Force"
        del platform-tools.zip
        set "ADB_BIN=.\platform-tools\adb.exe"
    )
)

:: 2. Identify/Download APK via PowerShell
echo Fetching latest releases from GitHub...
set "PS_CMD=$repo='iamthetwodigiter/FocusGuard'; $release=Invoke-RestMethod -Uri \"https://api.github.com/repos/$repo/releases/latest\"; $apks=$release.assets | Where-Object { $_.name -like '*.apk' }; if ($apks) { for ($i=0; $i -lt $apks.Length; $i++) { Write-Host (\"{0}) {1}\" -f ($i+1), $apks[$i].name) }; if ($apks.Length -eq 1) { $choice=1 } else { $choice=Read-Host \"Select an APK to install\" }; $selected=$apks[$choice-1]; if (!(Test-Path $selected.name)) { Write-Host \"Downloading $($selected.name)...\"; Invoke-WebRequest -Uri $selected.browser_download_url -OutFile $selected.name }; Write-Output $selected.name } else { Write-Output 'NONE' }"

for /f "delims=" %%i in ('powershell -Command "%PS_CMD%"') do (
    set "APK_PATH=%%i"
)

if "%APK_PATH%"=="NONE" (
    :: Fallback to local search
    echo No APK found in GitHub releases. Checking local directory...
    set "APK_PATH="
    for %%f in (*.apk) do (
        set "APK_PATH=%%f"
        goto :found_local
    )
)

:found_local
if "%APK_PATH%"=="" (
    echo Error: No APK file found on GitHub or locally.
    pause
    exit /b 1
)

echo Selected APK: %APK_PATH%

:: 3. Check for Devices
echo Checking for connected devices...
%ADB_BIN% devices | findstr /C:"device" | findstr /V "List" > nul
if %errorlevel% neq 0 (
    echo ------------------------------------------------
    echo ❌ No Android devices found.
    echo Please:
    echo   1. Connect your phone via USB
    echo   2. Enable 'USB Debugging' in Developer Options
    echo   3. Accept the debugging prompt on your phone
    echo ------------------------------------------------
    pause
    exit /b 1
)

:: 4. Install
echo Installing "%APK_PATH%"...
%ADB_BIN% install -r "%APK_PATH%"

if %errorlevel% equ 0 (
    echo ------------------------------------------------
    echo ✅ Success! FocusGuard installed successfully.
    echo ------------------------------------------------
) else (
    echo ------------------------------------------------
    echo ❌ Error: Failed to install APK.
    echo ------------------------------------------------
)

pause
exit /b 0
