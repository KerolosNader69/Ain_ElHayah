# Quick Start Script for Eye Wise Connect

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Eye Wise Connect - Quick Start" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Check if backend is running
Write-Host "Step 1: Checking backend..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -Method GET -TimeoutSec 2 -ErrorAction Stop
    Write-Host "✅ Backend is running!" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend is not running!" -ForegroundColor Red
    Write-Host "`nStarting backend..." -ForegroundColor Yellow
    Write-Host "Run this in a separate terminal:" -ForegroundColor Cyan
    Write-Host "  cd backend" -ForegroundColor White
    Write-Host "  node server.js" -ForegroundColor White
    Write-Host "`nPress Enter when backend is started..." -ForegroundColor Yellow
    Read-Host
}

# Step 2: Test new APIs
Write-Host "`nStep 2: Testing new APIs..." -ForegroundColor Yellow
node test_new_apis.js

# Step 3: Check disk space
Write-Host "`nStep 3: Checking disk space..." -ForegroundColor Yellow
$drive = Get-PSDrive C
$freeGB = [math]::Round($drive.Free/1GB, 2)
Write-Host "Free space on C: drive: $freeGB GB" -ForegroundColor White

if ($freeGB -lt 5) {
    Write-Host "⚠️  Low disk space detected!" -ForegroundColor Red
    Write-Host "Run cleanup script? (Y/N)" -ForegroundColor Yellow
    $cleanup = Read-Host
    if ($cleanup -eq 'Y' -or $cleanup -eq 'y') {
        .\free_disk_space.ps1
    }
}

# Step 4: Ready to run
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Ready to Run!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Run Flutter app with:" -ForegroundColor Yellow
Write-Host "  flutter run -d chrome`n" -ForegroundColor White

Write-Host "Features to test:" -ForegroundColor Yellow
Write-Host "  ✓ Questionnaire Analysis (NEW)" -ForegroundColor Green
Write-Host "  ✓ Mock Retinal Analysis (NEW)" -ForegroundColor Green
Write-Host "  ✓ Doctor Appointment Booking" -ForegroundColor Green
Write-Host "  ✓ Voice Chat" -ForegroundColor Green
Write-Host "  ✓ AI Chatbot" -ForegroundColor Green

Write-Host "`nPress Enter to continue..." -ForegroundColor Cyan
Read-Host
