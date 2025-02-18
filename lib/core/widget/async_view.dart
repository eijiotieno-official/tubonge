import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) onData;
  final Widget? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? onError;

  const AsyncView({
    super.key,
    required this.asyncValue,
    required this.onData,
    this.onError,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: asyncValue.when(
        data: onData,
        loading: () => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(asyncValue.toString()),
            loading ??
                Center(
                  child: CircularProgressIndicator(
                    strokeCap: StrokeCap.round,
                  ),
                ),
          ],
        ),
        error: (error, stackTrace) =>
            onError?.call(error, stackTrace) ??
            Center(
              child: SelectableText(
                'Unexpected error: $error',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
      ),
    );
  }
}
