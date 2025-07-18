import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/service/firebase_auth_service.dart';

class DeleteAccountViewModel extends StateNotifier<AsyncValue<bool>> {
  DeleteAccountViewModel() : super(const AsyncValue.data(false));

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  Future<void> call() async {
    state = const AsyncValue.loading();

    final Either<String, bool> result =
        await _firebaseAuthService.deleteAccount();

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final deleteAccountProvider =
    StateNotifierProvider.autoDispose<DeleteAccountViewModel, AsyncValue<bool>>(
  (ref) {
    return DeleteAccountViewModel();
  },
);
