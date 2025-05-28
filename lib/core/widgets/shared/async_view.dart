import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'loading_indicator.dart';

class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onRetry;

  const AsyncView({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: builder,
      loading: () =>
          loadingWidget ?? const Center(child: TubongeLoadingIndicator()),
      error: (error, stackTrace) {
        if (errorBuilder != null) {
          return errorBuilder!(error, stackTrace);
        }
        return ErrorView(
          message: error.toString(),
          onRetry: onRetry,
        );
      },
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
