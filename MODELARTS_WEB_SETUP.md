# ModelArts Setup for Web

## المشكلة
على الويب (web)، لا يمكن قراءة `env.json` مباشرة. يجب استخدام compile-time variables.

## الحل: استخدام --dart-define

### 1. شغّل التطبيق مع المتغيرات:

```bash
flutter run -d chrome \
  --dart-define=MODELARTS_PROJECT_ID=your-project-id \
  --dart-define=MODELARTS_ACCESS_KEY=your-access-key \
  --dart-define=MODELARTS_SECRET_KEY=your-secret-key \
  --dart-define=MODELARTS_SERVICE_ID=your-service-id \
  --dart-define=MODELARTS_REGION=ap-southeast-3 \
  --dart-define=MODELARTS_INVOKE_URL=https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>
```

### 2. أو استخدم ملف script:

**Windows (PowerShell):**
```powershell
flutter run -d chrome `
  --dart-define=MODELARTS_PROJECT_ID=59dcb311da5e4ca6b8db8bbc7a7712d7 `
  --dart-define=MODELARTS_ACCESS_KEY=HPUALP3GCEZ2AMWETEHI `
  --dart-define=MODELARTS_SECRET_KEY=ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM `
  --dart-define=MODELARTS_SERVICE_ID=c3ea302b-d98b-4f80-85bb-552e9ca8e0c9 `
  --dart-define=MODELARTS_REGION=ap-southeast-3 `
  --dart-define=MODELARTS_INVOKE_URL=https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>
```

**Mac/Linux:**
```bash
flutter run -d chrome \
  --dart-define=MODELARTS_PROJECT_ID=59dcb311da5e4ca6b8db8bbc7a7712d7 \
  --dart-define=MODELARTS_ACCESS_KEY=HPUALP3GCEZ2AMWETEHI \
  --dart-define=MODELARTS_SECRET_KEY=ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM \
  --dart-define=MODELARTS_SERVICE_ID=c3ea302b-d98b-4f80-85bb-552e9ca8e0c9 \
  --dart-define=MODELARTS_REGION=ap-southeast-3 \
  --dart-define=MODELARTS_INVOKE_URL=https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>
```

### 3. للـ Build:

```bash
flutter build web \
  --dart-define=MODELARTS_PROJECT_ID=... \
  --dart-define=MODELARTS_ACCESS_KEY=... \
  --dart-define=MODELARTS_SECRET_KEY=... \
  --dart-define=MODELARTS_SERVICE_ID=... \
  --dart-define=MODELARTS_REGION=ap-southeast-3 \
  --dart-define=MODELARTS_INVOKE_URL=...
```

## ملاحظات

- على **Mobile/Desktop**: يمكن استخدام `env.json` (أسهل)
- على **Web**: يجب استخدام `--dart-define` (compile-time variables)
- **لا تضع** credentials في الكود مباشرة لأسباب أمنية

## استكشاف الأخطاء

إذا ظهرت رسالة "ModelArts configuration is missing":
1. تأكد أنك استخدمت `--dart-define` لكل المتغيرات
2. تأكد أن القيم صحيحة (خاصة SERVICE_ID)
3. تحقق من Console logs لرؤية أي متغيرات مفقودة

