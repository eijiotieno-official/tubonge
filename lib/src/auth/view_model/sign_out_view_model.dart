import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';

class SignOutViewModel extends StateNotifier<AsyncValue<bool>> {
  final FirebaseAuthService _firebaseAuthService;
  SignOutViewModel(this._firebaseAuthService)
      : super(const AsyncValue.data(false));

  final Logger _logger = Logger();

  Future<void> call() async {
    _logger.i("Sign out process started.");
    state = const AsyncValue.loading();

    final Either<String, bool> result = await _firebaseAuthService.signOut();

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final signOutProvider =
    StateNotifierProvider<SignOutViewModel, AsyncValue<bool>>(
  (ref) {
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);
    return SignOutViewModel(firebaseAuthService);
  },
);
