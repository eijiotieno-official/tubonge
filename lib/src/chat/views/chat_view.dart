import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_info_provider.dart';
import '../../../core/views/avatar_view.dart';
import '../../contact/models/contact_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../screens/chat_detail_screen.dart';
import '../services/message_service.dart';

class ChatView extends ConsumerWidget {
  final Chat chat;
  const ChatView({super.key, required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Message> sortedMessages =
        MessageService.sortItemsByDate(chat.messages);

    final Message? message = lastMessage(sortedMessages);

    String? text;

    if (message is TextMessage) {
      text = message.text;
    }

    final AsyncValue<ContactModel> userInfoAsync =
        ref.watch(userInfoProvider(chat.chatId));

    return sortedMessages.isEmpty
        ? SizedBox.shrink()
        : userInfoAsync.when(
            data: (contact) {
              String? photo = contact.photo;
              String name = contact.name;
              Text? subtitle = text == null ? null : Text(text);
              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final String chatId = contact.id ?? "";
                      return ChatDetailScreen(chatId: chatId);
                    },
                  ),
                ),
                leading: AvatarView(imageUrl: photo),
                title: Text(name),
                subtitle: subtitle,
              );
            },
            loading: () => SizedBox.shrink(),
            error: (error, stack) => SizedBox.shrink(),
          );
  }

  Message? lastMessage(List<Message> sortedMessages) =>
      sortedMessages.isNotEmpty ? sortedMessages.last : null;
}
