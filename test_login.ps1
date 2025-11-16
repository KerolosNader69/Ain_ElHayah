# Test Login Script

Write-Host "=== Testing Backend Login ===" -ForegroundColor Cyan

# Test with sample credentials
$body = @{
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

Write-Host "`nSending login request..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3001/api/login" -Method POST -Body $body -ContentType "application/json" -ErrorAction Stop
    Write-Host "`n✅ Login successful!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 10)
} catch {
    Write-Host "`n❌ Login failed!" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)"
    Write-Host "Error: $($_.Exception.Message)"
    
    # Try to read error response
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $errorBody = $reader.ReadToEnd()
    Write-Host "Response: $errorBody"
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Make sure backend is running: cd backend && node server.js"
Write-Host "2. Check if you have a registered user in Huawei Cloud"
Write-Host "3. Try registering first: POST http://localhost:3001/api/signup"
