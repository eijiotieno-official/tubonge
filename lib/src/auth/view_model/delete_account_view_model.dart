import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';

/// ViewModel for handling user account deletion.
/// Uses Riverpod's StateNotifier to manage async state.
class DeleteAccountViewModel extends StateNotifier<AsyncValue<bool>> {
  final FirebaseAuthService _firebaseAuthService; // Firebase service dependency

  // Constructor initializes the notifier with a default state of false (not deleted yet)
  DeleteAccountViewModel(this._firebaseAuthService)
      : super(const AsyncValue.data(false));

  final Logger _logger = Logger(); // Logger instance for logging actions

  /// Initiates the account deletion process
  Future<void> call() async {
    _logger.i("Delete account process started.");

    // Set state to loading while deletion is in progress
    state = const AsyncValue.loading();

    // Attempt to delete the account using Firebase service
    final Either<String, bool> result =
        await _firebaseAuthService.deleteAccount();

    // Update the state based on the result
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current), // On failure
      (success) => AsyncValue.data(success), // On success
    );
  }
}

/// Riverpod provider that exposes DeleteAccountViewModel to the app
final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountViewModel, AsyncValue<bool>>(
  (ref) {
    // Watch and retrieve FirebaseAuthService from the provider
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);

    // Return an instance of DeleteAccountViewModel with the injected service
    return DeleteAccountViewModel(firebaseAuthService);
  },
);
