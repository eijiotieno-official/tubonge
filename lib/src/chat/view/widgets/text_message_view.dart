import 'package:flutter/material.dart';

import '../../model/base/message_model.dart';
import 'time_status_view.dart';

class TextMessageView extends StatelessWidget {
  final TextMessage message;
  final bool showStatus;
  const TextMessageView({
    super.key,
    required this.message,
    required this.showStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        Text(
          message.text,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
          ),
        ),
        TimeStatusView(
          timeSent: message.timeSent,
          status: message.status,
          showStatus: showStatus,
        ),
      ],
    );
  }
}
