@echo off
echo Renaming gradle-wrapper to gradle-wrapper.jar...
echo.

cd /d "%~dp0"

if exist "android\gradle\wrapper\gradle-wrapper" (
    if not exist "android\gradle\wrapper\gradle-wrapper.jar" (
        ren "android\gradle\wrapper\gradle-wrapper" "gradle-wrapper.jar"
        echo [SUCCESS] File renamed!
        dir "android\gradle\wrapper\gradle-wrapper.jar"
    ) else (
        echo [WARNING] gradle-wrapper.jar already exists!
        echo Deleting old gradle-wrapper file...
        del "android\gradle\wrapper\gradle-wrapper"
    )
) else (
    if exist "android\gradle\wrapper\gradle-wrapper.jar" (
        echo [OK] gradle-wrapper.jar already exists with correct name!
        dir "android\gradle\wrapper\gradle-wrapper.jar"
    ) else (
        echo [ERROR] Neither file found!
        echo Please download gradle-wrapper.jar first.
    )
)

echo.
pause
