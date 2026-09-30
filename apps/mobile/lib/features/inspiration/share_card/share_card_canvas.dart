import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

import '../../../core/brand.dart';
import 'share_card_models.dart';

const _lightText = Color(0xFFFFFDF7);
const _darkText = Color(0xFF102454);
const _gold = Color(0xFFE9A33A);

/// The share card itself.
///
/// One widget draws both the on-screen preview and the exported PNG: the
/// preview is this canvas scaled down, so what the user sees is exactly
/// what is written to the file. All measurements are in export pixels and
/// scaled by [scale].
class ShareCardCanvas extends StatelessWidget {
  const ShareCardCanvas({
    super.key,
    required this.data,
    required this.config,
    required this.scale,
  });

  final ShareCardData data;
  final ShareCardConfiguration config;

  /// 1.0 renders at full export size (e.g. 1080pt); the preview passes a
  /// fraction of that.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = config.format.exportSize;
    final template = data.templateById(config.templateId);
    final asset = template.assetFor(config.format);
    final light = config.textColor == ShareCardTextColorMode.light;
    final textColor = light ? _lightText : _darkText;

    // Safe insets per format, kept clear of social-platform overlays.
    final EdgeInsets padding = config.format == ShareCardFormat.square
        ? const EdgeInsets.all(88)
        : const EdgeInsets.fromLTRB(80, 210, 80, 290);

    return SizedBox(
      width: size.width * scale,
      height: size.height * scale,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (asset != null)
                Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  // A missing background must not block export.
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: Color(0xFF102454),
                  ),
                )
              else
                const ColoredBox(color: Color(0xFF102454)),

              // Deterministic contrast plate from template metadata rather
              // than per-pixel analysis.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: light
                        ? const [Color(0x40061236), Color(0xA6061236)]
                        : const [Color(0x26FFFFFF), Color(0x73FFFFFF)],
                  ),
                ),
              ),

              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: config.alignment.crossAxis,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (config.showLogo) ...[
                      // The official logo, never recoloured or cropped.
                      JcfLogo(size: 132),
                      const SizedBox(height: 44),
                    ],
                    Flexible(
                      child: Text(
                        '“${data.shareExcerpt}”',
                        textAlign: config.alignment.textAlign,
                        maxLines:
                            config.format == ShareCardFormat.square ? 8 : 10,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: config.textSize.quoteSize(config.format),
                          height: 1.34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (config.showSource && data.hasSource) ...[
                      const SizedBox(height: 28),
                      Text(
                        '— ${data.sourceLabel}',
                        textAlign: config.alignment.textAlign,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: light ? _gold : const Color(0xFFB07714),
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 56),
                    // The foundation name stays even when the graphical logo
                    // is hidden, per brand policy.
                    Text(
                      'Jan Cosmic Foundation',
                      textAlign: config.alignment.textAlign,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: JcfTypography.bodyFamily,
                        fontSize: 36,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (config.showWebsite &&
                        data.websiteLabel.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        data.websiteLabel,
                        textAlign: config.alignment.textAlign,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: light
                              ? const Color(0xFFB9C9F5)
                              : const Color(0xFF667085),
                          fontFamily: JcfTypography.bodyFamily,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
