import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/async_view.dart';
import '../../model/base/chat_model.dart';
import '../../view_model/chats_view_model.dart';
import 'chat_view.dart';

class ChatsList extends ConsumerWidget {
  const ChatsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Chat>> chatsAsync = ref.watch(chatsProvider);

    return AsyncView(
      asyncValue: chatsAsync,
      builder: (chats) {
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final Chat chat = chats[index];

            return ChatView(chatId: chat.chatId);
          },
        );
      },
    );
  }
}
