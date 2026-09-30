import 'dart:ui' show Locale, TextDirection;

import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';

/// Asset paths, named once so a filename cannot drift.
class LanguageSelectionAssets {
  LanguageSelectionAssets._();

  /// Abstract multilingual header artwork.
  ///
  /// Not yet supplied. The header falls back to a brand gradient when the
  /// file is absent, so dropping it in needs no code change.
  static const String header =
      'assets/images/language_selection/language_selection_header.png';

  /// The same file the splash, welcome and onboarding screens use — one
  /// piece of artwork rather than four copies in the bundle.
  static const String brandLogo =
      'assets/images/splash/splash_brand_logo.png';
}

/// A language the app can present its interface in.
@immutable
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.badgeText,
    required this.textDirection,
    required this.isFullyTranslated,
    required this.sortOrder,
    this.searchAliases = const [],
    this.countryCode,
  });

  /// BCP 47 language subtag.
  final String code;

  /// The language's own name in its own script. Never translated: a
  /// reader who does not yet understand the current interface language
  /// recognises this and nothing else on the row.
  final String nativeName;

  final String badgeText;
  final TextDirection textDirection;

  /// Whether every string the app shows exists in this language. A
  /// half-translated language is worse than an untranslated one, because
  /// the gaps appear as English scattered through the interface.
  final bool isFullyTranslated;

  final int sortOrder;

  /// Extra terms a reader might type — the English name, the code, and
  /// common spellings without diacritics.
  final List<String> searchAliases;

  /// Region subtag, when the bundle is region-specific (e.g. pt-BR).
  final String? countryCode;

  Locale get locale =>
      countryCode == null ? Locale(code) : Locale(code, countryCode);

  /// The BCP 47 identifier stored in preferences.
  String get tag => countryCode == null ? code : '$code-$countryCode';

  bool get isRtl => textDirection == TextDirection.rtl;

  /// Only fully translated languages may be chosen.
  bool get isSelectable => isFullyTranslated;

  /// The name in the language the interface is currently using.
  String localizedName(AppLocalizations t) => switch (code) {
        'en' => t.languageEnglish,
        'fr' => t.languageFrench,
        'es' => t.languageSpanish,
        'de' => t.languageGerman,
        'pt' => t.languagePortuguese,
        'ar' => t.languageArabic,
        'sw' => t.languageSwahili,
        _ => nativeName,
      };

  @override
  bool operator ==(Object other) =>
      other is AppLanguage && other.tag == tag;

  @override
  int get hashCode => tag.hashCode;
}

/// **The** supported-language configuration.
///
/// One list. The localization delegate, the startup resolver, the welcome
/// screen's picker and this screen all read it, because a second list
/// somewhere else drifts the first time a language is added.
///
/// Arabic and Swahili are configured but NOT translated, so they are not
/// selectable and do not appear. They are here so the RTL machinery is
/// exercised and so enabling them later is one flag, not a code change.
const allLanguages = <AppLanguage>[
  AppLanguage(
    code: 'en',
    nativeName: 'English',
    badgeText: 'EN',
    textDirection: TextDirection.ltr,
    isFullyTranslated: true,
    sortOrder: 1,
    searchAliases: ['english', 'en'],
  ),
  AppLanguage(
    code: 'fr',
    nativeName: 'Français',
    badgeText: 'FR',
    textDirection: TextDirection.ltr,
    isFullyTranslated: true,
    sortOrder: 2,
    searchAliases: ['french', 'francais', 'français', 'fr'],
  ),
  AppLanguage(
    code: 'es',
    nativeName: 'Español',
    badgeText: 'ES',
    textDirection: TextDirection.ltr,
    isFullyTranslated: true,
    sortOrder: 3,
    searchAliases: ['spanish', 'espanol', 'español', 'castellano', 'es'],
  ),
  AppLanguage(
    code: 'de',
    nativeName: 'Deutsch',
    badgeText: 'DE',
    textDirection: TextDirection.ltr,
    isFullyTranslated: true,
    sortOrder: 4,
    searchAliases: ['german', 'deutsch', 'de'],
  ),
  AppLanguage(
    code: 'pt',
    nativeName: 'Português',
    badgeText: 'PT',
    textDirection: TextDirection.ltr,
    isFullyTranslated: true,
    sortOrder: 5,
    searchAliases: ['portuguese', 'portugues', 'português', 'pt'],
  ),
  // --- configured, not yet translated -------------------------------
  AppLanguage(
    code: 'ar',
    nativeName: 'العربية',
    badgeText: 'AR',
    textDirection: TextDirection.rtl,
    isFullyTranslated: false,
    sortOrder: 6,
    searchAliases: ['arabic', 'arabe', 'ar'],
  ),
  AppLanguage(
    code: 'sw',
    nativeName: 'Kiswahili',
    badgeText: 'SW',
    textDirection: TextDirection.ltr,
    isFullyTranslated: false,
    sortOrder: 7,
    searchAliases: ['swahili', 'kiswahili', 'sw'],
  ),
];

/// The languages a reader may actually choose, in display order.
List<AppLanguage> get selectableLanguages =>
    (allLanguages.where((l) => l.isSelectable).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)));

/// What MaterialApp declares it supports.
List<Locale> get supportedAppLocales =>
    selectableLanguages.map((l) => l.locale).toList();

AppLanguage get defaultLanguage => selectableLanguages.first;

/// Finds a selectable language by tag or code, or null.
AppLanguage? languageByTag(String? tag) {
  if (tag == null || tag.isEmpty) return null;
  final normalized = tag.replaceAll('_', '-').trim();
  for (final language in selectableLanguages) {
    if (language.tag.toLowerCase() == normalized.toLowerCase()) {
      return language;
    }
  }
  // Fall back to the language subtag: fr-CA resolves to fr when no
  // Canadian French bundle exists.
  final subtag = normalized.split('-').first.toLowerCase();
  for (final language in selectableLanguages) {
    if (language.code.toLowerCase() == subtag) return language;
  }
  return null;
}

/// The language for a [Locale], falling back safely.
AppLanguage languageFor(Locale? locale) {
  if (locale == null) return defaultLanguage;
  final tag = locale.countryCode == null
      ? locale.languageCode
      : '${locale.languageCode}-${locale.countryCode}';
  return languageByTag(tag) ?? defaultLanguage;
}

/// Which language the app should start in.
///
/// Priority: a previously saved choice, then an exact device match
/// including region, then the device's language subtag, then the default.
/// The app must never start in a locale it cannot render.
AppLanguage resolveInitialLanguage({
  String? savedTag,
  List<Locale> deviceLocales = const [],
}) {
  final saved = languageByTag(savedTag);
  if (saved != null) return saved;

  for (final locale in deviceLocales) {
    final exact = locale.countryCode == null
        ? null
        : languageByTag('${locale.languageCode}-${locale.countryCode}');
    if (exact != null) return exact;
  }
  for (final locale in deviceLocales) {
    final byCode = languageByTag(locale.languageCode);
    if (byCode != null) return byCode;
  }
  return defaultLanguage;
}

/// Strips diacritics so "francais" matches "Français".
///
/// Deliberately narrow: it folds the accents that appear in the names and
/// aliases this app ships, and leaves every other script alone. A general
/// transliteration would mangle Arabic and Swahili queries.
String foldForSearch(String input) {
  const folds = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ñ': 'n', 'ç': 'c',
  };
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(folds[char] ?? char);
  }
  return buffer.toString().trim();
}

/// Filters [languages] by a reader's query.
///
/// Matches the native name, the name in the current interface language,
/// the code and the aliases — so "arabic", "العربية" and "ar" all find the
/// same row.
List<AppLanguage> searchLanguages(
  List<AppLanguage> languages,
  String query,
  AppLocalizations t,
) {
  final needle = foldForSearch(query);
  if (needle.isEmpty) return languages;
  return languages.where((language) {
    final haystacks = <String>[
      language.nativeName,
      language.localizedName(t),
      language.code,
      language.badgeText,
      ...language.searchAliases,
    ];
    return haystacks
        .any((value) => foldForSearch(value).contains(needle));
  }).toList();
}
