import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/code_verification_controller.dart';
import '../controller/phone_verification_controller.dart';
import '../providers/otp_code_provider.dart';
import '../providers/phone_number_provider.dart';
import '../providers/verification_id_provider.dart';
import '../views/code_input_view.dart';
import '../views/phone_input_view.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool showCodeInput = ref.watch(verificationIdProvider) != null;

    final AsyncValue<Object?> operationState = showCodeInput
        ? ref.watch(codeVerificationProvider)
        : ref.watch(phoneVerificationProvider);

    final bool isLoading = operationState.isLoading;

    final String? errorMessage = operationState.when(
      loading: () => null,
      data: (_) => null,
      error: (e, _) => e.toString(),
    );

    final bool isPhoneValid = ref.watch(phoneNumberProvider) != null;

    final bool isCodeValid = ref.watch(otpCodeProvider) != null;

    final bool codeSent = ref.watch(verificationIdProvider) != null;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(codeSent ? "Verification Code" : "Phone Number"),
        ),
        body: showCodeInput
            ? CodeInputView(
                isLoading: isLoading,
                onTap: isCodeValid
                    ? () async =>
                        await ref.read(codeVerificationProvider.notifier).call()
                    : null,
                errorMessage: errorMessage,
              )
            : PhoneInputView(
                isLoading: isLoading,
                onTap: isPhoneValid
                    ? () async => await ref
                        .read(phoneVerificationProvider.notifier)
                        .call()
                    : null,
                errorMessage: errorMessage,
              ),
      ),
    );
  }
}
