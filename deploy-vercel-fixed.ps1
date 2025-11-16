# Fixed Vercel Deployment Script for Flutter Web
# This builds locally and deploys the pre-built files

Write-Host "🚀 Starting Vercel deployment..." -ForegroundColor Green
Write-Host ""

# Step 1: Clean and build
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "🔨 Building Flutter web (release mode)..." -ForegroundColor Yellow
flutter build web --release

# Check if build was successful
if (-Not (Test-Path "build/web/index.html")) {
    Write-Host "❌ Build failed! build/web/index.html not found." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green
Write-Host ""

# Step 2: Deploy from build/web directory
Write-Host "🌐 Deploying to Vercel..." -ForegroundColor Yellow
Write-Host ""

# Navigate to build/web
Set-Location build/web

# Deploy to production
vercel --prod

# Go back to root
Set-Location ../..

Write-Host ""
Write-Host "✨ Deployment complete!" -ForegroundColor Green
Write-Host "🎉 Your app is now live on Vercel!" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Tip: Your app URL will be shown above" -ForegroundColor Yellow
