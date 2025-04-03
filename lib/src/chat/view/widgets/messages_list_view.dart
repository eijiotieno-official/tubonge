import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../core/utils/date_time_util.dart';
import '../../model/base/message_model.dart';
import 'message_view.dart';

class MessagesListView extends StatelessWidget {
  final AutoScrollController scrollController;
  final List<Message> messages;
  final String chatId;
  const MessagesListView(
      {super.key,
      required this.scrollController,
      required this.messages,
      required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GroupedListView(
        controller: scrollController,
        reverse: true,
        floatingHeader: true,
        elements: messages,
        order: GroupedListOrder.DESC,
        groupBy: (Message element) => DateTime(
          element.timeSent.year,
          element.timeSent.month,
          element.timeSent.day,
        ),
        useStickyGroupSeparators: true,
        groupHeaderBuilder: (message) {
          final String day = DateTimeUtil.day(message.timeSent);
          return Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(day),
              ),
            ),
          );
        },
        indexedItemBuilder: (BuildContext context, Message element, int index) {
          Message? nextMessage =
              (index + 1 < messages.length) ? messages[index + 1] : null;

          double topPadding =
              nextMessage == null || nextMessage.sender == element.sender
                  ? 4.0
                  : 16.0;

          return Padding(
            padding: EdgeInsets.only(top: topPadding, left: 8, right: 8),
            child: MessageView(
              chatId: chatId,
              key: Key(element.id),
              controller: scrollController,
              message: element,
              index: index,
            ),
          );
        },
        itemComparator: (Message element1, Message element2) =>
            element1.timeSent.compareTo(element2.timeSent),
      ),
    );
  }
}
