import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/di/injector.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/colors.dart';
import '../../data/storage/local_storage.dart';
import '../providers/breathing_provider.dart';
import '../providers/theme_provider.dart';

/// Settings — sound, haptics, and theme. Reuses the app's existing Hive
/// [LocalStorage] setting methods rather than introducing a new store.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final LocalStorage _storage = getIt<LocalStorage>();

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: tokens.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: tokens.fg),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: tokens.fg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _sectionLabel(tokens, 'SESSION'),
                    _switchTile(
                      tokens,
                      icon: Icons.volume_up_outlined,
                      title: 'Sound',
                      subtitle: 'Ambient sound during sessions',
                      value: _storage.isSoundEnabled(),
                      onChanged: (v) async {
                        await _storage.setSoundEnabled(v);
                        setState(() {});
                      },
                    ),
                    _switchTile(
                      tokens,
                      icon: Icons.vibration,
                      title: 'Haptics',
                      subtitle: 'Vibrate on phase changes',
                      value: _storage.isVibrationEnabled(),
                      onChanged: (v) async {
                        await _storage.setVibrationEnabled(v);
                        setState(() {});
                      },
                    ),
                    _switchTile(
                      tokens,
                      icon: Icons.shield_moon_outlined,
                      title: 'Pocket / Stealth mode',
                      subtitle: 'Silent sessions with tactile guidance & pocket lock',
                      value: _storage.isStealthModeEnabled(),
                      onChanged: (v) async {
                        await _storage.setStealthModeEnabled(v);
                        if (context.mounted) {
                          context.read<BreathingProvider>().setStealthMode(v);
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    _sectionLabel(tokens, 'REMINDERS'),
                    _switchTile(
                      tokens,
                      icon: Icons.notifications_none_outlined,
                      title: 'Daily reminder',
                      subtitle: 'Gentle on-device reminder to pause and breathe',
                      value: _storage.isReminderEnabled(),
                      onChanged: (enabled) async {
                        if (enabled) {
                          final granted = await getIt<NotificationService>().requestPermissions();
                          if (!granted && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enable notifications in system settings')),
                            );
                          }
                          await _storage.setReminderEnabled(true);
                          await getIt<NotificationService>().scheduleDailyReminder(
                            hour: _storage.getReminderHour(),
                            minute: _storage.getReminderMinute(),
                          );
                        } else {
                          await _storage.setReminderEnabled(false);
                          await getIt<NotificationService>().cancelDailyReminder();
                        }
                        setState(() {});
                      },
                    ),
                    if (_storage.isReminderEnabled())
                      _timePickerTile(
                        tokens,
                        icon: Icons.access_time_rounded,
                        title: 'Reminder time',
                        hour: _storage.getReminderHour(),
                        minute: _storage.getReminderMinute(),
                        onTap: () async {
                          final currentHour = _storage.getReminderHour();
                          final currentMinute = _storage.getReminderMinute();
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: tokens.neon,
                                    onPrimary: tokens.ink,
                                    surface: tokens.bg,
                                    onSurface: tokens.fg,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            await _storage.setReminderTime(picked.hour, picked.minute);
                            await getIt<NotificationService>().scheduleDailyReminder(
                              hour: picked.hour,
                              minute: picked.minute,
                            );
                            setState(() {});
                          }
                        },
                      ),
                    const SizedBox(height: 10),
                    _sectionLabel(tokens, 'APPEARANCE'),
                    _switchTile(
                      tokens,
                      icon: themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      title: 'Dark mode',
                      subtitle: 'Neon on near-black, or daylight',
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                    const SizedBox(height: 10),
                    _sectionLabel(tokens, 'ABOUT'),
                    _linkTile(
                      tokens,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _openPrivacyPolicy(),
                    ),
                    _linkTile(
                      tokens,
                      icon: Icons.health_and_safety_outlined,
                      title: 'Health disclaimer',
                      onTap: () => _showDisclaimer(context, tokens),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text('Version 1.0.3', style: TextStyle(fontSize: 12, color: tokens.muted)),
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

  Widget _sectionLabel(NeonTokens tokens, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text, style: TextStyle(fontSize: 11, letterSpacing: 1.6, color: tokens.neon)),
    );
  }

  Widget _switchTile(
    NeonTokens tokens, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.glass.withOpacity(tokens.isDark ? 0.05 : 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.fg.withOpacity(0.06)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: value,
        onChanged: onChanged,
        activeThumbColor: tokens.ink,
        activeTrackColor: tokens.neon,
        secondary: Icon(icon, color: tokens.muted),
        title: Text(title, style: TextStyle(color: tokens.fg, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: tokens.muted, fontSize: 12)),
      ),
    );
  }

  Widget _timePickerTile(
    NeonTokens tokens, {
    required IconData icon,
    required String title,
    required int hour,
    required int minute,
    required VoidCallback onTap,
  }) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    final formattedTime = '$displayHour:$displayMinute $period';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.glass.withOpacity(tokens.isDark ? 0.05 : 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.fg.withOpacity(0.06)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: tokens.muted),
        title: Text(title, style: TextStyle(color: tokens.fg, fontWeight: FontWeight.w500)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.neon.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: tokens.neon.withOpacity(0.35)),
          ),
          child: Text(
            formattedTime,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: tokens.neon,
            ),
          ),
        ),
      ),
    );
  }

  Widget _linkTile(NeonTokens tokens, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tokens.glass.withOpacity(tokens.isDark ? 0.05 : 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.fg.withOpacity(0.06)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: tokens.muted),
        title: Text(title, style: TextStyle(color: tokens.fg, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right, color: tokens.muted),
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://dilukm.github.io/breath/privacy-policy.html');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open privacy policy')),
        );
      }
    }
  }

  void _showDisclaimer(BuildContext context, NeonTokens tokens) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health disclaimer'),
        content: const Text(
          'This app is for relaxation and wellness purposes only. '
          'It is not intended to diagnose, treat, cure, or prevent any '
          'medical condition. Please consult a healthcare provider for '
          'medical advice.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
