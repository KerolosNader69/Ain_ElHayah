# ModelArts Debugging Guide

## المشكلة: المودل يعطي Confidence 0.0% أو Unknown

### الخطوات للـ Debugging:

#### 1. تحقق من Console Logs

عند تشغيل التطبيق، افتح Developer Console (F12 في المتصفح) وابحث عن:
- `[RetinaInferenceService] Initializing ModelArts service...`
- `[RetinaInferenceService] ModelArts config loaded successfully`
- `[RetinaInferenceService] Calling ModelArts inference...`
- `[RetinaInferenceService] ModelArts response: {...}`

#### 2. تحقق من الإعدادات في env.json

تأكد أن جميع الحقول موجودة ومملوءة:

```json
{
  "MODELARTS_PROJECT_ID": "your-project-id",
  "MODELARTS_ACCESS_KEY": "your-access-key",
  "MODELARTS_SECRET_KEY": "your-secret-key",
  "MODELARTS_SERVICE_ID": "your-service-id",
  "MODELARTS_REGION": "ap-southeast-3",
  "MODELARTS_INVOKE_URL": "https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>"
}
```

#### 3. تحقق من تنسيق الاستجابة

إذا رأيت في الـ logs:
```
[RetinaInferenceService] WARNING: Could not parse ModelArts response properly.
[RetinaInferenceService] Full response: {...}
```

هذا يعني أن تنسيق الاستجابة من ModelArts مختلف عما نتوقع.

**الحل:** أرسل لي الـ response الكامل من الـ logs وسأعدل الكود ليتعامل معه.

#### 4. تنسيقات الاستجابة المتوقعة

الكود يحاول التعامل مع هذه التنسيقات:

**Format 1:**
```json
{
  "prediction": "class_name",
  "confidence": 0.95,
  "probabilities": {
    "class1": 0.95,
    "class2": 0.05
  }
}
```

**Format 2:**
```json
{
  "result": {
    "class": "class_name",
    "score": 0.95,
    "probabilities": {...}
  }
}
```

**Format 3:**
```json
{
  "predictions": [
    {
      "class": "class_name",
      "confidence": 0.95,
      "probabilities": {...}
    }
  ]
}
```

#### 5. إذا كان التنسيق مختلف

إذا كان تنسيق الاستجابة من ModelArts مختلف، أرسل لي:
1. الـ response الكامل من الـ logs
2. سأعدل الكود في `retina_inference_service_mobile.dart` ليتعامل معه

#### 6. تحقق من Service ID

- تأكد أن `MODELARTS_SERVICE_ID` صحيح
- يمكنك الحصول عليه من ModelArts Console → Deployment → Your Endpoint

#### 7. تحقق من أن الـ Deployment نشط

- في ModelArts Console، تأكد أن الـ deployment في حالة "Running"
- إذا كان "Stopped"، شغّله

#### 8. تحقق من Network

- تأكد من الاتصال بالإنترنت
- تحقق من أن الـ endpoint URL صحيح

## كيفية الحصول على الـ Response الكامل

1. افتح Developer Console (F12)
2. ابحث عن: `[RetinaInferenceService] ModelArts response:`
3. انسخ الـ response الكامل
4. أرسله لي مع وصف المشكلة

## أمثلة على الأخطاء الشائعة

### Error: "ModelArts configuration is missing"
**الحل:** أضف الإعدادات في `env.json`

### Error: "ModelArts inference failed (status: 401)"
**الحل:** تحقق من Access Key و Secret Key

### Error: "ModelArts inference failed (status: 404)"
**الحل:** تحقق من Service ID و Invoke URL

### Confidence 0.0% مع Unknown
**الحل:** تنسيق الاستجابة مختلف - أرسل الـ response الكامل

