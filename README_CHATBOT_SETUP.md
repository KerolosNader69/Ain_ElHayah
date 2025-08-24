# Chatbot Integration Setup Guide

## Overview
Your AI chatbot from "D:\CahtBot-chatbot" has been successfully integrated into the Eye Wise Connect project. The chatbot uses Google's Generative AI (Gemini) to provide eye health assistance.

## Features Integrated
- ✅ Real AI-powered conversations using Gemini 1.5 Flash
- ✅ Bilingual support (Arabic/English)
- ✅ Image analysis for eye conditions
- ✅ Voice input/output (existing functionality preserved)
- ✅ Eye health focused responses
- ✅ Medical disclaimer integration

## Setup Instructions

### 1. Get Google AI API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the API key

### 2. Configure the API Key

#### Option A: Environment Variable (Recommended)
Set the environment variable before running the app:
```bash
# Windows
set GOOGLE_API_KEY=your_api_key_here
flutter run

# macOS/Linux
export GOOGLE_API_KEY=your_api_key_here
flutter run
```

#### Option B: Dart Define (Alternative)
Run the app with the API key as a parameter:
```bash
flutter run --dart-define=GOOGLE_API_KEY=your_api_key_here
```

### 3. Test the Integration
1. Run the app: `flutter run`
2. Navigate to the Chat section
3. Try sending a message like "Hello" or "I have red eyes"
4. Try uploading an eye image for analysis

## How It Works

### Text Messages
- Greetings are handled locally for fast response
- Eye-related questions are sent to Gemini AI
- Non-eye questions get a polite redirect message
- All responses end with medical disclaimers

### Image Analysis
- Upload eye images for AI analysis
- AI identifies potential eye conditions
- Provides brief explanations
- Always recommends professional consultation

### Bilingual Support
- Automatically detects Arabic/English
- Responds in the same language
- Supports RTL text direction

## Files Modified
- `lib/services/ai_chat_service.dart` - New AI service using your chatbot logic
- `lib/providers/chat_provider.dart` - Updated to support images and AI responses
- `lib/screens/chat_screen.dart` - Enhanced UI with image support
- `pubspec.yaml` - Added Google Generative AI dependency
- `assets/chatbot/` - Copied your chatbot assets

## Troubleshooting

### API Key Issues
- Ensure the API key is valid and has access to Gemini
- Check that the environment variable is set correctly
- Verify the API key has sufficient quota

### Image Issues
- Ensure camera/gallery permissions are granted
- Check that images are in supported formats (JPEG, PNG)

### Performance
- First AI response may take 2-3 seconds
- Subsequent responses are faster due to chat session
- Images are compressed to 85% quality for faster processing

## Security Notes
- API key is only used for AI communication
- No user data is stored permanently
- All medical advice includes professional consultation disclaimers

## Next Steps
1. Test with your API key
2. Customize the system prompts if needed
3. Add more specific eye health knowledge
4. Consider adding conversation history persistence

Your chatbot is now fully integrated and ready to use! 🎉
