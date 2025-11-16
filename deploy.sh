#!/bin/bash

# Flutter Web Deployment Script for Vercel
# This script builds the Flutter web app and deploys it to Vercel

set -e  # Exit on error

echo "🚀 Starting deployment process..."
echo ""

# Step 1: Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Step 2: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Step 3: Build for web
echo "🔨 Building Flutter web app (release mode)..."
flutter build web --release

# Step 4: Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Build failed! build/web directory not found."
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Step 5: Deploy to Vercel
echo "🌐 Deploying to Vercel..."
echo ""

# Check if vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "⚠️  Vercel CLI not found. Installing..."
    npm install -g vercel
fi

# Deploy to production
vercel --prod

echo ""
echo "✨ Deployment complete!"
echo "🎉 Your app should now be live on Vercel!"
