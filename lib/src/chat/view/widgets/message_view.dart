import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../core/widgets/shared/avatar_view.dart';
import '../../model/base/message_model.dart';
import '../../model/provider/message_service_provider.dart';
import '../../model/provider/selected_messages_provider.dart';
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
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    final Message message = widget.message;

    final bool shouldUpdate = message.status != MessageStatus.seen &&
        message.sender != FirebaseAuth.instance.currentUser?.uid;

    if (shouldUpdate) {
      ref.read(messageServiceProvider).onMessageSeen(
          userId: message.sender,
          chatId: message.receiver,
          messageId: message.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Message message = widget.message;
    final theme = Theme.of(context);

    final bool fromCurrentUser =
        message.sender == FirebaseAuth.instance.currentUser?.uid;

    final Alignment alignment =
        fromCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    final bool showStatus = fromCurrentUser;

    final Color color =
        fromCurrentUser ? theme.hoverColor : theme.colorScheme.primaryContainer;

    final bool isSelected = ref
        .read(selectedMessagesProvider.notifier)
        .isMessageSelected(chatId: widget.chatId, messageId: message.id);

    return AutoScrollTag(
      key: ValueKey(widget.index),
      index: widget.index,
      controller: widget.controller,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment:
              fromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!fromCurrentUser) ...[
              AvatarView(
                size: 32.0,
                onTap: () {
                  // TODO: Implement profile view
                },
              ),
              const SizedBox(width: 8.0),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : color,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ref.read(selectedMessagesProvider.notifier).select(
                            chatId: widget.chatId,
                            message: message,
                            isOnTap: true,
                          );
                    },
                    onLongPress: () {
                      ref.read(selectedMessagesProvider.notifier).select(
                            chatId: widget.chatId,
                            message: message,
                            isOnTap: false,
                          );
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextMessageView(
                        message: message as TextMessage,
                        showStatus: showStatus,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (fromCurrentUser) ...[
              const SizedBox(width: 8.0),
              AvatarView(
                size: 32.0,
                onTap: () {
                  // TODO: Implement profile view
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
