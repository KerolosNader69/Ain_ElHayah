# Huawei ModelArts Integration Setup

## Quick Start

1. **Add configuration to `env.json`:**

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

2. **Use in your code:**

```dart
import 'package:eye_wise_connect/services/huawei_modelarts_service.dart';
import 'package:eye_wise_connect/services/api_key_loader.dart';

// Load config
final config = await ApiKeyLoaderModelArts.loadHuaweiModelArtsConfig();
if (config == null || !config.isComplete) {
  throw Exception('ModelArts configuration missing');
}

// Create service
final service = HuaweiModelArtsService(config: config);

// Run inference
final imageBytes = /* your image bytes */;
try {
  final result = await service.inferImage(imageBytes);
  // Process result
} catch (e) {
  if (e is Map<String, dynamic>) {
    // Structured error: { "statusCode": int, "body": Map }
    final statusCode = e['statusCode'];
    final body = e['body'];
  } else {
    // Exception (e.g., image too large)
  }
}
```

## Features

- ✅ Automatic IAM token management (cached until expiry)
- ✅ Dual payload format support (tries both automatically)
- ✅ 8MB image size limit with clear error messages
- ✅ Structured error responses
- ✅ Configuration from env.json or compile-time variables

## Security Note

⚠️ **For mobile apps**: Consider using a backend proxy to handle authentication instead of embedding AK/SK credentials in the app. If used directly, ensure proper obfuscation and secure storage.

## Getting Your Credentials

1. **Project ID**: From Huawei Cloud Console → Project Management
2. **Access Key / Secret Key**: From IAM → My Credentials → Access Keys
3. **Service ID**: From ModelArts → Deployment → Your Endpoint → Service ID
4. **Region**: Your ModelArts deployment region (e.g., `ap-southeast-3`)
5. **Invoke URL**: Format: `https://infer-modelarts-{region}.modelarts-infer.com/v1/infers/<SERVICE_ID>`

