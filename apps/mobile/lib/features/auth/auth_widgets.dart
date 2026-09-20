import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../core/brand.dart';

/// Shared chrome for the auth screens (designs 10-13): back button,
/// logo + wordmark, headline + subtitle.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoSize = 130,
  });

  final String title;
  final String subtitle;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: JcfColors.inkOnLight),
          ),
        ),
        JcfLogo(size: logoSize),
        const SizedBox(height: 8),
        const Text(
          'JAN COSMIC\nFOUNDATION',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: JcfColors.inkOnLight,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 18,
            height: 1.2,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: JcfColors.inkOnLight,
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF54689B),
            fontFamily: JcfTypography.bodyFamily,
            fontSize: 16,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// Primary pill button used across the auth flow.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: JcfColors.skyPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: JcfTypography.bodyFamily,
        ),
      ),
      child: busy
          ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label),
    );
  }
}

/// Secondary outlined pill.
class AuthOutlinedButton extends StatelessWidget {
  const AuthOutlinedButton(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: JcfColors.skyPrimary,
        minimumSize: const Size.fromHeight(56),
        side: const BorderSide(color: JcfColors.skyPrimary, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: JcfTypography.bodyFamily,
        ),
      ),
      child: Text(label),
    );
  }
}

/// Blue text-link button.
class AuthLink extends StatelessWidget {
  const AuthLink({super.key, required this.label, required this.onPressed,
      this.underline = false});

  final String label;
  final VoidCallback? onPressed;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: JcfColors.skyPrimary,
          fontFamily: JcfTypography.bodyFamily,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          decoration: underline ? TextDecoration.underline : null,
          decorationColor: JcfColors.skyPrimary,
        ),
      ),
    );
  }
}
