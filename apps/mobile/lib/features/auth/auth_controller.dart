import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcf_models/jcf_models.dart';

import 'auth_repository.dart';

/// Holds the authenticated member (or null for a guest).
class AuthController extends AsyncNotifier<Member?> {
  @override
  Future<Member?> build() {
    return ref.read(authRepositoryProvider).currentMember();
  }

  Future<void> requestCode(String identifier) {
    return ref.read(authRepositoryProvider).requestCode(identifier);
  }

  Future<void> verify(String identifier, String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).verifyCode(identifier, code),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, Member?>(AuthController.new);

/// Convenience: is a member currently logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).asData?.value != null;
});
