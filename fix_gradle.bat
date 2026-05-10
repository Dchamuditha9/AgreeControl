@echo off
echo Downloading gradle-wrapper.jar...
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'android\gradle\wrapper\gradle-wrapper.jar'"
if exist "android\gradle\wrapper\gradle-wrapper.jar" (
    echo Success! gradle-wrapper.jar downloaded.
) else (
    echo Failed to download. Please check your internet connection.
)
pause
