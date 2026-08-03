import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/di/injector.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/unsplash.dart';
import '../../data/storage/local_storage.dart';
import '../../routes/app_routes.dart';
import '../providers/breathing_provider.dart';
import '../widgets/remote_image.dart';
import '../widgets/ring_emitter.dart';

/// Active breathing session — the ring as a light emitter over a dimmed
/// photograph, with a live per-phase countdown at its center.
class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  bool _navigatedToComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BreathingProvider>().startSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    final provider = context.watch<BreathingProvider>();
    final storage = getIt<LocalStorage>();

    if (provider.currentPhase == BreathingPhase.complete && !_navigatedToComplete) {
      _navigatedToComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.sessionComplete);
      });
    }

    final minutes = provider.remainingTime ~/ 60;
    final seconds = provider.remainingTime % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog(context);
        if (shouldPop == true && context.mounted) {
          await provider.stopSession();
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: tokens.bg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.3,
              child: RemoteImage(url: UnsplashPhotos.darkWater),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.1),
                  radius: 0.9,
                  colors: [
                    tokens.neon.withOpacity(0.16),
                    tokens.bg.withOpacity(0.78),
                    tokens.bg.withOpacity(0.98),
                  ],
                  stops: const [0.0, 0.62, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circleIconButton(
                          context,
                          icon: Icons.close,
                          onTap: () async {
                            final shouldPop = await _showExitDialog(context);
                            if (shouldPop == true && context.mounted) {
                              await provider.stopSession();
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          },
                        ),
                        Text(
                          '${provider.technique.pattern} · round ${provider.completedCycles + 1}',
                          style: TextStyle(fontSize: 11, letterSpacing: 1.6, color: tokens.muted),
                        ),
                        _circleIconButton(
                          context,
                          icon: storage.isSoundEnabled() ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                          onTap: () async {
                            await storage.setSoundEnabled(!storage.isSoundEnabled());
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: RingEmitter(
                          phase: provider.currentPhase,
                          phaseSecondsRemaining: provider.phaseSecondsRemaining,
                        ),
                      ),
                    ),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 42,
                        fontWeight: FontWeight.w500,
                        color: tokens.fg,
                        shadows: [Shadow(color: tokens.neon.withOpacity(0.3), blurRadius: 24)],
                      ),
                    ),
                    Text(
                      'remaining',
                      style: TextStyle(fontSize: 12, letterSpacing: 1.4, color: tokens.muted),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        width: 200,
                        height: 3,
                        child: LinearProgressIndicator(
                          value: provider.progress,
                          backgroundColor: tokens.fg.withOpacity(0.1),
                          color: tokens.neon,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: tokens.glass.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: tokens.fg.withOpacity(0.08)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.graphic_eq, size: 14, color: tokens.neon),
                          const SizedBox(width: 8),
                          Text(provider.ambience, style: TextStyle(fontSize: 12, color: tokens.muted)),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1200.ms),
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _circleIconButton(
                          context,
                          icon: storage.isVibrationEnabled() ? Icons.vibration : Icons.mobile_off,
                          onTap: () async {
                            await storage.setVibrationEnabled(!storage.isVibrationEnabled());
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 22),
                        GestureDetector(
                          onTap: () async {
                            final shouldStop = await _showExitDialog(context);
                            if (shouldStop == true && context.mounted) {
                              await provider.stopSession();
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.neon,
                              boxShadow: [BoxShadow(color: tokens.neon.withOpacity(0.6), blurRadius: 40)],
                            ),
                            child: Icon(Icons.stop_rounded, color: tokens.ink, size: 30),
                          ),
                        ),
                        const SizedBox(width: 22),
                        _circleIconButton(context, icon: Icons.timer_outlined, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
    final tokens = NeonTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: tokens.glass.withOpacity(0.07),
          shape: BoxShape.circle,
          border: Border.all(color: tokens.fg.withOpacity(0.12)),
        ),
        child: Icon(icon, size: 18, color: tokens.muted),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End session?', style: theme.textTheme.headlineMedium),
        content: Text(
          'Are you sure you want to end this breathing session?',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Continue', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('End session', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
