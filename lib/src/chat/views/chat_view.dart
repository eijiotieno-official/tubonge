import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_info_provider.dart';
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
    final List<Message> sortedMessages = MessageService.sortItemsByDate(chat.messages);

    final Message? message = sortedMessages.isNotEmpty ? sortedMessages.last : null;

    String? text;

    if (message is TextMessage) {
      text = message.text;
    } else if (message is ImageMessage) {
      text = message.text ?? "Sent a photo";
    }

    Icon? icon;

    if (message is ImageMessage) {
      icon = Icon(
        Icons.image_rounded,
        size: 16.0,
      );
    }

    final AsyncValue<ContactModel> userInfoAsync = ref.watch(userInfoProvider(chat.chatId));

    return userInfoAsync.when(
      data: (contact) => ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ChatDetailScreen(chatId: contact.id ?? "");
            },
          ),
        ),
        leading: CircleAvatar(
          backgroundImage:
              contact.photo != null ? NetworkImage(contact.photo!) : null,
          child: contact.photo == null ? const Icon(Icons.person) : null,
        ),
        title: Text(contact.name),
        subtitle: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: icon,
              ),
            if (text != null)
              Text(
                text,
              ),
          ],
        ),
      ),
      loading: () => SizedBox.shrink(),
      error: (error, stack) => SizedBox.shrink(),
    );
  }
}
