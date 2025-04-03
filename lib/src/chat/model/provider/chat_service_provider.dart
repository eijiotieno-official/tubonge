import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/firestore_error_util.dart';
import '../service/chat_service.dart';

final chatsServiceProvider = Provider<ChatService>((ref) {
  final FirestoreErrorUtil firestoreErrorUtil = FirestoreErrorUtil();
  return ChatService(firestoreErrorUtil: firestoreErrorUtil);
});
