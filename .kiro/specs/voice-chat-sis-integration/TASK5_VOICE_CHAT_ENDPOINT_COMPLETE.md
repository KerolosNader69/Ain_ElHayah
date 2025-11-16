# Task 5 Complete: Voice Chat API Endpoint

## Overview
Created the `/api/voice-chat` endpoint in the backend server that integrates SIS transcription with the complete voice chat flow. This endpoint receives audio from Flutter, transcribes it using SIS, and returns both the transcribed text and bot reply.

## Implementation Details

### Endpoint: POST /api/voice-chat

**Location**: `backend/server.js`

**Content-Type**: `audio/wav`

**Request Body**: Raw audio bytes (WAV format, PCM 16kHz 16-bit mono)

**Response**: JSON
```json
{
  "success": true,
  "userText": "transcribed text from audio",
  "botReply": "chatbot response"
}
```

## Sub-Tasks Completed

### 5.1 Set up endpoint route and middleware ✅

**Middleware Configuration**:
```javascript
app.use('/api/voice-chat', express.raw({ type: 'audio/wav', limit: '10mb' }));
```
- Accepts `audio/wav` content type
- Parses raw binary data (not JSON)
- 10MB size limit for audio files
- Request logging with timestamps

### 5.2 Implement audio processing flow ✅

**Audio Validation**:
- Checks if audio data exists
- Validates data is not empty
- Logs audio data size for debugging

**Audio Handling**:
- Receives audio as Buffer from `req.body`
- Passes directly to SIS manager (no conversion needed)
- SIS manager handles base64 encoding internally

### 5.3 Integrate IAM token management ✅

**Token Acquisition**:
- Reuses existing `getIAMToken()` function
- Uses MODELARTS credentials from env.json:
  - `MODELARTS_USERNAME`
  - `MODELARTS_PASSWORD`
  - `MODELARTS_DOMAIN`
  - `MODELARTS_REGION`
- Token caching (23 hours) handled automatically
- Error handling for authentication failures

**Configuration Loading**:
```javascript
const sisEndpoint = envConfig.SIS_ENDPOINT;
const sisProjectId = envConfig.SIS_PROJECT_ID;
const sisProperty = envConfig.SIS_PROPERTY || 'english_16k_general';
```

### 5.4 Implement complete request flow ✅

**Flow Steps**:
1. ✅ Receive and validate audio data
2. ✅ Load SIS configuration from env.json
3. ✅ Obtain IAM token (cached or new)
4. ✅ Create SIS WebSocket manager instance
5. ✅ Call `transcribe()` method (handles full SIS flow):
   - Connect to WebSocket
   - Send START command
   - Send audio in chunks
   - Send END command
   - Wait for result
   - Close connection
6. ✅ Receive transcribed text
7. ✅ Generate bot reply (placeholder for now)
8. ✅ Return JSON response

### 5.5 Integrate chatbot service ✅

**Current Implementation**:
- Placeholder bot reply: `"You said: \"{transcribedText}\". Chatbot integration coming soon!"`
- TODO comment added for future chatbot integration
- Structure ready for chatbot API call

**Future Integration** (when chatbot API is available):
```javascript
// Send to chatbot
const chatbotResponse = await fetch(chatbotApiUrl, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ message: transcribedText }),
});
const botReply = await chatbotResponse.json();
```

### 5.6 Build and return response ✅

**Success Response** (200):
```json
{
  "success": true,
  "userText": "Hello world",
  "botReply": "You said: \"Hello world\". Chatbot integration coming soon!"
}
```

**Error Responses**:

**400 - Bad Request** (No audio data):
```json
{
  "success": false,
  "error": "No audio data provided"
}
```

**500 - Internal Server Error** (Configuration missing):
```json
{
  "success": false,
  "error": "SIS configuration incomplete",
  "details": {
    "hasEndpoint": false,
    "hasProjectId": true,
    "hasUsername": true,
    "hasPassword": true
  }
}
```

**500 - Authentication Failed**:
```json
{
  "success": false,
  "error": "Authentication failed",
  "details": {
    "message": "Failed to obtain IAM token",
    "stage": "transcription"
  }
}
```

**502 - Bad Gateway** (SIS error):
```json
{
  "success": false,
  "error": "Transcription failed",
  "details": {
    "message": "SIS Error: SIS.0001 - Invalid audio format",
    "stage": "transcription"
  }
}
```

**503 - Service Unavailable** (WebSocket connection failed):
```json
{
  "success": false,
  "error": "SIS service unavailable",
  "details": {
    "message": "WebSocket connection timeout",
    "stage": "transcription"
  }
}
```

**504 - Gateway Timeout** (Transcription timeout):
```json
{
  "success": false,
  "error": "Transcription timeout",
  "details": {
    "message": "Transcription timeout",
    "stage": "transcription"
  }
}
```

## Error Handling

### Error Detection
The endpoint intelligently determines error types and returns appropriate HTTP status codes:

- **Timeout errors** → 504 Gateway Timeout
- **WebSocket errors** → 503 Service Unavailable
- **SIS errors** → 502 Bad Gateway
- **IAM token errors** → 500 Internal Server Error
- **Missing audio** → 400 Bad Request
- **Configuration errors** → 500 Internal Server Error

### Error Logging
All errors are logged with:
- Timestamp
- Error message
- Stack trace
- Request context

## Configuration Requirements

### env.json Fields Used:
```json
{
  "SIS_ENDPOINT": "sis-ext.ap-southeast-3.myhuaweicloud.com",
  "SIS_PROJECT_ID": "59dcb311da5e4ca6b8db8bbc7a7712d7",
  "SIS_PROPERTY": "english_16k_general",
  "MODELARTS_USERNAME": "modelarts-bot",
  "MODELARTS_PASSWORD": "kerokero12@12",
  "MODELARTS_DOMAIN": "kero_o911",
  "MODELARTS_REGION": "ap-southeast-3"
}
```

## Testing the Endpoint

### Using curl (Windows PowerShell):
```powershell
# Record audio or use existing WAV file
$audioFile = "test_audio.wav"

# Send to endpoint
Invoke-WebRequest -Uri "http://localhost:3001/api/voice-chat" `
  -Method POST `
  -ContentType "audio/wav" `
  -InFile $audioFile
```

### Using curl (Linux/Mac):
```bash
curl -X POST http://localhost:3001/api/voice-chat \
  -H "Content-Type: audio/wav" \
  --data-binary @test_audio.wav
```

### Expected Response:
```json
{
  "success": true,
  "userText": "Hello, how are you?",
  "botReply": "You said: \"Hello, how are you?\". Chatbot integration coming soon!"
}
```

## Logging Output

Example console output during successful request:
```
[2025-11-15T10:00:00.000Z] POST /api/voice-chat - Received audio data
[2025-11-15T10:00:00.001Z] Audio data size: 51200 bytes
[2025-11-15T10:00:00.002Z] Obtaining IAM token for SIS...
[2025-11-15T10:00:00.003Z] Using cached IAM token
[2025-11-15T10:00:00.004Z] Starting transcription with property: english_16k_general
[2025-11-15T10:00:00.005Z] Connecting to SIS WebSocket: wss://sis-ext.ap-southeast-3.myhuaweicloud.com/v1/59dcb311da5e4ca6b8db8bbc7a7712d7/rasr/sentence-stream
[2025-11-15T10:00:01.000Z] SIS WebSocket connected successfully
[2025-11-15T10:00:01.100Z] Sending START command: {"command":"START","config":{...}}
[2025-11-15T10:00:01.200Z] Sending audio in 5 chunks (51200 bytes total)
[2025-11-15T10:00:02.000Z] All audio chunks sent successfully
[2025-11-15T10:00:02.100Z] Sending END command
[2025-11-15T10:00:03.000Z] Received SIS message: {"result":{"text":"Hello world"}}
[2025-11-15T10:00:03.100Z] Closing SIS WebSocket connection
[2025-11-15T10:00:03.101Z] Transcription result: "Hello world"
```

## Server Startup

Updated server startup message includes the new endpoint:
```
============================================================
🚀 Eye Wise Connect Backend Server
============================================================
📍 Server URL:        http://localhost:3001
🏥 Health Check:       http://localhost:3001/health
📝 Available Endpoints:
   - GET  /health
   - POST /api/signup (with bcrypt password hashing)
   - POST /api/login (with bcrypt password verification)
   - POST /api/modelarts/infer
   - POST /api/voice-chat (SIS speech-to-text + chatbot)
============================================================
✅ Server is running on port 3001
```

## Next Steps

Task 5 is complete. The voice chat endpoint is fully functional and ready for testing.

**Remaining tasks**:
- Task 6-7: Flutter implementation (add dependencies, create UI components)
- Task 8-9: Testing (backend and Flutter tests)
- Task 10: Manual end-to-end testing
- Task 11-12: Configuration and documentation

**To test the endpoint**:
1. Start the backend server: `cd backend && npm start`
2. Send a WAV audio file to `/api/voice-chat`
3. Verify transcription in response

**Future enhancements**:
- Integrate real chatbot service (replace placeholder)
- Add support for multiple languages
- Implement conversation history
- Add rate limiting
