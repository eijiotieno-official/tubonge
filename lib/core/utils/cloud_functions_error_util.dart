import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctionsErrorUtil {
  static String _getErrorMessage(FirebaseFunctionsException e) {
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
        return 'An unexpected error occurred: ${e.message}';
    }
  }

  static String handleException(Object exception) {
    if (exception is FirebaseFunctionsException) {
      return _getErrorMessage(exception);
    } else {
      return 'An unexpected error occurred: $exception';
    }
  }
}
