# Final Solution - ModelArts Authentication

## Problem Identified ✅

The error is clear:
```
"Incorrect IAM authentication information: x-auth-token not found"
"error_code": "APIG.0301"
```

**Root Cause**: ModelArts requires IAM token authentication using **username/password**, not AK/SK.

---

## Solution (2 Steps)

### Step 1: Add Credentials to env.json

You need to add three new fields to your `env.json`:

```json
{
  "MODELARTS_USERNAME": "kero_o911",
  "MODELARTS_PASSWORD": "your_huawei_cloud_password",
  "MODELARTS_DOMAIN": "kero_o911",
  
  "MODELARTS_PROJECT_ID": "59dcb311da5e4ca6b8db8bbc7a7712d7",
  "MODELARTS_ACCESS_KEY": "HPUALP3GCEZ2AMWETEHI",
  "MODELARTS_SECRET_KEY": "ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM",
  "MODELARTS_SERVICE_ID": "c3ea302b-d98b-4f80-85bb-552e9ca8e0c9",
  "MODELARTS_REGION": "ap-southeast-3",
  "MODELARTS_INVOKE_URL": "https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>"
}
```

**Where to find these:**
- **USERNAME**: Your Huawei Cloud IAM username (likely `kero_o911` based on DLI_USERNAME)
- **PASSWORD**: Your Huawei Cloud account password (the one you use to login)
- **DOMAIN**: Your account domain name (often same as username, try `kero_o911`)

### Step 2: Update Backend Code

The backend needs to use username/password instead of AK/SK for IAM authentication.

**File: `backend/server.js`**

Change the `getIAMToken` function to accept username/password/domain:

```javascript
async function getIAMToken(username, password, domain, projectId, region) {
  const now = Date.now();
  if (tokenCache && now < tokenExpiresAt) {
    console.log(`[${new Date().toISOString()}] Using cached IAM token`);
    return tokenCache;
  }

  console.log(`[${new Date().toISOString()}] Obtaining IAM token...`);
  const iamUrl = `https://iam.${region}.myhuaweicloud.com/v3/auth/tokens`;
  
  const body = {
    auth: {
      identity: {
        methods: ['password'],
        password: {
          user: {
            name: username,
            password: password,
            domain: { name: domain }
          }
        }
      },
      scope: { project: { id: projectId } }
    }
  };

  const response = await fetch(iamUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });

  const token = response.headers.get('x-subject-token');
  if (!token) {
    const errorText = await response.text();
    throw new Error(`Failed to obtain IAM token: ${errorText}`);
  }

  tokenCache = token;
  tokenExpiresAt = now + 23 * 3600 * 1000;
  console.log(`[${new Date().toISOString()}] IAM token obtained successfully`);
  return tokenCache;
}
```

And update the env.json loading section to include the new fields:

```javascript
// In the /api/modelarts/infer endpoint, update to load username/password/domain:
const username = envConfig.MODELARTS_USERNAME;
const password = envConfig.MODELARTS_PASSWORD;
const domain = envConfig.MODELARTS_DOMAIN || username; // Default domain to username

// Then call getIAMToken with these:
const token = await getIAMToken(username, password, domain, projectId, region);
```

---

## Quick Implementation

Since the code changes are complex, here's what I recommend:

### Option 1: Manual Fix (Recommended)

1. **Add to env.json**:
   ```json
   "MODELARTS_USERNAME": "kero_o911",
   "MODELARTS_PASSWORD": "YOUR_PASSWORD_HERE",
   "MODELARTS_DOMAIN": "kero_o911"
   ```

2. **I'll create a fixed version of backend/server.js for you**

3. **Test**:
   ```powershell
   cd backend
   node server.js
   
   # In another terminal:
   .\test_modelarts_api.ps1
   ```

### Option 2: Use Existing E2E Test

Your existing E2E test (`test_modelarts_e2e.ps1`) might already have the correct authentication. Check if it works after adding credentials to env.json.

---

## What You Need to Do NOW

1. **Find your Huawei Cloud password**
   - This is the password you use to login to https://console.huaweicloud.com

2. **Add three lines to env.json**:
   ```json
   "MODELARTS_USERNAME": "kero_o911",
   "MODELARTS_PASSWORD": "your_actual_password",
   "MODELARTS_DOMAIN": "kero_o911"
   ```

3. **Tell me when you've added them**, and I'll create the fixed backend code for you.

---

## Why This Will Work

The diagnostic test showed:
- ✅ Service is running
- ✅ Service ID is correct
- ✅ Region is correct
- ❌ Only missing: proper IAM token with username/password

Once we have the IAM token with correct credentials, ModelArts will accept the request.

---

## Security Note

⚠️ Your password will be in plain text in env.json. Make sure:
- env.json is in .gitignore
- Don't share env.json with anyone
- Don't commit it to version control

---

## Next Steps

1. Add credentials to env.json
2. Let me know, and I'll provide the fixed backend code
3. Test with `.\test_modelarts_api.ps1`
4. If successful, test the web app

The solution is simple - we just need the right credentials!
