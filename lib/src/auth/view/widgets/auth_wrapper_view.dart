import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/screens/home_screen.dart';
import '../../../../core/views/async_view.dart';
import '../../model/provider/auth_status_provider.dart';
import '../screens/auth_screen.dart';

/// A wrapper widget that decides whether to show the auth screen or the home screen
/// based on the current authentication status.
class AuthWrapperView extends ConsumerWidget {
  const AuthWrapperView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication status from the provider (async value of bool)
    final AsyncValue<bool> statusAsync = ref.watch(authStatusProvider);

    // Wrap the UI in an AsyncView that handles loading/error/data states
    return AsyncView(
      asyncValue: statusAsync,
      builder: (isAuthenticated) {
        // If the user is not authenticated, show the AuthScreen
        if (isAuthenticated == false) {
          return const AuthScreen();
        } else {
          // If authenticated, navigate to the HomeScreen
          return HomeScreen(receivedAction: null);
        }
      },
    );
  }
}
