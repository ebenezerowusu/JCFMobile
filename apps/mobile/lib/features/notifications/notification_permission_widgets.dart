import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../welcome/welcome_widgets.dart'
    show royalBlue, deepNavy, warmWhite, softGold, supportingText;
import 'notification_permission_state.dart';

/// The soft blue surface the benefit rows sit on (owner palette).
const _softBlueSurface = Color(0xFFEDF5FF);
const _border = Color(0xFFD8DEEA);
const _dangerInk = Color(0xFF9B1C1C);

/// The brand mark, centred near the top.
class NotificationPermissionLogo extends StatelessWidget {
  const NotificationPermissionLogo({super.key, this.width = 72});

  final double width;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      label: t.splashLogoLabel,
      image: true,
      child: Image.asset(
        NotificationPermissionAssets.brandLogo,
        width: width,
        // Contain and never mirrored: a reversed mark is not the brand.
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => SizedBox(width: width),
      ),
    );
  }
}

/// The bell over a soft circular glow.
///
/// The glow is decoration and is excluded from semantics; the bell carries
/// the label. Nothing here moves on a loop and nothing is red — this screen
/// is an explanation, not an alarm.
class NotificationPermissionIllustration extends StatelessWidget {
  const NotificationPermissionIllustration({super.key, this.size = 220});

  final double size;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ExcludeSemantics, not just excludeFromSemantics: a decorative
          // gradient has nothing to announce.
          ExcludeSemantics(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    royalBlue.withValues(alpha: 0.16),
                    royalBlue.withValues(alpha: 0.04),
                    royalBlue.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.6, 1],
                ),
              ),
            ),
          ),
          Semantics(
            label: t.notificationPermissionBellLabel,
            image: true,
            child: Padding(
              padding: EdgeInsets.all(size * 0.1),
              child: Image.asset(
                NotificationPermissionAssets.bell,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                // A missing asset must not leave a hole where the subject
                // of the screen should be.
                errorBuilder: (_, _, _) => Icon(
                  Icons.notifications_active_rounded,
                  size: size * 0.5,
                  color: royalBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One benefit. Deliberately short: three rows of prose would make the
/// actions unreachable on a small phone at large text sizes.
class NotificationBenefitTile extends StatelessWidget {
  const NotificationBenefitTile({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: _softBlueSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: royalBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: deepNavy,
                ),
              ),
            ),
          ],
        ),
      );
}

class NotificationBenefitList extends StatelessWidget {
  const NotificationBenefitList({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final benefits = <(IconData, String)>[
      (Icons.event_available_rounded, t.notificationBenefitLiveSessions),
      (Icons.self_improvement_rounded, t.notificationBenefitPractice),
      (Icons.campaign_rounded, t.notificationBenefitUpdates),
    ];
    return Column(
      children: [
        for (final (index, benefit) in benefits.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          NotificationBenefitTile(icon: benefit.$1, label: benefit.$2),
        ],
      ],
    );
  }
}

/// The eyebrow / title / description block.
class NotificationPermissionIntro extends StatelessWidget {
  const NotificationPermissionIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          t.notificationPermissionEyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: softGold,
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(
            t.notificationPermissionTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: deepNavy,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          t.notificationPermissionDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 14, height: 1.5, color: supportingText),
        ),
      ],
    );
  }
}

/// The outcome of a permission decision, stated plainly.
///
/// There is a check or a cross as well as a colour, because colour alone
/// is not a state indicator.
class NotificationPermissionResult extends StatelessWidget {
  const NotificationPermissionResult({
    super.key,
    required this.title,
    required this.message,
    required this.granted,
  });

  final String title;
  final String message;
  final bool granted;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: granted ? const Color(0xFFEAF6EE) : _softBlueSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: granted ? const Color(0xFFB7DEC5) : _border),
          ),
          child: Column(
            children: [
              Icon(
                granted
                    ? Icons.check_circle_rounded
                    : Icons.notifications_off_rounded,
                size: 30,
                color: granted ? const Color(0xFF2E7D4F) : supportingText,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: deepNavy,
                ),
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13.5, height: 1.45, color: supportingText),
                ),
              ],
            ],
          ),
        ),
      );
}

/// What to do when the operating system will not be asked again.
class NotificationSettingsGuidance extends StatelessWidget {
  const NotificationSettingsGuidance({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => NotificationPermissionResult(
        title: title,
        message: message,
        granted: false,
      );
}

/// A failure that the reader can do something about.
class NotificationPermissionError extends StatelessWidget {
  const NotificationPermissionError({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: _dangerInk),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style:
                  const TextStyle(fontSize: 12.5, color: _dangerInk),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: _dangerInk,
                minimumSize: const Size(48, 44),
              ),
              child: Text(t.notificationPermissionRetry),
            ),
        ],
      ),
    );
  }
}

/// The action pair.
///
/// Not now is a plain, readable button — never faded, never reworded into
/// a loss. Both are disabled together while a request is in flight so a
/// second tap cannot stack a second system prompt.
class NotificationPermissionActions extends StatelessWidget {
  const NotificationPermissionActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.loading = false,
    this.loadingLabel,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String secondaryLabel;
  final VoidCallback? onSecondary;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              enabled: onPrimary != null && !loading,
              // Progress in words, not only a spinner.
              label: loading ? (loadingLabel ?? primaryLabel) : primaryLabel,
              liveRegion: loading,
              excludeSemantics: true,
              child: FilledButton(
                onPressed: loading ? null : onPrimary,
                style: FilledButton.styleFrom(
                  backgroundColor: royalBlue,
                  disabledBackgroundColor: royalBlue.withValues(alpha: 0.4),
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
                    : Text(primaryLabel),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: loading ? null : onSecondary,
              style: TextButton.styleFrom(
                foregroundColor: royalBlue,
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              child: Text(secondaryLabel, textAlign: TextAlign.center),
            ),
          ),
        ],
      );
}

/// The privacy line. Supporting text, but not so small it cannot be read.
class NotificationPermissionControlNote extends StatelessWidget {
  const NotificationPermissionControlNote({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Text(
      t.notificationPermissionControlMessage,
      textAlign: TextAlign.center,
      style: const TextStyle(
          fontSize: 12.5, height: 1.45, color: supportingText),
    );
  }
}

/// A full-bleed warm-white page body with a tablet-safe content width.
class NotificationPermissionCanvas extends StatelessWidget {
  const NotificationPermissionCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: warmWhite,
        child: Center(
          // Benefit rows stretched across a tablet look like a mistake.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      );
}
