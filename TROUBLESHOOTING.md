# Troubleshooting Guide

## Common Issues and Solutions

### ✅ CORS Issues - RESOLVED

**Symptom:** Getting CORS errors when trying to connect to Huawei Cloud API from Flutter Web.

**Solution:** The backend proxy server resolves this. Ensure:
- Backend server is running on port 3001
- Flutter app uses `http://localhost:3001/api` as base URL
- No direct calls to Huawei Cloud URL from Flutter

**Verification:**
- Check browser console - should see requests to `localhost:3001`, not Huawei Cloud URL
- No CORS policy errors in console

---

### ⚠️ Huawei Cloud API Endpoint Not Found

**Symptom:**
```json
{
  "error_msg": "The API does not exist or has not been published in the environment",
  "error_code": "APIG.0101"
}
```

**What This Means:**
- ✅ **CORS is working** - The request successfully reached Huawei Cloud
- ✅ **Backend proxy is working** - Request was forwarded correctly
- ⚠️ **Huawei Cloud API issue** - The endpoint doesn't exist or isn't published

**Possible Causes:**
1. The `/login` endpoint hasn't been created in Huawei Cloud APIG
2. The endpoint exists but isn't published to the environment
3. The endpoint path is incorrect
4. The AppCode doesn't have access to this endpoint

**Solutions:**

1. **Check Huawei Cloud APIG Console:**
   - Log into Huawei Cloud Console
   - Navigate to APIG (API Gateway)
   - Check if `/login` endpoint exists
   - Verify it's published to the correct environment

2. **Verify Endpoint Path:**
   - Check if the endpoint should be `/api/login` instead of `/login`
   - Check if there's a version prefix like `/v1/login`

3. **Check AppCode Permissions:**
   - Verify the AppCode has access to the login endpoint
   - Check if the endpoint requires different authentication

4. **Test with Signup:**
   - If signup works but login doesn't, the login endpoint likely needs to be created/published
   - Use signup as a reference for how login should be configured

**Temporary Workaround:**
If login endpoint doesn't exist yet, you can:
- Use signup to create accounts
- Implement login functionality later when the endpoint is available
- Or create a mock login endpoint for development

---

### 🔴 Backend Server Won't Start

**Symptom:** `npm start` fails or server doesn't start.

**Solutions:**

1. **Port Already in Use:**
   ```bash
   # Find process using port 3001
   # Windows PowerShell:
   netstat -ano | findstr :3001
   
   # Kill the process or change port in server.js
   ```

2. **Dependencies Not Installed:**
   ```bash
   cd backend
   npm install
   ```

3. **Node.js Version:**
   - Ensure Node.js v14 or higher is installed
   - Check: `node --version`

---

### 🔴 Flutter Can't Connect to Backend

**Symptom:** Flutter app shows connection errors.

**Solutions:**

1. **Backend Not Running:**
   - Ensure backend server is running: `cd backend && npm start`
   - Check `http://localhost:3001/health` in browser

2. **Wrong Base URL:**
   - Verify `api_service.dart` uses `http://localhost:3001/api`
   - Not the Huawei Cloud URL

3. **Firewall/Antivirus:**
   - Check if firewall is blocking localhost:3001
   - Temporarily disable to test

---

### 🔴 PowerShell curl Command Errors

**Symptom:** `curl -X POST` doesn't work in PowerShell.

**Solution:** PowerShell aliases `curl` to `Invoke-WebRequest`. Use:

```powershell
# Use Invoke-RestMethod (simpler):
Invoke-RestMethod -Uri http://localhost:3001/api/login `
  -Method POST `
  -ContentType "application/json" `
  -Body (@{email="test@example.com"; password="test123"} | ConvertTo-Json)

# Or use curl.exe (if available):
curl.exe -X POST http://localhost:3001/api/login `
  -H "Content-Type: application/json" `
  -d "{\"email\":\"test@example.com\",\"password\":\"test123\"}"
```

See `backend/README.md` for full PowerShell examples.

---

### 🔴 Disk Space Error (Flutter)

**Symptom:** `Flutter failed to write to a file... The target device is full.`

**Solutions:**

1. **Free Up Disk Space:**
   - Delete temporary files
   - Clear Flutter cache: `flutter clean`
   - Clear browser cache

2. **Change Temp Directory:**
   ```powershell
   # Set temp to D: drive (if more space)
   $env:TEMP = "D:\temp"
   $env:TMP = "D:\temp"
   flutter run -d chrome
   ```

---

### 🔴 Signup Works But Login Doesn't

**Symptom:** Signup endpoint works, but login returns API not found error.

**Cause:** Login endpoint not configured in Huawei Cloud APIG.

**Solution:**
1. Create `/login` endpoint in Huawei Cloud APIG console
2. Publish it to the same environment as signup
3. Ensure AppCode has access
4. Test again

---

## Debug Checklist

When troubleshooting, verify:

- [ ] Backend server is running (`http://localhost:3001/health` works)
- [ ] Backend logs show incoming requests
- [ ] Flutter app uses `localhost:3001/api` (not Huawei Cloud URL)
- [ ] No CORS errors in browser console
- [ ] Network tab shows requests to `localhost:3001`
- [ ] Huawei Cloud endpoints exist and are published
- [ ] AppCode is correct in `backend/server.js`
- [ ] Node.js version is v14+

---

## Getting Help

1. **Check Logs:**
   - Backend console logs show request/response details
   - Browser console shows client-side errors
   - Network tab shows request details

2. **Test Each Layer:**
   - Test backend directly with curl/PowerShell
   - Test Flutter app separately
   - Test Huawei Cloud API directly (if possible)

3. **Common Patterns:**
   - CORS errors = Backend not running or wrong URL
   - API not found = Huawei Cloud configuration issue
   - Connection refused = Backend not running or firewall
   - Timeout = Network or Huawei Cloud issue

---

## Still Having Issues?

1. Check all logs (backend console, browser console, network tab)
2. Verify each component separately (backend, Flutter, Huawei Cloud)
3. Test with simple curl/PowerShell commands first
4. Ensure all dependencies are installed
5. Check Huawei Cloud APIG console for endpoint status

