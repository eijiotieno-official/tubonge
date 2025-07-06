import 'package:fl_dial_code_picker/fl_dial_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/phone_model.dart';
import '../../../../core/views/error_message_view.dart';
import '../../../../core/widgets/shared/tubonge_button.dart';
import '../../view_model/phone_verification_view_model.dart';

class PhoneInputView extends ConsumerStatefulWidget {
  const PhoneInputView({super.key});

  @override
  ConsumerState<PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends ConsumerState<PhoneInputView> {
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _countryController = TextEditingController();

  Country? _selectedCountry;

  Future<void> _showCountryPicker() async {
    final result = await FlDialCodePicker.show(
      context: context,
      pickerType: PickerType.responsive,
      initialCountry: _selectedCountry,
      showCloseButton: false,
    );

    if (result != null) {
      setState(() {
        _selectedCountry = result;
        _countryController.text = result.name;
      });
    }
  }

  String get _phoneNumber =>
      "${_selectedCountry?.dial}${_phoneController.text.trim()}";

  bool get _isPhoneValid =>
      _selectedCountry != null && _phoneController.text.isNotEmpty;

  Future<void> _onContinue() async {
    PhoneModel phone = PhoneModel(
      dialCode: _selectedCountry?.dial ?? "",
      isoCode: _selectedCountry?.code ?? "",
      phoneNumber: _phoneNumber,
    );

    await ref.read(phoneVerificationViewModelProvider.notifier).call(phone);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    AsyncValue phoneVerificationState =
        ref.watch(phoneVerificationViewModelProvider);

    bool isLoading = phoneVerificationState.isLoading;

    String? errorMessage = phoneVerificationState.error?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16.0,
        children: [
          SizedBox(height: 8.0),
          TextField(
            autofocus: false,
            controller: _countryController,
            readOnly: true,
            onTap: _showCountryPicker,
            decoration: InputDecoration(
              hintText: "Country",
            ),
          ),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              prefixText:
                  _selectedCountry != null ? "${_selectedCountry?.dial} " : "",
              prefixStyle: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              hintText: "Phone Number",
            ),
            onChanged: (value) {
              setState(() {});
            },
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          ErrorMessageView(errorMessage: errorMessage),
          const Spacer(),
          TubongeButton(
            text: "Continue",
            onPressed: _isPhoneValid ? _onContinue : null,
            isLoading: isLoading,
          ),
          SizedBox(height: 2.0),
        ],
      ),
    );
  }
}
