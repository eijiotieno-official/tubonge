import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widget/async_view.dart';
import '../../profile/provider/stream_profile_provider.dart';
import '../controller/chats_controller.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../provider/message_service_provider.dart';
import '../provider/opened_chat_provider.dart';

class ChatsListView extends ConsumerWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsState = ref.watch(chatsProvider);
    return AsyncView(
      asyncValue: chatsState,
      onData: (data) {
        final chats = data.where((chat) => chat.messages.isNotEmpty).toList();

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ChatItemView(chat: chat);
          },
        );
      },
    );
  }
}

class ChatItemView extends ConsumerWidget {
  final Chat chat;
  const ChatItemView({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageService = ref.watch(messageServiceProvider);

    final sortedMessages = messageService.sortItemsByDate(chat.messages);
    final message = sortedMessages.last;

    String? text;
    if (message is TextMessage) {
      text = message.text;
    } else if (message is ImageMessage) {
      text = message.text ?? "Sent a photo";
    } else if (message is VideoMessage) {
      text = message.text ?? "Sent a video";
    }

    Icon? icon;
    if (message is ImageMessage) {
      icon = const Icon(
        Icons.image_rounded,
        size: 16.0,
      );
    } else if (message is VideoMessage) {
      icon = const Icon(
        Icons.video_library_rounded,
        size: 16.0,
      );
    }

    final profileState = ref.watch(streamProfileProvider(chat.chatId));

    return profileState.when(
      data: (profile) => ListTile(
        onTap: () {
          ref.read(openedChatIdProvider.notifier).state = chat.chatId;
        },
        leading: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(profile.photoUrl),
        ),
        title: Text(profile.name),
        subtitle: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: icon,
              ),
            if (text != null) Text(text),
          ],
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
