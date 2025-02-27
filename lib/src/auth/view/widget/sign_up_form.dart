import 'dart:ui'; // for lerpDouble
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

class _SignUpFormState extends ConsumerState<SignUpForm>
    with TickerProviderStateMixin {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Gradually interpolate spacing between 16 and 24 for widths between 300 and 600.
        double spacing = constraints.maxWidth < 300
            ? 16.0
            : constraints.maxWidth > 600
                ? 24.0
                : lerpDouble(16, 24, (constraints.maxWidth - 300) / 300)!;

        // Gradually interpolate headline font size between 20 and 28.
        double headlineFontSize = constraints.maxWidth < 300
            ? 20.0
            : constraints.maxWidth > 600
                ? 28.0
                : lerpDouble(20, 28, (constraints.maxWidth - 300) / 300)!;

        // Gradually interpolate label font size between 14 and 16.
        double labelFontSize = constraints.maxWidth < 300
            ? 14.0
            : constraints.maxWidth > 600
                ? 16.0
                : lerpDouble(14, 16, (constraints.maxWidth - 300) / 300)!;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Aboard!",
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontSize: headlineFontSize),
                    ),
                    SizedBox(height: spacing / 2),
                    Text(
                      "Let's get you started with a new account.",
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontSize: labelFontSize),
                    ),
                  ],
                ),
                
                SizedBox(height: spacing),
                // Email Field
                TextFormField(
                  enabled: enabled,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),
                SizedBox(height: spacing),
                // Password Field
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
                SizedBox(height: spacing),
                // Confirm Password Field
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
                SizedBox(height: spacing),
                // Action Button or Loading Indicator
                if (!enabled)
                  Center(
                    child: CircularProgressIndicator(
                      strokeCap: StrokeCap.round,
                    ),
                  )
                else
                  FilledButton(
                    onPressed: _handleSignUp,
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                SizedBox(height: spacing),
                // Footer: Already have an account?
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontSize: labelFontSize),
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
          ),
        );
      },
    );
  }
}
