import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_service_provider.dart';
import '../view/code_input_view.dart';
import '../view/phone_input_view.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final showCodeInput = ref.watch(verificationIdProvider) != null;

    final operationState = showCodeInput
        ? ref.watch(codeVerificationProvider)
        : ref.watch(phoneVerificationProvider);

    final isLoading = operationState.isLoading;

    final errorMessage = operationState.when(
      loading: () => null,
      data: (_) => null,
      error: (e, _) => e.toString(),
    );

    final isPhoneValid = ref.watch(phoneNumberProvider) != null;

    final isCodeValid = ref.watch(otpCodeProvider) != null;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(ref.watch(verificationIdProvider) != null
              ? "OTP"
              : "Phone Number"),
        ),
        body: showCodeInput
            ? CodeInputView(
                isLoading: isLoading,
                onTap: isCodeValid
                    ? () async {
                        await ref
                            .read(codeVerificationProvider.notifier)
                            .call();
                      }
                    : null,
                errorMessage: errorMessage,
              )
            : PhoneInputView(
                isLoading: isLoading,
                onTap: isPhoneValid
                    ? () async {
                        await ref
                            .read(phoneVerificationProvider.notifier)
                            .call();
                      }
                    : null,
                errorMessage: errorMessage,
              ),
      ),
    );
  }
}
