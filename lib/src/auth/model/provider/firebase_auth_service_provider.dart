import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/user_service_provider.dart'; // Import for the user service provider
import '../service/firebase_auth_service.dart'; // Import the FirebaseAuthService
import '../util/firebase_auth_error_util.dart'; // Import utility for handling FirebaseAuth errors

// A provider that creates and provides an instance of FirebaseAuthService.
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  // Access the FirebaseAuth instance to interact with Firebase authentication.
  final firebaseAuth = FirebaseAuth.instance;

  // Access the FirebaseAuthErrorUtil to handle Firebase authentication errors.
  final firebaseAuthErrorUtil = FirebaseAuthErrorUtil();

  // Watch the userServiceProvider to get the instance of UserService.
  final userService = ref.watch(userServiceProvider);

  // Return an instance of FirebaseAuthService with the necessary dependencies.
  return FirebaseAuthService(
    firebaseAuth:
        firebaseAuth, // FirebaseAuth instance for authentication operations
    firebaseAuthErrorUtil:
        firebaseAuthErrorUtil, // FirebaseAuthErrorUtil instance for error handling
    userService: userService, // UserService instance for managing user data
  );
});
