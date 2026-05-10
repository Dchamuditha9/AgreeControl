@echo off
echo Fixing gradle-wrapper.jar.jar to gradle-wrapper.jar...
echo.

cd /d "%~dp0"

if exist "android\gradle\wrapper\gradle-wrapper.jar.jar" (
    echo Found gradle-wrapper.jar.jar - renaming...
    ren "android\gradle\wrapper\gradle-wrapper.jar.jar" "gradle-wrapper.jar"
    echo [SUCCESS] File renamed to gradle-wrapper.jar!
    dir "android\gradle\wrapper\gradle-wrapper.jar"
) else if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo [OK] gradle-wrapper.jar already exists with correct name!
    dir "android\gradle\wrapper\gradle-wrapper.jar"
) else (
    echo [ERROR] gradle-wrapper.jar not found!
    echo Current files in wrapper directory:
    dir "android\gradle\wrapper"
)

echo.
echo You can now run: flutter run
echo.
pause
