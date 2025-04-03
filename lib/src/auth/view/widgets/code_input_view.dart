import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/error_message_view.dart';
import '../../../../core/views/tubonge_filled_button.dart';
import '../../view_model/resend_code_view_model.dart';
import '../../model/provider/auth_state_provider.dart';
import '../../model/provider/timer_provider.dart';

class CodeInputView extends ConsumerWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onTap;
  const CodeInputView({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int timerCount = ref.watch(timerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16.0,
        children: [
          const SizedBox(height: 8.0),
          TextField(
            autofocus: true,
            enabled: !isLoading,
            decoration: InputDecoration(
              hintText: "Code",
            ),
            onChanged: (value) => ref
                .read(authStateProvider.notifier)
                .updateState(optCode: value),
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
          TubongeFilledButton(
            isExtended: true,
            isLoading: isLoading,
            onTap: onTap,
            text: "Confirm",
          ),
          const SizedBox(height: 2.0),
        ],
      ),
    );
  }
}
