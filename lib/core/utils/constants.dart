/// Duration values, text constants, and other app constants
class AppConstants {
  // Duration constants (in seconds)
  static const int defaultInhaleDuration = 4;
  static const int defaultHoldDuration = 4;
  static const int defaultExhaleDuration = 6;
  
  // Session durations (in minutes)
  static const List<int> sessionDurations = [1, 3, 5, 10];
  
  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 500);
  static const Duration breathingTransition = Duration(milliseconds: 800);
  
  // Text constants
  static const String appTitle = 'Breathe';
  static const String appDescription = 'Take a moment to calm your mind\nand find your peace';
  static const String startSession = 'Start Session';
  static const String endSession = 'End Session';
  static const String sessionComplete = 'Well done!';
  static const String sessionCompleteMessage = 'Take a moment to relax and notice how you feel.';
  static const String startAgain = 'Start Again';
  static const String goHome = 'Go Home';
  
  // Breathing phase text
  static const String breatheIn = 'Breathe In';
  static const String hold = 'Hold';
  static const String breatheOut = 'Breathe Out';
  static const String getReady = 'Get Ready';
  
  // Storage keys
  static const String sessionHistoryBox = 'session_history';
  static const String settingsBox = 'settings';
  
  // Settings keys
  static const String vibrationEnabledKey = 'vibration_enabled';
  static const String soundEnabledKey = 'sound_enabled';
  static const String themeKey = 'theme_mode';

  // Ambience options (decorative sound chips)
  static const List<String> ambienceOptions = ['Forest', 'Rain', 'Ocean', 'Drone'];
}

/// Breathing phases enum
enum BreathingPhase {
  ready,
  inhale,
  hold,
  exhale,
  complete,
}

/// Extension to get display text for breathing phases
extension BreathingPhaseExtension on BreathingPhase {
  String get displayText {
    switch (this) {
      case BreathingPhase.ready:
        return AppConstants.getReady;
      case BreathingPhase.inhale:
        return AppConstants.breatheIn;
      case BreathingPhase.hold:
        return AppConstants.hold;
      case BreathingPhase.exhale:
        return AppConstants.breatheOut;
      case BreathingPhase.complete:
        return AppConstants.sessionComplete;
    }
  }
  
  int get duration {
    switch (this) {
      case BreathingPhase.ready:
        return 3;
      case BreathingPhase.inhale:
        return AppConstants.defaultInhaleDuration;
      case BreathingPhase.hold:
        return AppConstants.defaultHoldDuration;
      case BreathingPhase.exhale:
        return AppConstants.defaultExhaleDuration;
      case BreathingPhase.complete:
        return 0;
    }
  }
}
