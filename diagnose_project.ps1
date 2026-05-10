# Flutter Project Diagnostic Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter Project Diagnostic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check gradle-wrapper.jar
$gradleWrapperPath = "android\gradle\wrapper\gradle-wrapper.jar"
Write-Host "1. Checking gradle-wrapper.jar..." -ForegroundColor Yellow
if (Test-Path $gradleWrapperPath) {
    $file = Get-Item $gradleWrapperPath
    Write-Host "   [OK] File EXISTS" -ForegroundColor Green
    Write-Host "   Location: $($file.FullName)" -ForegroundColor Gray
    Write-Host "   Size: $($file.Length) bytes" -ForegroundColor Gray
    if ($file.Length -lt 50000) {
        Write-Host "   [WARNING] File seems too small (should be ~60-70 KB)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   [ERROR] File NOT FOUND" -ForegroundColor Red
    Write-Host "   Expected location: $((Get-Location).Path)\$gradleWrapperPath" -ForegroundColor Gray
}

Write-Host ""

# Check local.properties
Write-Host "2. Checking local.properties..." -ForegroundColor Yellow
if (Test-Path "android\local.properties") {
    Write-Host "   [OK] File EXISTS" -ForegroundColor Green
    $props = Get-Content "android\local.properties"
    foreach ($line in $props) {
        if ($line -match "flutter.sdk") {
            $sdkPath = $line.Split("=")[1]
            Write-Host "   Flutter SDK: $sdkPath" -ForegroundColor Gray
            if (Test-Path $sdkPath) {
                Write-Host "   [OK] Flutter SDK path is valid" -ForegroundColor Green
            } else {
                Write-Host "   [ERROR] Flutter SDK path does not exist!" -ForegroundColor Red
            }
        }
        if ($line -match "sdk.dir") {
            $sdkPath = $line.Split("=")[1]
            Write-Host "   Android SDK: $sdkPath" -ForegroundColor Gray
            if (Test-Path $sdkPath) {
                Write-Host "   [OK] Android SDK path is valid" -ForegroundColor Green
            } else {
                Write-Host "   [WARNING] Android SDK path may not exist" -ForegroundColor Yellow
            }
        }
    }
} else {
    Write-Host "   [ERROR] File NOT FOUND" -ForegroundColor Red
}

Write-Host ""

# Check Flutter installation
Write-Host "3. Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    if ($flutterVersion -match "Flutter") {
        Write-Host "   [OK] Flutter is installed" -ForegroundColor Green
        Write-Host "   $flutterVersion" -ForegroundColor Gray
    } else {
        Write-Host "   [ERROR] Flutter command not found" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERROR] Flutter command failed: $_" -ForegroundColor Red
}

Write-Host ""

# Check pubspec dependencies
Write-Host "4. Checking dependencies..." -ForegroundColor Yellow
if (Test-Path "pubspec.lock") {
    Write-Host "   [OK] pubspec.lock exists (dependencies may be installed)" -ForegroundColor Green
} else {
    Write-Host "   [WARNING] pubspec.lock not found - run 'flutter pub get'" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Diagnostic Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
