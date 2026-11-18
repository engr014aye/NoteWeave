import 'package:flutter/material.dart';
import '../services/storage_service.dart';

enum AppTextSize {
  compact,
  standard,
  large;

  double get scaleFactor {
    switch (this) {
      case AppTextSize.compact:
        return 0.90;
      case AppTextSize.standard:
        return 1.0;
      case AppTextSize.large:
        return 1.15;
    }
  }

  String get displayName {
    switch (this) {
      case AppTextSize.compact:
        return 'Compact';
      case AppTextSize.standard:
        return 'Standard';
      case AppTextSize.large:
        return 'Large';
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppTextSize _textSize = AppTextSize.standard;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  AppTextSize get textSize => _textSize;
  double get fontScale => _textSize.scaleFactor;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    final modeStr = await StorageService.instance.getPreference('theme_mode', defaultValue: 'light');
    if (modeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    final sizeStr = await StorageService.instance.getPreference('text_size', defaultValue: 'standard');
    if (sizeStr == 'compact') {
      _textSize = AppTextSize.compact;
    } else if (sizeStr == 'large') {
      _textSize = AppTextSize.large;
    } else {
      _textSize = AppTextSize.standard;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await StorageService.instance.setPreference(
      'theme_mode',
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> setTextSize(AppTextSize size) async {
    if (_textSize == size) return;
    _textSize = size;
    notifyListeners();
    await StorageService.instance.setPreference('text_size', size.name);
  }
}
