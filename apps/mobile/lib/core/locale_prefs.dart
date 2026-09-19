import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UI locales the app ships today (Wave 1). More arrive as translations land.
const supportedAppLocales = [
  Locale('en'),
  Locale('fr'),
  Locale('es'),
  Locale('de'),
  Locale('pt'),
];

/// The chosen UI locale; null = follow the device locale.
class AppLocaleNotifier extends Notifier<Locale?> {
  static const _key = 'app_locale';

  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) state = Locale(code);
  }

  Future<void> set(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale?>(AppLocaleNotifier.new);
