import 'package:flutter/material.dart';
import '../presentation/pages/onboarding_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/library_page.dart';
import '../presentation/pages/mood_checkin_page.dart';
import '../presentation/pages/session_page.dart';
import '../presentation/pages/session_complete_page.dart';
import '../presentation/pages/history_page.dart';
import '../presentation/pages/settings_page.dart';
import '../presentation/pages/profile_page.dart';

/// Centralized navigation routes
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String library = '/library';
  static const String moodCheckIn = '/mood-check-in';
  static const String session = '/session';
  static const String sessionComplete = '/session-complete';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String profile = '/profile';

  /// Generate route based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case library:
        return MaterialPageRoute(
          builder: (_) => const LibraryPage(),
          settings: settings,
        );

      case moodCheckIn:
        return MaterialPageRoute(
          builder: (_) => const MoodCheckInPage(),
          settings: settings,
        );

      case session:
        return MaterialPageRoute(
          builder: (_) => const SessionPage(),
          settings: settings,
        );

      case sessionComplete:
        return MaterialPageRoute(
          builder: (_) => const SessionCompletePage(),
          settings: settings,
        );

      case history:
        return MaterialPageRoute(
          builder: (_) => const HistoryPage(),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
