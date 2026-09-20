import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jcf_ui/jcf_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../core/brand.dart';
import '../auth/auth_widgets.dart';
import 'inspiration_repository.dart';

enum CardStyle { light, cosmic, minimal }

/// Share Inspiration (design/23): a branded quote card in three styles,
/// rendered in-app and shared as an image.
class ShareInspirationScreen extends StatefulWidget {
  const ShareInspirationScreen({super.key, required this.inspiration});

  final Inspiration inspiration;

  @override
  State<ShareInspirationScreen> createState() => _ShareInspirationScreenState();
}

class _ShareInspirationScreenState extends State<ShareInspirationScreen> {
  final _cardKey = GlobalKey();
  CardStyle _style = CardStyle.cosmic;
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final boundary = _cardKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await SharePlus.instance.share(ShareParams(files: [
        XFile.fromData(
          bytes.buffer.asUint8List(),
          name: 'jcf-inspiration.png',
          mimeType: 'image/png',
        ),
      ]));
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back,
                        color: JcfColors.inkOnLight),
                  ),
                  Expanded(
                    child: Text(
                      t.shareInspirationTitle,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                t.shareInspirationSub,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF54689B),
                  fontFamily: JcfTypography.bodyFamily,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              RepaintBoundary(
                key: _cardKey,
                child: _QuoteCard(
                    inspiration: widget.inspiration, style: _style),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.chooseStyle,
                      style: const TextStyle(
                        color: JcfColors.inkOnLight,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    t.differentLooks,
                    style: const TextStyle(
                      color: Color(0xFF54689B),
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final (style, label) in [
                    (CardStyle.light, t.styleLight),
                    (CardStyle.cosmic, t.styleCosmic),
                    (CardStyle.minimal, t.styleMinimal),
                  ]) ...[
                    Expanded(
                      child: _StyleThumb(
                        style: style,
                        label: label,
                        selected: style == _style,
                        onTap: () => setState(() => _style = style),
                      ),
                    ),
                    if (style != CardStyle.minimal) const SizedBox(width: 10),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              AuthPrimaryButton(
                  label: t.shareLabel, busy: _busy, onPressed: _share),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.inspiration, required this.style});

  final Inspiration inspiration;
  final CardStyle style;

  @override
  Widget build(BuildContext context) {
    final cosmic = style == CardStyle.cosmic;
    final minimal = style == CardStyle.minimal;
    final ink = cosmic ? Colors.white : JcfColors.inkOnLight;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: minimal
              ? Colors.white
              : (cosmic ? null : JcfColors.skySurface),
          gradient: cosmic
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF060E4A), Color(0xFF1B3BD8)],
                )
              : null,
          borderRadius: BorderRadius.circular(24),
          border: minimal
              ? Border.all(color: const Color(0xFFD3DDF0))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            JcfLogo(size: minimal ? 56 : 84, onDark: cosmic),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      '“${inspiration.quote}”',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ink,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 21,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '— ${inspiration.author} —',
              style: TextStyle(
                color: cosmic ? const Color(0xFFB9C9F5) : JcfColors.skyPrimary,
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Jan Cosmic Foundation',
              style: TextStyle(
                color: cosmic ? Colors.white70 : const Color(0xFF7C8DB5),
                fontFamily: JcfTypography.bodyFamily,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleThumb extends StatelessWidget {
  const _StyleThumb({
    required this.style,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final CardStyle style;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cosmic = style == CardStyle.cosmic;
    final minimal = style == CardStyle.minimal;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 78,
                decoration: BoxDecoration(
                  color: minimal
                      ? Colors.white
                      : (cosmic ? null : JcfColors.skySurface),
                  gradient: cosmic
                      ? const LinearGradient(
                          colors: [Color(0xFF060E4A), Color(0xFF1B3BD8)])
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? JcfColors.skyPrimary
                        : const Color(0xFFD3DDF0),
                    width: selected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: JcfLogo(size: 44, onDark: cosmic),
              ),
              if (selected)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: JcfColors.skyPrimary,
                    child: Icon(Icons.check, size: 13, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? JcfColors.skyPrimary : const Color(0xFF54689B),
              fontFamily: JcfTypography.bodyFamily,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
