import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../core/models/phone_model.dart';
import '../../../../core/views/error_message_view.dart';
import '../../model/provider/auth_state_provider.dart';

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
            onInputChanged: (phoneNumber) =>
                ref.read(authStateProvider.notifier).updateState(
                      phone: PhoneModel(
                        isoCode: phoneNumber.isoCode ?? "Next",
                        dialCode: phoneNumber.dialCode ?? "",
                        phoneNumber: phoneNumber.phoneNumber ?? "",
                      ),
                    ),
            autoFocus: true,
            autoFocusSearch: true,
            formatInput: true,
            inputDecoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            searchBoxDecoration: InputDecoration(
              hintText: "Search",
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            selectorTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            ),
            autoValidateMode: AutovalidateMode.disabled,
            selectorConfig: SelectorConfig(
              showFlags: true,
              trailingSpace: false,
              leadingPadding: 16.0,
              setSelectorButtonAsPrefixIcon: true,
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              useBottomSheetSafeArea: true,
            ),
          ),
          ErrorMessageView(errorMessage: errorMessage),
          const Spacer(),
          if (isLoading == false)
            FilledButton(
              onPressed: onTap,
              child: Text("Continue"),
            )
          else
            CircularProgressIndicator(),
          SizedBox(height: 2.0),
        ],
      ),
    );
  }
}
