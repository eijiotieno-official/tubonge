import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller/sign_in_with_email_password_controller.dart';
import '../../controller/sign_in_with_google_controller.dart';
import '../../controller/sign_up_with_email_password_controller.dart';
import '../../provider/toggle_sign_state_provider.dart';
import '../../../../core/widget/error_message_view.dart';
import 'google_sign_in_view.dart';
import 'sign_in_form.dart';
import 'sign_up_form.dart';

class UnauthenticatedView extends StatelessWidget {
  const UnauthenticatedView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Consumer(
      builder: (context, ref, child) {
        final theme = Theme.of(context);

        final toggleSignState = ref.watch(toggleSignStateProvider);

        final operationState = toggleSignState == ToggleSignState.signIn
            ? ref.watch(signInWithEmailPasswordProvider)
            : ref.watch(signUpWithEmailPasswordProvider);

        final signInWithGoogleState = ref.watch(signInWithGoogleProvider);

        final isLoading =
            operationState.isLoading || signInWithGoogleState.isLoading;

        final errorMessage = operationState.error?.toString();

        return Material(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        color: theme.primaryColor,
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(),
                    ),
                  ],
                ),
              ),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: theme.scaffoldBackgroundColor,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Column(
                        spacing: 16.0,
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
                          Text("or"),
                          GoogleSignInView(),
                          ErrorMessageView(errorMessage: errorMessage),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
