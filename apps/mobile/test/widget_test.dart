import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jcf_mobile/main.dart';

void main() {
  testWidgets('renders JCF App home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JcfApp()));
    await tester.pumpAndSettle();

    expect(find.text('JCF App'), findsOneWidget);
    expect(find.text('Jan Cosmic Foundation'), findsOneWidget);
  });
}
