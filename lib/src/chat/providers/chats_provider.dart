import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/message_service.dart';
import 'chat_service_provider.dart';
import 'message_service_provider.dart';

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
      state = AsyncValue.data(<Chat>[]);
    } else {
      final chatsStreamResult = _chatService.subscribeToChats(_userId);

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

                List<Message> initialMessages =
                    currentChats[chatIndex].messages;

                if (chatIndex > -1) {
                  final messagesStreamResult =
                      _messageService.subscribeToMessages(
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
}

final chatsProvider =
    StateNotifierProvider<ChatsNotifier, AsyncValue<List<Chat>>>((ref) {
  final chatService = ref.watch(chatsServiceProvider);
  final messageService = ref.watch(messageServiceProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;
  return ChatsNotifier(chatService, messageService, userId);
});
