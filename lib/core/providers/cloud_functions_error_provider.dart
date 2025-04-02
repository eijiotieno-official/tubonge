

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/cloud_functions_error_service.dart';

final cloudFunctionsErrorServiceProvider = Provider<CloudFunctionsErrorService>((ref) {
  return CloudFunctionsErrorService();
});