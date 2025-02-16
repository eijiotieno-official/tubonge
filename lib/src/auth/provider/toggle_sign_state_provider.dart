import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ToggleSignState {
  signIn,
  signUp,
}

final toggleSignStateProvider = StateProvider<ToggleSignState>(
  (ref) {
    return ToggleSignState.signIn;
  },
);
