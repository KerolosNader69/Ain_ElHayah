# 🚀 Deploy to Vercel NOW - Quick Start

## Fastest Way to Deploy (3 Steps)

### Step 1: Build Your App
```bash
flutter build web --release
```

### Step 2: Install Vercel CLI (if not installed)
```bash
npm install -g vercel
```

### Step 3: Deploy!
```bash
vercel --prod
```

That's it! Your app will be live in minutes.

---

## Alternative: Use the Deployment Script

### On Windows (PowerShell):
```powershell
.\deploy.ps1
```

### On Mac/Linux:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## First Time Setup

If this is your first deployment:

1. **Login to Vercel**:
   ```bash
   vercel login
   ```

2. **Run deployment**:
   ```bash
   vercel
   ```
   
3. **Answer the prompts**:
   - Set up and deploy? → **Y**
   - Which scope? → Select your account
   - Link to existing project? → **N**
   - Project name? → `eye-wise-connect` (or your choice)
   - Directory? → Press Enter
   - Override settings? → **N**

4. **Deploy to production**:
   ```bash
   vercel --prod
   ```

---

## What Happens During Deployment?

1. ✅ Flutter builds your web app
2. ✅ Optimizes assets and code
3. ✅ Uploads to Vercel's CDN
4. ✅ Assigns a URL (e.g., `your-app.vercel.app`)
5. ✅ Your app is live!

---

## After Deployment

Your app will be available at:
- **Production**: `https://your-project-name.vercel.app`
- **Preview**: Unique URL for each deployment

### Test Your Deployment:
- ✅ Navigate to different pages
- ✅ Test appointment booking flow
- ✅ Check doctor profiles
- ✅ Try booking and canceling appointments
- ✅ Test on mobile and desktop

---

## Troubleshooting

### "vercel: command not found"
```bash
npm install -g vercel
```

### "flutter: command not found"
Make sure Flutter is installed and in your PATH.

### Build fails
```bash
flutter clean
flutter pub get
flutter build web --release
```

---

## Need Help?

Check the full guide: `VERCEL_DEPLOYMENT_GUIDE.md`

---

## 🎉 Ready to Deploy?

Run this command now:
```bash
flutter build web --release && vercel --prod
```

Your app will be live in minutes!
