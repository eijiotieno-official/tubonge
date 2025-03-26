import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/views/async_view.dart';
import '../providers/chats_provider.dart';
import 'chat_view.dart';

class ChatsListView extends ConsumerWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsState = ref.watch(chatsProvider);

    return AsyncView(
      asyncValue: chatsState,
      onData: (chats) {
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final  chat = chats[index];

            return ChatView(chat: chat);
          },
        );
      },
    );
  }
}
