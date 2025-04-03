import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/firestore_error_util.dart';
import '../service/message_service.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  final FirestoreErrorUtil firestoreErrorUtil =
      FirestoreErrorUtil();
  return MessageService(firestoreErrorUtil: firestoreErrorUtil);
});
