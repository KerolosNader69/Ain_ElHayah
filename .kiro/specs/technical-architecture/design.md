# EyeWise Connect - Technical Architecture Design

## Overview

EyeWise Connect is a cross-platform healthcare application built with Flutter that provides AI-powered eye diagnosis, doctor appointment booking, voice-enabled chatbot assistance, and health questionnaire analysis. The system integrates with Huawei Cloud services for AI inference, speech recognition, and API management.

### System Purpose

- Enable users to perform AI-powered retinal and selfie image analysis for eye health screening
- Connect patients with qualified ophthalmologists through appointment booking
- Provide intelligent voice-enabled chatbot for eye health queries
- Analyze health questionnaires using AI to identify potential eye conditions
- Support multiple platforms: iOS, Android, and Web

### Technology Stack

**Frontend:**
- Flutter 3.0+ (Dart 3.0+)
- Provider for state management
- GoRouter for navigation
- Dio for HTTP requests
- WebSocket for real-time communication

**Backend:**
- Node.js with Express.js
- WebSocket (ws library) for real-time connections
- node-fetch for HTTP proxying
- bcrypt for password hashing

**Cloud Services:**
- Huawei Cloud API Gateway (APIG)
- Huawei ModelArts (AI inference)
- Huawei Speech Interaction Service (SIS)
- Huawei Identity and Access Management (IAM)
- DeepSeek AI (questionnaire analysis)



## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   iOS App    │  │ Android App  │  │   Web App    │          │
│  │  (Flutter)   │  │  (Flutter)   │  │  (Flutter)   │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                   │
│         └──────────────────┴──────────────────┘                  │
│                            │                                      │
└────────────────────────────┼──────────────────────────────────────┘
                             │
                             │ HTTP/WebSocket
                             │
┌────────────────────────────┼──────────────────────────────────────┐
│                    Backend Proxy Layer                            │
│                   ┌────────┴────────┐                             │
│                   │  Node.js/Express │                            │
│                   │   Port 3001      │                            │
│                   └────────┬────────┘                             │
│                            │                                      │
│    ┌───────────────────────┼───────────────────────┐             │
│    │                       │                       │             │
│    ▼                       ▼                       ▼             │
│  REST API            WebSocket Manager      IAM Token Cache      │
│  Endpoints           (SIS Integration)      (24hr TTL)           │
└────────────────────────────┼──────────────────────────────────────┘
                             │
                             │ HTTPS/WSS
                             │
┌────────────────────────────┼──────────────────────────────────────┐
│                    Huawei Cloud Layer                             │
│                            │                                      │
│    ┌───────────────────────┼───────────────────────┐             │
│    │                       │                       │             │
│    ▼                       ▼                       ▼             │
│  ┌─────────┐         ┌─────────┐           ┌─────────┐          │
│  │  APIG   │         │ModelArts│           │   SIS   │          │
│  │ Gateway │         │   AI    │           │ Speech  │          │
│  └────┬────┘         └─────────┘           └─────────┘          │
│       │                                                           │
│       ▼                                                           │
│  ┌─────────┐         ┌─────────┐           ┌─────────┐          │
│  │   IAM   │         │   RDS   │           │   OBS   │          │
│  │  Auth   │         │Database │           │ Storage │          │
│  └─────────┘         └─────────┘           └─────────┘          │
└───────────────────────────────────────────────────────────────────┘
```

### Architecture Patterns

1. **Proxy Pattern**: Backend acts as a secure proxy to resolve CORS and protect credentials
2. **Provider Pattern**: Flutter state management using Provider package
3. **Repository Pattern**: Service layer abstracts data access
4. **Token Caching**: IAM tokens cached for 23 hours to reduce authentication overhead
5. **WebSocket Manager**: Dedicated manager for real-time SIS communication



## Components and Interfaces

### Frontend Components

#### 1. Presentation Layer (Screens)

**Core Screens:**
- `home_screen.dart` - Landing page with feature navigation
- `diagnosis_screen.dart` - AI-powered image analysis interface
- `doctors_screen.dart` - Doctor search and listing
- `chat_screen.dart` - AI chatbot interface
- `voice_chat_demo_screen.dart` - Voice interaction interface

**Appointment Booking Screens:**
- `appointment_booking_screen.dart` - Main booking flow
- `doctor_profile_screen.dart` - Doctor details
- `time_slot_selection_screen.dart` - Appointment scheduling
- `booking_form_screen.dart` - Patient information form
- `booking_review_screen.dart` - Booking confirmation review
- `booking_confirmation_screen.dart` - Final confirmation
- `my_appointments_screen.dart` - Appointment history
- `appointment_details_screen.dart` - Individual appointment view

#### 2. State Management Layer (Providers)

**AppProvider** (`lib/providers/app_provider.dart`)
- Global application state
- Theme management
- Loading states
- User session management

**ChatProvider** (`lib/providers/chat_provider.dart`)
- Chat message history
- Message sending/receiving
- Voice chat state
- Chatbot integration

**DiagnosisProvider** (`lib/providers/diagnosis_provider.dart` / `diagnosis_provider_web.dart`)
- Image upload and processing
- AI inference results
- Analysis history
- Platform-specific implementations

**AppointmentProvider** (`lib/providers/appointment_provider.dart`)
- Appointment booking flow
- Doctor selection
- Time slot management
- Booking history

#### 3. Service Layer

**ApiService** (`lib/services/api_service.dart`)
```dart
class ApiService {
  static String _baseUrl = 'http://localhost:3001/api';
  
  // Authentication
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required dynamic role,
  });
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });
}
```

**HuaweiModelArtsService** (`lib/services/huawei_modelarts_service.dart`)
```dart
class HuaweiModelArtsService {
  final HuaweiModelArtsConfig config;
  String? _cachedToken;
  DateTime? _tokenExpiry;
  
  // Main inference
  Future<Map<String, dynamic>> inferImage(Uint8List imageBytes);
  
  // IAM authentication
  Future<void> _ensureToken();
  
  // Token management
  void clearToken();
}
```

#### 4. Widget Layer

**Reusable Widgets:**
- `app_header.dart` - Navigation header
- `role_selector.dart` - User role selection
- `voice_chat_button.dart` - Voice interaction trigger
- `step_indicator.dart` - Multi-step process indicator
- `appointment_card.dart` - Appointment display card



### Backend Components

#### 1. Express Server (`backend/server.js`)

**Core Endpoints:**

```javascript
// Health check
GET /health
Response: { status: 'OK', message: 'Server is running', timestamp: ISO8601 }

// Authentication
POST /api/signup
Request: { username, email, password, user_type }
Response: { success: boolean, data: {...} | error: string }

POST /api/login
Request: { email, password }
Response: { success: boolean, data: {...} | error: string }

// AI Inference
POST /api/modelarts/infer
Request: { imageBase64, serviceId?, region?, projectId? }
Response: { success: boolean, result: {...} | error: string }

// Voice Chat
POST /api/voice-chat
Request: Binary audio data (audio/wav)
Response: { success: boolean, userText: string, botReply: string }

// Questionnaire Analysis
POST /api/questionnaire/analyze
Request: { answers: {...} }
Response: { 
  success: boolean, 
  conditions: [...], 
  recommendations: [...],
  red_flags: [...],
  ai_powered: boolean
}

// Retinal Analysis (Mock)
POST /api/retinal/analyze
Request: { imageBase64 }
Response: { 
  success: boolean, 
  confidence: number,
  conditions: [...],
  recommendations: [...]
}
```

#### 2. WebSocket Manager (`backend/sis_websocket_manager.js`)

**SisWebSocketManager Class:**
```javascript
class SisWebSocketManager {
  constructor(endpoint, projectId, iamToken);
  
  // Connection management
  connect(): Promise<WebSocket>;
  close(): void;
  
  // SIS protocol
  sendStart(property): Promise<void>;
  sendAudioChunk(audioBuffer): Promise<void>;
  sendAudioInChunks(audioBuffer, chunkSize): Promise<void>;
  sendEnd(): Promise<void>;
  
  // Result handling
  waitForResult(timeout): Promise<object>;
  
  // Complete flow
  transcribe(audioBuffer, property): Promise<string>;
}
```

**SIS Protocol Flow:**
1. Connect to WebSocket with IAM token
2. Send START command with audio format and property
3. Send audio data in chunks (max 10KB per chunk)
4. Send END command
5. Wait for transcription result
6. Close connection

#### 3. IAM Token Management

**Token Caching Strategy:**
```javascript
let tokenCache = null;
let tokenExpiresAt = 0;

async function getIAMToken(username, password, domain, projectId, region) {
  // Check cache (23-hour TTL)
  if (tokenCache && Date.now() < tokenExpiresAt) {
    return tokenCache;
  }
  
  // Obtain new token from IAM
  const iamUrl = `https://iam.${region}.myhuaweicloud.com/v3/auth/tokens`;
  const response = await fetch(iamUrl, {
    method: 'POST',
    body: JSON.stringify({
      auth: {
        identity: {
          methods: ['password'],
          password: {
            user: { name: username, password, domain: { name: domain } }
          }
        },
        scope: { project: { id: projectId } }
      }
    })
  });
  
  tokenCache = response.headers.get('x-subject-token');
  tokenExpiresAt = Date.now() + 23 * 3600 * 1000;
  return tokenCache;
}
```



## Data Models

### Frontend Data Models

#### Appointment Model (`lib/models/appointment.dart`)
```dart
class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String patientName;
  final String patientEmail;
  final String? notes;
  
  Appointment({...});
  
  factory Appointment.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### User Model
```dart
enum UserRole { patient, doctor }

class User {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String? token;
  
  User({...});
  
  factory User.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### Diagnosis Result Model
```dart
class DiagnosisResult {
  final String id;
  final DateTime timestamp;
  final String imageType; // 'retinal' or 'selfie'
  final double confidence;
  final List<Condition> conditions;
  final List<String> recommendations;
  final String? disclaimer;
  
  DiagnosisResult({...});
  
  factory DiagnosisResult.fromJson(Map<String, dynamic> json);
}

class Condition {
  final String name;
  final String severity;
  final double confidence;
  final String description;
  
  Condition({...});
}
```

#### Chat Message Model
```dart
enum MessageType { text, voice, system }
enum MessageSender { user, bot }

class ChatMessage {
  final String id;
  final MessageType type;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;
  final bool isProcessing;
  
  ChatMessage({...});
}
```

### Backend Data Structures

#### Questionnaire Answers
```javascript
{
  age: { years: number, months: number, days?: number },
  gender: 'male' | 'female' | 'other',
  recent_injury: 'yes' | 'no',
  smoking_10y: 'yes' | 'no',
  family_allergy: 'yes' | 'no',
  obesity: 'yes' | 'no',
  diabetes: 'yes' | 'no',
  hypertension: 'yes' | 'no',
  headache: {
    type: 'Eye strain' | 'Migraine' | 'Tension' | 'None',
    severity: 'Mild' | 'Moderate' | 'Severe'
  },
  other_symptoms: string,
  country: string,
  locale: 'en' | 'ar'
}
```

#### Analysis Response
```javascript
{
  success: boolean,
  conditions: [
    {
      name: string,
      probability: number, // 0-1
      rationale: string
    }
  ],
  recommendations: string[],
  red_flags: string[],
  disclaimer: string,
  ai_powered: boolean,
  model: 'DeepSeek AI' | 'Rule-based'
}
```



## Data Flow Diagrams

### 1. User Authentication Flow

```
┌─────────┐                ┌─────────┐                ┌─────────┐
│ Flutter │                │ Backend │                │  APIG   │
│   App   │                │  Proxy  │                │ Gateway │
└────┬────┘                └────┬────┘                └────┬────┘
     │                          │                          │
     │ POST /api/signup         │                          │
     │ {username, email,        │                          │
     │  password, user_type}    │                          │
     ├─────────────────────────>│                          │
     │                          │                          │
     │                          │ Hash password (bcrypt)   │
     │                          │                          │
     │                          │ POST /signup             │
     │                          │ {username, email,        │
     │                          │  hashed_password,        │
     │                          │  user_type}              │
     │                          ├─────────────────────────>│
     │                          │                          │
     │                          │                          │ Store in RDS
     │                          │                          │
     │                          │ 200 OK                   │
     │                          │ {success, data}          │
     │                          │<─────────────────────────┤
     │                          │                          │
     │ 200 OK                   │                          │
     │ {success, data}          │                          │
     │<─────────────────────────┤                          │
     │                          │                          │
     │ Store user in            │                          │
     │ SharedPreferences        │                          │
     │                          │                          │
```

### 2. Retinal Image Analysis Flow

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌──────────┐
│ Flutter │     │ Backend │     │   IAM   │     │ModelArts │
│   App   │     │  Proxy  │     │ Service │     │    AI    │
└────┬────┘     └────┬────┘     └────┬────┘     └────┬─────┘
     │               │               │               │
     │ Select image  │               │               │
     │ (max 8MB)     │               │               │
     │               │               │               │
     │ POST /api/    │               │               │
     │ modelarts/    │               │               │
     │ infer         │               │               │
     │ {imageBase64} │               │               │
     ├──────────────>│               │               │
     │               │               │               │
     │               │ Check token   │               │
     │               │ cache         │               │
     │               │               │               │
     │               │ If expired:   │               │
     │               │ POST /v3/auth/│               │
     │               │ tokens        │               │
     │               ├──────────────>│               │
     │               │               │               │
     │               │ X-Subject-    │               │
     │               │ Token         │               │
     │               │<──────────────┤               │
     │               │               │               │
     │               │ Cache token   │               │
     │               │ (23hr TTL)    │               │
     │               │               │               │
     │               │ POST /v1/     │               │
     │               │ infers/{id}   │               │
     │               │ {image}       │               │
     │               │ X-Auth-Token  │               │
     │               ├──────────────────────────────>│
     │               │               │               │
     │               │               │               │ AI Inference
     │               │               │               │
     │               │ 200 OK        │               │
     │               │ {result}      │               │
     │               │<──────────────────────────────┤
     │               │               │               │
     │ 200 OK        │               │               │
     │ {result}      │               │               │
     │<──────────────┤               │               │
     │               │               │               │
     │ Display       │               │               │
     │ diagnosis     │               │               │
     │               │               │               │
```



### 3. Voice Chat Interaction Flow

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ Flutter │     │ Backend │     │   IAM   │     │   SIS   │     │Chatbot  │
│   App   │     │  Proxy  │     │ Service │     │ Service │     │   AI    │
└────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘
     │               │               │               │               │
     │ Record audio  │               │               │               │
     │ (WAV format)  │               │               │               │
     │               │               │               │               │
     │ POST /api/    │               │               │               │
     │ voice-chat    │               │               │               │
     │ Binary audio  │               │               │               │
     ├──────────────>│               │               │               │
     │               │               │               │               │
     │               │ Get IAM token │               │               │
     │               ├──────────────>│               │               │
     │               │<──────────────┤               │               │
     │               │               │               │               │
     │               │ Connect WSS   │               │               │
     │               ├──────────────────────────────>│               │
     │               │               │               │               │
     │               │ Send START    │               │               │
     │               │ command       │               │               │
     │               ├──────────────────────────────>│               │
     │               │               │               │               │
     │               │ Send audio    │               │               │
     │               │ chunks (10KB) │               │               │
     │               ├──────────────────────────────>│               │
     │               │               │               │               │
     │               │ Send END      │               │               │
     │               ├──────────────────────────────>│               │
     │               │               │               │               │
     │               │               │               │ Transcribe    │
     │               │               │               │               │
     │               │ Result        │               │               │
     │               │ {text}        │               │               │
     │               │<──────────────────────────────┤               │
     │               │               │               │               │
     │               │ Close WSS     │               │               │
     │               │               │               │               │
     │               │ Send to       │               │               │
     │               │ chatbot       │               │               │
     │               ├──────────────────────────────────────────────>│
     │               │               │               │               │
     │               │               │               │               │ Generate
     │               │               │               │               │ response
     │               │               │               │               │
     │               │ Bot reply     │               │               │
     │               │<──────────────────────────────────────────────┤
     │               │               │               │               │
     │ 200 OK        │               │               │               │
     │ {userText,    │               │               │               │
     │  botReply}    │               │               │               │
     │<──────────────┤               │               │               │
     │               │               │               │               │
     │ Display       │               │               │               │
     │ conversation  │               │               │               │
     │               │               │               │               │
```

### 4. Questionnaire Analysis Flow

```
┌─────────┐          ┌─────────┐          ┌──────────┐
│ Flutter │          │ Backend │          │DeepSeek  │
│   App   │          │  Proxy  │          │    AI    │
└────┬────┘          └────┬────┘          └────┬─────┘
     │                    │                    │
     │ User completes     │                    │
     │ questionnaire      │                    │
     │                    │                    │
     │ POST /api/         │                    │
     │ questionnaire/     │                    │
     │ analyze            │                    │
     │ {answers}          │                    │
     ├───────────────────>│                    │
     │                    │                    │
     │                    │ Check if AI key    │
     │                    │ available          │
     │                    │                    │
     │                    │ If available:      │
     │                    │ POST /v1/chat/     │
     │                    │ completions        │
     │                    │ {model, messages}  │
     │                    ├───────────────────>│
     │                    │                    │
     │                    │                    │ Analyze
     │                    │                    │ symptoms
     │                    │                    │
     │                    │ 200 OK             │
     │                    │ {analysis JSON}    │
     │                    │<───────────────────┤
     │                    │                    │
     │                    │ Parse JSON         │
     │                    │                    │
     │                    │ If AI fails:       │
     │                    │ Use rule-based     │
     │                    │ analysis           │
     │                    │                    │
     │ 200 OK             │                    │
     │ {conditions,       │                    │
     │  recommendations,  │                    │
     │  red_flags}        │                    │
     │<───────────────────┤                    │
     │                    │                    │
     │ Display results    │                    │
     │                    │                    │
```



## Security Architecture

### 1. Credential Management

**Backend Credentials (env.json):**
```json
{
  "MODELARTS_PROJECT_ID": "project-id",
  "MODELARTS_USERNAME": "username",
  "MODELARTS_PASSWORD": "password",
  "MODELARTS_DOMAIN": "domain-name",
  "MODELARTS_REGION": "ap-southeast-3",
  "MODELARTS_SERVICE_ID": "service-id",
  "MODELARTS_INVOKE_URL": "https://...",
  "SIS_ENDPOINT": "sis-endpoint",
  "SIS_PROJECT_ID": "project-id",
  "SIS_PROPERTY": "english_16k_general",
  "HUAWEI_AI_API_KEY": "api-key",
  "HUAWEI_AI_BASE_URL": "https://...",
  "HUAWEI_AI_MODEL": "deepseek-v3.1"
}
```

**Security Practices:**
- Credentials stored only on backend server
- Never exposed to client-side code
- Environment-specific configuration
- Git-ignored configuration files
- Secure file permissions (600)

### 2. Authentication & Authorization

**IAM Token Flow:**
1. Backend authenticates with Huawei IAM using username/password
2. Receives X-Subject-Token header
3. Caches token for 23 hours
4. Includes token in all Huawei Cloud API requests
5. Automatically refreshes on expiry

**User Authentication:**
1. Passwords hashed with bcrypt (10 rounds)
2. JWT tokens for session management (future enhancement)
3. Secure password requirements enforced
4. Email validation on signup

### 3. CORS Configuration

**Backend CORS Policy:**
```javascript
app.use(cors({
  origin: '*', // Development: allow all
  // Production: restrict to specific domains
  // origin: ['https://eyewise.com', 'https://app.eyewise.com']
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));
```

**Web Platform:**
- Backend proxy resolves CORS issues
- Direct Huawei Cloud calls blocked by browser
- All requests routed through localhost:3001

### 4. Data Security

**In Transit:**
- HTTPS for all external API calls
- WSS (WebSocket Secure) for SIS connections
- TLS 1.2+ required

**At Rest:**
- Local storage encrypted (SharedPreferences)
- Sensitive data not persisted on client
- Images temporarily stored, cleared after analysis

**Data Validation:**
- Input sanitization on all endpoints
- File size limits (8MB for images)
- Content-type validation
- JSON schema validation

### 5. API Security

**Rate Limiting (Future Enhancement):**
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

**Request Validation:**
- Required field validation
- Email format validation
- Password strength requirements
- Image format and size validation



## Error Handling

### Frontend Error Handling

**Network Errors:**
```dart
try {
  final response = await http.post(uri, headers: headers, body: body)
    .timeout(Duration(seconds: 30));
} on http.ClientException catch (e) {
  if (e.message.contains('Connection refused')) {
    return {
      'success': false,
      'error': 'Backend server is not running. Please start the backend server.'
    };
  }
} on TimeoutException {
  return {
    'success': false,
    'error': 'Request timeout. Please check your internet connection.'
  };
} catch (e) {
  return {
    'success': false,
    'error': 'An unexpected error occurred: $e'
  };
}
```

**User-Friendly Error Messages:**
- Connection errors: "Backend server not running"
- Timeout errors: "Request timeout, check connection"
- Validation errors: Specific field-level messages
- API errors: Parsed from response body

### Backend Error Handling

**Structured Error Responses:**
```javascript
// Success response
{
  success: true,
  data: {...}
}

// Error response
{
  success: false,
  error: 'Human-readable error message',
  details: {
    stage: 'authentication' | 'transcription' | 'inference',
    code: 'ERROR_CODE',
    message: 'Technical details'
  }
}
```

**HTTP Status Codes:**
- 200: Success
- 400: Bad request (validation errors)
- 401: Unauthorized (authentication failed)
- 404: Not found
- 500: Internal server error
- 502: Bad gateway (upstream service error)
- 503: Service unavailable
- 504: Gateway timeout

**Error Logging:**
```javascript
console.error(`[${new Date().toISOString()}] Error in ${endpoint}:`, error.message);
console.error(`[${new Date().toISOString()}] Error stack:`, error.stack);
```

### Huawei Cloud Error Handling

**ModelArts Errors:**
- 401: IAM token expired → Refresh token and retry
- 400: Invalid request format → Return validation error
- 413: Image too large → Enforce 8MB limit
- 500: Inference failed → Return service error

**SIS Errors:**
- WebSocket connection timeout → Return timeout error
- Invalid audio format → Return format error
- Transcription failed → Return SIS error details
- Token expired → Refresh and reconnect



## Deployment Architecture

### Development Environment

**Local Development Setup:**
```
┌─────────────────────────────────────────┐
│         Developer Machine                │
│                                          │
│  ┌────────────────┐  ┌────────────────┐ │
│  │ Flutter App    │  │ Backend Server │ │
│  │ localhost:8080 │  │ localhost:3001 │ │
│  └────────────────┘  └────────────────┘ │
│                                          │
└─────────────────────────────────────────┘
           │                    │
           │                    │
           └────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │   Huawei Cloud        │
        │   (Development)       │
        └───────────────────────┘
```

**Development Commands:**
```bash
# Backend
cd backend
npm install
npm start  # Runs on port 3001

# Flutter Web
flutter run -d chrome

# Flutter Mobile
flutter run  # iOS/Android emulator
```

### Production Environment

**Deployment Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│                    CDN / Edge Network                    │
│              (Static Assets Distribution)                │
└────────────────────────┬────────────────────────────────┘
                         │
┌────────────────────────┼────────────────────────────────┐
│                  Load Balancer                           │
│              (SSL Termination, Routing)                  │
└────────────────────────┬────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
┌────────▼────────┐            ┌────────▼────────┐
│  Web Server 1   │            │  Web Server 2   │
│  (Flutter Web)  │            │  (Flutter Web)  │
│  Nginx/Apache   │            │  Nginx/Apache   │
└─────────────────┘            └─────────────────┘
         │                               │
         └───────────────┬───────────────┘
                         │
┌────────────────────────┼────────────────────────────────┐
│              Backend API Servers                         │
│                                                          │
│  ┌────────────────┐  ┌────────────────┐                │
│  │  Node.js API 1 │  │  Node.js API 2 │                │
│  │  Port 3001     │  │  Port 3001     │                │
│  └────────────────┘  └────────────────┘                │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────┐
        │      Huawei Cloud Services     │
        │  - APIG                        │
        │  - ModelArts                   │
        │  - SIS                         │
        │  - IAM                         │
        │  - RDS (Database)              │
        │  - OBS (Object Storage)        │
        └────────────────────────────────┘
```

### Infrastructure Requirements

**Backend Server:**
- OS: Linux (Ubuntu 20.04+ or CentOS 7+)
- CPU: 2+ cores
- RAM: 4GB minimum, 8GB recommended
- Storage: 20GB SSD
- Node.js: v14+ (v18 recommended)
- Network: Public IP with HTTPS support

**Flutter Web Hosting:**
- Static file hosting (Nginx, Apache, or CDN)
- HTTPS required
- Gzip compression enabled
- Cache headers configured

**Mobile App Distribution:**
- iOS: Apple App Store
- Android: Google Play Store
- Build artifacts: .ipa (iOS), .apk/.aab (Android)

### Environment Configuration

**Backend Environment Variables:**
```bash
# Server
PORT=3001
NODE_ENV=production

# Huawei Cloud
MODELARTS_PROJECT_ID=xxx
MODELARTS_USERNAME=xxx
MODELARTS_PASSWORD=xxx
MODELARTS_DOMAIN=xxx
MODELARTS_REGION=ap-southeast-3
MODELARTS_SERVICE_ID=xxx
MODELARTS_INVOKE_URL=https://...
SIS_ENDPOINT=xxx
SIS_PROJECT_ID=xxx
SIS_PROPERTY=english_16k_general

# AI Services
HUAWEI_AI_API_KEY=xxx
HUAWEI_AI_BASE_URL=https://...
HUAWEI_AI_MODEL=deepseek-v3.1

# Security
CORS_ORIGIN=https://app.eyewise.com
JWT_SECRET=xxx
```

**Flutter Build Configuration:**
```bash
# Web
flutter build web --release --dart-define=API_BASE_URL=https://api.eyewise.com

# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```



## Database and Storage

### Local Storage (Client-Side)

**SharedPreferences (Flutter):**
```dart
// User session
await prefs.setString('user_id', userId);
await prefs.setString('user_email', email);
await prefs.setString('user_token', token);
await prefs.setString('user_role', role);

// App preferences
await prefs.setBool('dark_mode', isDarkMode);
await prefs.setString('language', languageCode);

// Cache
await prefs.setString('last_diagnosis', jsonEncode(diagnosis));
```

**Storage Patterns:**
- User session: Persistent until logout
- App preferences: Persistent
- Diagnosis history: Cached (last 10 results)
- Images: Temporary (cleared after analysis)

### Cloud Storage

**Huawei Object Storage Service (OBS):**
- Medical images (retinal scans, selfies)
- Diagnosis reports (PDF)
- User profile images
- Backup data

**Storage Structure:**
```
eyewise-bucket/
├── users/
│   ├── {user_id}/
│   │   ├── profile/
│   │   │   └── avatar.jpg
│   │   ├── diagnoses/
│   │   │   ├── {diagnosis_id}/
│   │   │   │   ├── image.jpg
│   │   │   │   └── report.pdf
```

### Database (Huawei RDS)

**Schema Design:**

**Users Table:**
```sql
CREATE TABLE users (
  id VARCHAR(36) PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  user_type ENUM('patient', 'doctor') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  INDEX idx_email (email),
  INDEX idx_username (username)
);
```

**Doctors Table:**
```sql
CREATE TABLE doctors (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  specialty VARCHAR(100),
  license_number VARCHAR(50),
  years_experience INT,
  rating DECIMAL(3,2),
  bio TEXT,
  location VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_specialty (specialty),
  INDEX idx_location (location)
);
```

**Appointments Table:**
```sql
CREATE TABLE appointments (
  id VARCHAR(36) PRIMARY KEY,
  patient_id VARCHAR(36) NOT NULL,
  doctor_id VARCHAR(36) NOT NULL,
  appointment_date DATETIME NOT NULL,
  status ENUM('pending', 'confirmed', 'completed', 'cancelled') DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
  INDEX idx_patient (patient_id),
  INDEX idx_doctor (doctor_id),
  INDEX idx_date (appointment_date),
  INDEX idx_status (status)
);
```

**Diagnoses Table:**
```sql
CREATE TABLE diagnoses (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  image_type ENUM('retinal', 'selfie') NOT NULL,
  image_url VARCHAR(500),
  confidence DECIMAL(5,4),
  result JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_created (created_at)
);
```

**Chat History Table:**
```sql
CREATE TABLE chat_messages (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  message_type ENUM('text', 'voice') NOT NULL,
  sender ENUM('user', 'bot') NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_created (created_at)
);
```

### Data Retention Policy

**User Data:**
- Active accounts: Retained indefinitely
- Inactive accounts (2+ years): Archived
- Deleted accounts: 30-day soft delete, then permanent deletion

**Medical Data:**
- Diagnosis results: Retained for 7 years (regulatory compliance)
- Medical images: Retained for 7 years
- Chat history: Retained for 1 year

**Logs:**
- Application logs: 90 days
- Access logs: 180 days
- Error logs: 1 year



## Integration Patterns

### 1. Proxy Pattern (CORS Resolution)

**Problem:** Browser CORS restrictions prevent direct Huawei Cloud API calls from web apps

**Solution:** Backend proxy server forwards requests with proper headers

**Implementation:**
```javascript
// Backend proxy endpoint
app.post('/api/modelarts/infer', async (req, res) => {
  const { imageBase64, serviceId, region, projectId } = req.body;
  
  // Get IAM token
  const token = await getIAMToken(...);
  
  // Forward to ModelArts
  const response = await fetch(modelArtsUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Auth-Token': token,
      'X-Project-Id': projectId
    },
    body: JSON.stringify({ image: imageBase64 })
  });
  
  // Return response to client
  res.status(response.status).json(await response.json());
});
```

**Benefits:**
- Resolves CORS issues
- Keeps credentials secure on server
- Centralizes authentication logic
- Enables request/response logging

### 2. WebSocket Manager Pattern

**Problem:** Complex WebSocket protocol for SIS requires careful state management

**Solution:** Dedicated manager class encapsulates WebSocket lifecycle

**Implementation:**
```javascript
class SisWebSocketManager {
  async transcribe(audioBuffer, property) {
    try {
      await this.connect();
      await this.sendStart(property);
      await this.sendAudioInChunks(audioBuffer);
      await this.sendEnd();
      const result = await this.waitForResult();
      this.close();
      return result.text;
    } catch (error) {
      this.close();
      throw error;
    }
  }
}
```

**Benefits:**
- Encapsulates complex protocol
- Automatic connection cleanup
- Consistent error handling
- Reusable across endpoints

### 3. Token Caching Pattern

**Problem:** IAM token requests are expensive and have rate limits

**Solution:** Cache tokens with TTL and automatic refresh

**Implementation:**
```javascript
let tokenCache = null;
let tokenExpiresAt = 0;

async function getIAMToken(...) {
  const now = Date.now();
  
  // Return cached token if valid
  if (tokenCache && now < tokenExpiresAt) {
    return tokenCache;
  }
  
  // Obtain new token
  const response = await fetch(iamUrl, {...});
  tokenCache = response.headers.get('x-subject-token');
  tokenExpiresAt = now + 23 * 3600 * 1000; // 23 hours
  
  return tokenCache;
}
```

**Benefits:**
- Reduces authentication overhead
- Improves response times
- Respects rate limits
- Automatic refresh on expiry

### 4. Service Layer Abstraction

**Problem:** Direct API calls in UI code create tight coupling

**Solution:** Service layer abstracts API details

**Implementation:**
```dart
// Service layer
class ApiService {
  static Future<Map<String, dynamic>> signup({...}) async {
    final uri = Uri.parse('$_baseUrl/signup');
    final response = await http.post(uri, ...);
    return _parseResponse(response);
  }
}

// UI layer
final result = await ApiService.signup(
  username: username,
  email: email,
  password: password,
  role: role
);

if (result['success']) {
  // Handle success
} else {
  // Handle error
}
```

**Benefits:**
- Separation of concerns
- Testable business logic
- Consistent error handling
- Easy to mock for testing

### 5. Provider Pattern (State Management)

**Problem:** Complex state needs to be shared across widgets

**Solution:** Provider pattern for reactive state management

**Implementation:**
```dart
// Provider
class DiagnosisProvider extends ChangeNotifier {
  DiagnosisResult? _result;
  bool _isLoading = false;
  
  Future<void> analyzImage(Uint8List imageBytes) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _service.inferImage(imageBytes);
      _result = DiagnosisResult.fromJson(result);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// UI
Consumer<DiagnosisProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return LoadingWidget();
    if (provider.result != null) return ResultWidget(provider.result);
    return UploadWidget();
  }
)
```

**Benefits:**
- Reactive UI updates
- Centralized state management
- Testable business logic
- Reduced boilerplate



## Testing Strategy

### Frontend Testing

**Unit Tests:**
```dart
// Service tests
test('ApiService.signup returns success on valid credentials', () async {
  final result = await ApiService.signup(
    username: 'testuser',
    email: 'test@example.com',
    password: 'password123',
    role: UserRole.patient
  );
  
  expect(result['success'], true);
  expect(result['data'], isNotNull);
});

// Provider tests
test('DiagnosisProvider updates state on image analysis', () async {
  final provider = DiagnosisProvider();
  final imageBytes = Uint8List.fromList([...]);
  
  await provider.analyzeImage(imageBytes);
  
  expect(provider.isLoading, false);
  expect(provider.result, isNotNull);
});
```

**Widget Tests:**
```dart
testWidgets('Login screen shows error on invalid credentials', (tester) async {
  await tester.pumpWidget(MyApp());
  
  await tester.enterText(find.byKey(Key('email')), 'invalid@email.com');
  await tester.enterText(find.byKey(Key('password')), 'wrong');
  await tester.tap(find.byKey(Key('login_button')));
  await tester.pumpAndSettle();
  
  expect(find.text('Invalid credentials'), findsOneWidget);
});
```

**Integration Tests:**
```dart
testWidgets('Complete diagnosis flow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navigate to diagnosis screen
  await tester.tap(find.text('AI Diagnosis'));
  await tester.pumpAndSettle();
  
  // Upload image
  await tester.tap(find.byKey(Key('upload_button')));
  await tester.pumpAndSettle();
  
  // Verify result displayed
  expect(find.byType(DiagnosisResultWidget), findsOneWidget);
});
```

### Backend Testing

**Unit Tests:**
```javascript
describe('IAM Token Management', () => {
  it('should cache token for 23 hours', async () => {
    const token1 = await getIAMToken(...);
    const token2 = await getIAMToken(...);
    
    expect(token1).toBe(token2);
  });
  
  it('should refresh expired token', async () => {
    const token1 = await getIAMToken(...);
    
    // Simulate expiry
    tokenExpiresAt = 0;
    
    const token2 = await getIAMToken(...);
    expect(token2).not.toBe(token1);
  });
});
```

**Integration Tests:**
```javascript
describe('POST /api/modelarts/infer', () => {
  it('should return diagnosis result', async () => {
    const response = await request(app)
      .post('/api/modelarts/infer')
      .send({ imageBase64: validBase64Image })
      .expect(200);
    
    expect(response.body.success).toBe(true);
    expect(response.body.result).toBeDefined();
  });
  
  it('should return 400 for missing image', async () => {
    const response = await request(app)
      .post('/api/modelarts/infer')
      .send({})
      .expect(400);
    
    expect(response.body.success).toBe(false);
    expect(response.body.error).toBeDefined();
  });
});
```

**End-to-End Tests:**
```javascript
describe('Voice Chat Flow', () => {
  it('should transcribe audio and return bot reply', async () => {
    const audioBuffer = fs.readFileSync('test/fixtures/audio.wav');
    
    const response = await request(app)
      .post('/api/voice-chat')
      .set('Content-Type', 'audio/wav')
      .send(audioBuffer)
      .expect(200);
    
    expect(response.body.success).toBe(true);
    expect(response.body.userText).toBeDefined();
    expect(response.body.botReply).toBeDefined();
  });
});
```

### Test Coverage Goals

**Frontend:**
- Unit tests: 80%+ coverage
- Widget tests: Key user flows
- Integration tests: Critical paths

**Backend:**
- Unit tests: 85%+ coverage
- Integration tests: All API endpoints
- E2E tests: Complete user journeys

### Testing Tools

**Frontend:**
- flutter_test (built-in)
- mockito (mocking)
- integration_test (E2E)

**Backend:**
- Jest (test framework)
- Supertest (HTTP testing)
- Sinon (mocking)
- Istanbul (coverage)



## Monitoring and Logging

### Application Logging

**Backend Logging:**
```javascript
// Request logging
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.path}`);
  next();
});

// Error logging
app.use((err, req, res, next) => {
  const timestamp = new Date().toISOString();
  console.error(`[${timestamp}] Error:`, err.message);
  console.error(`[${timestamp}] Stack:`, err.stack);
  res.status(500).json({ success: false, error: 'Internal server error' });
});

// Structured logging
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

**Frontend Logging:**
```dart
// Debug logging
debugPrint('[ApiService] Calling endpoint: $endpoint');

// Error logging
try {
  // API call
} catch (e, stackTrace) {
  debugPrint('[ApiService] Error: $e');
  debugPrint('[ApiService] Stack trace: $stackTrace');
  
  // Send to error tracking service
  FirebaseCrashlytics.instance.recordError(e, stackTrace);
}
```

### Performance Monitoring

**Metrics to Track:**
- API response times
- Image processing duration
- WebSocket connection latency
- Database query performance
- Memory usage
- CPU utilization

**Implementation:**
```javascript
// Response time middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${req.method} ${req.path}] ${duration}ms`);
    
    // Send to monitoring service
    metrics.recordResponseTime(req.path, duration);
  });
  
  next();
});
```

### Health Checks

**Backend Health Endpoint:**
```javascript
app.get('/health', async (req, res) => {
  const health = {
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    services: {
      database: await checkDatabase(),
      huaweiCloud: await checkHuaweiCloud(),
      sis: await checkSIS()
    }
  };
  
  const allHealthy = Object.values(health.services).every(s => s.status === 'OK');
  res.status(allHealthy ? 200 : 503).json(health);
});
```

**Monitoring Tools:**
- Huawei Cloud Application Performance Management (APM)
- Prometheus + Grafana
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Sentry (error tracking)

### Alerting

**Alert Conditions:**
- API error rate > 5%
- Response time > 5 seconds
- Memory usage > 80%
- Disk usage > 90%
- Service downtime
- Failed authentication attempts > 10/minute

**Alert Channels:**
- Email notifications
- SMS for critical alerts
- Slack/Teams integration
- PagerDuty for on-call



## Performance Optimization

### Frontend Optimization

**Image Optimization:**
```dart
// Compress images before upload
Future<Uint8List> compressImage(Uint8List imageBytes) async {
  final image = img.decodeImage(imageBytes);
  
  // Resize if too large
  if (image.width > 2048 || image.height > 2048) {
    final resized = img.copyResize(image, width: 2048);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }
  
  return imageBytes;
}

// Enforce 8MB limit
if (imageBytes.length > 8 * 1024 * 1024) {
  throw Exception('Image exceeds 8MB limit');
}
```

**Lazy Loading:**
```dart
// Lazy load images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => ShimmerWidget(),
  errorWidget: (context, url, error) => ErrorWidget(),
);

// Lazy load lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);
```

**Code Splitting:**
```dart
// Lazy load routes
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/diagnosis',
      builder: (context, state) => const DiagnosisScreen(),
    ),
    // Other routes loaded on demand
  ],
);
```

### Backend Optimization

**Connection Pooling:**
```javascript
// Database connection pool
const pool = mysql.createPool({
  host: 'localhost',
  user: 'user',
  password: 'password',
  database: 'eyewise',
  connectionLimit: 10,
  queueLimit: 0
});
```

**Response Compression:**
```javascript
const compression = require('compression');

app.use(compression({
  level: 6,
  threshold: 1024, // Only compress responses > 1KB
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));
```

**Caching:**
```javascript
// In-memory cache for frequently accessed data
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 600 }); // 10 minutes

app.get('/api/doctors', async (req, res) => {
  const cacheKey = 'doctors_list';
  
  // Check cache
  const cached = cache.get(cacheKey);
  if (cached) {
    return res.json(cached);
  }
  
  // Fetch from database
  const doctors = await db.query('SELECT * FROM doctors');
  
  // Store in cache
  cache.set(cacheKey, doctors);
  
  res.json(doctors);
});
```

### Database Optimization

**Indexing Strategy:**
```sql
-- Frequently queried columns
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_diagnoses_user_created ON diagnoses(user_id, created_at);

-- Composite indexes for common queries
CREATE INDEX idx_appointments_doctor_date ON appointments(doctor_id, appointment_date);
CREATE INDEX idx_appointments_patient_status ON appointments(patient_id, status);
```

**Query Optimization:**
```sql
-- Use EXPLAIN to analyze queries
EXPLAIN SELECT * FROM appointments 
WHERE doctor_id = '123' 
AND appointment_date >= '2024-01-01'
ORDER BY appointment_date;

-- Avoid SELECT *, specify needed columns
SELECT id, patient_id, appointment_date, status 
FROM appointments 
WHERE doctor_id = '123';

-- Use LIMIT for pagination
SELECT * FROM diagnoses 
WHERE user_id = '123' 
ORDER BY created_at DESC 
LIMIT 10 OFFSET 0;
```

### Network Optimization

**HTTP/2:**
- Enable HTTP/2 on web server
- Multiplexing reduces latency
- Server push for critical resources

**CDN Configuration:**
```nginx
# Cache static assets
location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)$ {
  expires 1y;
  add_header Cache-Control "public, immutable";
}

# Gzip compression
gzip on;
gzip_types text/plain text/css application/json application/javascript;
gzip_min_length 1000;
```

**Request Batching:**
```dart
// Batch multiple API calls
Future<Map<String, dynamic>> batchRequest(List<String> endpoints) async {
  final futures = endpoints.map((e) => http.get(Uri.parse(e)));
  final responses = await Future.wait(futures);
  
  return {
    for (var i = 0; i < endpoints.length; i++)
      endpoints[i]: jsonDecode(responses[i].body)
  };
}
```



## Scalability Considerations

### Horizontal Scaling

**Backend API Servers:**
```
┌─────────────────┐
│  Load Balancer  │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│API #1 │ │API #2 │
└───────┘ └───────┘
```

**Stateless Design:**
- No session state stored in memory
- Use JWT tokens for authentication
- Store session data in Redis/database
- Enable any server to handle any request

**Load Balancing Strategy:**
```nginx
upstream backend {
  least_conn;  # Route to server with fewest connections
  server api1.eyewise.com:3001;
  server api2.eyewise.com:3001;
  server api3.eyewise.com:3001;
}

server {
  listen 443 ssl;
  server_name api.eyewise.com;
  
  location / {
    proxy_pass http://backend;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

### Vertical Scaling

**Resource Allocation:**
- Start: 2 CPU cores, 4GB RAM
- Growth: 4 CPU cores, 8GB RAM
- Peak: 8 CPU cores, 16GB RAM

**Auto-scaling Rules:**
```yaml
# Kubernetes HPA example
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: eyewise-backend
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: eyewise-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Database Scaling

**Read Replicas:**
```
┌─────────────┐
│   Primary   │ (Write)
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
┌──▼──┐ ┌─▼───┐
│Rep#1│ │Rep#2│ (Read)
└─────┘ └─────┘
```

**Sharding Strategy:**
```javascript
// User-based sharding
function getUserShard(userId) {
  const shardCount = 4;
  const hash = crypto.createHash('md5').update(userId).digest('hex');
  return parseInt(hash.substring(0, 8), 16) % shardCount;
}

// Route query to appropriate shard
const shard = getUserShard(userId);
const db = dbConnections[shard];
const user = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
```

### Caching Strategy

**Multi-Layer Caching:**
```
┌──────────────┐
│   Browser    │ (Client cache)
└──────┬───────┘
       │
┌──────▼───────┐
│     CDN      │ (Edge cache)
└──────┬───────┘
       │
┌──────▼───────┐
│    Redis     │ (Application cache)
└──────┬───────┘
       │
┌──────▼───────┐
│   Database   │ (Source of truth)
└──────────────┘
```

**Cache Invalidation:**
```javascript
// Time-based expiration
cache.set('doctors_list', data, 600); // 10 minutes

// Event-based invalidation
async function updateDoctor(doctorId, updates) {
  await db.query('UPDATE doctors SET ? WHERE id = ?', [updates, doctorId]);
  
  // Invalidate related caches
  cache.del('doctors_list');
  cache.del(`doctor_${doctorId}`);
}
```

### Message Queue (Future Enhancement)

**Async Processing:**
```javascript
// Producer
const queue = require('bull');
const diagnosisQueue = new queue('diagnosis', redisConfig);

app.post('/api/diagnosis', async (req, res) => {
  const job = await diagnosisQueue.add({
    userId: req.user.id,
    imageUrl: req.body.imageUrl
  });
  
  res.json({ jobId: job.id, status: 'processing' });
});

// Consumer
diagnosisQueue.process(async (job) => {
  const { userId, imageUrl } = job.data;
  
  // Download image
  const imageBytes = await downloadImage(imageUrl);
  
  // Run inference
  const result = await modelArtsService.inferImage(imageBytes);
  
  // Store result
  await db.query('INSERT INTO diagnoses SET ?', {
    user_id: userId,
    result: JSON.stringify(result)
  });
  
  // Notify user
  await notificationService.send(userId, 'Diagnosis complete');
});
```



## API Documentation

### Authentication Endpoints

#### POST /api/signup

Register a new user account.

**Request:**
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "user_type": "patient"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid-here",
    "username": "johndoe",
    "email": "john@example.com",
    "user_type": "patient",
    "token": "jwt-token-here"
  }
}
```

**Response (Error - 400):**
```json
{
  "success": false,
  "error": "Email already exists"
}
```

#### POST /api/login

Authenticate user and obtain session token.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "data": {
    "user_id": "uuid-here",
    "username": "johndoe",
    "email": "john@example.com",
    "user_type": "patient",
    "token": "jwt-token-here"
  }
}
```

**Response (Error - 401):**
```json
{
  "success": false,
  "error": "Invalid credentials"
}
```

### AI Inference Endpoints

#### POST /api/modelarts/infer

Analyze retinal or selfie image using AI.

**Request:**
```json
{
  "imageBase64": "base64-encoded-image-data",
  "serviceId": "optional-service-id",
  "region": "optional-region",
  "projectId": "optional-project-id"
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "result": {
    "confidence": 0.87,
    "conditions": [
      {
        "name": "Diabetic Retinopathy",
        "severity": "Mild",
        "confidence": 0.72
      }
    ],
    "recommendations": [
      "Schedule follow-up in 6 months",
      "Maintain blood sugar control"
    ]
  }
}
```

**Response (Error - 400):**
```json
{
  "success": false,
  "error": "Image exceeds 8MB limit"
}
```

#### POST /api/questionnaire/analyze

Analyze health questionnaire using AI.

**Request:**
```json
{
  "answers": {
    "age": { "years": 45, "months": 6 },
    "gender": "male",
    "diabetes": "yes",
    "hypertension": "no",
    "other_symptoms": "Blurred vision",
    "locale": "en"
  }
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "conditions": [
    {
      "name": "Diabetic Retinopathy Risk",
      "probability": 0.65,
      "rationale": "Patient has diabetes, increasing retinal damage risk"
    }
  ],
  "recommendations": [
    "Schedule comprehensive eye examination",
    "Regular eye screenings crucial for diabetes management"
  ],
  "red_flags": [
    "⚠️ Sudden vision changes require urgent evaluation"
  ],
  "disclaimer": "This is an AI-assisted preliminary assessment...",
  "ai_powered": true,
  "model": "DeepSeek AI"
}
```

### Voice Chat Endpoints

#### POST /api/voice-chat

Transcribe audio and get chatbot response.

**Request:**
- Content-Type: `audio/wav`
- Body: Binary audio data (WAV format, 16kHz, 16-bit PCM)

**Response (Success - 200):**
```json
{
  "success": true,
  "userText": "What are the symptoms of glaucoma?",
  "botReply": "Glaucoma symptoms include gradual loss of peripheral vision..."
}
```

**Response (Error - 400):**
```json
{
  "success": false,
  "error": "No audio data provided"
}
```

**Response (Error - 504):**
```json
{
  "success": false,
  "error": "Transcription timeout",
  "details": {
    "message": "SIS service did not respond in time",
    "stage": "transcription"
  }
}
```

### Health Check Endpoint

#### GET /health

Check server health and service status.

**Response (Success - 200):**
```json
{
  "status": "OK",
  "message": "Server is running",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "uptime": 86400,
  "memory": {
    "rss": 52428800,
    "heapTotal": 20971520,
    "heapUsed": 15728640
  },
  "services": {
    "database": { "status": "OK", "latency": 5 },
    "huaweiCloud": { "status": "OK", "latency": 120 },
    "sis": { "status": "OK", "latency": 80 }
  }
}
```

**Response (Service Degraded - 503):**
```json
{
  "status": "DEGRADED",
  "message": "Some services unavailable",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "services": {
    "database": { "status": "OK" },
    "huaweiCloud": { "status": "ERROR", "error": "Connection timeout" },
    "sis": { "status": "OK" }
  }
}
```

### Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Authentication failed |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 413 | Payload Too Large - File exceeds limit |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |
| 502 | Bad Gateway - Upstream service error |
| 503 | Service Unavailable |
| 504 | Gateway Timeout |



## Technology Decisions and Rationale

### Why Flutter?

**Cross-Platform Development:**
- Single codebase for iOS, Android, and Web
- Reduces development time by 60%
- Consistent UI/UX across platforms
- Hot reload for rapid development

**Performance:**
- Compiled to native code (ARM/x64)
- 60fps smooth animations
- Small app size with tree shaking
- Fast startup time

**Ecosystem:**
- Rich widget library
- Strong community support
- Extensive package ecosystem
- Google backing and long-term support

### Why Node.js for Backend?

**JavaScript Ecosystem:**
- Same language as frontend (if using web)
- Large npm package ecosystem
- Easy to find developers
- Excellent async I/O performance

**Event-Driven Architecture:**
- Perfect for I/O-heavy operations
- Non-blocking WebSocket support
- Efficient handling of concurrent requests
- Low memory footprint

**Rapid Development:**
- Quick prototyping
- Minimal boilerplate
- Easy deployment
- Good debugging tools

### Why Huawei Cloud?

**AI Services:**
- ModelArts for custom AI models
- Pre-trained models available
- GPU acceleration
- Competitive pricing

**Speech Services:**
- SIS for speech-to-text
- Multiple language support
- Real-time transcription
- High accuracy

**Regional Presence:**
- Data centers in target regions
- Low latency for users
- Compliance with local regulations
- 24/7 support

### Why Provider for State Management?

**Simplicity:**
- Easy to learn and implement
- Minimal boilerplate
- Built-in to Flutter
- Good documentation

**Performance:**
- Efficient rebuilds
- Granular control over updates
- No unnecessary re-renders
- Small bundle size

**Flexibility:**
- Works with any architecture
- Easy to test
- Supports dependency injection
- Scales well

### Why GoRouter for Navigation?

**Declarative Routing:**
- Type-safe navigation
- Deep linking support
- URL-based routing for web
- Easy to maintain

**Features:**
- Nested navigation
- Redirect support
- Route guards
- Query parameters

**Web Support:**
- Browser back/forward buttons
- Shareable URLs
- SEO-friendly
- Progressive web app ready



## Future Enhancements

### Phase 2 Features

**Real-time Notifications:**
- Push notifications for appointment reminders
- Diagnosis result notifications
- Chat message notifications
- Firebase Cloud Messaging integration

**Offline Support:**
- Local database (SQLite/Hive)
- Sync when online
- Cached diagnosis history
- Offline-first architecture

**Advanced Analytics:**
- User behavior tracking
- Feature usage analytics
- Performance metrics
- A/B testing framework

**Multi-language Support:**
- Internationalization (i18n)
- Arabic, English, French, Spanish
- RTL layout support
- Localized content

### Phase 3 Features

**Video Consultations:**
- WebRTC integration
- Real-time video calls with doctors
- Screen sharing for image review
- Recording and playback

**Wearable Integration:**
- Apple Watch support
- Health data sync
- Activity tracking
- Medication reminders

**AI Improvements:**
- Federated learning
- Continuous model improvement
- Multi-modal analysis (image + questionnaire)
- Explainable AI results

**Telemedicine Platform:**
- Prescription management
- Electronic health records (EHR)
- Insurance integration
- Payment processing

### Technical Debt to Address

**Security Enhancements:**
- Implement JWT authentication
- Add rate limiting
- Enable HTTPS everywhere
- Implement RBAC (Role-Based Access Control)

**Performance Improvements:**
- Implement Redis caching
- Add CDN for static assets
- Optimize database queries
- Implement lazy loading

**Code Quality:**
- Increase test coverage to 90%+
- Add end-to-end tests
- Implement CI/CD pipeline
- Add code quality gates

**Documentation:**
- API documentation (OpenAPI/Swagger)
- Architecture decision records (ADRs)
- Deployment runbooks
- Troubleshooting guides

### Migration Considerations

**Database Migration:**
- Plan for schema changes
- Zero-downtime migrations
- Rollback procedures
- Data validation

**API Versioning:**
```javascript
// Version 1
app.use('/api/v1', v1Routes);

// Version 2 (with breaking changes)
app.use('/api/v2', v2Routes);

// Deprecation notice
app.use('/api/v1', (req, res, next) => {
  res.setHeader('X-API-Deprecation', 'v1 will be deprecated on 2025-12-31');
  next();
});
```

**Backward Compatibility:**
- Support old mobile app versions
- Graceful degradation
- Feature flags for gradual rollout
- A/B testing infrastructure



## Conclusion

This technical architecture document provides a comprehensive overview of the EyeWise Connect application, covering all major aspects from high-level system design to detailed implementation patterns.

### Key Architectural Principles

1. **Separation of Concerns**: Clear boundaries between frontend, backend, and cloud services
2. **Security First**: Credentials protected, authentication enforced, data encrypted
3. **Scalability**: Stateless design, horizontal scaling, caching strategies
4. **Maintainability**: Clean code, comprehensive testing, detailed documentation
5. **Performance**: Optimized queries, efficient caching, lazy loading
6. **User Experience**: Fast response times, offline support, intuitive UI

### System Strengths

- **Cross-platform**: Single codebase for iOS, Android, and Web
- **AI-powered**: Advanced image analysis and questionnaire evaluation
- **Real-time**: Voice chat with instant transcription
- **Secure**: Backend proxy protects credentials and resolves CORS
- **Scalable**: Designed for growth with horizontal scaling support
- **Maintainable**: Well-structured code with clear patterns

### Next Steps

1. Review and approve this architecture document
2. Create implementation task list based on this design
3. Set up development environment
4. Begin implementation following the patterns defined here
5. Conduct regular architecture reviews as the system evolves

### References

- Flutter Documentation: https://flutter.dev/docs
- Node.js Best Practices: https://github.com/goldbergyoni/nodebestpractices
- Huawei Cloud Documentation: https://support.huaweicloud.com/
- Provider Package: https://pub.dev/packages/provider
- GoRouter Package: https://pub.dev/packages/go_router

---

**Document Version**: 1.0  
**Last Updated**: 2024-01-15  
**Author**: EyeWise Connect Development Team  
**Status**: Draft - Pending Review
