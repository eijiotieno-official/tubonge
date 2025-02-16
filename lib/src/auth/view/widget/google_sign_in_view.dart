
import 'package:auth_button_kit/auth_button_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/sign_in_with_google_controller.dart';
import 'error_view.dart';

class GoogleSignInView extends ConsumerWidget {
  const GoogleSignInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> signInWithGoogleState =
        ref.watch(signInWithGoogleProvider);

    final SignInWithGoogleNotifier signInWithGoogleNotifier =
        ref.read(signInWithGoogleProvider.notifier);

    bool isLoading = signInWithGoogleState.isLoading;

    final String? errorMessage = signInWithGoogleState.error as String?;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16.0,
        children: [
          AuthButton(
            onPressed: (method) async => await signInWithGoogleNotifier.call(),
            brand: Method.google,
            showLoader: isLoading,
            padding: EdgeInsets.zero,
            fontWeight: FontWeight.bold,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.25),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          if (errorMessage != null) ErrorView(errorMessage: errorMessage),
        ],
      ),
    );
  }
}
