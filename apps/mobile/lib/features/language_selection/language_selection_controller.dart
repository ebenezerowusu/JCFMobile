import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/locale_prefs.dart';
import '../../l10n/app_localizations.dart';
import 'supported_languages.dart';

/// Where the screen was opened from.
///
/// Held by the screen rather than the controller: the two modes differ
/// only in whether Back is shown and where Continue goes, and both of
/// those are the screen's business.
enum LanguageSelectionMode { firstLaunch, settings }

enum LanguageSelectionStatus { initial, ready, saving, saved, failure }

/// Remembers that the reader has been asked to choose a language.
///
/// Separate from the stored locale: a locale can be written automatically
/// by resolution, so its presence does not prove anyone was asked.
class LanguageSelectionPrefs {
  static const _completedKey = 'language_selection_completed';

  Future<bool> isCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_completedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
  }
}

final languageSelectionPrefsProvider =
    Provider<LanguageSelectionPrefs>((ref) => LanguageSelectionPrefs());

@immutable
class LanguageSelectionState {
  const LanguageSelectionState({
    this.available = const [],
    this.filtered = const [],
    this.initialLanguage,
    this.selected,
    this.searchQuery = '',
    this.status = LanguageSelectionStatus.initial,
    this.errorMessage,
  });

  final List<AppLanguage> available;
  final List<AppLanguage> filtered;
  final AppLanguage? initialLanguage;
  final AppLanguage? selected;
  final String searchQuery;
  final LanguageSelectionStatus status;
  final String? errorMessage;

  bool get hasSelection => selected != null;

  bool get hasChanged =>
      selected != null && selected != initialLanguage;

  bool get hasResults => filtered.isNotEmpty;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  bool get isSaving => status == LanguageSelectionStatus.saving;

  /// Continue is available whenever a supported language is chosen —
  /// including the one already active, so the first launch can be
  /// completed without changing anything.
  bool get canContinue => hasSelection && !isSaving;

  LanguageSelectionState copyWith({
    List<AppLanguage>? available,
    List<AppLanguage>? filtered,
    AppLanguage? initialLanguage,
    AppLanguage? selected,
    String? searchQuery,
    LanguageSelectionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) =>
      LanguageSelectionState(
        available: available ?? this.available,
        filtered: filtered ?? this.filtered,
        initialLanguage: initialLanguage ?? this.initialLanguage,
        selected: selected ?? this.selected,
        searchQuery: searchQuery ?? this.searchQuery,
        status: status ?? this.status,
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

class LanguageSelectionController extends Notifier<LanguageSelectionState> {
  @override
  LanguageSelectionState build() {
    final languages = selectableLanguages;
    final saved = ref.watch(appLocaleProvider);
    // With nothing saved, start from the device's own languages rather
    // than silently defaulting to English.
    final initial = saved != null
        ? languageFor(saved)
        : resolveInitialLanguage(
            deviceLocales: ui.PlatformDispatcher.instance.locales);
    return LanguageSelectionState(
      available: languages,
      filtered: languages,
      initialLanguage: initial,
      selected: initial,
      status: LanguageSelectionStatus.ready,
    );
  }

  void selectLanguage(AppLanguage language) {
    if (state.isSaving) return;
    state = state.copyWith(selected: language, clearError: true);
  }

  void updateSearchQuery(String query, AppLocalizations t) {
    // Filtering only; the selection is never dropped because a row
    // scrolled out of the results.
    state = state.copyWith(
      searchQuery: query,
      filtered: searchLanguages(state.available, query, t),
    );
  }

  void clearSearch(AppLocalizations t) => updateSearchQuery('', t);

  /// Persists the choice and applies it.
  ///
  /// Returns true when the caller should navigate. A failed write does
  /// not navigate: nothing would have been saved, so the reader would be
  /// asked again on the next launch.
  ///
  /// [skipUnchanged] lets Settings return without a pointless write when
  /// nothing was actually chosen differently.
  Future<bool> confirmSelection({bool skipUnchanged = false}) async {
    final language = state.selected;
    if (language == null || state.isSaving) return false;
    if (skipUnchanged && !state.hasChanged) return true;

    state = state.copyWith(
      status: LanguageSelectionStatus.saving, clearError: true);
    try {
      await ref.read(appLocaleProvider.notifier).set(language.locale);
      await ref.read(languageSelectionPrefsProvider).markCompleted();
      state = state.copyWith(status: LanguageSelectionStatus.saved);
      return true;
    } catch (_) {
      state = state.copyWith(
        status: LanguageSelectionStatus.failure,
        errorMessage: 'save_failed',
      );
      return false;
    }
  }

  Future<bool> retrySave() => confirmSelection();
}

final languageSelectionControllerProvider =
    NotifierProvider<LanguageSelectionController, LanguageSelectionState>(
        LanguageSelectionController.new);
