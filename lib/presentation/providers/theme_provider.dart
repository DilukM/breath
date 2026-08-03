import 'package:flutter/material.dart';
import '../../data/storage/local_storage.dart';

/// Provider for managing app theme
class ThemeProvider extends ChangeNotifier {
  final LocalStorage _storage;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider(this._storage) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadTheme() async {
    final isDark = _storage.getThemeMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _storage.saveThemeMode(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.saveThemeMode(mode == ThemeMode.dark);
    notifyListeners();
  }
}
