# Requirements Document

## Introduction

This feature ensures that the SIS (Speech Interaction Service) voice chat integration is properly visible and functional in the chatbot page of the Eye Wise Connect application. The implementation already exists but needs verification and potential fixes to ensure it appears correctly and works as expected.

## Glossary

- **SIS**: Speech Interaction Service - Huawei Cloud's real-time speech recognition service
- **VoiceChatButton**: UI widget that allows users to record and send voice messages
- **Backend Server**: Node.js Express server at `/api/voice-chat` endpoint
- **ChatScreen**: The main chatbot interface where users interact with the AI assistant
- **env.json**: Configuration file containing SIS credentials and endpoints

## Requirements

### Requirement 1

**User Story:** As a user, I want to see the voice chat button in the chatbot interface, so that I can use voice input to interact with the AI assistant.

#### Acceptance Criteria

1. WHEN the user navigates to the chat screen, THE ChatScreen SHALL display the VoiceChatButton widget in the input section
2. THE VoiceChatButton SHALL be visible on both mobile and web platforms
3. THE VoiceChatButton SHALL be positioned next to the text input field and send button
4. THE VoiceChatButton SHALL have a clear microphone icon indicating its purpose
5. THE VoiceChatButton SHALL be styled consistently with the application theme

### Requirement 2

**User Story:** As a user, I want to record my voice by tapping the voice button, so that I can send voice messages to the chatbot.

#### Acceptance Criteria

1. WHEN the user taps the VoiceChatButton, THE VoiceChatButton SHALL start recording audio
2. WHILE recording is active, THE VoiceChatButton SHALL display a visual indicator showing recording in progress
3. WHEN the user taps the button again during recording, THE VoiceChatButton SHALL stop recording and send the audio to the backend
4. WHEN audio is being processed, THE VoiceChatButton SHALL display a loading indicator
5. IF recording fails, THE VoiceChatButton SHALL display an error message to the user

### Requirement 3

**User Story:** As a user, I want my voice message to be transcribed and processed by the chatbot, so that I receive a relevant response.

#### Acceptance Criteria

1. WHEN the VoiceChatButton sends audio to the backend, THE Backend Server SHALL transcribe the audio using SIS
2. WHEN transcription is complete, THE Backend Server SHALL send the transcribed text to the chatbot service
3. WHEN the chatbot responds, THE Backend Server SHALL return both the transcribed text and bot reply to the Flutter app
4. WHEN the Flutter app receives the response, THE ChatScreen SHALL display the transcribed user text in the chat interface
5. WHEN the Flutter app receives the response, THE ChatScreen SHALL display the bot response in the chat interface

### Requirement 4

**User Story:** As a developer, I want to verify that all SIS configuration is correct, so that the voice chat feature works reliably.

#### Acceptance Criteria

1. THE env.json file SHALL contain valid SIS_PROJECT_ID, SIS_ENDPOINT, and SIS_PROPERTY values
2. THE env.json file SHALL contain valid MODELARTS_USERNAME, MODELARTS_PASSWORD, and MODELARTS_DOMAIN for IAM authentication
3. THE Backend Server SHALL successfully obtain IAM tokens using the configured credentials
4. THE Backend Server SHALL successfully establish WebSocket connections to the SIS endpoint
5. THE Backend Server SHALL log all SIS-related operations for debugging purposes

### Requirement 5

**User Story:** As a user, I want clear error messages when voice chat fails, so that I understand what went wrong and can take corrective action.

#### Acceptance Criteria

1. IF microphone permission is denied, THE ChatScreen SHALL display a message explaining that permission is required
2. IF the backend is unreachable, THE ChatScreen SHALL display a network error message
3. IF SIS transcription fails, THE ChatScreen SHALL display a transcription error message
4. IF the chatbot service fails, THE ChatScreen SHALL display the transcribed text but indicate that the bot response failed
5. THE Backend Server SHALL return appropriate HTTP status codes for different error scenarios (400, 500, 502, 503)
