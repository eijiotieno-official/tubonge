import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import 'user_service_provider.dart';

/// A Riverpod provider that streams the [UserModel] of the currently authenticated user.
/// If the user is not logged in, it returns an error.
final currentUserInfoProvider = StreamProvider<UserModel>(
  (ref) {
    // Watch the UserService instance from the provider
    final UserService userService = ref.watch(userServiceProvider);

    // Get the current user's ID from FirebaseAuth
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    // If there's no user logged in, return an error stream
    if (userId == null) {
      return Stream.error('User not logged in');
    }

    // Stream user data using the UserService and map the result
    return userService.streamUser(userId).map(
          (either) => either.fold(
            // If there's an error, throw it so the provider can handle it
            (error) => throw error,
            // If successful, return the user model
            (user) => user,
          ),
        );
  },
);
