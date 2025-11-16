# Quick Start - Run Web with ModelArts

## الطريقة الأسهل:

### 1. افتح Command Prompt (cmd) - ليس PowerShell

### 2. اذهب إلى مجلد المشروع:

```cmd
cd "D:\eye-wise-connect-main (3)\eye-wise-connect-main (2)\eye-wise-connect-main"
```

### 3. شغّل:

```cmd
run_web.bat
```

## أو انسخ هذا الأمر بالكامل:

```cmd
flutter run -d chrome --dart-define=MODELARTS_PROJECT_ID=59dcb311da5e4ca6b8db8bbc7a7712d7 --dart-define=MODELARTS_ACCESS_KEY=HPUALP3GCEZ2AMWETEHI --dart-define=MODELARTS_SECRET_KEY=ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM --dart-define=MODELARTS_SERVICE_ID=c3ea302b-d98b-4f80-85bb-552e9ca8e0c9 --dart-define=MODELARTS_REGION=ap-southeast-3 --dart-define=MODELARTS_INVOKE_URL=https://infer-modelarts-ap-southeast-3.modelarts-infer.com/v1/infers/<SERVICE_ID>
```

## ملاحظات مهمة:

1. **استخدم Command Prompt (cmd)** وليس PowerShell
2. **تأكد** أن التطبيق لم يشتغل بالفعل - أغلق أي نافذة Chrome مفتوحة
3. **انتظر** حتى يفتح Chrome تلقائياً
4. **افتح Console** (F12) لرؤية الـ logs

## إذا ظهرت نفس المشكلة:

1. تأكد أنك استخدمت **Command Prompt** وليس PowerShell
2. تأكد أنك في المجلد الصحيح
3. جرب نسخ الأمر مباشرة بدلاً من استخدام الـ batch file

