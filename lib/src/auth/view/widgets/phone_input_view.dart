import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../core/models/phone_model.dart';
import '../../../../core/views/error_message_view.dart';
import '../../../../core/views/tubonge_filled_button.dart';
import '../../model/provider/auth_state_provider.dart';

/// A widget that provides a phone number input field and a confirmation button.
class PhoneInputView extends ConsumerWidget {
  final bool isLoading; // Determines if the UI should show loading state
  final String? errorMessage; // Optional error message to display
  final VoidCallback? onTap; // Callback when "Next" button is pressed

  const PhoneInputView({
    super.key,
    this.errorMessage,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Horizontal padding around content
      child: Column(
        spacing:
            16.0, // Custom spacing between children (may not work without MainAxisAlignment)
        children: [
          SizedBox(height: 8.0), // Spacer at the top

          /// International phone input field using a package
          InternationalPhoneNumberInput(
            isEnabled: isLoading == false, // Disable when loading
            onInputChanged: (phoneNumber) =>
                ref.read(authStateProvider.notifier).updateState(
                      phone: PhoneModel(
                        isoCode: phoneNumber.isoCode ?? "",
                        dialCode: phoneNumber.dialCode ?? "",
                        phoneNumber: phoneNumber.phoneNumber ?? "",
                      ),
                    ), // Updates state with new phone data
            autoFocus: true,
            autoFocusSearch: true,
            formatInput: true, // Formats input to match phone number format
            searchBoxDecoration: InputDecoration(
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
              setSelectorButtonAsPrefixIcon: true,
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              trailingSpace: false,
              useBottomSheetSafeArea: true,
            ),
          ),

          /// Displays any error message passed to the widget
          ErrorMessageView(errorMessage: errorMessage),

          const Spacer(), // Pushes the "Next" button to the bottom of the column

          /// Button to continue to the next step
          TubongeFilledButton(
            isExtended: true,
            isLoading: isLoading,
            onTap: onTap,
            text: "Next",
          ),

          SizedBox(height: 2.0), // Small space after button
        ],
      ),
    );
  }
}
