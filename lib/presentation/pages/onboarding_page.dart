import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/di/injector.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/unsplash.dart';
import '../../data/storage/local_storage.dart';
import '../../routes/app_routes.dart';
import '../widgets/remote_image.dart';

/// First-launch screen — sets the "seen" flag in local storage and hands
/// off to Home. Shown once; skipped on subsequent launches.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _begin(BuildContext context) async {
    await getIt<LocalStorage>().setOnboardingSeen();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.dark;

    return Scaffold(
      backgroundColor: tokens.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RemoteImage(url: UnsplashPhotos.nightForest),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  tokens.bg.withOpacity(0.35),
                  tokens.bg.withOpacity(0.55),
                  tokens.bg.withOpacity(0.98),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: tokens.glass.withOpacity(0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.line.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: tokens.neon, width: 2.5),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 28),
                  Text(
                    'Still',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3.2,
                      color: tokens.neon,
                      shadows: [Shadow(color: tokens.neon.withOpacity(0.6), blurRadius: 14)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Let's take\na moment.",
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontWeight: FontWeight.w500,
                      fontSize: 44,
                      height: 1.06,
                      letterSpacing: -0.5,
                      color: tokens.fg,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.15, end: 0),
                  const SizedBox(height: 14),
                  Text(
                    'Set a timer, pick a rhythm, and follow the ring. '
                    'A few minutes is enough to change how the rest of your day feels.',
                    style: TextStyle(fontSize: 15, height: 1.5, color: tokens.muted),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => _begin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.neon,
                        foregroundColor: tokens.ink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Begin',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
