import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TubongeInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final bool readOnly;

  const TubongeInput({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.borderRadius,
    this.focusNode,
    this.onTap,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderRadius = BorderRadius.circular(8.0);
    final defaultPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    );

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      focusNode: focusNode,
      onTap: onTap,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      validator: validator,
      readOnly: readOnly,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: contentPadding ?? defaultPadding,
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
    );
  }
}
