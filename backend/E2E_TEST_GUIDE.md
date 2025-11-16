# End-to-End ModelArts Integration Test Guide

This guide walks you through testing the complete ModelArts inference flow from the Flutter web application through the backend proxy to the Huawei ModelArts service.

## Prerequisites

- Node.js installed
- Flutter SDK installed
- Backend dependencies installed (`npm install` in backend folder)
- Valid ModelArts credentials in `env.json`

## Test Scenarios

### Scenario 1: Backend Proxy Only Test

Test the backend proxy server independently without the Flutter app.

**Steps:**

1. Start the backend server:
   ```powershell
   cd backend
   node server.js
   ```

2. In another terminal, run the test script:
   ```powershell
   cd backend
   node test_proxy.js
   ```

**Expected Results:**
- ✓ Backend health check passes
- ✓ IAM token is obtained successfully
- ✓ ModelArts API responds (even if with an error due to test image)
- ✓ Response is properly formatted JSON

**What to Verify:**
- [ ] Backend server starts on port 3001
- [ ] Health endpoint returns `{"status": "OK"}`
- [ ] IAM token is cached (check console logs)
- [ ] ModelArts API is called with correct headers
- [ ] Response is parsed correctly

---

### Scenario 2: Full End-to-End Test

Test the complete flow from Flutter web UI to ModelArts inference.

**Steps:**

1. Start the backend server:
   ```powershell
   .\test_backend_only.ps1
   ```

2. In another terminal, start the Flutter web app:
   ```powershell
   flutter run -d chrome --web-port 8080
   ```

3. In the Flutter app:
   - Navigate to the diagnosis screen
   - Select "Retinal Scan" model
   - Upload a test retinal image
   - Click "Analyze"

**Expected Results:**
- ✓ Image uploads successfully
- ✓ Request goes through backend proxy (check backend console)
- ✓ IAM token is obtained and cached
- ✓ ModelArts API is called
- ✓ Response is parsed correctly
- ✓ Results display in the UI

**What to Verify:**
- [ ] Backend logs show: `POST /api/modelarts/infer`
- [ ] Backend logs show: `Using cached IAM token` (on subsequent requests)
- [ ] Backend logs show: `ModelArts Response Status: 200`
- [ ] Flutter app displays diagnosis results
- [ ] No CORS errors in browser console
- [ ] No authentication errors

---

### Scenario 3: Automated E2E Test

Run the automated test script that monitors both backend and provides instructions.

**Steps:**

1. Run the E2E test script:
   ```powershell
   .\test_modelarts_e2e.ps1
   ```

2. Follow the on-screen instructions to start Flutter app

3. Perform manual testing in the UI

4. Press Ctrl+C to stop monitoring

**Expected Results:**
- ✓ Backend starts automatically
- ✓ Health check passes
- ✓ Backend logs are displayed in real-time
- ✓ Clean shutdown on Ctrl+C

---

## Verification Checklist

### Backend Proxy Verification

- [ ] Server starts on port 3001
- [ ] Health endpoint responds correctly
- [ ] CORS is enabled for all origins
- [ ] Request body is parsed correctly
- [ ] IAM token is obtained on first request
- [ ] IAM token is cached for subsequent requests
- [ ] ModelArts URL is constructed correctly
- [ ] Request headers include `X-Auth-Token` and `X-Project-Id`
- [ ] Response is forwarded to client correctly
- [ ] Errors are handled gracefully

### Flutter Web Verification

- [ ] App loads without errors
- [ ] Image upload works
- [ ] Model selection works (Retinal Scan)
- [ ] Analyze button triggers request
- [ ] Loading state is displayed
- [ ] Request goes to `http://localhost:3001/api/modelarts/infer`
- [ ] No CORS errors in browser console
- [ ] Response is parsed correctly
- [ ] Results are displayed in UI
- [ ] Error messages are user-friendly

### ModelArts API Verification

- [ ] IAM token request succeeds
- [ ] Token is valid for 23+ hours
- [ ] Inference request includes correct headers
- [ ] Image is base64 encoded correctly
- [ ] Response format matches expected structure
- [ ] Error responses are handled properly

---

## Common Issues and Solutions

### Issue: Backend server not starting

**Solution:**
```powershell
cd backend
npm install
node server.js
```

### Issue: CORS errors in browser

**Solution:** Verify backend has CORS enabled:
```javascript
app.use(cors()); // Should be in server.js
```

### Issue: IAM token errors

**Solution:** Check credentials in `env.json`:
- `MODELARTS_ACCESS_KEY`
- `MODELARTS_SECRET_KEY`
- `MODELARTS_PROJECT_ID`
- `MODELARTS_REGION`

### Issue: ModelArts API returns 404

**Solution:** Verify service ID and URL:
- Check `MODELARTS_SERVICE_ID` in `env.json`
- Verify service is deployed in ModelArts console
- Confirm region matches service deployment

### Issue: Image too large error

**Solution:** The service enforces an 8MB limit. Compress or resize images before upload.

---

## Test Data

### Sample Test Images

For testing, use retinal images from:
- `assets/images/` (if available)
- Download sample retinal images from medical image databases
- Use your own retinal scan images

**Image Requirements:**
- Format: JPG, PNG
- Size: < 8MB
- Resolution: Recommended 224x224 or higher
- Content: Retinal fundus photograph

---

## Success Criteria

The end-to-end test is successful when:

1. ✓ Backend server starts without errors
2. ✓ Health check endpoint responds
3. ✓ IAM token is obtained and cached
4. ✓ Flutter web app loads correctly
5. ✓ Image upload works
6. ✓ Inference request completes successfully
7. ✓ Response is parsed correctly
8. ✓ Results display in UI
9. ✓ No errors in backend logs
10. ✓ No errors in browser console

---

## Requirements Coverage

This test verifies the following requirements:

- **1.1**: System accepts retinal images via web interface
- **1.2**: System processes images through ModelArts
- **1.3**: System returns structured diagnosis results
- **1.4**: System displays results in user-friendly format
- **3.1**: Backend proxy handles authentication
- **3.2**: IAM tokens are cached efficiently
- **3.3**: Requests include proper headers
- **9.1**: End-to-end flow works on web platform
- **9.2**: CORS is handled correctly
- **9.3**: Errors are handled gracefully
- **9.4**: Performance is acceptable (< 5s for inference)

---

## Next Steps After Testing

1. Document any issues found
2. Verify all requirements are met
3. Test with various image types and sizes
4. Test error scenarios (invalid credentials, network errors)
5. Performance testing with multiple concurrent requests
6. Security review of credential handling
