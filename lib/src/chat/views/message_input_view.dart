import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final TextEditingController _textEditingController = TextEditingController();

  bool get _isValidToSend => _textEditingController.text.trim().isNotEmpty;

  void _onImageTapped() {
    debugPrint("Image");
  }

  void _onSendTapped() {
    debugPrint("Send");
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
            onPressed: _onImageTapped,
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
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ),
          ),
          if (_isValidToSend)
            IconButton(
              onPressed: _onSendTapped,
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
                onPressed: _onImageTapped,
                icon: Icon(Icons.image_rounded),
              ),
              if (_isValidToSend)
                IconButton.filled(
                  onPressed: _onSendTapped,
                  icon: Icon(Icons.arrow_upward_rounded),
                ),
            ],
          ),
        ),
      );
}
