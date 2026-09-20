import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/launch.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';

const _supportEmail = 'support@jancosmicfoundation.org';

/// "Didn't receive the code?" (design/13). Pops with the new retry-after
/// seconds when a code was resent.
class ResendHelpScreen extends ConsumerStatefulWidget {
  const ResendHelpScreen(
      {super.key, required this.identifier, required this.isPhone});

  final String identifier;
  final bool isPhone;

  @override
  ConsumerState<ResendHelpScreen> createState() => _ResendHelpScreenState();
}

class _ResendHelpScreenState extends ConsumerState<ResendHelpScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestCode(widget.identifier);
      if (mounted) Navigator.of(context).pop(result.retryAfter);
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.genericError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: t.didntReceiveCode,
                subtitle: t.resendHelpSub,
              ),
              const SizedBox(height: 20),
              Icon(Icons.sms_outlined,
                  size: 96, color: JcfColors.skyPrimary.withValues(alpha: 0.8)),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFC0392B))),
              ],
              const SizedBox(height: 24),
              AuthPrimaryButton(
                  label: t.resendCode, busy: _busy, onPressed: _resend),
              const SizedBox(height: 12),
              AuthOutlinedButton(
                label: widget.isPhone
                    ? t.changePhoneNumber
                    : t.changeEmailAddress,
                // Pop help + verify, back to the identifier screen.
                onPressed: () => Navigator.of(context)
                  ..pop()
                  ..maybePop(),
              ),
              const SizedBox(height: 10),
              AuthLink(
                label: t.contactSupport,
                underline: true,
                onPressed: () => openExternalUrl('mailto:$_supportEmail'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
