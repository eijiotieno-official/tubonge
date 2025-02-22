import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) {
    return ProfileService();
  },
);
