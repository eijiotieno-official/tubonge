import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/screen/home_screen.dart';
import '../../../core/view/async_view.dart';
import '../provider/auth_status_provider.dart';
import '../screen/auth_screen.dart';

class AuthWrapperView extends ConsumerWidget {
  const AuthWrapperView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusValue = ref.watch(authStatusProvider);
    return AsyncView(
      asyncValue: statusValue,
      onData: (isAuthenticated) {
        if (isAuthenticated == false) {
          return const AuthScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
