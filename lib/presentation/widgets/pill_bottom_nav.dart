import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../routes/app_routes.dart';

enum NavTab { breathe, history, library, you }

/// The glass pill tab bar shown at the bottom of every top-level screen
/// (Home, History, Library, Profile) in the neon direction.
class PillBottomNav extends StatelessWidget {
  final NavTab active;

  const PillBottomNav({super.key, required this.active});

  static const _routes = {
    NavTab.breathe: AppRoutes.home,
    NavTab.history: AppRoutes.history,
    NavTab.library: AppRoutes.library,
    NavTab.you: AppRoutes.profile,
  };

  void _go(BuildContext context, NavTab tab) {
    if (tab == active) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      _routes[tab]!,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: tokens.isDark
                  ? tokens.cardBg.withOpacity(0.7)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: tokens.line.withOpacity(0.12)),
              boxShadow: tokens.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: tokens.fg.withOpacity(0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _item(context, NavTab.breathe, Icons.blur_circular, 'Breathe'),
                _item(context, NavTab.history, Icons.calendar_month_outlined, 'History'),
                _item(context, NavTab.library, Icons.menu_book_outlined, 'Library'),
                _item(context, NavTab.you, Icons.person_outline, 'You'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, NavTab tab, IconData icon, String label) {
    final tokens = NeonTokens.of(context);
    final isActive = tab == active;
    final color = isActive ? tokens.neon : tokens.muted;
    return GestureDetector(
      onTap: () => _go(context, tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              letterSpacing: 0.4,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
