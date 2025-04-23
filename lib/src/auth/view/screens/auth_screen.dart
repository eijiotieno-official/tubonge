import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/base/auth_state_model.dart';
import '../../model/provider/auth_state_provider.dart';
import '../../view_model/code_verification_view_model.dart';
import '../../view_model/phone_verification_view_model.dart';
import '../widgets/code_input_view.dart';
import '../widgets/phone_input_view.dart';

/// This screen toggles between phone input and code input views
/// depending on the authentication state (whether a verification ID exists).
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authStateValue = ref.watch(authStateProvider);

    // Determines which view to show: phone input or code input
    final bool showCodeInput = authStateValue.verificationId != null;

    // Watches the relevant provider depending on the current step
    final AsyncValue<Object?> operationState = showCodeInput
        ? ref.watch(codeVerificationViewModelProvider)
        : ref.watch(phoneVerificationViewModelProvider);

    // Indicates loading state for the button and text field
    final bool isLoading = operationState.isLoading;

    // Extracts error message from operation state if any
    final String? errorMessage = operationState.when(
      loading: () => null,
      data: (_) => null,
      error: (e, _) => e.toString(),
    );

    // Checks if the user has entered a valid phone number
    final bool isPhoneValid = authStateValue.phone != null;

    // Checks if the user has entered a valid OTP code
    final bool isCodeValid = authStateValue.optCode != null;

    // Just a re-check if verification code was sent (same as showCodeInput)
    final bool codeSent = authStateValue.verificationId != null;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(codeSent ? "Verification Code" : "Phone Number"),
        ),
        body: showCodeInput
            ? CodeInputView(
                isLoading: isLoading,
                onTap: isCodeValid
                    ? () async => await ref
                        .read(codeVerificationViewModelProvider.notifier)
                        .call() // Triggers code verification
                    : null, // Button is disabled if code is not valid
                errorMessage: errorMessage,
              )
            : PhoneInputView(
                isLoading: isLoading,
                onTap: isPhoneValid
                    ? () async => await ref
                        .read(phoneVerificationViewModelProvider.notifier)
                        .call() // Triggers phone number verification
                    : null, // Button is disabled if phone is not valid
                errorMessage: errorMessage,
              ),
      ),
    );
  }
}
