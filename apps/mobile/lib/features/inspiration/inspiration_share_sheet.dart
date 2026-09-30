import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jcf_ui/jcf_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/brand.dart';
import '../../l10n/app_localizations.dart';
import 'inspiration_detail_repository.dart';

const _sub = Color(0xFF667085);
const _ink = Color(0xFF172033);

/// The square share card. Rendered live so every word is real text — the
/// background asset carries no text of its own.
class InspirationShareCard extends StatelessWidget {
  const InspirationShareCard({super.key, required this.detail, this.size = 320});

  final DailyInspirationDetail detail;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Everything scales from the card's own size, so the preview and the
    // 1080px export are identical apart from resolution.
    final k = size / 320;
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18 * k),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/daily_inspiration_detail/'
              'daily_inspiration_share_background.webp',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66102454), Color(0xCC061236)],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(26 * k),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JcfLogo(size: 40 * k),
                  SizedBox(height: 14 * k),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        '“${detail.shareExcerpt}”',
                        // Long translations shrink to fit rather than
                        // dropping below a readable size.
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 21 * k,
                          height: 1.32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (detail.author case final author?) ...[
                    SizedBox(height: 8 * k),
                    Text(
                      '— $author',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFFE9A33A),
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 13 * k,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  SizedBox(height: 14 * k),
                  Text(
                    'Jan Cosmic Foundation',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 14 * k,
                      letterSpacing: 0.6 * k,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3 * k),
                  Text(
                    _shortLink(detail.canonicalUrl),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFB9C9F5),
                      fontFamily: JcfTypography.bodyFamily,
                      fontSize: 11 * k,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortLink(String url) =>
      url.replaceFirst(RegExp(r'^https?://'), '');
}

/// Renders the share card off-screen at export resolution and shares it.
Future<void> shareInspirationImage(
    BuildContext context, DailyInspirationDetail detail) async {
  final messenger = ScaffoldMessenger.of(context);
  final t = AppLocalizations.of(context)!;
  final key = GlobalKey();
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      // Off-screen but laid out, so the boundary can paint.
      left: -2000,
      top: -2000,
      child: Material(
        color: Colors.transparent,
        child: RepaintBoundary(
          key: key,
          child: MediaQuery(
            // The card must not inherit the reader's text scale.
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: InspirationShareCard(detail: detail, size: 360),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  try {
    // Let the overlay lay out and paint before capturing.
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    // 360 logical * 3 = 1080px square.
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('encode failed');

    // Shared from memory, so there is no temporary file to clean up.
    await SharePlus.instance.share(ShareParams(
      files: [
        XFile.fromData(
          bytes.buffer.asUint8List(),
          name: 'jcf-inspiration-${detail.slug}.png',
          mimeType: 'image/png',
        ),
      ],
      text: '${detail.shareExcerpt}\n\n${detail.canonicalUrl}',
    ));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(t.genericError)));
  } finally {
    entry.remove();
  }
}

/// The share options sheet.
Future<void> showInspirationShareSheet(
    BuildContext context, DailyInspirationDetail detail) {
  final t = AppLocalizations.of(context)!;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: InspirationShareCard(detail: detail, size: 210),
            ),
            const SizedBox(height: 18),
            _ShareOption(
              icon: Icons.image_rounded,
              label: t.shareAsImage,
              onTap: () {
                Navigator.of(sheetContext).pop();
                // The composer lets the reader choose a style and format.
                context.push('/inspirations/${detail.slug}/share-card');
              },
            ),
            _ShareOption(
              icon: Icons.link_rounded,
              label: t.shareLink,
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await SharePlus.instance
                    .share(ShareParams(text: detail.canonicalUrl));
              },
            ),
            _ShareOption(
              icon: Icons.copy_rounded,
              label: t.copyLink,
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(
                    ClipboardData(text: detail.canonicalUrl));
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                messenger.showSnackBar(
                    SnackBar(content: Text(t.linkCopied)));
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _ShareOption extends StatelessWidget {
  const _ShareOption(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEAF2FF),
                child: Icon(icon, size: 19, color: JcfColors.skyPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: JcfTypography.bodyFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _sub, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
