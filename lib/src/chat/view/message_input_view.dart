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
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: onAttachmentTapped,
              icon: Icon(
                Icons.attachment_rounded,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48.0),
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
            if (controller.text.trim().isNotEmpty)
              IconButton.filledTonal(
                onPressed: onSend,
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
