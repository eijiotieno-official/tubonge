import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/user_service.dart';
import '../utils/firestore_error_util.dart';

/// A Riverpod provider that supplies a [UserService] instance
final userServiceProvider = Provider<UserService>(
  (ref) {
    // Instantiate FirestoreErrorUtil to handle Firestore-related errors
    final firestoreErrorUtil = FirestoreErrorUtil();

    // Create and return the UserService instance with the required dependency
    return UserService(firestoreErrorUtil: firestoreErrorUtil);
  },
);
