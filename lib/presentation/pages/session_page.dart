import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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

class _SessionPageState extends State<SessionPage> with SingleTickerProviderStateMixin {
  bool _navigatedToComplete = false;
  late final AnimationController _unlockController;

  @override
  void initState() {
    super.initState();
    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _unlockController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact().catchError((_) {});
        context.read<BreathingProvider>().setStealthMode(false);
        _unlockController.reset();
      }
    });

    // Keep the screen awake for the duration of the session — a failure
    // here (e.g. denied by the platform) should never block the session.
    WakelockPlus.enable().catchError((_) {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BreathingProvider>().startSession();
    });
  }

  @override
  void dispose() {
    _unlockController.dispose();
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
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

    if (provider.isStealthMode) {
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
        child: _buildStealthCurtain(context, tokens, provider, timeText),
      );
    }

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
                          tooltip: 'Close session',
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
                          tooltip: storage.isSoundEnabled() ? 'Mute sound' : 'Unmute sound',
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
                        fontFamily: 'SpaceGrotesk',
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
                          Text(provider.ambienceTrack.label, style: TextStyle(fontSize: 12, color: tokens.muted)),
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
                          tooltip: storage.isVibrationEnabled() ? 'Haptics enabled' : 'Haptics disabled',
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
                        _circleIconButton(
                          context,
                          icon: Icons.shield_moon_outlined,
                          tooltip: 'Pocket / Stealth mode',
                          color: tokens.neon,
                          onTap: () {
                            provider.setStealthMode(true);
                          },
                        ),
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

  /// OLED Pure-Black Stealth Curtain for pocket use without visual glare or accidental touches
  Widget _buildStealthCurtain(
    BuildContext context,
    NeonTokens tokens,
    BreathingProvider provider,
    String timeText,
  ) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        _unlockController.forward();
      },
      onPointerUp: (_) {
        if (_unlockController.status != AnimationStatus.completed) {
          _unlockController.reverse();
        }
      },
      onPointerCancel: (_) {
        _unlockController.reverse();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top status bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.neon.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'POCKET STEALTH MODE',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 11,
                            letterSpacing: 1.8,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),

                // Center subtle breathing guide
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      width: provider.currentPhase == BreathingPhase.inhale
                          ? 96
                          : (provider.currentPhase == BreathingPhase.hold ? 84 : 64),
                      height: provider.currentPhase == BreathingPhase.inhale
                          ? 96
                          : (provider.currentPhase == BreathingPhase.hold ? 84 : 64),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.neon.withOpacity(
                          provider.currentPhase == BreathingPhase.inhale
                              ? 0.14
                              : (provider.currentPhase == BreathingPhase.hold ? 0.20 : 0.06),
                        ),
                        border: Border.all(
                          color: tokens.neon.withOpacity(0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.vibration,
                          color: tokens.neon.withOpacity(0.5),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      provider.currentPhase.displayText.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 22,
                        letterSpacing: 3.2,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Haptic pulses guiding your breath · Audio muted',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Bottom hold-to-unlock widget with touch protection
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _unlockController,
                      builder: (context, _) {
                        final progress = _unlockController.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 68,
                              height: 68,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(tokens.neon),
                              ),
                            ),
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05 + progress * 0.15),
                              ),
                              child: Icon(
                                progress > 0.8 ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                                color: progress > 0.8 ? tokens.neon : Colors.white.withOpacity(0.4),
                                size: 22,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Press and hold screen for 1.5s to unlock',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () async {
                        final shouldPop = await _showExitDialog(context);
                        if (shouldPop == true && context.mounted) {
                          await provider.stopSession();
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'End session',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? color,
  }) {
    final tokens = NeonTokens.of(context);
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: tokens.glass.withOpacity(0.07),
          shape: BoxShape.circle,
          border: Border.all(color: (color ?? tokens.fg).withOpacity(0.14)),
        ),
        child: Icon(icon, size: 18, color: color ?? tokens.muted),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
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
