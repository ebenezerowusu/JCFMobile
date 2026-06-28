import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jcf_models/jcf_models.dart';

import 'package:jcf_mobile/features/auth/auth_controller.dart';
import 'package:jcf_mobile/features/engagement/engagement_repository.dart';
import 'package:jcf_mobile/main.dart';

/// Auth controller that reports a guest without touching secure storage.
class _GuestAuth extends AuthController {
  @override
  Future<Member?> build() async => null;
}

void main() {
  testWidgets('boots to Home with an empty announcements state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_GuestAuth.new),
          announcementsProvider.overrideWith(
            (ref) async => const Paginated<Announcement>(count: 0, results: []),
          ),
        ],
        child: const JcfApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('No announcements yet.'), findsOneWidget);
    expect(find.text('Home'), findsWidgets); // nav label
  });
}
