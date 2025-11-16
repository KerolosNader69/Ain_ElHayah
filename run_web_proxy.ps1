# Run Flutter Web with Backend Proxy Mode
# This script runs the web app without compile-time variables
# All ModelArts credentials are handled by the backend proxy

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Starting Flutter Web (Proxy Mode)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[INFO] Backend proxy will handle ModelArts authentication" -ForegroundColor Yellow
Write-Host "[INFO] Make sure backend server is running on port 3001`n" -ForegroundColor Yellow

# Check if backend is running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -Method GET -TimeoutSec 2 -ErrorAction Stop
    Write-Host "[OK] Backend server is running`n" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Backend server is NOT running!" -ForegroundColor Red
    Write-Host "Please start it first with: cd backend && node server.js`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "Starting Flutter web app...`n" -ForegroundColor Cyan
flutter run -d chrome
