import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jcf_models/jcf_models.dart';

import 'package:jcf_mobile/features/auth/auth_controller.dart';
import 'package:jcf_mobile/features/lessons/lessons_repository.dart';
import 'package:jcf_mobile/main.dart';

/// Auth controller that reports a guest without touching secure storage.
class _GuestAuth extends AuthController {
  @override
  Future<Member?> build() async => null;
}

void main() {
  testWidgets('boots to the Lessons tab with an empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_GuestAuth.new),
          lessonsListProvider.overrideWith(
            (ref) async => const Paginated<Teaching>(count: 0, results: []),
          ),
        ],
        child: const JcfApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lessons'), findsWidgets); // app bar + nav label
    expect(find.text('No lessons yet.'), findsOneWidget);
  });
}
