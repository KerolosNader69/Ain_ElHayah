# Vercel Deployment Guide for EyeWise Connect

## Overview

This guide covers deploying the EyeWise Connect Flutter web application to Vercel. The deployment includes both the frontend Flutter web app and the Node.js backend API.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Vercel Platform                       │
│                                                          │
│  ┌────────────────────┐      ┌────────────────────┐   │
│  │  Flutter Web App   │      │  Backend API       │   │
│  │  (Static Site)     │◄────►│  (Serverless)      │   │
│  │  /build/web        │      │  /api/*            │   │
│  └────────────────────┘      └────────────────────┘   │
│           │                           │                 │
└───────────┼───────────────────────────┼─────────────────┘
            │                           │
            └───────────┬───────────────┘
                        │
                        ▼
            ┌───────────────────────┐
            │   Huawei Cloud        │
            │   - APIG              │
            │   - ModelArts         │
            │   - SIS               │
            │   - IAM               │
            └───────────────────────┘
```

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Flutter SDK**: Version 3.0+ installed and configured
3. **Node.js**: Version 18+ for backend functions
4. **Git**: Project in a Git repository (GitHub, GitLab, or Bitbucket)
5. **Huawei Cloud**: Active account with configured services

## Step 1: Build Flutter Web App

Before deploying, build your Flutter web app:

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web (production)
flutter build web --release
```

This creates optimized files in the `build/web` directory.

## Step 2: Deploy to Vercel

### Option A: Deploy via Vercel CLI (Recommended)

1. **Install Vercel CLI**:
```bash
npm install -g vercel
```

2. **Login to Vercel**:
```bash
vercel login
```

3. **Deploy**:
```bash
vercel
```

Follow the prompts:
- Set up and deploy? **Y**
- Which scope? Select your account
- Link to existing project? **N** (first time) or **Y** (subsequent)
- Project name? Enter your desired name (e.g., `eye-wise-connect`)
- Directory? Press Enter (use current directory)
- Override settings? **N**

4. **Deploy to Production**:
```bash
vercel --prod
```

### Option B: Deploy via Vercel Dashboard

1. **Push to Git**:
```bash
git add .
git commit -m "Ready for deployment"
git push origin main
```

2. **Import Project**:
   - Go to [vercel.com/new](https://vercel.com/new)
   - Click "Import Project"
   - Select your Git repository
   - Configure project:
     - Framework Preset: **Other**
     - Build Command: `flutter build web --release`
     - Output Directory: `build/web`
     - Install Command: Leave empty or `flutter pub get`

3. **Deploy**:
   - Click "Deploy"
   - Wait for build to complete

## Step 3: Configure Environment Variables (if needed)

If your app uses environment variables:

1. Go to your project settings on Vercel
2. Navigate to "Environment Variables"
3. Add your variables:
   - `HUAWEI_ACCESS_KEY`
   - `HUAWEI_SECRET_KEY`
   - `BACKEND_URL`
   - etc.

## Step 4: Custom Domain (Optional)

1. Go to your project settings
2. Navigate to "Domains"
3. Add your custom domain
4. Follow DNS configuration instructions

## Vercel Configuration Files

### vercel.json
Already configured in your project:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "build/web/**",
      "use": "@vercel/static"
    }
  ],
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/build/web/$1"
    }
  ]
}
```

### .vercelignore
Created to exclude unnecessary files from deployment.

## Troubleshooting

### Build Fails

**Issue**: Flutter build command not found
**Solution**: Vercel doesn't have Flutter pre-installed. You need to build locally and commit the `build/web` folder, or use a custom build script.

**Recommended Approach**: Build locally before deploying:
```bash
flutter build web --release
git add build/web -f
git commit -m "Add web build"
git push
```

### 404 Errors on Routes

**Issue**: Direct navigation to routes returns 404
**Solution**: The `vercel.json` rewrites configuration handles this. Ensure it's properly configured.

### Assets Not Loading

**Issue**: Images or fonts not loading
**Solution**: 
- Check that assets are in `build/web` after build
- Verify `pubspec.yaml` assets configuration
- Use relative paths in your code

## Continuous Deployment

Once set up, Vercel automatically deploys:
- **Production**: When you push to `main` branch
- **Preview**: When you push to other branches or open PRs

## Post-Deployment Checklist

- [ ] Test all routes and navigation
- [ ] Verify appointment booking flow works
- [ ] Check responsive design on different devices
- [ ] Test doctor profile and booking features
- [ ] Verify images and assets load correctly
- [ ] Check console for any errors
- [ ] Test on different browsers (Chrome, Firefox, Safari, Edge)

## Useful Commands

```bash
# Build for web
flutter build web --release

# Deploy to Vercel (preview)
vercel

# Deploy to production
vercel --prod

# View deployment logs
vercel logs

# List deployments
vercel ls

# Remove deployment
vercel rm [deployment-url]
```

## Backend Deployment

If you need to deploy the Node.js backend separately:

1. Create a separate Vercel project for backend
2. Or use Vercel Serverless Functions
3. Or deploy backend to another service (Heroku, Railway, etc.)
4. Update `BACKEND_URL` environment variable

## Support

- Vercel Docs: https://vercel.com/docs
- Flutter Web Docs: https://docs.flutter.dev/platform-integration/web
- Issues: Check Vercel deployment logs for errors

## Quick Deploy Script

Create a `deploy.sh` file:

```bash
#!/bin/bash
echo "Building Flutter web app..."
flutter clean
flutter pub get
flutter build web --release

echo "Deploying to Vercel..."
vercel --prod

echo "Deployment complete!"
```

Make it executable:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

**Note**: Since Flutter requires a build step and Vercel doesn't have Flutter pre-installed, the recommended approach is to build locally and commit the `build/web` folder, or use GitHub Actions to build and deploy automatically.
