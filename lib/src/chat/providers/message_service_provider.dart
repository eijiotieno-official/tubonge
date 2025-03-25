import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/message_service.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService();
});
