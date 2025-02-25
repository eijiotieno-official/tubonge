import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/user_service_provider.dart';
import 'rail_view.dart';
import 'screen_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Row(
          children: [
            RailView(
              onComposeTap: () {
                ref.read(userServiceProvider).showUsersDialog(context);
              },
            ),
            ScreenView(),
          ],
        ),
      ),
    );
  }
}
