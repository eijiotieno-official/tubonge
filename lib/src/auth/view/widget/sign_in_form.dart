import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/toggle_sign_state_provider.dart';

class SignInForm extends ConsumerStatefulWidget {
  final Function(String email, String password) onSignIn;
  final bool enabled;
  const SignInForm({
    super.key,
    required this.onSignIn,
    required this.enabled,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  bool _obscurePassword = true;

  void _toggleObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _handleSignIn() async {
    // Trigger form validation
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool enabled = widget.enabled;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24.0,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16.0,
            children: [
              Text(
                "Hello Again!",
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                "We're happy to see you. Please sign in to continue.",
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          SizedBox(height: 20),
          TextFormField(
            enabled: enabled,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
            decoration: InputDecoration(
              labelText: "Email",
            ),
            onChanged: (value) => setState(() {}),
          ),
          TextFormField(
            enabled: enabled,
            controller: _passwordController,
            keyboardType: TextInputType.text,
            obscureText: _obscurePassword,
            validator: _passwordValidator,
            decoration: InputDecoration(
              labelText: "Password",
              suffixIcon: InkWell(
                onTap: _toggleObscurePassword,
                child: Icon(
                  _obscurePassword
                      ? Icons.remove_red_eye_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          if (!enabled)
            Center(
              child: CircularProgressIndicator(
                strokeCap: StrokeCap.round,
              ),
            )
          else
            FilledButton(
              onPressed: _handleSignIn,
              child: Text(
                "Sign In",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  "Don't have an account",
                  style: theme.textTheme.labelMedium,
                ),
              ),
              Flexible(
                child: TextButton(
                  onPressed: () {
                    if (enabled) {
                      ref.read(toggleSignStateProvider.notifier).state =
                          ToggleSignState.signUp;
                    }
                  },
                  child: Text("Create an account"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
