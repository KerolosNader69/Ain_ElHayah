# Manual Testing Checklist - ModelArts Retina Integration

**Tester:** _______________  
**Date:** _______________  
**Platform:** Web  
**Browser:** Chrome  

---

## Pre-Testing Setup

- [ ] Backend server running on port 3001
- [ ] Flutter web app running in Chrome
- [ ] Test retinal images prepared (normal and diseased)
- [ ] MANUAL_TESTING_GUIDE.md reviewed

---

## Test 1: Web Platform with Backend Proxy

### 1.1 Backend Server Verification
- [ ] Backend started successfully
- [ ] Health check endpoint responds: http://localhost:3001/health
- [ ] Console shows server startup message

**Notes:**
```
_________________________________________________________________
```

### 1.2 Flutter Web App Launch
- [ ] App loads without errors
- [ ] No console errors in browser DevTools
- [ ] Navigation works properly

**Notes:**
```
_________________________________________________________________
```

---

## Test 2: Normal Retinal Image Analysis

### 2.1 Upload Normal Image
- [ ] Navigate to Diagnosis page
- [ ] Select "Retinal Model" from dropdown
- [ ] Upload normal retinal image
- [ ] Image preview displays correctly

### 2.2 Analyze Normal Image
- [ ] Click "Analyze" button
- [ ] Loading indicator appears
- [ ] Backend logs show ModelArts API call
- [ ] IAM token obtained (first time) or cached token used

**Backend Console Output:**
```
POST /api/modelarts/infer - Service: c3ea302b...
[Obtaining new IAM token / Using cached IAM token]
IAM token obtained successfully
ModelArts Response Status: 200
```

### 2.3 Verify Normal Image Results
- [ ] Analysis completes successfully
- [ ] Predicted class: "Normal"
- [ ] Severity: "Normal"
- [ ] Confidence score displayed (0.0 - 1.0)
- [ ] Recommendations list shown
- [ ] AI second opinion displayed (if available)

**Browser Console Output:**
```
[DiagnosisProvider] Using real ModelArts inference for retinal model
[DiagnosisProvider] Requesting AI second opinion...
[DiagnosisProvider] Diagnosis complete - Class: Normal, Confidence: 0.XX
```

**Results:**
- Predicted Class: _______________
- Confidence: _______________
- Severity: _______________
- Number of Recommendations: _______________

**Notes:**
```
_________________________________________________________________
```

---

## Test 3: Diseased Retinal Image Analysis

### 3.1 Upload Diseased Image
- [ ] Clear previous image
- [ ] Upload diseased retinal image (e.g., Diabetic Retinopathy)
- [ ] Image preview displays correctly

### 3.2 Analyze Diseased Image
- [ ] Click "Analyze" button
- [ ] Loading indicator appears
- [ ] Backend uses cached IAM token

**Backend Console Output:**
```
Using cached IAM token
ModelArts Response Status: 200
```

### 3.3 Verify Diseased Image Results
- [ ] Analysis completes successfully
- [ ] Predicted class: Disease name (not "Normal")
- [ ] Severity matches confidence level:
  - [ ] Confidence ≥ 0.9 → Severity = "High"
  - [ ] Confidence 0.8-0.89 → Severity = "Medium"
  - [ ] Confidence < 0.8 → Severity = "Low"
- [ ] Condition-specific recommendations shown
- [ ] AI second opinion with reasoning displayed

**Results:**
- Predicted Class: _______________
- Confidence: _______________
- Severity: _______________
- Severity Mapping Correct: [ ] Yes [ ] No

**Condition-Specific Recommendations Found:**
- [ ] Diabetic Retinopathy: "Monitor blood sugar and consider specialist treatment"
- [ ] Glaucoma: "Use prescribed drops and monitor IOP"
- [ ] AMD: "Discuss AREDS2 supplements with your doctor"
- [ ] Hypertensive Retinopathy: "Control blood pressure and reduce salt intake"
- [ ] Other: _______________

**Notes:**
```
_________________________________________________________________
```

---

## Test 4: Multiple Image Analysis

### 4.1 Analyze Multiple Images in Sequence
- [ ] Analyze image 1 - results displayed
- [ ] Clear image
- [ ] Analyze image 2 - new results displayed
- [ ] Analyze image 3 - new results displayed
- [ ] Previous results properly cleared each time

### 4.2 Verify Token Caching
- [ ] Backend logs show "Using cached IAM token" for subsequent requests
- [ ] No repeated token acquisition calls

**Notes:**
```
_________________________________________________________________
```

---

## Test 5: English Locale

### 5.1 Set Locale to English
- [ ] App language set to English
- [ ] Navigate to Diagnosis page

### 5.2 Verify English UI
- [ ] Model selection label in English
- [ ] Upload button text in English
- [ ] Analyze button text in English
- [ ] Results section headers in English

### 5.3 Analyze Image in English
- [ ] Upload and analyze retinal image
- [ ] All recommendations in English
- [ ] Error messages (if any) in English
- [ ] AI second opinion in English

**Notes:**
```
_________________________________________________________________
```

---

## Test 6: Arabic Locale (If Supported)

### 6.1 Set Locale to Arabic
- [ ] App language set to Arabic (العربية)
- [ ] Navigate to Diagnosis page
- [ ] UI switches to RTL (right-to-left) layout

### 6.2 Verify Arabic UI
- [ ] Model selection label in Arabic
- [ ] Upload button text in Arabic
- [ ] Analyze button text in Arabic
- [ ] Results section headers in Arabic
- [ ] Text direction is RTL
- [ ] Arabic font renders correctly

### 6.3 Analyze Image in Arabic
- [ ] Upload and analyze retinal image
- [ ] Recommendations in Arabic (if translated)
- [ ] Error messages (if any) in Arabic
- [ ] Numbers display correctly

**Notes:**
```
_________________________________________________________________
```

---

## Test 7: UI Display Verification

### 7.1 Results Display Components
- [ ] Confidence score displayed as percentage
- [ ] Confidence score color-coded by severity
- [ ] Condition name clearly visible
- [ ] Severity badge displayed (Normal/Low/Medium/High)
- [ ] Severity badge color-coded appropriately

### 7.2 Recommendations Display
- [ ] All recommendations visible
- [ ] AI second opinion at top (if available)
- [ ] Proper formatting (bullets/numbering)
- [ ] Text is readable
- [ ] List is scrollable if long

### 7.3 Loading States
- [ ] Loading indicator appears during analysis
- [ ] Analyze button disabled while processing
- [ ] Previous results cleared before new analysis
- [ ] Smooth transitions between states

### 7.4 Error Display
- [ ] Error messages shown clearly
- [ ] Error text is actionable
- [ ] Error styling (red/warning color)
- [ ] Dismiss/retry option available

**Notes:**
```
_________________________________________________________________
```

---

## Test 8: Responsive Design

### 8.1 Desktop View (1920x1080)
- [ ] Layout looks good
- [ ] All elements visible
- [ ] No overflow issues
- [ ] Images scale properly

### 8.2 Tablet View (768x1024)
- [ ] Layout adapts correctly
- [ ] Touch targets adequate size
- [ ] Text remains readable
- [ ] No horizontal scrolling

### 8.3 Mobile View (375x667)
- [ ] Layout stacks vertically
- [ ] All features accessible
- [ ] Text size appropriate
- [ ] Buttons easy to tap

**Notes:**
```
_________________________________________________________________
```

---

## Test 9: Error Scenarios

### 9.1 No Image Selected
- [ ] Click "Analyze" without selecting image
- [ ] Error message: "Please select an image and model first"
- [ ] Error displayed clearly

### 9.2 No Model Selected
- [ ] Select image but no model
- [ ] Click "Analyze"
- [ ] Error message displayed

### 9.3 Network Error Simulation
- [ ] Stop backend server
- [ ] Try to analyze image
- [ ] Error message about network/connection
- [ ] User can retry after restarting backend

**Notes:**
```
_________________________________________________________________
```

---

## Test 10: Performance Verification

### 10.1 Analysis Speed
- [ ] Analysis completes in reasonable time (< 10 seconds)
- [ ] No UI freezing during analysis
- [ ] Loading indicator provides feedback

### 10.2 Token Caching
- [ ] First request: IAM token obtained (~2-3 seconds)
- [ ] Subsequent requests: Cached token used (faster)
- [ ] Token cache persists across multiple analyses

**Timing:**
- First analysis: _______________ seconds
- Second analysis: _______________ seconds
- Third analysis: _______________ seconds

**Notes:**
```
_________________________________________________________________
```

---

## Requirements Coverage Verification

### Requirement 1.1, 1.2, 1.3, 1.4 - ModelArts Integration
- [ ] Image uploaded and sent to ModelArts
- [ ] Base64 encoding works correctly
- [ ] ModelArts returns successful response
- [ ] Predicted class and confidence extracted
- [ ] Web platform uses backend proxy

### Requirement 5.1, 5.2, 5.3, 5.4, 5.5 - Severity Mapping
- [ ] Normal condition → "Normal" severity
- [ ] Confidence ≥ 0.9 → "High" severity
- [ ] Confidence 0.8-0.9 → "Medium" severity
- [ ] Confidence < 0.8 → "Low" severity

### Requirement 5.6 - Recommendations
- [ ] Condition-specific recommendations generated
- [ ] General eye health advice included
- [ ] Recommendations appropriate for condition

**Notes:**
```
_________________________________________________________________
```

---

## Overall Test Summary

### Tests Passed: _____ / _____

### Critical Issues Found:
1. 
2. 
3. 

### Minor Issues Found:
1. 
2. 
3. 

### Recommendations:
1. 
2. 
3. 

---

## Final Verdict

**Overall Result:** [ ] PASS [ ] FAIL [ ] PASS WITH ISSUES

**Ready for Production:** [ ] Yes [ ] No [ ] With Fixes

**Tester Signature:** _______________

**Date Completed:** _______________

---

## Additional Notes

```
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
```
