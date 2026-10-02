import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../data/models/mood.dart';
import '../../routes/app_routes.dart';
import '../providers/breathing_provider.dart';

/// A quick mood check-in shown before a session starts. Purely optional —
/// "Skip" moves on without recording anything.
class MoodCheckInPage extends StatefulWidget {
  const MoodCheckInPage({super.key});

  @override
  State<MoodCheckInPage> createState() => _MoodCheckInPageState();
}

class _MoodCheckInPageState extends State<MoodCheckInPage> {
  String? _selected;

  void _continue(BuildContext context) {
    context.read<BreathingProvider>().setMoodBefore(_selected);
    Navigator.of(context).pushReplacementNamed(AppRoutes.session);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: tokens.muted),
              ),
              const Spacer(),
              Text(
                'BEFORE WE BEGIN',
                style: TextStyle(fontSize: 11, letterSpacing: 2.4, color: tokens.neon),
              ),
              const SizedBox(height: 10),
              Text(
                'How are you\nfeeling right now?',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                  letterSpacing: -0.3,
                  color: tokens.fg,
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kMoods.map((mood) {
                  final selected = _selected == mood.label;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = mood.label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? tokens.neon.withOpacity(0.16) : tokens.glass.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? tokens.neon : tokens.line.withOpacity(0.25),
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mood.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: selected ? tokens.neon : tokens.fg,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
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
                  onPressed: () => _continue(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.neon,
                    foregroundColor: tokens.ink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(
                    _selected == null ? 'Skip' : 'Continue',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
