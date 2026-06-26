import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jcf_desktop/main.dart';

void main() {
  testWidgets('renders JCF Admin home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JcfDesktopApp()));
    await tester.pumpAndSettle();

    expect(find.text('JCF Admin'), findsOneWidget);
  });
}
