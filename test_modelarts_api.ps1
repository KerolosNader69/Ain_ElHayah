# Test ModelArts API Directly
# This script runs a diagnostic test of the ModelArts service

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ModelArts API Diagnostic Test" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "This test will:" -ForegroundColor Yellow
Write-Host "  1. Obtain IAM token using credentials from env.json" -ForegroundColor Gray
Write-Host "  2. Call ModelArts inference API directly" -ForegroundColor Gray
Write-Host "  3. Check service deployment status`n" -ForegroundColor Gray

# Check if env.json exists
if (-not (Test-Path "env.json")) {
    Write-Host "[ERROR] env.json not found" -ForegroundColor Red
    Write-Host "Please ensure env.json exists in the project root`n" -ForegroundColor Yellow
    exit 1
}

# Run the diagnostic test
Write-Host "Running diagnostic test...`n" -ForegroundColor Cyan
node backend/test_modelarts_direct.js

Write-Host "`nDiagnostic test complete.`n" -ForegroundColor Cyan
