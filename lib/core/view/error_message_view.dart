import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorMessageView extends StatelessWidget {
  final String? errorMessage;
  const ErrorMessageView({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return errorMessage == null
        ? SizedBox.shrink()
        : Consumer(
            builder: (context, ref, child) {
              return SelectableText(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              );
            },
          );
  }
}
