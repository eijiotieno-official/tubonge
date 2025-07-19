import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/user_util.dart';
import '../../model/base/chat_model.dart';
import '../../model/base/message_model.dart';
import '../../model/provider/chat_service_provider.dart';
import '../../model/provider/message_service_provider.dart';
import '../../view_model/chats_view_model.dart';

class MessageInput extends ConsumerStatefulWidget {
  final String chatId;
  const MessageInput({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MessageInputViewState();
}

class _MessageInputViewState extends ConsumerState<MessageInput> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createChat();
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _createChat() {
    if (_chatAlreadyExists == false) {
      String? currentUserId = UserUtil.currentUserId;

      if (currentUserId != null) {
        ref
            .read(chatServiceProvider)
            .createChat(userId: currentUserId, chatId: widget.chatId);

        ref
            .read(chatServiceProvider)
            .createChat(userId: widget.chatId, chatId: currentUserId);
      }
    }
  }

  bool get _chatAlreadyExists {
    Chat? chat = ref.read(chatsProvider.notifier).getChatById(widget.chatId);

    bool exists = chat != null;

    return exists;
  }

  bool get _isValidToSend => _textEditingController.text.trim().isNotEmpty;

  Message? _message;

  void _onTyping(String text) {
    if (_message == null) {
      setState(() {
        _message = TextMessage.empty;
      });
    } else {
      final message = _message;
      if (message is TextMessage) {
        setState(() {
          _message = message.copyWith(text: text);
        });
      }
    }
  }

  void _onSend() {
    if (_message != null) {
      final Message? updatedMessage =
          _message?.copyWith(receiver: widget.chatId);

      final Either<String, Message> result =
          ref.read(messageServiceProvider).createMessage(updatedMessage);

      if (result.isRight()) {
        setState(() {
          _textEditingController.clear();
          _message = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.2;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                child: TextField(
                  controller: _textEditingController,
                  onChanged: _onTyping,
                  maxLines: null,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  ),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: _isValidToSend ? _onSend : null,
              icon: Icon(
                Icons.arrow_upward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
