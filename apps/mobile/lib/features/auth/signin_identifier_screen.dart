import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'verify_code_screen.dart';

/// Dial codes offered by the picker (design/10). Flag + code only, so the
/// list needs no per-language country names.
const _dialCodes = [
  ('🇬🇭', '+233'),
  ('🇳🇬', '+234'),
  ('🇨🇮', '+225'),
  ('🇹🇬', '+228'),
  ('🇬🇧', '+44'),
  ('🇺🇸', '+1'),
  ('🇩🇪', '+49'),
  ('🇫🇷', '+33'),
  ('🇪🇸', '+34'),
  ('🇵🇹', '+351'),
  ('🇳🇱', '+31'),
  ('🇮🇹', '+39'),
  ('🇮🇳', '+91'),
  ('🇿🇦', '+27'),
];

/// Phone (design/10) and email (design/12) sign-in entry.
class SignInIdentifierScreen extends ConsumerStatefulWidget {
  const SignInIdentifierScreen({super.key, required this.isPhone});

  final bool isPhone;

  @override
  ConsumerState<SignInIdentifierScreen> createState() =>
      _SignInIdentifierScreenState();
}

class _SignInIdentifierScreenState
    extends ConsumerState<SignInIdentifierScreen> {
  final _field = TextEditingController();
  String _dialCode = '+233';
  String _flag = '🇬🇭';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  String get _identifier {
    final raw = _field.text.trim();
    if (!widget.isPhone) return raw;
    final national = raw.replaceAll(RegExp(r'[^0-9]'), '');
    // Drop a leading trunk zero: 020 123 4567 -> +233201234567.
    final trimmed = national.startsWith('0')
        ? national.substring(1)
        : national;
    return '$_dialCode$trimmed';
  }

  Future<void> _sendCode() async {
    if (_field.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestCode(_identifier);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VerifyCodeScreen(
          identifier: _identifier,
          isPhone: widget.isPhone,
          maskedDestination: result.maskedDestination,
          retryAfter: result.retryAfter,
        ),
      ));
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context)!.genericError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDialCode() async {
    final picked = await showModalBottomSheet<(String, String)>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        children: [
          for (final (flag, code) in _dialCodes)
            ListTile(
              leading: Text(flag, style: const TextStyle(fontSize: 26)),
              title: Text(code,
                  style: const TextStyle(
                    color: JcfColors.inkOnLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  )),
              trailing: code == _dialCode
                  ? const Icon(Icons.check, color: JcfColors.skyPrimary)
                  : null,
              onTap: () => Navigator.pop(context, (flag, code)),
            ),
        ],
      ),
    );
    if (picked != null) {
      setState(() {
        _flag = picked.$1;
        _dialCode = picked.$2;
      });
    }
  }

  InputDecoration _fieldDecoration(String hint, {Widget? prefixIcon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9AA7C7)),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC6D6F2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: JcfColors.skyPrimary, width: 1.6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isPhone = widget.isPhone;
    return Scaffold(
      backgroundColor: JcfColors.skySurface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: isPhone ? t.signInWithPhone : t.signInWithEmail,
                subtitle: t.oneTimeCodeSub,
              ),
              const SizedBox(height: 26),
              if (isPhone)
                Row(
                  children: [
                    // Country dial-code selector.
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _pickDialCode,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 15),
                          child: Row(
                            children: [
                              Text(_flag,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Text(_dialCode,
                                  style: const TextStyle(
                                    color: JcfColors.inkOnLight,
                                    fontFamily: JcfTypography.bodyFamily,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  )),
                              const Icon(Icons.keyboard_arrow_down,
                                  color: JcfColors.inkOnLight),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _field,
                        keyboardType: TextInputType.phone,
                        decoration: _fieldDecoration(t.phoneNumber),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFC6D6F2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.emailAddress,
                        style: const TextStyle(
                          color: Color(0xFF54689B),
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextField(
                        controller: _field,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: 'name@example.com',
                          hintStyle: TextStyle(color: Color(0xFF9AA7C7)),
                          icon: Icon(Icons.mail_outline_rounded,
                              color: JcfColors.skyPrimary),
                          border: InputBorder.none,
                        ),
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
              const SizedBox(height: 22),
              AuthPrimaryButton(
                  label: t.sendCode, busy: _busy, onPressed: _sendCode),
              const SizedBox(height: 10),
              AuthLink(
                label: isPhone ? t.useEmailInstead : t.usePhoneInstead,
                onPressed: () => context.pushReplacement(
                    isPhone ? '/login/email' : '/login/phone'),
              ),
              const SizedBox(height: 40),
              Text(
                isPhone ? t.phoneMatchNote : t.emailMatchNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7C8DB5),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 14.5,
                  height: 1.35,
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
