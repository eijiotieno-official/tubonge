import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tubonge/src/chat/model/base/chat_model.dart';

import '../../../../core/providers/user_info_provider.dart';
import '../../../../core/views/async_view.dart';
import '../../../../core/views/avatar_view.dart';
import '../../model/base/message_model.dart';
import '../../view_model/chats_view_model.dart';
import '../widgets/message_input.dart';
import '../widgets/messages_list.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final AutoScrollController _scrollController = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    final userInfoAsync = ref.watch(userInfoProvider(widget.chatId));

    return AsyncView(
      asyncValue: userInfoAsync,
      builder: (user) {
        if (user == null) {
          return Text("User not found");
        }
        final AsyncValue<List<Chat>> chatsAsync = ref.watch(chatsProvider);

        return AsyncView(
            asyncValue: chatsAsync,
            builder: (chats) {
              
              List<Message> messages = ref
                  .watch(chatsProvider.notifier)
                  .getChatMessages(user.id ?? '');

              return Scaffold(
                appBar: AppBar(
                  titleSpacing: 0.0,
                  title: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: AvatarView(imageUrl: user.photo),
                    title: Text(user.name),
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      MessagesList(
                          scrollController: _scrollController,
                          messages: messages,
                          chatId: widget.chatId),
                      MessageInput(chatId: widget.chatId),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}
