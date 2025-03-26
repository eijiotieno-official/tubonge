import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/contact/models/contact_model.dart';
import '../../src/contact/providers/contacts_provider.dart';
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
