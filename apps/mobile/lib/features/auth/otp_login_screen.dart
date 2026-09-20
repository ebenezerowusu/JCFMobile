import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import 'auth_controller.dart';

/// OTP entry for one channel (phone or email), styled per the new design
/// language. The backend sends the code by SMS for phone identifiers and by
/// email otherwise.
class OtpLoginScreen extends ConsumerStatefulWidget {
  const OtpLoginScreen({super.key, required this.isPhone});

  final bool isPhone;

  @override
  ConsumerState<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends ConsumerState<OtpLoginScreen> {
  final _identifier = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.genericError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() => _run(() async {
        await ref
            .read(authControllerProvider.notifier)
            .requestCode(_identifier.text.trim());
        if (mounted) setState(() => _codeSent = true);
      });

  Future<void> _verify() => _run(() async {
        await ref.read(authControllerProvider.notifier).verify(
              _identifier.text.trim(),
              _code.text.trim(),
            );
        if (!mounted) return;
        if (ref.read(isLoggedInProvider)) {
          context.go('/stay-connected');
        } else {
          setState(() => _error = AppLocalizations.of(context)!.invalidCode);
        }
      });

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7C8DB5)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final label = widget.isPhone ? t.phoneNumber : t.emailAddress;
    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back,
                      color: JcfColors.inkOnLight),
                ),
              ),
              const JcfLogo(size: 110),
              const SizedBox(height: 16),
              Text(
                t.welcomeBack,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _codeSent
                    ? (widget.isPhone ? t.codeSentPhone : t.codeSentEmail)
                    : t.otpNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                label,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _identifier,
                enabled: !_codeSent,
                keyboardType: widget.isPhone
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                autocorrect: false,
                decoration: _decoration(
                    widget.isPhone ? '+233 20 000 0000' : 'name@example.com'),
              ),
              if (_codeSent) ...[
                const SizedBox(height: 16),
                Text(
                  t.verificationCode,
                  style: const TextStyle(
                    color: JcfColors.inkOnLight,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _code,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: _decoration('••••••'),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFC0392B)),
                ),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _busy ? null : (_codeSent ? _verify : _sendCode),
                style: FilledButton.styleFrom(
                  backgroundColor: JcfColors.skyPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: JcfTypography.bodyFamily,
                  ),
                ),
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_codeSent ? t.verifySignIn : t.sendCode),
              ),
              if (_codeSent)
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _codeSent = false;
                            _code.clear();
                          }),
                  child: Text(
                    t.startOver,
                    style: const TextStyle(
                      color: JcfColors.skyPrimary,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
