import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../models/message_model.dart';
import '../service/message_service.dart';

class SendMessageController extends StateNotifier<AsyncValue<bool>> {
  final Message _message;
  final MessageService _messageService = MessageService();
  final Logger _logger = Logger();

  SendMessageController(this._message) : super(const AsyncValue.data(false)) {
    _send();
  }

  void _send() {
    state = const AsyncValue.loading();

    final result = _messageService.createMessage(_message);

    state = result.fold(
      (error) {
        _logger.e('Failed to send message: $error');
        return AsyncValue.error(error, StackTrace.current);
      },
      (message) {
        _logger.i('Message sent successfully: $message');
        return const AsyncValue.data(true);
      },
    );
  }
}

final sendMessageProvider = StateNotifierProvider.family<SendMessageController,
    AsyncValue<bool>, Message>(
  (ref, message) {
    return SendMessageController(message);
  },
);
