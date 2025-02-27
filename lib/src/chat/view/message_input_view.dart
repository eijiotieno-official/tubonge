import 'package:flutter/material.dart';

class MessageInputView extends StatelessWidget {
  final TextEditingController controller;
  final Function(String value) onChanged;
  final VoidCallback onSend;
  final VoidCallback onAttachmentTapped;
  const MessageInputView({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.onAttachmentTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 32.0,
        horizontal: 6.0,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton.filledTonal(
                onPressed: onAttachmentTapped,
                icon: Icon(
                  Icons.attachment_rounded,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Message",
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
            if (controller.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton.filledTonal(
                  onPressed: onSend,
                  icon: Icon(
                    Icons.arrow_upward_rounded,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
