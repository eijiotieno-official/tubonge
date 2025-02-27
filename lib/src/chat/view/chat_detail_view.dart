import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../core/provider/media_picker_provider.dart';
import '../../../core/service/media_picker_service.dart';
import '../../../core/widget/async_view.dart';
import '../../profile/provider/current_user_profile_provider.dart';
import '../../profile/provider/stream_profile_provider.dart';
import '../controller/chats_controller.dart';
import '../controller/send_message_controller.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../provider/chat_service_provider.dart';
import '../provider/opened_chat_provider.dart';
import 'message_input_view.dart';
import 'messages_list_view.dart';
import 'picked_media_view.dart';

class ChatDetailView extends ConsumerStatefulWidget {
  const ChatDetailView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends ConsumerState<ChatDetailView> {
  final AutoScrollController _scrollController = AutoScrollController();

  final TextEditingController _messageController = TextEditingController();

  final List<Message> _messages = [];

  void _onSend({required bool isNewChat}) {
    final openedChatId = ref.watch(openedChatIdProvider);

    final chatService = ref.read(chatServiceProvider);

    final currentUserProfile = ref.watch(currentUserProfileProvider);

    currentUserProfile.whenData(
      (profile) {
        if (isNewChat && openedChatId != null) {
          chatService.createChat(Chat.empty.copyWith(chatId: openedChatId));

          chatService
              .chats(openedChatId)
              .doc(profile.id)
              .set(Chat.empty.copyWith(chatId: profile.id).toMap());
        }

        for (var message in _messages) {
          final messageModel = message.copyWith(receiver: openedChatId);

          ref.read(sendMessageProvider(messageModel));
        }

        setState(() {
          _messages.clear(); // Clear messages after sending
          _messageController.clear();
          ref.read(filePickerProvider.notifier).clear();
        });
      },
    );
  }

  Future<void> _onAttachmentTapped() async {
    await ref.read(filePickerProvider.notifier).call(type: FileType.image);

    final pickedMedias = ref.watch(filePickerProvider).value ?? [];

    if (pickedMedias.isNotEmpty) {
      for (var media in pickedMedias) {
        final type = MediaPickerService().getMimeTypeFromMime(media);

        final message = type == MimeType.image
            ? ImageMessage.empty().copyWith(
                text: _messageController.text.trim(),
                imageUri: pickedMedias.first.path,
              )
            : VideoMessage.empty().copyWith(
                text: _messageController.text.trim(),
                videoUri: pickedMedias.first.path,
              );

        setState(() {
          _messages.add(message);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatsState = ref.watch(chatsProvider);

    final openedChatId = ref.watch(openedChatIdProvider);

    final pickedMedias = ref.watch(filePickerProvider).value ?? [];

    return AsyncView(
      asyncValue: chatsState,
      onData: (chats) {
        final chat =
            chats.firstWhereOrNull((test) => test.chatId == openedChatId);

        final messages = chat?.messages ?? [];

        final profileState = ref.watch(streamProfileProvider(openedChatId));

        return AsyncView(
          asyncValue: profileState,
          onData: (profile) {
            return Column(
              children: [
                AppBar(
                  leading: Center(
                    child: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(profile.photoUrl),
                    ),
                  ),
                  title: Text(profile.name),
                  titleSpacing: 0.0,
                ),
                MessagesListView(
                  scrollController: _scrollController,
                  messages: messages,
                ),
                PickedMediaView(),
                MessageInputView(
                  controller: _messageController,
                  onChanged: (value) {
                    setState(() {
                      if (pickedMedias.isEmpty && _messages.isEmpty) {
                        // Add an empty TextMessage if no media is picked and no messages exist
                        _messages.add(TextMessage.empty().copyWith(
                          text: value.trim(),
                        ));
                      } else if (_messages.isNotEmpty) {
                        // Update the last message's text
                        final lastMessage = _messages.last;
                        if (lastMessage is TextMessage) {
                          _messages[_messages.length - 1] =
                              lastMessage.copyWith(text: value.trim());
                        } else if (lastMessage is ImageMessage) {
                          _messages[_messages.length - 1] =
                              lastMessage.copyWith(text: value.trim());
                        } else if (lastMessage is VideoMessage) {
                          _messages[_messages.length - 1] =
                              lastMessage.copyWith(text: value.trim());
                        }
                      }
                    });
                  },
                  onAttachmentTapped: () {
                    _onAttachmentTapped();
                  },
                  onSend: () {
                    _onSend(isNewChat: messages.isEmpty);
                  },
                ),
              ],
            );
          },
          onError: (error, stackTrace) => Center(
            child: Text("Open a chat"),
          ),
        );
      },
    );
  }
}
