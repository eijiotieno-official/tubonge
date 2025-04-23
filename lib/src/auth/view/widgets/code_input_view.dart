import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/error_message_view.dart';
import '../../../../core/views/tubonge_filled_button.dart';
import '../../view_model/resend_code_view_model.dart';
import '../../model/provider/auth_state_provider.dart';
import '../../model/provider/timer_provider.dart';

/// Widget for inputting OTP code during phone number verification process.
class CodeInputView extends ConsumerWidget {
  final bool
      isLoading; // Indicates if a request (e.g. confirmation) is in progress
  final String? errorMessage; // Optional error message to display
  final VoidCallback?
      onTap; // Callback to be triggered when the user confirms the code

  const CodeInputView({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the countdown timer for resending the OTP
    final int timerCount = ref.watch(timerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16.0, // Adds spacing between children
        children: [
          const SizedBox(height: 8.0),

          /// TextField for user to input OTP code
          TextField(
            autofocus: true, // Focus this field when the widget loads
            enabled: !isLoading, // Disable input when loading
            decoration: InputDecoration(
              hintText: "Code",
            ),
            // Save the input value to the auth state (optCode)
            onChanged: (value) => ref
                .read(authStateProvider.notifier)
                .updateState(optCode: value),
          ),

          /// Button to resend OTP, only enabled if timer reaches 0
          TextButton(
            onPressed: timerCount == 0
                ? () async =>
                    await ref.read(resendCodeViewModelProvider.notifier).call()
                : null,
            child: timerCount == 0
                ? const Text("Resend Code")
                : Text("Resend Code in $timerCount seconds"),
          ),

          /// Display error message if any
          ErrorMessageView(errorMessage: errorMessage),

          const Spacer(), // Pushes the confirm button to the bottom

          /// Confirm button to submit the entered code
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
