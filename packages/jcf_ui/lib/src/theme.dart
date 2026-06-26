import 'package:flutter/material.dart';

/// JCF design system — pixel-sampled from jancosmicfoundation.org.
/// See product doc §2 "Design system".
class JcfColors {
  JcfColors._();

  static const heroNavy = Color(0xFF141667); // hero bg, CTA fills, dark cards
  static const gold = Color(0xFFD4A843); // primary CTAs, gold italic emphasis
  static const pageCream = Color(0xFFF2EFE9); // all screen backgrounds
  static const headingInk = Color(0xFF000B58); // H1/H2 on cream
  static const bodyText = Color(0xFF3E3B46); // paragraph + UI body
  static const mutedText = Color(0xFF626168); // dates, meta, secondary
  static const articleLink = Color(0xFF003A68); // article titles, links
}

class JcfRadii {
  JcfRadii._();

  static const card = 8.0; // matches JCF website card style
  static const cta = 6.0; // matches "Give" / "Begin Here" buttons
}

class JcfTypography {
  JcfTypography._();

  static const headingFamily = 'Cormorant Garamond'; // gold italic on key words
  static const bodyFamily = 'Inter'; // body, labels, forms (300–500)
}

class JcfTheme {
  JcfTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: JcfColors.heroNavy,
      primary: JcfColors.heroNavy,
      secondary: JcfColors.gold,
      surface: JcfColors.pageCream,
      brightness: Brightness.light,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: JcfColors.pageCream,
      textTheme: base.textTheme.apply(
        fontFamily: JcfTypography.bodyFamily,
        bodyColor: JcfColors.bodyText,
        displayColor: JcfColors.headingInk,
      ).copyWith(
        displayLarge: const TextStyle(
          fontFamily: JcfTypography.headingFamily,
          color: JcfColors.headingInk,
        ),
        headlineMedium: const TextStyle(
          fontFamily: JcfTypography.headingFamily,
          color: JcfColors.headingInk,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JcfColors.gold,
          foregroundColor: JcfColors.heroNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JcfRadii.cta),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JcfRadii.card),
        ),
      ),
    );
  }
}
