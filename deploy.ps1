# Flutter Web Deployment Script for Vercel (PowerShell)
# This script builds the Flutter web app and deploys it to Vercel

Write-Host "🚀 Starting deployment process..." -ForegroundColor Green
Write-Host ""

# Step 1: Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Step 2: Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Step 3: Build for web
Write-Host "🔨 Building Flutter web app (release mode)..." -ForegroundColor Yellow
flutter build web --release

# Step 4: Check if build was successful
if (-Not (Test-Path "build/web")) {
    Write-Host "❌ Build failed! build/web directory not found." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green
Write-Host ""

# Step 5: Deploy to Vercel
Write-Host "🌐 Deploying to Vercel..." -ForegroundColor Yellow
Write-Host ""

# Check if vercel CLI is installed
$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue
if (-Not $vercelInstalled) {
    Write-Host "⚠️  Vercel CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g vercel
}

# Deploy to production
vercel --prod

Write-Host ""
Write-Host "✨ Deployment complete!" -ForegroundColor Green
Write-Host "🎉 Your app should now be live on Vercel!" -ForegroundColor Cyan
