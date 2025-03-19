import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/message_model.dart';
import '../service/message_service.dart';
import 'message_service_provider.dart';

class SendMessageNotifier extends StateNotifier<AsyncValue<Message?>> {
  final MessageService _messageService;

  SendMessageNotifier(this._messageService)
      : super(const AsyncValue.data(null));

  void sendMessage(Message message) {
    state = const AsyncValue.loading();

    final result = _messageService.createMessage(message);

    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (sentMessage) => state = AsyncValue.data(sentMessage),
    );
  }
}

final sendMessageProvider =
    StateNotifierProvider<SendMessageNotifier, AsyncValue<Message?>>(
  (ref) {
    final messageService = ref.watch(messageServiceProvider);
    return SendMessageNotifier(messageService);
  },
);

