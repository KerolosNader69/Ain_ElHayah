# Huawei Cloud APIG - Login Endpoint Setup Guide

## ✅ Yes, You Need to Create the Login API

Your Flutter app expects a `/login` endpoint to authenticate returning users. Since signup works, you need to create a similar login endpoint.

## 📋 Step-by-Step Guide

### Step 1: Access Huawei Cloud APIG Console

1. Log into [Huawei Cloud Console](https://console.huaweicloud.com/)
2. Navigate to **APIG (API Gateway)**
3. Select your API group (the same one where `/signup` is configured)

### Step 2: Create Login Endpoint

1. **Click "Create API"** or find your existing API group
2. **Use `/signup` as a reference** - The login endpoint should be similar but:
   - **Path**: `/login` (instead of `/signup`)
   - **Method**: `POST`
   - **Backend Service**: Should point to your authentication backend that verifies credentials

### Step 3: Configure Login Endpoint

**Basic Configuration:**
- **API Name**: `login` or `user-login`
- **Path**: `/login`
- **Method**: `POST`
- **Description**: "User login endpoint - verifies email and password"

**Request Parameters:**
The endpoint should accept:
```json
{
  "email": "user@example.com",
  "password": "userpassword"
}
```

**Backend Service Configuration:**
- Point to the same backend service as `/signup` (if they share the same backend)
- Or create a new backend service that handles authentication

**Response Configuration:**
Expected response format:
```json
{
  "success": true,
  "data": {
    "message": "Login successful",
    "user": {
      "email": "user@example.com",
      "username": "username"
    },
    "token": "jwt_token_here" // Optional, if using JWT
  }
}
```

Or error response:
```json
{
  "success": false,
  "error": "Invalid credentials"
}
```

### Step 4: Publish the API

1. **Save** the API configuration
2. **Publish** it to the same environment as `/signup`
3. **Verify** the AppCode has access to this endpoint

### Step 5: Test the Endpoint

After publishing, test using your backend proxy:

**PowerShell:**
```powershell
$body = @{
    email = "test@example.com"
    password = "test123"
} | ConvertTo-Json

Invoke-RestMethod -Uri http://localhost:3001/api/login `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

**Expected:** Should return success response instead of "API does not exist" error.

## 🔍 What the Login Endpoint Should Do

The login endpoint should:

1. **Accept credentials:**
   - Email (required)
   - Password (required)

2. **Verify credentials:**
   - Check if user exists in database
   - Verify password (hashed comparison)
   - Return error if credentials are invalid

3. **Return user data:**
   - User information (email, username, role, etc.)
   - Authentication token (if using JWT)
   - Success status

## 📝 Backend Service Requirements

Your backend service (behind Huawei Cloud APIG) should:

1. **Receive POST request** with email and password
2. **Query database** to find user by email
3. **Compare password hash** (never store plain passwords!)
4. **Return user data** if valid, or error if invalid

**Example Backend Logic (pseudo-code):**
```javascript
// Backend service behind Huawei Cloud APIG
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  // Find user in database
  const user = await db.users.findOne({ email });
  
  if (!user) {
    return res.status(401).json({
      success: false,
      error: 'Invalid credentials'
    });
  }
  
  // Verify password (compare hash)
  const isValid = await bcrypt.compare(password, user.passwordHash);
  
  if (!isValid) {
    return res.status(401).json({
      success: false,
      error: 'Invalid credentials'
    });
  }
  
  // Return success with user data
  res.json({
    success: true,
    data: {
      message: 'Login successful',
      user: {
        email: user.email,
        username: user.username,
        role: user.role
      },
      token: generateJWT(user) // Optional
    }
  });
});
```

## 🔄 Alternative: Temporary Workaround

If you can't create the login endpoint immediately, you can:

### Option 1: Use Signup for Testing
- For development/testing, users can "sign up" again (if your backend handles duplicates)
- Not recommended for production

### Option 2: Mock Login Endpoint
- Create a temporary mock endpoint that returns success
- Only for development/testing
- Replace with real endpoint before production

### Option 3: Skip Login Temporarily
- Modify Flutter app to skip login requirement
- Set `initialLocation: '/'` instead of requiring login
- Only for development

## ✅ Verification Checklist

After creating the login endpoint:

- [ ] Login endpoint created in Huawei Cloud APIG
- [ ] Endpoint path is `/login`
- [ ] Endpoint method is `POST`
- [ ] Endpoint is published to the environment
- [ ] AppCode has access to the endpoint
- [ ] Backend service handles authentication correctly
- [ ] Test with backend proxy: `http://localhost:3001/api/login`
- [ ] Returns success response for valid credentials
- [ ] Returns error response for invalid credentials
- [ ] Flutter app can login successfully

## 🆘 Need Help?

1. **Check Huawei Cloud Documentation:**
   - [APIG User Guide](https://support.huaweicloud.com/en-us/apig/index.html)
   - API creation tutorials

2. **Compare with Signup:**
   - Look at how `/signup` is configured
   - Use it as a template for `/login`

3. **Backend Service:**
   - Ensure your backend service has login logic
   - Verify database connection
   - Check password hashing implementation

## 📚 Related Files

- `backend/server.js` - Backend proxy (already configured for login)
- `lib/services/api_service.dart` - Flutter API service (already configured)
- `lib/services/auth_service.dart` - Flutter auth service (already configured)
- `lib/screens/login_screen.dart` - Login UI (already implemented)

All Flutter code is ready - you just need to create the Huawei Cloud APIG endpoint!

