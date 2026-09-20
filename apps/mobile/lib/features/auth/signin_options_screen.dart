import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';

/// Sign-in options (design/9): Welcome back — phone, email, or guest.
class SignInOptionsScreen extends StatelessWidget {
  const SignInOptionsScreen({super.key});

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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back,
                      color: JcfColors.inkOnLight),
                ),
              ),
              const JcfLogo(size: 150),
              const SizedBox(height: 18),
              Text(
                t.welcomeBack,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: JcfColors.inkOnLight,
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.signInOptionsSub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              // "Secure and private" divider.
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFB9C6E2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          width: 36,
                          decoration: BoxDecoration(
                            color: JcfColors.skyPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.lock,
                              size: 20, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.secureAndPrivate,
                          style: const TextStyle(
                            color: Color(0xFF7C8DB5),
                            fontFamily: JcfTypography.bodyFamily,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFB9C6E2))),
                ],
              ),
              const SizedBox(height: 22),
              _OptionCard(
                icon: Icons.phone_rounded,
                tinted: true,
                label: t.continueWithPhone,
                onTap: () => context.push('/login/phone'),
              ),
              const SizedBox(height: 14),
              _OptionCard(
                icon: Icons.mail_rounded,
                tinted: false,
                label: t.continueWithEmail,
                onTap: () => context.push('/login/email'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.go('/stay-connected'),
                child: Text(
                  t.continueAsGuest,
                  style: const TextStyle(
                    color: JcfColors.skyPrimary,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFD3DDF0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      t.noPasswordNeeded,
                      style: const TextStyle(
                        color: Color(0xFF7C8DB5),
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFD3DDF0))),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.tinted,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final bool tinted;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tinted ? const Color(0xFFE3EEFF) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: tinted
                    ? JcfColors.skyPrimary
                    : const Color(0xFFDCE9FF),
                child: Icon(icon,
                    size: 28,
                    color: tinted ? Colors.white : JcfColors.skyPrimary),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: JcfColors.inkOnLight,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: JcfColors.skyPrimary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
