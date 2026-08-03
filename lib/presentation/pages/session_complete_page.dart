import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/constants.dart';
import '../../data/models/mood.dart';
import '../../routes/app_routes.dart';
import '../providers/breathing_provider.dart';

/// Session complete — congratulates the user, summarizes the session, and
/// asks how they feel now (stored against the session that was just saved).
class SessionCompletePage extends StatefulWidget {
  const SessionCompletePage({super.key});

  @override
  State<SessionCompletePage> createState() => _SessionCompletePageState();
}

class _SessionCompletePageState extends State<SessionCompletePage> {
  String? _selectedMood;

  Future<void> _finish(BuildContext context, {required bool startAgain}) async {
    final provider = context.read<BreathingProvider>();
    if (_selectedMood != null) {
      await provider.setMoodAfter(_selectedMood!);
    }
    provider.reset();
    if (!context.mounted) return;
    if (startAgain) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.moodCheckIn);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    final provider = context.watch<BreathingProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: tokens.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.neon.withOpacity(0.14),
                    border: Border.all(color: tokens.neon, width: 2),
                    boxShadow: [BoxShadow(color: tokens.neon.withOpacity(0.5), blurRadius: 34)],
                  ),
                  child: Icon(Icons.check, color: tokens.neon, size: 34),
                ).animate().scale(duration: 450.ms, curve: Curves.elasticOut),
                const SizedBox(height: 22),
                Text(
                  'Well done.',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: tokens.fg,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.sessionCompleteMessage,
                  style: TextStyle(fontSize: 14.5, color: tokens.muted, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  decoration: BoxDecoration(
                    color: tokens.glass.withOpacity(tokens.isDark ? 0.06 : 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tokens.line.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      _stat(tokens, '${provider.completedCycles}', 'cycles'),
                      _divider(tokens),
                      _stat(tokens, '${provider.selectedDuration}', 'minutes'),
                      _divider(tokens),
                      _stat(tokens, provider.technique.pattern, provider.technique.name),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'HOW DO YOU FEEL NOW?',
                  style: TextStyle(fontSize: 11, letterSpacing: 2, color: tokens.neon),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: kMoods.map((mood) {
                    final selected = _selectedMood == mood.label;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = mood.label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? tokens.neon.withOpacity(0.16) : tokens.glass.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: selected ? tokens.neon : tokens.line.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(mood.emoji, style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 6),
                            Text(mood.label, style: TextStyle(fontSize: 12.5, color: selected ? tokens.neon : tokens.fg)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () => _finish(context, startAgain: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.neon,
                      foregroundColor: tokens.ink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: const Text('Start again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => _finish(context, startAgain: false),
                    child: Text(AppConstants.goHome, style: TextStyle(color: tokens.muted, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(NeonTokens tokens, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontFamily: 'Space Grotesk', fontSize: 20, fontWeight: FontWeight.w500, color: tokens.fg),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: tokens.muted), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _divider(NeonTokens tokens) {
    return Container(width: 1, height: 32, color: tokens.fg.withOpacity(0.1));
  }
}
