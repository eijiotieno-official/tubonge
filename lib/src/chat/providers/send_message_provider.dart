import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../models/message_model.dart';
import '../services/message_service.dart';
import 'message_service_provider.dart';

final Logger _logger = Logger();

final sendMessageProvider = Provider.family<Either<String, Message>, Message>(
  (ref, message) {
    final MessageService messageService = ref.watch(messageServiceProvider);

    _logger.i("Sending message: $message");

    final Either<String, Message> result =
        messageService.createMessage(message);

    result.fold(
      (error) => _logger.e("Error sending message: $error"),
      (sentMessage) => _logger.i("Message sent successfully: $sentMessage"),
    );

    return result;
  },
);
