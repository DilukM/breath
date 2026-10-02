import 'package:flutter/material.dart';
import '../../core/di/injector.dart';
import '../../core/theme/colors.dart';
import '../../data/storage/local_storage.dart';
import '../../routes/app_routes.dart';
import '../widgets/pill_bottom_nav.dart';

/// Profile — practice stats at a glance, and the way in to Settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    final storage = getIt<LocalStorage>();
    final streak = storage.getCurrentStreak();
    final sessions = storage.getTotalSessionsCount();
    final total = storage.getTotalDuration();
    final totalLabel = total.inHours > 0 ? '${total.inHours}h ${total.inMinutes % 60}m' : '${total.inMinutes}m';

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tokens.neon.withOpacity(0.14),
                              border: Border.all(color: tokens.neon, width: 2),
                              boxShadow: [BoxShadow(color: tokens.neon.withOpacity(0.4), blurRadius: 30)],
                            ),
                            child: Center(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: tokens.neon,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Your practice',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: tokens.fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        _statCard(tokens, '$streak', 'day streak'),
                        const SizedBox(width: 11),
                        _statCard(tokens, '$sessions', 'sessions'),
                        const SizedBox(width: 11),
                        _statCard(tokens, totalLabel, 'total time'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _linkTile(
                      tokens,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'Sound, haptics & theme',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                    ),
                    _linkTile(
                      tokens,
                      icon: Icons.menu_book_outlined,
                      title: 'Technique library',
                      subtitle: 'Browse breathing rhythms',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.library),
                    ),
                    _linkTile(
                      tokens,
                      icon: Icons.calendar_month_outlined,
                      title: 'History',
                      subtitle: 'Streaks, stats & sessions',
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.history),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const PillBottomNav(active: NavTab.you),
          ],
        ),
      ),
    );
  }

  Widget _statCard(NeonTokens tokens, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: tokens.glass.withOpacity(tokens.isDark ? 0.05 : 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.fg.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 20, fontWeight: FontWeight.w500, color: tokens.neon),
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10.5, color: tokens.muted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _linkTile(
    NeonTokens tokens, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.glass.withOpacity(tokens.isDark ? 0.05 : 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.fg.withOpacity(0.06)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: tokens.neon),
        title: Text(title, style: TextStyle(color: tokens.fg, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: tokens.muted, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: tokens.muted),
      ),
    );
  }
}
