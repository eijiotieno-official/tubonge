import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/view/error_message_view.dart';
import '../../../core/view/tubonge_filled_button.dart';
import '../provider/auth_service_provider.dart';

// here, show resend code when the timer has completed the count down to 60 seconds, othersie show a text widget showing the count down :

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        spacing: 16.0,
        children: [
          SizedBox(height: 8.0),
          OtpTextField(
            autoFocus: true,
            enabled: isLoading == false,
            numberOfFields: 6,
            focusedBorderColor: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8.0),
            showFieldAsBox: false,
            onSubmit: (String code) {
              ref.read(otpCodeProvider.notifier).state = code;
              debugPrint(code);
            },
          ),
          TextButton(onPressed: () {}, child: Text("Resend Code")),
          ErrorMessageView(errorMessage: errorMessage),
          const Spacer(),
          TubongeFilledButton(
            isExtended: true,
            isLoading: isLoading,
            onTap: onTap,
            text: "Confirm",
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
