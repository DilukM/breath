import 'package:flutter/material.dart';
import '../../core/di/injector.dart';
import '../../core/theme/colors.dart';
import '../../data/models/breathing_technique.dart';
import '../../data/storage/local_storage.dart';
import '../widgets/glass_panel.dart';
import '../widgets/pill_bottom_nav.dart';

/// History — a lit heatmap of practice over the last 24 weeks, streak and
/// total stats, a weekly bar chart, and recent sessions. All computed from
/// the sessions actually stored in Hive.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const int _heatmapDays = 24 * 7;

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    final storage = getIt<LocalStorage>();

    final dailyMinutes = storage.getDailyMinutes(_heatmapDays);
    final days = dailyMinutes.keys.toList()..sort();
    final weekly = storage.getDailyMinutes(7);
    final weeklyDays = weekly.keys.toList()..sort();
    final maxWeekly = weekly.values.fold<int>(1, (m, v) => v > m ? v : m);
    final recent = storage.getSessionsDescending(limit: 4);

    final streak = storage.getCurrentStreak();
    final totalSessions = storage.getTotalSessionsCount();
    final totalDuration = storage.getTotalDuration();
    final totalLabel = totalDuration.inHours > 0
        ? '${totalDuration.inHours}h ${totalDuration.inMinutes % 60}m'
        : '${totalDuration.inMinutes}m';

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your year',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: tokens.fg,
                          ),
                        ),
                        Text('${DateTime.now().year}', style: TextStyle(fontSize: 12, color: tokens.neon)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: tokens.glass.withOpacity(tokens.isDark ? 0.045 : 0.7),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: tokens.fg.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: days.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 24,
                              mainAxisSpacing: 3.5,
                              crossAxisSpacing: 3.5,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              final minutes = dailyMinutes[days[index]] ?? 0;
                              return Container(
                                decoration: BoxDecoration(
                                  color: _heatColor(tokens, minutes),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text('LESS', style: TextStyle(fontSize: 9.5, letterSpacing: 1, color: tokens.muted)),
                              const SizedBox(width: 6),
                              for (final m in [0, 5, 15, 30, 45]) ...[
                                Container(
                                  width: 11,
                                  height: 11,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: _heatColor(tokens, m),
                                    borderRadius: BorderRadius.circular(3.5),
                                  ),
                                ),
                              ],
                              Text('MORE', style: TextStyle(fontSize: 9.5, letterSpacing: 1, color: tokens.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        _statCard(tokens, '$streak', 'streak', highlight: true),
                        const SizedBox(width: 11),
                        _statCard(tokens, '$totalSessions', 'sessions'),
                        const SizedBox(width: 11),
                        _statCard(tokens, totalLabel, 'total'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THIS WEEK',
                            style: TextStyle(fontSize: 11, letterSpacing: 1.6, color: tokens.muted),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 96,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: weeklyDays.map((day) {
                                final minutes = weekly[day] ?? 0;
                                final isToday = _isSameDay(day, DateTime.now());
                                final height = minutes == 0 ? 4.0 : 20 + (minutes / maxWeekly) * 60;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: height,
                                          decoration: BoxDecoration(
                                            color: isToday
                                                ? tokens.neon
                                                : tokens.neon.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(9),
                                            boxShadow: isToday
                                                ? [BoxShadow(color: tokens.neon.withOpacity(0.5), blurRadius: 16)]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _weekdayLetter(day.weekday),
                                          style: TextStyle(fontSize: 10, color: isToday ? tokens.fg : tokens.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('RECENT', style: TextStyle(fontSize: 11, letterSpacing: 1.6, color: tokens.muted)),
                    const SizedBox(height: 9),
                    if (recent.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No sessions yet — your first one will show up here.',
                          style: TextStyle(fontSize: 13, color: tokens.muted),
                        ),
                      )
                    else
                      ...recent.map((session) {
                        final technique = session.techniqueId != null ? techniqueById(session.techniqueId!) : null;
                        final moodTransition = session.moodBefore != null && session.moodAfter != null
                            ? '${session.moodBefore} → ${session.moodAfter}'
                            : (session.moodAfter ?? session.moodBefore ?? '');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: tokens.glass.withOpacity(tokens.isDark ? 0.05 : 0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: tokens.fg.withOpacity(0.06)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: tokens.neon.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: tokens.line.withOpacity(0.3)),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: tokens.neon,
                                        boxShadow: [BoxShadow(color: tokens.neon.withOpacity(0.7), blurRadius: 10)],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${technique?.name ?? 'Session'} · ${session.durationMinutes} min',
                                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: tokens.fg),
                                      ),
                                      Text(
                                        [
                                          _relativeDay(session.startTime),
                                          if (moodTransition.isNotEmpty) moodTransition,
                                        ].join(' · '),
                                        style: TextStyle(fontSize: 11.5, color: tokens.muted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const PillBottomNav(active: NavTab.history),
          ],
        ),
      ),
    );
  }

  Color _heatColor(NeonTokens tokens, int minutes) {
    if (minutes <= 0) return tokens.fg.withOpacity(tokens.isDark ? 0.06 : 0.08);
    if (minutes < 10) return tokens.neon.withOpacity(0.22);
    if (minutes < 20) return tokens.neon.withOpacity(0.45);
    if (minutes < 35) return tokens.neon.withOpacity(0.72);
    return tokens.neon;
  }

  Widget _statCard(NeonTokens tokens, String value, String label, {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        decoration: BoxDecoration(
          color: highlight ? tokens.neon.withOpacity(0.12) : tokens.glass.withOpacity(tokens.isDark ? 0.05 : 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: highlight ? tokens.line.withOpacity(0.4) : tokens.fg.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: highlight ? tokens.neon : tokens.fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: tokens.muted)),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayLetter(int weekday) => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1];

  String _relativeDay(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final diff = today.difference(day).inDays;
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'pm' : 'am';
    final timeText = '$hour:$minute $ampm';
    if (diff == 0) return 'Today $timeText';
    if (diff == 1) return 'Yesterday $timeText';
    if (diff < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[time.weekday - 1]} $timeText';
    }
    return '${time.month}/${time.day} $timeText';
  }
}
