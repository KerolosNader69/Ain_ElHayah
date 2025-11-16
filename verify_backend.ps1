# Quick Backend Verification Script
# Tests that the backend server can start and respond to requests

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend Server Quick Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting backend server..." -ForegroundColor Yellow
Write-Host "The server will run in the background for testing" -ForegroundColor Gray
Write-Host ""

# Start backend server in background
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location backend
    node server.js
}

Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Test health endpoint
Write-Host "Testing health endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get -TimeoutSec 5
    Write-Host "✓ Health check passed!" -ForegroundColor Green
    Write-Host "  Status: $($response.status)" -ForegroundColor Gray
    Write-Host "  Message: $($response.message)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Backend server is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now:" -ForegroundColor White
    Write-Host "1. Run the proxy test: node backend/test_proxy.js" -ForegroundColor Cyan
    Write-Host "2. Start Flutter web: flutter run -d chrome" -ForegroundColor Cyan
    Write-Host "3. Test the full E2E flow" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press any key to stop the backend server..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
} catch {
    Write-Host "✗ Health check failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Checking backend logs..." -ForegroundColor Yellow
    $logs = Receive-Job $backendJob
    if ($logs) {
        Write-Host $logs
    }
} finally {
    Write-Host ""
    Write-Host "Stopping backend server..." -ForegroundColor Yellow
    Stop-Job $backendJob
    Remove-Job $backendJob
    Write-Host "✓ Backend server stopped" -ForegroundColor Green
}
