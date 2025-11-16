# Existing SIS Implementation Analysis

## Overview
This document analyzes the existing Huawei SIS implementation found in the Flutter codebase and identifies why it failed and what needs to be changed.

## Files Reviewed

### 1. lib/services/huawei_sis_asr_service.dart
**Purpose**: Direct WebSocket connection from Flutter to Huawei SIS with AK/SK signing

**Key Features**:
- Implements AK/SK signature generation for WebSocket authentication
- Builds WebSocket URL with signed query parameters
- Sends ASR configuration commands (START, SEND, END)
- Handles audio streaming to SIS

**Critical Issues**:
1. **Security Risk**: AK/SK credentials exposed in Flutter app
   - Anyone can decompile the app and extract credentials
   - Credentials hardcoded or passed from config accessible to client
   - Violates Huawei Cloud security best practices

2. **Authentication Method**: Uses AK/SK signing instead of IAM tokens
   - SIS WebSocket endpoint requires X-Auth-Token (IAM token) in headers
   - AK/SK signature in query parameters may not work for WebSocket upgrade
   - Mismatch between implementation and SIS API requirements

3. **CORS and Network Issues**:
   - Mobile apps may face CORS restrictions with direct WebSocket connections
   - Network policies might block direct cloud service access
   - No proxy layer for debugging or monitoring

4. **Configuration Issues**:
   - WebSocket URL uses `/v1/{projectId}/ws` endpoint
   - Correct endpoint should be `/v1/{projectId}/rasr/sentence-stream`
   - Audio format specified as `audio/L16;rate=16000;channels=1`
   - Should use `pcm16k16bit` format specification

### 2. lib/providers/huawei_sis_provider.dart
**Purpose**: Provider for managing recording state and SIS connection

**Key Features**:
- Uses `record` package for audio recording
- Manages WebSocket connection lifecycle
- Streams audio chunks directly to SIS
- Handles transcription results

**Critical Issues**:
1. **Direct Connection**: Connects Flutter app directly to SIS
   - Bypasses any backend security layer
   - No centralized error handling or logging
   - Difficult to update or maintain

2. **Audio Streaming**: Streams raw PCM bytes to WebSocket
   - SIS expects base64-encoded audio in JSON messages
   - Current implementation sends raw bytes which won't work
   - Missing proper message framing

3. **Error Handling**: Limited error handling
   - Generic error messages
   - No retry logic
   - No fallback mechanisms

4. **State Management**: Tightly coupled to SIS service
   - Hard to test independently
   - Cannot switch to backend API without major refactoring

## Why It Failed

### Primary Reasons:
1. **Wrong Authentication Method**: AK/SK signing vs IAM token requirement
2. **Wrong Endpoint**: `/ws` vs `/rasr/sentence-stream`
3. **Wrong Audio Format**: Raw bytes vs base64-encoded JSON messages
4. **Security Violations**: Credentials exposed in client app
5. **Network Restrictions**: Direct WebSocket connections from mobile may be blocked

### Secondary Issues:
- No backend proxy for monitoring and debugging
- Difficult to integrate with chatbot service
- Cannot implement rate limiting or usage tracking
- Hard to update without app redeployment

## Reusable Code Patterns

### From huawei_sis_asr_service.dart:
✅ **Keep**:
- Audio format configuration knowledge (16kHz, mono, PCM)
- Understanding of SIS command structure (START, SEND, END)
- WebSocket message flow pattern

❌ **Remove**:
- AK/SK signing logic (move to backend if needed)
- Direct WebSocket connection code
- Query parameter authentication

### From huawei_sis_provider.dart:
✅ **Keep**:
- Audio recording configuration (AudioEncoder.pcm16bits, 16kHz, mono)
- State management pattern (_isRecording, _isSending, _error)
- Permission handling logic
- Audio streaming approach (can adapt for backend upload)

❌ **Remove**:
- Direct SIS WebSocket connection
- WebSocket message handling
- SIS-specific error parsing

## Recommended Architecture Change

### Current (Failed) Architecture:
```
Flutter App → Direct WebSocket → Huawei SIS
     ↓
  AK/SK exposed
```

### New (Secure) Architecture:
```
Flutter App → HTTPS POST → Backend Server → WebSocket → Huawei SIS
                              ↓
                         IAM Token (cached)
                              ↓
                         Chatbot Service
```

## Migration Strategy

### Phase 1: Backend Implementation
1. Create backend endpoint `/api/voice-chat`
2. Implement IAM token authentication
3. Implement SIS WebSocket connection with correct endpoint
4. Implement proper message formatting (base64 JSON)
5. Integrate with chatbot service

### Phase 2: Flutter Refactoring
1. Keep audio recording logic from existing provider
2. Replace WebSocket connection with HTTP POST to backend
3. Simplify provider to handle recording and API calls only
4. Remove all SIS-specific code and credentials

### Phase 3: Testing
1. Test backend SIS integration independently
2. Test Flutter audio recording and upload
3. Test end-to-end flow
4. Verify no credentials in Flutter app

## Configuration Corrections

### Current env.json (Correct):
```json
{
  "SIS_PROJECT_ID": "59dcb311d4e5e4ca6bb8b8bc7a7712d7",
  "SIS_ENDPOINT": "sis-ext.ap-southeast-3.myhuaweicloud.com",
  "SIS_LANGUAGE": "en_US"
}
```

### Correct WebSocket URL:
```
wss://sis-ext.ap-southeast-3.myhuaweicloud.com/v1/59dcb311d4e5e4ca6bb8b8bc7a7712d7/rasr/sentence-stream
```

### Correct START Command:
```json
{
  "command": "START",
  "config": {
    "audio_format": "pcm16k16bit",
    "property": "english_16k_general",
    "add_punc": "yes"
  }
}
```

### Correct Audio Chunk Format:
```json
{
  "command": "SEND",
  "data": "<base64_encoded_audio_bytes>"
}
```

## Conclusion

The existing implementation failed due to:
1. Security issues (exposed credentials)
2. Wrong authentication method (AK/SK vs IAM)
3. Wrong endpoint and message format
4. Architectural problems (no backend proxy)

The solution is to:
1. Move all SIS communication to backend
2. Use IAM token authentication
3. Use correct endpoint and message formats
4. Keep only audio recording logic in Flutter
5. Implement secure HTTPS communication between Flutter and backend

This approach follows Huawei Cloud best practices and provides a secure, maintainable solution.
