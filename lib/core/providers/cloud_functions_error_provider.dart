import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/cloud_functions_error_util.dart';

/// A Riverpod provider that supplies an instance of [CloudFunctionsErrorUtil],
/// which is used to handle errors related to Firebase Cloud Functions.
final cloudFunctionsErrorUtilProvider =
    Provider<CloudFunctionsErrorUtil>((ref) {
  // Create and return a new instance of CloudFunctionsErrorUtil
  return CloudFunctionsErrorUtil();
});
