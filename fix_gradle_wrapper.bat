@echo off
echo Downloading gradle-wrapper.jar...
echo.

cd /d "%~dp0"

set "URL=https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar"
set "OUTPUT=android\gradle\wrapper\gradle-wrapper.jar"

echo URL: %URL%
echo Output: %CD%\%OUTPUT%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%URL%' -OutFile '%OUTPUT%' -UseBasicParsing -ErrorAction Stop; Write-Host '[SUCCESS] File downloaded!' } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 }"

if exist "%OUTPUT%" (
    echo.
    echo [SUCCESS] gradle-wrapper.jar is now in place!
    dir "%OUTPUT%"
    echo.
    echo You can now run: flutter run
) else (
    echo.
    echo [ERROR] Download failed!
    echo.
    echo Please download manually:
    echo 1. Open: %URL%
    echo 2. Save as: %CD%\%OUTPUT%
    echo.
    pause
    exit 1
)

pause
