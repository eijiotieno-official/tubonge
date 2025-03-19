import 'package:flutter/material.dart';

class ErrorMessageView extends StatelessWidget {
  final String? errorMessage;
  const ErrorMessageView({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return errorMessage == null
        ? SizedBox.shrink()
        : SelectableText(
          errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.error,
          ),
        );
  }
}
