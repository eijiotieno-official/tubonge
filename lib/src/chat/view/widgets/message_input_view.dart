import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/base/chat_model.dart';
import '../../model/base/message_model.dart';
import '../../model/provider/chat_service_provider.dart';
import '../../view_model/chats_view_model.dart';
import '../../model/provider/send_message_provider.dart';

class MessageInputView extends ConsumerStatefulWidget {
  final String chatId;
  const MessageInputView({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MessageInputViewState();
}

class _MessageInputViewState extends ConsumerState<MessageInputView> {
  @override
  void initState() {
    super.initState();
    _createChat();
  }

  Future<void> _createChat() async {
    await Future.delayed(Duration(milliseconds: 100));

    if (!_chatAlreadyExists) {
      final String? currentUser = FirebaseAuth.instance.currentUser?.uid;

      if (currentUser != null) {
        ref
            .read(chatsServiceProvider)
            .createChat(userId: currentUser, chatId: widget.chatId);

        ref
            .read(chatsServiceProvider)
            .createChat(userId: widget.chatId, chatId: currentUser);
      }
    }
  }

  bool get _chatAlreadyExists {
    final AsyncValue<List<Chat>> chatsAsync = ref.read(chatsProvider);

    final List<Chat> chats = chatsAsync.value ?? [];

    return chats.any((chat) => chat.chatId == widget.chatId);
  }

  final TextEditingController _textEditingController = TextEditingController();

  bool get _isValidToSend => _textEditingController.text.trim().isNotEmpty;

  Message? _message;

  void _typing(String text) {
    if (_message == null) {
      setState(() {
        _message = TextMessage.empty();
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

  Future<void> _send() async {
    await _createChat().then(
      (_) {
        if (_message != null) {
          final Message updatedMessage =
              _message!.copyWith(receiver: widget.chatId);

          final Either<String, Message> result =
              ref.read(sendMessageProvider(updatedMessage));

          if (result.isRight()) {
            setState(() {
              _textEditingController.clear();
              _message = null;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.2;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Stack(
          children: [
            _buttons(),
            _textField(maxHeight: maxHeight),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required double maxHeight,
  }) =>
      Row(
        children: [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.image_rounded,
              color: Colors.transparent,
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
              ),
              child: Scrollbar(
                radius: Radius.circular(8.0),
                child: TextField(
                  maxLines: null,
                  minLines: 1,
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: "Message",
                    border: InputBorder.none,
                  ),
                  onChanged: _typing,
                ),
              ),
            ),
          ),
          if (_isValidToSend)
            IconButton(
              onPressed: _send,
              icon: Icon(
                Icons.arrow_upward_rounded,
                color: Colors.transparent,
              ),
            ),
        ],
      );

  Widget _buttons() => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filled(
                onPressed: null,
                icon: Icon(Icons.image_rounded),
              ),
              if (_isValidToSend)
                IconButton.filled(
                  onPressed: _send,
                  icon: Icon(Icons.arrow_upward_rounded),
                ),
            ],
          ),
        ),
      );
}
