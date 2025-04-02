import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firestore_error_provider.dart';
import '../../../core/services/firestore_error_service.dart';
import '../services/chat_service.dart';

final chatsServiceProvider = Provider<ChatService>((ref) {
  final FirestoreErrorService firestoreErrorService = ref.watch(firestoreErrorServiceProvider);
  return ChatService(firestoreErrorService: firestoreErrorService);
});
