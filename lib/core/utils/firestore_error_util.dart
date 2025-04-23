import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class for handling and mapping Firestore exceptions to user-friendly messages
class FirestoreErrorUtil {
  /// Maps specific [FirebaseException] codes to human-readable error messages
  String _getErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'unavailable':
        return 'The Firestore service is currently unavailable. Please try again later.';
      case 'not-found':
        return 'The requested resource was not found.';
      case 'already-exists':
        return 'The item you are trying to create already exists.';
      case 'cancelled':
        return 'The operation was cancelled. Please try again.';
      case 'data-loss':
        return 'Data corruption or loss has occurred.';
      case 'deadline-exceeded':
        return 'The operation took too long to complete. Please try again.';
      case 'failed-precondition':
        return 'The operation could not be performed due to a failed precondition.';
      case 'internal':
        return 'An internal error occurred. Please try again later.';
      case 'invalid-argument':
        return 'Invalid data was provided. Please check your input.';
      case 'resource-exhausted':
        return 'Quota has been exceeded. Please try again later.';
      case 'unauthenticated':
        return 'You are not authenticated. Please sign in and try again.';
      case 'unimplemented':
        return 'The requested operation is not supported.';
      default:
        // If the error code isn't explicitly handled, return the default message from Firestore
        return 'An unexpected error occurred: ${e.message}';
    }
  }

  /// Entry point to handle any caught exception and return a safe error message
  String handleException(Object exception) {
    if (exception is FirebaseException) {
      // Handle known Firebase exceptions
      return _getErrorMessage(exception);
    } else {
      // Fallback for non-Firebase exceptions
      return 'An unexpected error occurred: $exception';
    }
  }
}
