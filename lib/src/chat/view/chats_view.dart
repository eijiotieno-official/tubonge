import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'conversation_detail_view.dart';
import 'conversations_view.dart';

class ChatsView extends ConsumerWidget {
  const ChatsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: ConversationsView(),
          ),
          Flexible(
            flex: 5,
            child: ConversationDetailView(),
          ),
        ],
      ),
    );
  }
}
