import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'resend_help_screen.dart';

/// Verification code entry (design/11): six digit boxes, masked destination,
/// resend countdown, change-identifier link.
class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.identifier,
    required this.isPhone,
    this.maskedDestination,
    this.retryAfter = 30,
  });

  final String identifier;
  final bool isPhone;
  final String? maskedDestination;
  final int retryAfter;

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = 0;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown(widget.retryAfter);
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsLeft = _secondsLeft > 0 ? _secondsLeft - 1 : 0;
        if (_secondsLeft == 0) timer.cancel();
      });
    });
  }

  Future<void> _verify() async {
    if (_code.text.length < 6) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .verify(widget.identifier, _code.text);
      if (!mounted) return;
      if (ref.read(isLoggedInProvider)) {
        context.go('/stay-connected');
      } else {
        setState(() => _error = AppLocalizations.of(context)!.invalidCode);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.genericError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openResendHelp() async {
    final newRetry = await Navigator.of(context).push<int>(MaterialPageRoute(
      builder: (_) => ResendHelpScreen(
        identifier: widget.identifier,
        isPhone: widget.isPhone,
      ),
    ));
    if (newRetry != null && mounted) {
      _code.clear();
      _startCountdown(newRetry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final destination = widget.maskedDestination ??
        (widget.isPhone ? t.phoneNumber : t.emailAddress);
    final mm = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                logoSize: 110,
                title: t.enterVerificationCode,
                subtitle: t.codeSentToMasked(destination),
              ),
              const SizedBox(height: 24),
              // Six digit boxes driven by one invisible field.
              GestureDetector(
                onTap: () => _focus.requestFocus(),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        height: 1,
                        child: TextField(
                          controller: _code,
                          focusNode: _focus,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          autofocus: true,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < 6; i++)
                          Container(
                            height: 62,
                            width: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: i == _code.text.length
                                    ? JcfColors.skyPrimary
                                    : const Color(0xFFC6D6F2),
                                width: i == _code.text.length ? 1.8 : 1.2,
                              ),
                            ),
                            child: Text(
                              i < _code.text.length ? _code.text[i] : '',
                              style: const TextStyle(
                                color: JcfColors.inkOnLight,
                                fontFamily: JcfTypography.bodyFamily,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFC0392B))),
              ],
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: t.verifyAndContinue,
                busy: _busy,
                onPressed: _code.text.length == 6 ? _verify : null,
              ),
              const SizedBox(height: 14),
              if (_secondsLeft > 0)
                Text(
                  t.resendCodeIn('$mm:$ss'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF54689B),
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 16,
                  ),
                )
              else
                AuthLink(label: t.didntReceiveCode, onPressed: _openResendHelp),
              AuthLink(
                label: widget.isPhone
                    ? t.changePhoneNumber
                    : t.changeEmailAddress,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
