import 'package:cloud_functions/cloud_functions.dart';

/// Utility class for handling and mapping Firebase Cloud Functions exceptions
class CloudFunctionsErrorUtil {
  /// Maps specific [FirebaseFunctionsException] codes to user-friendly error messages
  String _getErrorMessage(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'invalid-argument':
        return 'Invalid argument provided. Please check your input.';
      case 'failed-precondition':
        return 'The operation could not be performed due to a failed precondition.';
      case 'not-found':
        return 'The requested function or resource was not found.';
      case 'out-of-range':
        return 'The provided value is out of range.';
      case 'unimplemented':
        return 'This functionality is not implemented.';
      case 'internal':
        return 'An internal error occurred. Please try again later.';
      case 'unavailable':
        return 'The Cloud Functions service is currently unavailable. Please try again later.';
      case 'unauthenticated':
        return 'You are not authenticated. Please sign in and try again.';
      default:
        // If the error code isn't handled, return the default message
        return 'An unexpected error occurred: ${e.message}';
    }
  }

  /// Public method to handle any exception and return a user-friendly message
  String handleException(Object exception) {
    if (exception is FirebaseFunctionsException) {
      // Handle known Firebase Functions exceptions
      return _getErrorMessage(exception);
    } else {
      // Fallback for unexpected or non-Firebase exceptions
      return 'An unexpected error occurred: $exception';
    }
  }
}
