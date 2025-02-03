import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_service_provider.dart';
import '../service/auth_service.dart';

class SendPasswordResetEmailController extends StateNotifier<AsyncValue> {
  final AuthService _authService;
  SendPasswordResetEmailController(this._authService)
      : super(AsyncValue.data(false));

  Future<void> call(String email) async {
    state = AsyncValue.loading();

    final signUpResult = await _authService.sendPasswordResetEmail(email);

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

final sendPasswordResetEmailProvider =
    StateNotifierProvider<SendPasswordResetEmailController, AsyncValue>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return SendPasswordResetEmailController(authService);
  },
);
