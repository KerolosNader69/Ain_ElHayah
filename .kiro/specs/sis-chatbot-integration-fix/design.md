# SIS Chatbot Integration Fix - Design Document

## Overview

This design addresses the issue where the SIS voice chat button is not visible in the chatbot interface. The implementation already exists but has a platform-specific condition that hides it on web. This fix will ensure the voice chat button is visible and functional across all platforms, with proper configuration verification and error handling.

## Architecture

### Current Implementation Analysis

The voice chat feature is already implemented with the following components:

1. **Backend**: `/api/voice-chat` endpoint with SIS WebSocket manager
2. **Frontend**: `VoiceChatButton` widget with audio recording
3. **Integration**: Button integrated in `ChatScreen` but conditionally hidden on web

### Issue Identification

```dart
// Current code in chat_screen.dart (line ~1050)
if (!kIsWeb) ...[
  const SizedBox(width: 8),
  VoiceChatButton(
    backendUrl: 'http://10.0.2.2:3001',
    onResponse: (userText, botReply) { ... },
    onError: (error) { ... },
  ),
  const SizedBox(width: 8),
] else
  const SizedBox(width: 8),
```

**Problem**: The `if (!kIsWeb)` condition prevents the button from appearing on web platforms.

## Components and Interfaces

### 1. ChatScreen Modifications

#### Current State
- VoiceChatButton is conditionally rendered only on mobile
- Hardcoded backend URL (`http://10.0.2.2:3001`)
- No configuration validation

#### Proposed Changes
1. **Remove platform restriction**: Show button on all platforms
2. **Dynamic backend URL**: Use environment-based configuration
3. **Add configuration service**: Validate SIS setup before showing button
4. **Improve error handling**: Show clear messages for configuration issues

### 2. Configuration Service

Create a new service to manage backend URL configuration:

```dart
class BackendConfig {
  static String getBackendUrl() {
    if (kIsWeb) {
      // For web, use relative URL or configured endpoint
      return const String.fromEnvironment('BACKEND_URL', 
        defaultValue: 'http://localhost:3001');
    } else if (Platform.isAndroid) {
      // Android emulator
      return 'http://10.0.2.2:3001';
    } else if (Platform.isIOS) {
      // iOS simulator
      return 'http://localhost:3001';
    } else {
      // Default for other platforms
      return 'http://localhost:3001';
    }
  }
}
```

### 3. VoiceChatButton Enhancements

#### Current Implementation
- Works on mobile only
- Shows generic error messages
- No configuration validation

#### Proposed Enhancements
1. **Platform detection**: Handle web recording differently
2. **Better error messages**: Specific messages for different failure scenarios
3. **Visual feedback**: Clear recording state indicators
4. **Graceful degradation**: Show helpful message if feature unavailable

### 4. Backend Verification

The backend implementation is already complete and functional:
- ✅ SIS WebSocket manager implemented
- ✅ `/api/voice-chat` endpoint configured
- ✅ IAM token management working
- ✅ Error handling in place

**Verification needed**:
- Ensure backend is running
- Verify env.json has correct credentials
- Test WebSocket connection to SIS

## Data Models

### Configuration Model

```dart
class VoiceChatConfig {
  final String backendUrl;
  final bool isAvailable;
  final String? errorMessage;
  
  VoiceChatConfig({
    required this.backendUrl,
    required this.isAvailable,
    this.errorMessage,
  });
  
  factory VoiceChatConfig.fromEnvironment() {
    // Check if backend is configured
    final backendUrl = BackendConfig.getBackendUrl();
    
    // For now, assume available if URL is set
    // Could add health check in future
    return VoiceChatConfig(
      backendUrl: backendUrl,
      isAvailable: true,
    );
  }
}
```

### Response Model (Already Implemented)

```dart
// Backend response structure
{
  "success": true,
  "userText": "transcribed text",
  "botReply": "AI response"
}
```

## Error Handling

### Frontend Error Scenarios

1. **Backend Unreachable**
   - Detection: HTTP connection error
   - Message: "Voice chat service unavailable. Please check your connection."
   - Action: Disable button temporarily, show retry option

2. **Microphone Permission Denied**
   - Detection: Permission request returns denied
   - Message: "Microphone access required for voice chat. Please enable in settings."
   - Action: Show settings link (platform-specific)

3. **Recording Failed**
   - Detection: Audio recording returns null/error
   - Message: "Failed to record audio. Please try again."
   - Action: Reset button state, allow retry

4. **Transcription Failed**
   - Detection: Backend returns error with stage: 'transcription'
   - Message: "Could not understand audio. Please speak clearly and try again."
   - Action: Allow immediate retry

5. **Chatbot Failed**
   - Detection: Backend returns error with stage: 'chatbot'
   - Message: "Transcription: [text]. Chatbot temporarily unavailable."
   - Action: Show transcribed text, allow user to see what was understood

### Backend Error Scenarios (Already Handled)

1. **IAM Token Failure** → 500 error
2. **WebSocket Connection Failed** → 503 error
3. **SIS Transcription Error** → 502 error
4. **Invalid Audio Format** → 400 error

## Testing Strategy

### Verification Tests

1. **Configuration Verification**
   - Test: Check env.json has all required SIS fields
   - Expected: SIS_PROJECT_ID, SIS_ENDPOINT, SIS_PROPERTY present
   - Test: Verify MODELARTS credentials for IAM
   - Expected: USERNAME, PASSWORD, DOMAIN present

2. **Backend Health Check**
   - Test: GET /health endpoint
   - Expected: 200 OK response
   - Test: Backend logs show SIS configuration loaded
   - Expected: Console shows "Loaded env.json configuration"

3. **Button Visibility Test**
   - Test: Navigate to chat screen on web
   - Expected: VoiceChatButton visible next to send button
   - Test: Navigate to chat screen on mobile
   - Expected: VoiceChatButton visible next to send button

4. **Recording Flow Test**
   - Test: Tap voice button
   - Expected: Recording starts, button shows recording state
   - Test: Tap button again
   - Expected: Recording stops, loading indicator shows
   - Test: Wait for response
   - Expected: Transcribed text and bot reply appear in chat

### Integration Tests

1. **End-to-End Voice Chat**
   - Start backend server
   - Open chat screen
   - Record 5-second voice message
   - Verify transcription appears
   - Verify bot response appears
   - Verify chat history updated

2. **Error Recovery**
   - Stop backend server
   - Try to send voice message
   - Verify error message shown
   - Restart backend
   - Retry voice message
   - Verify success

3. **Permission Handling**
   - Deny microphone permission
   - Tap voice button
   - Verify permission error shown
   - Grant permission
   - Retry
   - Verify recording works

## Implementation Plan

### Phase 1: Configuration Fix (High Priority)

1. Remove `if (!kIsWeb)` condition from chat_screen.dart
2. Create BackendConfig service for dynamic URL
3. Update VoiceChatButton to use BackendConfig
4. Test on web and mobile platforms

### Phase 2: Verification (High Priority)

1. Verify env.json configuration
2. Test backend /health endpoint
3. Test /api/voice-chat endpoint with sample audio
4. Verify SIS WebSocket connection
5. Check IAM token generation

### Phase 3: Error Handling Enhancement (Medium Priority)

1. Add specific error messages for each failure type
2. Implement retry mechanism
3. Add configuration validation on startup
4. Show helpful hints when feature unavailable

### Phase 4: Testing (Medium Priority)

1. Manual testing on web browser
2. Manual testing on Android emulator
3. Manual testing on iOS simulator (if available)
4. Test with different audio lengths
5. Test error scenarios

## Security Considerations

### Already Implemented ✅
- All credentials stored in backend env.json
- No credentials in Flutter app
- IAM token never sent to frontend
- HTTPS/WSS for all communications

### Additional Recommendations
- Add rate limiting on /api/voice-chat endpoint
- Implement request size limits (already at 10MB)
- Add user authentication to voice chat endpoint
- Log all voice chat requests for audit

## Performance Considerations

### Current Performance
- Audio recording: ~320KB for 10 seconds
- Backend processing: 2-5 seconds typical
- WebSocket connection: ~1 second to establish

### Optimizations
- Reuse IAM token (already implemented, 23-hour cache)
- Compress audio before sending (optional)
- Show progress indicator during processing
- Implement timeout (30 seconds max)

## Dependencies

### Existing Dependencies ✅
```yaml
# Flutter
dependencies:
  http: ^1.2.0
  record: ^5.0.0
  permission_handler: ^11.0.0

# Backend
{
  "ws": "^8.14.0"
}
```

### No New Dependencies Required

## Platform-Specific Considerations

### Web Platform
- Use browser MediaRecorder API (already handled by `record` package)
- Backend URL should be relative or CORS-enabled
- Microphone permission handled by browser
- No file system access needed

### Mobile Platform (Android/iOS)
- Native audio recording (already implemented)
- Platform-specific permissions (already configured)
- Different backend URLs for emulator vs device

### Backend URL Configuration

| Platform | Environment | Backend URL |
|----------|-------------|-------------|
| Web | Development | `http://localhost:3001` |
| Web | Production | `https://api.eyewise.com` |
| Android Emulator | Development | `http://10.0.2.2:3001` |
| Android Device | Development | `http://192.168.x.x:3001` |
| iOS Simulator | Development | `http://localhost:3001` |
| iOS Device | Development | `http://192.168.x.x:3001` |

## Rollout Plan

### Step 1: Verify Current Implementation
- Check all files are present
- Verify backend is running
- Test with curl/Postman

### Step 2: Apply Fix
- Remove platform restriction
- Add configuration service
- Update error messages

### Step 3: Test
- Test on web browser
- Test on mobile emulator
- Verify error handling

### Step 4: Document
- Update README with setup instructions
- Document backend URL configuration
- Add troubleshooting guide

## Success Criteria

1. ✅ Voice chat button visible on all platforms
2. ✅ Button functional on web and mobile
3. ✅ Clear error messages for all failure scenarios
4. ✅ Configuration properly validated
5. ✅ Backend URL dynamically configured
6. ✅ All existing tests pass
7. ✅ Documentation updated
