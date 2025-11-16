# Start Manual Testing - Launches backend and Flutter web app
# This script starts both services needed for manual testing

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Starting Manual Testing Environment" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if backend is already running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -Method GET -TimeoutSec 2 -ErrorAction Stop
    Write-Host "[INFO] Backend server is already running on port 3001" -ForegroundColor Green
} catch {
    Write-Host "[INFO] Starting backend server..." -ForegroundColor Yellow
    Write-Host "Opening new terminal for backend server..." -ForegroundColor Gray
    
    # Start backend in a new PowerShell window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; node server.js"
    
    Write-Host "[INFO] Waiting for backend to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    
    # Verify backend started
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
        Write-Host "[OK] Backend server started successfully!" -ForegroundColor Green
    } catch {
        Write-Host "[WARN] Could not verify backend server - it may still be starting" -ForegroundColor Yellow
    }
}

Write-Host "`n[INFO] Starting Flutter web application..." -ForegroundColor Yellow
Write-Host "This will open Chrome with the app..." -ForegroundColor Gray
Write-Host "`nPress Ctrl+C to stop the Flutter app when done testing.`n" -ForegroundColor Cyan

# Start Flutter web app in proxy mode (this will block until stopped)
& .\run_web_proxy.ps1
