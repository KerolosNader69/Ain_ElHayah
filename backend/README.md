# Eye Wise Connect Backend Proxy Server

This is a Node.js/Express backend proxy server that handles API requests between the Flutter Web app and Huawei Cloud APIG. It solves CORS issues and keeps sensitive credentials (AppCode) secure on the server.

## 🎯 Purpose

- **CORS Resolution**: Flutter Web apps cannot directly call Huawei Cloud APIs due to CORS restrictions
- **Security**: Keeps the AppCode secure on the server, not exposed in client-side code
- **Proxy Layer**: Acts as an intermediary between the Flutter app and Huawei Cloud

## 📋 Prerequisites

- Node.js (v14 or higher)
- npm (comes with Node.js)

## 🚀 Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

## ▶️ Running the Server

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on **port 3001** by default.

## 📡 Available Endpoints

### Health Check
```
GET /health
```
Returns server status and confirms the server is running.

**Response:**
```json
{
  "status": "OK",
  "message": "Server is running",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Signup
```
POST /api/signup
```
Proxies signup requests to Huawei Cloud APIG.

**Request Body:**
```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "test123"
}
```

**Response:**
Returns the exact response from Huawei Cloud APIG (status code and body).

### Login
```
POST /api/login
```
Proxies login requests to Huawei Cloud APIG.

**Request Body:**
```json
{
  "email": "test@example.com",
  "password": "test123"
}
```

**Response:**
Returns the exact response from Huawei Cloud APIG (status code and body).

**Note:** If you receive an error like `"The API does not exist or has not been published in the environment"`, this means:
- ✅ CORS is working correctly (request reached Huawei Cloud)
- ✅ Backend proxy is working correctly
- ⚠️ The `/login` endpoint may not be configured or published in your Huawei Cloud APIG environment
- Check your Huawei Cloud APIG console to ensure the login endpoint is published

See `TROUBLESHOOTING.md` for more details.

## 🧪 Testing with cURL

### Test Health Endpoint

**Linux/Mac/Git Bash:**
```bash
curl http://localhost:3001/health
```

**Windows PowerShell:**
```powershell
Invoke-WebRequest -Uri http://localhost:3001/health -Method GET
```

**Windows CMD (if curl.exe is available):**
```cmd
curl.exe http://localhost:3001/health
```

### Test Signup Endpoint

**Linux/Mac/Git Bash:**
```bash
curl -X POST http://localhost:3001/api/signup \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"test123"}'
```

**Windows PowerShell:**
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

**Windows CMD (if curl.exe is available):**
```cmd
curl.exe -X POST http://localhost:3001/api/signup ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"testuser\",\"email\":\"test@example.com\",\"password\":\"test123\"}"
```

### Test Login Endpoint

**Linux/Mac/Git Bash:**
```bash
curl -X POST http://localhost:3001/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

**Windows PowerShell:**
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

**Windows CMD (if curl.exe is available):**
```cmd
curl.exe -X POST http://localhost:3001/api/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"test123\"}"
```

**Alternative: Use Postman or Browser DevTools**
- Open browser DevTools (F12) → Network tab
- Or use Postman/Insomnia for easier testing

## 📊 Expected Responses

### Success Response (200)
```json
{
  "success": true,
  "data": {
    "user_id": "...",
    "email": "test@example.com",
    "username": "testuser",
    "token": "jwt_token_here"
  }
}
```

### Error Response (400/401)
```json
{
  "success": false,
  "error": "invalid_credentials"
}
```

Or from Huawei Cloud:
```json
{
  "error_code": "APIG.0101",
  "error_msg": "The API does not exist or has not been published in the environment"
}
```

**Expected Behavior:**
- Request is forwarded to Huawei Cloud
- Response is returned (success or error depending on Huawei Cloud)
- Check Terminal 1 for request/response logs
- No CORS errors should occur

**Example Success Response:**
```json
{
  "success": true,
  "data": {
    "message": "Login successful",
    "token": "..."
  }
}
```

**Example Error Response:**
```json
{
  "success": false,
  "error": "Invalid credentials"
}
```

## 🔧 Configuration

The server is configured with:
- **Port**: 3001
- **Huawei Base URL**: `https://bfea85780dee4f95b5e5ce77704934e9.apic.af-south-1.huaweicloudapis.com`
- **AppCode**: Stored securely in the server (not exposed to client)

## 🔒 Security Features

- ✅ CORS enabled for all origins (development)
- ✅ Input validation (required fields, email format, password length)
- ✅ Request/response logging
- ✅ Error handling with graceful error messages
- ✅ AppCode never exposed to client-side code

## 📝 Logging

The server logs:
- All incoming requests with timestamps
- Response status codes
- Errors with full error details

Example log output:
```
[2024-01-01T00:00:00.000Z] POST /api/signup - Username: testuser, Email: test@example.com
[2024-01-01T00:00:00.000Z] Response Status: 200
```

## 🚀 Production Deployment

For production deployment:

1. **Use Environment Variables**: Move sensitive data to environment variables
2. **Update CORS**: Restrict CORS to your production domain only
3. **Add Rate Limiting**: Implement rate limiting to prevent abuse
4. **HTTPS Only**: Always use HTTPS in production
5. **Monitoring**: Set up logging and monitoring services

### Example Environment Variables Setup

Create a `.env` file:
```env
PORT=3001
HUAWEI_BASE_URL=https://bfea85780dee4f95b5e5ce77704934e9.apic.af-south-1.huaweicloudapis.com
HUAWEI_APP_CODE=your_app_code_here
```

Then use `dotenv` package to load them:
```javascript
require('dotenv').config();
const PORT = process.env.PORT || 3001;
const HUAWEI_BASE_URL = process.env.HUAWEI_BASE_URL;
const HUAWEI_APP_CODE = process.env.HUAWEI_APP_CODE;
```

## 📚 Dependencies

- **express**: ^4.18.2 - Web framework
- **cors**: ^2.8.5 - CORS middleware
- **node-fetch**: ^2.7.0 - HTTP client (version 2 for CommonJS compatibility)

## 🐛 Troubleshooting

### Port Already in Use
If port 3001 is already in use, you can change it in `server.js`:
```javascript
const PORT = 3002; // or any available port
```

### CORS Still Not Working
- Ensure the backend server is running
- Check that Flutter app is using `http://localhost:3001/api` as base URL
- Verify CORS middleware is enabled in server.js

### Connection Refused
- Make sure the server is running (`npm start`)
- Check the port number matches in both server and Flutter app
- Verify no firewall is blocking the connection

## 📖 Related Documentation

- See `SECURITY.md` in the project root for security architecture details
- See `TESTING.md` in the project root for complete testing instructions

