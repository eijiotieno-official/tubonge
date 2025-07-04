import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../core/providers/user_info_provider.dart';
import '../../../../core/views/async_view.dart';
import '../../../../core/views/avatar_view.dart';
import '../../../contact/model/base/contact_model.dart';
import '../../model/base/chat_model.dart';
import '../../model/base/message_model.dart';
import '../../view_model/chats_view_model.dart';
import '../../model/service/message_service.dart';
import '../widgets/message_input_view.dart';
import '../widgets/messages_list_view.dart';

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
    final AsyncValue<List<Chat>> chatsAsync = ref.watch(chatsProvider);

    return AsyncView(
      asyncValue: chatsAsync,
      builder: (chats) {
        final Chat? thisChat =
            chats.firstWhereOrNull((test) => test.chatId == widget.chatId);

        final AsyncValue<ContactModel> userInfoAsync =
            ref.watch(userInfoProvider(widget.chatId));

        return AsyncView(
          asyncValue: userInfoAsync,
          builder: (contact) {
            final List<Message> messages = MessageService.sortItemsByDate(
              thisChat?.messages ?? [],
              ascending: false,
            );

            return Scaffold(
              appBar: AppBar(
                titleSpacing: 0.0,
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: AvatarView(imageUrl: contact.photo),
                  title: Text(contact.name),
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    MessagesListView(
                        scrollController: _scrollController,
                        messages: messages,
                        chatId: widget.chatId),
                    MessageInputView(chatId: widget.chatId),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
