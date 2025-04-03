import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/base/auth_state_model.dart';
import '../../model/provider/auth_state_provider.dart';
import '../../view_model/code_verification_view_model.dart';
import '../../view_model/phone_verification_view_model.dart';
import '../widgets/code_input_view.dart';
import '../widgets/phone_input_view.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authStateValue = ref.watch(authStateProvider);

    final bool showCodeInput = authStateValue.verificationId != null;

    final AsyncValue<Object?> operationState = showCodeInput
        ? ref.watch(codeVerificationViewModelProvider)
        : ref.watch(phoneVerificationViewModelProvider);

    final bool isLoading = operationState.isLoading;

    final String? errorMessage = operationState.when(
      loading: () => null,
      data: (_) => null,
      error: (e, _) => e.toString(),
    );

    final bool isPhoneValid = authStateValue.phone != null;

    final bool isCodeValid = authStateValue.optCode != null;

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
                        .call()
                    : null,
                errorMessage: errorMessage,
              )
            : PhoneInputView(
                isLoading: isLoading,
                onTap: isPhoneValid
                    ? () async => await ref
                        .read(phoneVerificationViewModelProvider.notifier)
                        .call()
                    : null,
                errorMessage: errorMessage,
              ),
      ),
    );
  }
}
