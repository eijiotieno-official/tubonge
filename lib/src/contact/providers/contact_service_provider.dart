import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/cloud_functions_error_provider.dart';
import '../services/contact_service.dart';

final contactServiceProvider = Provider<ContactService>((ref) {
  final cloudFunctionsErrorService = ref.watch(cloudFunctionsErrorServiceProvider);
  return ContactService(cloudFunctionsErrorService: cloudFunctionsErrorService);
});
