# PowerShell script to download gradle-wrapper.jar
$url = "https://raw.githubusercontent.com/gradle/gradle/v8.14.0/gradle/wrapper/gradle-wrapper.jar"
$output = "$PSScriptRoot\android\gradle\wrapper\gradle-wrapper.jar"

Write-Host "Downloading gradle-wrapper.jar..."
Invoke-WebRequest -Uri $url -OutFile $output
Write-Host "Download complete! File saved to: $output"
