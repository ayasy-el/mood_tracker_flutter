# Mood Tracker Flutter App

A Flutter application for tracking your daily moods using either camera-based detection or manual selection.

## Features

- Camera-based mood detection
- Manual mood selection with intensity slider
- Beautiful and modern UI
- Real-time mood tracking
- Support for multiple mood types (Happy, Sad, Angry, Neutral, Excited)

## Prerequisites

Before running the app, make sure you have the following installed:

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- For iOS development: Xcode (Mac only)
- For Android development: Android SDK

## Getting Started

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd mood_tracker_flutter
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── constants/
│   ├── colors.dart
│   └── layout.dart
├── models/
│   └── mood.dart
├── screens/
│   └── mood_check_in_screen.dart
├── widgets/
│   ├── mood_detector.dart
│   └── mood_selector.dart
└── main.dart
```

## Dependencies

- camera: For accessing device camera
- google_fonts: For custom typography
- provider: For state management
- shared_preferences: For local storage
- flutter_bloc: For state management
- equatable: For value comparison
- path_provider: For file system access

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
