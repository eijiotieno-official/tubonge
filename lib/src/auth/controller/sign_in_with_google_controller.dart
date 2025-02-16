import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_service_provider.dart';
import '../service/auth_service.dart';

class SignInWithGoogleNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthService _authService;
  SignInWithGoogleNotifier(this._authService) : super(AsyncValue.data(false));

  Future<void> call() async {
    state = AsyncValue.loading();

    final result = await _authService.signInWithGoogle();

    result.fold(
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
      (success) {
        state = AsyncValue.data(success);
      },
    );
  }
}

final signInWithGoogleProvider =
    StateNotifierProvider<SignInWithGoogleNotifier, AsyncValue<bool>>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return SignInWithGoogleNotifier(authService);
  },
);
