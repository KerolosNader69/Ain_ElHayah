# Troubleshooting ModelArts Integration

## Issue: "ModelArts configuration is missing or incomplete"

### Solution: Use Proxy Mode (Recommended)

The web app now supports proxy mode where the backend handles all authentication.

**Steps:**

1. **Ensure backend is running:**
   ```powershell
   cd backend
   node server.js
   ```

2. **Start Flutter web in proxy mode:**
   ```powershell
   .\run_web_proxy.ps1
   ```
   
   Or use the automated script:
   ```powershell
   .\start_manual_testing.ps1
   ```

3. **Verify env.json has ModelArts credentials:**
   ```json
   {
     "MODELARTS_PROJECT_ID": "59dcb311da5e4ca6b8db8bbc7a7712d7",
     "MODELARTS_ACCESS_KEY": "HPUALP3GCEZ2AMWETEHI",
     "MODELARTS_SECRET_KEY": "ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM",
     "MODELARTS_SERVICE_ID": "c3ea302b-d98b-4f80-85bb-552e9ca8e0c9",
     "MODELARTS_REGION": "ap-southeast-3"
   }
   ```

### How It Works

- **Web App:** Sends image to backend proxy (no credentials needed)
- **Backend:** Reads credentials from env.json
- **Backend:** Obtains IAM token and calls ModelArts
- **Backend:** Returns results to web app

---

## Alternative: Use Compile-Time Variables

If you want to run without the backend proxy:

```powershell
.\run_web_simple.ps1
```

This script includes all --dart-define flags with credentials.

---

## Backend Logs to Check

When analysis runs, backend should show:

```
[timestamp] POST /api/modelarts/infer - Service: c3ea302b...
[timestamp] Using credentials from env.json (if not in request)
[timestamp] Obtaining new IAM token... (first time)
[timestamp] IAM token obtained successfully
[timestamp] ModelArts Response Status: 200
```

---

## Browser Console Logs to Check

Open DevTools (F12) and check console:

```
[RetinaInferenceService-Web] Initializing ModelArts service...
[RetinaInferenceService-Web] No compile-time config found, using backend proxy mode
[RetinaInferenceService-Web] Backend proxy will handle authentication
[RetinaInferenceService-Web] Initialization complete (proxy mode)
[HuaweiModelArtsService] Using backend proxy for web
[DiagnosisProvider] Using real ModelArts inference for retinal model
[DiagnosisProvider] Diagnosis complete - Class: XXX, Confidence: 0.XX
```

---

## Common Issues

### 1. Backend Not Running

**Symptom:** Network error, can't connect to localhost:3001

**Solution:**
```powershell
cd backend
node server.js
```

Wait for: `✅ Server is running on port 3001`

### 2. Missing env.json

**Symptom:** Backend logs show "Could not load env.json"

**Solution:** Ensure env.json exists in project root with all ModelArts fields

### 3. Wrong Credentials

**Symptom:** Backend logs show 401 or authentication error

**Solution:** Verify credentials in env.json are correct

### 4. Service Not Deployed

**Symptom:** Backend logs show 404 or service not found

**Solution:** Verify MODELARTS_SERVICE_ID in env.json matches your deployed service

### 5. CORS Error

**Symptom:** Browser console shows CORS policy error

**Solution:** Backend should have CORS enabled (already configured in server.js)

---

## Testing the Setup

### 1. Test Backend Health
```powershell
Invoke-WebRequest -Uri "http://localhost:3001/health" -Method GET
```

Should return:
```json
{
  "status": "OK",
  "message": "Server is running",
  "timestamp": "..."
}
```

### 2. Test Backend Proxy (with curl or Postman)
```powershell
$body = @{
    imageBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:3001/api/modelarts/infer" -Method POST -Body $body -ContentType "application/json"
```

Should return ModelArts response (or error if image is invalid)

### 3. Test Full Flow
1. Start backend
2. Start web app with `.\run_web_proxy.ps1`
3. Navigate to Diagnosis page
4. Select "Retinal Model"
5. Upload retinal image
6. Click "Analyze"
7. Check backend console for logs
8. Check browser console for logs
9. Verify results display

---

## Quick Fixes

### Reset Everything
```powershell
# Stop all processes
# Close all terminals

# Restart backend
cd backend
node server.js

# In new terminal, restart web app
.\run_web_proxy.ps1
```

### Clear Browser Cache
1. Open DevTools (F12)
2. Right-click refresh button
3. Select "Empty Cache and Hard Reload"

### Verify Configuration
```powershell
.\verify_manual_test_setup.ps1
```

All checks should pass.

---

## Diagnostic Tests

### Test ModelArts API Directly
```powershell
.\test_modelarts_api.ps1
```

This will:
1. Obtain IAM token using your credentials
2. Call ModelArts API directly
3. Check service deployment status
4. Show detailed error messages

### Test Backend Configuration
```powershell
.\test_backend_config.ps1
```

This verifies the backend can read env.json and proxy requests.

### Test End-to-End
```powershell
.\test_modelarts_e2e.ps1
```

This tests the full flow from Flutter app to ModelArts.

---

## Still Not Working?

1. **Run diagnostic test first**:
   ```powershell
   .\test_modelarts_api.ps1
   ```

2. **Check backend console** for error messages

3. **Check browser console (F12)** for error messages

4. **Verify env.json** has all required fields

5. **Verify backend is running** on port 3001

---

## Contact Information

If issues persist, provide:
- Backend console output
- Browser console output (F12)
- env.json (with credentials redacted)
- Steps to reproduce
