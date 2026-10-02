# 🌬️ Mindful Breathing - Relaxation Timer

A beautiful Flutter app that helps users practice mindful breathing using smooth animations, timers, and soothing color transitions.

<div align="center">
  
  ![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
  ![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
  ![License](https://img.shields.io/badge/License-MIT-green)
  
</div>

## ✨ Features

- 🎯 **Guided Breathing Sessions** - Choose from 1, 3, 5, or 10-minute sessions
- 🎨 **Beautiful Animations** - Smooth expanding/contracting circle animations with `flutter_animate`
- 🌗 **Light & Dark Themes** - Calming color palettes optimized for both modes
- 📱 **Haptic Feedback** - Gentle vibrations mark phase transitions
- 🔊 **Audio Cues** - Optional breathing sound effects (coming soon)
- 💾 **Session History** - Track your breathing sessions with Hive local storage
- 🏗️ **Clean Architecture** - Well-organized codebase with dependency injection

## 🎨 Design Philosophy

The app follows a **calming minimal aesthetic** with:
- Soft gradients and gentle animations
- No harsh contrasts
- Smooth phase transitions
- Clean typography using **Google Fonts** (Poppins & Lato)

### Color Palette

| Purpose    | Light Theme       | Dark Theme        |
|------------|-------------------|-------------------|
| Background | `#E8F5E9` (mint)  | `#0A0F0D` (deep teal) |
| Primary    | `#4DB6AC` (teal)  | `#80CBC4` (aqua)  |
| Accent     | `#FFB74D` (soft orange) | `#FFD54F` (warm yellow) |
| Text       | `#1B1B1B`         | `#E0F2F1`         |

## 🏗️ Architecture

```
lib/
 ├── main.dart
 ├── core/
 │    ├── di/
 │    │    └── injector.dart          # Dependency injection with get_it
 │    ├── theme/
 │    │    ├── app_theme.dart         # Light and dark themes
 │    │    └── colors.dart            # Color palette
 │    └── utils/
 │         └── constants.dart         # App constants
 ├── data/
 │    ├── models/
 │    │    └── breathing_session.dart # Session data model
 │    └── storage/
 │         └── local_storage.dart     # Hive implementation
 ├── presentation/
 │    ├── providers/
 │    │    └── breathing_provider.dart # State management
 │    ├── pages/
 │    │    ├── home_page.dart          # Main screen
 │    │    └── session_page.dart       # Active session
 │    └── widgets/
 │         ├── breathing_circle.dart   # Animated circle
 │         └── timer_display.dart      # Timer & instructions
 └── routes/
      └── app_routes.dart              # Navigation
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd breath
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Optional: Generate Hive Adapters

If you modify the `breathing_session.dart` model, regenerate the adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📦 Dependencies

### Core
- **provider** `^6.1.1` - State management
- **get_it** `^8.0.2` - Dependency injection
- **hive** `^2.2.3` & **hive_flutter** `^1.1.0` - Local storage

### UI & Animations
- **google_fonts** `^6.2.1` - Beautiful typography
- **flutter_animate** `^4.5.0` - Smooth animations

### Optional Features
- **vibration** `^2.0.0` - Haptic feedback
- **audioplayers** `^6.1.0` - Sound effects

## 🧘 How It Works

### Breathing Cycle

Each breathing cycle consists of three phases:
1. **Inhale** (4 seconds) - Breathe in slowly through your nose
2. **Hold** (4 seconds) - Hold your breath gently
3. **Exhale** (6 seconds) - Breathe out slowly through your mouth

The app uses the **4-4-6 breathing technique**, proven to reduce stress and promote relaxation.

### State Management

The app uses **Provider** for state management:
- `BreathingProvider` handles session state, timing, and phase transitions
- Notifies UI on phase changes
- Uses `Timer.periodic()` for precise timing

### Dependency Injection

**get_it** manages dependencies:
- `LocalStorage` registered as singleton
- `BreathingProvider` registered as factory

## 🎯 UI Flow

1. **Home Page**
   - App title and description
   - Duration selector (1, 3, 5, 10 minutes)
   - Start session button
   - Theme toggle

2. **Session Page**
   - Expanding/contracting circle animation
   - Phase instructions ("Breathe In", "Hold", "Breathe Out")
   - Countdown timer with progress indicator
   - End session button

3. **Completion Dialog**
   - Congratulations message
   - Session statistics
   - Options to restart or return home

## 🔊 Adding Audio (Optional)

1. Add audio files to `assets/sounds/`:
   - `inhale.mp3`
   - `exhale.mp3`

2. Uncomment audio code in `breathing_provider.dart` (lines marked with comments)

3. Ensure `pubspec.yaml` includes the assets (already configured)

## 🎨 Customization

### Adjust Breathing Timings

Edit `lib/core/utils/constants.dart`:

```dart
static const int defaultInhaleDuration = 4;  // seconds
static const int defaultHoldDuration = 4;    // seconds
static const int defaultExhaleDuration = 6;  // seconds
```

### Customize Colors

Edit `lib/core/theme/colors.dart` to change the color palette.

### Add More Durations

Edit the `sessionDurations` list in `constants.dart`:

```dart
static const List<int> sessionDurations = [1, 3, 5, 10, 15];
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ⚠️ Web (limited - vibration not supported)
- ⚠️ Desktop (limited - vibration not supported)

## 🐛 Known Issues

- Audio playback requires actual audio files in `assets/sounds/`
- Vibration requires physical device testing (won't work in simulators)

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All open-source package contributors
- The mindfulness community for breathing techniques

---

<div align="center">
  Made with ❤️ and Flutter
  <br/>
  <em>Take a deep breath. You've got this.</em>
</div>

