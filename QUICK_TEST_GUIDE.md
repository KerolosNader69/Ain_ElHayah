# Quick Test Guide - ModelArts E2E Integration

## 🚀 Quick Start (Recommended)

Run the automated test suite:

```powershell
.\run_e2e_test.ps1
```

This will:
1. Test the backend proxy independently
2. Start the backend server
3. Guide you through Flutter web testing
4. Monitor backend logs in real-time

---

## 📋 Manual Testing Steps

### Option 1: Full Manual Test

**Terminal 1 - Backend Server:**
```powershell
cd backend
node server.js
```

**Terminal 2 - Flutter Web:**
```powershell
flutter run -d chrome --web-port 8080
```

**In the Flutter App:**
1. Go to diagnosis screen
2. Select "Retinal Scan" model
3. Upload a retinal image
4. Click "Analyze"
5. Verify results display

---

### Option 2: Backend Test Only

Test the backend proxy without the Flutter app:

```powershell
cd backend
node test_proxy.js
```

This verifies:
- Backend server connectivity
- IAM token acquisition
- ModelArts API communication

---

## ✅ What to Verify

### Backend Logs (Terminal 1)
Look for these messages:
```
✅ Server is running on port 3001
POST /api/modelarts/infer - Service: c3ea302b-...
Obtaining new IAM token...
IAM token obtained successfully
ModelArts Response Status: 200
```

### Browser Console (F12)
Should see:
```
✅ No CORS errors
✅ Request to localhost:3001 succeeds
✅ Response is valid JSON
```

### Flutter UI
Should see:
```
✅ Image uploads
✅ Loading indicator
✅ Results display
✅ Confidence scores
✅ Recommendations
```

---

## 🔧 Troubleshooting

### Backend won't start
```powershell
cd backend
npm install
node server.js
```

### CORS errors
- Verify backend has `app.use(cors())` in server.js
- Check backend is running on port 3001

### IAM token errors
- Check credentials in `env.json`:
  - MODELARTS_ACCESS_KEY
  - MODELARTS_SECRET_KEY
  - MODELARTS_PROJECT_ID
  - MODELARTS_REGION

### ModelArts 404 errors
- Verify MODELARTS_SERVICE_ID in `env.json`
- Check service is deployed in ModelArts console

---

## 📊 Test Checklist

- [ ] Backend server starts successfully
- [ ] Health endpoint responds (http://localhost:3001/health)
- [ ] Backend proxy test passes
- [ ] Flutter web app loads
- [ ] Image upload works
- [ ] Model selection works
- [ ] Analyze button triggers request
- [ ] Backend receives request (check logs)
- [ ] IAM token is obtained
- [ ] IAM token is cached (subsequent requests)
- [ ] ModelArts API responds
- [ ] Response is parsed correctly
- [ ] Results display in UI
- [ ] No CORS errors
- [ ] No JavaScript errors

---

## 📝 Documentation

- **Detailed Guide**: `backend/E2E_TEST_GUIDE.md`
- **Test Report Template**: `TEST_EXECUTION_REPORT.md`
- **Backend Setup**: `backend/AUTH_SETUP.md`

---

## 🎯 Success Criteria

The test is successful when:

1. ✓ Backend proxy test passes
2. ✓ Backend server runs without errors
3. ✓ Flutter web app loads correctly
4. ✓ Image upload and analysis works
5. ✓ Results display in UI
6. ✓ No errors in backend logs
7. ✓ No errors in browser console
8. ✓ IAM token is cached efficiently
9. ✓ Response time < 8 seconds
10. ✓ All requirements verified

---

## 🚦 Next Steps After Testing

1. Fill out `TEST_EXECUTION_REPORT.md`
2. Document any issues found
3. Test with various image types
4. Test error scenarios
5. Performance testing
6. Security review

---

## 💡 Tips

- Use Chrome DevTools (F12) to monitor network requests
- Watch backend logs for detailed request/response info
- Test with different image sizes (< 8MB limit)
- Try multiple requests to verify token caching
- Check IAM token expiry (should last 23+ hours)

---

## 📞 Need Help?

If you encounter issues:

1. Check the troubleshooting section above
2. Review `backend/E2E_TEST_GUIDE.md` for detailed steps
3. Verify all credentials in `env.json`
4. Check backend logs for error messages
5. Review browser console for client-side errors
