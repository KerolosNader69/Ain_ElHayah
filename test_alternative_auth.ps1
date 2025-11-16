# Test Alternative Authentication Methods
# This tests if ModelArts service works without IAM tokens

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Alternative Authentication" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "This will test if the ModelArts service:" -ForegroundColor Yellow
Write-Host "  1. Works without authentication (public access)" -ForegroundColor Gray
Write-Host "  2. Works with API Key authentication" -ForegroundColor Gray
Write-Host "  3. Requires IAM token authentication`n" -ForegroundColor Gray

node backend/test_ak_sk_signature.js

Write-Host "`nTest complete.`n" -ForegroundColor Cyan
