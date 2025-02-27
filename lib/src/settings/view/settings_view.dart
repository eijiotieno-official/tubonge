import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubonge/src/auth/controller/logout_controller.dart';

import '../../../core/widget/async_view.dart';
import '../../profile/provider/current_user_profile_provider.dart';
import '../../profile/view/profile_form_view.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserProfile = ref.watch(currentUserProfileProvider);
    return AsyncView(
      asyncValue: currentUserProfile,
      onData: (profile) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileFormView(profile: profile),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextButton(
              onPressed: () {
                ref.read(logoutProvider.notifier).call();
              },
              child: Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
