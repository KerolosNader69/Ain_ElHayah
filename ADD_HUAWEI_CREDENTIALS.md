# Add Huawei Cloud Credentials for ModelArts

## Problem
ModelArts requires IAM token authentication using username/password, not just AK/SK.

The error message confirms this:
```
"Incorrect IAM authentication information: x-auth-token not found"
```

## Solution
Add your Huawei Cloud account credentials to `env.json`.

---

## Step 1: Find Your Huawei Cloud Credentials

You need three pieces of information:

### 1. Username (IAM User Name)
- Go to Huawei Cloud Console
- Click on your account name (top right)
- Go to "My Credentials"
- Look for "IAM User Name" or "Username"
- Example: `kero_o911` (you already have this as DLI_USERNAME)

### 2. Password
- This is your Huawei Cloud account password
- The password you use to login to Huawei Cloud Console

### 3. Domain Name (Account Name)
- Go to "My Credentials" in Huawei Cloud Console
- Look for "Account Name" or "Domain Name"
- This is usually your account ID or domain name
- Example: If your account name is `hw123456789`, use that

---

## Step 2: Add to env.json

Add these three fields to your `env.json` file:

```json
{
  "MODELARTS_USERNAME": "kero_o911",
  "MODELARTS_PASSWORD": "your_huawei_cloud_password_here",
  "MODELARTS_DOMAIN": "your_domain_name_here",
  
  "MODELARTS_PROJECT_ID": "59dcb311da5e4ca6b8db8bbc7a7712d7",
  "MODELARTS_ACCESS_KEY": "HPUALP3GCEZ2AMWETEHI",
  "MODELARTS_SECRET_KEY": "ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM",
  "MODELARTS_SERVICE_ID": "c3ea302b-d98b-4f80-85bb-552e9ca8e0c9",
  "MODELARTS_REGION": "ap-southeast-3",
  "MODELARTS_INVOKE_URL": "https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>"
}
```

### Important Notes:
- `MODELARTS_USERNAME`: Your IAM username (likely `kero_o911`)
- `MODELARTS_PASSWORD`: Your actual Huawei Cloud password
- `MODELARTS_DOMAIN`: Your account/domain name

---

## Step 3: How to Find Domain Name

### Method 1: From Console
1. Login to Huawei Cloud Console
2. Click your account name (top right)
3. Go to "My Credentials"
4. Look for "Account Name" or "Domain Name"

### Method 2: From Project ID
Sometimes the domain name is part of your project structure. Check the ModelArts console URL or project details.

### Method 3: Try Username as Domain
In some cases, the domain name is the same as your username. Try using `kero_o911` as the domain name.

---

## Step 4: Test After Adding Credentials

Once you've added the credentials to env.json:

```powershell
# Test the authentication
.\test_modelarts_api.ps1
```

You should see:
```
[1/3] Obtaining IAM token...
  ✓ IAM token obtained successfully (password method)

[2/3] Testing ModelArts inference...
  Using IAM token authentication
  Response status: 200
  ✓ ModelArts inference successful
```

---

## Example env.json (with placeholders)

```json
{
  "GOOGLE_API_KEY": "AIzaSyCyRX3Atmca6Vf5HcnsEImzvXcTlNvRqrw",
  
  "MODELARTS_USERNAME": "kero_o911",
  "MODELARTS_PASSWORD": "YourPassword123!",
  "MODELARTS_DOMAIN": "kero_o911",
  "MODELARTS_PROJECT_ID": "59dcb311da5e4ca6b8db8bbc7a7712d7",
  "MODELARTS_ACCESS_KEY": "HPUALP3GCEZ2AMWETEHI",
  "MODELARTS_SECRET_KEY": "ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM",
  "MODELARTS_SERVICE_ID": "c3ea302b-d98b-4f80-85bb-552e9ca8e0c9",
  "MODELARTS_REGION": "ap-southeast-3",
  "MODELARTS_INVOKE_URL": "https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>",
  
  "DLI_PROJECT_ID": "b4ba6a794c4a4430933d3df4d49c7b83",
  "DLI_ACCESS_KEY": "HPUALP3GCEZ2AMWETEHI",
  "DLI_SECRET_KEY": "ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM",
  "DLI_USERNAME": "kero_o911",
  "DLI_REGION": "af-north-1",
  "DLI_ENDPOINT": "",
  
  "HUAWEI_AI_API_KEY": "4_JENf9g9NVi7_332loZt65qIydiAJCPNHhbx0irqaHtJPkfqcUCpp8tp85SlqOU8QX1lYp4AsvLtKqgx0OXRQ",
  "HUAWEI_AI_BASE_URL": "",
  "HUAWEI_AI_MODEL": "deepseek-v3.1",
  
  "SIS_PROJECT_ID": "59dcb311d4e5e4ca6bb8b8bc7a7712d7",
  "SIS_ACCESS_KEY": "HPUALP3GCEZ2AMWETEHI",
  "SIS_SECRET_KEY": "ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM",
  "SIS_ENDPOINT": "sis-ext.ap-southeast-3.myhuaweicloud.com",
  "SIS_LANGUAGE": "en_US"
}
```

---

## Security Note

⚠️ **Important**: Your password will be stored in plain text in env.json. Make sure:
- env.json is in .gitignore (don't commit it to git)
- Only you have access to this file
- Consider using environment variables in production

---

## Alternative: Use Project Name Instead of Project ID

If you're having trouble with authentication, you can also try using the project name instead of project ID in the scope:

```json
"scope": {
  "project": { "name": "ap-southeast-3" }
}
```

Instead of:
```json
"scope": {
  "project": { "id": "59dcb311da5e4ca6b8db8bbc7a7712d7" }
}
```

---

## Next Steps

1. **Add credentials to env.json**
   - MODELARTS_USERNAME
   - MODELARTS_PASSWORD  
   - MODELARTS_DOMAIN

2. **Test authentication**
   ```powershell
   .\test_modelarts_api.ps1
   ```

3. **If successful, restart backend and test web app**
   ```powershell
   cd backend
   node server.js
   
   # In another terminal:
   .\run_web_proxy.ps1
   ```

4. **If still failing, check:**
   - Username is correct
   - Password is correct
   - Domain name is correct
   - Try using project name instead of project ID

---

## Common Issues

### "Invalid username or password"
- Double-check your Huawei Cloud login credentials
- Make sure there are no extra spaces in env.json
- Try logging into Huawei Cloud Console to verify password

### "Domain not found"
- Try using your username as the domain name
- Check "My Credentials" for the exact domain name
- Try your account ID as the domain name

### Still getting 401
- Verify the region is correct (ap-southeast-3)
- Check if your account has access to ModelArts in that region
- Verify the service ID is correct

---

## Quick Test Command

After adding credentials:
```powershell
.\test_modelarts_api.ps1
```

This will tell you immediately if the credentials work.
