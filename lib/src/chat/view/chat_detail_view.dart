import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../core/widget/async_view.dart';
import '../controller/chats_controller.dart';
import '../provider/opened_chat_provider.dart';
import 'messages_list_view.dart';

class ChatDetailView extends ConsumerStatefulWidget {
  const ChatDetailView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends ConsumerState<ChatDetailView> {
  final AutoScrollController _scrollController = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    final chatsState = ref.watch(chatsProvider);

    final openedChatId = ref.watch(openedChatIdProvider);

    return AsyncView(
      asyncValue: chatsState,
      onData: (chats) {
        final chat =
            chats.firstWhereOrNull((test) => test.chatId == openedChatId);

        final messages = chat?.messages ?? [];

        return Column(
          children: [
            MessagesListView(
              scrollController: _scrollController,
              messages: messages,
            ),
          ],
        );
      },
    );
  }
}
