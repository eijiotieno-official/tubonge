import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/cloud_functions_error_util.dart';

final cloudFunctionsErrorUtilProvider =
    Provider<CloudFunctionsErrorUtil>((ref) {
  return CloudFunctionsErrorUtil();
});
