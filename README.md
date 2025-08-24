# EyeWise Connect - Flutter App

A modern Flutter application for AI-powered eye diagnosis and health assistance. This app provides advanced eye health screening using AI models, connects users with eye care specialists, and offers an intelligent chat assistant for eye health queries.

## Features

- **AI Eye Diagnosis**: Upload retinal or selfie images for instant AI-powered analysis
- **Doctor Finder**: Search and connect with qualified ophthalmologists in your area
- **AI Health Assistant**: Chat with an intelligent assistant for eye health questions
- **Voice Support**: Speech-to-text and text-to-speech capabilities
- **Responsive Design**: Works seamlessly on mobile, tablet, and desktop

## Screenshots

[Add screenshots here]

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd eye-wise-connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Ensure Android SDK is installed
- Set up Android emulator or connect physical device
- Run `flutter run` for Android

#### iOS (macOS only)
- Install Xcode
- Set up iOS Simulator or connect physical device
- Run `flutter run` for iOS

#### Web
- Run `flutter run -d chrome` for web development

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme/
│   └── app_theme.dart        # Theme configuration
├── routes/
│   └── app_router.dart       # Navigation setup
├── providers/
│   ├── app_provider.dart     # Global app state
│   ├── chat_provider.dart    # Chat functionality
│   └── diagnosis_provider.dart # AI diagnosis state
├── screens/
│   ├── home_screen.dart      # Home page
│   ├── diagnosis_screen.dart # AI diagnosis
│   ├── doctors_screen.dart   # Doctor finder
│   ├── chat_screen.dart      # AI assistant
│   └── not_found_screen.dart # 404 page
└── widgets/
    └── app_header.dart       # Navigation header
```

## Dependencies

### Core Dependencies
- `flutter`: Flutter framework
- `provider`: State management
- `go_router`: Navigation
- `google_fonts`: Typography

### UI & UX
- `flutter_svg`: SVG support
- `cached_network_image`: Image caching
- `shimmer`: Loading animations

### Functionality
- `image_picker`: Image selection
- `speech_to_text`: Voice input
- `flutter_tts`: Text-to-speech
- `camera`: Camera access
- `permission_handler`: Permissions

### Data & Storage
- `shared_preferences`: Local storage
- `http`: HTTP requests
- `dio`: Advanced HTTP client

## Features in Detail

### AI Diagnosis
- **Retinal Analysis**: Professional retinal imaging analysis
- **Selfie Analysis**: Smartphone-friendly eye screening
- **Real-time Processing**: Live progress updates
- **Detailed Reports**: Comprehensive findings and recommendations

### Doctor Finder
- **Search & Filter**: Find specialists by location and specialty
- **Profile Cards**: Detailed doctor information
- **Booking System**: Schedule appointments
- **Reviews & Ratings**: Patient feedback

### AI Assistant
- **Natural Language**: Conversational interface
- **Voice Support**: Speech input and output
- **Health Guidance**: Eye health advice and information
- **Appointment Booking**: Integration with doctor finder

## Architecture

The app follows a clean architecture pattern with:

- **Presentation Layer**: Screens and widgets
- **Business Logic Layer**: Providers and services
- **Data Layer**: Models and repositories

### State Management
Uses Provider pattern for state management:
- `AppProvider`: Global app state (theme, loading)
- `ChatProvider`: Chat functionality and messages
- `DiagnosisProvider`: AI diagnosis state and results

### Navigation
Uses GoRouter for declarative routing with:
- Named routes
- Deep linking support
- Error handling

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## Acknowledgments

- Flutter team for the amazing framework
- Google Fonts for typography
- Unsplash for placeholder images
- All contributors and maintainers
