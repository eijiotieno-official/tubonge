import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/chat/view/chat_view.dart';
import '../../src/settings/view/settings_view.dart';
import 'rail_view.dart';

class ScreenView extends ConsumerWidget {
  const ScreenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Expanded(
      child: selectedIndex == 0 ? ChatView() : SettingsView(),
    );
  }
}
