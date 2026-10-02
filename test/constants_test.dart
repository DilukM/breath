import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_breathing/core/utils/constants.dart';

void main() {
  test('appTitle matches the published product name', () {
    // Regression guard: the app is listed as "Mindful Breathing" in the
    // Play Store, Android manifest, and iOS Info.plist. If this drifts,
    // the in-app title (main.dart, onboarding, home) silently drifts too.
    expect(AppConstants.appTitle, 'Mindful Breathing');
  });

  test('BreathingPhase.displayText covers every phase', () {
    expect(BreathingPhase.ready.displayText, AppConstants.getReady);
    expect(BreathingPhase.inhale.displayText, AppConstants.breatheIn);
    expect(BreathingPhase.hold.displayText, AppConstants.hold);
    expect(BreathingPhase.exhale.displayText, AppConstants.breatheOut);
    expect(BreathingPhase.complete.displayText, AppConstants.sessionComplete);
  });
}
