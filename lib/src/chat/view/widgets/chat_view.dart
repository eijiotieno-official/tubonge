import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/user_info_provider.dart';
import '../../../../core/views/async_view.dart';
import '../../../../core/views/avatar_view.dart';
import '../../../contact/model/base/contact_model.dart';
import '../../model/base/message_model.dart';
import '../../view_model/chats_view_model.dart';
import '../screens/chat_detail_screen.dart';

class ChatView extends ConsumerWidget {
  final String chatId;
  const ChatView({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Message? message = ref.watch(chatsProvider.notifier).getLastMessage(chatId);

    String? text;

    if (message is TextMessage) {
      text = message.text;
    }

    AsyncValue<ContactModel?> userInfoAsync =
        ref.watch(userInfoProvider(chatId));

    return message == null
        ? SizedBox.shrink()
        : AsyncView(
            asyncValue: userInfoAsync,
            builder: (user) {
              if (user == null) {
                return SizedBox.shrink();
              }

              String? photo = user.photo;

              String name = user.name;

              Text? subtitle = text == null ? null : Text(text);

              return ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final String chatId = user.id ?? "";
                      return ChatDetailScreen(chatId: chatId);
                    },
                  ),
                ),
                leading: AvatarView(imageUrl: photo),
                title: Text(name),
                subtitle: subtitle,
              );
            },
          );
  }
}
