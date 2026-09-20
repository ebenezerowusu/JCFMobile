import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import '../../core/launch.dart';
import 'auth_controller.dart';
import 'auth_widgets.dart';
import 'verify_code_screen.dart';

const kSupportEmail = 'support@jancosmicfoundation.org';

/// "We couldn't find your record" (design/15).
class RecordNotFoundScreen extends StatelessWidget {
  const RecordNotFoundScreen({super.key});

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
                title: t.recordNotFoundTitle,
                subtitle: t.recordNotFoundSub,
              ),
              const SizedBox(height: 24),
              const Icon(Icons.person_search_rounded,
                  size: 120, color: JcfColors.skyPrimary),
              const SizedBox(height: 28),
              AuthPrimaryButton(
                label: t.tryAnotherDetail,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 12),
              AuthOutlinedButton(
                label: t.continueAsGuest,
                onPressed: () => context.go('/stay-connected'),
              ),
              const SizedBox(height: 10),
              AuthLink(
                label: t.contactSupport,
                underline: true,
                onPressed: () => openExternalUrl('mailto:$kSupportEmail'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Your access is being reviewed" (design/16).
class ApprovalPendingScreen extends ConsumerStatefulWidget {
  const ApprovalPendingScreen({super.key, required this.identifier,
      required this.isPhone});

  final String identifier;
  final bool isPhone;

  @override
  ConsumerState<ApprovalPendingScreen> createState() =>
      _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends ConsumerState<ApprovalPendingScreen> {
  bool _busy = false;
  String? _notice;

  Future<void> _checkAgain() async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .requestCode(widget.identifier);
      if (!mounted) return;
      if (result.status == 'sent') {
        // Approved since — carry straight on into verification.
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(
            identifier: widget.identifier,
            isPhone: widget.isPhone,
            maskedDestination: result.maskedDestination,
            retryAfter: result.retryAfter,
          ),
        ));
      } else {
        setState(() => _notice = AppLocalizations.of(context)!.stillPending);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _notice = AppLocalizations.of(context)!.genericError);
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
              const SizedBox(height: 8),
              const JcfLogo(size: 120),
              const SizedBox(height: 18),
              // Avatar with the pending clock badge.
              SizedBox(
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 62,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Color(0xFFDCE9FF),
                        child: Icon(Icons.person_rounded,
                            size: 64, color: JcfColors.skyPrimary),
                      ),
                    ),
                    Positioned(
                      right: 92,
                      bottom: 6,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF08A24),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.schedule_rounded,
                            size: 24, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEED9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t.approvalPendingChip,
                    style: const TextStyle(
                      color: Color(0xFFE07B12),
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                t.accessReviewTitle,
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
                t.accessReviewSub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3EEFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.menu_book_rounded,
                          color: JcfColors.skyPrimary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        t.browseWhileWaiting,
                        style: const TextStyle(
                          color: JcfColors.inkOnLight,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 15.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_notice != null) ...[
                const SizedBox(height: 12),
                Text(_notice!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFE07B12))),
              ],
              const SizedBox(height: 20),
              AuthPrimaryButton(
                label: t.continueAsGuest,
                onPressed: () => context.go('/stay-connected'),
              ),
              const SizedBox(height: 12),
              AuthOutlinedButton(
                label: _busy ? '…' : t.checkAgain,
                onPressed: _busy ? null : _checkAgain,
              ),
              const SizedBox(height: 10),
              AuthLink(
                label: t.contactSupport,
                underline: true,
                onPressed: () => openExternalUrl('mailto:$kSupportEmail'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
