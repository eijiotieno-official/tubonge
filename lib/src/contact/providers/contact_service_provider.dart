import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/contact_service.dart';

final contactServiceProvider = Provider<ContactService>((ref) {
  return ContactService();
});
