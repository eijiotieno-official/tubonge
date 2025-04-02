import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../providers/auth_service_provider.dart';
import '../services/auth_service.dart';

final Logger _logger = Logger();

class DeleteAccountNotifier extends StateNotifier<AsyncValue<bool>> {
  DeleteAccountNotifier({
    required this.authService,
  }) : super(const AsyncValue.data(false));

  final AuthService authService;

  Future<void> call() async {
    _logger.i("Delete account process started.");

    state = const AsyncValue.loading();

    final Either<String, bool> result = await authService.deleteAccount();

    result.fold(
      (error) => _logger.e("Delete account failed: $error"),
      (success) => _logger.i("Account deleted successfully."),
    );

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountNotifier, AsyncValue<bool>>((ref) {
      
  final AuthService authService = ref.read(authServiceProvider);

  return DeleteAccountNotifier(
    authService: authService,
  );
});
