import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widget/async_view.dart';
import '../../controller/auth_status_controller.dart';
import 'authenticated_view.dart';
import 'unauthenticated_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final authStatusState = ref.watch(authStatusProvider);

        return AsyncView(
          asyncValue: authStatusState,
          onData: (authenticated) {
            if (authenticated) {
              return AuthenticatedView();
            } else {
              return UnauthenticatedView();
            }
          },
        );
      },
    );
  }
}
