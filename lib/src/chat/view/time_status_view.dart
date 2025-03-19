import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/message_model.dart';


class TimeStatus extends StatelessWidget {
  final DateTime timeSent;
  final bool showStatus;
  final MessageStatus status;

  const TimeStatus({
    super.key,
    required this.timeSent,
    required this.status,
    required this.showStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(context),
            style: TextStyle(
              fontSize: 12.0,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.75),
            ),
          ),
          if (showStatus) ...[
            const SizedBox(width: 4.0),
            _buildStatusIcon(context),
          ],
        ],
      ),
    );
  }

  String _formatTime(BuildContext context) {
    String timeFormat =
        MediaQuery.of(context).alwaysUse24HourFormat ? 'HH:mm' : 'h:mm a';

    return DateFormat(timeFormat).format(timeSent);
  }

  Widget _buildStatusIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (status) {
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

    iconColor = (status == MessageStatus.seen
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.primary.withOpacity(0.15));

    return Icon(
      iconData,
      size: 16.0,
      color: iconColor,
    );
  }
}
