import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../core/util/string_util.dart';
import '../../../profile/provider/current_user_profile_provider.dart';
import '../../controller/message_file_upload_controller.dart';
import '../../models/message_model.dart';
import '../../provider/opened_chat_provider.dart';
import '../../provider/selected_messages_provider.dart';
import 'image_message_view.dart';
import 'text_message_view.dart';

class MessageItemView extends ConsumerStatefulWidget {
  final AutoScrollController scrollController;
  final Message message;
  final int index;
  final double topPadding;
  const MessageItemView({
    super.key,
    required this.scrollController,
    required this.message,
    required this.index,
    required this.topPadding,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MessageItemViewState();
}

class _MessageItemViewState extends ConsumerState<MessageItemView> {
  PlatformFile? _file;

  Future<void> _uploadFile() async {
    final message = widget.message;

    // Check if the message is an ImageMessage or VideoMessage and if the file exists
    if (message is ImageMessage) {
      bool isFile = StringUtil.isFilePath(message.imageUri) &&
          await File(message.imageUri).exists();

      if (isFile) {
        setState(() {
          _file = PlatformFile(
            name: message.imageUri.split('/').last,
            size: File(message.imageUri).lengthSync(),
            path: message.imageUri,
          );
        });
      }
    } else if (message is VideoMessage) {
      bool isFile = StringUtil.isFilePath(message.videoUri) &&
          await File(message.videoUri).exists();

      if (isFile) {
        setState(() {
          _file = PlatformFile(
            name: message.videoUri.split('/').last,
            size: File(message.videoUri).lengthSync(),
            path: message.videoUri,
          );
        });
      }
    }

    // If the file exists and the message status is 'none', initiate the upload
    if (_file != null) {
      bool fileExists = await File(_file?.path ?? "").exists();

      bool shouldUpload = fileExists && message.status == MessageStatus.none;

      if (shouldUpload) {
        // Delay to ensure the provider is fully loaded
        await Future.delayed(
          const Duration(milliseconds: 500),
          () {
            ref
                .read(messageFileUploadProvider(widget.message.id).notifier)
                .upload(widget.message);
          },
        );
      }
    }
  }

  @override
  void initState() {
    _uploadFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Message message = widget.message;

    final currentUser = ref.watch(currentUserProfileProvider).value?.value;

    bool fromCurrentUser = message.sender == currentUser?.id;

    Alignment alignment =
        fromCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    bool showStatus = fromCurrentUser;

    Color? color = fromCurrentUser
        ? Theme.of(context).hoverColor
        : Theme.of(context).colorScheme.primaryContainer;

    final openedChatId = ref.watch(openedChatIdProvider);

    final isSelected = ref
        .read(selectedMessagesProvider.notifier)
        .isMessageSelected(chatId: openedChatId ?? "", messageId: message.id);

    final selectedMessages = ref.watch(selectedMessagesProvider);

    return AutoScrollTag(
      key: ValueKey(widget.index),
      controller: widget.scrollController,
      index: widget.index,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
          ),
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: widget.topPadding,
              ),
              child: GestureDetector(
                onLongPress: () {
                  if (selectedMessages.isEmpty) {
                    ref
                        .read(selectedMessagesProvider.notifier)
                        .select(chatId: openedChatId ?? "", message: message);
                  }
                },
                onTap: () {
                  if (selectedMessages.isNotEmpty) {
                    ref
                        .read(selectedMessagesProvider.notifier)
                        .select(chatId: openedChatId ?? "", message: message);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message is TextMessage)
                          TextMessageView(
                            key: Key(message.id),
                            message: message,
                            showStatus: showStatus,
                          )
                        else if (message is ImageMessage)
                          ImageMessageView(
                            key: Key(message.id),
                            message: message,
                            showStatus: showStatus,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
