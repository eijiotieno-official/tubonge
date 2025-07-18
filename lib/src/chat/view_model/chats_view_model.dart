import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/user_util.dart';
import '../model/base/chat_model.dart';
import '../model/base/message_model.dart';
import '../model/service/chat_service.dart';
import '../model/service/message_service.dart';

class ChatsNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  ChatsNotifier() : super(AsyncValue.loading()) {
    _fetch();
  }

  final ChatService _chatService = ChatService();

  final MessageService _messageService = MessageService();

  final String? _userId = UserUtil.currentUserId;

  void _fetch() {
    if (_userId == null) {
      state = AsyncValue.data(<Chat>[]);
    } else {
      final Stream<Either<String, List<Chat>>> chatsStreamResult =
          _chatService.streamChats(_userId);

      chatsStreamResult.listen(
        (chatsEither) => chatsEither.fold(
          (error) {
            state = AsyncValue.error(error, StackTrace.current);
          },
          (chats) {
            if (chats.isEmpty) {
              state = AsyncValue.data(<Chat>[]);
            } else {
              state = AsyncValue.data(chats);
              for (var chat in chats) {
                List<Chat> currentChats = state.value ?? [];

                int chatIndex = currentChats
                    .indexWhere((test) => test.chatId == chat.chatId);

                if (chatIndex > -1) {
                  List<Message> initialMessages =
                      currentChats[chatIndex].messages;

                  final Stream<Either<String, List<Message>>>
                      messagesStreamResult = _messageService.streamMessages(
                          chatId: chat.chatId,
                          initialMessages: initialMessages,
                          userId: _userId);

                  messagesStreamResult.listen(
                    (messagesEither) => messagesEither.fold(
                      (error) {
                        state = AsyncValue.error(error, StackTrace.current);
                      },
                      (messages) {
                        currentChats[chatIndex] = currentChats[chatIndex]
                            .copyWith(messages: messages);
                        state = AsyncValue.data(currentChats);
                      },
                    ),
                  );
                }
              }
            }
          },
        ),
      );
    }
  }

  Chat? getChatById(String? chatId) {
    List<Chat>? currentChats = state.value;

    if (currentChats == null) return null;

    Chat? chat = currentChats.firstWhereOrNull((chat) => chat.chatId == chatId);

    return chat;
  }

  List<Message> getChatMessages(String? chatId) {
    List<Message> messages = getChatById(chatId)?.messages ?? [];

    List<Message> sortedMessages = MessageService.sortItemsByDate(messages);

    return sortedMessages;
  }

  Message? getLastMessage(String? chatId) {
    List<Message> messages = getChatMessages(chatId);

    Message? message = messages.isNotEmpty ? messages.last : null;

    return message;
  }
}

final chatsProvider =
    StateNotifierProvider<ChatsNotifier, AsyncValue<List<Chat>>>((ref) {
  return ChatsNotifier();
});
