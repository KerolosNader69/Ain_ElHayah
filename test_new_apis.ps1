# Test New APIs - PowerShell Version

Write-Host "`n🧪 Testing New APIs`n" -ForegroundColor Cyan

# Test 1: Questionnaire Analysis
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Test 1: Questionnaire Analysis API" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

$questionnaireBody = @{
    answers = @{
        for_whom = "self"
        gender = "male"
        age = @{
            years = 45
            months = 0
            days = 0
        }
        recent_injury = "no"
        smoking_10y = "no"
        family_allergy = "yes"
        obesity = "no"
        diabetes = "yes"
        hypertension = "yes"
        headache = @{
            type = "Eye strain"
            severity = "Moderate"
        }
        other_symptoms = "Blurry vision, dry eyes, redness"
        country = "Egypt"
        locale = "en"
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3001/api/questionnaire/analyze" `
        -Method POST `
        -Body $questionnaireBody `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "`n✅ Test PASSED" -ForegroundColor Green
    Write-Host "`nResponse:" -ForegroundColor White
    Write-Host ($response | ConvertTo-Json -Depth 10)
    
    if ($response.conditions) {
        Write-Host "`nFound $($response.conditions.Count) conditions:" -ForegroundColor Green
        foreach ($condition in $response.conditions) {
            $prob = [math]::Round($condition.probability * 100, 1)
            Write-Host "  - $($condition.name) ($prob%)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "`n❌ Test FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nMake sure backend is running:" -ForegroundColor Yellow
    Write-Host "  cd backend" -ForegroundColor White
    Write-Host "  node server.js" -ForegroundColor White
}

# Test 2: Mock Retinal Analysis
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Test 2: Mock Retinal Analysis API" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

# Small 1x1 pixel PNG in base64
$mockImage = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

$retinalBody = @{
    imageBase64 = $mockImage
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3001/api/retinal/analyze" `
        -Method POST `
        -Body $retinalBody `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    Write-Host "`n✅ Test PASSED" -ForegroundColor Green
    Write-Host "`nResponse:" -ForegroundColor White
    Write-Host ($response | ConvertTo-Json -Depth 10)
    
    if ($response.conditions) {
        $conf = [math]::Round($response.confidence * 100, 1)
        Write-Host "`nOverall Confidence: $conf%" -ForegroundColor Green
        Write-Host "Found $($response.conditions.Count) conditions:" -ForegroundColor Green
        foreach ($condition in $response.conditions) {
            $condConf = [math]::Round($condition.confidence * 100, 1)
            Write-Host "  - $($condition.name) [$($condition.severity)] ($condConf%)" -ForegroundColor White
        }
    }
    
    if ($response.disclaimer) {
        Write-Host "`n⚠️  $($response.disclaimer)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "`n❌ Test FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "All tests complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host "`n💡 Next steps:" -ForegroundColor Yellow
Write-Host "1. Free up disk space: .\free_disk_space.ps1" -ForegroundColor White
Write-Host "2. Run Flutter app: flutter run -d chrome" -ForegroundColor White
Write-Host "3. Test questionnaire feature in the app" -ForegroundColor White
Write-Host "4. Test retinal diagnosis feature in the app" -ForegroundColor White
Write-Host ""
