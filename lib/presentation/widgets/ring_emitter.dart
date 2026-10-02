import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/constants.dart';

/// The breathing ring as a light emitter — concentric rings that bloom
/// outward and recede in sync with the current phase, with the phase name
/// and its per-phase countdown at the center.
class RingEmitter extends StatelessWidget {
  final BreathingPhase phase;
  final int phaseSecondsRemaining;
  final double size;

  const RingEmitter({
    super.key,
    required this.phase,
    required this.phaseSecondsRemaining,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    final scale = _scaleFor(phase);
    final duration = _durationFor(phase);

    final rings = [
      (size * 1.0, tokens.neon2.withOpacity(0.13), null),
      (size * 0.86, tokens.neon2, 1),
      (size * 0.68, tokens.neon, 1.5),
      (size * 0.46, tokens.neon, 2.0),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final ring in rings)
            _AnimatedRing(
              diameter: ring.$1,
              color: ring.$2,
              filled: ring.$1 == size * 0.46,
              scale: scale,
              duration: duration,
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phase.displayText.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                  color: tokens.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$phaseSecondsRemaining',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: tokens.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _scaleFor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
      case BreathingPhase.hold:
        return 1.0;
      case BreathingPhase.exhale:
        return 0.68;
      case BreathingPhase.ready:
      case BreathingPhase.complete:
        return 0.8;
    }
  }

  Duration _durationFor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return Duration(seconds: AppConstants.defaultInhaleDuration);
      case BreathingPhase.hold:
        return const Duration(milliseconds: 400);
      case BreathingPhase.exhale:
        return Duration(seconds: AppConstants.defaultExhaleDuration);
      case BreathingPhase.ready:
      case BreathingPhase.complete:
        return const Duration(seconds: 1);
    }
  }
}

class _AnimatedRing extends StatelessWidget {
  final double diameter;
  final Color color;
  final bool filled;
  final double scale;
  final Duration duration;

  const _AnimatedRing({
    required this.diameter,
    required this.color,
    required this.filled,
    required this.scale,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.75, end: scale),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? color : null,
              border: filled ? null : Border.all(color: color, width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.55), blurRadius: filled ? 46 : 26),
              ],
            ),
          ),
        );
      },
    );
  }
}
