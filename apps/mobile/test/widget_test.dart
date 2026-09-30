import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jcf_mobile/features/splash/app_bootstrap_service.dart';
import 'package:jcf_mobile/features/splash/splash_state.dart';
import 'package:jcf_mobile/features/splash/startup_splash_screen.dart';
import 'package:jcf_mobile/main.dart';

/// Bootstrap without the network, so this test stays about the first-run
/// flow rather than about how long a refused connection takes to fail.
class _FirstRunBootstrap implements AppBootstrapService {
  @override
  Future<BootstrapResult> run() async => const BootstrapResult(
        stage: SplashStage.ready,
        destination: '/onboarding',
      );
}

void main() {
  testWidgets('first run: splash -> onboarding -> welcome -> sign in',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // onboarding not seen

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appBootstrapServiceProvider
            .overrideWithValue(_FirstRunBootstrap()),
      ],
      child: const JcfApp(),
    ));

    // Splash is visible first.
    expect(find.byType(StartupSplashScreen), findsOneWidget);

    // Bootstrap sends a first-time user straight to onboarding. Welcome
    // now comes after it, not before.
    // Explicit pumps, not pumpAndSettle: the loading dots repeat forever
    // by design, so nothing would ever settle while the splash is up.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pumpAndSettle();

    // Page 1 of the rebuilt carousel.
    expect(find.text('TEACHINGS'), findsOneWidget);
    expect(find.text('Discover timeless teachings'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Back'), findsNothing); // nothing to go back to

    // Next -> InnerSpace, which can go back.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Go deeper within'), findsOneWidget);

    // Next -> Community & Service: no Skip, and the primary action
    // becomes Get started.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Grow together. Serve with purpose.'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    expect(find.text('Get started'), findsOneWidget);

    // Get started -> Welcome.
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Begin your journey within'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);

    // The account action -> the sign-in options screen (design 9).
    await tester.tap(find.text('Sign in or create account'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Phone'), findsOneWidget);
    // The journey ends here: what happens inside authentication is the
    // auth tests' subject, not this one's.
  });
}
