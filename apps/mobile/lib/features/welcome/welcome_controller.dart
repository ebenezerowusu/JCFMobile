import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale_prefs.dart';
import 'welcome_prefs.dart';
import 'welcome_state.dart';

class WelcomeController extends Notifier<WelcomeState> {
  late WelcomePrefs _prefs;

  @override
  WelcomeState build() {
    _prefs = ref.watch(welcomePrefsProvider);
    return const WelcomeState();
  }

  /// Marks the account path as chosen. No session is created here — the
  /// authentication screens own that, and deciding between signing in and
  /// registering is theirs too.
  ///
  /// Returns true when the caller should navigate.
  bool beginAccountJourney() {
    if (state.busy) return false; // a second tap changes nothing
    state = state.copyWith(
      accountAction: WelcomeActionStatus.loading,
      clearError: true,
    );
    return true;
  }

  /// Settles the account action once navigation has happened, so the
  /// button is usable again if the reader comes back.
  void finishAccountJourney() {
    state = state.copyWith(accountAction: WelcomeActionStatus.idle);
  }

  /// Records the guest choice locally.
  ///
  /// Guest mode grants nothing: every protected surface still asks the
  /// server. So there is no guest session to create, no identifier to
  /// store and no request to make — which is also why this cannot fail
  /// for network reasons.
  Future<bool> continueAsGuest() async {
    // Not just `busy`: once the choice has succeeded, a second tap must
    // not record it again or start a second navigation.
    if (state.busy || state.guestAction == WelcomeActionStatus.success) {
      return false;
    }
    state = state.copyWith(
      guestAction: WelcomeActionStatus.loading,
      clearError: true,
    );
    try {
      await _prefs.chooseGuest();
      state = state.copyWith(guestAction: WelcomeActionStatus.success);
      return true;
    } catch (error) {
      state = state.copyWith(
        guestAction: WelcomeActionStatus.failure,
        errorMessage: 'guest_failed',
      );
      return false;
    }
  }

  /// Applies a language immediately and persists it. A failure keeps the
  /// previous locale rather than leaving the app in a half-changed state.
  Future<bool> chooseLanguage(AppLanguage language) async {
    try {
      await ref.read(appLocaleProvider.notifier).set(language.locale);
      state = state.copyWith(clearError: true);
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: 'language_failed');
      return false;
    }
  }

  void dismissError() => state = state.copyWith(clearError: true);
}

final welcomeControllerProvider =
    NotifierProvider<WelcomeController, WelcomeState>(WelcomeController.new);
