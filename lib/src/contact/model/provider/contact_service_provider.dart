import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/cloud_functions_error_provider.dart';
import '../../../../core/utils/cloud_functions_error_util.dart';
import '../service/contact_service.dart';

final contactServiceProvider = Provider<ContactService>(
  (ref) {
    final CloudFunctionsErrorUtil cloudFunctionsErrorUtil =
        ref.watch(cloudFunctionsErrorUtilProvider);

    return ContactService(cloudFunctionsErrorUtil: cloudFunctionsErrorUtil);
  },
);
