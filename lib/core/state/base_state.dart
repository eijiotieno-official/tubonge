import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseState<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  const BaseState({
    this.data,
    this.error,
    this.isLoading = false,
  });

  BaseState<T> copyWith({
    T? data,
    String? error,
    bool? isLoading,
  });

  bool get hasError => error != null;
  bool get hasData => data != null;
  bool get isInitial => !isLoading && !hasError && !hasData;
}

class AsyncState<T> extends BaseState<T> {
  const AsyncState({
    super.data,
    super.error,
    super.isLoading,
  });

  factory AsyncState.initial() => const AsyncState();
  factory AsyncState.loading() => const AsyncState(isLoading: true);
  factory AsyncState.error(String error) => AsyncState(error: error);
  factory AsyncState.data(T data) => AsyncState(data: data);

  @override
  AsyncState<T> copyWith({
    T? data,
    String? error,
    bool? isLoading,
  }) {
    return AsyncState(
      data: data ?? this.data,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  AsyncState<T> fromAsyncValue(AsyncValue<T> value) {
    return value.when(
      data: (data) => AsyncState.data(data),
      error: (error, _) => AsyncState.error(error.toString()),
      loading: () => AsyncState.loading(),
    );
  }
}
