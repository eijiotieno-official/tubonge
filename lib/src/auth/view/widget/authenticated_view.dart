import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widget/async_view.dart';
import '../../../../core/widget/home_view.dart';
import '../../../profile/model/profile_model.dart';
import '../../../profile/provider/current_user_profile_provider.dart';
import '../../../profile/view/profile_form_view.dart';

class AuthenticatedView extends StatelessWidget {
  const AuthenticatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final currentUserProfileAsyncValue =
            ref.watch(currentUserProfileProvider);

        return AsyncView(
          asyncValue: currentUserProfileAsyncValue,
          onData: (profile) {
            final shouldCreateProfile = profile.isNotEmpty == false;

            return shouldCreateProfile
                ? ProfileFormView(
                    profile: Profile.empty
                        .copyWith(id: FirebaseAuth.instance.currentUser?.uid),
                  )
                : HomeView();
          },
        );
      },
    );
  }
}
