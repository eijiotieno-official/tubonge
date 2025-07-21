import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubonge/src/auth/model/provider/auth_state_provider.dart';

import '../../../../core/models/phone_model.dart';
import '../../../../core/views/error_message_view.dart';
import '../../../../core/widgets/shared/tubonge_button.dart';
import '../../model/provider/timer_provider.dart';
import '../../view_model/code_verification_view_model.dart';
import '../../view_model/resend_code_view_model.dart';

class CodeInputView extends ConsumerStatefulWidget {
  const CodeInputView({super.key});

  @override
  ConsumerState<CodeInputView> createState() => _CodeInputViewState();
}

class _CodeInputViewState extends ConsumerState<CodeInputView> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async =>
      await ref.read(codeVerificationViewModelProvider.notifier).call();

  Future<void> _onResendCode() async {
    await ref.read(resendCodeViewModelProvider.notifier).call();
  }

  bool get _isCodeValid => _codeController.text.trim().isNotEmpty;

  void _updateCode() {
    ref
        .read(authStateProvider.notifier)
        .updateState(optCode: _codeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final timerCount = ref.watch(timerProvider);
    final codeVerificationState = ref.watch(codeVerificationViewModelProvider);
    final isLoading = codeVerificationState.isLoading;
    final errorMessage = codeVerificationState.error?.toString();

    final phoneNumber = ref.watch(authStateProvider).phone?.phoneNumber;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16.0,
        children: [
          const SizedBox(height: 8.0),
          Text(
            "Enter the 6-digit verification code sent to ${PhoneModel.formatPhoneNumber(phoneNumber)}",
          ),
          TextField(
            controller: _codeController,
            autofocus: true,
            enabled: !isLoading,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              _updateCode();
              setState(() {});
            },
            decoration: const InputDecoration(
              hintText: "Enter the 6-digit verification code",
              prefixIcon: Icon(Icons.security),
            ),
          ),
          TextButton(
            onPressed: timerCount == 0 && !isLoading ? _onResendCode : null,
            child: timerCount == 0
                ? const Text("Resend verification code")
                : Text("Resend code in $timerCount seconds"),
          ),
          ErrorMessageView(errorMessage: errorMessage),
          TubongeButton(
            text: "Verify Code",
            onPressed: _isCodeValid && !isLoading ? _onContinue : null,
            isLoading: isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
