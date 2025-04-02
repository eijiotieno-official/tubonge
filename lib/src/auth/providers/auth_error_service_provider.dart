import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_error_service.dart';

final authErrorServiceProvider = Provider<AuthErrorService>((ref) {
  return AuthErrorService();
});