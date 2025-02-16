import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/toggle_sign_state_provider.dart';

class SignUpForm extends ConsumerStatefulWidget {
  final Function(String email, String password) onSignUp;
  final bool enabled;
  const SignUpForm({
    super.key,
    required this.onSignUp,
    required this.enabled,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
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
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _obscurePassword = true;

  void _toggleObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _handleSignUp() async {
    // Trigger form validation
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignUp(
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
                "Welcome Aboard!",
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                "Let's get you started with a new account.",
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
          ),
          TextFormField(
            enabled: enabled,
            controller: _passwordController,
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
          ),
          TextFormField(
            enabled: enabled,
            controller: _confirmPasswordController,
            obscureText: _obscurePassword,
            validator: _confirmPasswordValidator,
            decoration: InputDecoration(
              labelText: "Confirm Password",
              suffixIcon: InkWell(
                onTap: _toggleObscurePassword,
                child: Icon(
                  _obscurePassword
                      ? Icons.remove_red_eye_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
          ),
          if (!enabled)
            Center(
              child: CircularProgressIndicator(
                strokeCap: StrokeCap.round,
              ),
            )
          else
            FilledButton(
              onPressed: _handleSignUp,
              child: Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Already have an account?",
                style: theme.textTheme.labelMedium,
              ),
              TextButton(
                onPressed: () {
                  if (enabled) {
                    ref.read(toggleSignStateProvider.notifier).state =
                        ToggleSignState.signIn;
                  }
                },
                child: Text("Sign In"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
