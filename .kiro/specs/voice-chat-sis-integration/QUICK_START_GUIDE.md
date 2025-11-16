# Voice Chat Feature - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Start Backend (30 seconds)
```bash
cd backend
npm start
```

Wait for:
```
✅ Server is running on port 3001
   - POST /api/voice-chat (SIS speech-to-text + chatbot)
```

### Step 2: Configure Flutter (1 minute)

Open `lib/screens/voice_chat_demo_screen.dart`

**For Android Emulator**:
```dart
static const String backendUrl = 'http://10.0.2.2:3001';
```

**For Physical Device**:
1. Find your computer's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Update:
```dart
static const String backendUrl = 'http://192.168.1.X:3001'; // Replace X
```

### Step 3: Run App (2 minutes)
```bash
flutter run
```

### Step 4: Test Voice Chat (1 minute)
1. Navigate to Voice Chat Demo screen
2. **Long press** microphone button (turns red)
3. **Speak**: "Hello, how are you?"
4. **Release** button
5. Wait 3-5 seconds
6. See transcription and bot reply!

## ✅ Success Checklist

- [ ] Backend shows: `Server is running on port 3001`
- [ ] App requests microphone permission → Grant it
- [ ] Long press makes button red
- [ ] Release shows loading spinner
- [ ] Backend logs show: `Transcription result: "..."`
- [ ] Two messages appear in chat

## 🔧 Quick Fixes

### "Connection refused"
- ✅ Backend running? Check terminal
- ✅ Correct IP address? Check `ipconfig`
- ✅ Same WiFi? Device and computer must be on same network

### "Permission denied"
- ✅ Go to Settings → Apps → Eye Wise Connect → Permissions
- ✅ Enable Microphone
- ✅ Restart app

### "No transcription"
- ✅ Speak clearly and loudly
- ✅ Record for at least 1 second
- ✅ Check backend logs for errors

## 📱 Integration into Your App

### Add to Existing Chat Screen:

```dart
import 'package:eye_wise_connect/widgets/voice_chat_button.dart';

// In your input row:
Row(
  children: [
    Expanded(child: yourTextField),
    yourSendButton,
    VoiceChatButton(
      backendUrl: 'http://your-backend:3001',
      onResponse: (userText, botReply) {
        setState(() {
          messages.add(Message(text: userText, isUser: true));
          messages.add(Message(text: botReply, isUser: false));
        });
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    ),
  ],
)
```

## 📚 Full Documentation

- **Complete Guide**: `IMPLEMENTATION_COMPLETE.md`
- **Testing Guide**: `TASK12_PERMISSIONS_AND_TESTING_GUIDE.md`
- **Architecture**: `design.md`
- **Requirements**: `requirements.md`

## 🎯 What's Working

- ✅ Voice recording (WAV, 16kHz, mono)
- ✅ Backend API (`/api/voice-chat`)
- ✅ SIS transcription (Huawei Cloud)
- ✅ Error handling
- ✅ Chat UI with voice messages
- ✅ Secure architecture (no credentials in app)

## 🔜 Next Steps

1. **Test thoroughly** - Try different phrases, lengths, accents
2. **Integrate** - Add to your existing chat screens
3. **Customize** - Style button to match your app
4. **Enhance** - Add real chatbot integration

## 💡 Pro Tips

- **Clear speech** = Better transcription
- **Quiet environment** = Higher accuracy
- **1-10 seconds** = Optimal recording length
- **Check backend logs** = See what's happening

## 🆘 Need Help?

1. Check backend terminal for errors
2. Review `TASK12_PERMISSIONS_AND_TESTING_GUIDE.md`
3. Verify `env.json` configuration
4. Test with `curl`:
   ```bash
   curl http://localhost:3001/health
   ```

---

**Ready to go!** Start with Step 1 above. 🎤
