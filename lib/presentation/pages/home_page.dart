import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/unsplash.dart';
import '../../data/models/ambience_track.dart';
import '../../routes/app_routes.dart';
import '../providers/breathing_provider.dart';
import '../widgets/glass_panel.dart';
import '../widgets/pill_bottom_nav.dart';
import '../widgets/remote_image.dart';

/// Home — glass rhythm/timer card over a night-forest photograph.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Late night';
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    if (hour < 21) return 'Evening';
    return 'Night';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    final provider = context.watch<BreathingProvider>();
    final cycleSeconds = provider.technique.inhaleSeconds +
        provider.technique.holdSeconds +
        provider.technique.exhaleSeconds;
    final totalSeconds = provider.selectedDuration * 60;
    final estimatedCycles = cycleSeconds > 0 ? (totalSeconds / cycleSeconds).round() : 0;

    return Scaffold(
      backgroundColor: tokens.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox(
            height: 470,
            width: double.infinity,
            child: const RemoteImage(url: UnsplashPhotos.nightForest),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 470,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tokens.bg.withOpacity(0.55),
                    tokens.bg.withOpacity(0.2),
                    tokens.bg,
                  ],
                  stops: const [0.0, 0.38, 0.92],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 470,
            child: DecoratedBox(decoration: BoxDecoration(color: tokens.bg)),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppConstants.appTitle,
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 18,
                                color: tokens.neon,
                                shadows: [Shadow(color: tokens.neon.withOpacity(0.6), blurRadius: 14)],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: tokens.glass.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: tokens.line.withOpacity(0.25)),
                                ),
                                child: Center(
                                  child: Text(
                                    'A',
                                    style: TextStyle(color: tokens.neon, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 68),
                        Text(
                          _greetingTime(),
                          style: TextStyle(fontSize: 12.5, letterSpacing: 2, color: tokens.muted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Let's take\na moment.",
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontWeight: FontWeight.w500,
                            fontSize: 34,
                            height: 1.06,
                            letterSpacing: -0.4,
                            color: tokens.fg,
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
                        const SizedBox(height: 24),
                        GlassPanel(
                          glowColor: tokens.neon,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'RHYTHM',
                                    style: TextStyle(fontSize: 11, letterSpacing: 2, color: tokens.muted),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.library),
                                    child: Text(
                                      'Change',
                                      style: TextStyle(fontSize: 12.5, color: tokens.neon2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    provider.technique.pattern,
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500,
                                      color: tokens.fg,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      provider.technique.name,
                                      style: TextStyle(fontSize: 13, color: tokens.muted),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _phaseBar(tokens.neon, 0.22, tokens.neon),
                                  const SizedBox(width: 5),
                                  _phaseBar(tokens.neon.withOpacity(0.28), 0.38),
                                  const SizedBox(width: 5),
                                  _phaseBar(tokens.neon2, 0.4, tokens.neon2),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                child: Divider(height: 1, color: tokens.fg.withOpacity(0.1)),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${provider.selectedDuration}',
                                    style: TextStyle(
                                      fontFamily: 'SpaceGrotesk',
                                      fontSize: 48,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                      color: tokens.neon,
                                      shadows: [Shadow(color: tokens.neon.withOpacity(0.5), blurRadius: 26)],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'min · $estimatedCycles cycles',
                                      style: TextStyle(fontSize: 13.5, color: tokens.muted),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: AppConstants.sessionDurations.map((d) {
                                  final selected = provider.selectedDuration == d;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        onTap: () => provider.setDuration(d),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: selected ? tokens.neon : tokens.glass.withOpacity(0.06),
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(
                                              color: selected ? Colors.transparent : tokens.line.withOpacity(0.2),
                                            ),
                                          ),
                                          child: Text(
                                            '$d',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: selected ? tokens.ink : tokens.fg,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => provider.toggleStealthMode(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: provider.isStealthMode ? tokens.neon.withOpacity(0.18) : tokens.glass.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: provider.isStealthMode ? tokens.neon.withOpacity(0.6) : tokens.fg.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  provider.isStealthMode ? Icons.shield_moon : Icons.shield_moon_outlined,
                                  size: 15,
                                  color: provider.isStealthMode ? tokens.neon : tokens.muted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  provider.isStealthMode ? 'Pocket Mode: On (Silent & Haptic)' : 'Pocket Mode: Off',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: provider.isStealthMode ? FontWeight.w600 : FontWeight.w400,
                                    color: provider.isStealthMode ? tokens.neon : tokens.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.moodCheckIn),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tokens.neon,
                              foregroundColor: tokens.ink,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.play_arrow, size: 22),
                                const SizedBox(width: 8),
                                const Text(
                                  'Start session',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 250.ms),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: kAmbienceTracks.map((track) {
                              final selected = provider.ambienceTrack.id == track.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 9),
                                child: GestureDetector(
                                  onTap: () => provider.setAmbience(track.id),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: selected ? tokens.neon.withOpacity(0.14) : tokens.glass.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: selected ? tokens.line.withOpacity(0.5) : tokens.fg.withOpacity(0.08),
                                      ),
                                    ),
                                    child: Text(
                                      track.label,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: selected ? tokens.neon : tokens.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const PillBottomNav(active: NavTab.breathe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseBar(Color color, double flex, [Color? glow]) {
    return Expanded(
      flex: (flex * 100).round(),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
          boxShadow: glow != null
              ? [BoxShadow(color: glow.withOpacity(0.7), blurRadius: 10)]
              : null,
        ),
      ),
    );
  }
}
