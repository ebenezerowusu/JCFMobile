import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'share_card_canvas.dart';
import 'share_card_models.dart';

/// Renders the share card at full export resolution.
///
/// The canvas is mounted off-screen in an overlay so the same widget tree
/// that draws the preview produces the file — the preview is never upscaled.
Future<Uint8List> renderShareCard({
  required BuildContext context,
  required ShareCardData data,
  required ShareCardConfiguration config,
}) async {
  final key = GlobalKey();
  final overlay = Overlay.of(context);
  final size = config.format.exportSize;
  // Draw at a third of export size and capture at 3x, which keeps the
  // off-screen layout small while producing the full 1080px output.
  const captureRatio = 3.0;
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -(size.width / captureRatio) - 50,
      top: -(size.height / captureRatio) - 50,
      child: Material(
        color: Colors.transparent,
        child: Directionality(
          textDirection: Directionality.of(context),
          child: MediaQuery(
            // The card must never inherit the reader's text scale.
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: RepaintBoundary(
              key: key,
              child: ShareCardCanvas(
                data: data,
                config: config,
                scale: 1 / captureRatio,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  try {
    // Let the overlay lay out and paint before capturing.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: captureRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null || bytes.lengthInBytes == 0) {
      throw StateError('share card produced no bytes');
    }
    return bytes.buffer.asUint8List();
  } finally {
    entry.remove();
  }
}

/// A filesystem-safe name; the timestamp is local time, the identity is the
/// slug.
String shareCardFileName(ShareCardData data, ShareCardFormat format) {
  final slug = data.slug
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\-]+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
  final trimmed = slug.length > 60 ? slug.substring(0, 60) : slug;
  final now = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  final stamp = '${now.year}${two(now.month)}${two(now.day)}_'
      '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  return 'jcf_daily_inspiration_${trimmed}_${format.id}_$stamp.png';
}
