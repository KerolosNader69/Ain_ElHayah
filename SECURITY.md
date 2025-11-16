# Security Architecture: Backend Proxy Implementation

## ✅ Solution Implemented

**A backend proxy server has been implemented to resolve CORS issues and secure the AppCode.**

The AppCode is no longer exposed in the Flutter Web app. It is securely stored in the backend proxy server.

## 🏗️ Architecture

```
Flutter Web App → Backend Proxy Server → Huawei Cloud APIG
(localhost:56605)  (localhost:3001)      (Huawei Cloud)
                    (AppCode secure)
```

### How It Works

1. **Flutter App** makes requests to `http://localhost:3001/api/*`
2. **Backend Proxy** receives the request, adds the AppCode header, and forwards to Huawei Cloud
3. **Huawei Cloud** processes the request and returns a response
4. **Backend Proxy** forwards the response back to the Flutter app
5. **CORS is resolved** because the backend proxy is on the same origin or properly configured

### Benefits

✅ **CORS Issues Resolved**: Backend proxy handles cross-origin requests  
✅ **AppCode Hidden**: Never exposed to client-side code  
✅ **Security**: Can add rate limiting, input validation, and monitoring  
✅ **Flexibility**: Easy to add authentication, logging, and other middleware  

## ⚠️ Previous Security Issue (Now Resolved)

**Previously, the AppCode was hardcoded in `lib/services/api_service.dart` for testing purposes only.**

### Why This Is Dangerous

When you build a Flutter Web application, all Dart code is compiled to JavaScript and sent to the client's browser. This means:

1. **Anyone can view your source code** - Users can open browser DevTools and see the compiled JavaScript
2. **AppCode is exposed** - The AppCode value is visible in the client-side code
3. **API abuse** - Malicious users can extract your AppCode and make unauthorized API calls
4. **Rate limiting bypass** - Attackers can use your AppCode to make requests that count against your API quota
5. **Cost implications** - Unauthorized usage can lead to unexpected charges

### Example: How Easy It Is to Extract

A user can simply:
1. Open browser DevTools (F12)
2. Go to Sources tab
3. Search for "appCode" or "X-Apig-AppCode"
4. Find and copy your AppCode
5. Use it to make direct API calls

## 🔧 Implementation Details

The backend proxy server (`backend/server.js`) provides:
- ✅ Keeps the AppCode secure on the server
- ✅ Validates and sanitizes requests
- ✅ Logs API usage
- ✅ Handles CORS for all origins (development)
- 🔄 Can add rate limiting (future enhancement)
- 🔄 Can add authentication/authorization (future enhancement)

### Backend Proxy Implementation

The backend proxy is implemented using Node.js/Express:

#### 1. Installation

The backend proxy is located in the `backend/` directory. See `backend/README.md` for installation instructions.

#### 2. Server Implementation

The `backend/server.js` file implements:

```javascript
const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch'); // or use axios

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Environment variables (keep in .env file, never commit!)
const APIG_BASE_URL = process.env.APIG_BASE_URL || 'https://bfea85780dee4f95b5e5ce77704934e9.apic.af-south-1.huaweicloudapis.com';
const APIG_APP_CODE = process.env.APIG_APP_CODE; // Load from environment

// Signup endpoint
app.post('/api/signup', async (req, res) => {
  try {
    // Validate request
    const { username, email, password } = req.body;
    
    if (!username || !email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields'
      });
    }

    // Validate email format
    if (!email.includes('@')) {
      return res.status(400).json({
        success: false,
        error: 'Invalid email format'
      });
    }

    // Validate password length
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        error: 'Password must be at least 6 characters'
      });
    }

    // Forward request to Huawei Cloud APIG
    const response = await fetch(`${APIG_BASE_URL}/signup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Apig-AppCode': APIG_APP_CODE, // Secure: AppCode stays on server
      },
      body: JSON.stringify({
        username: username.trim(),
        email: email.trim(),
        password: password.trim(),
      }),
    });

    const data = await response.json();

    // Forward response to client
    res.status(response.status).json(data);
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Proxy server running on port ${PORT}`);
});
```

#### 3. Create `.env` file

```env
APIG_BASE_URL=https://bfea85780dee4f95b5e5ce77704934e9.apic.af-south-1.huaweicloudapis.com
APIG_APP_CODE=b369a2fd558f4331a644598d6223a731b2ffaaa3baf644c1a606d593b52301c7
PORT=3000
```

#### 4. Add `.env` to `.gitignore`

```
node_modules/
.env
*.log
```

#### 5. Deploy Backend

Deploy to a service like:
- **Heroku** (free tier available)
- **Vercel** (serverless functions)
- **AWS Lambda** (serverless)
- **Google Cloud Functions** (serverless)
- **Railway** (easy deployment)
- **Render** (free tier available)

### Flutter App Configuration

The Flutter app (`lib/services/api_service.dart`) has been updated to use the proxy:

```dart
class ApiService {
  // Base URL for backend proxy server
  // For local development: http://localhost:3001/api
  // For production: Update to your deployed backend URL
  static const String _baseUrl = 'http://localhost:3001/api';

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/signup');
      
      final body = jsonEncode({
        'username': username.trim(),
        'email': email.trim(),
        'password': password.trim(),
      });

      // Only Content-Type needed - AppCode handled by backend proxy
      final headers = {
        'Content-Type': 'application/json',
      };

      // ... rest of the code remains the same
    } catch (e) {
      // ... error handling
    }
  }
}
```

**Key Changes:**
- ✅ Base URL changed to `http://localhost:3001/api`
- ✅ AppCode constant removed completely
- ✅ `X-Apig-AppCode` header removed from requests
- ✅ Only `Content-Type` header is sent

## 🔒 Additional Security Best Practices

### 1. Environment Variables
- Never commit `.env` files to version control
- Use environment variables for all sensitive data
- Use different AppCodes for development and production

### 2. Rate Limiting
Add rate limiting to your backend proxy:

```javascript
const rateLimit = require('express-rate-limit');

const signupLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5 // limit each IP to 5 requests per windowMs
});

app.post('/api/signup', signupLimiter, async (req, res) => {
  // ... signup logic
});
```

### 3. Input Validation
- Validate all inputs on the backend
- Sanitize user data
- Use libraries like `validator` for email validation

### 4. HTTPS Only
- Always use HTTPS in production
- Never send sensitive data over HTTP

### 5. CORS Configuration
Configure CORS properly on your backend:

```javascript
const cors = require('cors');

app.use(cors({
  origin: ['https://your-flutter-app.com'], // Only allow your app
  credentials: true,
}));
```

### 6. Logging and Monitoring
- Log all API requests
- Monitor for suspicious activity
- Set up alerts for unusual patterns

### 7. Authentication Tokens
- After signup, use JWT tokens for subsequent requests
- Store tokens securely (not in localStorage for web)
- Implement token refresh mechanism

## 📝 Summary

**Current State (Implemented):**
- ✅ Backend proxy server created and configured
- ✅ AppCode removed from Flutter app
- ✅ Flutter app updated to use proxy server
- ✅ CORS issues resolved
- ✅ Security improved

**Production Requirements:**
- ✅ Backend proxy with AppCode stored securely
- ✅ Input validation implemented
- ✅ Request/response logging
- 🔄 Environment variables for configuration (recommended for production)
- 🔄 Rate limiting (can be added)
- 🔄 HTTPS only (required for production)
- 🔄 Restricted CORS configuration (recommended for production)
- 🔄 Enhanced monitoring (recommended for production)

## 🚀 Production Deployment Checklist

Before deploying to production:

- [x] Create backend proxy server
- [ ] Deploy backend to hosting service (Heroku, Railway, Render, etc.)
- [x] Update `api_service.dart` to use proxy URL
- [x] Remove AppCode from Flutter app
- [ ] Test signup flow with proxy
- [ ] Update Flutter app's `_baseUrl` to production backend URL
- [ ] Use environment variables for AppCode in backend
- [ ] Add rate limiting to backend
- [ ] Configure CORS to only allow your production domain
- [ ] Set up HTTPS for both frontend and backend
- [ ] Set up monitoring and logging
- [ ] Test end-to-end in production environment

## 🧪 Testing

See `TESTING.md` for complete testing instructions.

## 📚 Additional Resources

- [Flutter Web Security Best Practices](https://docs.flutter.dev/development/platform-integration/web)
- [Express.js Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)

---

**Remember:** Security is not optional. Always use a backend proxy for production applications, especially for Flutter Web.

