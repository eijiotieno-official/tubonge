import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/views/async_view.dart';
import '../models/chat_model.dart';
import '../providers/chats_provider.dart';
import 'chat_view.dart';

class ChatsListView extends ConsumerWidget {
  const ChatsListView({super.key});

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

            return ChatView(chat: chat);
          },
        );
      },
    );
  }
}
