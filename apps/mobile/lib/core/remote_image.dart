import 'package:flutter/material.dart';

/// Remote image first, packaged asset as the intentional fallback, neutral
/// placeholder last.
///
/// It lived in the member home's widgets and was named MemberImage, but
/// six other features import it and none of them are about membership.
/// Only the name and the file ever tied it to a tier.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    required this.asset,
    required this.width,
    required this.height,
    this.semanticLabel,
  });

  final String url;
  final String asset;
  final double width;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    // A card may pass double.infinity; fall back to the viewport width so the
    // decode hint stays finite and positive.
    final logical = width.isFinite && width > 0
        ? width
        : MediaQuery.sizeOf(context).width;
    final cacheWidth = logical > 0 ? (logical * dpr).round() : null;
    final fallback = Image.asset(
      asset,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      excludeFromSemantics: semanticLabel == null,
      semanticLabel: semanticLabel,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: const Color(0xFFEAF2FF),
      ),
    );
    if (url.isEmpty) return fallback;
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: cacheWidth,
      excludeFromSemantics: semanticLabel == null,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
