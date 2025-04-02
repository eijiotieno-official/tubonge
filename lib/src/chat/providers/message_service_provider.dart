import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firestore_error_provider.dart';
import '../../../core/services/firestore_error_service.dart';
import '../services/message_service.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  final FirestoreErrorService firestoreErrorService =
      ref.watch(firestoreErrorServiceProvider);
  return MessageService(firestoreErrorService: firestoreErrorService);
});
