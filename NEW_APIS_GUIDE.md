# New APIs Guide

## Overview
Two new APIs have been added to fix the questionnaire and retinal analysis features:

1. **Questionnaire Analysis API** - Analyzes health questionnaire responses
2. **Mock Retinal Analysis API** - Provides mock retinal diagnosis (since ModelArts isn't working)

---

## 1. Questionnaire Analysis API

### Endpoint
```
POST http://localhost:3001/api/questionnaire/analyze
```

### Request Body
```json
{
  "answers": {
    "for_whom": "self",
    "gender": "male",
    "age": { "years": 45, "months": 0, "days": 0 },
    "recent_injury": "no",
    "smoking_10y": "no",
    "family_allergy": "yes",
    "obesity": "no",
    "diabetes": "yes",
    "hypertension": "yes",
    "headache": { "type": "Eye strain", "severity": "Moderate" },
    "other_symptoms": "Blurry vision, dry eyes",
    "country": "Egypt",
    "locale": "en"
  }
}
```

### Response
```json
{
  "success": true,
  "conditions": [
    {
      "name": "Diabetic Retinopathy Risk",
      "probability": 0.65,
      "rationale": "Patient has diabetes, which increases risk of retinal damage"
    },
    {
      "name": "Computer Vision Syndrome",
      "probability": 0.70,
      "rationale": "Symptoms suggest eye strain from prolonged screen use"
    }
  ],
  "recommendations": [
    "Schedule a comprehensive eye examination with an ophthalmologist",
    "Regular eye screenings are crucial for managing systemic conditions",
    "Follow the 20-20-20 rule: Every 20 minutes, look at something 20 feet away for 20 seconds"
  ],
  "red_flags": [],
  "disclaimer": "This is an AI-assisted preliminary assessment. Always consult with a qualified ophthalmologist for accurate diagnosis and treatment."
}
```

### Features
- Rule-based analysis considering:
  - Age-related conditions
  - Systemic diseases (diabetes, hypertension)
  - Symptoms and headache types
  - Family history
  - Lifestyle factors
- Provides probability scores (0-1)
- Generates personalized recommendations
- Identifies red flags requiring urgent attention

---

## 2. Mock Retinal Analysis API

### Endpoint
```
POST http://localhost:3001/api/retinal/analyze
```

### Request Body
```json
{
  "imageBase64": "base64_encoded_image_data_here"
}
```

### Response
```json
{
  "success": true,
  "confidence": 0.87,
  "conditions": [
    {
      "name": "Diabetic Retinopathy",
      "severity": "Mild",
      "confidence": 0.72,
      "description": "Early signs of diabetic retinopathy detected"
    },
    {
      "name": "Microaneurysms",
      "severity": "Mild",
      "confidence": 0.68,
      "description": "Small vascular abnormalities present"
    }
  ],
  "recommendations": [
    "Schedule follow-up examination in 6 months",
    "Maintain good blood sugar control",
    "Regular monitoring recommended",
    "Consult with ophthalmologist for detailed assessment"
  ],
  "analysis_date": "2025-11-15T12:00:00.000Z",
  "model_version": "mock-v1.0",
  "disclaimer": "⚠️ This is a MOCK result for testing purposes. Real ModelArts integration is not active."
}
```

### Features
- Simulates 2-second processing delay (realistic)
- Returns mock diabetic retinopathy diagnosis
- Provides confidence scores
- Includes severity levels
- Generates appropriate recommendations
- **Note**: This is for testing only until ModelArts is fixed

---

## Testing

### Test Both APIs
```bash
node test_new_apis.js
```

### Test Questionnaire Only
```bash
curl -X POST http://localhost:3001/api/questionnaire/analyze \
  -H "Content-Type: application/json" \
  -d '{"answers":{"diabetes":"yes","hypertension":"yes","age":{"years":45}}}'
```

### Test Retinal Analysis Only
```bash
curl -X POST http://localhost:3001/api/retinal/analyze \
  -H "Content-Type: application/json" \
  -d '{"imageBase64":"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="}'
```

---

## Integration

### Flutter Integration

The APIs are automatically integrated:

1. **Questionnaire**: `lib/services/ai_chat_service.dart`
   - Method: `analyzeQuestionnaireStructured()`
   - Tries backend API first, falls back to AI if unavailable

2. **Retinal Analysis**: `lib/providers/diagnosis_provider_web.dart`
   - Method: `analyzeImage()`
   - Tries mock API first, falls back to ModelArts if unavailable

---

## Usage in App

### 1. Start Backend
```bash
cd backend
node server.js
```

### 2. Run Flutter App
```bash
flutter run -d chrome
```

### 3. Test Questionnaire
1. Navigate to Diagnosis screen
2. Click "Start questionnaire"
3. Fill out the form
4. View AI-generated analysis

### 4. Test Retinal Analysis
1. Navigate to Diagnosis screen
2. Click "Try Retinal Lens"
3. Upload a retinal image
4. View mock analysis results

---

## Next Steps

1. **Free up disk space** to run Flutter:
   ```bash
   .\free_disk_space.ps1
   ```

2. **Test the new APIs**:
   ```bash
   node test_new_apis.js
   ```

3. **Run the app**:
   ```bash
   flutter run -d chrome
   ```

4. **When ModelArts is fixed**:
   - The retinal analysis will automatically fall back to real ModelArts
   - Remove mock API or keep it as a fallback

---

## Troubleshooting

### Backend not responding
- Make sure backend is running: `cd backend && node server.js`
- Check port 3001 is not in use

### Questionnaire not working
- Check browser console for errors
- Verify backend API is accessible
- Check network tab in DevTools

### Retinal analysis fails
- Mock API should always work
- If both mock and ModelArts fail, check backend logs
- Verify image is being sent as base64

---

## Summary

✅ **Questionnaire Analysis** - Working with rule-based AI
✅ **Mock Retinal Analysis** - Working with simulated results
✅ **Automatic Fallbacks** - Flutter tries backend first, then AI
✅ **Ready to Test** - Just start backend and run Flutter app

The questionnaire feature now works without requiring external AI APIs, and the retinal analysis has a working mock until ModelArts is fixed!
