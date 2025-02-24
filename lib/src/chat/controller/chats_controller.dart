import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../service/chat_service.dart';
import '../service/message_service.dart';

class ChatsController extends StateNotifier<AsyncValue<List<Chat>>> {
  final ChatService _chatService;
  final MessageService _messageService;
  final Logger _logger = Logger();

  ChatsController(this._chatService, this._messageService)
      : super(AsyncValue.loading()) {
    _logger.i("Starting to fetch chats.");
    _fetch();
  }

  void _fetch() {
    _logger.i("Subscribing to chats stream...");
    Stream<Either<String, List<Chat>>> chatsStream =
        _chatService.subscribeToChats();

    chatsStream.listen(
      (chatsEither) {
        chatsEither.fold(
          (error) {
            _logger.e("Error while fetching chats: $error");
            state = AsyncValue.error(error, StackTrace.current);
          },
          (chats) {
            _logger.i("Received ${chats.length} chats from stream.");
            if (chats.isEmpty) {
              _logger.w("No chats found. Updating state with an empty list.");
              state = AsyncValue.data(<Chat>[]);
            } else {
              state = AsyncValue.data(chats);
              for (var chat in chats) {
                _logger.i("Processing chat with chatId: ${chat.chatId}");
                List<Chat> currentChats = state.value ?? [];
                int chatIndex =
                    currentChats.indexWhere((c) => c.chatId == chat.chatId);

                if (chatIndex == -1) {
                  _logger.w(
                      "Chat with chatId: ${chat.chatId} not found in state.");
                  continue;
                }

                List<Message> initialMessages =
                    currentChats[chatIndex].messages;
                _logger.i(
                    "Subscribing to messages for chat ${chat.chatId} with ${initialMessages.length} initial messages.");

                Stream<Either<String, List<Message>>> messagesStream =
                    _messageService.subscribeToMessages(
                        chatId: chat.chatId, initialMessages: initialMessages);

                messagesStream.listen(
                  (messagesEither) => messagesEither.fold(
                    (error) {
                      _logger.e(
                          "Error fetching messages for chat ${chat.chatId}: $error");
                      state = AsyncValue.error(error, StackTrace.current);
                    },
                    (messages) {
                      _logger.i(
                          "Received ${messages.length} messages for chat ${chat.chatId}.");
                      currentChats[chatIndex] =
                          currentChats[chatIndex].copyWith(messages: messages);
                      state = AsyncValue.data(currentChats);
                    },
                  ),
                  onError: (error) {
                    _logger.e(
                        "Error in messages stream for chat ${chat.chatId}: $error");
                  },
                );
              }
            }
          },
        );
      },
      onError: (error) {
        _logger.e("Error in chats stream subscription: $error");
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }
}

final chatsProvider =
    StateNotifierProvider<ChatsController, AsyncValue<List<Chat>>>(
  (ref) {
    final chatService = ChatService();
    final messageService = MessageService();
    return ChatsController(chatService, messageService);
  },
);
