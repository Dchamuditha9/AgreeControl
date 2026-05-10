@echo off
echo ========================================
echo Checking for gradle-wrapper.jar...
echo ========================================
echo.

cd /d "%~dp0"

if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo [OK] File EXISTS at: %CD%\android\gradle\wrapper\gradle-wrapper.jar
    dir "android\gradle\wrapper\gradle-wrapper.jar"
    echo.
    echo File is in the correct location!
) else (
    echo [ERROR] File NOT FOUND at: %CD%\android\gradle\wrapper\gradle-wrapper.jar
    echo.
    echo The file should be at this EXACT location:
    echo %CD%\android\gradle\wrapper\gradle-wrapper.jar
    echo.
    echo Current contents of wrapper folder:
    dir "android\gradle\wrapper"
    echo.
    echo ========================================
    echo Attempting to download now...
    echo ========================================
    echo.
    
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'android\gradle\wrapper\gradle-wrapper.jar' -ErrorAction Stop; Write-Host '[SUCCESS] File downloaded!' } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message }"
    
    echo.
    if exist "android\gradle\wrapper\gradle-wrapper.jar" (
        echo [SUCCESS] File is now in place!
        dir "android\gradle\wrapper\gradle-wrapper.jar"
    ) else (
        echo [ERROR] Download failed. Please download manually.
        echo.
        echo Open this URL in your browser:
        echo https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar
        echo.
        echo Then save the file to:
        echo %CD%\android\gradle\wrapper\gradle-wrapper.jar
    )
)

echo.
echo ========================================
pause
