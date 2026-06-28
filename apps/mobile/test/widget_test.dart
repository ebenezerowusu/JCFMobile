import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jcf_mobile/main.dart';

void main() {
  testWidgets('first run shows splash then onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({}); // onboarding not seen

    await tester.pumpWidget(const ProviderScope(child: JcfApp()));

    // Splash is visible first.
    expect(find.text('Jan Cosmic Foundation'), findsOneWidget);

    // Advance past the splash delay -> onboarding.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Learn & grow'), findsOneWidget);
    expect(find.text('Get started'), findsNothing); // not on the first page
  });
}
