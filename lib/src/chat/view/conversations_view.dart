import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widget/search_bar_view.dart';

class ConversationsView extends ConsumerStatefulWidget {
  const ConversationsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConversationsViewState();
}

class _ConversationsViewState extends ConsumerState<ConversationsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarView(),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {},
          ),
        ),
      ],
    );
  }
}
