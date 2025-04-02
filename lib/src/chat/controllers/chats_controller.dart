import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/message_service.dart';
import '../providers/chat_service_provider.dart';
import '../providers/message_service_provider.dart';

final Logger _logger = Logger();

class ChatsNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final ChatService _chatService;
  final MessageService _messageService;
  final String? _userId;

  ChatsNotifier(this._chatService, this._messageService, this._userId)
      : super(AsyncValue.loading()) {
    _fetch();
  }

  void _fetch() {
    if (_userId == null) {
      _logger.i("User is not authenticated. No chats to fetch.");
      state = AsyncValue.data(<Chat>[]);
    } else {
      _logger.i("Fetching chats for user: $_userId");
      
      final Stream<Either<String, List<Chat>>> chatsStreamResult =
          _chatService.subscribeToChats(_userId);

      chatsStreamResult.listen(
        (chatsEither) => chatsEither.fold(
          (error) {
            _logger.e("Error subscribing to chats: $error");
            state = AsyncValue.error(error, StackTrace.current);
          },
          (chats) {
            _logger.i("Received ${chats.length} chats.");
            if (chats.isEmpty) {
              _logger.i("No chats found for user: $_userId");
              state = AsyncValue.data(<Chat>[]);
            } else {
              state = AsyncValue.data(chats);
              for (var chat in chats) {
                List<Chat> currentChats = state.value ?? [];

                int chatIndex = currentChats
                    .indexWhere((test) => test.chatId == chat.chatId);

                if (chatIndex > -1) {
                  _logger.i("Subscribing to messages for chat: ${chat.chatId}");
                  
                  List<Message> initialMessages =
                      currentChats[chatIndex].messages;

                  final Stream<Either<String, List<Message>>>
                      messagesStreamResult =
                      _messageService.subscribeToMessages(
                          chatId: chat.chatId,
                          initialMessages: initialMessages,
                          userId: _userId);

                  messagesStreamResult.listen(
                    (messagesEither) => messagesEither.fold(
                      (error) {
                        _logger.e(
                            "Error subscribing to messages for chat ${chat.chatId}: $error");
                        state = AsyncValue.error(error, StackTrace.current);
                      },
                      (messages) {
                        _logger.i(
                            "Received ${messages.length} messages for chat: ${chat.chatId}");
                        currentChats[chatIndex] = currentChats[chatIndex]
                            .copyWith(messages: messages);
                        state = AsyncValue.data(currentChats);
                      },
                    ),
                  );
                } else {
                  _logger.w(
                      "Chat with id ${chat.chatId} not found in current state.");
                }
              }
            }
          },
        ),
      );
    }
  }
}

final chatsProvider =
    StateNotifierProvider<ChatsNotifier, AsyncValue<List<Chat>>>((ref) {
  final ChatService chatService = ref.watch(chatsServiceProvider);
  final MessageService messageService = ref.watch(messageServiceProvider);
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  return ChatsNotifier(chatService, messageService, userId);
});
