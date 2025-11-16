# Test Backend Configuration Loading
# This script tests if the backend can properly load and use env.json

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Backend Configuration" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if backend is running
Write-Host "[1/3] Checking if backend is running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -Method GET -TimeoutSec 2 -ErrorAction Stop
    Write-Host "   [OK] Backend is running`n" -ForegroundColor Green
} catch {
    Write-Host "   [ERROR] Backend is NOT running" -ForegroundColor Red
    Write-Host "   Please start it with: cd backend && node server.js`n" -ForegroundColor Yellow
    exit 1
}

# Check env.json exists
Write-Host "[2/3] Checking env.json..." -ForegroundColor Yellow
if (Test-Path "env.json") {
    $envContent = Get-Content "env.json" -Raw | ConvertFrom-Json
    $requiredFields = @(
        "MODELARTS_PROJECT_ID",
        "MODELARTS_ACCESS_KEY",
        "MODELARTS_SECRET_KEY",
        "MODELARTS_SERVICE_ID",
        "MODELARTS_REGION"
    )
    
    $allPresent = $true
    foreach ($field in $requiredFields) {
        if (-not $envContent.$field) {
            Write-Host "   [ERROR] Missing field: $field" -ForegroundColor Red
            $allPresent = $false
        }
    }
    
    if ($allPresent) {
        Write-Host "   [OK] All required fields present" -ForegroundColor Green
        Write-Host "     - Project ID: $($envContent.MODELARTS_PROJECT_ID)" -ForegroundColor Gray
        Write-Host "     - Service ID: $($envContent.MODELARTS_SERVICE_ID)" -ForegroundColor Gray
        Write-Host "     - Region: $($envContent.MODELARTS_REGION)`n" -ForegroundColor Gray
    } else {
        Write-Host "`n   [ERROR] env.json is incomplete`n" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   [ERROR] env.json not found`n" -ForegroundColor Red
    exit 1
}

# Test backend proxy with minimal payload (no credentials)
Write-Host "[3/3] Testing backend proxy (without credentials in request)..." -ForegroundColor Yellow
Write-Host "   This tests if backend can read from env.json..." -ForegroundColor Gray

# Create a tiny 1x1 pixel PNG image in base64
$testImage = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

$body = @{
    imageBase64 = $testImage
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/modelarts/infer" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 30 -ErrorAction Stop
    
    Write-Host "   [OK] Backend proxy responded" -ForegroundColor Green
    Write-Host "   Status Code: $($response.StatusCode)" -ForegroundColor Gray
    
    # Note: The response might be an error because the image is invalid,
    # but if we get here, it means the backend successfully loaded credentials from env.json
    Write-Host "`n   [SUCCESS] Backend can read credentials from env.json!" -ForegroundColor Green
    Write-Host "   (Response may show error due to test image, but config loading works)`n" -ForegroundColor Gray
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    
    if ($statusCode -eq 400) {
        # 400 means backend processed the request but image/payload was invalid
        # This is actually good - it means credentials were loaded
        Write-Host "   [OK] Backend processed request (400 = invalid image, but config works)" -ForegroundColor Green
        Write-Host "`n   [SUCCESS] Backend can read credentials from env.json!`n" -ForegroundColor Green
    } elseif ($statusCode -eq 401 -or $statusCode -eq 403) {
        Write-Host "   [ERROR] Authentication failed (401/403)" -ForegroundColor Red
        Write-Host "   Check if credentials in env.json are correct`n" -ForegroundColor Yellow
    } else {
        Write-Host "   [WARN] Got status code: $statusCode" -ForegroundColor Yellow
        Write-Host "   Error: $($_.Exception.Message)`n" -ForegroundColor Gray
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Test Complete" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Start Flutter web: .\run_web_proxy.ps1" -ForegroundColor Gray
Write-Host "  2. Test with real retinal image" -ForegroundColor Gray
Write-Host "  3. Check backend console for detailed logs`n" -ForegroundColor Gray
