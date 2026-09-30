// AppLanguage, appLanguages and languageFor used to live here. They now
// come from the language-selection feature, which is the one authoritative
// source the delegate, the resolver and both pickers read.
export '../language_selection/supported_languages.dart'
    show AppLanguage, languageFor, selectableLanguages;

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
