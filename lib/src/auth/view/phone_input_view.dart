import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneInputView extends StatelessWidget {
  final TextEditingController controller;
  final Function(PhoneNumber) onInputChanged;
  const PhoneInputView(
      {super.key, required this.controller, required this.onInputChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InternationalPhoneNumberInput(
          textFieldController: controller,
          isEnabled: true,
          onInputChanged: onInputChanged,
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
          autoValidateMode: AutovalidateMode.always,
          selectorConfig: SelectorConfig(
            showFlags: true,
            setSelectorButtonAsPrefixIcon: true,
            selectorType: PhoneInputSelectorType.DIALOG,
            trailingSpace: false,
          ),
        ),
      ],
    );
  }
}
