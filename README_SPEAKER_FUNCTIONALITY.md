# AI Chat Speaker Functionality

## Overview
The AI chat now includes comprehensive text-to-speech functionality that allows users to hear AI chatbot messages spoken aloud. This feature enhances accessibility and provides a more interactive experience.

## Features

### 1. Global Speaker Toggle
- **Location**: Header section of the chat screen
- **Function**: Master switch to enable/disable all AI speech
- **Visual Indicator**: Shows ON/OFF status with animated icon
- **Behavior**: When disabled, stops any current speech and prevents new speech

### 2. Automatic AI Message Speaking
- **Behavior**: AI messages are automatically spoken when received (if speaker is enabled)
- **Language Support**: Supports both English and Arabic
- **Smart Handling**: Stops previous speech before starting new speech

### 3. Individual Message Controls
- **Location**: Each AI message bubble
- **Speaker Button**: Click to hear specific message
- **Stop Button**: Click to stop current speech
- **Visual Feedback**: Shows speaking status with progress indicator

### 4. Language Switching
- **Supported Languages**: English (en-US) and Arabic (ar-EG)
- **Real-time Switching**: TTS language changes immediately when selected
- **Voice Recognition**: Speech-to-text also switches to selected language

### 5. Visual Indicators
- **Header Status**: Shows when AI is currently speaking
- **Message Status**: Individual message indicators during speech
- **Animated Icons**: Visual feedback for speaker states

## Usage

### Enabling/Disabling Speaker
1. Look for the "AI Speaker" section in the chat header
2. Click the speaker toggle to switch between ON/OFF
3. When OFF, no AI messages will be spoken

### Changing Language
1. Select your preferred language (English or Arabic)
2. Both TTS and speech recognition will switch to the selected language
3. AI messages will be spoken in the selected language

### Manual Message Speaking
1. Click the speaker icon on any AI message bubble
2. The message will be spoken immediately
3. Click the stop icon to stop the speech

### Testing the Speaker
1. Use the "Test Speaker" button in the quick actions
2. This will play a test message to verify functionality
3. Use the "Test Send" button to send a test message and hear the AI response

## Technical Implementation

### Dependencies
- `flutter_tts: ^3.8.5` - Text-to-speech functionality
- `speech_to_text: ^6.6.0` - Speech recognition (existing)

### Key Components
1. **ChatScreen**: Main UI with speaker controls
2. **ChatProvider**: Callback system for AI message notifications
3. **FlutterTTS**: Text-to-speech engine
4. **Animation Controllers**: Visual feedback animations

### State Management
- `_speakerEnabled`: Global speaker toggle state
- `_isSpeaking`: Current speaking status
- `_currentSpeakingText`: Currently spoken message
- `_currentLanguage`: Selected language for TTS

### Callback System
- ChatProvider notifies ChatScreen when AI messages are received
- Automatic speaking is triggered through the callback
- Manual speaking is handled through UI interactions

## Accessibility Features
- Visual indicators for all speaker states
- Easy-to-use toggle controls
- Individual message controls for precise control
- Language support for multiple regions
- Clear status messages and feedback

## Future Enhancements
- Voice speed control
- Voice pitch adjustment
- Multiple voice options
- Speech rate controls
- Background music/sound effects
- Speech queue management for multiple messages
