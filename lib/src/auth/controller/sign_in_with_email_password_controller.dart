import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_service_provider.dart';
import '../service/auth_service.dart';

class SignInWithEmailPasswordController extends StateNotifier<AsyncValue> {
  final AuthService _authService;
  SignInWithEmailPasswordController(this._authService)
      : super(AsyncValue.data(false));

  Future<void> call({
    required String email,
    required String password,
  }) async {
    state = AsyncValue.loading();

    final signInResult = await _authService.signInWithEmailAndPassword(
        email: email, password: password);

    signInResult.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
      (success) {
        state = AsyncValue.data(success);
      },
    );
  }
}

final signInWithEmailPasswordProvider =
    StateNotifierProvider<SignInWithEmailPasswordController, AsyncValue>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return SignInWithEmailPasswordController(authService);
  },
);
