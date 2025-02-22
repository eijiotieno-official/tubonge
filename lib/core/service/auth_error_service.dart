import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorService {
  String handleException({
    required Object exception,
    String? email,
  }) {
    if (exception is FirebaseAuthException) {
      return _getErrorMessage(exception: exception);
    } else {
      return 'An unexpected error occurred: $exception';
    }
  }

  String _getErrorMessage({required FirebaseAuthException exception}) {
    switch (exception.code) {
      // Google Sign-In Errors
      case 'user-cancelled':
      case 'sign-in-canceled':
        return 'Sign-in was cancelled. Please try again.';
      case 'account-exists-with-different-credential':
      case 'auth/account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method. Please use a different method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'network-request-failed':
      case 'auth/network-request-failed':
        return 'Network error occurred. Please check your internet connection and try again.';
      case 'missing-email':
        return 'No email found. Please ensure your account has an associated email.';

      // Email and Password Sign-In Errors
      case 'email-already-in-use':
      case 'auth/email-already-in-use':
        return 'This email is already in use. Please use a different email address.';
      case 'invalid-email':
      case 'auth/invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';

      // Other Authentication Errors
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'auth/invalid-api-key':
        return 'Invalid API key. Please check your configuration.';
      case 'auth/invalid-user-token':
        return 'Invalid user token. Please reauthenticate.';
      case 'auth/invalid-credential':
        return 'Invalid credentials provided. Please try again.';

      // Default case for unknown errors
      default:
        return exception.message ??
            'An unknown error occurred. Please try again later.';
    }
  }
}
