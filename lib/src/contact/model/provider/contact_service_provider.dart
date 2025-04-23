import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/cloud_functions_error_provider.dart';
import '../../../../core/utils/cloud_functions_error_util.dart';
import '../service/contact_service.dart';

/// A Riverpod provider for [ContactService].
/// This allows [ContactService] to be injected and reused throughout the app.
final contactServiceProvider = Provider<ContactService>(
  (ref) {
    // Watch the CloudFunctionsErrorUtil provider to handle cloud function errors
    final CloudFunctionsErrorUtil cloudFunctionsErrorUtil =
        ref.watch(cloudFunctionsErrorUtilProvider);

    // Return a new instance of ContactService with the error util injected
    return ContactService(cloudFunctionsErrorUtil: cloudFunctionsErrorUtil);
  },
);
