import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/screens/home_screen.dart';
import '../../../../core/views/async_view.dart';
import '../../model/provider/auth_status_provider.dart';
import '../screens/auth_screen.dart';

class AuthWrapperView extends ConsumerWidget {
  const AuthWrapperView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> statusAsync = ref.watch(authStatusProvider);

    return AsyncView(
      asyncValue: statusAsync,
      builder: (isAuthenticated) {
        if (isAuthenticated == false) {
          return const AuthScreen();
        } else {
          return HomeScreen(receivedAction: null);
        }
      },
    );
  }
}
