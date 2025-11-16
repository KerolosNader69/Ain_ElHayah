# Quick Disk Space Cleanup Script

Write-Host "=== Cleaning Flutter Cache ===" -ForegroundColor Cyan
flutter clean
flutter pub cache clean

Write-Host "`n=== Cleaning Temp Files ===" -ForegroundColor Cyan
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n=== Cleaning Flutter Tools Cache ===" -ForegroundColor Cyan
Remove-Item -Path "$env:LOCALAPPDATA\Temp\flutter_tools*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n=== Checking Disk Space ===" -ForegroundColor Cyan
Get-PSDrive C | Select-Object Name, @{Name="Used(GB)";Expression={[math]::Round($_.Used/1GB,2)}}, @{Name="Free(GB)";Expression={[math]::Round($_.Free/1GB,2)}}

Write-Host "`nDisk cleanup complete!" -ForegroundColor Green
