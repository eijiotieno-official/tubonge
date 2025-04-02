

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_error_service.dart';

final firestoreErrorServiceProvider = Provider<FirestoreErrorService>((ref) {
  return FirestoreErrorService();
});