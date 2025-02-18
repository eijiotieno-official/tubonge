import 'package:flutter_riverpod/flutter_riverpod.dart';

final isUrlProvider = Provider(
  (ref) => (String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  },
);
