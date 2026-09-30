import 'dart:ui' show ImageFilter;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import 'welcome_state.dart';

const royalBlue = Color(0xFF1555D7);
const deepNavy = Color(0xFF102454);
const warmWhite = Color(0xFFF8F7F2);
const softGold = Color(0xFFD5A62E);
const supportingText = Color(0xFF59647A);

/// The hero photograph with the gradients that make the controls on top of
/// it readable wherever the sky happens to be bright.
class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Decorative: excluded from semantics so a screen reader does
        // not describe the wallpaper before the words that matter.
        Image.asset(
          WelcomeAssets.heroJourney,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => const ColoredBox(color: deepNavy),
        ),
        // Top scrim for the logo and language pill.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x59102454), Color(0x00102454)],
              stops: [0, 0.35],
            ),
          ),
        ),
        // Bottom scrim so the photograph settles into the panel
        // instead of ending at a hard line.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xCC102454), Color(0x00102454)],
              stops: [0, 0.32],
            ),
          ),
        ),
      ],
    ),
  );
}

/// The mark in a translucent navy disc.
///
/// The disc is a separate container: clipping the logo itself to a circle
/// would crop the orbit ring off the artwork.
class WelcomeBrandLogo extends StatelessWidget {
  const WelcomeBrandLogo({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      label: t.splashLogoLabel,
      image: true,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: deepNavy.withValues(alpha: 0.42),
              border: Border.all(
                color: warmWhite.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.all(size * 0.16),
            child: Image.asset(
              WelcomeAssets.brandLogo,
              // Contain, never cover: the mark is never cropped.
              fit: BoxFit.contain,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

/// The language pill in the top-right.
class WelcomeLanguageButton extends StatelessWidget {
  const WelcomeLanguageButton({
    super.key,
    required this.language,
    required this.onPressed,
  });

  final AppLanguage language;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: t.welcomeLanguageSelector(language.nativeName),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                // At least 48 logical pixels of target.
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: deepNavy.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: warmWhite.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      size: 17,
                      color: warmWhite,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        language.nativeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: warmWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: warmWhite,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-width action. Loading happens inside the button and keeps its
/// width, so the layout does not jump and the label does not disappear.
class WelcomeActionButton extends StatelessWidget {
  const WelcomeActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: outlined ? royalBlue : Colors.white,
            ),
          )
        : Text(label);

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size.fromHeight(56)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled && !loading,
      // Loading is announced in words, not by a spinner alone.
      label: loading ? '$label…' : label,
      excludeSemantics: true,
      child: SizedBox(
        width: double.infinity,
        child: outlined
            ? OutlinedButton(
                onPressed: enabled && !loading ? onPressed : null,
                style: style.copyWith(
                  backgroundColor: WidgetStateProperty.all(warmWhite),
                  foregroundColor: WidgetStateProperty.all(royalBlue),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: royalBlue, width: 1.5),
                  ),
                ),
                child: child,
              )
            : FilledButton(
                onPressed: enabled && !loading ? onPressed : null,
                style: style.copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.disabled)
                        ? royalBlue.withValues(alpha: 0.5)
                        : royalBlue,
                  ),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: child,
              ),
      ),
    );
  }
}

/// "By continuing, you agree to the Terms of Use and Privacy Policy."
///
/// Two genuinely separate links, each its own tap target and its own
/// semantic link — not one sentence that happens to be blue.
class WelcomeLegalAgreement extends StatefulWidget {
  const WelcomeLegalAgreement({
    super.key,
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  State<WelcomeLegalAgreement> createState() => _WelcomeLegalAgreementState();
}

class _WelcomeLegalAgreementState extends State<WelcomeLegalAgreement> {
  final _terms = TapGestureRecognizer();
  final _privacy = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _terms.onTap = () => widget.onTerms();
    _privacy.onTap = () => widget.onPrivacy();
  }

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    const base = TextStyle(fontSize: 12.5, height: 1.5, color: supportingText);
    final link = base.copyWith(
      color: royalBlue,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: royalBlue,
    );

    // Built from parts rather than one interpolated sentence, so every
    // language can order the clause its own way.
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: '${t.welcomeAgreementPrefix} '),
          TextSpan(
            text: t.welcomeTermsOfUse,
            style: link,
            recognizer: _terms,
            semanticsLabel: t.welcomeTermsOfUse,
          ),
          TextSpan(text: ' ${t.welcomeAgreementJoin} '),
          TextSpan(
            text: t.welcomePrivacyPolicy,
            style: link,
            recognizer: _privacy,
            semanticsLabel: t.welcomePrivacyPolicy,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// An inline, retryable failure. Never a raw API error.
class WelcomeErrorMessage extends StatelessWidget {
  const WelcomeErrorMessage({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: Color(0xFF9B1C1C),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: Color(0xFF9B1C1C),
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9B1C1C),
                minimumSize: const Size(48, 44),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(t.welcomeRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// The language chooser. One list, from [appLanguages].
class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelected;

  static Future<AppLanguage?> show(
    BuildContext context, {
    required AppLanguage selected,
  }) => showModalBottomSheet<AppLanguage>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => LanguageSelectionSheet(
      selected: selected,
      onSelected: (language) => Navigator.of(sheetContext).pop(language),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8E0EE),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Semantics(
                header: true,
                child: Text(
                  t.welcomeChooseLanguage,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: JcfColors.inkOnLight,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                for (final language in appLanguages)
                  ListTile(
                    // The name in its own script, so a reader who does
                    // not yet understand the current UI language can
                    // still find theirs.
                    title: Text(
                      language.nativeName,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: language == selected
                        ? const Icon(Icons.check_rounded, color: royalBlue)
                        : null,
                    selected: language == selected,
                    onTap: () => onSelected(language),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
