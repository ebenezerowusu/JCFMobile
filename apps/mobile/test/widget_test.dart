import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jcf_mobile/main.dart';

void main() {
  testWidgets('first run: splash -> welcome -> Begin -> onboarding',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // onboarding not seen

    await tester.pumpWidget(const ProviderScope(child: JcfApp()));

    // Splash is visible first.
    expect(find.text('JAN COSMIC FOUNDATION'), findsOneWidget);
    expect(find.text('Freedom. Awake and aware.'), findsOneWidget);

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
  });
}
