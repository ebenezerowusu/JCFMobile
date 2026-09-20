import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jcf_mobile/features/onboarding/splash_screen.dart';
import 'package:jcf_mobile/main.dart';

void main() {
  testWidgets('first run: splash -> welcome -> Begin -> onboarding',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // onboarding not seen

    await tester.pumpWidget(const ProviderScope(child: JcfApp()));

    // Splash is visible first (the comp image carries the branding).
    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance past the splash delay -> welcome.
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.text('A Path of Freedom and Awareness'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);

    // Begin -> onboarding carousel.
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    expect(find.text('Wisdom for the journey'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Continue'), findsNothing); // not on the first page

    // Walk to the last page: Next label becomes Continue, Skip becomes Back.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Learn, gather and serve'), findsOneWidget);
    expect(find.text('3 of 3'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    // Continue -> language chooser.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    // Select Français; it becomes the highlighted choice.
    await tester.tap(find.text('Français'));
    await tester.pump();
    expect(find.byIcon(Icons.check), findsOneWidget);

    // More languages reveals the coming-soon set (scroll down to it).
    await tester.tap(find.text('More languages'));
    await tester.pump();
    await tester.dragUntilVisible(
        find.text('Twi'), find.byType(ListView), const Offset(0, -200));
    await tester.pump();
    expect(find.text('Twi'), findsOneWidget);
    expect(find.text('Coming soon'), findsWidgets);
    await tester.pumpAndSettle(); // let list momentum die before tapping

    // Continue -> path chooser. Having picked Français, the app now renders
    // in French — proving the l10n foundation end to end.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Comment souhaitez-vous\ncontinuer ?'), findsOneWidget);
    expect(find.text('Membre ou étudiant'), findsOneWidget);
    expect(find.text('Continuer en invité'), findsOneWidget);

    // Sign In -> the sign-in options screen (design 9), in French.
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Bon retour'), findsOneWidget);
    expect(find.text('Continuer avec le téléphone'), findsOneWidget);

    // Continue with Email -> OTP entry with the email field.
    await tester.ensureVisible(find.text("Continuer avec l'e-mail"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Continuer avec l'e-mail"));
    await tester.pumpAndSettle();
    expect(find.text('Adresse e-mail'), findsOneWidget);
    expect(find.text('Envoyer le code'), findsOneWidget);

    // Switch to the phone screen: country dial code + phone field.
    await tester.ensureVisible(find.text('Utiliser le téléphone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utiliser le téléphone'));
    await tester.pumpAndSettle();
    expect(find.text('+233'), findsOneWidget);
    expect(find.text('Numéro de téléphone'), findsOneWidget);
    expect(find.text('Utiliser l\'e-mail'), findsOneWidget);

    // Back out to the path chooser.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Continue as Guest -> notification opt-in (scroll it into view first).
    await tester.ensureVisible(find.text('Continuer en invité'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer en invité'));
    await tester.pumpAndSettle();
    expect(find.text('Restez connecté'), findsOneWidget);
    expect(find.text('Inspiration quotidienne'), findsOneWidget);
    expect(find.text('Rappels de pratique'), findsOneWidget);
    expect(find.text('Actualités des programmes'), findsOneWidget);
    expect(find.text('Activer les notifications'), findsOneWidget);
    expect(find.text('Pas maintenant'), findsOneWidget);
  });
}
