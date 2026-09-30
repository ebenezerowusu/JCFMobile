import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/language_selection/supported_languages.dart';

/// Re-exported so existing imports keep working. The list itself lives in
/// supported_languages.dart, which is the single authoritative source —
/// a second copy here drifted the first time a language was added.
export '../features/language_selection/supported_languages.dart'
    show supportedAppLocales, AppLanguage, languageFor;

/// The chosen UI locale; null = follow the device locale.
class AppLocaleNotifier extends Notifier<Locale?> {
  static const _key = 'app_locale';

  @override
  Locale? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Validated against the supported list: a corrupted or since-removed
      // value must not start the app in a locale it cannot render.
      final language = languageByTag(prefs.getString(_key));
      if (language != null) state = language.locale;
    } catch (_) {
      // Leave the device locale in place.
    }
  }

  Future<void> set(Locale locale) async {
    final language = languageFor(locale);
    state = language.locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.tag);
  }
}

final appLocaleProvider =
    NotifierProvider<AppLocaleNotifier, Locale?>(AppLocaleNotifier.new);
