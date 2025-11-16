# Implementation Plan

## Analysis and Cleanup

- [ ] 1. Review existing SIS implementation and identify issues
  - Review lib/services/huawei_sis_asr_service.dart for direct WebSocket approach
  - Review lib/providers/huawei_sis_provider.dart for client-side implementation
  - Document why direct Flutter-to-SIS connection failed (security, CORS, authentication)
  - Identify reusable code patterns for backend implementation
  - _Requirements: 2.1, 2.2_

- [ ] 2. Remove or refactor insecure Flutter SIS code
  - Remove direct WebSocket connection code from Flutter
  - Remove AK/SK signing logic from Flutter (security risk)
  - Keep audio recording logic that can be reused
  - Update provider to call backend API instead of direct SIS connection
  - _Requirements: 2.1, 2.2_

## Backend Implementation

- [ ] 3. Install WebSocket dependency and update configuration
  - Add `ws` package to backend/package.json
  - Verify env.json has correct SIS configuration (SIS_PROJECT_ID, SIS_ENDPOINT, SIS_PROPERTY already exist)
  - Verify existing MODELARTS credentials can be reused for SIS authentication
  - _Requirements: 2.1, 2.3_

- [ ] 4. Implement SIS WebSocket manager module
- [ ] 4.1 Create SIS WebSocket connection handler
  - Write function to construct WebSocket URL with project ID
  - Implement WebSocket connection with IAM token authentication
  - Add connection timeout handling (10 seconds)
  - _Requirements: 1.4, 2.3, 5.3_

- [ ] 4.2 Implement SIS protocol commands
  - Write START command builder with audio format configuration
  - Write SEND command for audio chunk transmission with base64 encoding
  - Write END command sender
  - _Requirements: 1.5_

- [ ] 4.3 Implement transcription result handler
  - Parse WebSocket messages from SIS
  - Extract transcribed text from result
  - Handle SIS error responses with proper error codes
  - _Requirements: 3.1, 5.4_

- [ ] 5. Create voice chat API endpoint
- [ ] 5.1 Set up endpoint route and middleware
  - Add POST /api/voice-chat route to server.js
  - Configure express.raw() middleware for audio/wav content type with 10MB limit
  - Add request logging for debugging
  - _Requirements: 2.5, 4.2_

- [ ] 5.2 Implement audio processing flow
  - Receive audio bytes from request body
  - Validate audio data is present and not empty
  - Convert audio buffer to base64 for SIS transmission
  - Split audio into chunks if needed (max 10KB per chunk)
  - _Requirements: 1.3, 5.5_

- [ ] 5.3 Integrate IAM token management
  - Reuse existing getIAMToken function with SIS credentials
  - Handle token caching and refresh logic
  - Add error handling for authentication failures
  - _Requirements: 2.3, 2.4, 5.2_

- [ ] 5.4 Implement complete request flow
  - Obtain IAM token for SIS authentication
  - Establish WebSocket connection to SIS
  - Send START command with audio configuration
  - Stream audio chunks to SIS via SEND commands
  - Send END command to finalize transcription
  - Wait for and parse transcription result
  - Close WebSocket connection
  - _Requirements: 1.4, 1.5, 3.1_

- [ ] 5.5 Integrate chatbot service
  - Send transcribed text to existing Huawei AI chatbot API
  - Handle chatbot response or error
  - Implement fallback message if chatbot fails
  - _Requirements: 3.2, 5.5_

- [ ] 5.6 Build and return response
  - Create JSON response with userText and botReply fields
  - Add success flag and error details
  - Return appropriate HTTP status codes (200, 400, 500, 502, 503)
  - _Requirements: 3.3, 4.4, 5.2, 5.3, 5.4, 5.5_

## Flutter Implementation

- [ ] 6. Add required dependencies to Flutter project
  - Add http ^1.2.0 to pubspec.yaml
  - Add record ^5.0.0 to pubspec.yaml
  - Add permission_handler ^11.0.0 to pubspec.yaml
  - Run flutter pub get
  - _Requirements: 1.1_

- [ ] 5. Create voice chat button widget
- [ ] 5.1 Implement VoiceChatButton stateful widget
  - Create widget file lib/widgets/voice_chat_button.dart
  - Add state variables for _isRecording and _isSending
  - Import required packages (dart:io, record, http, permission_handler)
  - _Requirements: 1.1, 4.1_

- [ ] 5.2 Implement audio recording logic
  - Initialize Record instance
  - Implement _startRecording method with permission check
  - Configure recording with AudioEncoder.wav, 16kHz sample rate, mono channel
  - Update UI state when recording starts
  - _Requirements: 1.1, 1.2, 5.1_

- [ ] 5.3 Implement stop and send logic
  - Implement _stopAndSend method to stop recording
  - Read audio file bytes
  - Show loading indicator during upload
  - Clean up temporary audio file after reading
  - _Requirements: 1.3, 4.1_

- [ ] 5.4 Implement API communication
  - Build POST request to backend /api/voice-chat endpoint
  - Set Content-Type header to audio/wav
  - Send audio bytes as request body
  - Parse JSON response with userText and botReply
  - _Requirements: 1.3, 3.3, 3.4_

- [ ] 5.5 Build widget UI with gesture handling
  - Create GestureDetector with onLongPress and onLongPressUp
  - Show CircleAvatar with microphone icon
  - Toggle icon between mic and mic_none based on recording state
  - Show CircularProgressIndicator when sending
  - _Requirements: 1.2, 4.1, 4.4_

- [ ] 5.6 Implement error handling
  - Handle permission denial with user-friendly message
  - Handle recording failures with error display
  - Handle network errors with retry option
  - Handle backend errors by parsing error field from response
  - _Requirements: 4.5, 5.1, 5.2_

- [ ] 6. Integrate voice chat button into chat UI
  - Locate existing chat screen file
  - Add VoiceChatButton import
  - Place voice button in Row alongside text input field
  - Add spacing between text field and voice button
  - _Requirements: 6.1, 6.2_

- [ ] 7. Implement chat message handling for voice input
  - Create callback function to handle voice chat response
  - Add transcribed user text to chat messages list
  - Add bot reply to chat messages list
  - Use existing chat message styling for consistency
  - Ensure chat scrolls to show new messages
  - _Requirements: 3.4, 3.5, 6.2, 6.3, 6.5_

## Testing and Validation

- [ ] 8. Backend testing
- [ ] 8.1 Create unit tests for SIS WebSocket manager
  - Test WebSocket URL construction with project ID
  - Test START command JSON format
  - Test audio chunk base64 encoding
  - Test END command sending
  - Test transcription result parsing
  - _Requirements: 1.4, 1.5, 3.1_

- [ ] 8.2 Create integration test for voice chat endpoint
  - Test endpoint accepts audio/wav content type
  - Test with sample WAV file
  - Verify JSON response structure
  - Test error handling for missing audio
  - Test IAM token caching behavior
  - _Requirements: 2.3, 2.4, 3.3, 5.2_

- [ ] 9. Flutter testing
- [ ] 9.1 Create widget tests for VoiceChatButton
  - Test long press starts recording
  - Test release stops recording and sends
  - Test loading indicator appears during processing
  - Test error message display
  - _Requirements: 1.1, 1.2, 1.3, 4.1, 4.4_

- [ ] 9.2 Create unit tests for audio recording
  - Test audio format configuration (16kHz, mono, WAV)
  - Test permission request handling
  - Test file cleanup after sending
  - _Requirements: 1.1, 5.1_

- [ ] 10. Manual end-to-end testing
  - Start backend server with updated configuration
  - Run Flutter app on physical device or emulator
  - Test microphone permission flow (deny then allow)
  - Record 5-second voice message and verify transcription
  - Verify bot response appears in chat
  - Test with different audio lengths (1s, 10s, 30s)
  - Test error scenarios (no internet, backend down)
  - Verify chat history includes voice messages
  - Test on both Android and iOS if applicable
  - _Requirements: 1.1, 1.2, 1.3, 3.4, 3.5, 4.5, 6.2, 6.3, 6.5_

## Configuration and Documentation

- [ ] 11. Update environment configuration
  - Verify SIS_PROJECT_ID is set correctly in env.json
  - Verify SIS_ENDPOINT points to ap-southeast-3 region
  - Verify SIS_PROPERTY is set to english_16k_general
  - Document configuration in README or setup guide
  - _Requirements: 2.1_

- [ ] 12. Add platform-specific permissions
  - Add microphone permission to AndroidManifest.xml
  - Add microphone permission to Info.plist for iOS
  - Add permission usage descriptions
  - _Requirements: 5.1_
