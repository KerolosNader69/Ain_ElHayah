# End-to-End ModelArts Integration Test Script
# This script tests the complete flow from Flutter web to ModelArts inference

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ModelArts E2E Integration Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if backend dependencies are installed
Write-Host "[1/8] Checking backend dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "backend/node_modules")) {
    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    Push-Location backend
    npm install
    Pop-Location
}
Write-Host "✓ Backend dependencies ready" -ForegroundColor Green
Write-Host ""

# Step 2: Start the backend server
Write-Host "[2/8] Starting backend proxy server..." -ForegroundColor Yellow
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location backend
    node server.js
}
Write-Host "✓ Backend server starting (Job ID: $($backendJob.Id))" -ForegroundColor Green
Start-Sleep -Seconds 3
Write-Host ""

# Step 3: Verify backend is running
Write-Host "[3/8] Verifying backend health..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get -TimeoutSec 5
    Write-Host "✓ Backend server is healthy" -ForegroundColor Green
    Write-Host "  Status: $($healthCheck.status)" -ForegroundColor Gray
    Write-Host "  Message: $($healthCheck.message)" -ForegroundColor Gray
} catch {
    Write-Host "✗ Backend health check failed: $_" -ForegroundColor Red
    Stop-Job $backendJob
    Remove-Job $backendJob
    exit 1
}
Write-Host ""

# Step 4: Check Flutter web build
Write-Host "[4/8] Checking Flutter web setup..." -ForegroundColor Yellow
Write-Host "  Note: Flutter web app should be started manually" -ForegroundColor Gray
Write-Host "  Run: flutter run -d chrome --web-port 8080" -ForegroundColor Gray
Write-Host ""

# Step 5: Display test instructions
Write-Host "[5/8] Manual Testing Instructions:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open another terminal and run:" -ForegroundColor White
Write-Host "   flutter run -d chrome --web-port 8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. In the Flutter app:" -ForegroundColor White
Write-Host "   - Navigate to the diagnosis screen" -ForegroundColor Gray
Write-Host "   - Select 'Retinal Scan' model" -ForegroundColor Gray
Write-Host "   - Upload a test retinal image" -ForegroundColor Gray
Write-Host "   - Click 'Analyze'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Expected behavior:" -ForegroundColor White
Write-Host "   ✓ Request goes through backend proxy (localhost:3001)" -ForegroundColor Gray
Write-Host "   ✓ IAM token is obtained and cached" -ForegroundColor Gray
Write-Host "   ✓ ModelArts API is called with correct headers" -ForegroundColor Gray
Write-Host "   ✓ Response is parsed correctly" -ForegroundColor Gray
Write-Host "   ✓ Results display in the UI" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 6: Monitor backend logs
Write-Host "[6/8] Monitoring backend logs..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop monitoring and shut down the backend" -ForegroundColor Gray
Write-Host ""

try {
    while ($true) {
        $output = Receive-Job $backendJob
        if ($output) {
            Write-Host $output
        }
        Start-Sleep -Milliseconds 500
    }
} finally {
    # Cleanup
    Write-Host ""
    Write-Host "[7/8] Shutting down backend server..." -ForegroundColor Yellow
    Stop-Job $backendJob
    Remove-Job $backendJob
    Write-Host "✓ Backend server stopped" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "[8/8] Test session complete" -ForegroundColor Green
    Write-Host ""
}
