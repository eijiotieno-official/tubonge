import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';

class SignOutViewModel extends StateNotifier<AsyncValue<bool>> {
  final FirebaseAuthService _firebaseAuthService;

  SignOutViewModel(this._firebaseAuthService)
      : super(const AsyncValue.data(false));

  Future<void> call() async {
    state = const AsyncValue.loading();
    final Either<String, bool> result = await _firebaseAuthService.signOut();
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final signOutProvider =
    StateNotifierProvider.autoDispose<SignOutViewModel, AsyncValue<bool>>(
  (ref) {
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);
    return SignOutViewModel(firebaseAuthService);
  },
);
