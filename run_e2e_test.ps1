# Complete End-to-End Test Runner
# This script guides you through the complete testing process

param(
    [switch]$SkipBackendTest,
    [switch]$AutoStart
)

$ErrorActionPreference = "Continue"

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Number, [string]$Text)
    Write-Host "[$Number] $Text" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Text)
    Write-Host "✓ $Text" -ForegroundColor Green
}

function Write-Error {
    param([string]$Text)
    Write-Host "✗ $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "  $Text" -ForegroundColor Gray
}

# Main test flow
Write-Header "ModelArts E2E Integration Test Suite"

Write-Host "This script will guide you through testing the complete ModelArts integration." -ForegroundColor White
Write-Host ""
Write-Host "Test phases:" -ForegroundColor White
Write-Host "  1. Backend proxy standalone test" -ForegroundColor Gray
Write-Host "  2. Backend server startup" -ForegroundColor Gray
Write-Host "  3. Flutter web application test" -ForegroundColor Gray
Write-Host "  4. End-to-end verification" -ForegroundColor Gray
Write-Host ""

if (-not $AutoStart) {
    Write-Host "Press any key to begin..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Phase 1: Backend Proxy Test
if (-not $SkipBackendTest) {
    Write-Header "Phase 1: Backend Proxy Standalone Test"
    
    Write-Step "1/4" "Checking backend dependencies..."
    if (-not (Test-Path "backend/node_modules")) {
        Write-Info "Installing backend dependencies..."
        Push-Location backend
        npm install
        Pop-Location
    }
    Write-Success "Backend dependencies ready"
    
    Write-Step "2/4" "Running backend proxy test..."
    Write-Info "This will test the proxy without the Flutter app"
    Write-Host ""
    
    Push-Location backend
    node test_proxy.js
    $testResult = $LASTEXITCODE
    Pop-Location
    
    Write-Host ""
    if ($testResult -eq 0) {
        Write-Success "Backend proxy test passed!"
    } else {
        Write-Error "Backend proxy test failed"
        Write-Host ""
        Write-Host "Please check the error messages above and fix any issues before continuing." -ForegroundColor Yellow
        Write-Host "Common issues:" -ForegroundColor White
        Write-Info "- Backend server not running"
        Write-Info "- Invalid credentials in env.json"
        Write-Info "- Network connectivity issues"
        Write-Host ""
        exit 1
    }
    
    Write-Host ""
    Write-Host "Press any key to continue to Phase 2..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Phase 2: Start Backend Server
Write-Header "Phase 2: Backend Server Startup"

Write-Step "3/4" "Starting backend server..."
Write-Info "Server will run on http://localhost:3001"
Write-Host ""

$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location backend
    node server.js
}

Write-Info "Waiting for server to initialize..."
Start-Sleep -Seconds 3

Write-Step "4/4" "Verifying backend health..."
try {
    $health = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get -TimeoutSec 5
    Write-Success "Backend server is healthy"
    Write-Info "Status: $($health.status)"
    Write-Info "Message: $($health.message)"
} catch {
    Write-Error "Backend health check failed: $_"
    Stop-Job $backendJob
    Remove-Job $backendJob
    exit 1
}

# Phase 3: Flutter Web Instructions
Write-Header "Phase 3: Flutter Web Application Test"

Write-Host "The backend server is now running." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "1. Open a NEW terminal window" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Run the Flutter web app:" -ForegroundColor Cyan
Write-Host "   flutter run -d chrome --web-port 8080" -ForegroundColor White
Write-Host ""
Write-Host "3. In the Flutter app:" -ForegroundColor Cyan
Write-Info "a. Navigate to the diagnosis screen"
Write-Info "b. Select 'Retinal Scan' model"
Write-Info "c. Upload a test retinal image"
Write-Info "d. Click 'Analyze'"
Write-Host ""
Write-Host "4. Verify the following:" -ForegroundColor Cyan
Write-Info "✓ Image uploads successfully"
Write-Info "✓ Loading indicator appears"
Write-Info "✓ Backend logs show the request (watch this window)"
Write-Info "✓ Results display in the UI"
Write-Info "✓ No errors in browser console (F12)"
Write-Host ""

# Phase 4: Monitor Backend Logs
Write-Header "Phase 4: Monitoring Backend Logs"

Write-Host "Backend logs will appear below." -ForegroundColor Yellow
Write-Host "Watch for:" -ForegroundColor White
Write-Info "- POST /api/modelarts/infer"
Write-Info "- IAM token messages"
Write-Info "- ModelArts Response Status"
Write-Host ""
Write-Host "Press Ctrl+C when testing is complete" -ForegroundColor Yellow
Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor DarkGray

try {
    while ($true) {
        $output = Receive-Job $backendJob
        if ($output) {
            Write-Host $output
        }
        Start-Sleep -Milliseconds 500
    }
} finally {
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Header "Test Session Complete"
    
    Write-Step "Cleanup" "Stopping backend server..."
    Stop-Job $backendJob
    Remove-Job $backendJob
    Write-Success "Backend server stopped"
    
    Write-Host ""
    Write-Host "Test Summary:" -ForegroundColor White
    Write-Host ""
    Write-Host "Please fill out the test execution report:" -ForegroundColor Yellow
    Write-Host "  TEST_EXECUTION_REPORT.md" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "For detailed test procedures, see:" -ForegroundColor Yellow
    Write-Host "  backend/E2E_TEST_GUIDE.md" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Thank you for testing!" -ForegroundColor Green
    Write-Host ""
}
