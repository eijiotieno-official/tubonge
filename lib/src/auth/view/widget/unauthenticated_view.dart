import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widget/error_message_view.dart';
import '../../controller/sign_in_with_email_password_controller.dart';
import '../../controller/sign_in_with_google_controller.dart';
import '../../controller/sign_up_with_email_password_controller.dart';
import '../../provider/toggle_sign_state_provider.dart';
import 'google_sign_in_view.dart';
import 'sign_in_form.dart';
import 'sign_up_form.dart';

class UnauthenticatedView extends StatelessWidget {
  const UnauthenticatedView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, child) {
        final toggleSignState = ref.watch(toggleSignStateProvider);
        final operationState = toggleSignState == ToggleSignState.signIn
            ? ref.watch(signInWithEmailPasswordProvider)
            : ref.watch(signUpWithEmailPasswordProvider);
        final signInWithGoogleState = ref.watch(signInWithGoogleProvider);
        final isLoading =
            operationState.isLoading || signInWithGoogleState.isLoading;
        final errorMessage = operationState.error?.toString();

        return Material(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Compute container width as 90% of the screen width,
              // then clamp it between 300 and 500 pixels.
              double computedWidth =
                  (constraints.maxWidth * 0.9).clamp(300.0, 500.0);

              return Center(
                child: SingleChildScrollView(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: computedWidth,
                    curve: Curves.easeInOut,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        color: theme.scaffoldBackgroundColor,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      padding: const EdgeInsets.all(36.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (toggleSignState == ToggleSignState.signIn)
                            SignInForm(
                              enabled: !isLoading,
                              onSignIn: (email, password) async => await ref
                                  .read(
                                      signInWithEmailPasswordProvider.notifier)
                                  .call(email: email, password: password),
                            )
                          else
                            SignUpForm(
                              enabled: !isLoading,
                              onSignUp: (email, password) async => await ref
                                  .read(
                                      signUpWithEmailPasswordProvider.notifier)
                                  .call(email: email, password: password),
                            ),
                          const SizedBox(height: 16.0),
                          const Text("or"),
                          const SizedBox(height: 16.0),
                          GoogleSignInView(),
                          const SizedBox(height: 16.0),
                          ErrorMessageView(errorMessage: errorMessage),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
