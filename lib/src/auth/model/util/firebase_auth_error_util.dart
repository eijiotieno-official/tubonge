import 'package:firebase_auth/firebase_auth.dart';

/// Utility class for handling Firebase Auth exceptions and converting them
/// into user-friendly error messages.
class FirebaseAuthErrorUtil {
  /// Entry point to handle any exception thrown during Firebase Auth operations.
  /// If the exception is a [FirebaseAuthException], it maps it to a
  /// phone-auth-specific error message; otherwise returns a generic error.
  String handleException(Object e) {
    if (e is FirebaseAuthException) {
      return _getPhoneAuthErrorMessage(e);
    }
    // Fallback for non-FirebaseAuth exceptions
    return 'An unexpected error occurred: $e';
  }

  /// Maps [FirebaseAuthException] codes related to phone authentication
  /// to readable error messages.
  String _getPhoneAuthErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-verification-code':
        return 'The SMS verification code is invalid. Please check the code and try again.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid. Please request a new code.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later or contact support.';
      case 'missing-phone-number':
        return 'No phone number provided. Please enter a valid phone number.';
      case 'session-expired':
        return 'The SMS code has expired. Please request a new verification code.';
      default:
        // Use the exception's own message if available, otherwise a generic fallback
        return exception.message ??
            'An unknown error occurred. Please try again later.';
    }
  }
}
