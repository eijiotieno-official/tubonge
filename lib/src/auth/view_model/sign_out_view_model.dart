import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';

/// ViewModel for handling the user sign-out process.
/// Uses Riverpod's StateNotifier to manage the sign-out state.
class SignOutViewModel extends StateNotifier<AsyncValue<bool>> {
  final FirebaseAuthService
      _firebaseAuthService; // Dependency for Firebase Auth operations

  // Constructor initializes the state as "not signed out"
  SignOutViewModel(this._firebaseAuthService)
      : super(const AsyncValue.data(false));

  final Logger _logger = Logger(); // Logger for monitoring the process

  /// Executes the sign-out operation
  Future<void> call() async {
    _logger.i("Sign out process started.");

    // Set state to loading during sign-out
    state = const AsyncValue.loading();

    // Call the Firebase service to sign out
    final Either<String, bool> result = await _firebaseAuthService.signOut();

    // Update the state based on the result
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current), // On failure
      (success) => AsyncValue.data(success), // On success
    );
  }
}

/// Riverpod provider for exposing the sign-out ViewModel to the app
final signOutProvider =
    StateNotifierProvider<SignOutViewModel, AsyncValue<bool>>(
  (ref) {
    // Retrieve the FirebaseAuthService instance from the provider
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);

    // Return a new instance of SignOutViewModel
    return SignOutViewModel(firebaseAuthService);
  },
);
