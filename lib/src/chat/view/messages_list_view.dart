import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../models/message_model.dart';
import '../provider/message_service_provider.dart';
import 'message_view/message_item_view.dart';

class MessagesListView extends ConsumerWidget {
  final AutoScrollController scrollController;
  final List<Message> messages;
  const MessagesListView({
    super.key,
    required this.scrollController,
    required this.messages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageState = ref.watch(messageServiceProvider);

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
          String timeSent = messageState.formatTimeSent(message.timeSent);
          return Align(
            alignment: Alignment.topCenter,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Text(
                  timeSent,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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

          return MessageItemView(
            key: Key(element.id),
            scrollController: scrollController,
            message: element,
            index: index,
            topPadding: topPadding,
          );
        },
        itemComparator: (Message element1, Message element2) =>
            element1.timeSent.compareTo(element2.timeSent),
      ),
    );
  }
}






