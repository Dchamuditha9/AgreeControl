@echo off
echo ========================================
echo Downloading gradle-wrapper.jar...
echo ========================================
echo.

cd /d "%~dp0"

if not exist "android\gradle\wrapper" mkdir "android\gradle\wrapper"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'android\gradle\wrapper\gradle-wrapper.jar'"

if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo.
    echo ========================================
    echo SUCCESS! File downloaded.
    echo ========================================
    echo File location: %CD%\android\gradle\wrapper\gradle-wrapper.jar
    dir "android\gradle\wrapper\gradle-wrapper.jar"
) else (
    echo.
    echo ========================================
    echo ERROR: Download failed!
    echo ========================================
    echo Please check your internet connection and try again.
    echo.
    echo You can also download manually from:
    echo https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar
    echo.
    echo Save it to: %CD%\android\gradle\wrapper\gradle-wrapper.jar
)

echo.
pause
