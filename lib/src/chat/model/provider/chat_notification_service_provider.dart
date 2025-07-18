import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/chat_notification_service.dart';

final chatNotificationServiceProvider =
    Provider<ChatNotificationService>((ref) {
  return ChatNotificationService();
});
