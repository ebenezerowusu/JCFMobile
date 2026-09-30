import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../welcome/welcome_widgets.dart'
    show royalBlue, deepNavy, warmWhite, supportingText;
import 'supported_languages.dart';

const _border = Color(0xFFD8DEEA);
const _selectionBlue = Color(0xFF1769E8);

/// The illustrated header.
///
/// Falls back to a brand gradient if the artwork ever fails to load: a
/// missing asset must never be a blank rectangle where the logo should be.
class LanguageSelectionHeader extends StatelessWidget {
  const LanguageSelectionHeader({
    super.key,
    required this.showBack,
    required this.onBack,
  });

  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final height = MediaQuery.sizeOf(context).height;
    final short = height < 680;

    return SizedBox(
      height: height * (short ? 0.2 : 0.25),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            LanguageSelectionAssets.header,
            fit: BoxFit.cover,
            // Top, not the default centre. The artwork is portrait and
            // its globe sits in the upper fifth, so a centred crop into a
            // short header band shows empty blue and loses the subject.
            alignment: Alignment.topCenter,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B2F7A), deepNavy],
                ),
              ),
            ),
          ),
          // Contrast scrim so the controls stay readable over whatever
          // artwork eventually lands here.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66102454), Color(0x33102454)],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                if (showBack)
                  PositionedDirectional(
                    start: 4,
                    top: 4,
                    child: IconButton(
                      onPressed: onBack,
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: warmWhite,
                      // At least 48 logical pixels of target.
                      constraints: const BoxConstraints(
                          minWidth: 48, minHeight: 48),
                    ),
                  ),
                Center(
                  child: Semantics(
                    label: t.splashLogoLabel,
                    image: true,
                    child: Image.asset(
                      LanguageSelectionAssets.brandLogo,
                      width: 84,
                      // Contain, and never mirrored in RTL: a reversed
                      // mark is not the brand.
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                      errorBuilder: (_, _, _) => const SizedBox(width: 84),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageSearchField extends StatelessWidget {
  const LanguageSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 15, color: deepNavy),
      decoration: InputDecoration(
        hintText: t.languageSearchHint,
        hintStyle: const TextStyle(color: supportingText, fontSize: 15),
        prefixIcon:
            const Icon(Icons.search_rounded, color: supportingText),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: onClear,
                  tooltip: t.languageSearchClear,
                  icon: const Icon(Icons.close_rounded,
                      color: supportingText),
                  constraints: const BoxConstraints(
                      minWidth: 48, minHeight: 48),
                ),
        ),
        filled: true,
        fillColor: Colors.white,
        // Comfortably over the 48dp minimum once padding is added.
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: royalBlue, width: 1.6),
        ),
      ),
    );
  }
}

/// One language. The whole row is a single semantic control — a separate
/// radio would announce the same action twice.
class LanguageListTile extends StatelessWidget {
  const LanguageListTile({
    super.key,
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final localized = language.localizedName(t);
    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: [
        language.nativeName,
        if (localized != language.nativeName) localized,
        if (language.isRtl) t.languageDirectionRtlLabel,
      ].join(', '),
      excludeSemantics: true,
      child: Material(
        color: selected ? const Color(0xFFEDF3FE) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? royalBlue : _border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                _badge(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              // The language's own name, in its own
                              // script, always. Never translated.
                              language.nativeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: language.textDirection,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: deepNavy,
                              ),
                            ),
                          ),
                          if (language.isRtl) ...[
                            const SizedBox(width: 6),
                            _rtlBadge(t),
                          ],
                        ],
                      ),
                      if (localized != language.nativeName) ...[
                        const SizedBox(height: 2),
                        Text(
                          localized,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: supportingText),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // A check, not colour alone.
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 22,
                  color: selected ? _selectionBlue : _border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge() => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? royalBlue : const Color(0xFFEFF2F8),
          shape: BoxShape.circle,
        ),
        child: Text(
          language.badgeText,
          // Latin code, left-to-right even on an RTL row, so it stays
          // readable rather than reversed.
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : supportingText,
          ),
        ),
      );

  Widget _rtlBadge(AppLocalizations t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF0D5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          t.languageDirectionRtl,
          textDirection: TextDirection.ltr,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B4A00),
          ),
        ),
      );
}

class LanguageEmptyState extends StatelessWidget {
  const LanguageEmptyState({super.key, required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 38, color: supportingText),
              const SizedBox(height: 12),
              Text(
                t.languageNoResultsTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: deepNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.languageNoResultsDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13.5, height: 1.45, color: supportingText),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: royalBlue,
                  minimumSize: const Size(48, 48),
                  textStyle: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                child: Text(t.languageClearSearch),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The sticky Continue bar, with the save failure shown just above it so
/// the retry sits beside the thing that failed.
class LanguageContinueBar extends StatelessWidget {
  const LanguageContinueBar({
    super.key,
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onPressed,
    required this.onRetry,
    this.errorMessage,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;
  final VoidCallback onRetry;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: warmWhite,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (errorMessage != null) ...[
                Semantics(
                  liveRegion: true,
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 18, color: Color(0xFF9B1C1C)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF9B1C1C)),
                        ),
                      ),
                      TextButton(
                        onPressed: onRetry,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF9B1C1C),
                          minimumSize: const Size(48, 44),
                        ),
                        child: Text(t.languageRetry),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  enabled: enabled,
                  // Loading is announced in words, not by a spinner.
                  label: loading ? '$label…' : label,
                  excludeSemantics: true,
                  child: FilledButton(
                    onPressed: enabled && !loading ? onPressed : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: royalBlue,
                      disabledBackgroundColor:
                          royalBlue.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      textStyle: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w600),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text(label),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
