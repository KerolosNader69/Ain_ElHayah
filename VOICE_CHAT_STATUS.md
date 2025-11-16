# Voice Chat Status - Current Issue

## ✅ What's Working

1. **Voice Button Visible**: The microphone button now appears on the web chatbot page
2. **Recording Works**: Audio is being captured (619,380 bytes recorded)
3. **Backend Connection**: Audio successfully sent to backend server
4. **SIS Connection**: Backend connects to SIS WebSocket service

## ❌ Current Issue

**Error**: `SIS Error: SIS.0032 - 'command' is invalid`

**What This Means**: The SIS service is rejecting the command format being sent from the backend.

## 🔍 Analysis

### Error Details from Console:
```
Audio data size: 619380 bytes
Sending audio to backend: http://localhost:3001/api/voice-chat
Response status: 502
Response body: {"success":false,"error":"Transcription failed","details":{"message":"SIS Error: SIS.0032 - 'command' is invalid","stage":"transcription"}}
```

### Possible Causes:

1. **Audio Format Mismatch**: 
   - Web browser records in WAV format
   - SIS expects PCM 16kHz 16-bit mono
   - The WAV file might have headers that SIS doesn't expect

2. **Command Format Issue**:
   - SIS might expect a different command structure
   - The WebSocket protocol might have changed

3. **Audio Data Encoding**:
   - Base64 encoding might be incorrect
   - Audio chunks might be too large

## 🔧 Recommended Solutions

### Solution 1: Strip WAV Headers (Recommended)

SIS expects raw PCM data, but browsers record WAV files with headers. We need to strip the WAV header before sending to SIS.

**Implementation**:
```javascript
// In backend/server.js, before sending to SIS:
function stripWavHeader(wavBuffer) {
  // WAV header is typically 44 bytes
  // Check if it's a valid WAV file
  if (wavBuffer.length > 44 && 
      wavBuffer.toString('utf8', 0, 4) === 'RIFF' &&
      wavBuffer.toString('utf8', 8, 12) === 'WAVE') {
    // Strip the 44-byte header
    return wavBuffer.slice(44);
  }
  return wavBuffer; // Return as-is if not WAV
}

// Use it before SIS transcription:
const pcmData = stripWavHeader(req.body);
const transcribedText = await sisManager.transcribe(pcmData, sisProperty);
```

### Solution 2: Use Different Audio Format

Configure the recorder to output raw PCM instead of WAV:

**Flutter Side**:
```dart
const config = RecordConfig(
  encoder: AudioEncoder.pcm16bits, // Use PCM instead of WAV
  sampleRate: 16000,
  numChannels: 1,
);
```

**Note**: This might not work on web as browsers typically output WAV.

### Solution 3: Verify SIS Configuration

Check if the SIS endpoint and project ID are correct:

```bash
# In env.json, verify:
SIS_ENDPOINT: "sis-ext.ap-southeast-3.myhuaweicloud.com"
SIS_PROJECT_ID: "59dcb311da5e4ca6b8db8bbc7a7712d7"
SIS_PROPERTY: "english_16k_general"
```

## 📝 Next Steps

### Immediate Fix (Recommended):

1. **Add WAV header stripping** to `backend/server.js`
2. **Test with stripped audio** to see if SIS accepts it
3. **Check backend logs** for SIS WebSocket communication details

### Code to Add:

In `backend/server.js`, find the voice chat endpoint and add:

```javascript
// Add this function at the top of the file
function stripWavHeader(buffer) {
  // Check if it's a WAV file (starts with 'RIFF' and contains 'WAVE')
  if (buffer.length > 44 && 
      buffer.toString('utf8', 0, 4) === 'RIFF' &&
      buffer.toString('utf8', 8, 12) === 'WAVE') {
    console.log(`[${new Date().toISOString()}] Stripping WAV header (44 bytes)`);
    console.log(`[${new Date().toISOString()}] Original size: ${buffer.length} bytes`);
    const pcmData = buffer.slice(44);
    console.log(`[${new Date().toISOString()}] PCM data size: ${pcmData.length} bytes`);
    return pcmData;
  }
  console.log(`[${new Date().toISOString()}] No WAV header detected, using buffer as-is`);
  return buffer;
}

// Then in the /api/voice-chat endpoint, before transcription:
const pcmAudio = stripWavHeader(req.body);
const transcribedText = await sisManager.transcribe(pcmAudio, sisProperty);
```

## 🧪 Testing After Fix

1. **Restart backend**: `node backend/server.js`
2. **Refresh Flutter web app**: Ctrl+R in browser
3. **Try voice recording** again
4. **Check backend console** for:
   - "Stripping WAV header" message
   - PCM data size (should be ~44 bytes less)
   - SIS WebSocket messages

## 📊 Expected Results

After fixing:
```
✅ Audio data size: 619380 bytes
✅ Stripping WAV header (44 bytes)
✅ PCM data size: 619336 bytes
✅ SIS WebSocket connected successfully
✅ Transcription result: "your spoken text here"
✅ Bot reply: "AI response here"
```

## 🆘 Alternative: Test with Mobile

If web continues to have issues, test on mobile where the audio format is more reliable:

```bash
# Run on Android emulator
flutter run

# Or on physical device
flutter run -d <device-id>
```

Mobile apps have better control over audio format and typically work more reliably with SIS.

---

**Current Status**: Voice recording works, but SIS rejects the audio format  
**Priority**: HIGH - Add WAV header stripping to backend  
**ETA**: 5-10 minutes to implement and test
