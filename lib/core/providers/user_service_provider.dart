import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/user_service.dart';
import '../utils/firestore_error_util.dart';

final userServiceProvider = Provider<UserService>(
  (ref) {
    final firestoreErrorUtil = FirestoreErrorUtil();
    return UserService(firestoreErrorUtil: firestoreErrorUtil);
  },
);
