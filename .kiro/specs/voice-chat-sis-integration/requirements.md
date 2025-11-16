# Requirements Document

## Introduction

This feature enables voice-based interaction with the chatbot in the Eye Wise Connect application. Users can record their voice, which is transcribed using Huawei Speech Interaction Service (SIS), processed by the AI chatbot, and returned as text or audio response. The implementation follows security best practices by keeping all credentials and API endpoints on the backend server.

## Glossary

- **SIS**: Speech Interaction Service - Huawei Cloud's real-time speech recognition service
- **Backend Server**: Node.js Express server that acts as a secure proxy between the Flutter app and Huawei Cloud services
- **Flutter App**: The mobile frontend application built with Flutter framework
- **Voice Chat Button**: UI component in the Flutter app that allows users to record and send voice messages
- **IAM Token**: Identity and Access Management authentication token required for Huawei Cloud API calls
- **WebSocket Connection**: Real-time bidirectional communication channel between backend and SIS service
- **PCM Audio**: Pulse Code Modulation - raw audio format required by SIS (16kHz, 16-bit, mono)
- **Chatbot Service**: AI-powered conversational service that processes user queries and generates responses

## Requirements

### Requirement 1

**User Story:** As a user, I want to record my voice and have it transcribed to text, so that I can interact with the chatbot using voice instead of typing.

#### Acceptance Criteria

1. WHEN the user long-presses the voice chat button, THE Flutter App SHALL start recording audio in PCM 16kHz 16-bit mono format
2. WHILE the user holds the voice chat button, THE Flutter App SHALL display a visual indicator showing that recording is in progress
3. WHEN the user releases the voice chat button, THE Flutter App SHALL stop recording and send the audio data to the Backend Server
4. WHEN the Backend Server receives audio data, THE Backend Server SHALL establish a WebSocket connection to SIS endpoint at wss://sis-ext.ap-southeast-3.myhuaweicloud.com/v1/{project_id}/rasr/sentence-stream
5. WHEN the WebSocket connection is established, THE Backend Server SHALL send a START command with audio format configuration to SIS

### Requirement 2

**User Story:** As a developer, I want all sensitive credentials and API endpoints stored securely on the backend, so that the application remains secure and credentials cannot be extracted from the mobile app.

#### Acceptance Criteria

1. THE Backend Server SHALL store SIS endpoint, project ID, and IAM credentials in env.json file
2. THE Flutter App SHALL NOT contain any Huawei Cloud credentials, tokens, or direct API endpoints
3. THE Backend Server SHALL obtain and cache IAM tokens for authentication with SIS
4. WHEN an IAM token expires, THE Backend Server SHALL automatically obtain a new token without user intervention
5. THE Flutter App SHALL communicate with Backend Server through a single endpoint /api/voice-chat

### Requirement 3

**User Story:** As a user, I want to see the transcribed text from my voice input, so that I can verify what the system understood before getting the chatbot response.

#### Acceptance Criteria

1. WHEN SIS completes transcription, THE Backend Server SHALL receive the transcribed text via WebSocket
2. WHEN the Backend Server receives transcribed text, THE Backend Server SHALL send the text to the Chatbot Service
3. WHEN the Chatbot Service returns a response, THE Backend Server SHALL return both the transcribed user text and bot response to the Flutter App
4. WHEN the Flutter App receives the response, THE Flutter App SHALL display the transcribed user text in the chat interface
5. WHEN the Flutter App receives the response, THE Flutter App SHALL display the bot response in the chat interface

### Requirement 4

**User Story:** As a user, I want to receive feedback during the voice processing, so that I know the system is working and not frozen.

#### Acceptance Criteria

1. WHEN the Flutter App is sending audio to the backend, THE Flutter App SHALL display a loading indicator
2. WHEN the Backend Server is processing the request, THE Backend Server SHALL log progress information for debugging
3. IF the voice processing takes longer than 2 seconds, THE Flutter App SHALL continue showing the loading indicator
4. WHEN the Backend Server completes processing, THE Flutter App SHALL hide the loading indicator
5. IF an error occurs during processing, THE Flutter App SHALL display an error message to the user

### Requirement 5

**User Story:** As a developer, I want proper error handling throughout the voice chat flow, so that users receive clear feedback when something goes wrong.

#### Acceptance Criteria

1. IF the microphone permission is not granted, THE Flutter App SHALL request permission and display an appropriate message
2. IF the Backend Server cannot obtain an IAM token, THE Backend Server SHALL return a 500 error with details
3. IF the WebSocket connection to SIS fails, THE Backend Server SHALL return a 503 error indicating service unavailability
4. IF SIS returns an error during transcription, THE Backend Server SHALL log the error and return a 502 error to the Flutter App
5. IF the Chatbot Service fails to respond, THE Backend Server SHALL return a 500 error with chatbot failure details

### Requirement 6

**User Story:** As a user, I want the voice chat feature to work seamlessly with the existing text chat, so that I can switch between input methods without disruption.

#### Acceptance Criteria

1. THE Flutter App SHALL display the voice chat button alongside the existing text input field
2. WHEN a voice message is processed, THE Flutter App SHALL add the transcribed text and bot response to the existing chat message list
3. THE Flutter App SHALL maintain the same chat UI styling for voice-initiated messages as text-initiated messages
4. THE Flutter App SHALL allow users to send text messages while voice processing is in progress
5. THE Flutter App SHALL preserve chat history regardless of input method used
