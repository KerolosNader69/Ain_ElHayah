# Voice Chat with SIS Integration - Design Document

## Overview

This design implements a secure voice chat feature that allows users to interact with the chatbot using voice input. The architecture follows a three-tier approach: Flutter frontend for audio capture, Node.js backend as a secure proxy, and Huawei SIS for speech recognition. All sensitive credentials remain on the backend, ensuring security best practices.

## Architecture

### High-Level Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│                 │  HTTPS  │                  │  WSS    │                 │
│  Flutter App    │────────▶│  Backend Server  │────────▶│  Huawei SIS     │
│  (Mobile)       │◀────────│  (Node.js)       │◀────────│  (WebSocket)    │
│                 │  JSON   │                  │  JSON   │                 │
└─────────────────┘         └──────────────────┘         └─────────────────┘
                                     │
                                     │ HTTPS
                                     ▼
                            ┌──────────────────┐
                            │                  │
                            │  Chatbot Service │
                            │  (Huawei AI)     │
                            │                  │
                            └──────────────────┘
```

### Communication Flow

1. **Audio Capture**: Flutter app records audio in PCM 16kHz 16-bit mono format
2. **Upload**: Audio bytes sent to backend via POST /api/voice-chat
3. **Authentication**: Backend obtains/uses cached IAM token
4. **WebSocket**: Backend establishes WSS connection to SIS
5. **Transcription**: SIS processes audio and returns text
6. **Chatbot**: Backend sends transcribed text to chatbot service
7. **Response**: Backend returns both transcribed text and bot reply to Flutter

## Components and Interfaces

### 1. Flutter Frontend Components

#### VoiceChatButton Widget
- **Purpose**: UI component for voice recording
- **State Management**: 
  - `_isRecording`: Boolean indicating active recording
  - `_isSending`: Boolean indicating backend processing
- **User Interaction**:
  - Long press to start recording
  - Release to stop and send
- **Visual Feedback**:
  - Microphone icon changes during recording
  - Loading indicator during processing

#### Audio Recording Service
- **Package**: `record` (v5.0.0+)
- **Configuration**:
  ```dart
  encoder: AudioEncoder.wav
  samplingRate: 16000
  numChannels: 1
  ```
- **Output**: WAV file with PCM data
- **Permissions**: Handles microphone permission requests

#### Voice Chat API Client
- **Package**: `http` (v1.2.0+)
- **Endpoint**: `POST /api/voice-chat`
- **Request**:
  - Headers: `Content-Type: audio/wav`
  - Body: Raw audio bytes
- **Response**: JSON with transcribed text and bot reply

### 2. Backend Server Components

#### Voice Chat Endpoint Handler
```javascript
POST /api/voice-chat
- Accepts: audio/wav (raw bytes)
- Returns: JSON { userText, botReply, success, error }
```

**Responsibilities**:
1. Receive audio data from Flutter
2. Obtain IAM token (cached or new)
3. Establish WebSocket to SIS
4. Send START command with audio config
5. Stream audio chunks to SIS
6. Receive transcription result
7. Send text to chatbot service
8. Return combined response

#### SIS WebSocket Manager
- **Connection URL**: `wss://sis-ext.ap-southeast-3.myhuaweicloud.com/v1/{project_id}/rasr/sentence-stream`
- **Authentication**: X-Auth-Token header
- **Protocol**:
  1. Connect with IAM token
  2. Send START command
  3. Send audio chunks (base64 encoded)
  4. Send END command
  5. Receive transcription result
  6. Close connection

**START Command Format**:
```json
{
  "command": "START",
  "config": {
    "audio_format": "pcm16k16bit",
    "property": "english_16k_general",
    "add_punc": "yes",
    "interim_results": "no"
  }
}
```

**Audio Chunk Format**:
```json
{
  "command": "SEND",
  "data": "<base64_encoded_audio>"
}
```

**END Command Format**:
```json
{
  "command": "END"
}
```

#### IAM Token Manager (Reuse Existing)
- **Function**: `getIAMToken(username, password, domain, projectId, region)`
- **Caching**: 23-hour token cache
- **Credentials Source**: env.json
- **Required Fields**:
  - MODELARTS_USERNAME (reused for SIS)
  - MODELARTS_PASSWORD (reused for SIS)
  - MODELARTS_DOMAIN (reused for SIS)
  - SIS_PROJECT_ID
  - MODELARTS_REGION (reused for SIS)

#### Chatbot Integration
- **Service**: Huawei AI API (existing)
- **Input**: Transcribed text from SIS
- **Output**: Bot response text
- **Error Handling**: Fallback message if chatbot fails

### 3. Configuration Management

#### env.json Updates
```json
{
  "SIS_PROJECT_ID": "59dcb311d4e5e4ca6bb8b8bc7a7712d7",
  "SIS_ENDPOINT": "sis-ext.ap-southeast-3.myhuaweicloud.com",
  "SIS_LANGUAGE": "en_US",
  "SIS_PROPERTY": "english_16k_general"
}
```

Note: Reuse existing MODELARTS_USERNAME, MODELARTS_PASSWORD, MODELARTS_DOMAIN, and MODELARTS_REGION for SIS authentication.

## Data Models

### Flutter Request Model
```dart
// No explicit model needed - sends raw bytes
// Content-Type: audio/wav
```

### Backend Response Model
```typescript
interface VoiceChatResponse {
  success: boolean;
  userText?: string;        // Transcribed text from SIS
  botReply?: string;        // Response from chatbot
  error?: string;           // Error message if failed
  details?: {               // Additional error context
    stage?: string;         // Where error occurred
    sisError?: any;         // SIS-specific error
    chatbotError?: any;     // Chatbot-specific error
  };
}
```

### SIS WebSocket Messages

**Transcription Result**:
```json
{
  "result": {
    "text": "transcribed text here",
    "confidence": 0.95
  }
}
```

**Error Response**:
```json
{
  "error_code": "SIS.0001",
  "error_msg": "Invalid audio format"
}
```

## Error Handling

### Flutter Error Scenarios

1. **Microphone Permission Denied**
   - Check: `Permission.microphone.request()`
   - Action: Show dialog explaining permission needed
   - Recovery: Guide user to app settings

2. **Recording Failed**
   - Check: `_record.start()` returns null
   - Action: Show error snackbar
   - Recovery: Allow retry

3. **Network Error**
   - Check: HTTP exception during POST
   - Action: Show "Connection failed" message
   - Recovery: Retry button

4. **Backend Error (4xx/5xx)**
   - Check: Response status code
   - Action: Parse error message and display
   - Recovery: Allow retry with same audio

### Backend Error Scenarios

1. **IAM Token Failure**
   - Check: Token request returns non-200
   - Action: Log error details, return 500
   - Response: `{ success: false, error: "Authentication failed" }`

2. **WebSocket Connection Failed**
   - Check: WebSocket error event
   - Action: Log connection details, return 503
   - Response: `{ success: false, error: "SIS service unavailable" }`

3. **SIS Transcription Error**
   - Check: Error message in WebSocket response
   - Action: Log SIS error, return 502
   - Response: `{ success: false, error: "Transcription failed", details: {...} }`

4. **Chatbot Service Error**
   - Check: Chatbot API returns error
   - Action: Log error, return partial success
   - Response: `{ success: true, userText: "...", botReply: "Sorry, I couldn't process that" }`

5. **Invalid Audio Format**
   - Check: Audio data validation
   - Action: Return 400 with details
   - Response: `{ success: false, error: "Invalid audio format" }`

### Error Logging Strategy

All errors logged with:
- Timestamp
- Error stage (recording/upload/transcription/chatbot)
- Error details
- Request context (user ID if available)

## Testing Strategy

### Unit Tests

#### Flutter Tests
1. **VoiceChatButton Widget Test**
   - Test: Long press starts recording
   - Test: Release stops recording
   - Test: Loading indicator shows during processing
   - Test: Error message displays on failure

2. **Audio Recording Test**
   - Test: Correct audio format configuration
   - Test: Permission request handling
   - Test: File creation and cleanup

3. **API Client Test**
   - Test: Correct endpoint and headers
   - Test: Response parsing
   - Test: Error handling

#### Backend Tests
1. **Voice Chat Endpoint Test**
   - Test: Accepts audio/wav content type
   - Test: Returns correct JSON structure
   - Test: Handles missing audio data

2. **SIS WebSocket Manager Test**
   - Test: Correct WebSocket URL construction
   - Test: START command format
   - Test: Audio chunk encoding
   - Test: END command sending
   - Test: Response parsing

3. **IAM Token Caching Test**
   - Test: Token reuse within 23 hours
   - Test: Token refresh after expiry
   - Test: Concurrent request handling

### Integration Tests

1. **End-to-End Voice Chat Flow**
   - Record sample audio in Flutter
   - Send to backend
   - Verify transcription received
   - Verify bot response received
   - Verify UI updates correctly

2. **Error Recovery Flow**
   - Simulate network failure
   - Verify error message shown
   - Verify retry works

3. **Permission Flow**
   - Deny microphone permission
   - Verify error handling
   - Grant permission
   - Verify recording works

### Manual Testing Checklist

- [ ] Record voice and verify transcription accuracy
- [ ] Test with different audio lengths (1s, 5s, 10s)
- [ ] Test with background noise
- [ ] Test with poor network connection
- [ ] Test permission denial and recovery
- [ ] Test rapid consecutive recordings
- [ ] Verify chat history includes voice messages
- [ ] Test on different devices (Android/iOS)
- [ ] Verify no credentials in Flutter app binary

## Security Considerations

1. **Credential Protection**
   - All Huawei Cloud credentials stored only in backend env.json
   - Flutter app has no direct access to SIS or IAM endpoints
   - IAM tokens never sent to Flutter app

2. **Network Security**
   - HTTPS for Flutter ↔ Backend communication
   - WSS (WebSocket Secure) for Backend ↔ SIS communication
   - Token transmitted only in secure headers

3. **Audio Data Privacy**
   - Audio files deleted after processing
   - No audio storage on backend
   - Transcribed text logged only for debugging (can be disabled in production)

4. **Rate Limiting**
   - Consider implementing rate limiting on /api/voice-chat endpoint
   - Prevent abuse and control costs

## Performance Considerations

1. **Audio File Size**
   - 10-second recording ≈ 320KB (16kHz, 16-bit, mono)
   - Set reasonable max recording duration (e.g., 30 seconds)

2. **Token Caching**
   - Reuse IAM token for 23 hours
   - Reduces authentication overhead

3. **WebSocket Connection**
   - Create new connection per request (simpler)
   - Alternative: Connection pooling for high traffic

4. **Response Time**
   - Expected: 2-5 seconds for 10-second audio
   - Show loading indicator throughout

## Dependencies

### Flutter Dependencies
```yaml
dependencies:
  http: ^1.2.0
  record: ^5.0.0
  permission_handler: ^11.0.0
```

### Backend Dependencies
```json
{
  "ws": "^8.14.0"
}
```

## Implementation Notes

1. **Audio Format Compatibility**
   - Flutter `record` package outputs WAV with PCM data
   - SIS expects PCM 16kHz 16-bit mono
   - No conversion needed if configured correctly

2. **WebSocket Library**
   - Use `ws` package for Node.js
   - Handle connection lifecycle properly
   - Implement timeout for hanging connections

3. **Chatbot Integration**
   - Reuse existing Huawei AI API integration
   - Pass transcribed text as user message
   - Return bot response in same format as text chat

4. **UI Integration**
   - Place voice button next to text input
   - Use same chat bubble styling for voice messages
   - Add microphone icon to indicate voice origin (optional)
