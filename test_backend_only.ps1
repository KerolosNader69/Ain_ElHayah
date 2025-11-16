# Backend-Only Test Script
# Tests the backend proxy server independently

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend Proxy Server Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check dependencies
Write-Host "[1/3] Checking backend dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "backend/node_modules")) {
    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    Push-Location backend
    npm install
    Pop-Location
}
Write-Host "✓ Backend dependencies ready" -ForegroundColor Green
Write-Host ""

# Start server
Write-Host "[2/3] Starting backend server..." -ForegroundColor Yellow
Write-Host "Server will run on http://localhost:3001" -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

Push-Location backend
node server.js
Pop-Location
