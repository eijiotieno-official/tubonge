import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../models/message_model.dart';
import '../providers/selected_messages_provider.dart';
import 'image_message_view.dart';
import 'text_message_view.dart';

class MessageView extends ConsumerStatefulWidget {
  final AutoScrollController controller;
  final String chatId;
  final Message message;
  final int index;
  const MessageView({
    super.key,
    required this.controller,
    required this.chatId,
    required this.message,
    required this.index,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    final fromCurrentUser =
        message.sender == FirebaseAuth.instance.currentUser?.uid;

    final alignment =
        fromCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    final showStatus = fromCurrentUser;

    final color = fromCurrentUser
        ? Theme.of(context).hoverColor
        : Theme.of(context).colorScheme.primaryContainer;

    final isSelected = ref
        .read(selectedMessagesProvider.notifier)
        .isMessageSelected(chatId: widget.chatId, messageId: message.id);

    return AutoScrollTag(
      key: ValueKey(widget.index),
      controller: widget.controller,
      index: widget.index,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
        child: Align(
          alignment: alignment,
          child: GestureDetector(
            onLongPress: () => ref
                .read(selectedMessagesProvider.notifier)
                .select(
                    chatId: widget.chatId, message: message, isOnTap: false),
            onTap: () => ref
                .read(selectedMessagesProvider.notifier)
                .select(chatId: widget.chatId, message: message, isOnTap: true),
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
    );
  }
}
