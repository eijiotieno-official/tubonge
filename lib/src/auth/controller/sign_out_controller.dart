import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../providers/auth_service_provider.dart';
import '../services/auth_service.dart';

final Logger _logger = Logger();

class SignOutNotifier extends StateNotifier<AsyncValue<bool>> {
  SignOutNotifier({
    required this.authService,
  }) : super(const AsyncValue.data(false));

  final AuthService authService;

  Future<void> call() async {
    _logger.i("Sign out process started.");
    state = const AsyncValue.loading();

    final Either<String, bool> result = await authService.signOut();

    result.fold(
      (error) => _logger.e("Sign out failed: $error"),
      (success) => _logger.i("Signed out successfully."),
    );

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final signOutProvider =
    StateNotifierProvider<SignOutNotifier, AsyncValue<bool>>((ref) {
      
  final AuthService authService = ref.read(authServiceProvider);

  return SignOutNotifier(
    authService: authService,
  );
});
