import 'dart:ui' show Locale, TextDirection;

import 'package:flutter/foundation.dart';

/// Asset paths, named once so a filename cannot drift.
class WelcomeAssets {
  WelcomeAssets._();

  static const String heroJourney =
      'assets/images/welcome/welcome_hero_journey.webp';

  /// The same file the splash uses. It is one piece of artwork, and
  /// shipping a second 305KB copy under a second name would put the same
  /// pixels in the bundle twice.
  static const String brandLogo = 'assets/images/splash/splash_brand_logo.png';
}

/// A language the app can actually render.
///
/// One list, in one place: a selector and a settings screen that each
/// hardcode their own will drift apart the first time a language is added.
@immutable
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.direction,
  });

  final String code;

  /// The language's name in its own script — what a reader who does not
  /// yet understand the current UI language can recognise.
  final String nativeName;
  final TextDirection direction;

  Locale get locale => Locale(code);

  @override
  bool operator ==(Object other) => other is AppLanguage && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// Every language the app ships today. Wave 2 adds to this list alone.
const appLanguages = <AppLanguage>[
  AppLanguage(code: 'en', nativeName: 'English', direction: TextDirection.ltr),
  AppLanguage(code: 'fr', nativeName: 'Français', direction: TextDirection.ltr),
  AppLanguage(code: 'es', nativeName: 'Español', direction: TextDirection.ltr),
  AppLanguage(code: 'de', nativeName: 'Deutsch', direction: TextDirection.ltr),
  AppLanguage(
    code: 'pt',
    nativeName: 'Português',
    direction: TextDirection.ltr,
  ),
];

AppLanguage languageFor(Locale? locale) {
  final code = locale?.languageCode;
  for (final language in appLanguages) {
    if (language.code == code) return language;
  }
  return appLanguages.first;
}

enum WelcomeActionStatus { idle, loading, success, failure }

@immutable
class WelcomeState {
  const WelcomeState({
    this.accountAction = WelcomeActionStatus.idle,
    this.guestAction = WelcomeActionStatus.idle,
    this.errorMessage,
  });

  final WelcomeActionStatus accountAction;
  final WelcomeActionStatus guestAction;

  /// A short key the screen turns into localized copy. Never a raw API
  /// error: the reader cannot act on a stack trace.
  final String? errorMessage;

  /// Either action running disables both, so a second tap cannot start a
  /// competing journey.
  bool get busy =>
      accountAction == WelcomeActionStatus.loading ||
      guestAction == WelcomeActionStatus.loading;

  WelcomeState copyWith({
    WelcomeActionStatus? accountAction,
    WelcomeActionStatus? guestAction,
    String? errorMessage,
    bool clearError = false,
  }) => WelcomeState(
    accountAction: accountAction ?? this.accountAction,
    guestAction: guestAction ?? this.guestAction,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
