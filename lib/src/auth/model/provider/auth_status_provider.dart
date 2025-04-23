import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A StreamProvider that tracks the authentication status of the user.
final authStatusProvider = StreamProvider<bool>((ref) {
  // `authStateChanges()` listens to changes in the authentication state.
  // It emits `true` if a user is signed in, `false` if the user is signed out.
  return FirebaseAuth.instance.authStateChanges().map((user) => user != null);
});
