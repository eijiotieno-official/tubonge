import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorService {
  String handleException({
    required Object exception,
    String? email,
  }) {
    if (exception is FirebaseAuthException) {
      return _getErrorMessage(exception: exception, email: email);
    } else {
      return 'An unexpected error occurred: $exception';
    }
  }

  String _getErrorMessage({
    required FirebaseAuthException exception,
    String? email,
  }) {
    switch (exception.code) {
      // Google Sign-In Errors
      case 'user-cancelled':
        return 'Google sign-in was cancelled. Please try again.';
      case 'sign-in-canceled':
        return 'Sign-in process was canceled. Please try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method. Please try a different method.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled for this project. Please contact support.';
      case 'network-request-failed':
        return 'Network error occurred. Please check your internet connection and try again.';
      case 'missing-email':
        return 'No email found for the Google account. Please ensure your Google account has an email associated with it.';

      // Email and Password Sign-In Errors
      case 'email-already-in-use':
        return 'An account already exists with the provided email. Please try a different sign-in method.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return "It looks like the email [$email] isn't registered. Please contact your school admin to get registered.";
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for further assistance.';

      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'auth/invalid-api-key':
        return 'The API key used is invalid. Please check your configuration.';
      case 'auth/invalid-user-token':
        return 'Invalid user token. Please reauthenticate and try again.';
      case 'auth/network-request-failed':
        return 'Network request failed. Please check your internet connection.';
      case 'auth/invalid-credential':
        return 'The credentials provided are invalid. Please try again.';
      case 'auth/account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method. Please try a different method.';
      case 'auth/email-already-in-use':
        return 'The email is already in use. Please use a different email address.';
      case 'auth/invalid-email':
        return 'The email provided is not valid. Please try again.';

      // Default case for unknown errors
      default:
        return exception.message ??
            'An unknown error occurred. Please try again later.';
    }
  }
}
