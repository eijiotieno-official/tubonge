import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_service_provider.dart';

final authStatusProvider = StreamProvider.autoDispose<bool>(
  (ref) {
    final authService = ref.watch(authServiceProvider);

    final status = authService.authStateChangesStream;

    return status.map(
      (either) => either.fold(
        (error) => false,
        (isAuthenticated) => isAuthenticated,
      ),
    );
  },
);
