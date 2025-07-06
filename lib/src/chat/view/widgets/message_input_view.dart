import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/shared/tubonge_button.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                  ),
                  child: TextField(
                    controller: _textEditingController,
                    onChanged: _typing,
                    maxLines: null,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  ),
                ),
              ),),
              const SizedBox(width: 8.0),
              TubongeButton(
                text: '',
                onPressed: _isValidToSend ? _send : null,
                icon: const Icon(Icons.send_rounded),
                variant: TubongeButtonVariant.filled,
                borderRadius: BorderRadius.circular(20.0),
                width: 40.0,
                height: 40.0,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
