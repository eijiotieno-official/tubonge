import 'package:fl_dial_code_picker/fl_dial_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/phone_model.dart';
import '../../../../core/views/error_message_view.dart';
import '../../../../core/widgets/shared/tubonge_button.dart';
import '../../model/provider/auth_state_provider.dart';
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

  @override
  void dispose() {
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _showCountryPicker() async {
    final result = await FlDialCodePicker.show(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pickerType: PickerType.responsive,
      initialCountry: _selectedCountry,
      showCloseButton: false,
      accentColor: Theme.of(context).colorScheme.primary,
      searchDecoration: InputDecoration(
        hintText: "Search country",
        prefixIcon: const Icon(Icons.search),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCountry = result;
        _countryController.text = result.name;
      });
      _updatePhone();
    }
  }

  void _updatePhone() {
    final phone = PhoneModel(
      dialCode: _selectedCountry?.dial ?? "",
      isoCode: _selectedCountry?.code ?? "",
      phoneNumber: "${_selectedCountry?.dial}${_phoneController.text.trim()}",
    );
    ref.read(authStateProvider.notifier).updateState(phone: phone);
  }

  bool get _isPhoneValid =>
      _selectedCountry != null &&
      _phoneController.text.trim().isNotEmpty &&
      _phoneController.text.trim().length >= 7;

  Future<void> _onContinue() async =>
      await ref.read(phoneVerificationViewModelProvider.notifier).call();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final phoneVerificationState =
        ref.watch(phoneVerificationViewModelProvider);

    final isLoading = phoneVerificationState.isLoading;

    final errorMessage = phoneVerificationState.error?.toString();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: 16.0,
        children: [
          const SizedBox(height: 8.0),
          Text(
            "Enter your phone number to receive a verification code via SMS",
          ),
          TextField(
            controller: _countryController,
            readOnly: true,
            enabled: !isLoading,
            onTap: _showCountryPicker,
            decoration: InputDecoration(
              hintText: "Select your country",
              prefixIcon: Icon(Icons.flag),
            ),
          ),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            enabled: !isLoading && _selectedCountry != null,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              _updatePhone();
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: _selectedCountry != null
                  ? "Enter your phone number"
                  : "Please select your country first",
              prefixText:
                  _selectedCountry != null ? "${_selectedCountry!.dial} " : "",
              prefixStyle: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ErrorMessageView(errorMessage: errorMessage),
          TubongeButton(
            text: "Send Verification Code",
            onPressed: _isPhoneValid && !isLoading ? _onContinue : null,
            isLoading: isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

mixin PhoneValidationMixin {
  static bool isValidPhoneFormat(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 7 && digitsOnly.length <= 15;
  }

  static String? validatePhoneModel(PhoneModel? phone) {
    if (phone == null) return "Phone number is required";
    if (phone.dialCode.isEmpty) return "Country code is required";
    if (phone.phoneNumber.isEmpty) return "Phone number is required";
    if (!isValidPhoneFormat(phone.phoneNumber)) {
      return "Please enter a valid phone number";
    }
    return null;
  }
}
