# Quick Manual Test Reference Card

## Start Testing (3 Steps)

1. **Start Backend:**
   ```powershell
   cd backend
   node server.js
   ```
   Wait for: `✅ Server is running on port 3001`

2. **Start Flutter Web:**
   ```powershell
   .\run_web_simple.ps1
   ```
   Wait for Chrome to open

3. **Navigate to Diagnosis Page**

---

## Quick Test Flow

### Test Normal Image
1. Select "Retinal Model"
2. Upload normal retinal image
3. Click "Analyze"
4. ✅ Verify: Class = "Normal", Severity = "Normal"

### Test Diseased Image
1. Clear previous image
2. Upload diseased image
3. Click "Analyze"
4. ✅ Verify: Disease name, Severity matches confidence

---

## What to Check

### Backend Console
```
POST /api/modelarts/infer - Service: c3ea302b...
[Obtaining new IAM token] (first time only)
IAM token obtained successfully
ModelArts Response Status: 200
```

### Browser Console (F12)
```
[DiagnosisProvider] Using real ModelArts inference
[DiagnosisProvider] Diagnosis complete - Class: XXX, Confidence: 0.XX
```

### UI Display
- ✅ Predicted class name
- ✅ Confidence score (0.0 - 1.0)
- ✅ Severity badge (Normal/Low/Medium/High)
- ✅ Recommendations list
- ✅ AI second opinion (if available)

---

## Severity Mapping Rules

| Condition | Confidence | Expected Severity |
|-----------|------------|-------------------|
| Normal | Any | Normal |
| Disease | ≥ 0.9 | High |
| Disease | 0.8 - 0.89 | Medium |
| Disease | < 0.8 | Low |

---

## Condition-Specific Recommendations

- **Diabetic Retinopathy:** "Monitor blood sugar and consider specialist treatment"
- **Glaucoma:** "Use prescribed drops and monitor IOP"
- **AMD:** "Discuss AREDS2 supplements with your doctor"
- **Hypertensive Retinopathy:** "Control blood pressure and reduce salt intake"

---

## Common Issues

### "ModelArts configuration is missing"
- ✅ Check: `run_web_simple.ps1` has all --dart-define flags
- ✅ Restart Flutter app

### "Network error"
- ✅ Check: Backend server is running on port 3001
- ✅ Check: `http://localhost:3001/health` responds

### "Analysis failed"
- ✅ Check: Backend console for error details
- ✅ Check: Browser console (F12) for error messages
- ✅ Verify: ModelArts credentials in env.json

---

## Test Locales

### English
1. Set language to English
2. Analyze image
3. ✅ All text in English

### Arabic (if supported)
1. Set language to Arabic (العربية)
2. ✅ UI switches to RTL
3. Analyze image
4. ✅ Text in Arabic

---

## Stop Testing

1. Press `Ctrl+C` in Flutter terminal
2. Close backend terminal window
3. Close Chrome browser

---

## Files to Review

- **Full Guide:** `MANUAL_TESTING_GUIDE.md`
- **Checklist:** `MANUAL_TEST_CHECKLIST.md`
- **Setup Verification:** `.\verify_manual_test_setup.ps1`
- **Quick Start:** `.\start_manual_testing.ps1`
