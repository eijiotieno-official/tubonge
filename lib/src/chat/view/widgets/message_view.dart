import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../core/utils/user_util.dart';
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
  String? get _currentUserId => UserUtil.currentUserId;

  Message get _message => widget.message;

  bool get _fromCurrentUser => _message.sender == _currentUserId;

  bool get _showStatus => _fromCurrentUser;

  bool get _isSelected => ref
      .watch(selectedMessagesProvider.notifier)
      .isMessageSelected(chatId: widget.chatId, messageId: _message.id);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onSeen();
    });
  }

  void _onSeen() {
    final bool shouldUpdate = _message.status != MessageStatus.seen &&
        _message.sender != _currentUserId;

    if (shouldUpdate) {
      ref.read(messageServiceProvider).onMessageSeen(
            userId: _message.sender,
            chatId: _message.receiver,
            messageId: _message.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color color = _fromCurrentUser
        ? theme.hoverColor
        : theme.colorScheme.primaryContainer;

    return AutoScrollTag(
      key: ValueKey(widget.index),
      index: widget.index,
      controller: widget.controller,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          mainAxisAlignment: _fromCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: _isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : color,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ref.read(selectedMessagesProvider.notifier).select(
                          chatId: widget.chatId,
                          message: _message,
                          isOnTap: true,
                        );
                  },
                  onLongPress: () {
                    ref.read(selectedMessagesProvider.notifier).select(
                          chatId: widget.chatId,
                          message: _message,
                          isOnTap: false,
                        );
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextMessageView(
                      message: _message as TextMessage,
                      showStatus: _showStatus,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
