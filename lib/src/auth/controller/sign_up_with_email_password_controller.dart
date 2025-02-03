import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_service_provider.dart';
import '../service/auth_service.dart';

class SignUpWithEmailPasswordController extends StateNotifier<AsyncValue> {
  final AuthService _authService;
  SignUpWithEmailPasswordController(this._authService)
      : super(AsyncValue.data(false));

  Future<void> call({
    required String email,
    required String password,
  }) async {
    state = AsyncValue.loading();

    final signUpResult = await _authService.signUpWithEmailAndPassword(
        email: email, password: password);

    signUpResult.fold(
      (error) {
        state = AsyncValue.data(error);
      },
      (success) {
        state = AsyncValue.data(success);
      },
    );
  }
}

final signUpWithEmailPasswordProvider =
    StateNotifierProvider<SignUpWithEmailPasswordController, AsyncValue>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return SignUpWithEmailPasswordController(authService);
  },
);
