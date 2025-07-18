import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthErrorUtil {
 static String handleException(Object e, {String? phoneNumber}) {
    if (e is FirebaseAuthException) {
      return _getPhoneAuthErrorMessage(e, phoneNumber: phoneNumber);
    }

    return 'An unexpected error occurred: $e';
  }

static String _getPhoneAuthErrorMessage(
    FirebaseAuthException exception, {
    String? phoneNumber,
  }) {
    switch (exception.code) {
      case 'invalid-verification-code':
        if (phoneNumber != null) {
          return 'The verification code sent to $phoneNumber is incorrect. Please check the code and try again.';
        }
        return 'The verification code is incorrect. Please check the code and try again.';
      case 'invalid-verification-id':
        return 'The verification session has expired. Please request a new code.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later or contact support.';
      case 'missing-phone-number':
        return 'No phone number provided. Please enter a valid phone number.';
      case 'session-expired':
        if (phoneNumber != null) {
          return 'The verification code sent to $phoneNumber has expired. Please request a new code.';
        }
        return 'The verification code has expired. Please request a new code.';
      case 'too-many-requests':
        if (phoneNumber != null) {
          return 'Too many verification attempts for $phoneNumber. Please wait before trying again.';
        }
        return 'Too many verification attempts. Please wait before trying again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      default:
        return exception.message ??
            'An unknown error occurred. Please try again later.';
    }
  }
}
