import 'package:flutter/material.dart';

import '../../../../core/utils/date_utils.dart';
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
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        Text(
          message.text,
          style: theme.textTheme.bodyLarge,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TubongeDateUtils.formatTime(message.timeSent),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
              ),
              if (showStatus) ...[
                const SizedBox(width: 4.0),
                _buildStatusIcon(theme),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (message.status) {
      case MessageStatus.none:
        iconData = Icons.watch_later_rounded;
        break;
      case MessageStatus.sent:
        iconData = Icons.done_rounded;
        break;
      case MessageStatus.delivered:
      case MessageStatus.seen:
        iconData = Icons.done_all_rounded;
        break;
    }

    iconColor = (message.status == MessageStatus.seen
        ? theme.colorScheme.primary
        : theme.colorScheme.primary.withOpacity(0.15));

    return Icon(
      iconData,
      size: 16.0,
      color: iconColor,
    );
  }
}
