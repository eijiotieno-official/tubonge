import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> _onContinue() async {
    await ref.read(codeVerificationViewModelProvider.notifier).call(
          _codeController.text.trim(),
        );
  }

  bool get _isCodeValid => _codeController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    int timerCount = ref.watch(timerProvider);

    AsyncValue codeVerificationState =
        ref.watch(codeVerificationViewModelProvider);

    bool isLoading = codeVerificationState.isLoading;

    String? errorMessage = codeVerificationState.error?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16.0,
        children: [
          const SizedBox(height: 8.0),
          TextField(
            controller: _codeController,
            autofocus: true,
            enabled: !isLoading,
            decoration: InputDecoration(
              hintText: "Code",
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          TextButton(
            onPressed: timerCount == 0
                ? () async =>
                    await ref.read(resendCodeViewModelProvider.notifier).call()
                : null,
            child: timerCount == 0
                ? const Text("Resend Code")
                : Text("Resend Code in $timerCount seconds"),
          ),
          ErrorMessageView(errorMessage: errorMessage),
          const Spacer(),
          TubongeButton(
            text: "Continue",
            onPressed: _isCodeValid ? _onContinue : null,
            isLoading: isLoading,
          ),
          const SizedBox(height: 2.0),
        ],
      ),
    );
  }
}
