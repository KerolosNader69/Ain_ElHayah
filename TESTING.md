# Testing Guide: Backend Proxy Server

This guide provides step-by-step instructions for testing the backend proxy server and the Flutter app integration.

## 📋 Prerequisites

- Node.js (v14 or higher) installed
- npm (comes with Node.js)
- Flutter SDK installed
- A terminal/command prompt

## 🧪 Part 1: Backend Testing

### Step 1: Start the Backend Server

Open Terminal 1 and navigate to the backend directory:

```bash
cd backend
```

Install dependencies (if not already installed):

```bash
npm install
```

Start the server:

```bash
npm start
```

**Expected Output:**
```
============================================================
🚀 Eye Wise Connect Backend Proxy Server
============================================================
📍 Server URL:        http://localhost:3001
🏥 Health Check:       http://localhost:3001/health
📝 Available Endpoints:
   - GET  /health
   - POST /api/signup
   - POST /api/login
🌐 Target Huawei URL:   https://bfea85780dee4f95b5e5ce77704934e9.apic.af-south-1.huaweicloudapis.com
============================================================
✅ Server is running on port 3001
```

### Step 2: Test Health Endpoint

Open Terminal 2 and test the health endpoint:

**Using cURL (Linux/Mac/Git Bash):**
```bash
curl http://localhost:3001/health
```

**Using PowerShell (Windows):**
```powershell
Invoke-WebRequest -Uri http://localhost:3001/health -Method GET
```

**Using Browser:**
Open `http://localhost:3001/health` in your browser. You should see the JSON response.

**Expected Response:**
```json
{
  "status": "OK",
  "message": "Server is running",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Step 3: Test Signup Endpoint

Test the signup endpoint with a sample request:

**Using cURL (Linux/Mac/Git Bash):**
```bash
curl -X POST http://localhost:3001/api/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"test123"}'
```

**Using PowerShell (Windows):**
```powershell
$body = @{
    username = "testuser"
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:3001/api/signup `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

**Expected Behavior:**
- Request is forwarded to Huawei Cloud
- Response is returned (success or error depending on Huawei Cloud)
- Check Terminal 1 for request/response logs

**Example Success Response:**
```json
{
  "success": true,
  "data": {
    "message": "User created successfully"
  }
}
```

**Example Error Response:**
```json
{
  "success": false,
  "error": "User already exists"
}
```

### Step 4: Test Login Endpoint

Test the login endpoint:

**Using cURL (Linux/Mac/Git Bash):**
```bash
curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

**Using PowerShell (Windows):**
```powershell
$body = @{
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:3001/api/login `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

### Step 5: Test Error Handling

Test missing fields validation:

```bash
curl -X POST http://localhost:3001/api/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser"}'
```

**Expected Response (400 Bad Request):**
```json
{
  "success": false,
  "error": "Missing required fields. Please provide username, email, and password."
}
```

Test invalid email format:

```bash
curl -X POST http://localhost:3001/api/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"invalid-email","password":"test123"}'
```

**Expected Response (400 Bad Request):**
```json
{
  "success": false,
  "error": "Invalid email format"
}
```

Test short password:

```bash
curl -X POST http://localhost:3001/api/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"123"}'
```

**Expected Response (400 Bad Request):**
```json
{
  "success": false,
  "error": "Password must be at least 6 characters"
}
```

## 🧪 Part 2: Flutter App Testing

### Step 1: Verify Backend Server is Running

Before testing the Flutter app, ensure the backend server is running on port 3001 (from Part 1, Step 1).

### Step 2: Run Flutter Web App

Open Terminal 3 and navigate to the project root:

```bash
cd eye-wise-connect-main
```

Run the Flutter app in Chrome:

```bash
flutter run -d chrome
```

**Alternative:** If you have a specific Chrome device:
```bash
flutter devices  # List available devices
flutter run -d chrome  # Run on Chrome
```

The app should open in your default browser (usually Chrome).

### Step 3: Test Signup Flow

1. Navigate to the signup screen in the Flutter app
2. Fill in the signup form:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `test123`
3. Click the signup button

**Expected Behavior:**
- ✅ No CORS errors in browser console
- ✅ Request is sent to `http://localhost:3001/api/signup`
- ✅ Backend proxy forwards request to Huawei Cloud
- ✅ Response is returned to Flutter app
- ✅ Success or error message is displayed

### Step 4: Check Browser Console

Open browser DevTools (F12) and check the Console tab:

**What to Look For:**
- ✅ No CORS errors
- ✅ Network requests to `localhost:3001`
- ✅ No errors related to AppCode or authentication

**What You Should NOT See:**
- ❌ CORS policy errors
- ❌ "Access to fetch blocked" errors
- ❌ Direct requests to Huawei Cloud URL

### Step 5: Check Network Tab

In browser DevTools, go to the Network tab:

1. Filter by "Fetch/XHR"
2. Look for requests to `localhost:3001`
3. Click on a request to see details:
   - **Request URL**: Should be `http://localhost:3001/api/signup`
   - **Request Headers**: Should only include `Content-Type: application/json`
   - **Response**: Should show the response from Huawei Cloud

### Step 6: Check Backend Logs

In Terminal 1 (where the backend server is running), you should see logs like:

```
[2024-01-01T00:00:00.000Z] POST /api/signup - Username: testuser, Email: test@example.com
[2024-01-01T00:00:00.000Z] Response Status: 200
```

## ✅ Verification Checklist

After testing, verify the following:

### Backend Server
- [ ] Backend starts without errors on port 3001
- [ ] `/health` endpoint returns OK status
- [ ] `/api/signup` endpoint accepts POST requests
- [ ] Backend logs show requests being forwarded
- [ ] Error handling works (missing fields, invalid email, short password)

### Flutter App
- [ ] Flutter app connects to `localhost:3001` (not Huawei Cloud directly)
- [ ] No CORS errors in browser console
- [ ] Signup form works end-to-end
- [ ] Success messages display correctly
- [ ] Error messages display correctly
- [ ] Network tab shows requests to `localhost:3001`

### Integration
- [ ] Requests flow: Flutter → Backend → Huawei Cloud
- [ ] Responses flow: Huawei Cloud → Backend → Flutter
- [ ] AppCode is not visible in Flutter app code
- [ ] AppCode is not visible in browser DevTools

## 🐛 Troubleshooting

### Backend Server Won't Start

**Error: Port 3001 already in use**

**Solution:**
1. Find the process using port 3001:
   ```bash
   # Windows
   netstat -ano | findstr :3001
   
   # Mac/Linux
   lsof -i :3001
   ```
2. Kill the process or change the port in `backend/server.js`

**Error: Cannot find module 'express'**

**Solution:**
```bash
cd backend
npm install
```

### Flutter App Can't Connect

**Error: Connection refused**

**Solution:**
1. Verify backend server is running (`http://localhost:3001/health`)
2. Check that Flutter app is using `http://localhost:3001/api` as base URL
3. Ensure no firewall is blocking the connection

**Error: CORS errors still appearing**

**Solution:**
1. Verify backend server has CORS enabled (`app.use(cors())`)
2. Restart the backend server
3. Clear browser cache and reload

### Signup Not Working

**Error: 400 Bad Request**

**Solution:**
- Check that all required fields are provided
- Verify email format is valid
- Ensure password is at least 6 characters

**Error: 500 Internal Server Error**

**Solution:**
1. Check backend server logs for error details
2. Verify Huawei Cloud API is accessible
3. Check that AppCode is correct in `backend/server.js`

## 📊 Expected Flow Diagram

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│   Flutter   │         │    Backend   │         │   Huawei     │
│     App     │         │    Proxy     │         │    Cloud     │
└──────┬──────┘         └──────┬───────┘         └──────┬───────┘
       │                       │                        │
       │ POST /api/signup      │                        │
       │ {username, email,     │                        │
       │  password}            │                        │
       ├──────────────────────>│                        │
       │                       │                        │
       │                       │ POST /signup           │
       │                       │ X-Apig-AppCode: ...    │
       │                       │ {username, email,       │
       │                       │  password}             │
       │                       ├───────────────────────>│
       │                       │                        │
       │                       │                        │ Response
       │                       │<───────────────────────┤
       │                       │                        │
       │ Response              │                        │
       │<──────────────────────┤                        │
       │                       │                        │
```

## 🎯 Success Criteria

The implementation is successful when:

1. ✅ Backend server runs without errors
2. ✅ Health endpoint returns OK
3. ✅ Signup endpoint forwards requests correctly
4. ✅ Flutter app connects to backend (not Huawei Cloud)
5. ✅ No CORS errors in browser console
6. ✅ Signup form works end-to-end
7. ✅ Error messages display correctly
8. ✅ AppCode is not exposed in client-side code

## 📝 Next Steps

After successful testing:

1. **Production Deployment:**
   - Deploy backend to a hosting service (Heroku, Railway, Render, etc.)
   - Update Flutter app's `_baseUrl` to production URL
   - Use environment variables for AppCode

2. **Enhancements:**
   - Add rate limiting
   - Configure CORS for production domain
   - Add authentication/authorization
   - Set up monitoring and logging
   - Implement HTTPS

3. **Documentation:**
   - Update deployment guides
   - Document production configuration
   - Create API documentation

## 📚 Related Documentation

- `backend/README.md` - Backend server documentation
- `SECURITY.md` - Security architecture and best practices
- `README.md` - Project overview

---

**Happy Testing! 🚀**

