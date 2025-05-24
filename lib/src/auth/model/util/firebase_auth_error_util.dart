import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthErrorUtil {
  String handleException(Object e) {
    if (e is FirebaseAuthException) {
      return _getPhoneAuthErrorMessage(e);
    }

    return 'An unexpected error occurred: $e';
  }

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
        return exception.message ??
            'An unknown error occurred. Please try again later.';
    }
  }
}
