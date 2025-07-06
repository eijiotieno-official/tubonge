import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/base/auth_state_model.dart';
import '../../model/provider/auth_state_provider.dart';
import '../widgets/code_input_view.dart';
import '../widgets/phone_input_view.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authStateValue = ref.watch(authStateProvider);

    final bool showCodeInput = authStateValue.verificationId != null;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(showCodeInput ? "Verification Code" : "Phone Number"),
        ),
        body: showCodeInput ? CodeInputView() : PhoneInputView(),
      ),
    );
  }
}
