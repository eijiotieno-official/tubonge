import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/contact/model/base/contact_model.dart';
import '../../src/contact/view_model/contacts_view_model.dart';
import 'user_service_provider.dart';

final userInfoProvider = StreamProvider.family<ContactModel, String>(
  (ref, userId) {
    final userService = ref.watch(userServiceProvider);

    final registeredContacts = ref.watch(contactsProvider);

    return registeredContacts.when(
      data: (contacts) {
        final contact = contacts.firstWhereOrNull((c) => c.id == userId);

        if (contact != null) {
          return Stream.value(contact);
        } else {
          return userService.streamUser(userId).map(
            (either) {
              return either.fold(
                (error) => throw error,
                (user) => ContactModel(
                  id: userId,
                  name: user.phone.phoneNumber,
                  phoneNumbers: [user.phone],
                  photo: user.photo,
                ),
              );
            },
          );
        }
      },
      loading: () => const Stream.empty(),
      error: (error, stack) => Stream.error(error),
    );
  },
);
