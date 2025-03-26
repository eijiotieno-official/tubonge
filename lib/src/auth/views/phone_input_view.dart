import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../core/views/error_message_view.dart';
import '../../../core/views/tubonge_filled_button.dart';
import '../../../core/models/phone_model.dart';
import '../providers/auth_service_provider.dart';

class PhoneInputView extends ConsumerWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onTap;
  const PhoneInputView({
    super.key,
    this.errorMessage,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16.0,
        children: [
          SizedBox(height: 8.0),
          InternationalPhoneNumberInput(
            isEnabled: isLoading == false,
            onInputChanged: (phoneNumber) {
              ref.read(phoneNumberProvider.notifier).state = PhoneModel(
                isoCode: phoneNumber.isoCode ?? "",
                dialCode: phoneNumber.dialCode ?? "",
                phoneNumber: phoneNumber.phoneNumber ?? "",
              );
            },
            autoFocus: true,
            autoFocusSearch: true,
            formatInput: true,
            selectorTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            autoValidateMode: AutovalidateMode.disabled,
            selectorConfig: SelectorConfig(
              showFlags: true,
              setSelectorButtonAsPrefixIcon: true,
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              trailingSpace: false,
            ),
          ),
          ErrorMessageView(errorMessage: errorMessage),
          const Spacer(),
          TubongeFilledButton(
            isExtended: true,
            isLoading: isLoading,
            onTap: onTap,
            text: "Next",
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
