import 'package:flutter/material.dart';
import 'package:jcf_ui/jcf_ui.dart';

/// The JCF logo. Falls back to a branded placeholder if the asset is missing
/// (so the app builds before the real logo.png is added).
class JcfLogo extends StatelessWidget {
  const JcfLogo({super.key, this.size = 96, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: size,
      width: size,
      errorBuilder: (context, _, _) => Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: onDark ? Colors.white10 : JcfColors.heroNavy,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          'JCF',
          style: TextStyle(
            color: JcfColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.32,
          ),
        ),
      ),
    );
  }
}
