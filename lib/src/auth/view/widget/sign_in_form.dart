import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widget/animated_text_view.dart';
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

class _SignInFormState extends ConsumerState<SignInForm>
    with TickerProviderStateMixin {
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
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = constraints.maxWidth < 300
            ? 16.0
            : constraints.maxWidth > 600
                ? 24.0
                : lerpDouble(16, 24, (constraints.maxWidth - 300) / 300)!;

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
                // Header texts with animated text style
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedText(
                      text: "Hello Again!",
                      isTitle: true,
                    ),
                    SizedBox(height: spacing / 2),
                    AnimatedText(
                        text:
                            "We're happy to see you. Please sign in to continue."),
                  ],
                ),
                SizedBox(height: spacing),
                TextFormField(
                  enabled: widget.enabled,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailValidator,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: spacing),
                TextFormField(
                  enabled: widget.enabled,
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
                SizedBox(height: spacing),
                if (!widget.enabled)
                  Center(
                    child: CircularProgressIndicator(
                      strokeCap: StrokeCap.round,
                    ),
                  )
                else
                  FilledButton(
                    onPressed: _handleSignIn,
                    child: const AnimatedText(text: "Sign In"),
                  ),
                SizedBox(height: spacing),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: AnimatedText(text: "Don't have an account")),
                    Flexible(
                      child: TextButton(
                        onPressed: () {
                          if (widget.enabled) {
                            ref.read(toggleSignStateProvider.notifier).state =
                                ToggleSignState.signUp;
                          }
                        },
                        child: const AnimatedText(text: "Create an account"),
                      ),
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
