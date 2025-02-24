import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_detail_view.dart';
import 'chats_list_view.dart';

class ChatView extends ConsumerWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: ChatsListView(),
          ),
          Flexible(
            flex: 3,
            child: ChatDetailView(),
          ),
        ],
      ),
    );
  }
}
