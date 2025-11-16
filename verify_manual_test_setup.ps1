# Manual Testing Setup Verification Script
# This script verifies that all prerequisites are in place for manual testing

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Manual Testing Setup Verification" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$allChecks = $true

# Check 1: env.json exists and has required fields
Write-Host "[1/6] Checking env.json configuration..." -ForegroundColor Yellow
if (Test-Path "env.json") {
    $envContent = Get-Content "env.json" -Raw | ConvertFrom-Json
    $requiredFields = @(
        "MODELARTS_PROJECT_ID",
        "MODELARTS_ACCESS_KEY",
        "MODELARTS_SECRET_KEY",
        "MODELARTS_SERVICE_ID",
        "MODELARTS_REGION",
        "MODELARTS_INVOKE_URL"
    )
    
    $missingFields = @()
    foreach ($field in $requiredFields) {
        if (-not $envContent.$field) {
            $missingFields += $field
        }
    }
    
    if ($missingFields.Count -eq 0) {
        Write-Host "   [OK] All ModelArts configuration fields present" -ForegroundColor Green
        Write-Host "     - Project ID: $($envContent.MODELARTS_PROJECT_ID)" -ForegroundColor Gray
        Write-Host "     - Service ID: $($envContent.MODELARTS_SERVICE_ID)" -ForegroundColor Gray
        Write-Host "     - Region: $($envContent.MODELARTS_REGION)" -ForegroundColor Gray
    } else {
        Write-Host "   [ERROR] Missing fields: $($missingFields -join ', ')" -ForegroundColor Red
        $allChecks = $false
    }
} else {
    Write-Host "   [ERROR] env.json file not found" -ForegroundColor Red
    $allChecks = $false
}

# Check 2: Backend server files exist
Write-Host "`n[2/6] Checking backend server files..." -ForegroundColor Yellow
if (Test-Path "backend/server.js") {
    Write-Host "   [OK] backend/server.js exists" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] backend/server.js not found" -ForegroundColor Red
    $allChecks = $false
}

if (Test-Path "backend/package.json") {
    Write-Host "   [OK] backend/package.json exists" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] backend/package.json not found" -ForegroundColor Red
    $allChecks = $false
}

# Check 3: Backend dependencies installed
Write-Host "`n[3/6] Checking backend dependencies..." -ForegroundColor Yellow
if (Test-Path "backend/node_modules") {
    Write-Host "   [OK] node_modules directory exists" -ForegroundColor Green
} else {
    Write-Host "   [WARN] node_modules not found - run npm install in backend directory" -ForegroundColor Yellow
    Write-Host "     Command: cd backend && npm install" -ForegroundColor Gray
}

# Check 4: Flutter project files
Write-Host "`n[4/6] Checking Flutter project files..." -ForegroundColor Yellow
if (Test-Path "pubspec.yaml") {
    Write-Host "   [OK] pubspec.yaml exists" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] pubspec.yaml not found" -ForegroundColor Red
    $allChecks = $false
}

if (Test-Path "lib/providers/diagnosis_provider_web.dart") {
    Write-Host "   [OK] diagnosis_provider_web.dart exists" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] diagnosis_provider_web.dart not found" -ForegroundColor Red
    $allChecks = $false
}

# Check 5: Locale files
Write-Host "`n[5/6] Checking locale support..." -ForegroundColor Yellow
if (Test-Path "assets/l10n/app_en.arb") {
    Write-Host "   [OK] English locale file exists" -ForegroundColor Green
} else {
    Write-Host "   [WARN] English locale file not found" -ForegroundColor Yellow
}

if (Test-Path "assets/l10n/app_ar.arb") {
    Write-Host "   [OK] Arabic locale file exists" -ForegroundColor Green
} else {
    Write-Host "   [WARN] Arabic locale file not found" -ForegroundColor Yellow
}

# Check 6: Test images directory
Write-Host "`n[6/6] Checking test images..." -ForegroundColor Yellow
if (Test-Path "assets/images") {
    $imageCount = (Get-ChildItem "assets/images" -File).Count
    Write-Host "   [OK] assets/images directory exists ($imageCount files)" -ForegroundColor Green
    Write-Host "     Note: You will need retinal test images for manual testing" -ForegroundColor Gray
} else {
    Write-Host "   [WARN] assets/images directory not found" -ForegroundColor Yellow
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Verification Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($allChecks) {
    Write-Host "[OK] All critical checks passed!" -ForegroundColor Green
    Write-Host "`nYou can proceed with manual testing:" -ForegroundColor White
    Write-Host "  1. Start backend: cd backend && node server.js" -ForegroundColor Gray
    Write-Host "  2. Start Flutter web: .\run_web_simple.ps1" -ForegroundColor Gray
    Write-Host "  3. Follow MANUAL_TESTING_GUIDE.md" -ForegroundColor Gray
} else {
    Write-Host "[ERROR] Some checks failed - please fix issues before testing" -ForegroundColor Red
}

Write-Host "`n========================================`n" -ForegroundColor Cyan

# Check if backend is running
Write-Host "Checking if backend server is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -Method GET -TimeoutSec 2 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] Backend server is running on port 3001" -ForegroundColor Green
        $healthData = $response.Content | ConvertFrom-Json
        Write-Host "  Status: $($healthData.status)" -ForegroundColor Gray
    }
} catch {
    Write-Host "[WARN] Backend server is not running" -ForegroundColor Yellow
    Write-Host "  Start it with: cd backend && node server.js" -ForegroundColor Gray
}

Write-Host ""
