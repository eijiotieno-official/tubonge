import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_service_provider.dart';
import '../service/auth_service.dart';

class LogoutController extends StateNotifier<AsyncValue> {
  final AuthService _authService;
  LogoutController(this._authService) : super(AsyncValue.data(false));

  Future<void> call() async {
    state = AsyncValue.loading();

    final logoutResult = await _authService.logout();

    logoutResult.fold(
      (error) {
        state = AsyncValue.data(error);
      },
      (success) {
        state = AsyncValue.data(success);
      },
    );
  }
}

final logoutProvider = StateNotifierProvider<LogoutController, AsyncValue>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return LogoutController(authService);
  },
);
