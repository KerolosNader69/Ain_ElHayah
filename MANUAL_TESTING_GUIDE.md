# Manual Testing Guide - ModelArts Retina Integration

## Overview
This guide provides step-by-step instructions for manually testing the ModelArts retina integration across different platforms, locales, and scenarios.

## Prerequisites

### Required Setup
- ✅ Backend server running on port 3001
- ✅ Flutter web application running
- ✅ Valid ModelArts credentials in `env.json`
- ✅ Test retinal images (normal and diseased)

### Configuration Check
Verify `env.json` contains:
```json
{
  "MODELARTS_PROJECT_ID": "59dcb311da5e4ca6b8db8bbc7a7712d7",
  "MODELARTS_ACCESS_KEY": "HPUALP3GCEZ2AMWETEHI",
  "MODELARTS_SECRET_KEY": "ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM",
  "MODELARTS_SERVICE_ID": "c3ea302b-d98b-4f80-85bb-552e9ca8e0c9",
  "MODELARTS_REGION": "ap-southeast-3",
  "MODELARTS_INVOKE_URL": "https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>"
}
```

---

## Test Plan

### Test 1: Web Platform with Backend Proxy

#### 1.1 Start Backend Server
```powershell
cd backend
node server.js
```

**Expected Output:**
```
🚀 Eye Wise Connect Backend Server
📍 Server URL:        http://localhost:3001
✅ Server is running on port 3001
```

#### 1.2 Start Flutter Web Application
```powershell
.\run_web_simple.ps1
```
Or:
```powershell
flutter run -d chrome --web-port 8080
```

#### 1.3 Test Normal Retinal Image
1. Navigate to the Diagnosis page
2. Select "Retinal Model" from dropdown
3. Upload a normal retinal image
4. Click "Analyze"

**Expected Behavior:**
- Loading indicator appears
- Backend logs show:
  ```
  POST /api/modelarts/infer - Service: c3ea302b-d98b-4f80-85bb-552e9ca8e0c9
  Obtaining new IAM token... (first time)
  IAM token obtained successfully
  ModelArts Response Status: 200
  ```
- UI displays:
  - Predicted class: "Normal"
  - Severity: "Normal"
  - Confidence score (0.0 - 1.0)
  - Recommendations list
  - AI second opinion (if available)

**Browser Console Logs to Verify:**
```
[DiagnosisProvider] Using real ModelArts inference for retinal model
[DiagnosisProvider] Requesting AI second opinion...
[DiagnosisProvider] Diagnosis complete - Class: Normal, Confidence: 0.XX
```

#### 1.4 Test Diseased Retinal Image
1. Clear previous image
2. Upload a diseased retinal image (e.g., Diabetic Retinopathy)
3. Click "Analyze"

**Expected Behavior:**
- Backend logs show cached token usage:
  ```
  Using cached IAM token
  ModelArts Response Status: 200
  ```
- UI displays:
  - Predicted class: Disease name (e.g., "Diabetic Retinopathy")
  - Severity: "High" (if confidence ≥ 0.9), "Medium" (0.8-0.9), or "Low" (< 0.8)
  - Confidence score
  - Condition-specific recommendations
  - AI second opinion with reasoning

**Severity Mapping Verification:**
| Condition | Confidence | Expected Severity |
|-----------|------------|-------------------|
| Normal | Any | Normal |
| Disease | ≥ 0.9 | High |
| Disease | 0.8 - 0.89 | Medium |
| Disease | < 0.8 | Low |

---

### Test 2: Mobile Platform (If Applicable)

**Note:** Mobile testing requires direct API calls without the backend proxy.

#### 2.1 Build and Run Mobile App
```powershell
flutter run -d <device-id>
```

#### 2.2 Test with Retinal Images
Follow the same steps as Test 1.3 and 1.4

**Expected Behavior:**
- App makes direct HTTPS calls to ModelArts
- IAM token managed within Flutter app
- Same UI results as web platform

**Console Logs to Verify:**
```
[HuaweiModelArtsService] Making direct API call (not using proxy)
[HuaweiModelArtsService] Obtaining IAM token...
[HuaweiModelArtsService] Response status: 200
```

---

### Test 3: Various Retinal Images

Test with multiple image types to verify model accuracy:

#### 3.1 Normal Retinal Images
- **Test Case:** Upload 2-3 normal retinal images
- **Expected:** All classified as "Normal" with high confidence
- **Verify:** Severity = "Normal", general recommendations provided

#### 3.2 Diabetic Retinopathy Images
- **Test Case:** Upload DR images at different stages
- **Expected:** Classified as "Diabetic Retinopathy"
- **Verify:** 
  - Severity based on confidence
  - Recommendation includes: "Monitor blood sugar and consider specialist treatment"

#### 3.3 Glaucoma Images
- **Test Case:** Upload glaucoma images
- **Expected:** Classified as "Glaucoma"
- **Verify:** Recommendation includes: "Use prescribed drops and monitor IOP"

#### 3.4 Age-related Macular Degeneration
- **Test Case:** Upload AMD images
- **Expected:** Classified as "Age-related Macular Degeneration"
- **Verify:** Recommendation includes: "Discuss AREDS2 supplements with your doctor"

#### 3.5 Hypertensive Retinopathy
- **Test Case:** Upload hypertensive retinopathy images
- **Expected:** Classified as "Hypertensive Retinopathy"
- **Verify:** Recommendation includes: "Control blood pressure and reduce salt intake"

---

### Test 4: English Locale

#### 4.1 Set Locale to English
1. Open app settings or language selector
2. Select "English"
3. Navigate to Diagnosis page

#### 4.2 Perform Analysis
1. Upload retinal image
2. Click "Analyze"

**Expected Behavior:**
- All UI text in English
- Recommendations in English
- Error messages in English
- AI second opinion in English

**Verify UI Elements:**
- Model selection label
- Upload button text
- Analyze button text
- Results section headers
- Recommendation text

---

### Test 5: Arabic Locale

#### 5.1 Set Locale to Arabic
1. Open app settings or language selector
2. Select "العربية" (Arabic)
3. Navigate to Diagnosis page

#### 5.2 Perform Analysis
1. Upload retinal image
2. Click "Analyze"

**Expected Behavior:**
- All UI text in Arabic (RTL layout)
- Recommendations in Arabic
- Error messages in Arabic
- AI second opinion may be in English (depends on AI service)

**Verify UI Elements:**
- Right-to-left text direction
- Arabic translations for all labels
- Proper Arabic font rendering
- Numbers displayed correctly

**Note:** Check `assets/l10n/app_ar.arb` for available translations.

---

### Test 6: UI Display Verification

#### 6.1 Results Display Components
Verify all UI elements display correctly:

**Confidence Score:**
- [ ] Displayed as percentage (e.g., "92%")
- [ ] Color-coded based on severity
- [ ] Properly formatted

**Condition Card:**
- [ ] Condition name displayed
- [ ] Severity badge shown (Normal/Low/Medium/High)
- [ ] Confidence score visible
- [ ] Proper styling and spacing

**Recommendations List:**
- [ ] All recommendations displayed
- [ ] AI second opinion at top (if available)
- [ ] Proper bullet points or numbering
- [ ] Readable font size
- [ ] Scrollable if list is long

**Error Display:**
- [ ] Error messages shown in red or warning color
- [ ] Clear and actionable text
- [ ] Dismiss button available

#### 6.2 Responsive Design
Test on different screen sizes:
- [ ] Desktop (1920x1080)
- [ ] Tablet (768x1024)
- [ ] Mobile (375x667)

**Verify:**
- Layout adapts to screen size
- Images scale properly
- Text remains readable
- Buttons accessible

#### 6.3 Loading States
- [ ] Loading indicator appears during analysis
- [ ] Analyze button disabled while processing
- [ ] Previous results cleared before new analysis
- [ ] Smooth transitions between states

---

## Test Scenarios Summary

### Scenario 1: Happy Path - Normal Image
| Step | Action | Expected Result | Status |
|------|--------|----------------|--------|
| 1 | Start backend | Server running on 3001 | ⬜ |
| 2 | Start web app | App loads successfully | ⬜ |
| 3 | Select retinal model | Model selected | ⬜ |
| 4 | Upload normal image | Image preview shown | ⬜ |
| 5 | Click analyze | Analysis starts | ⬜ |
| 6 | Wait for result | "Normal" classification | ⬜ |
| 7 | Check severity | Severity = "Normal" | ⬜ |
| 8 | Check recommendations | General recommendations shown | ⬜ |

### Scenario 2: Happy Path - Diseased Image
| Step | Action | Expected Result | Status |
|------|--------|----------------|--------|
| 1 | Upload diseased image | Image preview shown | ⬜ |
| 2 | Click analyze | Analysis starts | ⬜ |
| 3 | Wait for result | Disease name shown | ⬜ |
| 4 | Check severity | Severity based on confidence | ⬜ |
| 5 | Check recommendations | Condition-specific recs shown | ⬜ |
| 6 | Check second opinion | AI reasoning displayed | ⬜ |

### Scenario 3: Multiple Images
| Step | Action | Expected Result | Status |
|------|--------|----------------|--------|
| 1 | Analyze image 1 | Results displayed | ⬜ |
| 2 | Clear image | Results cleared | ⬜ |
| 3 | Upload image 2 | New image shown | ⬜ |
| 4 | Analyze image 2 | New results displayed | ⬜ |
| 5 | Verify token cache | Backend uses cached token | ⬜ |

### Scenario 4: Locale Switching
| Step | Action | Expected Result | Status |
|------|--------|----------------|--------|
| 1 | Set locale to English | UI in English | ⬜ |
| 2 | Analyze image | Results in English | ⬜ |
| 3 | Switch to Arabic | UI switches to Arabic | ⬜ |
| 4 | Analyze same image | Results in Arabic | ⬜ |

---

## Verification Checklist

### Requirements Coverage

#### Requirement 1.1, 1.2, 1.3, 1.4 - ModelArts Integration
- [ ] Image uploaded and sent to ModelArts
- [ ] Base64 encoding works correctly
- [ ] ModelArts returns successful response
- [ ] Predicted class and confidence extracted
- [ ] Web platform uses backend proxy

#### Requirement 5.1, 5.2, 5.3, 5.4, 5.5 - Severity Mapping
- [ ] Normal condition → "Normal" severity
- [ ] Confidence ≥ 0.9 → "High" severity
- [ ] Confidence 0.8-0.9 → "Medium" severity
- [ ] Confidence < 0.8 → "Low" severity

#### Requirement 5.6 - Recommendations
- [ ] Condition-specific recommendations generated
- [ ] General eye health advice included
- [ ] Recommendations appropriate for condition

---

## Logging Verification

### Backend Logs to Check
```
[timestamp] POST /api/modelarts/infer - Service: c3ea302b...
[timestamp] Obtaining new IAM token... (or Using cached IAM token)
[timestamp] IAM token obtained successfully
[timestamp] ModelArts Response Status: 200
[timestamp] ModelArts Response: {"prediction": "...", ...}
```

### Browser Console Logs to Check
```
[DiagnosisProvider] Using real ModelArts inference for retinal model
[DiagnosisProvider] Requesting AI second opinion...
[DiagnosisProvider] Second opinion received (XXX chars)
[DiagnosisProvider] Diagnosis complete - Class: XXX, Confidence: 0.XX
[RetinaInferenceService] Initialized with ModelArts config
[RetinaInferenceService] ModelArts response keys: [prediction, confidence, ...]
[HuaweiModelArtsService] Using web proxy for ModelArts API
[HuaweiModelArtsService] Invoke URL: http://localhost:3001/api/modelarts/infer
```

---

## Common Issues and Solutions

### Issue 1: Backend Not Running
**Symptom:** Network error when analyzing
**Solution:** Start backend with `node backend/server.js`

### Issue 2: CORS Error
**Symptom:** CORS policy error in browser console
**Solution:** Ensure backend CORS is enabled (already configured)

### Issue 3: IAM Token Failure
**Symptom:** 401 error after retry
**Solution:** Verify credentials in env.json

### Issue 4: No Second Opinion
**Symptom:** Second opinion not appearing
**Solution:** Check HUAWEI_AI_API_KEY in env.json (graceful failure is expected)

### Issue 5: Wrong Severity
**Symptom:** Severity doesn't match confidence
**Solution:** Verify _mapSeverity logic in diagnosis_provider_web.dart

---

## Test Results Template

### Test Execution Date: _______________
### Tester Name: _______________
### Platform: [ ] Web [ ] Mobile [ ] Desktop

| Test Case | Status | Notes |
|-----------|--------|-------|
| Web platform with proxy | ⬜ Pass ⬜ Fail | |
| Normal image classification | ⬜ Pass ⬜ Fail | |
| Diseased image classification | ⬜ Pass ⬜ Fail | |
| Severity mapping | ⬜ Pass ⬜ Fail | |
| Recommendations generation | ⬜ Pass ⬜ Fail | |
| English locale | ⬜ Pass ⬜ Fail | |
| Arabic locale | ⬜ Pass ⬜ Fail | |
| UI display | ⬜ Pass ⬜ Fail | |
| Token caching | ⬜ Pass ⬜ Fail | |
| Second opinion integration | ⬜ Pass ⬜ Fail | |

### Overall Result: ⬜ PASS ⬜ FAIL

### Issues Found:
1. 
2. 
3. 

### Recommendations:
1. 
2. 
3. 

---

## Next Steps

After completing manual testing:
1. Document any issues found
2. Verify all requirements are met
3. Update task status to complete
4. Proceed to Task 12: Validate second opinion integration
5. Continue to Task 13: Performance and optimization validation

