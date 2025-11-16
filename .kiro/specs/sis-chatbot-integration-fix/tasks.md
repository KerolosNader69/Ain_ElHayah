# Implementation Plan

- [ ] 1. Verify existing SIS implementation
  - Review backend/sis_websocket_manager.js for completeness
  - Review backend/server.js /api/voice-chat endpoint
  - Review lib/widgets/voice_chat_button.dart implementation
  - Review lib/screens/chat_screen.dart integration
  - Verify env.json has all required SIS configuration fields
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 2. Create backend configuration service
- [ ] 2.1 Create lib/config/backend_config.dart file
  - Write BackendConfig class with static getBackendUrl() method
  - Implement platform-specific URL logic (web, Android, iOS)
  - Add support for environment variable BACKEND_URL
  - Add default fallback URLs for each platform
  - _Requirements: 1.3, 4.1_

- [ ] 2.2 Create configuration validation helper
  - Write method to check if backend URL is reachable
  - Add optional health check endpoint call
  - Return configuration status with error details
  - _Requirements: 4.1, 4.5, 5.2_

- [ ] 3. Fix ChatScreen voice button visibility
- [ ] 3.1 Remove platform restriction in chat_screen.dart
  - Locate the `if (!kIsWeb)` condition around line 1050
  - Remove the condition to show VoiceChatButton on all platforms
  - Keep the button layout and spacing consistent
  - _Requirements: 1.1, 1.2_

- [ ] 3.2 Update VoiceChatButton to use dynamic backend URL
  - Import BackendConfig service
  - Replace hardcoded 'http://10.0.2.2:3001' with BackendConfig.getBackendUrl()
  - Ensure URL is passed correctly to VoiceChatButton widget
  - _Requirements: 1.3, 4.1_

- [ ] 3.3 Improve error message display
  - Update onError callback to show more specific error messages
  - Add error type detection (network, permission, transcription, chatbot)
  - Show appropriate user-friendly messages for each error type
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 4. Enhance VoiceChatButton error handling
- [ ] 4.1 Add specific error messages for different scenarios
  - Add error message for microphone permission denied
  - Add error message for backend unreachable
  - Add error message for recording failure
  - Add error message for transcription failure
  - Add error message for chatbot failure
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 4.2 Improve visual feedback during recording
  - Ensure recording indicator is clearly visible
  - Add pulsing animation during recording
  - Show loading spinner during backend processing
  - Display success/error state after completion
  - _Requirements: 1.4, 2.2, 2.4_

- [ ] 5. Verify backend configuration
- [ ] 5.1 Check env.json has all required fields
  - Verify SIS_PROJECT_ID is present and valid
  - Verify SIS_ENDPOINT is present and correct
  - Verify SIS_PROPERTY is set (english_16k_general)
  - Verify MODELARTS_USERNAME, PASSWORD, DOMAIN for IAM
  - Verify MODELARTS_REGION is set
  - _Requirements: 4.1, 4.2_

- [ ] 5.2 Test backend health endpoint
  - Start backend server with `node backend/server.js`
  - Test GET http://localhost:3001/health
  - Verify response shows "status": "OK"
  - Check console logs show env.json loaded successfully
  - _Requirements: 4.3, 4.5_

- [ ] 5.3 Test voice chat endpoint with sample audio
  - Create or use existing sample WAV file (16kHz, 16-bit, mono)
  - Send POST request to /api/voice-chat with audio data
  - Verify response contains userText and botReply fields
  - Check backend logs for SIS WebSocket connection details
  - Verify IAM token is obtained successfully
  - _Requirements: 4.3, 4.4, 4.5_

- [ ] 6. Test on multiple platforms
- [ ] 6.1 Test on web browser
  - Run Flutter web app with `flutter run -d chrome`
  - Navigate to chat screen
  - Verify VoiceChatButton is visible
  - Test recording and sending voice message
  - Verify transcription and bot reply appear in chat
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 6.2 Test on Android emulator
  - Run Flutter app on Android emulator
  - Navigate to chat screen
  - Verify VoiceChatButton is visible
  - Grant microphone permission when prompted
  - Test recording and sending voice message
  - Verify transcription and bot reply appear in chat
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 6.3 Test error scenarios
  - Test with backend server stopped (network error)
  - Test with microphone permission denied
  - Test with invalid audio (very short recording)
  - Test with backend returning error response
  - Verify appropriate error messages shown for each case
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 7. Update documentation
  - Document backend URL configuration for different platforms
  - Add troubleshooting section for common issues
  - Update README with voice chat feature description
  - Document required env.json fields for SIS
  - _Requirements: 4.1, 4.2_
