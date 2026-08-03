import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../data/models/breathing_technique.dart';
import '../providers/breathing_provider.dart';
import '../widgets/pill_bottom_nav.dart';
import '../widgets/remote_image.dart';

/// Library — pick a breathing rhythm. Daylight or dark, same neon logic.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    final provider = context.watch<BreathingProvider>();
    final active = provider.technique;
    final others = kBreathingTechniques.where((t) => t.id != active.id).toList();
    final gridItems = others.take(2).toList();
    final rowItems = others.skip(2).toList();

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RHYTHMS',
                      style: TextStyle(fontSize: 11, letterSpacing: 2.4, color: tokens.neon),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick your\nbreath.',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        height: 1.08,
                        letterSpacing: -0.3,
                        color: tokens.fg,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _HeroCard(technique: active, tokens: tokens),
                    if (gridItems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: gridItems
                            .map((t) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: t == gridItems.first ? 10 : 0,
                                    ),
                                    child: _GridCard(
                                      technique: t,
                                      onTap: () => provider.setTechnique(t.id),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                    for (final t in rowItems) ...[
                      const SizedBox(height: 12),
                      _RowCard(
                        technique: t,
                        tokens: tokens,
                        onTap: () => provider.setTechnique(t.id),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const PillBottomNav(active: NavTab.library),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final BreathingTechnique technique;
  final NeonTokens tokens;

  const _HeroCard({required this.technique, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 210,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RemoteImage(url: technique.imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [tokens.bg.withOpacity(0), tokens.bg.withOpacity(0.86)],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: tokens.neon.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [BoxShadow(color: tokens.neon.withOpacity(0.6), blurRadius: 22)],
                    ),
                    child: Text(
                      'IN USE',
                      style: TextStyle(fontSize: 10.5, letterSpacing: 1.2, color: tokens.ink, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    technique.name,
                    style: const TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    technique.description,
                    style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.78)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final BreathingTechnique technique;
  final VoidCallback onTap;

  const _GridCard({required this.technique, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 148,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RemoteImage(url: technique.imageUrl),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [tokens.bg.withOpacity(0), tokens.bg.withOpacity(0.88)],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 15,
                bottom: 13,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technique.pattern,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    Text(
                      technique.name,
                      style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.72)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  final BreathingTechnique technique;
  final NeonTokens tokens;
  final VoidCallback onTap;

  const _RowCard({required this.technique, required this.tokens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: tokens.glass.withOpacity(tokens.isDark ? 0.06 : 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: tokens.line.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: tokens.neon, width: 2),
                boxShadow: [BoxShadow(color: tokens.neon.withOpacity(0.4), blurRadius: 16)],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    technique.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: tokens.fg),
                  ),
                  Text(
                    technique.description,
                    style: TextStyle(fontSize: 12, color: tokens.muted),
                  ),
                ],
              ),
            ),
            if (technique.advanced)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: tokens.line.withOpacity(0.5)),
                ),
                child: Text('ADV', style: TextStyle(fontSize: 10, letterSpacing: 1, color: tokens.neon)),
              ),
          ],
        ),
      ),
    );
  }
}
