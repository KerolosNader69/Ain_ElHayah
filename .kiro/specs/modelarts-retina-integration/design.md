# Design Document

## Overview

This design document outlines the technical approach for integrating the trained Huawei ModelArts retina disease classification model into the EyeWise Connect diagnosis page. The integration will replace the current mock data implementation with real AI-powered predictions from the deployed ModelArts endpoint in the ap-southeast-3 region.

The system follows a layered architecture with clear separation of concerns:
- **Presentation Layer**: DiagnosisProvider manages UI state and user interactions
- **Service Layer**: RetinaInferenceService handles business logic and orchestration
- **Integration Layer**: HuaweiModelArtsService manages API communication and authentication
- **Proxy Layer**: Backend Node.js server handles web platform CORS restrictions

## Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           DiagnosisProvider (State Management)         │ │
│  │  - User interaction handling                           │ │
│  │  - Result display logic                                │ │
│  │  - Error handling                                      │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │                                        │
│  ┌──────────────────▼─────────────────────────────────────┐ │
│  │      RetinaInferenceService (Business Logic)           │ │
│  │  - Image preprocessing                                 │ │
│  │  - Response parsing                                    │ │
│  │  - Result transformation                               │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │                                        │
│  ┌──────────────────▼─────────────────────────────────────┐ │
│  │    HuaweiModelArtsService (API Integration)            │ │
│  │  - Base64 encoding                                     │ │
│  │  - IAM authentication                                  │ │
│  │  - HTTP communication                                  │ │
│  │  - Token caching                                       │ │
│  └──────────────────┬─────────────────────────────────────┘ │
│                     │                                        │
└─────────────────────┼────────────────────────────────────────┘
                      │
        ┌─────────────┴──────────────┐
        │                            │
        │ Web Platform               │ Mobile/Desktop Platform
        │                            │
┌───────▼────────┐          ┌────────▼────────┐
│  Backend Proxy │          │  Direct HTTPS   │
│  (Node.js)     │          │  to ModelArts   │
│  Port 3001     │          │                 │
└───────┬────────┘          └────────┬────────┘
        │                            │
        └─────────────┬──────────────┘
                      │
        ┌─────────────▼──────────────┐
        │  Huawei Cloud ModelArts    │
        │  Inference Endpoint        │
        │  ap-southeast-3 region     │
        │  Service ID: c3ea302b...   │
        └────────────────────────────┘
```

### Authentication Flow

```
┌──────────────┐
│ First API    │
│ Call (401)   │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────┐
│ Request IAM Token                │
│ POST https://iam.{region}.       │
│      myhuaweicloud.com/v3/       │
│      auth/tokens                 │
│                                  │
│ Body: {                          │
│   auth: {                        │
│     identity: {                  │
│       methods: ["ak-sak"],       │
│       ak-sak: {                  │
│         access: AK,              │
│         secret: SK               │
│       }                          │
│     },                           │
│     scope: {                     │
│       project: {id: PROJECT_ID}  │
│     }                            │
│   }                              │
│ }                                │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Extract Token from Header        │
│ x-subject-token: <TOKEN>         │
│                                  │
│ Cache token with expiry          │
│ (24 hours - 5 min buffer)        │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Retry Original Request           │
│ Headers:                         │
│   X-Auth-Token: <TOKEN>          │
│   X-Project-Id: <PROJECT_ID>     │
└──────────────────────────────────┘
```

## Components and Interfaces

### 1. DiagnosisProvider (Updated)

**Location**: `lib/providers/diagnosis_provider_web.dart`

**Responsibilities**:
- Manage diagnosis page state
- Coordinate image analysis workflow
- Parse and display results
- Handle errors gracefully
- Request AI second opinions

**Key Changes**:
```dart
Future<void> analyzeImage({BuildContext? context}) async {
  // Remove mock data path
  // Activate real ModelArts inference
  
  if (_selectedModel == 'retinal') {
    // Get locale for multilingual support
    Locale? locale;
    if (context != null) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      locale = appProvider.locale;
    }
    
    // Call real inference service
    final result = await _retina.predictBytes(_selectedImageBytes!);
    
    // Request DeepSeek second opinion (graceful failure)
    String? deepseekNote;
    try {
      deepseekNote = await AIChatService.reasonWithModelOutputs(
        imageBytes: _selectedImageBytes!,
        probabilities: result.probabilities,
      );
    } catch (_) {
      // Continue without second opinion if it fails
    }
    
    // Build diagnosis result
    final primaryCondition = Condition(
      name: result.predictedClass,
      severity: _mapSeverity(result.predictedClass, result.confidence),
      confidence: result.confidence,
    );
    
    final recs = _generateRecommendations([primaryCondition]);
    if (deepseekNote != null && deepseekNote.trim().isNotEmpty) {
      recs.insert(0, deepseekNote);
    }
    
    _diagnosisResult = DiagnosisResult(
      confidence: result.confidence,
      conditions: [primaryCondition],
      recommendations: recs,
    );
  }
}

String _mapSeverity(String condition, double confidence) {
  if (condition == 'Normal') return 'Normal';
  if (confidence >= 0.9) return 'High';
  if (confidence >= 0.8) return 'Medium';
  return 'Low';
}
```

**Interface**:
```dart
class DiagnosisProvider extends ChangeNotifier {
  // State
  String? _selectedModel;
  Uint8List? _selectedImageBytes;
  bool _isAnalyzing;
  DiagnosisResult? _diagnosisResult;
  String? _error;
  
  // Methods
  Future<void> analyzeImage({BuildContext? context});
  void selectModel(String? model);
  void setImageBytes(Uint8List bytes);
  void clearImage();
  void reset();
}
```

### 2. RetinaInferenceService (Existing - Minor Updates)

**Location**: `lib/services/retina_inference_service_web.dart`

**Responsibilities**:
- Initialize ModelArts service
- Validate configuration
- Call ModelArts inference
- Parse multiple response formats
- Handle errors with detailed logging

**Current Implementation** (already well-designed):
- Supports multiple response formats (prediction, result, predictions array)
- Handles uncertain predictions (confidence < 0.6)
- Provides detailed error messages
- Logs response structure for debugging

**No major changes needed** - the service already handles:
- Configuration loading from env.json
- Multiple payload formats ({"image": "..."} and {"instances": [...]})
- Response parsing with fallbacks
- Error handling with structured messages

### 3. HuaweiModelArtsService (Existing - Minor Updates)

**Location**: `lib/services/huawei_modelarts_service.dart`

**Responsibilities**:
- Manage HTTP communication with ModelArts
- Handle IAM token lifecycle
- Enforce 8MB image size limit
- Support web proxy and direct calls
- Retry with alternative payload formats

**Current Implementation** (already complete):
- Token caching with expiry management
- Automatic 401 handling and retry
- Web platform proxy support
- Multiple payload format attempts
- Comprehensive error handling

**Key Methods**:
```dart
class HuaweiModelArtsService {
  Future<Map<String, dynamic>> inferImage(Uint8List imageBytes);
  Future<void> _ensureToken();
  Future<Map<String, dynamic>> _tryInference(String url, Map<String, dynamic> payload);
  void clearToken();
}
```

### 4. Backend Proxy (Existing - No Changes Needed)

**Location**: `backend/server.js`

**Responsibilities**:
- Handle CORS for web platform
- Forward requests to ModelArts
- Manage IAM token caching (23 hours)
- Return structured responses

**Current Implementation** (already complete):
```javascript
app.post('/api/modelarts/infer', async (req, res) => {
  // Extract credentials from request
  const { imageBase64, serviceId, region, accessKey, secretKey, projectId } = req.body;
  
  // Get or refresh IAM token
  const token = await getIAMToken(accessKey, secretKey, projectId, region);
  
  // Forward to ModelArts
  const response = await fetch(modelArtsUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Auth-Token': token,
      'X-Project-Id': projectId,
    },
    body: JSON.stringify({ image: imageBase64 }),
  });
  
  // Return response
  res.status(response.status).json(responseData);
});
```

### 5. AI Chat Service Integration

**Location**: `lib/services/ai_chat_service.dart`

**Responsibilities**:
- Request second opinion from DeepSeek/Huawei AI
- Provide additional reasoning about diagnosis
- Fail gracefully if API key missing

**Method**:
```dart
static Future<String> reasonWithModelOutputs({
  required Uint8List imageBytes,
  required Map<String, double> probabilities,
}) async {
  // Format probabilities for AI
  final probsList = probabilities.entries
      .map((e) => '${e.key}: ${(e.value * 100).toStringAsFixed(1)}%')
      .join(', ');
  
  // Request second opinion
  final prompt = '''These are the model output probabilities:
$probsList

You are an ophthalmology AI assistant. Evaluate the model outputs and provide a brief second opinion:

(1) What is the most likely condition and why?
(2) One practical recommendation

End with: "It is very important to visit an ophthalmologist for accurate diagnosis."''';
  
  // Call Huawei AI or Gemini
  final response = await _huawei!.chat(messages: [...]);
  return response;
}
```

## Data Models

### Configuration Model

```dart
class HuaweiModelArtsConfig {
  final String projectId;           // 59dcb311da5e4ca6b8db8bbc7a7712d7
  final String accessKeyId;         // HPUALP3GCEZ2AMWETEHI
  final String secretAccessKey;     // ixFbU5NdPZ5Mvo7ZYXlFGdlAmZ9ZOQA6QtWDWYrM
  final String serviceId;           // c3ea302b-d98b-4f80-85bb-552e9ca8e0c9
  final String region;              // ap-southeast-3
  final String invokeUrl;           // https://infer-modelarts-{region}.modelarts-infer.com/v1/infers/<SERVICE_ID>
  
  bool get isComplete => /* all fields non-empty */;
}
```

### Inference Result Model

```dart
class InferenceResult {
  final String predictedClass;      // e.g., "Diabetic Retinopathy"
  final double confidence;           // 0.0 to 1.0
  final Map<String, double> probabilities;  // All class probabilities
  final bool uncertain;              // true if confidence < 0.6
}
```

### Diagnosis Result Model

```dart
class DiagnosisResult {
  final double confidence;
  final List<Condition> conditions;
  final List<String> recommendations;
}

class Condition {
  final String name;                 // Disease name
  final String severity;             // "Normal", "Low", "Medium", "High"
  final double confidence;           // 0.0 to 1.0
}
```

### ModelArts Response Formats

The system supports multiple response formats from ModelArts:

**Format 1: Direct prediction**
```json
{
  "prediction": "Diabetic Retinopathy",
  "confidence": 0.92,
  "probabilities": {
    "Normal": 0.02,
    "Diabetic Retinopathy": 0.92,
    "Glaucoma": 0.06
  }
}
```

**Format 2: Result object**
```json
{
  "result": {
    "class": "Diabetic Retinopathy",
    "confidence": 0.92,
    "probabilities": {...}
  }
}
```

**Format 3: Predictions array**
```json
{
  "predictions": [
    {
      "class": "Diabetic Retinopathy",
      "confidence": 0.92,
      "probabilities": {...}
    }
  ]
}
```

## Error Handling

### Error Categories and Responses

| Error Type | Detection | User Message | Technical Action |
|------------|-----------|--------------|------------------|
| **Missing Configuration** | Config fields empty | "ModelArts configuration is missing. Please check env.json file." | Throw exception with missing field list |
| **Image Too Large** | Size > 8MB | "Image size exceeds 8MB limit. Please compress or resize the image." | Reject before API call |
| **Network Error** | DioException with no response | "Network error. Please check your internet connection." | Log error, display user-friendly message |
| **Authentication Failed** | 401 response after retry | "Authentication failed. Please check ModelArts credentials." | Log IAM error details |
| **Invalid Service ID** | 404 response | "ModelArts service not found. Please verify service ID." | Log service ID and region |
| **Model Error** | 500 response | "Model inference failed. Please try again later." | Log full error response |
| **Parsing Error** | Unexpected response format | "Unable to parse model response. Please contact support." | Log response structure |
| **AI Second Opinion Failed** | Exception in reasonWithModelOutputs | (Silent failure) | Continue without second opinion, log error |

### Error Handling Flow

```
┌─────────────────┐
│ User Action     │
│ (Analyze Image) │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ Validate Image Size     │
│ < 8MB?                  │
└────┬────────────────┬───┘
     │ Yes            │ No
     │                ▼
     │         ┌──────────────┐
     │         │ Show Error   │
     │         │ "Too Large"  │
     │         └──────────────┘
     ▼
┌─────────────────────────┐
│ Check Configuration     │
│ Complete?               │
└────┬────────────────┬───┘
     │ Yes            │ No
     │                ▼
     │         ┌──────────────┐
     │         │ Show Error   │
     │         │ "Missing     │
     │         │  Config"     │
     │         └──────────────┘
     ▼
┌─────────────────────────┐
│ Call ModelArts API      │
└────┬────────────────────┘
     │
     ▼
┌─────────────────────────┐
│ Response Status?        │
└─┬───┬───┬───┬───┬───┬───┘
  │200│401│404│500│0  │
  │   │   │   │   │   │
  ▼   ▼   ▼   ▼   ▼   ▼
Success Auth Service Model Network
        Failed NotFound Error Error
```

### Logging Strategy

All components log at key decision points:

**DiagnosisProvider**:
- Log when switching between mock and real inference
- Log when requesting second opinion
- Log final diagnosis result structure

**RetinaInferenceService**:
- Log initialization status
- Log ModelArts response keys and structure
- Log parsing warnings for unexpected formats
- Log final parsed values (class, confidence)

**HuaweiModelArtsService**:
- Log invoke URL and payload keys
- Log response status and data type
- Log when using web proxy
- Log IAM token acquisition
- Log retry attempts with alternative formats

**Backend Proxy**:
- Log incoming requests with service ID and region
- Log IAM token cache hits/misses
- Log ModelArts response status
- Log errors with full details

## Testing Strategy

### Unit Testing

**DiagnosisProvider Tests**:
- Test severity mapping logic (Normal, Low, Medium, High)
- Test recommendation generation for different conditions
- Test error state management
- Test state transitions (idle → analyzing → complete)

**RetinaInferenceService Tests**:
- Test response parsing for all supported formats
- Test uncertain prediction handling (confidence < 0.6)
- Test error handling for malformed responses
- Test configuration validation

**HuaweiModelArtsService Tests**:
- Test token caching logic
- Test token expiry calculation
- Test payload format fallback
- Test 8MB size limit enforcement
- Mock HTTP calls to test error scenarios

### Integration Testing

**End-to-End Flow**:
1. Load configuration from env.json
2. Select retinal model
3. Upload test image
4. Verify ModelArts API call
5. Verify response parsing
6. Verify UI update with results

**Web Platform Proxy**:
1. Verify proxy receives correct payload
2. Verify IAM token acquisition
3. Verify ModelArts forwarding
4. Verify response relay to Flutter

**Error Scenarios**:
1. Missing configuration → Clear error message
2. Invalid credentials → Authentication error
3. Network timeout → Network error message
4. Invalid service ID → Service not found error
5. Malformed response → Parsing error with logs

### Manual Testing Checklist

- [ ] Test with various retinal images (normal, diseased)
- [ ] Test with images of different sizes (< 8MB, > 8MB)
- [ ] Test on web platform (verify proxy usage)
- [ ] Test on mobile platform (verify direct API call)
- [ ] Test with missing configuration (verify error message)
- [ ] Test with invalid credentials (verify auth error)
- [ ] Test network disconnection (verify error handling)
- [ ] Test second opinion integration (with and without API key)
- [ ] Verify logging output at each step
- [ ] Verify UI displays results correctly
- [ ] Verify recommendations are condition-specific
- [ ] Test in both English and Arabic locales

## Implementation Notes

### Configuration Management

The system loads configuration in this priority order:
1. Compile-time variables (--dart-define) - **Preferred for web**
2. env.json file - **Used for desktop/mobile**

**env.json structure**:
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

### Platform-Specific Behavior

**Web Platform**:
- Uses backend proxy at `http://localhost:3001/api/modelarts/infer`
- Sends credentials with each request
- Backend handles IAM token caching
- Avoids CORS restrictions

**Mobile/Desktop Platform**:
- Makes direct HTTPS calls to ModelArts
- Manages IAM token in Flutter app
- Reads configuration from env.json file

### Performance Considerations

**Token Caching**:
- Tokens cached for 24 hours with 5-minute buffer
- Reduces IAM API calls
- Improves response time for subsequent requests

**Image Size Limit**:
- 8MB hard limit enforced before API call
- Prevents unnecessary network usage
- Provides clear user feedback

**Payload Format Fallback**:
- Try format A first (simpler)
- Automatically retry with format B if A fails
- Minimizes configuration requirements

### Security Considerations

**Credential Handling**:
- Never log full credentials
- Use environment variables or secure files
- For production mobile apps, consider backend proxy to avoid exposing credentials

**Token Management**:
- Tokens expire after 24 hours
- Automatic refresh on expiry
- Clear token method available for testing

**Error Messages**:
- Don't expose internal system details
- Provide actionable user guidance
- Log technical details separately

## Migration Path

### Phase 1: Preparation (Current State)
- ✅ ModelArts service implemented
- ✅ Backend proxy implemented
- ✅ Configuration loading implemented
- ✅ Response parsing implemented
- ✅ Mock data in place

### Phase 2: Integration (This Spec)
- Remove mock data code
- Uncomment real inference code
- Test with real ModelArts endpoint
- Verify error handling
- Test second opinion integration

### Phase 3: Validation
- Monitor logs for parsing issues
- Collect user feedback
- Optimize response time
- Refine error messages

### Phase 4: Optimization
- Add response caching if needed
- Implement retry logic for transient failures
- Add analytics for model performance
- Consider A/B testing with mock vs real

## Dependencies

**Flutter Packages**:
- `dio`: ^5.0.0 - HTTP client
- `provider`: ^6.0.0 - State management
- `flutter/foundation.dart` - Platform detection (kIsWeb)

**Backend Dependencies**:
- `express`: ^4.18.0 - Web server
- `cors`: ^2.8.5 - CORS handling
- `node-fetch`: ^2.6.7 - HTTP client

**External Services**:
- Huawei Cloud IAM (authentication)
- Huawei Cloud ModelArts (inference)
- Huawei AI / DeepSeek (second opinion)

## Rollback Plan

If issues arise after deployment:

1. **Immediate Rollback**: Re-enable mock data code
2. **Investigate**: Review logs for error patterns
3. **Fix**: Address configuration or parsing issues
4. **Redeploy**: Test thoroughly before re-enabling

**Rollback Code**:
```dart
// In diagnosis_provider_web.dart
if (_selectedModel == 'retinal') {
  // Temporary: Use mock data until issues resolved
  await Future.delayed(const Duration(seconds: 2));
  _diagnosisResult = _generateMockResult();
}
```
