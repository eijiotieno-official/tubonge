import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/auth_service_provider.dart';

final authStatusProvider = StreamProvider<bool>(
  (ref) {
    final authService = ref.watch(authServiceProvider);

    return authService.authStateChangesStream.asyncMap(
      (either) => either.fold(
        (error) => false,
        (isAuthenticated) => isAuthenticated,
      ),
    );
  },
);
